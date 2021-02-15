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

abstract class AVPixelFormat {
  static const int AV_PIX_FMT_NONE = -1;

  /// ///< planar YUV 4:2:0, 12bpp, (1 Cr & Cb sample per 2x2 Y samples)
  static const int AV_PIX_FMT_YUV420P = 0;

  /// ///< packed YUV 4:2:2, 16bpp, Y0 Cb Y1 Cr
  static const int AV_PIX_FMT_YUYV422 = 1;

  /// ///< packed RGB 8:8:8, 24bpp, RGBRGB...
  static const int AV_PIX_FMT_RGB24 = 2;

  /// ///< packed RGB 8:8:8, 24bpp, BGRBGR...
  static const int AV_PIX_FMT_BGR24 = 3;

  /// ///< planar YUV 4:2:2, 16bpp, (1 Cr & Cb sample per 2x1 Y samples)
  static const int AV_PIX_FMT_YUV422P = 4;

  /// ///< planar YUV 4:4:4, 24bpp, (1 Cr & Cb sample per 1x1 Y samples)
  static const int AV_PIX_FMT_YUV444P = 5;

  /// ///< planar YUV 4:1:0,  9bpp, (1 Cr & Cb sample per 4x4 Y samples)
  static const int AV_PIX_FMT_YUV410P = 6;

  /// ///< planar YUV 4:1:1, 12bpp, (1 Cr & Cb sample per 4x1 Y samples)
  static const int AV_PIX_FMT_YUV411P = 7;

  /// ///<        Y        ,  8bpp
  static const int AV_PIX_FMT_GRAY8 = 8;

  /// ///<        Y        ,  1bpp, 0 is white, 1 is black, in each byte pixels are ordered from the msb to the lsb
  static const int AV_PIX_FMT_MONOWHITE = 9;

  /// ///<        Y        ,  1bpp, 0 is black, 1 is white, in each byte pixels are ordered from the msb to the lsb
  static const int AV_PIX_FMT_MONOBLACK = 10;

  /// ///< 8 bits with AV_PIX_FMT_RGB32 palette
  static const int AV_PIX_FMT_PAL8 = 11;

  /// ///< planar YUV 4:2:0, 12bpp, full scale (JPEG), deprecated in favor of AV_PIX_FMT_YUV420P and setting color_range
  static const int AV_PIX_FMT_YUVJ420P = 12;

  /// ///< planar YUV 4:2:2, 16bpp, full scale (JPEG), deprecated in favor of AV_PIX_FMT_YUV422P and setting color_range
  static const int AV_PIX_FMT_YUVJ422P = 13;

  /// ///< planar YUV 4:4:4, 24bpp, full scale (JPEG), deprecated in favor of AV_PIX_FMT_YUV444P and setting color_range
  static const int AV_PIX_FMT_YUVJ444P = 14;

  /// ///< packed YUV 4:2:2, 16bpp, Cb Y0 Cr Y1
  static const int AV_PIX_FMT_UYVY422 = 15;

  /// ///< packed YUV 4:1:1, 12bpp, Cb Y0 Y1 Cr Y2 Y3
  static const int AV_PIX_FMT_UYYVYY411 = 16;

  /// ///< packed RGB 3:3:2,  8bpp, (msb)2B 3G 3R(lsb)
  static const int AV_PIX_FMT_BGR8 = 17;

  /// ///< packed RGB 1:2:1 bitstream,  4bpp, (msb)1B 2G 1R(lsb), a byte contains two pixels, the first pixel in the byte is the one composed by the 4 msb bits
  static const int AV_PIX_FMT_BGR4 = 18;

  /// ///< packed RGB 1:2:1,  8bpp, (msb)1B 2G 1R(lsb)
  static const int AV_PIX_FMT_BGR4_BYTE = 19;

  /// ///< packed RGB 3:3:2,  8bpp, (msb)2R 3G 3B(lsb)
  static const int AV_PIX_FMT_RGB8 = 20;

  /// ///< packed RGB 1:2:1 bitstream,  4bpp, (msb)1R 2G 1B(lsb), a byte contains two pixels, the first pixel in the byte is the one composed by the 4 msb bits
  static const int AV_PIX_FMT_RGB4 = 21;

  /// ///< packed RGB 1:2:1,  8bpp, (msb)1R 2G 1B(lsb)
  static const int AV_PIX_FMT_RGB4_BYTE = 22;

  /// ///< planar YUV 4:2:0, 12bpp, 1 plane for Y and 1 plane for the UV components, which are interleaved (first byte U and the following byte V)
  static const int AV_PIX_FMT_NV12 = 23;

  /// ///< as above, but U and V bytes are swapped
  static const int AV_PIX_FMT_NV21 = 24;

