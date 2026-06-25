#include "include/otp_forge/otp_forge_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "otp_forge_plugin.h"

void OtpForgePluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  otp_forge::OtpForgePlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
