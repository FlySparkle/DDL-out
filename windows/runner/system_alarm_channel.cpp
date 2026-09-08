#include "system_alarm_channel.h"

#include <windows.h>
#include <propkey.h>
#include <propvarutil.h>
#include <shlobj.h>
#include <shobjidl.h>
#include <winrt/Windows.Data.Xml.Dom.h>
#include <winrt/Windows.Foundation.h>
#include <winrt/Windows.UI.Notifications.h>
#include <winrt/base.h>

#include <chrono>
#include <filesystem>
#include <string>
#include <vector>

namespace {
constexpr wchar_t kAppId[] = L"com.flysparkle.ddlout";

const flutter::EncodableValue* Argument(const flutter::EncodableMap& values,
                                      const char* name) {
  const auto found = values.find(flutter::EncodableValue(name));
  return found == values.end() ? nullptr : &found->second;
}

// Desktop notifications require an installed Start-menu shortcut with an AUMID.
// Re-register the current portable executable path when exporting reminders.
void RegisterDesktopIdentity() {
  std::vector<wchar_t> executable(32768);
  const DWORD length = GetModuleFileNameW(nullptr, executable.data(),
                                         static_cast<DWORD>(executable.size()));
  if (length == 0 || length >= executable.size()) {
    winrt::throw_hresult(HRESULT_FROM_WIN32(ERROR_INSUFFICIENT_BUFFER));
  }
  PWSTR programs = nullptr;
  winrt::check_hresult(SHGetKnownFolderPath(FOLDERID_Programs, 0, nullptr, &programs));
  const std::filesystem::path folder(programs);
  CoTaskMemFree(programs);
  std::filesystem::create_directories(folder);
  auto shortcut = winrt::create_instance<IShellLinkW>(CLSID_ShellLink);
  winrt::check_hresult(shortcut->SetPath(executable.data()));
  const auto directory = std::filesystem::path(executable.data()).parent_path();
  winrt::check_hresult(shortcut->SetWorkingDirectory(directory.c_str()));
  winrt::check_hresult(shortcut->SetIconLocation(executable.data(), 0));
  auto properties = shortcut.as<IPropertyStore>();
  PROPVARIANT app_id;
  PropVariantInit(&app_id);
  winrt::check_hresult(InitPropVariantFromString(kAppId, &app_id));
  const HRESULT property_result = properties->SetValue(PKEY_AppUserModel_ID, app_id);
  PropVariantClear(&app_id);
  winrt::check_hresult(property_result);
  winrt::check_hresult(properties->Commit());
  const auto path = folder / L"DDL out!.lnk";
  winrt::check_hresult(shortcut.as<IPersistFile>()->Save(path.c_str(), TRUE));
  winrt::check_hresult(SetCurrentProcessExplicitAppUserModelID(kAppId));
}

void Schedule(const flutter::EncodableMap& arguments,
              flutter::MethodResult<flutter::EncodableValue>& result) {
  using namespace winrt::Windows::UI::Notifications;
  using winrt::Windows::Data::Xml::Dom::XmlDocument;
  const auto title_value = Argument(arguments, "title");
  const auto notes_value = Argument(arguments, "notes");
  const auto times_value = Argument(arguments, "times");
  const auto title = title_value ? std::get_if<std::string>(title_value) : nullptr;
  const auto notes = notes_value ? std::get_if<std::string>(notes_value) : nullptr;
  const auto times = times_value ? std::get_if<flutter::EncodableList>(times_value) : nullptr;
  if (!title || title->empty() || title->size() > 800 || !notes ||
      notes->size() > 4000 || !times || times->empty() || times->size() > 100) {
    result.Error("invalid_arguments", "Invalid alarm information.");
    return;
  }
  const auto now_ms = std::chrono::duration_cast<std::chrono::milliseconds>(
      std::chrono::system_clock::now().time_since_epoch()).count();
  std::vector<int64_t> timestamps;
  for (const auto& value : *times) {
    const auto timestamp = std::get_if<int64_t>(&value);
    if (!timestamp || *timestamp <= now_ms || *timestamp > 253402300799000LL) {
      result.Error("past_time", "Alarm times must be valid future timestamps.");
      return;
    }
    timestamps.push_back(*timestamp);
  }

  ToastNotifier notifier{nullptr};
  std::vector<ScheduledToastNotification> scheduled;
  try {
    winrt::init_apartment(winrt::apartment_type::single_threaded);
    struct ApartmentScope {
      ~ApartmentScope() { winrt::uninit_apartment(); }
    } apartment_scope;
    RegisterDesktopIdentity();
    notifier = ToastNotificationManager::CreateToastNotifier(kAppId);
    if (notifier.Setting() != NotificationSetting::Enabled) {
      result.Error("notifications_disabled", "Enable notifications for DDL out! in Windows Settings.");
      return;
    }
    XmlDocument document;
    document.LoadXml(L"<toast scenario='alarm' duration='long'><visual>"
                     "<binding template='ToastGeneric'><text/><text/></binding>"
                     "</visual><audio src='ms-winsoundevent:Notification.Looping.Alarm2' loop='true'/>"
                     "<actions><action activationType='system' arguments='dismiss' content=''/></actions></toast>");
    const auto text_nodes = document.GetElementsByTagName(L"text");
    text_nodes.Item(0).AppendChild(document.CreateTextNode(winrt::to_hstring(*title)));
    text_nodes.Item(1).AppendChild(document.CreateTextNode(winrt::to_hstring(*notes)));
    for (const auto timestamp : timestamps) {
      // WinRT DateTime is measured in 100ns ticks from 1601, not Unix milliseconds.
      const auto ticks = (timestamp + 11644473600000LL) * 10000;
      const winrt::Windows::Foundation::DateTime delivery{
          winrt::Windows::Foundation::TimeSpan{ticks}};
      ScheduledToastNotification notification(document, delivery);
      notifier.AddToSchedule(notification);
      scheduled.push_back(notification);
    }
    result.Success(flutter::EncodableValue(static_cast<int32_t>(scheduled.size())));
  } catch (const winrt::hresult_error& error) {
    int32_t remaining = 0;
    for (const auto& notification : scheduled) {
      try { notifier.RemoveFromSchedule(notification); }
      catch (...) { ++remaining; }
    }
    result.Error("schedule_failed", winrt::to_string(error.message()),
                 flutter::EncodableValue(remaining));
  } catch (const std::exception&) {
    int32_t remaining = 0;
    for (const auto& notification : scheduled) {
      try { notifier.RemoveFromSchedule(notification); }
      catch (...) { ++remaining; }
    }
    result.Error("schedule_failed", "Could not register Windows reminders.",
                 flutter::EncodableValue(remaining));
  }
}
}  // namespace

std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>>
CreateSystemAlarmChannel(flutter::BinaryMessenger* messenger) {
  auto channel = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
      messenger, "ddl_out/system_alarms", &flutter::StandardMethodCodec::GetInstance());
  channel->SetMethodCallHandler([](const auto& call, auto result) {
    if (call.method_name() != "schedule") { result->NotImplemented(); return; }
    const auto* arguments = call.arguments()
        ? std::get_if<flutter::EncodableMap>(call.arguments()) : nullptr;
    if (!arguments) { result->Error("invalid_arguments", "Missing alarm information."); return; }
    Schedule(*arguments, *result);
  });
  return channel;
}

namespace {
class SystemAlarmPlugin : public flutter::Plugin {
 public:
  explicit SystemAlarmPlugin(flutter::PluginRegistrarWindows* registrar)
      : channel_(CreateSystemAlarmChannel(registrar->messenger())) {}
 private:
  std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>> channel_;
};
}  // namespace

void RegisterSystemAlarmPlugin(FlutterDesktopPluginRegistrarRef registrar_ref) {
  auto* registrar = flutter::PluginRegistrarManager::GetInstance()
      ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar_ref);
  registrar->AddPlugin(std::make_unique<SystemAlarmPlugin>(registrar));
}
