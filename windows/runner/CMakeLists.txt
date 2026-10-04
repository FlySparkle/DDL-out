cmake_minimum_required(VERSION 3.14)
project(runner LANGUAGES CXX)

# Define the application target. To change its name, change BINARY_NAME in the
# top-level CMakeLists.txt, not the value here, or `flutter run` will no longer
# work.
#
# Any new source files that you add to the application should be added here.
add_executable(${BINARY_NAME} WIN32
  "flutter_window.cpp"
  "system_alarm_channel.cpp"
  "main.cpp"
  "utils.cpp"
  "win32_window.cpp"
  "${FLUTTER_MANAGED_DIR}/generated_plugin_registrant.cc"
  "Runner.rc"
  "runner.exe.manifest"
)

# Apply the standard set of build settings. This can be removed for applications
# that need different build settings.
apply_standard_settings(${BINARY_NAME})

# C++/WinRT selects the supported standard coroutine header in C++20 mode.
# Current MSVC releases reject its retired experimental C++17 header.
target_compile_features(${BINARY_NAME} PRIVATE cxx_std_20)

# Add preprocessor definitions for the build version.
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION=\"${FLUTTER_VERSION}\"")
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION_MAJOR=${FLUTTER_VERSION_MAJOR}")
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION_MINOR=${FLUTTER_VERSION_MINOR}")
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION_PATCH=${FLUTTER_VERSION_PATCH}")
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION_BUILD=${FLUTTER_VERSION_BUILD}")

# Disable Windows macros that collide with C++ standard library functions.
target_compile_definitions(${BINARY_NAME} PRIVATE "NOMINMAX")

# Add dependency libraries and include directories. Add any application-specific
# dependencies here.
target_link_libraries(${BINARY_NAME} PRIVATE flutter flutter_wrapper_app)
target_link_libraries(${BINARY_NAME} PRIVATE "dwmapi.lib")
target_link_libraries(${BINARY_NAME} PRIVATE "taskschd.lib" "oleaut32.lib" "advapi32.lib" "winmm.lib" "shell32.lib" "ole32.lib" "windowsapp.lib")
target_include_directories(${BINARY_NAME} PRIVATE "${CMAKE_SOURCE_DIR}")

# Run the Flutter tool portions of the build. This must not be removed.
add_dependencies(${BINARY_NAME} flutter_assemble)

# Explicit opt-in: exercises the real per-user Task Scheduler without running
# the main application. Not part of the normal build or distribution.
add_executable(alarm_scheduler_test EXCLUDE_FROM_ALL
  "../../test/native/alarm_scheduler_test.cpp" "system_alarm_channel.cpp")
apply_standard_settings(alarm_scheduler_test)
target_compile_features(alarm_scheduler_test PRIVATE cxx_std_20)
target_compile_definitions(alarm_scheduler_test PRIVATE NOMINMAX)
target_include_directories(alarm_scheduler_test PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}")
target_link_libraries(alarm_scheduler_test PRIVATE flutter flutter_wrapper_app
  "taskschd.lib" "oleaut32.lib" "advapi32.lib" "winmm.lib" "shell32.lib" "ole32.lib" "windowsapp.lib")
