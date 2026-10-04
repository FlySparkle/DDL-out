#ifndef RUNNER_SYSTEM_ALARM_CHANNEL_H_
#define RUNNER_SYSTEM_ALARM_CHANNEL_H_

#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>
#include <memory>

void HandleSystemAlarmCall(const flutter::MethodCall<flutter::EncodableValue>& call,
                          flutter::MethodResult<flutter::EncodableValue>& result,
                          const std::wstring& executable_override = L"");

std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>>
CreateSystemAlarmChannel(flutter::BinaryMessenger* messenger);

#endif