  /// ///< packed ARGB 8:8:8:8, 32bpp, ARGBARGB...
  static const int AV_PIX_FMT_ARGB = 25;

  /// ///< packed RGBA 8:8:8:8, 32bpp, RGBARGBA...
  static const int AV_PIX_FMT_RGBA = 26;

  /// ///< packed ABGR 8:8:8:8, 32bpp, ABGRABGR...
  static const int AV_PIX_FMT_ABGR = 27;

  /// ///< packed BGRA 8:8:8:8, 32bpp, BGRABGRA...
  static const int AV_PIX_FMT_BGRA = 28;

  /// ///<        Y        , 16bpp, big-endian
  static const int AV_PIX_FMT_GRAY16BE = 29;

  /// ///<        Y        , 16bpp, little-endian
  static const int AV_PIX_FMT_GRAY16LE = 30;

  /// ///< planar YUV 4:4:0 (1 Cr & Cb sample per 1x2 Y samples)
  static const int AV_PIX_FMT_YUV440P = 31;

  /// ///< planar YUV 4:4:0 full scale (JPEG), deprecated in favor of AV_PIX_FMT_YUV440P and setting color_range
  static const int AV_PIX_FMT_YUVJ440P = 32;

  /// ///< planar YUV 4:2:0, 20bpp, (1 Cr & Cb sample per 2x2 Y & A samples)
  static const int AV_PIX_FMT_YUVA420P = 33;

  /// ///< packed RGB 16:16:16, 48bpp, 16R, 16G, 16B, the 2-byte value for each R/G/B component is stored as big-endian
  static const int AV_PIX_FMT_RGB48BE = 34;

  /// ///< packed RGB 16:16:16, 48bpp, 16R, 16G, 16B, the 2-byte value for each R/G/B component is stored as little-endian
  static const int AV_PIX_FMT_RGB48LE = 35;

  /// ///< packed RGB 5:6:5, 16bpp, (msb)   5R 6G 5B(lsb), big-endian
  static const int AV_PIX_FMT_RGB565BE = 36;

  /// ///< packed RGB 5:6:5, 16bpp, (msb)   5R 6G 5B(lsb), little-endian
  static const int AV_PIX_FMT_RGB565LE = 37;

  /// ///< packed RGB 5:5:5, 16bpp, (msb)1X 5R 5G 5B(lsb), big-endian   , X=unused/undefined
  static const int AV_PIX_FMT_RGB555BE = 38;

  /// ///< packed RGB 5:5:5, 16bpp, (msb)1X 5R 5G 5B(lsb), little-endian, X=unused/undefined
  static const int AV_PIX_FMT_RGB555LE = 39;

  /// ///< packed BGR 5:6:5, 16bpp, (msb)   5B 6G 5R(lsb), big-endian
  static const int AV_PIX_FMT_BGR565BE = 40;

  /// ///< packed BGR 5:6:5, 16bpp, (msb)   5B 6G 5R(lsb), little-endian
  static const int AV_PIX_FMT_BGR565LE = 41;

  /// ///< packed BGR 5:5:5, 16bpp, (msb)1X 5B 5G 5R(lsb), big-endian   , X=unused/undefined
  static const int AV_PIX_FMT_BGR555BE = 42;

  /// ///< packed BGR 5:5:5, 16bpp, (msb)1X 5B 5G 5R(lsb), little-endian, X=unused/undefined
  static const int AV_PIX_FMT_BGR555LE = 43;

  /// ///< HW acceleration through VA API at motion compensation entry-point, Picture.data[3] contains a vaapi_render_state struct which contains macroblocks as well as various fields extracted from headers
  static const int AV_PIX_FMT_VAAPI_MOCO = 44;

  /// ///< HW acceleration through VA API at IDCT entry-point, Picture.data[3] contains a vaapi_render_state struct which contains fields extracted from headers
  static const int AV_PIX_FMT_VAAPI_IDCT = 45;

  /// ///< HW decoding through VA API, Picture.data[3] contains a VASurfaceID
  static const int AV_PIX_FMT_VAAPI_VLD = 46;

  /// @}
  static const int AV_PIX_FMT_VAAPI = 46;

  /// ///< planar YUV 4:2:0, 24bpp, (1 Cr & Cb sample per 2x2 Y samples), little-endian
  static const int AV_PIX_FMT_YUV420P16LE = 47;

  /// ///< planar YUV 4:2:0, 24bpp, (1 Cr & Cb sample per 2x2 Y samples), big-endian
  static const int AV_PIX_FMT_YUV420P16BE = 48;

  /// ///< planar YUV 4:2:2, 32bpp, (1 Cr & Cb sample per 2x1 Y samples), little-endian
  static const int AV_PIX_FMT_YUV422P16LE = 49;

