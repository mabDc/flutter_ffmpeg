part of 'package:flutter_ffmpeg/ffmpeg.dart';

class FfmpegStream implements _IsolateEncodable {
  _CodecContext __codec;
  final int index;
  Pointer<AVStream> _p;
  FfmpegStream._new(this.index, this._p);
  _CodecContext get _codec {
    if (_p == null) throw Exception("StreamInfo destroyed");
    if (__codec == null) __codec = _CodecContext._new(_p.codecpar);
    return __codec;
  }

  get codecType => _p.codecpar.codec_type;

  int _getFramePts(Frame frame) {
    return getFrameTimeMillisecond(frame._value, _p);
  }

  @override
  Map _encode() => {#streamIndex: index, #streamCodecType: codecType};

  void _close() {
    if (__codec != null) __codec._close();
    __codec = null;
  }
}

class _AudioCodecContext extends _CodecContext {
  Pointer<Pointer<SwrContext>> _swrCtx;
  int _srcChannelLayout = -1;
  int _srcFormat = -1;
  int _srcSampleRate = -1;
  _AudioClient _audio;

  Pointer<Pointer<Uint8>> _buffer;
  Pointer<Pointer<Uint8>> _buffer1;
  Pointer<Uint32> _bufferLen;
  Pointer<Uint32> _bufferLen1;

  @override
  Future _playFrame(_PlayFrame frame, Future delay) {
    final srcChannelLayout = frame.frame._value.channel_layout;
    final srcFormat = frame.frame._value.format;
    final srcSampleRate = frame.frame._value.sample_rate;
    if (_audio == null) {
      _audio = _AudioClient();
      _audio.start();
    }
    if (_swrCtx == null) {
      _swrCtx = allocate();
      _swrCtx.value = Pointer.fromAddress(0);
    }
    if (_swrCtx.value.address == 0 ||
        _srcChannelLayout != srcChannelLayout ||
        _srcFormat != srcFormat ||
        _srcSampleRate != srcSampleRate) {
      if (_swrCtx.value.address != 0) swr_free(_swrCtx);
      _swrCtx.value = swr_alloc_set_opts(
          Pointer.fromAddress(0),
          av_get_default_channel_layout(_audio.channels),
          _audio.format,
          _audio.sampleRate,
          frame.frame._value.channel_layout,
          frame.frame._value.format,
          frame.frame._value.sample_rate,
          0,
          Pointer.fromAddress(0));
      if (_swrCtx.value.address == 0 || swr_init(_swrCtx.value) < 0)
        throw Exception("cannot create SwrContext");
      _srcChannelLayout = srcChannelLayout;
      _srcFormat = srcFormat;
      _srcSampleRate = srcSampleRate;
    }
    if (_buffer == null || _buffer.value.address == 0) {
      _buffer = allocate();
      _buffer.value = Pointer.fromAddress(0);
    }
    if (_bufferLen == null || _bufferLen.address == 0) {
      _bufferLen = allocate();
      _bufferLen.value = 0;
    }
    final inp = frame.frame._value.extended_data;
    final inCount = frame.frame._value.nb_samples;
    final outCount = inCount * _audio.sampleRate ~/ _srcSampleRate + 256;
    final outSize = av_samples_get_buffer_size(
        Pointer.fromAddress(0), _audio.channels, outCount, _audio.format, 0);
    if (outSize < 0) throw Exception("av_samples_get_buffer_size failed");
    av_fast_malloc(_buffer, _bufferLen, outSize);
    if (_buffer.value.address == 0) throw Exception("av_fast_malloc failed");
    final nbSamples = swr_convert(_swrCtx.value, _buffer, outCount, inp, inCount);
    // swap buffer -> buffer1
    final buffer = _buffer;
    final bufferLen = _bufferLen;
    _buffer = _buffer1;
    _bufferLen = _bufferLen1;
    _buffer1 = buffer;
    _bufferLen1 = bufferLen;
    return Future.value(delay).then((_) => _audio.writeBuffer(
          buffer.value,
          nbSamples,
          av_get_bytes_per_sample(_audio.format) * _audio.channels,
          frame.pts,
          frame.timeStamp,
        ));
  }

