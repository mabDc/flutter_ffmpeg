import 'dart:ffi';

import 'package:ffi/ffi.dart';

final ffilib = DynamicLibrary.open('flutter_ffmpeg_plugin.dll');
final avformat = DynamicLibrary.open('avformat-58.dll');
final avcodec = DynamicLibrary.open('avcodec-58.dll');
final avutil = DynamicLibrary.open('avutil-56.dll');
final swscale = DynamicLibrary.open('swscale-5.dll');
final swresample = DynamicLibrary.open('swresample-3.dll');
final sdllib = DynamicLibrary.open('SDL2.dll');

abstract class AVMediaType {
  /// ///< Usually treated as AVMEDIA_TYPE_DATA
  static const int AVMEDIA_TYPE_UNKNOWN = -1;
  static const int AVMEDIA_TYPE_VIDEO = 0;
  static const int AVMEDIA_TYPE_AUDIO = 1;

  /// ///< Opaque data information usually continuous
  static const int AVMEDIA_TYPE_DATA = 2;
  static const int AVMEDIA_TYPE_SUBTITLE = 3;

  /// ///< Opaque data information usually sparse
  static const int AVMEDIA_TYPE_ATTACHMENT = 4;
  static const int AVMEDIA_TYPE_NB = 5;
}

const int AV_PIX_FMT_RGBA = 26;

const int SWS_POINT = 16;

Map<String, Function> _ffiGetCache = {};
int _ffiGetProperty<C extends Struct>(Pointer<C> obj, String propName) {
  final ffiMethodName = 'get_${C}_$propName';
  final cache = _ffiGetCache[ffiMethodName] ??
      ffilib
          .lookup<NativeFunction<IntPtr Function(Pointer)>>(ffiMethodName)
          .asFunction<int Function(Pointer)>();
  _ffiGetCache[ffiMethodName] = cache;
  return cache(obj);
}

int ffiSizeOf<C extends Struct>() {
  final ffiMethodName = 'sizeof_$C';
  final cache = _ffiGetCache[ffiMethodName] ??
      ffilib
          .lookup<NativeFunction<IntPtr Function()>>(ffiMethodName)
          .asFunction<int Function()>();
  _ffiGetCache[ffiMethodName] = cache;
  return cache();
}

class AVFormatContext extends Struct {}

extension PointerAVFormatContext on Pointer<AVFormatContext> {
  int get nb_streams => _ffiGetProperty(this, 'nb_streams');
  Pointer<Pointer<AVStream>> get streams =>
      Pointer.fromAddress(_ffiGetProperty(this, 'streams'));
}

class AVStream extends Struct {}

extension PointerAVStream on Pointer<AVStream> {
  Pointer<AVCodecParameters> get codecpar =>
      Pointer.fromAddress(_ffiGetProperty(this, 'codecpar'));
}

class AVInputFormat extends Struct {}

class AVDictionary extends Struct {}

class AVCodec extends Struct {}

class AVCodecContext extends Struct {}

extension PointerAVCodecContext on Pointer<AVCodecContext> {
  int get width => _ffiGetProperty(this, 'width');
  int get height => _ffiGetProperty(this, 'height');
  int get pix_fmt => _ffiGetProperty(this, 'pix_fmt');
}

class AVCodecParameters extends Struct {}

extension PointerAVCodecParameters on Pointer<AVCodecParameters> {
  int get codec_type => _ffiGetProperty(this, 'codec_type');
  int get codec_id => _ffiGetProperty(this, 'codec_id');
}

class AVFrame extends Struct {}

extension PointerAVFrame on Pointer<AVFrame> {
  Pointer<Pointer<Uint8>> get data =>
      Pointer.fromAddress(_ffiGetProperty(this, 'data'));
  Pointer<Int32> get linesize =>
      Pointer.fromAddress(_ffiGetProperty(this, 'linesize'));
  get channel_layout => _ffiGetProperty(this, 'channel_layout');
  get format => _ffiGetProperty(this, 'format');
  get sample_rate => _ffiGetProperty(this, 'sample_rate');
  Pointer<Pointer<Uint8>> get extended_data =>
      Pointer.fromAddress(_ffiGetProperty(this, 'extended_data'));
  get nb_samples => _ffiGetProperty(this, 'nb_samples');
  get best_effort_timestamp => _ffiGetProperty(this, 'best_effort_timestamp');
}

