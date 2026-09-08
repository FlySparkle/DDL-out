# ADR 008：从事项编辑器导出系统闹钟

## 状态

2026-09-09，v0.5.4 采纳。

## 决策

- 在截止时间输入区下方放置 Material 3 tonal「加入系统闹钟」按钮。独立对话框默认
  带入尚未保存的事项标题、详情纯文本及截止时间；不限时事项先提供三分钟后的时间。
  对话框中的修改不更改事项，也不隐式保存事项。
- 多重闹钟默认关闭，展开后可选择原闹钟之前或之后；默认间隔三分钟、额外三次。
  间隔范围 1–9999 分钟，额外次数范围 1–99。提交包含原闹钟，共最多一百个。
  提交前完整展示按时间排序的计划，不允许过去的时间。
- Android 通过官方 `AlarmClock.ACTION_SET_ALARM` 导出到系统时钟，声明
  `com.android.alarm.permission.SET_ALARM` 和包可见性查询。逐个启动时钟 Activity，
  等待返回后继续，避免批量 Intent 同时启动。标准接口没有任意年月日参数，因此
  Dart 与 Kotlin 均只接受今天或明天对应时刻的下一次响铃，绝不静默改变日期。
- Android 的 Intent 无标准创建成功回执。界面只报告已提交请求，并提醒用户在时钟
  中确认；部分失败显示提交数量并阻止直接重复提交。导出记录由系统时钟独立管理。
- Windows 没有公开的「时钟列表新增闹钟」接口，改用
  `Windows.UI.Notifications.ScheduledToastNotification`，场景为 alarm，使用系统
  循环提示音和关闭按钮。通过带 AppUserModelID 的开始菜单快捷方式登记便携应用。
  原生通道随 Flutter 插件注册，在主窗口和桌面浮窗中均可使用。
- Windows 先检查通知开关，再排期；批量失败时撤回本批次已添加的通知。独立提醒
  可在应用关闭时触发，但设备关机等情况下可能错过。两端导出后均不跟随事项修改、
  完成或删除自动更新，浮窗中明确说明。
- 不变更数据库及备份格式。闹钟只在用户点击确认后提交；构建过程不创建真实闹钟。

## 构建

复用 `.github/workflows/release.yml`。增加 `workflow_dispatch` 入口，在指定分支构建
Windows x64/ARM64 与 Android ARM64/x64，使用既有 Android 签名密钥。手动构建产物
按 pubspec 中的版本命名，不创建标签或 GitHub Release；其他平台不运行。
`skip_checks` 输入可跳过测试、静态分析和校验，默认开启；正常标签发布仍保留原校验。
本次按照用户要求不新增或运行测试、静态分析或校验，只生成资源并构建。

## 参考

- [Android AlarmClock](https://developer.android.com/reference/android/provider/AlarmClock)
- [Windows desktop notification identity](https://learn.microsoft.com/en-us/windows/win32/shell/enable-desktop-toast-with-appusermodelid)
- [Scheduled Windows notifications](https://learn.microsoft.com/en-us/windows/apps/develop/notifications/app-notifications/app-notifications-scheduled)