  /// ///< planar YUV 4:2:2, 32bpp, (1 Cr & Cb sample per 2x1 Y samples), big-endian
  static const int AV_PIX_FMT_YUV422P16BE = 50;

  /// ///< planar YUV 4:4:4, 48bpp, (1 Cr & Cb sample per 1x1 Y samples), little-endian
  static const int AV_PIX_FMT_YUV444P16LE = 51;

  /// ///< planar YUV 4:4:4, 48bpp, (1 Cr & Cb sample per 1x1 Y samples), big-endian
  static const int AV_PIX_FMT_YUV444P16BE = 52;

  /// ///< HW decoding through DXVA2, Picture.data[3] contains a LPDIRECT3DSURFACE9 pointer
  static const int AV_PIX_FMT_DXVA2_VLD = 53;

  /// ///< packed RGB 4:4:4, 16bpp, (msb)4X 4R 4G 4B(lsb), little-endian, X=unused/undefined
  static const int AV_PIX_FMT_RGB444LE = 54;

  /// ///< packed RGB 4:4:4, 16bpp, (msb)4X 4R 4G 4B(lsb), big-endian,    X=unused/undefined
  static const int AV_PIX_FMT_RGB444BE = 55;

  /// ///< packed BGR 4:4:4, 16bpp, (msb)4X 4B 4G 4R(lsb), little-endian, X=unused/undefined
  static const int AV_PIX_FMT_BGR444LE = 56;

  /// ///< packed BGR 4:4:4, 16bpp, (msb)4X 4B 4G 4R(lsb), big-endian,    X=unused/undefined
  static const int AV_PIX_FMT_BGR444BE = 57;

  /// ///< 8 bits gray, 8 bits alpha
  static const int AV_PIX_FMT_YA8 = 58;

  /// ///< alias for AV_PIX_FMT_YA8
  static const int AV_PIX_FMT_Y400A = 58;

  /// ///< alias for AV_PIX_FMT_YA8
  static const int AV_PIX_FMT_GRAY8A = 58;

  /// ///< packed RGB 16:16:16, 48bpp, 16B, 16G, 16R, the 2-byte value for each R/G/B component is stored as big-endian
  static const int AV_PIX_FMT_BGR48BE = 59;

  /// ///< packed RGB 16:16:16, 48bpp, 16B, 16G, 16R, the 2-byte value for each R/G/B component is stored as little-endian
  static const int AV_PIX_FMT_BGR48LE = 60;

  /// ///< planar YUV 4:2:0, 13.5bpp, (1 Cr & Cb sample per 2x2 Y samples), big-endian
  static const int AV_PIX_FMT_YUV420P9BE = 61;

  /// ///< planar YUV 4:2:0, 13.5bpp, (1 Cr & Cb sample per 2x2 Y samples), little-endian
  static const int AV_PIX_FMT_YUV420P9LE = 62;

  /// ///< planar YUV 4:2:0, 15bpp, (1 Cr & Cb sample per 2x2 Y samples), big-endian
  static const int AV_PIX_FMT_YUV420P10BE = 63;

  /// ///< planar YUV 4:2:0, 15bpp, (1 Cr & Cb sample per 2x2 Y samples), little-endian
  static const int AV_PIX_FMT_YUV420P10LE = 64;

  /// ///< planar YUV 4:2:2, 20bpp, (1 Cr & Cb sample per 2x1 Y samples), big-endian
  static const int AV_PIX_FMT_YUV422P10BE = 65;

  /// ///< planar YUV 4:2:2, 20bpp, (1 Cr & Cb sample per 2x1 Y samples), little-endian
  static const int AV_PIX_FMT_YUV422P10LE = 66;

  /// ///< planar YUV 4:4:4, 27bpp, (1 Cr & Cb sample per 1x1 Y samples), big-endian
  static const int AV_PIX_FMT_YUV444P9BE = 67;

  /// ///< planar YUV 4:4:4, 27bpp, (1 Cr & Cb sample per 1x1 Y samples), little-endian
  static const int AV_PIX_FMT_YUV444P9LE = 68;

  /// ///< planar YUV 4:4:4, 30bpp, (1 Cr & Cb sample per 1x1 Y samples), big-endian
  static const int AV_PIX_FMT_YUV444P10BE = 69;

  /// ///< planar YUV 4:4:4, 30bpp, (1 Cr & Cb sample per 1x1 Y samples), little-endian
  static const int AV_PIX_FMT_YUV444P10LE = 70;

  /// ///< planar YUV 4:2:2, 18bpp, (1 Cr & Cb sample per 2x1 Y samples), big-endian
  static const int AV_PIX_FMT_YUV422P9BE = 71;

  /// ///< planar YUV 4:2:2, 18bpp, (1 Cr & Cb sample per 2x1 Y samples), little-endian
  static const int AV_PIX_FMT_YUV422P9LE = 72;