class SwsContext extends Struct {}

class SwsFilter extends Struct {}

class AVPacket extends Struct {}

extension PointerAVPacket on Pointer<AVPacket> {
  int get stream_index => _ffiGetProperty(this, 'stream_index');
}

// double get_AVStream_time_base(AVStream *stream)
final double Function(
  Pointer<AVStream> stream,
) getAVStreamTimebase = ffilib
    .lookup<
        NativeFunction<
            Double Function(
      Pointer<AVStream>,
    )>>('get_AVStream_time_base')
    .asFunction();

// uint64_t getFramePtsMilliseconds(AVFrame *frame, AVCodecContext *codec)
final int Function(
  Pointer<AVFrame> frame,
  Pointer<AVCodecContext> codec,
) getFramePtsMilliseconds = ffilib
    .lookup<
        NativeFunction<
            Int32 Function(
      Pointer<AVFrame>,
      Pointer<AVCodecContext>,
    )>>('getFramePtsMilliseconds')
    .asFunction();

// int avformat_open_input(AVFormatContext **ps, const char *url, ff_const59 AVInputFormat *fmt, AVDictionary **options);
final int Function(
  Pointer<Pointer<AVFormatContext>> ps,
  Pointer<Utf8> url,
  Pointer<AVInputFormat> fmt,
  Pointer<Pointer<AVDictionary>> options,
) avformat_open_input = avformat
    .lookup<
        NativeFunction<
            Int32 Function(
      Pointer<Pointer<AVFormatContext>>,
      Pointer<Utf8>,
      Pointer<AVInputFormat>,
      Pointer<Pointer<AVDictionary>>,
    )>>('avformat_open_input')
    .asFunction();

// void avformat_close_input(AVFormatContext **s);
final void Function(
  Pointer<Pointer<AVFormatContext>> s,
) avformat_close_input = avformat
    .lookup<
        NativeFunction<
            Void Function(
      Pointer<Pointer<AVFormatContext>>,
    )>>('avformat_close_input')
    .asFunction();

// int avformat_find_stream_info(AVFormatContext *ic, AVDictionary **options);
final int Function(
  Pointer<AVFormatContext> ic,
  Pointer<Pointer<AVDictionary>> options,
) avformat_find_stream_info = avformat
    .lookup<
        NativeFunction<
            Int32 Function(
      Pointer<AVFormatContext>,
      Pointer<Pointer<AVDictionary>>,
    )>>('avformat_find_stream_info')
    .asFunction();

// AVCodec *avcodec_find_decoder(enum AVCodecID id);
final Pointer<AVCodec> Function(
  int id,
) avcodec_find_decoder = avcodec
    .lookup<
        NativeFunction<
            Pointer<AVCodec> Function(
      Int32,
    )>>('avcodec_find_decoder')
    .asFunction();

// AVCodecContext *avcodec_alloc_context3(const AVCodec *codec);
final Pointer<AVCodecContext> Function(
  Pointer<AVCodec> codec,
) avcodec_alloc_context3 = avcodec
    .lookup<
        NativeFunction<
            Pointer<AVCodecContext> Function(
      Pointer<AVCodec>,
    )>>('avcodec_alloc_context3')
    .asFunction();

// void avcodec_free_context(AVCodecContext **avctx);
final void Function(
  Pointer<Pointer<AVCodecContext>> avctx,
) avcodec_free_context = avcodec
    .lookup<
        NativeFunction<
            Void Function(
      Pointer<Pointer<AVCodecContext>>,
    )>>('avcodec_free_context')
    .asFunction();

// int avcodec_parameters_to_context(AVCodecContext *codec, const AVCodecParameters *par);
final int Function(
  Pointer<AVCodecContext> codec,
  Pointer<AVCodecParameters> par,
) avcodec_parameters_to_context = avcodec
    .lookup<
        NativeFunction<
            Int32 Function(
      Pointer<AVCodecContext>,
      Pointer<AVCodecParameters>,
    )>>('avcodec_parameters_to_context')
    .asFunction();

