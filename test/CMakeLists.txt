cmake_minimum_required(VERSION 3.15)
project(flutter_ffmpeg_plugin LANGUAGES CXX)

add_library(flutter_ffmpeg_plugin SHARED
  "${CMAKE_CURRENT_SOURCE_DIR}/../cxx/ffi.cpp"
)
target_include_directories(flutter_ffmpeg_plugin PRIVATE
  "${CMAKE_CURRENT_SOURCE_DIR}/../windows/ffmpeg/include"
)
target_compile_features(flutter_ffmpeg_plugin PUBLIC cxx_std_17)

target_link_libraries(flutter_ffmpeg_plugin PRIVATE
  "${CMAKE_CURRENT_SOURCE_DIR}/../windows/ffmpeg/lib/avcodec.lib"
  "${CMAKE_CURRENT_SOURCE_DIR}/../windows/ffmpeg/lib/avdevice.lib"
  "${CMAKE_CURRENT_SOURCE_DIR}/../windows/ffmpeg/lib/avfilter.lib"
  "${CMAKE_CURRENT_SOURCE_DIR}/../windows/ffmpeg/lib/avformat.lib"
  "${CMAKE_CURRENT_SOURCE_DIR}/../windows/ffmpeg/lib/avutil.lib"
  "${CMAKE_CURRENT_SOURCE_DIR}/../windows/ffmpeg/lib/swresample.lib"
  "${CMAKE_CURRENT_SOURCE_DIR}/../windows/ffmpeg/lib/swscale.lib"
)

file(COPY ${CMAKE_CURRENT_SOURCE_DIR}/../windows/ffmpeg/bin/ DESTINATION ${CMAKE_CURRENT_SOURCE_DIR}/build/Debug/)