  /// ///< planar GBR 4:4:4 24bpp
  static const int AV_PIX_FMT_GBRP = 73;
  static const int AV_PIX_FMT_GBR24P = 73;

  /// ///< planar GBR 4:4:4 27bpp, big-endian
  static const int AV_PIX_FMT_GBRP9BE = 74;

  /// ///< planar GBR 4:4:4 27bpp, little-endian
  static const int AV_PIX_FMT_GBRP9LE = 75;

  /// ///< planar GBR 4:4:4 30bpp, big-endian
  static const int AV_PIX_FMT_GBRP10BE = 76;

  /// ///< planar GBR 4:4:4 30bpp, little-endian
  static const int AV_PIX_FMT_GBRP10LE = 77;

  /// ///< planar GBR 4:4:4 48bpp, big-endian
  static const int AV_PIX_FMT_GBRP16BE = 78;

  /// ///< planar GBR 4:4:4 48bpp, little-endian
  static const int AV_PIX_FMT_GBRP16LE = 79;

  /// ///< planar YUV 4:2:2 24bpp, (1 Cr & Cb sample per 2x1 Y & A samples)
  static const int AV_PIX_FMT_YUVA422P = 80;

  /// ///< planar YUV 4:4:4 32bpp, (1 Cr & Cb sample per 1x1 Y & A samples)
  static const int AV_PIX_FMT_YUVA444P = 81;

  /// ///< planar YUV 4:2:0 22.5bpp, (1 Cr & Cb sample per 2x2 Y & A samples), big-endian
  static const int AV_PIX_FMT_YUVA420P9BE = 82;

  /// ///< planar YUV 4:2:0 22.5bpp, (1 Cr & Cb sample per 2x2 Y & A samples), little-endian
  static const int AV_PIX_FMT_YUVA420P9LE = 83;

  /// ///< planar YUV 4:2:2 27bpp, (1 Cr & Cb sample per 2x1 Y & A samples), big-endian
  static const int AV_PIX_FMT_YUVA422P9BE = 84;

  /// ///< planar YUV 4:2:2 27bpp, (1 Cr & Cb sample per 2x1 Y & A samples), little-endian
  static const int AV_PIX_FMT_YUVA422P9LE = 85;

  /// ///< planar YUV 4:4:4 36bpp, (1 Cr & Cb sample per 1x1 Y & A samples), big-endian
  static const int AV_PIX_FMT_YUVA444P9BE = 86;

  /// ///< planar YUV 4:4:4 36bpp, (1 Cr & Cb sample per 1x1 Y & A samples), little-endian
  static const int AV_PIX_FMT_YUVA444P9LE = 87;

  /// ///< planar YUV 4:2:0 25bpp, (1 Cr & Cb sample per 2x2 Y & A samples, big-endian)
  static const int AV_PIX_FMT_YUVA420P10BE = 88;

  /// ///< planar YUV 4:2:0 25bpp, (1 Cr & Cb sample per 2x2 Y & A samples, little-endian)
  static const int AV_PIX_FMT_YUVA420P10LE = 89;

  /// ///< planar YUV 4:2:2 30bpp, (1 Cr & Cb sample per 2x1 Y & A samples, big-endian)
  static const int AV_PIX_FMT_YUVA422P10BE = 90;

  /// ///< planar YUV 4:2:2 30bpp, (1 Cr & Cb sample per 2x1 Y & A samples, little-endian)
  static const int AV_PIX_FMT_YUVA422P10LE = 91;

  /// ///< planar YUV 4:4:4 40bpp, (1 Cr & Cb sample per 1x1 Y & A samples, big-endian)
  static const int AV_PIX_FMT_YUVA444P10BE = 92;

  /// ///< planar YUV 4:4:4 40bpp, (1 Cr & Cb sample per 1x1 Y & A samples, little-endian)
  static const int AV_PIX_FMT_YUVA444P10LE = 93;

  /// ///< planar YUV 4:2:0 40bpp, (1 Cr & Cb sample per 2x2 Y & A samples, big-endian)
  static const int AV_PIX_FMT_YUVA420P16BE = 94;

  /// ///< planar YUV 4:2:0 40bpp, (1 Cr & Cb sample per 2x2 Y & A samples, little-endian)
  static const int AV_PIX_FMT_YUVA420P16LE = 95;

  /// ///< planar YUV 4:2:2 48bpp, (1 Cr & Cb sample per 2x1 Y & A samples, big-endian)
  static const int AV_PIX_FMT_YUVA422P16BE = 96;

  /// ///< planar YUV 4:2:2 48bpp, (1 Cr & Cb sample per 2x1 Y & A samples, little-endian)
  static const int AV_PIX_FMT_YUVA422P16LE = 97;