  @override
  void _close() {
    super._close();
    if (_audio != null) {
      _audio.stop();
      _audio.close();
      _audio = null;
    }
    if (_swrCtx != null) {
      if (_swrCtx.value.address != null) swr_free(_swrCtx);
      free(_swrCtx);
      _swrCtx = null;
    }
  }
}

class _VideoCodecContext extends _CodecContext {
  Frame _frame;
  _IsolateFunction _onFrame;
  Frame _createFrame(int fmt, _IsolateFunction onFrame) {
    if (_ctx == null) throw Exception("CodecContext destroyed");
    if (_frame != null) _frame.close();
    _freeSwsCtx();
    _onFrame = onFrame;
    _frame = Frame._new();
    _frame._fmt = fmt;
    _frame._width = _ctx.value.width;
    _frame._height = _ctx.value.height;
    final bufSize = av_image_get_buffer_size(fmt, _frame._width, _frame._height, 1);
    _frame._buffer = allocate<Uint8>(count: bufSize);
    av_image_fill_arrays(
        _frame._value.data, // dst data[]
        _frame._value.linesize, // dst linesize[]
        _frame._buffer, // src buffer
        fmt, // pixel format
        _frame._width, // width
        _frame._height, // height
        1 // align
        );
    return _frame;
  }

  Pointer<SwsContext> _swsCtx;
  void _freeSwsCtx() {
    if (_swsCtx != null && _swsCtx.address != 0) {
      sws_freeContext(_swsCtx);
    }
    _swsCtx = null;
  }

  @override
  void _close() {
    super._close();
    _freeSwsCtx();
  }

  @override
  Future _playFrame(_PlayFrame frame, Future delay) async {
    if (_ctx == null || _ctx.address == 0) return;
    if (_swsCtx == null || _swsCtx.address == 0) {
      _swsCtx = sws_getContext(
          _ctx.value.width, // src width
          _ctx.value.height, // src height
          _ctx.value.pix_fmt, // src format
          _frame._width, // dst width
          _frame._height, // dst height
          _frame._fmt, // dst format
          SWS_POINT, // flags
          Pointer.fromAddress(0), // src filter
          Pointer.fromAddress(0), // dst filter
          Pointer.fromAddress(0) // param
          );
    }
    if (_swsCtx == null || _swsCtx.address == 0)
      throw Exception("cannot create SwsContext");
    await delay;
    sws_scale(
        _swsCtx, // sws context
        frame.frame._value.data, // src slice
        frame.frame._value.linesize, // src stride
        0, // src slice y
        _frame._height, // src slice height
        _frame._value.data, // dst planes
        _frame._value.linesize // dst strides
        );
    if (_onFrame != null) _onFrame([]);
  }
}

abstract class _CodecContext {
  Pointer<Pointer<AVCodecContext>> _ctx;

  static _new(Pointer<AVCodecParameters> codecpar) {
    final pCodec = avcodec_find_decoder(codecpar.codec_id);
    if (pCodec.address == 0) throw Exception("avcodec_find_decoder failed");
    final pCodecCtx = allocate<Pointer<AVCodecContext>>();
    pCodecCtx.value = avcodec_alloc_context3(pCodec);
    var ret = avcodec_parameters_to_context(pCodecCtx.value, codecpar);
    if (ret != 0) throw Exception("avcodec_parameters_to_context failed: $ret");
    ret = avcodec_open2(pCodecCtx.value, pCodec, Pointer.fromAddress(0));
    if (ret != 0) throw Exception("avcodec_open2 failed: $ret");
    switch (codecpar.codec_type) {
      case AVMediaType.AVMEDIA_TYPE_AUDIO:
        return _AudioCodecContext().._ctx = pCodecCtx;
      case AVMediaType.AVMEDIA_TYPE_VIDEO:
        return _VideoCodecContext().._ctx = pCodecCtx;
    }
  }

  Future _playFrame(_PlayFrame frame, Future delay);

  void _close() {
    if (_ctx == null) return;
    avcodec_free_context(_ctx);
    free(_ctx);
    _ctx = null;
  }
}

class Frame implements _IsolateEncodable {
  int _fmt;
  Pointer<Pointer<AVFrame>> _p;
  Pointer<AVFrame> get _value => _p.value;
  Pointer<Uint8> _buffer;
  get buffer => _buffer;
  int _width;
  get width => _width;
  int _height;
  get height => _height;
  Frame._new() {
    _p = allocate<Pointer<AVFrame>>();
    _p.value = av_frame_alloc();
  }

  void close() {
    if (_p == null) return;
    if (_buffer != null) free(_buffer);
    _buffer = null;
    av_frame_free(_p);
    free(_p);
    _p = null;
  }

  @override
  Map _encode() => {
        #frameWidth: _width,
        #frameHeight: _height,
        #frameBuffer: _buffer.address,
      };
}

class _PlayFrame {
  final _PTS pts;
  final int timeStamp;
  final Frame frame;
  final _CodecContext codec;
  _PlayFrame(this.timeStamp, this.frame, this.codec, this.pts);
}

class _PTS {
  int _relate = 0;
  int _absolute = DateTime.now().millisecondsSinceEpoch;

