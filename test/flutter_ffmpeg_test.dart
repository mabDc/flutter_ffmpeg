import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:flutter_ffmpeg/audio.dart';
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
  test('changeDirectory', () async {
    Directory.current = './test/build/Debug';
  });
  test('avformat', () async {
    final p_fmt_ctx = allocate<Pointer<AVFormatContext>>();
    p_fmt_ctx.value = Pointer.fromAddress(0);
    final url = Utf8.toUtf8("D:\\CloudMusic\\seven oops - オレンジ.flac");
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
    final streams = p_fmt_ctx.value.streams;
    int v_idx = -1;
    Pointer<AVCodecParameters> p_codecpar = Pointer.fromAddress(0);
    for (var i = 0; i < nb_streams; ++i) {
      final stream = streams.elementAt(i).value;
      final codec_type = stream.codecpar.codec_type;
      if (codec_type == AVMediaType.AVMEDIA_TYPE_AUDIO) {
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
    final p_frame = allocate<Pointer<AVFrame>>();
    p_frame.value = av_frame_alloc();
    final p_packet =
        allocate<Uint8>(count: ffiSizeOf<AVPacket>()).cast<AVPacket>();

    final audio = AudioClient();
    final s_resample_buf = allocate<Pointer<Uint8>>();
    s_resample_buf.value = Pointer.fromAddress(0);
    final s_resample_buf_len = allocate<Uint32>();
    s_resample_buf_len.value = 0;
    final s_audio_swr_ctx = allocate<Pointer<SwrContext>>();
    s_audio_swr_ctx.value = Pointer.fromAddress(0);
    int s_audio_param_src_channel_layout = -1;
    int s_audio_param_src_format = -1;
    int s_audio_param_src_sample_rate = -1;
    final audioChannels = audio.channels;
    final audioChannelLayout = av_get_default_channel_layout(audioChannels);
    final bytePerSample = av_get_bytes_per_sample(audio.format);
    audio.start();

    while (av_read_frame(p_fmt_ctx.value, p_packet) == 0) {
      if (p_packet.stream_index == v_idx) {
        if (avcodec_receive_frame(p_codec_ctx.value, p_frame.value) == 0) {
          final src_channel_layout = p_frame.value.channel_layout;
          final src_format = p_frame.value.format;
          final src_sample_rate = p_frame.value.sample_rate;
          if (s_audio_swr_ctx.value.address == 0 ||
              src_channel_layout != s_audio_param_src_channel_layout ||
              src_format != s_audio_param_src_format ||
              src_sample_rate != s_audio_param_src_sample_rate) {
            if (s_audio_swr_ctx.value.address != 0) swr_free(s_audio_swr_ctx);
            s_audio_swr_ctx.value = swr_alloc_set_opts(
                Pointer.fromAddress(0),
                audioChannelLayout,
                audio.format,
                audio.sampleRate,
                p_frame.value.channel_layout,
                p_frame.value.format,
                p_frame.value.sample_rate,
                0,
                Pointer.fromAddress(0));
            assert(s_audio_swr_ctx.value.address != 0 &&
                swr_init(s_audio_swr_ctx.value) >= 0);
            s_audio_param_src_channel_layout = src_channel_layout;
            s_audio_param_src_format = src_format;
            s_audio_param_src_sample_rate = src_sample_rate;
          }
          assert(s_audio_swr_ctx.value.address != 0);
          final inp = p_frame.value.extended_data;
          final in_count = p_frame.value.nb_samples;
          final out_count =
              in_count * audio.sampleRate ~/ s_audio_param_src_sample_rate +
                  256;
          final out_size = av_samples_get_buffer_size(Pointer.fromAddress(0),
              audioChannels, out_count, audio.format, 0);
          assert(out_size >= 0);
          av_fast_malloc(s_resample_buf, s_resample_buf_len, out_size);
          assert(s_resample_buf.value.address != 0);
          final nb_samples = swr_convert(
              s_audio_swr_ctx.value, s_resample_buf, out_count, inp, in_count);
          final resampled_data_size = nb_samples * bytePerSample * bytePerSample;
          await audio.writeBuffer(s_resample_buf.value, resampled_data_size);
        } else {
          ret = avcodec_send_packet(p_codec_ctx.value, p_packet);
          assert(ret == 0);
        }
      }
      av_packet_unref(p_packet);
    }
    audio.stop();
    audio.close();
    if (s_audio_swr_ctx.value.address != 0) swr_free(s_audio_swr_ctx);
    free(s_audio_swr_ctx);
    free(p_packet);
    av_frame_free(p_frame);
    free(p_frame);
    avcodec_free_context(p_codec_ctx);
    free(p_codec_ctx);
    avformat_close_input(p_fmt_ctx);
    free(p_fmt_ctx);
  });
}