// int avcodec_open2(AVCodecContext *avctx, const AVCodec *codec, AVDictionary **options);
final int Function(
  Pointer<AVCodecContext> avctx,
  Pointer<AVCodec> codec,
  Pointer<Pointer<AVDictionary>> options,
) avcodec_open2 = avcodec
    .lookup<
        NativeFunction<
            Int32 Function(
      Pointer<AVCodecContext>,
      Pointer<AVCodec>,
      Pointer<Pointer<AVDictionary>>,
    )>>('avcodec_open2')
    .asFunction();

// AVFrame *av_frame_alloc(void);
final Pointer<AVFrame> Function() av_frame_alloc = avutil
    .lookup<NativeFunction<Pointer<AVFrame> Function()>>('av_frame_alloc')
    .asFunction();

// void av_frame_free(AVFrame **frame);
final void Function(
  Pointer<Pointer<AVFrame>>,
) av_frame_free = avutil
    .lookup<
        NativeFunction<
            Void Function(
      Pointer<Pointer<AVFrame>>,
    )>>('av_frame_free')
    .asFunction();

// int av_image_get_buffer_size(enum AVPixelFormat pix_fmt, int width, int height, int align);
final int Function(
  int pix_fmt,
  int width,
  int height,
  int align,
) av_image_get_buffer_size = avutil
    .lookup<
        NativeFunction<
            Int32 Function(
      Int32,
      Int32,
      Int32,
      Int32,
    )>>('av_image_get_buffer_size')
    .asFunction();

// int av_image_fill_arrays(uint8_t *dst_data[4], int dst_linesize[4],
//                          const uint8_t *src,
//                          enum AVPixelFormat pix_fmt, int width, int height, int align);
final int Function(
  Pointer<Pointer<Uint8>> dst_data,
  Pointer<Int32> dst_linesize,
  Pointer<Uint8> src,
  int pix_fmt,
  int width,
  int height,
  int align,
) av_image_fill_arrays = avutil
    .lookup<
        NativeFunction<
            Int32 Function(
      Pointer<Pointer<Uint8>>,
      Pointer<Int32>,
      Pointer<Uint8>,
      Int32,
      Int32,
      Int32,
      Int32,
    )>>('av_image_fill_arrays')
    .asFunction();

// struct SwsContext *sws_getContext(int srcW, int srcH, enum AVPixelFormat srcFormat,
//                                   int dstW, int dstH, enum AVPixelFormat dstFormat,
//                                   int flags, SwsFilter *srcFilter,
//                                   SwsFilter *dstFilter, const double *param);
final Pointer<SwsContext> Function(
  int srcW,
  int srcH,
  int srcFormat,
  int dstW,
  int dstH,
  int dstFormat,
  int flags,
  Pointer<SwsFilter> srcFilter,
  Pointer<SwsFilter> dstFilter,
  Pointer<Double> param,
) sws_getContext = swscale
    .lookup<
        NativeFunction<
            Pointer<SwsContext> Function(
      Int32,
      Int32,
      Int32,
      Int32,
      Int32,
      Int32,
      Int32,
      Pointer<SwsFilter>,
      Pointer<SwsFilter>,
      Pointer<Double>,
    )>>('sws_getContext')
    .asFunction();

// void sws_freeContext(struct SwsContext *swsContext);
final void Function(
  Pointer<SwsContext> swsContext,
) sws_freeContext = swscale
    .lookup<
        NativeFunction<
            Void Function(
      Pointer<SwsContext>,
    )>>('sws_freeContext')
    .asFunction();

// int av_read_frame(AVFormatContext *s, AVPacket *pkt);
final int Function(
  Pointer<AVFormatContext> s,
  Pointer<AVPacket> pkt,
) av_read_frame = avformat
    .lookup<
        NativeFunction<
            Int32 Function(
      Pointer<AVFormatContext>,
      Pointer<AVPacket>,
    )>>('av_read_frame')
    .asFunction();

// void av_packet_unref(AVPacket *pkt);
final void Function(
  Pointer<AVPacket> pkt,
) av_packet_unref = avcodec
    .lookup<
        NativeFunction<
            Void Function(
      Pointer<AVPacket>,
    )>>('av_packet_unref')
    .asFunction();

// int avcodec_send_packet(AVCodecContext *avctx, const AVPacket *avpkt);
final int Function(
  Pointer<AVCodecContext> avctx,
  Pointer<AVPacket> avpkt,
) avcodec_send_packet = avcodec
    .lookup<
        NativeFunction<
            Int32 Function(
      Pointer<AVCodecContext>,
      Pointer<AVPacket>,
    )>>('avcodec_send_packet')
    .asFunction();

