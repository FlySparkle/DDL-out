#include "system_alarm_channel.h"
#include <windows.h>
#include <winrt/base.h>
#include <chrono>
#include <iostream>
#include <stdexcept>
#include <string>

using V = flutter::EncodableValue;
using M = flutter::EncodableMap;
using L = flutter::EncodableList;
struct Result : flutter::MethodResult<V> {
  Result() = default;
  Result(Result&& other) : value(std::move(other.value)), error(std::move(other.error)) {}
  V value;
  std::string error;
  void SuccessInternal(const V* result) override { if (result) value = *result; }
  void ErrorInternal(const std::string& code, const std::string& message, const V* details) override {
    error = code + ": " + message;
    if (details) {
      if (const auto* map = std::get_if<M>(details)) {
        for (const auto& [key, val] : *map) {
          if (const auto* text = std::get_if<std::string>(&val))
            error += " " + std::get<std::string>(key) + "=" + *text;
        }
      }
    }
  }
  void NotImplementedInternal() override { error = "not implemented"; }
};
Result Call(const std::string& method, M arguments = {}, const std::wstring& executable = L"") {
  flutter::MethodCall<V> call(method, std::make_unique<V>(arguments));
  Result result;
  HandleSystemAlarmCall(call, result, executable);
  return result;
}
V Ok(Result result) {
  if (!result.error.empty()) throw std::runtime_error(result.error);
  return result.value;
}
int64_t Now() {
  return std::chrono::duration_cast<std::chrono::milliseconds>(
    std::chrono::system_clock::now().time_since_epoch()).count();
}
std::string Create(const std::wstring& executable, int64_t time) {
  const auto title = "DDL out! scheduler integration " + std::to_string(Now());
  Ok(Call("schedule", {{V("title"), V(title)}, {V("notes"), V("Independent alarm window after main process exits.")},
    {V("times"), V(L{V(time)})}}, executable));
  const auto records = Ok(Call("list"));
  for (const auto& value : std::get<L>(records)) {
    const auto& entry = std::get<M>(value);
    if (std::get<std::string>(entry.at(V("title"))) == title)
      return std::get<std::string>(entry.at(V("id")));
  }
  throw std::runtime_error("Registered task missing from list");
}
int wmain(int argc, wchar_t* argv[]) {
  const auto initialized = CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);
  if (FAILED(initialized)) return 2;
  std::string cleanup;
  try {
    if (argc == 3 && std::wstring(argv[1]) == L"delete") {
      Ok(Call("delete", {{V("id"), V(winrt::to_string(argv[2]))}}));
      std::cout << "Deleted test task\n";
    } else if (argc == 3 && std::wstring(argv[1]) == L"create") {
      std::cout << Create(argv[2], Now() + 45000) << std::endl;
    } else if (argc == 2) {
      const auto before = std::get<L>(Ok(Call("list"))).size();
      const auto invalid = Call("schedule", {{V("title"), V("invalid batch")}, {V("notes"), V("")},
        {V("times"), V(L{V(Now() + 86400000), V(Now() - 1000)})}}, argv[1]);
      if (invalid.error.find("past_time") == std::string::npos ||
          std::get<L>(Ok(Call("list"))).size() != before) throw std::runtime_error("Invalid batch was not atomic");
      cleanup = Create(argv[1], Now() + 30LL * 86400000);
      const M key{{V("id"), V(cleanup)}};
      Ok(Call("disable", key));
      const auto entry = std::get<M>(Ok(Call("get", key)));
      if (std::get<bool>(entry.at(V("enabled")))) throw std::runtime_error("Disable failed");
      Ok(Call("delete", key));
      cleanup.clear();
      if (std::get<L>(Ok(Call("list"))).size() != before) throw std::runtime_error("Task cleanup failed");
      if (Call("delete", {{V("id"), V("../unrelated")}}).error.empty())
        throw std::runtime_error("Invalid ID accepted");
      std::cout << "PASS: future date, persisted metadata, list/get, disable/delete, atomic validation, ownership guard\n";
    } else { throw std::runtime_error("usage: alarm_scheduler_test <ddl_out.exe> | create <ddl_out.exe> | delete <id>"); }
  } catch (const std::exception& error) {
    if (!cleanup.empty()) Call("delete", {{V("id"), V(cleanup)}});
    std::cerr << error.what() << std::endl;
    CoUninitialize(); return 1;
  }
  CoUninitialize(); return 0;
}
