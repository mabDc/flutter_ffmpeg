import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:flutter_ffmpeg/ffi.dart';

class StreamInfo {
  int index;
  int codecType;
  Pointer<AVCodecParameters> _codecpar;
  CodecContext _codec;
  CodecContext get codec {
    if (_codecpar == null) throw Exception("StreamInfo destroyed");
    if (_codec == null) {
      final pCodec = avcodec_find_decoder(_codecpar.codec_id);
      if (pCodec.address == 0) throw Exception("avcodec_find_decoder failed");
      final pCodecCtx = allocate<Pointer<AVCodecContext>>();
      pCodecCtx.value = avcodec_alloc_context3(pCodec);
      var ret = avcodec_parameters_to_context(pCodecCtx.value, _codecpar);
      if (ret != 0)
        throw Exception("avcodec_parameters_to_context failed: $ret");
      ret = avcodec_open2(pCodecCtx.value, pCodec, Pointer.fromAddress(0));
      if (ret != 0) throw Exception("avcodec_open2 failed: $ret");
      _codec = CodecContext._new(pCodecCtx);
    }
    return _codec;
  }

  void close() {
    if (_codec != null) _codec.close();
    _codec = null;
    _codecpar = null;
  }
}

class CodecContext {
  Pointer<Pointer<AVCodecContext>> _ctx;
  CodecContext._new(this._ctx);

  Frame createFrame(int fmt) {
    if (_ctx == null) throw Exception("CodecContext destroyed");
    final frame = Frame();
    frame._fmt = fmt;
    frame._width = _ctx.value.width;
    frame._height = _ctx.value.height;
    final bufSize =
        av_image_get_buffer_size(fmt, frame._width, frame._height, 1);
    frame._buffer = allocate<Uint8>(count: bufSize);
    av_image_fill_arrays(
        frame._pframe.value.data, // dst data[]
        frame._pframe.value.linesize, // dst linesize[]
        frame._buffer, // src buffer
        fmt, // pixel format
        frame._width, // width
        frame._height, // height
        1 // align
        );
    return frame;
  }

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
  Pointer<Pointer<AVFrame>> _pframe;
  Pointer<Uint8> _buffer;
  get buffer => _buffer;
  int _width;
  get width => _width;
  int _height;
  get height => _height;
  Frame() {
    _pframe = allocate<Pointer<AVFrame>>();
    _pframe.value = av_frame_alloc();
  }

  void close() {
    if (_pframe == null) return;
    if (_buffer != null) free(_buffer);
    _buffer = null;
    av_frame_free(_pframe);
    free(_pframe);
    _pframe = null;
  }
}

class FormatContext {
  Future<dynamic> _context;
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

  Future play(StreamInfo videoStream, Frame frmArgb, void onFrame()) async {
    final packet =
        allocate<Uint8>(count: ffiSizeOf<AVPacket>()).cast<AVPacket>();
    final frmRaw = Frame();
    final swsCtx = sws_getContext(
        videoStream.codec._ctx.value.width, // src width
        videoStream.codec._ctx.value.height, // src height
        videoStream.codec._ctx.value.pix_fmt, // src format
        frmArgb._width, // dst width
        frmArgb._height, // dst height
        frmArgb._fmt, // dst format
        SWS_POINT, // flags
        Pointer.fromAddress(0), // src filter
        Pointer.fromAddress(0), // dst filter
        Pointer.fromAddress(0) // param
        );
    try {
      while (av_read_frame(_ctx.value, packet) == 0) {
        final streamIndex = packet.stream_index;
        if (streamIndex == videoStream.index) {
          final ret = avcodec_send_packet(videoStream.codec._ctx.value, packet);
          if (ret != 0) throw Exception("avcodec_send_packet failed: $ret");
          if (avcodec_receive_frame(
                  videoStream.codec._ctx.value, frmRaw._pframe.value) ==
              0) {
            sws_scale(
                swsCtx, // sws context
                frmRaw._pframe.value.data, // src slice
                frmRaw._pframe.value.linesize, // src stride
                0, // src slice y
                frmArgb._height, // src slice height
                frmArgb._pframe.value.data, // dst planes
                frmArgb._pframe.value.linesize // dst strides
                );
            onFrame();
            await Future.delayed(Duration(milliseconds: 25));
          }
        }
        av_packet_unref(packet);
      }
    } finally {
      free(packet);
      sws_freeContext(swsCtx);
      frmRaw.close();
      frmArgb.close();
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
          ..codecType = codecType);
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
