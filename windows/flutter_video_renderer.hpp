#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <mutex>

class FlutterVideoRenderer
{
  std::shared_ptr<FlutterDesktopPixelBuffer> pixel_buffer;

public:
  FlutterVideoRenderer(flutter::TextureRegistrar *registrar)
      : registrar_(registrar)
  {
    texture_ =
        std::make_unique<flutter::TextureVariant>(flutter::PixelBufferTexture(
            [this](size_t width,
                   size_t height) -> const FlutterDesktopPixelBuffer * {
              return this->CopyPixelBuffer(width, height);
            }));
    texture_id_ = registrar_->RegisterTexture(texture_.get());
  }

  void onFrame()
  {
    registrar_->MarkTextureFrameAvailable(texture_id_);
  }

  ~FlutterVideoRenderer()
  {
    registrar_->UnregisterTexture(texture_id_);
  }

  void setPixelBuffer(FlutterDesktopPixelBuffer *buffer)
  {
    pixel_buffer.reset(buffer);
  }

  FlutterDesktopPixelBuffer *CopyPixelBuffer(
      size_t width,
      size_t height)
  {
    return pixel_buffer.get();
  };

  int64_t texture_id() { return texture_id_; }

private:
  flutter::TextureRegistrar *registrar_ = nullptr;
  int64_t texture_id_ = -1;
  std::unique_ptr<flutter::TextureVariant> texture_;
  mutable std::mutex mutex_;
};