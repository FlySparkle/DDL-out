#include "system_alarm_channel.h"

#include <windows.h>
#include <taskschd.h>
#include <sddl.h>
#include <mmsystem.h>
#include <winrt/base.h>

#include <chrono>
#include <filesystem>
#include <iomanip>
#include <sstream>
#include <vector>

namespace {
using Value = flutter::EncodableValue;
using Map = flutter::EncodableMap;
using List = flutter::EncodableList;
constexpr wchar_t kOwner[] = L"DDL out! alarm v1";

struct Bstr {
  BSTR value = nullptr;
  Bstr() = default;
  explicit Bstr(const std::wstring& text) : value(SysAllocString(text.c_str())) {
    if (!value) winrt::throw_hresult(E_OUTOFMEMORY);
  }
  ~Bstr() { SysFreeString(value); }
  Bstr(const Bstr&) = delete;
  Bstr& operator=(const Bstr&) = delete;
  operator BSTR() const { return value; }
  BSTR* put() { return &value; }
  std::wstring str() const { return value ? value : L""; }
};

const Value* Field(const Map& values, const char* key) {
  const auto it = values.find(Value(key));
  return it == values.end() ? nullptr : &it->second;
}
std::string Text(const Map& values, const char* key) {
  const auto* value = Field(values, key);
  const auto* text = value ? std::get_if<std::string>(value) : nullptr;
  if (!text) winrt::throw_hresult(E_INVALIDARG);
  return *text;
}
std::wstring Wide(const std::string& value) {
  const auto text = winrt::to_hstring(value);
  return std::wstring(text.c_str(), text.size());
}
std::wstring Executable() {
  std::vector<wchar_t> path(32768);
  const auto size = GetModuleFileNameW(nullptr, path.data(), static_cast<DWORD>(path.size()));
  if (!size || size >= path.size()) winrt::throw_last_error();
  return std::wstring(path.data(), size);
}
int64_t Now() {
  return std::chrono::duration_cast<std::chrono::milliseconds>(
      std::chrono::system_clock::now().time_since_epoch()).count();
}
std::wstring Boundary(int64_t milliseconds) {
  ULARGE_INTEGER ticks{};
  ticks.QuadPart = static_cast<ULONGLONG>(milliseconds + 11644473600000LL) * 10000;
  FILETIME file{ticks.LowPart, ticks.HighPart};
  SYSTEMTIME time{};
  if (!FileTimeToSystemTime(&file, &time)) winrt::throw_last_error();
  wchar_t result[32];
  swprintf_s(result, L"%04u-%02u-%02uT%02u:%02u:%02uZ", time.wYear,
             time.wMonth, time.wDay, time.wHour, time.wMinute, time.wSecond);
  return result;
}
bool ValidId(const std::wstring& id) {
  GUID guid{};
  return id.size() == 38 && id.front() == L'{' && id.back() == L'}' &&
      SUCCEEDED(CLSIDFromString(id.c_str(), &guid));
}

class Scheduler {
 public:
  explicit Scheduler(const std::wstring& executable_override) : executable_override_(executable_override) {
    winrt::check_hresult(CoCreateInstance(CLSID_TaskScheduler, nullptr,
        CLSCTX_INPROC_SERVER, IID_PPV_ARGS(service_.put())));
    VARIANT empty{};
    winrt::check_hresult(service_->Connect(empty, empty, empty, empty));
    HANDLE raw_token = nullptr;
    if (!OpenProcessToken(GetCurrentProcess(), TOKEN_QUERY, &raw_token)) winrt::throw_last_error();
    winrt::handle token(raw_token);
    DWORD size = 0;
    GetTokenInformation(token.get(), TokenUser, nullptr, 0, &size);
    std::vector<BYTE> buffer(size);
    if (!GetTokenInformation(token.get(), TokenUser, buffer.data(), size, &size)) winrt::throw_last_error();
    LPWSTR sid = nullptr;
    if (!ConvertSidToStringSidW(reinterpret_cast<TOKEN_USER*>(buffer.data())->User.Sid, &sid)) winrt::throw_last_error();
    const std::wstring folder_name = std::wstring(L"\\DDLout-") + sid;
    LocalFree(sid);
    const auto hr = service_->GetFolder(Bstr(folder_name), folder_.put());
    if (hr == HRESULT_FROM_WIN32(ERROR_FILE_NOT_FOUND) || hr == HRESULT_FROM_WIN32(ERROR_PATH_NOT_FOUND)) {
      winrt::com_ptr<ITaskFolder> root;
      winrt::check_hresult(service_->GetFolder(Bstr(L"\\"), root.put()));
      const auto created = root->CreateFolder(Bstr(folder_name), empty, folder_.put());
      if (created == HRESULT_FROM_WIN32(ERROR_ALREADY_EXISTS)) {
        winrt::check_hresult(service_->GetFolder(Bstr(folder_name), folder_.put()));
      } else { winrt::check_hresult(created); }
    } else { winrt::check_hresult(hr); }
  }

