#ifdef _MSC_VER
#define DLLEXPORT __declspec(dllexport)
#else
#define DLLEXPORT __attribute__((visibility("default"))) __attribute__((used))
#endif

#define DEFINE_GET_CLASS_PROP(class, prop) \
  DLLEXPORT intptr_t get_##class##_##prop(class *p) { return (intptr_t)p->prop; }

#define DEFINE_SIZE_OF(class) \
  DLLEXPORT intptr_t sizeof_##class() { return sizeof(class); }

#include <mmdeviceapi.h>
#include <audiopolicy.h>

const CLSID CLSID_MMDeviceEnumerator = __uuidof(MMDeviceEnumerator);
const IID IID_IMMDeviceEnumerator = __uuidof(IMMDeviceEnumerator);
const IID IID_IAudioClient = __uuidof(IAudioClient);
const IID IID_IAudioRenderClient = __uuidof(IAudioRenderClient);

extern "C"
{
#include "libavcodec/avcodec.h"
#include "libavutil/imgutils.h"
#include "libavformat/avformat.h"
#include "libswscale/swscale.h"
#include "libswresample/swresample.h"

#include "SDL.h"

  DEFINE_SIZE_OF(AVPacket)

  DEFINE_GET_CLASS_PROP(AVFormatContext, nb_streams)
  DEFINE_GET_CLASS_PROP(AVFormatContext, streams)
  DEFINE_GET_CLASS_PROP(AVStream, codecpar)
  DEFINE_GET_CLASS_PROP(AVCodecParameters, codec_type)
  DEFINE_GET_CLASS_PROP(AVCodecParameters, codec_id)
  DEFINE_GET_CLASS_PROP(AVCodecContext, width)
  DEFINE_GET_CLASS_PROP(AVCodecContext, height)
  DEFINE_GET_CLASS_PROP(AVCodecContext, pix_fmt)
  DEFINE_GET_CLASS_PROP(AVFrame, data)
  DEFINE_GET_CLASS_PROP(AVFrame, linesize)
  DEFINE_GET_CLASS_PROP(AVFrame, channel_layout)
  DEFINE_GET_CLASS_PROP(AVFrame, format)
  DEFINE_GET_CLASS_PROP(AVFrame, sample_rate)
  DEFINE_GET_CLASS_PROP(AVFrame, extended_data)
  DEFINE_GET_CLASS_PROP(AVFrame, nb_samples)
  DEFINE_GET_CLASS_PROP(AVPacket, stream_index)

  struct AudioData
  {
    Uint32 audio_len = 0;
    Uint8 *audio_pos = NULL;
  };

  void fill_audio(void *udata, Uint8 *stream, int len)
  {
    auto data = (AudioData *)udata;
    SDL_memset(stream, 0, len);
    if (data->audio_len == 0)
      return;

    len = (len > data->audio_len ? data->audio_len : len); /*  Mix  as  much  data  as  possible  */

    SDL_MixAudio(stream, data->audio_pos, len, SDL_MIX_MAXVOLUME);
    data->audio_pos += len;
    data->audio_len -= len;
  }

  DLLEXPORT AudioData *openAudio(int freq, int samples)
  {
    AudioData *data = new AudioData();
    SDL_Init(SDL_INIT_AUDIO);
    SDL_AudioSpec wanted_spec;
    wanted_spec.freq = 44100;
    wanted_spec.format = AUDIO_S16SYS;
    wanted_spec.channels = av_get_channel_layout_nb_channels(AV_CH_LAYOUT_STEREO);
    wanted_spec.silence = 0;
    wanted_spec.samples = samples;
    wanted_spec.callback = fill_audio;
    wanted_spec.userdata = data;
    SDL_OpenAudio(&wanted_spec, NULL);
    SDL_PauseAudio(0);
    return data;
  }

  DLLEXPORT AudioData *closeAudio(AudioData *audio)
  {
    SDL_CloseAudio();
  }

  DLLEXPORT IMMDeviceEnumerator *createIMMDeviceEnumerator()
  {
    CoInitialize(NULL);
    IMMDeviceEnumerator *pEnumerator = NULL;
    CoCreateInstance(
        CLSID_MMDeviceEnumerator, NULL,
        CLSCTX_ALL, IID_IMMDeviceEnumerator,
        (void **)&pEnumerator);
    return pEnumerator;
  }
  DLLEXPORT void releaseIUnknown(IUnknown *p)
  {
    p->Release();
  }
  DLLEXPORT IMMDevice *IMMDeviceEnumeratorGetDefaultAudioEndpoint(IMMDeviceEnumerator *pEnumerator)
  {
    IMMDevice *pDevice = NULL;
    pEnumerator->GetDefaultAudioEndpoint(
        eRender, eConsole, &pDevice);
    return pDevice;
  }
  DLLEXPORT IAudioClient *IMMDeviceActivate(IMMDevice *pDevice)
  {
    IAudioClient *pAudioClient = NULL;
    pDevice->Activate(
        IID_IAudioClient, CLSCTX_ALL,
        NULL, (void **)&pAudioClient);
    return pAudioClient;
  }
  DLLEXPORT WAVEFORMATEX *IAudioClientGetMixFormat(IAudioClient *pAudioClient)
  {
    WAVEFORMATEX *pwfx = NULL;
    pAudioClient->GetMixFormat(&pwfx);
    return pwfx;
  }
  DLLEXPORT void ffiCoTaskMemFree(WAVEFORMATEX *pwfx)
  {
    CoTaskMemFree(pwfx);
  }
  DLLEXPORT AVSampleFormat GetSampleFormat(WAVEFORMATEX *wave_format)
  {
    switch (wave_format->wFormatTag)
    {
    case WAVE_FORMAT_PCM:
      if (16 == wave_format->wBitsPerSample)
      {
        return AV_SAMPLE_FMT_S16;
      }
      if (32 == wave_format->wBitsPerSample)
      {
        return AV_SAMPLE_FMT_S32;
      }
      break;
    case WAVE_FORMAT_IEEE_FLOAT:
      return AV_SAMPLE_FMT_FLT;
    case WAVE_FORMAT_ALAW:
    case WAVE_FORMAT_MULAW:
      return AV_SAMPLE_FMT_U8;
    case WAVE_FORMAT_EXTENSIBLE:
    {
      const WAVEFORMATEXTENSIBLE *wfe = reinterpret_cast<const WAVEFORMATEXTENSIBLE *>(wave_format);
      if (KSDATAFORMAT_SUBTYPE_IEEE_FLOAT == wfe->SubFormat)
      {
        return AV_SAMPLE_FMT_FLT;
      }
      if (KSDATAFORMAT_SUBTYPE_PCM == wfe->SubFormat)
      {
        if (16 == wave_format->wBitsPerSample)
        {
          return AV_SAMPLE_FMT_S16;
        }
        if (32 == wave_format->wBitsPerSample)
        {
          return AV_SAMPLE_FMT_S32;
        }
      }
      break;
    }
    default:
      break;
    }
    return AV_SAMPLE_FMT_NONE;
  }

  DLLEXPORT HRESULT IAudioClientInitialize(IAudioClient *pAudioClient, WAVEFORMATEX *pwfx,
                                           REFERENCE_TIME hnsRequestedDuration)
  {
    return pAudioClient->Initialize(
        AUDCLNT_SHAREMODE_SHARED,
        0,
        hnsRequestedDuration,
        0,
        pwfx,
        NULL);
  }
  DLLEXPORT UINT32 IAudioClientGetBufferSize(IAudioClient *pAudioClient)
  {
    UINT32 bufferFrameCount = 0;
    pAudioClient->GetBufferSize(&bufferFrameCount);
    return bufferFrameCount;
  }
  DLLEXPORT IAudioRenderClient *IAudioClientGetService(IAudioClient *pAudioClient)
  {
    IAudioRenderClient *pRenderClient = NULL;
    pAudioClient->GetService(
        IID_IAudioRenderClient,
        (void **)&pRenderClient);
    return pRenderClient;
  }
  // DLLEXPORT UINT32 IAudioRenderClientWriteBuffer(
  //     IAudioClient *pAudioClient, IAudioRenderClient *pRenderClient, UINT32 bufferFrameCount, BYTE *data, UINT32 length)
  // {
  //   UINT32 numFramesPadding;
  //   pAudioClient->GetCurrentPadding(&numFramesPadding);
  //   UINT32 requestBuffer = bufferFrameCount - numFramesPadding;
  //   if (requestBuffer > length)
  //     requestBuffer = length;
  //   BYTE *pData = NULL;
  //   pRenderClient->GetBuffer(requestBuffer, &pData);
  //   memcpy_s(pData, requestBuffer, data, requestBuffer);
  //   pRenderClient->ReleaseBuffer(requestBuffer, 0);
  //   return requestBuffer;
  // }
  DLLEXPORT UINT32 ffiMemcpy(void *dst, void *src, UINT32 size)
  {
    return memcpy_s(dst, size, src, size);
  }
  DLLEXPORT UINT32 IAudioClientGetCurrentPadding(IAudioClient *pAudioClient)
  {
    UINT32 numFramesPadding;
    pAudioClient->GetCurrentPadding(&numFramesPadding);
    return numFramesPadding;
  }
  DLLEXPORT BYTE *IAudioRenderClientGetBuffer(IAudioRenderClient *pRenderClient, UINT32 requestBuffer)
  {
    BYTE *pData = NULL;
    pRenderClient->GetBuffer(requestBuffer, &pData);
    return pData;
  }
  DLLEXPORT HRESULT IAudioRenderClientReleaseBuffer(IAudioRenderClient *pRenderClient, UINT32 requestBuffer)
  {
    return pRenderClient->ReleaseBuffer(requestBuffer, 0);
  }
  DLLEXPORT HRESULT IAudioClientStart(IAudioClient *pAudioClient)
  {
    return pAudioClient->Start();
  }
  DLLEXPORT HRESULT IAudioClientStop(IAudioClient *pAudioClient)
  {
    return pAudioClient->Stop();
  }
}