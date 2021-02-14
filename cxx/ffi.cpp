#ifdef _MSC_VER
#define DLLEXPORT __declspec(dllexport)
#else
#define DLLEXPORT __attribute__((visibility("default"))) __attribute__((used))
#endif

#define DEFINE_GET_CLASS_PROP(class, prop) \
  DLLEXPORT intptr_t get_##class##_##prop(class *p) { return (intptr_t)p->prop; }

#define DEFINE_SIZE_OF(class) \
  DLLEXPORT intptr_t sizeof_##class() { return sizeof(class); }

extern "C"
{
#include "libavcodec/avcodec.h"
#include "libavutil/imgutils.h"
#include "libavformat/avformat.h"
#include "libswscale/swscale.h"
#include "libswresample/swresample.h"

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
  DEFINE_GET_CLASS_PROP(AVPacket, stream_index)
}