  winrt::com_ptr<IRegisteredTask> Get(const std::wstring& id) {
    if (!ValidId(id)) winrt::throw_hresult(E_INVALIDARG);
    winrt::com_ptr<IRegisteredTask> task;
    winrt::check_hresult(folder_->GetTask(Bstr(id), task.put()));
    winrt::com_ptr<ITaskDefinition> definition;
    winrt::com_ptr<IRegistrationInfo> info;
    winrt::check_hresult(task->get_Definition(definition.put()));
    winrt::check_hresult(definition->get_RegistrationInfo(info.put()));
    Bstr author;
    winrt::check_hresult(info->get_Author(author.put()));
    if (author.str() != kOwner) winrt::throw_hresult(E_ACCESSDENIED);
    return task;
  }

  std::wstring Add(const std::string& title, const std::string& notes, int64_t time) {
    winrt::com_ptr<ITaskDefinition> definition;
    winrt::check_hresult(service_->NewTask(0, definition.put()));
    winrt::com_ptr<IRegistrationInfo> info;
    winrt::check_hresult(definition->get_RegistrationInfo(info.put()));
    winrt::check_hresult(info->put_Author(Bstr(kOwner)));
    winrt::check_hresult(info->put_Documentation(Bstr(Wide(title))));
    winrt::check_hresult(info->put_Description(Bstr(Wide(notes))));
    winrt::check_hresult(definition->put_Data(Bstr(std::to_wstring(time))));
    winrt::com_ptr<IPrincipal> principal;
    winrt::check_hresult(definition->get_Principal(principal.put()));
    winrt::check_hresult(principal->put_LogonType(TASK_LOGON_INTERACTIVE_TOKEN));
    winrt::check_hresult(principal->put_RunLevel(TASK_RUNLEVEL_LUA));
    winrt::com_ptr<ITaskSettings> settings;
    winrt::check_hresult(definition->get_Settings(settings.put()));
    winrt::check_hresult(settings->put_StartWhenAvailable(VARIANT_TRUE));
    winrt::check_hresult(settings->put_DisallowStartIfOnBatteries(VARIANT_FALSE));
    winrt::check_hresult(settings->put_StopIfGoingOnBatteries(VARIANT_FALSE));
    winrt::check_hresult(settings->put_WakeToRun(VARIANT_TRUE));
    winrt::check_hresult(settings->put_ExecutionTimeLimit(Bstr(L"PT0S")));
    winrt::check_hresult(settings->put_MultipleInstances(TASK_INSTANCES_IGNORE_NEW));
    winrt::com_ptr<ITriggerCollection> triggers;
    winrt::com_ptr<ITrigger> trigger;
    winrt::check_hresult(definition->get_Triggers(triggers.put()));
    winrt::check_hresult(triggers->Create(TASK_TRIGGER_TIME, trigger.put()));
    winrt::check_hresult(trigger->put_StartBoundary(Bstr(Boundary(time))));
    GUID guid{};
    winrt::check_hresult(CoCreateGuid(&guid));
    wchar_t id[40];
    StringFromGUID2(guid, id, 40);
    winrt::com_ptr<IActionCollection> actions;
    winrt::com_ptr<IAction> action;
    winrt::check_hresult(definition->get_Actions(actions.put()));
    winrt::check_hresult(actions->Create(TASK_ACTION_EXEC, action.put()));
    auto exec = action.as<IExecAction>();
    const auto path = executable_override_.empty() ? Executable() : executable_override_;
    winrt::check_hresult(exec->put_Path(Bstr(path)));
    winrt::check_hresult(exec->put_WorkingDirectory(Bstr(std::filesystem::path(path).parent_path().wstring())));
    winrt::check_hresult(exec->put_Arguments(Bstr(std::wstring(L"--ddl-alarm ") + id)));
    VARIANT empty{};
    winrt::com_ptr<IRegisteredTask> registered;
    winrt::check_hresult(folder_->RegisterTaskDefinition(Bstr(id), definition.get(),
        TASK_CREATE, empty, empty, TASK_LOGON_INTERACTIVE_TOKEN, empty, registered.put()));
    return id;
  }

