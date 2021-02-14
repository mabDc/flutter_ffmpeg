cmake_minimum_required(VERSION 3.15)
set(PROJECT_NAME "flutter_ffmpeg")
project(${PROJECT_NAME} LANGUAGES CXX)

# This value is used when generating builds using this plugin, so it must
# not be changed
set(PLUGIN_NAME "flutter_ffmpeg_plugin")

add_library(${PLUGIN_NAME} SHARED
  "${CMAKE_CURRENT_SOURCE_DIR}/../cxx/ffi.cpp"
  "flutter_ffmpeg_plugin.cpp"
)
apply_standard_settings(${PLUGIN_NAME})
set_target_properties(${PLUGIN_NAME} PROPERTIES
  CXX_VISIBILITY_PRESET hidden)
target_compile_definitions(${PLUGIN_NAME} PRIVATE FLUTTER_PLUGIN_IMPL)
target_include_directories(${PLUGIN_NAME} INTERFACE
  "${CMAKE_CURRENT_SOURCE_DIR}/include"
)
target_include_directories(${PLUGIN_NAME} PRIVATE
  "${CMAKE_CURRENT_SOURCE_DIR}/ffmpeg/include"
)
target_compile_options(${PLUGIN_NAME} PRIVATE /WX-)

target_link_libraries(${PLUGIN_NAME} PRIVATE flutter flutter_wrapper_plugin)

target_link_libraries(${PLUGIN_NAME} PRIVATE
  "${CMAKE_CURRENT_SOURCE_DIR}/ffmpeg/lib/avcodec.lib"
  "${CMAKE_CURRENT_SOURCE_DIR}/ffmpeg/lib/avdevice.lib"
  "${CMAKE_CURRENT_SOURCE_DIR}/ffmpeg/lib/avfilter.lib"
  "${CMAKE_CURRENT_SOURCE_DIR}/ffmpeg/lib/avformat.lib"
  "${CMAKE_CURRENT_SOURCE_DIR}/ffmpeg/lib/avutil.lib"
  "${CMAKE_CURRENT_SOURCE_DIR}/ffmpeg/lib/swresample.lib"
  "${CMAKE_CURRENT_SOURCE_DIR}/ffmpeg/lib/swscale.lib"
)

# List of absolute paths to libraries that should be bundled with the plugin
set(flutter_ffmpeg_bundled_libraries
  "${CMAKE_CURRENT_SOURCE_DIR}/ffmpeg/bin/avcodec-58.dll"
  "${CMAKE_CURRENT_SOURCE_DIR}/ffmpeg/bin/avdevice-58.dll"
  "${CMAKE_CURRENT_SOURCE_DIR}/ffmpeg/bin/avfilter-7.dll"
  "${CMAKE_CURRENT_SOURCE_DIR}/ffmpeg/bin/avformat-58.dll"
  "${CMAKE_CURRENT_SOURCE_DIR}/ffmpeg/bin/avutil-56.dll"
  "${CMAKE_CURRENT_SOURCE_DIR}/ffmpeg/bin/swresample-3.dll"
  "${CMAKE_CURRENT_SOURCE_DIR}/ffmpeg/bin/swscale-5.dll"
  PARENT_SCOPE
)
