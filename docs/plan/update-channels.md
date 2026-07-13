# 预发布更新开关

## 现状

- `update_checker.dart` 固定请求 `/releases/latest`，只检查正式 release。
- 用户无法选择是否接收 pre-release 更新提示。

## 目标

在设置页面提供一个开关，用户可以选择是否接收预发布（pre-release）更新：

- **关闭（默认）**：仅提示升级到最新的正式 release。
- **开启**：提示升级到最新的 release（含 pre-release），取版本号最大者。

这是一个**运行时用户偏好**，与当前主题、字体等设置同级，持久化在 SharedPreferences 中。

## 设计

### 设置状态

`AppSettingsState` 新增字段：

```dart
final bool preReleaseUpdatesEnabled; // 默认 false
```

`SettingsController` 新增持久化 key 和 setter。

### GitHub API 策略

| 开关 | API                        | 说明                                   |
| ---- | -------------------------- | -------------------------------------- |
| 关闭 | `GET /releases/latest`     | 只返回最新正式 release                 |
| 开启 | `GET /releases?per_page=1` | 返回最新一个 release（含 pre-release） |

注意：`/releases?per_page=1` 按创建时间倒序，会包含 pre-release。如果最新是 pre-release 且开关打开，用户会收到更新提示。

### 更新检查器

`AppUpdateChecker.checkForUpdate()` 新增 `includePreRelease` 参数：

```dart
Future<AppUpdate?> checkForUpdate({bool includePreRelease = false})
```

`GitHubLatestReleaseReader.readLatestVersion()` 同样新增该参数，据此选择 API 端点。

### 版本比较

`ReleaseVersion.parse` 已正确处理 pre-release 优先级（`1.0.0-rc.1 < 1.0.0`），无需改动。

### UI

在设置 → 关于页面中，"检查更新"按钮下方增加一个 `SwitchListTile`：

- 标题：「接收预发布更新」
- 副标题：「开启后将在 pre-release 版本可用时收到更新提示」

或者放在外观设置区域。具体位置待定。

## 涉及文件

| 文件                                                             | 改动                                                                           |
| ---------------------------------------------------------------- | ------------------------------------------------------------------------------ |
| `lib/features/settings/application/settings_state.dart`          | 新增 `preReleaseUpdatesEnabled` 字段                                           |
| `lib/features/settings/application/settings_controller.dart`     | 新增持久化 key、setter                                                         |
| `lib/core/update/update_checker.dart`                            | `checkForUpdate` / `readLatestVersion` 新增 `includePreRelease` 参数，切换 API |
| `lib/features/settings/presentation/about_settings_section.dart` | 新增开关 UI                                                                    |
| `lib/app/app_shell.dart`                                         | `_scheduleUpdateCheck` 传入用户偏好                                            |

## 不做

- 不引入编译期通道概念。
- 不自动下载或强制更新。
- dev/nightly 通道不做。
