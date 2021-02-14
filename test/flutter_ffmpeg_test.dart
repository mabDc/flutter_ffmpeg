import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:flutter_ffmpeg/ffi.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('make', () async {
    final utf8Encoding = Encoding.getByName('utf-8');
    var cmakePath = 'cmake';
    if (Platform.isWindows) {
      var vsDir = Directory('C:/Program Files (x86)/Microsoft Visual Studio/');
      vsDir = (vsDir.listSync().firstWhere((e) => e is Directory) as Directory)
          .listSync()
          .last as Directory;
      cmakePath = vsDir.path +
          '/Common7/IDE/CommonExtensions/Microsoft/CMake/CMake/bin/cmake.exe';
    }
    final buildDir = './build';
    var result = Process.runSync(
      cmakePath,
      ['-S', './', '-B', buildDir],
      workingDirectory: 'test',
      stdoutEncoding: utf8Encoding,
      stderrEncoding: utf8Encoding,
    );
    stdout.write(result.stdout);
    stderr.write(result.stderr);
    expect(result.exitCode, 0);

    result = Process.runSync(
      cmakePath,
      ['--build', buildDir, '--verbose'],
      workingDirectory: 'test',
      stdoutEncoding: utf8Encoding,
      stderrEncoding: utf8Encoding,
    );
    stdout.write(result.stdout);
    stderr.write(result.stderr);
    expect(result.exitCode, 0);
  });
  test('avformat', () async {
    Directory.current = './test/build/Debug';
    final p_fmt_ctx = allocate<Pointer<AVFormatContext>>();
    p_fmt_ctx.value = Pointer.fromAddress(0);
    final url = Utf8.toUtf8("D:\\Downloads\\System\\big_buck_bunny.mp4");
    // A1. 打开视频文件：读取文件头，将文件格式信息存储在"fmt context"中
    int ret = avformat_open_input(
        p_fmt_ctx, url, Pointer.fromAddress(0), Pointer.fromAddress(0));
    free(url);
    assert(ret == 0);
    // A2. 搜索流信息：读取一段视频文件数据，尝试解码，将取到的流信息填入pFormatCtx->streams
    //     p_fmt_ctx->streams是一个指针数组，数组大小是pFormatCtx->nb_streams
    ret = avformat_find_stream_info(p_fmt_ctx.value, Pointer.fromAddress(0));
    assert(ret == 0);
    // A3. 查找第一个音频流/视频流
    final nb_streams = p_fmt_ctx.value.nb_streams;
    print(nb_streams);
    final streams = p_fmt_ctx.value.streams;
    int v_idx = -1;
    Pointer<AVCodecParameters> p_codecpar = Pointer.fromAddress(0);
    for (var i = 0; i < nb_streams; ++i) {
      final stream = streams.elementAt(i).value;
      final codec_type = stream.codecpar.codec_type;
      if (codec_type == AVMediaType.AVMEDIA_TYPE_VIDEO){
        v_idx = i;
        p_codecpar = stream.codecpar;
        break;
      }
    }
    assert(p_codecpar.address != 0);
    // A5. 为视频流构建解码器AVCodecContext
    final p_codec = avcodec_find_decoder(p_codecpar.codec_id);
    assert(p_codec.address != 0);
    // A5.3 构建解码器AVCodecContext
    // A5.3.1 p_codec_ctx初始化：分配结构体，使用p_codec初始化相应成员为默认值
    final p_codec_ctx = allocate<Pointer<AVCodecContext>>();
    p_codec_ctx.value = avcodec_alloc_context3(p_codec);
    // A5.3.2 p_codec_ctx初始化：p_codec_par ==> p_codec_ctx，初始化相应成员
    ret = avcodec_parameters_to_context(p_codec_ctx.value, p_codecpar);
    assert(ret == 0);
    // A5.3.3 p_codec_ctx初始化：使用p_codec初始化p_codec_ctx，初始化完成
    ret = avcodec_open2(p_codec_ctx.value, p_codec, Pointer.fromAddress(0));
    assert(ret == 0);
    // A6. 分配AVFrame
    // A6.1 分配AVFrame结构，注意并不分配data buffer(即AVFrame.*data[])
    final p_frm_raw = allocate<Pointer<AVFrame>>();
    p_frm_raw.value = av_frame_alloc();
    final p_frm_argb = allocate<Pointer<AVFrame>>();
    p_frm_argb.value = av_frame_alloc();
    // A6.2 为AVFrame.*data[]手工分配缓冲区，用于存储sws_scale()中目的帧视频数据
    //     p_frm_raw的data_buffer由av_read_frame()分配，因此不需手工分配
    //     p_frm_yuv的data_buffer无处分配，因此在此处手工分配
    final fmt = AVPixelFormat.AV_PIX_FMT_RGBA;
    final buf_size = av_image_get_buffer_size(
        fmt, p_codec_ctx.value.width, p_codec_ctx.value.height, 1);
    final buffer = allocate<Uint8>(count: buf_size);
    av_image_fill_arrays(
        p_frm_argb.value.data, // dst data[]
        p_frm_argb.value.linesize, // dst linesize[]
        buffer, // src buffer
        fmt, // pixel format
        p_codec_ctx.value.width, // width
        p_codec_ctx.value.height, // height
        1 // align
        );

    final sws_ctx = sws_getContext(
        p_codec_ctx.value.width, // src width
        p_codec_ctx.value.height, // src height
        p_codec_ctx.value.pix_fmt, // src format
        p_codec_ctx.value.width, // dst width
        p_codec_ctx.value.height, // dst height
        fmt, // dst format
        SWS_POINT, // flags
        Pointer.fromAddress(0), // src filter
        Pointer.fromAddress(0), // dst filter
        Pointer.fromAddress(0) // param
        );
    final p_packet =
        allocate<Uint8>(count: ffiSizeOf<AVPacket>()).cast<AVPacket>();
    while (av_read_frame(p_fmt_ctx.value, p_packet) == 0) {
      if (p_packet.stream_index == v_idx) {
        ret = avcodec_send_packet(p_codec_ctx.value, p_packet);
        assert(ret == 0);
        if (avcodec_receive_frame(p_codec_ctx.value, p_frm_raw.value) == 0) {
          sws_scale(
              sws_ctx, // sws context
              p_frm_raw.value.data, // src slice
              p_frm_raw.value.linesize, // src stride
              0, // src slice y
              p_codec_ctx.value.height, // src slice height
              p_frm_argb.value.data, // dst planes
              p_frm_argb.value.linesize // dst strides
              );
        }
      }
      av_packet_unref(p_packet);
    }
    free(p_packet);
    sws_freeContext(sws_ctx);
    free(buffer);
    av_frame_free(p_frm_raw);
    av_frame_free(p_frm_argb);
    free(p_frm_raw);
    free(p_frm_argb);
    avcodec_free_context(p_codec_ctx);
    free(p_codec_ctx);
    avformat_close_input(p_fmt_ctx);
    free(p_fmt_ctx);
  });
}