  /// ///< planar YUV 4:4:4 64bpp, (1 Cr & Cb sample per 1x1 Y & A samples, big-endian)
  static const int AV_PIX_FMT_YUVA444P16BE = 98;

  /// ///< planar YUV 4:4:4 64bpp, (1 Cr & Cb sample per 1x1 Y & A samples, little-endian)
  static const int AV_PIX_FMT_YUVA444P16LE = 99;

  /// ///< HW acceleration through VDPAU, Picture.data[3] contains a VdpVideoSurface
  static const int AV_PIX_FMT_VDPAU = 100;

  /// ///< packed XYZ 4:4:4, 36 bpp, (msb) 12X, 12Y, 12Z (lsb), the 2-byte value for each X/Y/Z is stored as little-endian, the 4 lower bits are set to 0
  static const int AV_PIX_FMT_XYZ12LE = 101;

  /// ///< packed XYZ 4:4:4, 36 bpp, (msb) 12X, 12Y, 12Z (lsb), the 2-byte value for each X/Y/Z is stored as big-endian, the 4 lower bits are set to 0
  static const int AV_PIX_FMT_XYZ12BE = 102;

  /// ///< interleaved chroma YUV 4:2:2, 16bpp, (1 Cr & Cb sample per 2x1 Y samples)
  static const int AV_PIX_FMT_NV16 = 103;

  /// ///< interleaved chroma YUV 4:2:2, 20bpp, (1 Cr & Cb sample per 2x1 Y samples), little-endian
  static const int AV_PIX_FMT_NV20LE = 104;

  /// ///< interleaved chroma YUV 4:2:2, 20bpp, (1 Cr & Cb sample per 2x1 Y samples), big-endian
  static const int AV_PIX_FMT_NV20BE = 105;

  /// ///< packed RGBA 16:16:16:16, 64bpp, 16R, 16G, 16B, 16A, the 2-byte value for each R/G/B/A component is stored as big-endian
  static const int AV_PIX_FMT_RGBA64BE = 106;

  /// ///< packed RGBA 16:16:16:16, 64bpp, 16R, 16G, 16B, 16A, the 2-byte value for each R/G/B/A component is stored as little-endian
  static const int AV_PIX_FMT_RGBA64LE = 107;

  /// ///< packed RGBA 16:16:16:16, 64bpp, 16B, 16G, 16R, 16A, the 2-byte value for each R/G/B/A component is stored as big-endian
  static const int AV_PIX_FMT_BGRA64BE = 108;

  /// ///< packed RGBA 16:16:16:16, 64bpp, 16B, 16G, 16R, 16A, the 2-byte value for each R/G/B/A component is stored as little-endian
  static const int AV_PIX_FMT_BGRA64LE = 109;

  /// ///< packed YUV 4:2:2, 16bpp, Y0 Cr Y1 Cb
  static const int AV_PIX_FMT_YVYU422 = 110;

  /// ///< 16 bits gray, 16 bits alpha (big-endian)
  static const int AV_PIX_FMT_YA16BE = 111;

  /// ///< 16 bits gray, 16 bits alpha (little-endian)
  static const int AV_PIX_FMT_YA16LE = 112;

  /// ///< planar GBRA 4:4:4:4 32bpp
  static const int AV_PIX_FMT_GBRAP = 113;

  /// ///< planar GBRA 4:4:4:4 64bpp, big-endian
  static const int AV_PIX_FMT_GBRAP16BE = 114;

  /// ///< planar GBRA 4:4:4:4 64bpp, little-endian
  static const int AV_PIX_FMT_GBRAP16LE = 115;

  /// HW acceleration through QSV, data[3] contains a pointer to the
  /// mfxFrameSurface1 structure.
  static const int AV_PIX_FMT_QSV = 116;

  /// HW acceleration though MMAL, data[3] contains a pointer to the
  /// MMAL_BUFFER_HEADER_T structure.
  static const int AV_PIX_FMT_MMAL = 117;

  /// ///< HW decoding through Direct3D11 via old API, Picture.data[3] contains a ID3D11VideoDecoderOutputView pointer
  static const int AV_PIX_FMT_D3D11VA_VLD = 118;

  /// HW acceleration through CUDA. data[i] contain CUdeviceptr pointers
  /// exactly as for system memory frames.
  static const int AV_PIX_FMT_CUDA = 119;

  /// ///< packed RGB 8:8:8, 32bpp, XRGBXRGB...   X=unused/undefined
  static const int AV_PIX_FMT_0RGB = 120;

  /// ///< packed RGB 8:8:8, 32bpp, RGBXRGBX...   X=unused/undefined
  static const int AV_PIX_FMT_RGB0 = 121;

  /// ///< packed BGR 8:8:8, 32bpp, XBGRXBGR...   X=unused/undefined
  static const int AV_PIX_FMT_0BGR = 122;

