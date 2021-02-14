#include "include/flutter_ffmpeg/flutter_ffmpeg_plugin.h"
#include "flutter_video_renderer.hpp"

namespace
{
  class FlutterFfmpegPlugin : public flutter::Plugin
  {
  public:
    static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

    FlutterFfmpegPlugin(
        flutter::PluginRegistrarWindows *registrar,
        std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>> channel);

    virtual ~FlutterFfmpegPlugin();

  private:
    // Called when a method is called on this plugin's channel from Dart.
    void HandleMethodCall(
        const flutter::MethodCall<flutter::EncodableValue> &method_call,
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

    std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>> channel_;
    flutter::BinaryMessenger *messenger_;
    flutter::TextureRegistrar *textures_;
  };

  std::shared_ptr<flutter::MethodChannel<flutter::EncodableValue>> channel;
  const flutter::EncodableValue &ValueOrNull(const flutter::EncodableMap &map, const char *key)
  {
    static flutter::EncodableValue null_value;
    auto it = map.find(flutter::EncodableValue(key));
    if (it == map.end())
    {
      return null_value;
    }
    return it->second;
  }

  // static
  void FlutterFfmpegPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarWindows *registrar)
  {
    auto channel =
        std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
            registrar->messenger(), "flutter_ffmpeg",
            &flutter::StandardMethodCodec::GetInstance());

    auto *channel_pointer = channel.get();

    // Uses new instead of make_unique due to private constructor.
    std::unique_ptr<FlutterFfmpegPlugin> plugin(
        new FlutterFfmpegPlugin(registrar, std::move(channel)));

    channel_pointer->SetMethodCallHandler(
        [plugin_pointer = plugin.get()](const auto &call, auto result) {
          plugin_pointer->HandleMethodCall(call, std::move(result));
        });

    registrar->AddPlugin(std::move(plugin));
  }

  FlutterFfmpegPlugin::FlutterFfmpegPlugin(
      flutter::PluginRegistrarWindows *registrar,
      std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>> channel) : channel_(std::move(channel)),
                                                                                  messenger_(registrar->messenger()),
                                                                                  textures_(registrar->texture_registrar())
  {
  }

  FlutterFfmpegPlugin::~FlutterFfmpegPlugin() {}

  void FlutterFfmpegPlugin::HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
  {
    if (method_call.method_name().compare("createTexture") == 0)
    {
      auto renderer = new FlutterVideoRenderer(textures_);
      result->Success(flutter::EncodableValue((int64_t)renderer));
    }
    else if (method_call.method_name().compare("getTextureId") == 0)
    {
      auto renderer = (FlutterVideoRenderer *)*std::get_if<int64_t>(method_call.arguments());
      result->Success(flutter::EncodableValue((int64_t)renderer->texture_id()));
    }
    else if (method_call.method_name().compare("closeTexture") == 0)
    {
      auto renderer = (FlutterVideoRenderer *)*std::get_if<int64_t>(method_call.arguments());
      delete renderer;
      result->Success();
    }
    else if (method_call.method_name().compare("attatchBuffer") == 0)
    {
      flutter::EncodableMap args = *std::get_if<flutter::EncodableMap>(method_call.arguments());
      auto renderer = (FlutterVideoRenderer *)std::get<int64_t>(ValueOrNull(args, "renderer"));
      auto buffer = (uint8_t *)std::get<int64_t>(ValueOrNull(args, "buffer"));
      auto width = std::get<int32_t>(ValueOrNull(args, "width"));
      auto height = std::get<int32_t>(ValueOrNull(args, "height"));
      renderer->setPixelBuffer(new FlutterDesktopPixelBuffer{buffer, (size_t)width, (size_t)height});
      result->Success();
    }
    else if (method_call.method_name().compare("onFrame") == 0)
    {
      auto renderer = (FlutterVideoRenderer *)*std::get_if<int64_t>(method_call.arguments());
      renderer->onFrame();
      result->Success();
    }
    else
    {
      result->NotImplemented();
    }
  }

} // namespace

void FlutterFfmpegPluginRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar)
{

  FlutterFfmpegPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
