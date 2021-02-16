import 'dart:collection';
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:flutter_ffmpeg/ffi.dart';

import 'audio.dart';

class StreamInfo {
  int index;
  int codecType;
  Pointer<AVCodecParameters> _codecpar;
  CodecContext _codec;
  double timebase;
  CodecContext get codec {
    if (_codecpar == null) throw Exception("StreamInfo destroyed");
    if (_codec == null) _codec = CodecContext._new(_codecpar);
    return _codec;
  }

  int getFramePts(Frame frame) {
    return (timebase * frame._value.best_effort_timestamp * 1000).toInt();
  }

  void close() {
    if (_codec != null) _codec.close();
    _codec = null;
    _codecpar = null;
  }
}

class AudioCodecContext extends CodecContext {
  Pointer<Pointer<SwrContext>> _swrCtx;
  int _srcChannelLayout = -1;
  int _srcFormat = -1;
  int _srcSampleRate = -1;
  AudioClient _audio;

  Pointer<Pointer<Uint8>> _buffer;
  Pointer<Pointer<Uint8>> _buffer1;
  Pointer<Uint32> _bufferLen;

  @override
  Future playFrame(Frame frame) async {
    final srcChannelLayout = frame._value.channel_layout;
    final srcFormat = frame._value.format;
    final srcSampleRate = frame._value.sample_rate;
    if (_audio == null) {
      _audio = AudioClient();
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
          frame._value.channel_layout,
          frame._value.format,
          frame._value.sample_rate,
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
    final inp = frame._value.extended_data;
    final inCount = frame._value.nb_samples;
    final outCount = inCount * _audio.sampleRate ~/ _srcSampleRate + 256;
    final outSize = av_samples_get_buffer_size(
        Pointer.fromAddress(0), _audio.channels, outCount, _audio.format, 0);
    assert(outSize >= 0);
    av_fast_malloc(_buffer, _bufferLen, outSize);
    assert(_buffer.value.address != 0);
    final nbSamples =
        swr_convert(_swrCtx.value, _buffer, outCount, inp, inCount);
    return _audio.writeBuffer(_buffer.value, nbSamples,
        av_get_bytes_per_sample(_audio.format) * _audio.channels);
  }

  void close() {
    super.close();
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

class VideoCodecContext extends CodecContext {
  Frame _frame;
  void Function() _onFrame;
  Frame createFrame(int fmt, void onFrame()) {
    if (_ctx == null) throw Exception("CodecContext destroyed");
    if (_frame != null) _frame.close();
    _freeSwsCtx();
    _onFrame = onFrame;
    _frame = Frame();
    _frame._fmt = fmt;
    _frame._width = _ctx.value.width;
    _frame._height = _ctx.value.height;
    final bufSize =
        av_image_get_buffer_size(fmt, _frame._width, _frame._height, 1);
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
  void close() {
    super.close();
    _freeSwsCtx();
  }

  @override
  Future playFrame(Frame frame) async {
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
    sws_scale(
        _swsCtx, // sws context
        frame._value.data, // src slice
        frame._value.linesize, // src stride
        0, // src slice y
        _frame._height, // src slice height
        _frame._value.data, // dst planes
        _frame._value.linesize // dst strides
        );
    if (_onFrame != null) _onFrame();
  }
}

abstract class CodecContext {
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
        return AudioCodecContext().._ctx = pCodecCtx;
      case AVMediaType.AVMEDIA_TYPE_VIDEO:
        return VideoCodecContext().._ctx = pCodecCtx;
    }
  }

  Future playFrame(Frame frame);

  int getImageBufferSize(int fmt) {
    return av_image_get_buffer_size(
        fmt, _ctx.value.width, _ctx.value.height, 1);
  }

  void close() {
    if (_ctx == null) return;
    avcodec_free_context(_ctx);
    free(_ctx);
    _ctx = null;
  }
}

class Frame {
  int _fmt;
  Pointer<Pointer<AVFrame>> _p;
  Pointer<AVFrame> get _value => _p.value;
  Pointer<Uint8> _buffer;
  get buffer => _buffer;
  int _width;
  get width => _width;
  int _height;
  get height => _height;
  Frame() {
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
}

class PlayFrame {
  final int timeStamp;
  final Frame frame;
  final CodecContext codec;
  PlayFrame(this.timeStamp, this.frame, this.codec);
}

class PTS {
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
  List<StreamInfo> _streamInfo;

  FormatContext(this.url) {
    _ctx = allocate<Pointer<AVFormatContext>>();
    _ctx.value = Pointer.fromAddress(0);
    final _url = Utf8.toUtf8(url);
    int ret = avformat_open_input(
        _ctx, _url, Pointer.fromAddress(0), Pointer.fromAddress(0));
    free(_url);
    if (ret != 0) throw Exception("avformat_open_input failed: $ret");
  }

  void _checkCtx() {
    if (_ctx == null || _ctx.value.address == 0)
      throw Exception("context not initialized");
  }

  PTS _pts;

  Future play(
    List<StreamInfo> streams,
  ) async {
    final pts = PTS().._relate = 0;
    _pts = pts;
    final playing = () => _pts == pts;
    final packet =
        allocate<Uint8>(count: ffiSizeOf<AVPacket>()).cast<AVPacket>();
    var frame = Frame();
    try {
      Map<StreamInfo, Future Function(PlayFrame)> streamUpdators = {};
      streams.forEach((stream) {
        Future lastUpdate;
        streamUpdators[stream] = (PlayFrame frame) async {
          await lastUpdate;
          final ptsNow = pts.ptsNow();
          final timeStamp = frame.timeStamp;
          if (stream.codecType == AVMediaType.AVMEDIA_TYPE_AUDIO)
            pts.update(timeStamp);
          else if (timeStamp > ptsNow)
            lastUpdate =
                Future.delayed(Duration(milliseconds: timeStamp - ptsNow));
          lastUpdate = lastUpdate ?? Future.sync(() => null);
          lastUpdate = lastUpdate
              .then((_) => frame.codec.playFrame(frame.frame))
              .then((_) => frame.frame.close());
        };
      });

      while (playing() && av_read_frame(_ctx.value, packet) == 0) {
        final streamIndex = packet.stream_index;
        final stream = streams.firstWhere((s) => s.index == streamIndex,
            orElse: () => null);
        if (stream != null) {
          var ret = avcodec_send_packet(stream.codec._ctx.value, packet);
          if (ret != 0) throw Exception("avcodec_send_packet failed: $ret");
          if (0 ==
              avcodec_receive_frame(
                stream.codec._ctx.value,
                frame._value,
              )) {
            final timeStamp = stream.getFramePts(frame);
            await streamUpdators[stream]
                .call(PlayFrame(timeStamp, frame, stream.codec));
            frame = Frame();
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

  List<StreamInfo> getStreamInfo() {
    _checkCtx();
    if (_streamInfo == null) {
      final ret = avformat_find_stream_info(_ctx.value, Pointer.fromAddress(0));
      if (ret != 0) throw Exception("avformat_find_stream_info failed: $ret");
      _streamInfo = [];
      final nbStreams = _ctx.value.nb_streams;
      final streams = _ctx.value.streams;
      for (var i = 0; i < nbStreams; ++i) {
        final stream = streams.elementAt(i).value;
        final codecPar = stream.codecpar;
        final codecType = codecPar.codec_type;
        _streamInfo.add(StreamInfo()
          ..index = i
          .._codecpar = codecPar
          ..codecType = codecType
          ..timebase = getAVStreamTimebase(stream));
      }
    }
    return _streamInfo;
  }

  List<CodecContext> _codecs = [];

  close() async {
    if (_ctx == null || _ctx.value.address == 0) return;
    for (final codec in _codecs) codec.close();
    avformat_close_input(_ctx);
    free(_ctx);
    _ctx = null;
  }
}