  /// ///< packed BGR 8:8:8, 32bpp, BGRXBGRX...   X=unused/undefined
  static const int AV_PIX_FMT_BGR0 = 123;

  /// ///< planar YUV 4:2:0,18bpp, (1 Cr & Cb sample per 2x2 Y samples), big-endian
  static const int AV_PIX_FMT_YUV420P12BE = 124;

  /// ///< planar YUV 4:2:0,18bpp, (1 Cr & Cb sample per 2x2 Y samples), little-endian
  static const int AV_PIX_FMT_YUV420P12LE = 125;

  /// ///< planar YUV 4:2:0,21bpp, (1 Cr & Cb sample per 2x2 Y samples), big-endian
  static const int AV_PIX_FMT_YUV420P14BE = 126;

  /// ///< planar YUV 4:2:0,21bpp, (1 Cr & Cb sample per 2x2 Y samples), little-endian
  static const int AV_PIX_FMT_YUV420P14LE = 127;

  /// ///< planar YUV 4:2:2,24bpp, (1 Cr & Cb sample per 2x1 Y samples), big-endian
  static const int AV_PIX_FMT_YUV422P12BE = 128;

  /// ///< planar YUV 4:2:2,24bpp, (1 Cr & Cb sample per 2x1 Y samples), little-endian
  static const int AV_PIX_FMT_YUV422P12LE = 129;

  /// ///< planar YUV 4:2:2,28bpp, (1 Cr & Cb sample per 2x1 Y samples), big-endian
  static const int AV_PIX_FMT_YUV422P14BE = 130;

  /// ///< planar YUV 4:2:2,28bpp, (1 Cr & Cb sample per 2x1 Y samples), little-endian
  static const int AV_PIX_FMT_YUV422P14LE = 131;

  /// ///< planar YUV 4:4:4,36bpp, (1 Cr & Cb sample per 1x1 Y samples), big-endian
  static const int AV_PIX_FMT_YUV444P12BE = 132;

  /// ///< planar YUV 4:4:4,36bpp, (1 Cr & Cb sample per 1x1 Y samples), little-endian
  static const int AV_PIX_FMT_YUV444P12LE = 133;

  /// ///< planar YUV 4:4:4,42bpp, (1 Cr & Cb sample per 1x1 Y samples), big-endian
  static const int AV_PIX_FMT_YUV444P14BE = 134;

  /// ///< planar YUV 4:4:4,42bpp, (1 Cr & Cb sample per 1x1 Y samples), little-endian
  static const int AV_PIX_FMT_YUV444P14LE = 135;

  /// ///< planar GBR 4:4:4 36bpp, big-endian
  static const int AV_PIX_FMT_GBRP12BE = 136;

  /// ///< planar GBR 4:4:4 36bpp, little-endian
  static const int AV_PIX_FMT_GBRP12LE = 137;

  /// ///< planar GBR 4:4:4 42bpp, big-endian
  static const int AV_PIX_FMT_GBRP14BE = 138;

  /// ///< planar GBR 4:4:4 42bpp, little-endian
  static const int AV_PIX_FMT_GBRP14LE = 139;

  /// ///< planar YUV 4:1:1, 12bpp, (1 Cr & Cb sample per 4x1 Y samples) full scale (JPEG), deprecated in favor of AV_PIX_FMT_YUV411P and setting color_range
  static const int AV_PIX_FMT_YUVJ411P = 140;

  /// ///< bayer, BGBG..(odd line), GRGR..(even line), 8-bit samples
  static const int AV_PIX_FMT_BAYER_BGGR8 = 141;

  /// ///< bayer, RGRG..(odd line), GBGB..(even line), 8-bit samples
  static const int AV_PIX_FMT_BAYER_RGGB8 = 142;

  /// ///< bayer, GBGB..(odd line), RGRG..(even line), 8-bit samples
  static const int AV_PIX_FMT_BAYER_GBRG8 = 143;

  /// ///< bayer, GRGR..(odd line), BGBG..(even line), 8-bit samples
  static const int AV_PIX_FMT_BAYER_GRBG8 = 144;

  /// ///< bayer, BGBG..(odd line), GRGR..(even line), 16-bit samples, little-endian
  static const int AV_PIX_FMT_BAYER_BGGR16LE = 145;

  /// ///< bayer, BGBG..(odd line), GRGR..(even line), 16-bit samples, big-endian
  static const int AV_PIX_FMT_BAYER_BGGR16BE = 146;

  /// ///< bayer, RGRG..(odd line), GBGB..(even line), 16-bit samples, little-endian
  static const int AV_PIX_FMT_BAYER_RGGB16LE = 147;

  /// ///< bayer, RGRG..(odd line), GBGB..(even line), 16-bit samples, big-endian
  static const int AV_PIX_FMT_BAYER_RGGB16BE = 148;

