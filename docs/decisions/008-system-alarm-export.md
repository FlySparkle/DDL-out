# ADR 008：事项闹钟与管理列表

## 状态

2026-09-09，v0.5.4 采纳；2026-10-04 按用户要求改为 Windows Task Scheduler。

## 决策

- 事项编辑器在截止时间区提供 Material 3「加入系统闹钟」按钮，独立浮窗默认带入标题、详情纯文本及截止时间。浮窗中的修改不隐式保存事项。
- 多重闹钟可选择之前或之后，默认间隔三分钟、额外三次；间隔 1–9999 分钟，额外次数 1–99。提交含原闹钟，最多一百个；展示全部计划并拒绝过去的时间。
- Windows 仅使用官方 Task Scheduler COM 接口。每个任务使用 GUID，保存在当前用户 SID 对应的 `\DDLout-<SID>` 目录，运行身份为当前已登录用户的交互式令牌，不保存密码、不要求管理员权限。完整 UTC 日期作为一次性触发时间；任务执行当前安装目录的 `ddl_out.exe --ddl-alarm {GUID}`，不使用 Toast 或系统时钟列表。
- 闹钟入口启动独立 Flutter 进程，复用应用主题及语言，只读取闹钟与显示提示，不启动看板、数据库、同步或更新器。窗口置顶、播放系统提示音，关闭后停音并停用该任务。宿主先清空控制器再析构，避免退出中的原生消息访问已销毁的视图；Flutter 与插件在 COM 反初始化前销毁。
- 退出主程序不会取消任务。电脑必须开机且用户已登录；锁屏需要解锁查看，关机无法弹窗。请求唤醒与错过后补运行，但实际唤醒取决于设备、电源策略和唤醒计时器。程序目录必须保留；移动、卸载或更新失败后的旧路径需要在管理列表重新添加。
- Windows 列表直接读取本应用任务，支持停用与确认删除。删除前验证 GUID 与 Author 标记，不操作其他计划任务。批量登记失败撤回本批任务；错误包含操作阶段、HRESULT 及系统消息，不再用泛化提示掩盖失败原因。
- 设置首页在「外观与个性化」之前提供同级闹钟管理快捷入口。管理页右下角提供带数量确认的一键清空：只处理确认时列表中的本应用记录，空列表和操作期间不可点击；失败后刷新剩余记录并展示错误。Android 按钮明确为「一键清空记录」，不声称能够删除系统时钟闹钟。
- Android 使用官方 `AlarmClock.ACTION_SET_ALARM`，通过 `EXTRA_SKIP_UI=true` 请求直接创建、不显示确认界面，逐个等待系统 Activity 返回后继续提交多重闹钟。标准接口没有任意年月日参数：下一次本地时刻使用一次性闹钟，其余日期通过 `EXTRA_DAYS` 取本地星期，每周循环。浮窗明确提示可能在事项日期前响铃。厂商时钟可能忽略跳过界面的请求，不能把 Intent 提交等同于创建成功。
- Android 闹钟浮窗复用事项编辑器的底部面板展示方式及宽度规则，同时避让键盘；Windows 浮窗保持原来的尺寸与呈现方式。
- Android Intent 没有标准创建成功回执或完整闹钟查询/删除接口。SharedPreferences 保存本应用的提交记录供管理列表展示；记录不代表时钟已成功创建。提供打开系统时钟、确认移除记录；明确移除记录不会删除系统闹钟。
- 不改变数据库、备份或同步协议；事项修改、完成和删除不自动同步已导出的闹钟。

## 验证与构建

Flutter 测试覆盖跨年偏移、任意未来日期、星期回退提示、管理操作确认及原生错误展示。`alarm_scheduler_test` 是显式构建的原生测试目标，调用与生产相同的校验及 COM 路径，验证登记、读取、停用、删除、失败回滚和所有权保护；测试任务必须清理。实际弹窗及正常关闭还须在已登录 Windows 会话中验证进程启动、可见窗口和退出码。

`test/native/alarm_popup_test.ps1 -Bundle <独立构建目录>` 验证没有运行中的测试版本时，任务计划程序到点启动可见的置顶闹钟，正常关闭后进程退出码为 0、任务停用并清理测试任务。按钮自身的停音、停用和退出顺序由 Flutter 回归测试覆盖。2026-10-04 本机复现过关闭时 `flutter_windows.dll!FlutterWindowsView::GetEngine` 的 `0xC000041D` 崩溃；修正宿主清理顺序后正常关闭的任务结果为 0。

继续复用 `.github/workflows/release.yml`：开发分支可手动构建，不创建标签或正式 Release；正式标签发布仍需遵守项目发布规则。Android 本地无发布密钥时使用调试签名，仅作为验证包，不能替代正式发布资产。

## 参考

- [Task Scheduler](https://learn.microsoft.com/zh-cn/windows/win32/taskschd/task-scheduler-start-page)
- [任务运行身份](https://learn.microsoft.com/en-us/windows/win32/taskschd/security-contexts-for-running-tasks)
- [WakeToRun](https://learn.microsoft.com/en-us/windows/win32/taskschd/tasksettings-waketorun)
- [Android AlarmClock](https://developer.android.com/reference/android/provider/AlarmClock)