// int avcodec_receive_frame(AVCodecContext *avctx, AVFrame *frame);
final int Function(
  Pointer<AVCodecContext> avctx,
  Pointer<AVFrame> frame,
) avcodec_receive_frame = avcodec
    .lookup<
        NativeFunction<
            Int32 Function(
      Pointer<AVCodecContext>,
      Pointer<AVFrame>,
    )>>('avcodec_receive_frame')
    .asFunction();

// int sws_scale(struct SwsContext *c, const uint8_t *const srcSlice[],
//               const int srcStride[], int srcSliceY, int srcSliceH,
//               uint8_t *const dst[], const int dstStride[]);
final int Function(
  Pointer<SwsContext> c,
  Pointer<Pointer<Uint8>> srcSlice,
  Pointer<Int32> srcStride,
  int srcSliceY,
  int srcSliceH,
  Pointer<Pointer<Uint8>> dst,
  Pointer<Int32> dstStride,
) sws_scale = swscale
    .lookup<
        NativeFunction<
            Int32 Function(
      Pointer<SwsContext>,
      Pointer<Pointer<Uint8>>,
      Pointer<Int32>,
      Int32,
      Int32,
      Pointer<Pointer<Uint8>>,
      Pointer<Int32>,
    )>>('sws_scale')
    .asFunction();

// int64_t av_get_default_channel_layout(int nb_channels);
final int Function(
  int nb_channels,
) av_get_default_channel_layout = avutil
    .lookup<
        NativeFunction<
            Int64 Function(
      Int32,
    )>>('av_get_default_channel_layout')
    .asFunction();

// int av_samples_get_buffer_size(int *linesize, int nb_channels, int nb_samples,
//                                enum AVSampleFormat sample_fmt, int align);
final int Function(
  Pointer<Int32> linesize,
  int nb_channels,
  int nb_samples,
  int sample_fmt,
  int align,
) av_samples_get_buffer_size = avutil
    .lookup<
        NativeFunction<
            Int32 Function(
      Pointer<Int32>,
      Int32,
      Int32,
      Int32,
      Int32,
    )>>('av_samples_get_buffer_size')
    .asFunction();

// void av_fast_malloc(void *ptr, unsigned int *size, size_t min_size);
final void Function(
  Pointer ptr,
  Pointer<Uint32> size,
  int min_size,
) av_fast_malloc = avutil
    .lookup<
        NativeFunction<
            Void Function(
      Pointer,
      Pointer<Uint32>,
      Int32,
    )>>('av_fast_malloc')
    .asFunction();

// int av_get_bytes_per_sample(enum AVSampleFormat sample_fmt);
final int Function(
  int sample_fmt,
) av_get_bytes_per_sample = avutil
    .lookup<
        NativeFunction<
            Int32 Function(
      Int32,
    )>>('av_get_bytes_per_sample')
    .asFunction();

class SwrContext extends Struct {}

// struct SwrContext *swr_alloc_set_opts(struct SwrContext *s,
//                                       int64_t out_ch_layout, enum AVSampleFormat out_sample_fmt, int out_sample_rate,
//                                       int64_t  in_ch_layout, enum AVSampleFormat  in_sample_fmt, int  in_sample_rate,
//                                       int log_offset, void *log_ctx);
final Pointer<SwrContext> Function(
  Pointer<SwrContext> s,
  int out_ch_layout,
  int out_sample_fmt,
  int out_sample_rate,
  int in_ch_layout,
  int in_sample_fmt,
  int in_sample_rate,
  int log_offset,
  Pointer log_ctx,
) swr_alloc_set_opts = swresample
    .lookup<
        NativeFunction<
            Pointer<SwrContext> Function(
      Pointer<SwrContext>,
      Int64,
      Int32,
      Int32,
      Int64,
      Int32,
      Int32,
      Int32,
      Pointer,
    )>>('swr_alloc_set_opts')
    .asFunction();

// int swr_init(struct SwrContext *s);
final int Function(
  Pointer<SwrContext> s,
) swr_init = swresample
    .lookup<
        NativeFunction<
            Int32 Function(
      Pointer<SwrContext>,
    )>>('swr_init')
    .asFunction();