  Map Read(const std::wstring& id) {
    auto task = Get(id);
    winrt::com_ptr<ITaskDefinition> definition;
    winrt::com_ptr<IRegistrationInfo> info;
    winrt::check_hresult(task->get_Definition(definition.put()));
    winrt::check_hresult(definition->get_RegistrationInfo(info.put()));
    Bstr title, notes, data;
    winrt::check_hresult(info->get_Documentation(title.put()));
    winrt::check_hresult(info->get_Description(notes.put()));
    winrt::check_hresult(definition->get_Data(data.put()));
    VARIANT_BOOL enabled{};
    LONG last_result = 0;
    winrt::check_hresult(task->get_Enabled(&enabled));
    winrt::check_hresult(task->get_LastTaskResult(&last_result));
    return {{Value("id"), Value(winrt::to_string(id))},
      {Value("title"), Value(winrt::to_string(title.str()))},
      {Value("notes"), Value(winrt::to_string(notes.str()))},
      {Value("time"), Value(static_cast<int64_t>(std::stoll(data.str())))},
      {Value("enabled"), Value(enabled != VARIANT_FALSE)},
      {Value("lastResult"), Value(static_cast<int32_t>(last_result))},
      {Value("weekly"), Value(false)}};
  }

  List All() {
    winrt::com_ptr<IRegisteredTaskCollection> tasks;
    winrt::check_hresult(folder_->GetTasks(TASK_ENUM_HIDDEN, tasks.put()));
    LONG count = 0;
    winrt::check_hresult(tasks->get_Count(&count));
    List entries;
    for (LONG index = 1; index <= count; ++index) {
      VARIANT key{}; key.vt = VT_I4; key.lVal = index;
      winrt::com_ptr<IRegisteredTask> task;
      winrt::check_hresult(tasks->get_Item(key, task.put()));
      Bstr id;
      winrt::check_hresult(task->get_Name(id.put()));
      if (!ValidId(id.str())) continue;
      try { entries.emplace_back(Read(id.str())); }
      catch (const winrt::hresult_error& error) {
        // Another process may remove a task while this snapshot is read.
        if (error.code() != HRESULT_FROM_WIN32(ERROR_FILE_NOT_FOUND)) throw;
      }
    }
    return entries;
  }
  void Remove(const std::wstring& id) {
    Get(id);  // Check ownership before deleting.
    winrt::check_hresult(folder_->DeleteTask(Bstr(id), 0));
  }
 private:
  std::wstring executable_override_;
  winrt::com_ptr<ITaskService> service_;
  winrt::com_ptr<ITaskFolder> folder_;
};
}  // namespace