  /// ///< bayer, GBGB..(odd line), RGRG..(even line), 16-bit samples, little-endian
  static const int AV_PIX_FMT_BAYER_GBRG16LE = 149;

  /// ///< bayer, GBGB..(odd line), RGRG..(even line), 16-bit samples, big-endian
  static const int AV_PIX_FMT_BAYER_GBRG16BE = 150;

  /// ///< bayer, GRGR..(odd line), BGBG..(even line), 16-bit samples, little-endian
  static const int AV_PIX_FMT_BAYER_GRBG16LE = 151;

  /// ///< bayer, GRGR..(odd line), BGBG..(even line), 16-bit samples, big-endian
  static const int AV_PIX_FMT_BAYER_GRBG16BE = 152;

  /// ///< XVideo Motion Acceleration via common packet passing
  static const int AV_PIX_FMT_XVMC = 153;

  /// ///< planar YUV 4:4:0,20bpp, (1 Cr & Cb sample per 1x2 Y samples), little-endian
  static const int AV_PIX_FMT_YUV440P10LE = 154;

  /// ///< planar YUV 4:4:0,20bpp, (1 Cr & Cb sample per 1x2 Y samples), big-endian
  static const int AV_PIX_FMT_YUV440P10BE = 155;

  /// ///< planar YUV 4:4:0,24bpp, (1 Cr & Cb sample per 1x2 Y samples), little-endian
  static const int AV_PIX_FMT_YUV440P12LE = 156;

  /// ///< planar YUV 4:4:0,24bpp, (1 Cr & Cb sample per 1x2 Y samples), big-endian
  static const int AV_PIX_FMT_YUV440P12BE = 157;

  /// ///< packed AYUV 4:4:4,64bpp (1 Cr & Cb sample per 1x1 Y & A samples), little-endian
  static const int AV_PIX_FMT_AYUV64LE = 158;

  /// ///< packed AYUV 4:4:4,64bpp (1 Cr & Cb sample per 1x1 Y & A samples), big-endian
  static const int AV_PIX_FMT_AYUV64BE = 159;

  /// ///< hardware decoding through Videotoolbox
  static const int AV_PIX_FMT_VIDEOTOOLBOX = 160;

  /// ///< like NV12, with 10bpp per component, data in the high bits, zeros in the low bits, little-endian
  static const int AV_PIX_FMT_P010LE = 161;

  /// ///< like NV12, with 10bpp per component, data in the high bits, zeros in the low bits, big-endian
  static const int AV_PIX_FMT_P010BE = 162;

  /// ///< planar GBR 4:4:4:4 48bpp, big-endian
  static const int AV_PIX_FMT_GBRAP12BE = 163;

  /// ///< planar GBR 4:4:4:4 48bpp, little-endian
  static const int AV_PIX_FMT_GBRAP12LE = 164;

  /// ///< planar GBR 4:4:4:4 40bpp, big-endian
  static const int AV_PIX_FMT_GBRAP10BE = 165;

  /// ///< planar GBR 4:4:4:4 40bpp, little-endian
  static const int AV_PIX_FMT_GBRAP10LE = 166;

  /// ///< hardware decoding through MediaCodec
  static const int AV_PIX_FMT_MEDIACODEC = 167;

  /// ///<        Y        , 12bpp, big-endian
  static const int AV_PIX_FMT_GRAY12BE = 168;

  /// ///<        Y        , 12bpp, little-endian
  static const int AV_PIX_FMT_GRAY12LE = 169;

  /// ///<        Y        , 10bpp, big-endian
  static const int AV_PIX_FMT_GRAY10BE = 170;

  /// ///<        Y        , 10bpp, little-endian
  static const int AV_PIX_FMT_GRAY10LE = 171;

  /// ///< like NV12, with 16bpp per component, little-endian
  static const int AV_PIX_FMT_P016LE = 172;

  /// ///< like NV12, with 16bpp per component, big-endian
  static const int AV_PIX_FMT_P016BE = 173;

  /// Hardware surfaces for Direct3D11.
  ///
  /// This is preferred over the legacy AV_PIX_FMT_D3D11VA_VLD. The new D3D11
  /// hwaccel API and filtering support AV_PIX_FMT_D3D11 only.
  ///
  /// data[0] contains a ID3D11Texture2D pointer, and data[1] contains the
  /// texture array index of the frame as intptr_t if the ID3D11Texture2D is
  /// an array texture (or always 0 if it's a normal texture).
  static const int AV_PIX_FMT_D3D11 = 174;

  /// ///<        Y        , 9bpp, big-endian
  static const int AV_PIX_FMT_GRAY9BE = 175;