// void swr_free(struct SwrContext **s);
final void Function(
  Pointer<Pointer<SwrContext>> s,
) swr_free = swresample
    .lookup<
        NativeFunction<
            Void Function(
      Pointer<Pointer<SwrContext>>,
    )>>('swr_free')
    .asFunction();

// int swr_convert(struct SwrContext *s, uint8_t **out, int out_count,
//                                const uint8_t **in , int in_count);
final int Function(
  Pointer<SwrContext> s,
  Pointer<Pointer<Uint8>> out,
  int out_count,
  Pointer<Pointer<Uint8>> inp,
  int in_count,
) swr_convert = swresample
    .lookup<
        NativeFunction<
            Int32 Function(
      Pointer<SwrContext>,
      Pointer<Pointer<Uint8>>,
      Int32,
      Pointer<Pointer<Uint8>>,
      Int32,
    )>>('swr_convert')
    .asFunction();

class IMMDeviceEnumerator extends Struct {}

class IMMDevice extends Struct {}

class IAudioClient extends Struct {}

class IAudioRenderClient extends Struct {}

class WAVEFORMATEX extends Struct {
  @Uint16()
  int wFormatTag;
  @Uint16()
  int nChannels;
  @Uint32()
  int nSamplesPerSec;
  @Uint32()
  int nAvgBytesPerSec;
  @Uint16()
  int nBlockAlign;
  @Uint16()
  int wBitsPerSample;
  @Uint16()
  int cbSize;
}

// IMMDeviceEnumerator *createIMMDeviceEnumerator()
final Pointer<IMMDeviceEnumerator> Function() createIMMDeviceEnumerator = ffilib
    .lookup<NativeFunction<Pointer<IMMDeviceEnumerator> Function()>>(
        'createIMMDeviceEnumerator')
    .asFunction();

// void releaseIUnknown(IUnknown *p)
final void Function(
  Pointer p,
) releaseIUnknown = ffilib
    .lookup<
        NativeFunction<
            Void Function(
      Pointer,
    )>>('releaseIUnknown')
    .asFunction();

// IMMDevice *IMMDeviceEnumeratorGetDefaultAudioEndpoint(IMMDeviceEnumerator *pEnumerator)
final Pointer<IMMDevice> Function(
  Pointer<IMMDeviceEnumerator> pEnumerator,
) iMMDeviceEnumeratorGetDefaultAudioEndpoint = ffilib
    .lookup<
        NativeFunction<
            Pointer<IMMDevice> Function(
      Pointer<IMMDeviceEnumerator>,
    )>>('IMMDeviceEnumeratorGetDefaultAudioEndpoint')
    .asFunction();

// IAudioClient *IMMDeviceActivate(IMMDevice *pDevice)
final Pointer<IAudioClient> Function(
  Pointer<IMMDevice> pDevice,
) iMMDeviceActivate = ffilib
    .lookup<
        NativeFunction<
            Pointer<IAudioClient> Function(
      Pointer<IMMDevice>,
    )>>('IMMDeviceActivate')
    .asFunction();

// WAVEFORMATEX *IAudioClientGetMixFormat(IAudioClient *pAudioClient)
final Pointer<WAVEFORMATEX> Function(
  Pointer<IAudioClient> pAudioClient,
) iAudioClientGetMixFormat = ffilib
    .lookup<
        NativeFunction<
            Pointer<WAVEFORMATEX> Function(
      Pointer<IAudioClient>,
    )>>('IAudioClientGetMixFormat')
    .asFunction();

// void ffiCoTaskMemFree(WAVEFORMATEX *pwfx)
final void Function(
  Pointer<WAVEFORMATEX> pwfx,
) ffiCoTaskMemFree = ffilib
    .lookup<
        NativeFunction<
            Void Function(
      Pointer<WAVEFORMATEX>,
    )>>('ffiCoTaskMemFree')
    .asFunction();

// enum AVSampleFormat GetSampleFormat(WAVEFORMATEX *wave_format)
final int Function(
  Pointer<WAVEFORMATEX> waveFormat,
) getSampleFormat = ffilib
    .lookup<
        NativeFunction<
            Int32 Function(
      Pointer<WAVEFORMATEX>,
    )>>('GetSampleFormat')
    .asFunction();