// Kept separate from the messenger so native integration tests use the exact
// production validation, scheduler calls and error translation.
void HandleSystemAlarmCall(const flutter::MethodCall<flutter::EncodableValue>& call,
                          flutter::MethodResult<flutter::EncodableValue>& result,
                          const std::wstring& executable_override) {
  std::string stage = "connect_scheduler";
  try {
    const auto& method = call.method_name();
    if (method == "sound") {
      PlaySoundW(L"SystemExclamation", nullptr, SND_ALIAS | SND_ASYNC | SND_LOOP | SND_NODEFAULT);
      result.Success(); return;
    }
    if (method == "silence") { PlaySoundW(nullptr, nullptr, 0); result.Success(); return; }
    Scheduler scheduler(executable_override);
    if (method == "list") { result.Success(Value(scheduler.All())); return; }
    const auto* arguments = call.arguments() ? std::get_if<Map>(call.arguments()) : nullptr;
    if (!arguments) winrt::throw_hresult(E_INVALIDARG);
    if (method == "schedule") {
      stage = "validate_alarm";
      const auto title = Text(*arguments, "title");
      const auto notes = Text(*arguments, "notes");
      const auto* times_value = Field(*arguments, "times");
      const auto* times = times_value ? std::get_if<List>(times_value) : nullptr;
      if (title.empty() || title.size() > 800 || notes.size() > 4000 ||
          !times || times->empty() || times->size() > 100) winrt::throw_hresult(E_INVALIDARG);
      std::vector<int64_t> timestamps;
      for (const auto& value : *times) {
        const auto* time = std::get_if<int64_t>(&value);
        if (!time || *time <= Now() || *time > 253402300799000LL) {
          result.Error("past_time", "Alarm times must be valid future timestamps."); return;
        }
        timestamps.push_back(*time);
      }
      std::vector<std::wstring> ids;
      try {
        stage = "register_task";
        for (const auto time : timestamps) ids.push_back(scheduler.Add(title, notes, time));
      } catch (...) {
        int32_t remaining = 0;
        for (const auto& id : ids) { try { scheduler.Remove(id); } catch (...) { ++remaining; } }
        if (remaining) { result.Error("partial_schedule", "Some scheduled alarms could not be rolled back.", Value(remaining)); return; }
        throw;
      }
      result.Success(Value(static_cast<int32_t>(ids.size()))); return;
    }
    stage = method;
    const auto id = Wide(Text(*arguments, "id"));
    if (method == "get") { result.Success(Value(scheduler.Read(id))); return; }
    if (method == "delete") { scheduler.Remove(id); result.Success(); return; }
    if (method == "disable") {
      winrt::check_hresult(scheduler.Get(id)->put_Enabled(VARIANT_FALSE));
      result.Success(); return;
    }
    result.NotImplemented();
  } catch (const winrt::hresult_error& error) {
    std::ostringstream code;
    code << "0x" << std::hex << std::uppercase << std::setw(8) << std::setfill('0')
         << static_cast<uint32_t>(error.code().value);
    const auto hr = error.code();
    result.Error(hr == E_ACCESSDENIED ? "scheduler_access_denied" : "scheduler_failed",
        winrt::to_string(error.message()), Value(Map{
            {Value("stage"), Value(stage)}, {Value("hresult"), Value(code.str())}}));
  } catch (const std::exception& error) {
    result.Error("scheduler_failed", error.what(), Value(Map{{Value("stage"), Value(stage)}}));
  }
}

std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>>
CreateSystemAlarmChannel(flutter::BinaryMessenger* messenger) {
  auto channel = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
      messenger, "ddl_out/system_alarms", &flutter::StandardMethodCodec::GetInstance());
  channel->SetMethodCallHandler([](const auto& call, auto result) { HandleSystemAlarmCall(call, *result); });
  return channel;
}