  /// ///<        Y        , 9bpp, little-endian
  static const int AV_PIX_FMT_GRAY9LE = 176;

  /// ///< IEEE-754 single precision planar GBR 4:4:4,     96bpp, big-endian
  static const int AV_PIX_FMT_GBRPF32BE = 177;

  /// ///< IEEE-754 single precision planar GBR 4:4:4,     96bpp, little-endian
  static const int AV_PIX_FMT_GBRPF32LE = 178;

  /// ///< IEEE-754 single precision planar GBRA 4:4:4:4, 128bpp, big-endian
  static const int AV_PIX_FMT_GBRAPF32BE = 179;

  /// ///< IEEE-754 single precision planar GBRA 4:4:4:4, 128bpp, little-endian
  static const int AV_PIX_FMT_GBRAPF32LE = 180;

  /// DRM-managed buffers exposed through PRIME buffer sharing.
  ///
  /// data[0] points to an AVDRMFrameDescriptor.
  static const int AV_PIX_FMT_DRM_PRIME = 181;

  /// Hardware surfaces for OpenCL.
  ///
  /// data[i] contain 2D image objects (typed in C as cl_mem, used
  /// in OpenCL as image2d_t) for each plane of the surface.
  static const int AV_PIX_FMT_OPENCL = 182;

  /// ///<        Y        , 14bpp, big-endian
  static const int AV_PIX_FMT_GRAY14BE = 183;

  /// ///<        Y        , 14bpp, little-endian
  static const int AV_PIX_FMT_GRAY14LE = 184;

  /// ///< IEEE-754 single precision Y, 32bpp, big-endian
  static const int AV_PIX_FMT_GRAYF32BE = 185;

  /// ///< IEEE-754 single precision Y, 32bpp, little-endian
  static const int AV_PIX_FMT_GRAYF32LE = 186;

  /// ///< planar YUV 4:2:2,24bpp, (1 Cr & Cb sample per 2x1 Y samples), 12b alpha, big-endian
  static const int AV_PIX_FMT_YUVA422P12BE = 187;

  /// ///< planar YUV 4:2:2,24bpp, (1 Cr & Cb sample per 2x1 Y samples), 12b alpha, little-endian
  static const int AV_PIX_FMT_YUVA422P12LE = 188;

  /// ///< planar YUV 4:4:4,36bpp, (1 Cr & Cb sample per 1x1 Y samples), 12b alpha, big-endian
  static const int AV_PIX_FMT_YUVA444P12BE = 189;

  /// ///< planar YUV 4:4:4,36bpp, (1 Cr & Cb sample per 1x1 Y samples), 12b alpha, little-endian
  static const int AV_PIX_FMT_YUVA444P12LE = 190;

  /// ///< planar YUV 4:4:4, 24bpp, 1 plane for Y and 1 plane for the UV components, which are interleaved (first byte U and the following byte V)
  static const int AV_PIX_FMT_NV24 = 191;

  /// ///< as above, but U and V bytes are swapped
  static const int AV_PIX_FMT_NV42 = 192;

  /// Vulkan hardware images.
  ///
  /// data[0] points to an AVVkFrame
  static const int AV_PIX_FMT_VULKAN = 193;

  /// ///< packed YUV 4:2:2 like YUYV422, 20bpp, data in the high bits, big-endian
  static const int AV_PIX_FMT_Y210BE = 194;

  /// ///< packed YUV 4:2:2 like YUYV422, 20bpp, data in the high bits, little-endian
  static const int AV_PIX_FMT_Y210LE = 195;

  /// ///< packed RGB 10:10:10, 30bpp, (msb)2X 10R 10G 10B(lsb), little-endian, X=unused/undefined
  static const int AV_PIX_FMT_X2RGB10LE = 196;

  /// ///< packed RGB 10:10:10, 30bpp, (msb)2X 10R 10G 10B(lsb), big-endian, X=unused/undefined
  static const int AV_PIX_FMT_X2RGB10BE = 197;

  /// ///< number of pixel formats, DO NOT USE THIS if you want to link with shared libav* because the number of formats might differ between versions
  static const int AV_PIX_FMT_NB = 198;
}

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
}

class SwsContext extends Struct {}

class SwsFilter extends Struct {}

class AVPacket extends Struct {}

extension PointerAVPacket on Pointer<AVPacket> {
  int get stream_index => _ffiGetProperty(this, 'stream_index');
}

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

// HRESULT IAudioRenderClientReleaseBuffer(IAudioRenderClient *pRenderClient, UINT32 requestBuffer)
final int Function(
  Pointer<IAudioRenderClient> pRenderClient,
  int requestBuffer,
) iAudioRenderClientReleaseBuffer = ffilib
    .lookup<
        NativeFunction<
            Int32 Function(
      Pointer<IAudioRenderClient>,
      Uint32,
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