// HRESULT IAudioClientInitialize(IAudioClient *pAudioClient, WAVEFORMATEX *pwfx, REFERENCE_TIME hnsRequestedDuration)
final int Function(
  Pointer<IAudioClient> pAudioClient,
  Pointer<WAVEFORMATEX> pwfx,
  int hnsRequestedDuration,
) iAudioClientInitialize = ffilib
    .lookup<
        NativeFunction<
            Int32 Function(
      Pointer<IAudioClient>,
      Pointer<WAVEFORMATEX>,
      Int64,
    )>>('IAudioClientInitialize')
    .asFunction();

// UINT32 IAudioClientGetBufferSize(IAudioClient *pAudioClient)
final int Function(
  Pointer<IAudioClient> pAudioClient,
) iAudioClientGetBufferSize = ffilib
    .lookup<
        NativeFunction<
            Uint32 Function(
      Pointer<IAudioClient>,
    )>>('IAudioClientGetBufferSize')
    .asFunction();

// IAudioRenderClient *IAudioClientGetService(IAudioClient *pAudioClient)
final Pointer<IAudioRenderClient> Function(
  Pointer<IAudioClient> pAudioClient,
) iAudioClientGetService = ffilib
    .lookup<
        NativeFunction<
            Pointer<IAudioRenderClient> Function(
      Pointer<IAudioClient>,
    )>>('IAudioClientGetService')
    .asFunction();

// UINT32 IAudioClientGetCurrentPadding(IAudioClient *pAudioClient)
final int Function(
  Pointer<IAudioClient> pAudioClient,
) iAudioClientGetCurrentPadding = ffilib
    .lookup<
        NativeFunction<
            Int32 Function(
      Pointer<IAudioClient>,
    )>>('IAudioClientGetCurrentPadding')
    .asFunction();

// BYTE *IAudioRenderClientGetBuffer(IAudioRenderClient *pRenderClient, UINT32 requestBuffer)
final Pointer<Uint8> Function(
  Pointer<IAudioRenderClient> pRenderClient,
  int requestBuffer,
) iAudioRenderClientGetBuffer = ffilib
    .lookup<
        NativeFunction<
            Pointer<Uint8> Function(
      Pointer<IAudioRenderClient>,
      Uint32,
    )>>('IAudioRenderClientGetBuffer')
    .asFunction();

// HRESULT IAudioRenderClientReleaseBuffer(IAudioRenderClient *pRenderClient, UINT32 requestBuffer, int dwFlags)
final int Function(
  Pointer<IAudioRenderClient> pRenderClient,
  int requestBuffer,
  int dwFlags,
) iAudioRenderClientReleaseBuffer = ffilib
    .lookup<
        NativeFunction<
            Int32 Function(
      Pointer<IAudioRenderClient>,
      Uint32,
      Int32,
    )>>('IAudioRenderClientReleaseBuffer')
    .asFunction();

// DLLEXPORT HRESULT IAudioClientStart(IAudioClient *pAudioClient)
final int Function(
  Pointer<IAudioClient> pAudioClient,
) iAudioClientStart = ffilib
    .lookup<
        NativeFunction<
            Int32 Function(
      Pointer<IAudioClient>,
    )>>('IAudioClientStart')
    .asFunction();

// DLLEXPORT HRESULT IAudioClientStop(IAudioClient *pAudioClient)
final int Function(
  Pointer<IAudioClient> pAudioClient,
) iAudioClientStop = ffilib
    .lookup<
        NativeFunction<
            Int32 Function(
      Pointer<IAudioClient>,
    )>>('IAudioClientStop')
    .asFunction();

// DLLEXPORT UINT32 ffiMemcpy(void *dst, void *src, UINT32 size)
final int Function(
  Pointer dst,
  Pointer src,
  int size,
) ffiMemcpy = ffilib
    .lookup<
        NativeFunction<
            Uint32 Function(
      Pointer,
      Pointer,
      Uint32,
    )>>('ffiMemcpy')
    .asFunction();

// int SDLCALL SDL_Init(Uint32 flags)
final int Function(
  int flags,
) sdlInit = sdllib
    .lookup<
        NativeFunction<
            Int32 Function(
      Uint32,
    )>>('SDL_Init')
    .asFunction();
