#ifndef RUNNER_SYSTEM_ALARM_CHANNEL_H_
#define RUNNER_SYSTEM_ALARM_CHANNEL_H_

#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>
#include <flutter/plugin_registrar_windows.h>
#include <memory>

std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>>
CreateSystemAlarmChannel(flutter::BinaryMessenger* messenger);

void RegisterSystemAlarmPlugin(FlutterDesktopPluginRegistrarRef registrar);

#endif