  update(int relate) {
    _relate = relate;
    _absolute = DateTime.now().millisecondsSinceEpoch;
  }

  ptsNow() => (DateTime.now().millisecondsSinceEpoch - _absolute) + _relate;
}

class FormatContext {
  final String url;
  Pointer<Pointer<AVFormatContext>> _ctx;
  List<FfmpegStream> _streams;

  FormatContext(this.url) {
    _ctx = allocate<Pointer<AVFormatContext>>();
    _ctx.value = Pointer.fromAddress(0);
    final _url = Utf8.toUtf8(url);
    int ret =
        avformat_open_input(_ctx, _url, Pointer.fromAddress(0), Pointer.fromAddress(0));
    free(_url);
    if (ret != 0) throw Exception("avformat_open_input failed: $ret");
  }

  void _checkCtx() {
    if (_ctx == null || _ctx.value.address == 0)
      throw Exception("context not initialized");
  }

  _PTS _pts;
  Future _playing;

  Future play(
    List<FfmpegStream> streams,
  ) async {
    await stop();
    _playing = _play(streams);
    return _playing;
  }

  Future stop() {
    _pts = null;
    return _playing;
  }

  Future _play(
    List<FfmpegStream> streams,
  ) async {
    final pts = _PTS().._relate = 0;
    _pts = pts;
    final playing = () => _pts == pts;
    final packet = allocate<Uint8>(count: ffiSizeOf<AVPacket>()).cast<AVPacket>();
    var frame = Frame._new();
    try {
      Map<FfmpegStream, Future Function(_PlayFrame)> streamUpdators = {};
      streams.forEach((stream) {
        Future lastUpdate;
        streamUpdators[stream] = (_PlayFrame frame) {
          final _lastUpdate = lastUpdate;
          final ptsNow = pts.ptsNow();
          final timeStamp = frame.timeStamp;
          final comp = () => frame.codec._playFrame(frame, _lastUpdate);
          lastUpdate = stream._p.codecpar.codec_type == AVMediaType.AVMEDIA_TYPE_VIDEO &&
                  timeStamp > ptsNow
              ? Future.delayed(Duration(milliseconds: timeStamp - ptsNow),
                  () => playing() ? comp() : null)
              : comp();
          lastUpdate.then((_) {
            frame.frame.close();
          });
          return _lastUpdate;
        };
      });

      while (playing() && _ctx != null && av_read_frame(_ctx.value, packet) == 0) {
        final streamIndex = packet.stream_index;
        final stream =
            streams.firstWhere((s) => s.index == streamIndex, orElse: () => null);
        if (stream != null) {
          var ret = avcodec_send_packet(stream._codec._ctx.value, packet);
          if (ret != 0) throw Exception("avcodec_send_packet failed: $ret");
          if (0 ==
              avcodec_receive_frame(
                stream._codec._ctx.value,
                frame._value,
              )) {
            final timeStamp = stream._getFramePts(frame);
            await streamUpdators[stream]
                .call(_PlayFrame(timeStamp, frame, stream._codec, pts));
            frame = Frame._new();
          }
        }
        av_packet_unref(packet);
        await Future.delayed(Duration.zero);
      }
    } finally {
      _pts = null;
      frame.close();
      free(packet);
    }
  }

  Frame createFrame(FfmpegStream stream, void onFrame()) {
    return _createFrame(stream, _IsolateFunction._new((_) {
      onFrame();
    }));
  }

  Frame _createFrame(FfmpegStream stream, _IsolateFunction onFrame) {
    return (stream._codec as _VideoCodecContext)._createFrame(AV_PIX_FMT_RGBA, onFrame);
  }

  List<FfmpegStream> getStreams() {
    _checkCtx();
    if (_streams == null) {
      final ret = avformat_find_stream_info(_ctx.value, Pointer.fromAddress(0));
      if (ret != 0) throw Exception("avformat_find_stream_info failed: $ret");
      _streams = [];
      final nbStreams = _ctx.value.nb_streams;
      final streams = _ctx.value.streams;
      for (var i = 0; i < nbStreams; ++i) {
        final stream = streams.elementAt(i).value;
        _streams.add(FfmpegStream._new(i, stream));
      }
    }
    return _streams;
  }

  close() async {
    if (_ctx == null || _ctx.value.address == 0) return;
    _streams.forEach((s) => s._close());
    avformat_close_input(_ctx);
    free(_ctx);
    _ctx = null;
  }
}
