#include "flutter_window.h"

#include <flutter/standard_method_codec.h>

#include <optional>
#include <string>
#include <vector>

#include "flutter/generated_plugin_registrant.h"

namespace {

std::wstring Utf16FromUtf8(const std::string& value) {
  if (value.empty()) {
    return std::wstring();
  }
  const int length = ::MultiByteToWideChar(
      CP_UTF8, MB_ERR_INVALID_CHARS, value.data(),
      static_cast<int>(value.size()), nullptr, 0);
  if (length <= 0) {
    return std::wstring();
  }
  std::wstring result(length, L'\0');
  if (::MultiByteToWideChar(CP_UTF8, MB_ERR_INVALID_CHARS, value.data(),
                            static_cast<int>(value.size()), result.data(),
                            length) == 0) {
    return std::wstring();
  }
  return result;
}

std::wstring QuoteCommandLineArgument(const std::wstring& value) {
  std::wstring quoted = L"\"";
  size_t backslashes = 0;
  for (const wchar_t character : value) {
    if (character == L'\\') {
      backslashes++;
      continue;
    }
    if (character == L'\"') {
      quoted.append(backslashes * 2 + 1, L'\\');
      quoted.push_back(L'\"');
    } else {
      quoted.append(backslashes, L'\\');
      quoted.push_back(character);
    }
    backslashes = 0;
  }
  quoted.append(backslashes * 2, L'\\');
  quoted.push_back(L'\"');
  return quoted;
}

const std::string* ReadString(const flutter::EncodableMap& arguments,
                              const char* key) {
  const auto iterator = arguments.find(flutter::EncodableValue(key));
  if (iterator == arguments.end()) {
    return nullptr;
  }
  return std::get_if<std::string>(&iterator->second);
}

bool StartUpdaterWithoutConsole(const flutter::EncodableMap& arguments) {
  const std::string* script_path = ReadString(arguments, "scriptPath");
  const std::string* process_id = ReadString(arguments, "processId");
  const std::string* source = ReadString(arguments, "source");
  const std::string* destination = ReadString(arguments, "destination");
  const std::string* executable_name =
      ReadString(arguments, "executableName");
  if (script_path == nullptr || process_id == nullptr || source == nullptr ||
      destination == nullptr || executable_name == nullptr) {
    return false;
  }

  const std::vector<std::wstring> command_arguments = {
      L"powershell.exe",
      L"-NoProfile",
      L"-NonInteractive",
      L"-ExecutionPolicy",
      L"Bypass",
      L"-File",
      Utf16FromUtf8(*script_path),
      L"-ProcessId",
      Utf16FromUtf8(*process_id),
      L"-Source",
      Utf16FromUtf8(*source),
      L"-Destination",
      Utf16FromUtf8(*destination),
      L"-ExecutableName",
      Utf16FromUtf8(*executable_name),
  };
  for (const auto& argument : command_arguments) {
    if (argument.empty()) {
      return false;
    }
  }

  std::wstring command_line;
  for (const auto& argument : command_arguments) {
    if (!command_line.empty()) {
      command_line.push_back(L' ');
    }
    command_line.append(QuoteCommandLineArgument(argument));
  }
  std::vector<wchar_t> mutable_command(command_line.begin(), command_line.end());
  mutable_command.push_back(L'\0');

  STARTUPINFOW startup_info{};
  startup_info.cb = sizeof(startup_info);
  PROCESS_INFORMATION process_info{};
  const BOOL created = ::CreateProcessW(
      nullptr, mutable_command.data(), nullptr, nullptr, FALSE,
      CREATE_NO_WINDOW | CREATE_UNICODE_ENVIRONMENT, nullptr, nullptr,
      &startup_info, &process_info);
  if (!created) {
    return false;
  }
  ::CloseHandle(process_info.hThread);
  ::CloseHandle(process_info.hProcess);
  return true;
}

}  // namespace

FlutterWindow::FlutterWindow(const flutter::DartProject& project)
    : project_(project) {}

FlutterWindow::~FlutterWindow() {}

bool FlutterWindow::OnCreate() {
  if (!Win32Window::OnCreate()) {
    return false;
  }

  RECT frame = GetClientArea();

  // The size here must match the window dimensions to avoid unnecessary surface
  // creation / destruction in the startup path.
  flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
      frame.right - frame.left, frame.bottom - frame.top, project_);
  // Ensure that basic setup of the controller was successful.
  if (!flutter_controller_->engine() || !flutter_controller_->view()) {
    return false;
  }
  RegisterPlugins(flutter_controller_->engine());
  update_channel_ =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          flutter_controller_->engine()->messenger(),
          "ddl_out/windows_update",
          &flutter::StandardMethodCodec::GetInstance());
  update_channel_->SetMethodCallHandler(
      [](const flutter::MethodCall<flutter::EncodableValue>& call,
         std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>>
             result) {
        if (call.method_name() != "startUpdater") {
          result->NotImplemented();
          return;
        }
        const auto* arguments =
            std::get_if<flutter::EncodableMap>(call.arguments());
        if (arguments == nullptr) {
          result->Error("invalid_arguments", "Updater arguments are missing.");
          return;
        }
        if (!StartUpdaterWithoutConsole(*arguments)) {
          result->Error("launch_failed", "Unable to start the updater.");
          return;
        }
        result->Success(flutter::EncodableValue(true));
      });
  SetChildContent(flutter_controller_->view()->GetNativeWindow());

  flutter_controller_->engine()->SetNextFrameCallback([&]() {
    this->Show();
  });

  // Flutter can complete the first frame before the "show window" callback is
  // registered. The following call ensures a frame is pending to ensure the
  // window is shown. It is a no-op if the first frame hasn't completed yet.
  flutter_controller_->ForceRedraw();

  return true;
}

void FlutterWindow::OnDestroy() {
  if (flutter_controller_) {
    update_channel_.reset();
    flutter_controller_ = nullptr;
  }

  Win32Window::OnDestroy();
}

LRESULT
FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
                              WPARAM const wparam,
                              LPARAM const lparam) noexcept {
  // Give Flutter, including plugins, an opportunity to handle window messages.
  if (flutter_controller_) {
    std::optional<LRESULT> result =
        flutter_controller_->HandleTopLevelWindowProc(hwnd, message, wparam,
                                                      lparam);
    if (result) {
      return *result;
    }
  }

  switch (message) {
    case WM_FONTCHANGE:
      flutter_controller_->engine()->ReloadSystemFonts();
      break;
  }

  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}
