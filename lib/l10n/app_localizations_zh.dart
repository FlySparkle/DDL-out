// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'DDL out!';

  @override
  String get boardTitle => '截止事项';

  @override
  String get settingsTitle => '设置';

  @override
  String get appearanceSettingsTitle => '外观与个性化';

  @override
  String get systemDataSettingsTitle => '系统与数据';

  @override
  String get aboutSettingsTitle => '关于';

  @override
  String get communitySettingsTitle => '社区与支持';

  @override
  String get newCategory => '新建分类';

  @override
  String get editCategory => '编辑分类';

  @override
  String get categoryName => '分类名称';

  @override
  String get categoryColor => '分类颜色';

  @override
  String get uncategorized => '未分类';

  @override
  String get addTask => '添加事项';

  @override
  String get newTask => '新建事项';

  @override
  String get editTask => '编辑事项';

  @override
  String get taskName => '事项名称';

  @override
  String get taskCategory => '所属分类';

  @override
  String get deadline => '截止时间';

  @override
  String get relativeTime => '剩余时间';

  @override
  String get absoluteTime => '绝对时间';

  @override
  String get days => '日';

  @override
  String get hours => '时';

  @override
  String get minutes => '分';

  @override
  String get date => '日期';

  @override
  String get time => '时间';

  @override
  String get save => '保存';

  @override
  String get cancel => '取消';

  @override
  String get delete => '删除';

  @override
  String get confirm => '确认';

  @override
  String get customColor => '自定义颜色';

  @override
  String get expandCategory => '展开分类';

  @override
  String get collapseCategory => '折叠分类';

  @override
  String get markComplete => '标记为已完成';

  @override
  String get markIncomplete => '标记为未完成';

  @override
  String get completed => '已完成';

  @override
  String get overdue => '已过期';

  @override
  String get emptyTitle => '还没有截止事项';

  @override
  String get emptyBody => '先记下要完成的事，之后也可以再整理分类。';

  @override
  String get noTasks => '这个分类还没有事项';

  @override
  String get clearCompleted => '移除已完成事项';

  @override
  String get clearCategoryTasks => '移除本分类已完成事项';

  @override
  String get categoryActions => '分类操作';

  @override
  String get reorderCategory => '拖动调整分类顺序';

  @override
  String get moveTask => '拖动移动事项';

  @override
  String get taskActions => '事项操作';

  @override
  String get clearAllData => '清空全部数据';

  @override
  String get appLanguage => '语言';

  @override
  String get languageSystem => '跟随系统';

  @override
  String get languageSimplifiedChinese => '简体中文';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageJapanese => '日本語';

  @override
  String get themeMode => '外观模式';

  @override
  String get themeSystem => '跟随系统';

  @override
  String get themeLight => '浅色';

  @override
  String get themeDark => '深色';

  @override
  String get dynamicColor => '莫奈动态配色';

  @override
  String get dynamicColorSubtitle => 'Android 12 及以上默认使用系统配色';

  @override
  String get useSystemFont => '使用系统默认字体';

  @override
  String get useSystemFontSubtitle => '关闭后使用内嵌的思源黑体';

  @override
  String get fontSize => '字号';

  @override
  String fontSizeValue(int percent) {
    return '$percent%';
  }

  @override
  String get navigationMode => '边栏模式';

  @override
  String get floatingSidebar => '浮动边栏';

  @override
  String get floatingSidebarSubtitle => '使用左上角按钮或从页面左侧向右滑动打开边栏。';

  @override
  String get fixedSidebar => '固定边栏';

  @override
  String get fixedSidebarSubtitle => '宽度不足时自动切换为浮动边栏；固定时可手动收展或悬停展开。';

  @override
  String get sidebarAlignment => '边栏排放方式';

  @override
  String get sidebarAlignBetween => '两端';

  @override
  String get sidebarAlignStart => '靠上';

  @override
  String get sidebarAlignEnd => '靠下';

  @override
  String get expandSidebar => '展开边栏';

  @override
  String get collapseSidebar => '收起边栏';

  @override
  String get backup => '导出备份';

  @override
  String get restore => '恢复备份';

  @override
  String get exportDialogTitle => '导出 DDL out! 备份';

  @override
  String get restoreFileDialogTitle => '选择 DDL out! 备份';

  @override
  String get dataSection => '数据';

  @override
  String get appearanceSection => '外观';

  @override
  String get backupSuccess => '备份已导出';

  @override
  String get restoreSuccess => '备份恢复完成';

  @override
  String get operationCancelled => '操作已取消';

  @override
  String get operationFailed => '操作失败，请重试';

  @override
  String get invalidBackup => '备份文件无效';

  @override
  String get nameRequired => '请输入名称';

  @override
  String get nameTooLong => '名称过长';

  @override
  String get categoryRequired => '请选择分类';

  @override
  String get deleteTaskTitle => '删除事项？';

  @override
  String get deleteTaskBody => '此操作无法撤销。';

  @override
  String get deleteCategoryTitle => '删除分类？';

  @override
  String get deleteCategory => '删除分类';

  @override
  String deleteCategoryBody(int count) {
    return '分类内的 $count 个事项将移动到“未分类”。';
  }

  @override
  String get clearCompletedTitle => '移除所有已完成事项？';

  @override
  String clearCompletedBody(int count) {
    return '将永久删除 $count 个已完成事项。';
  }

  @override
  String get clearCategoryTasksTitle => '移除本分类已完成事项？';

  @override
  String clearCategoryTasksBody(int count) {
    return '将永久删除本分类内的 $count 个已完成事项。';
  }

  @override
  String get clearAllTitle => '清空全部数据？';

  @override
  String get clearAllBody => '所有分类和事项都将被永久删除。';

  @override
  String get restoreTitle => '恢复这个备份？';

  @override
  String restoreBody(
    int categories,
    int tasks,
    int existingCategories,
    int existingTasks,
  ) {
    return '备份包含 $categories 个分类和 $tasks 个事项。当前的 $existingCategories 个分类和 $existingTasks 个事项将被替换。';
  }

  @override
  String dataCount(int categories, int tasks) {
    return '$categories 个分类，$tasks 个事项';
  }

  @override
  String remainingShort(int hours, int minutes) {
    return '$hours小时$minutes分';
  }

  @override
  String remainingLong(int days, int hours) {
    return '$days天$hours小时';
  }

  @override
  String overdueByShort(int hours, int minutes) {
    return '逾期$hours小时$minutes分';
  }

  @override
  String overdueByLong(int days, int hours) {
    return '逾期$days天$hours小时';
  }

  @override
  String get inOneHour => '1 小时后';

  @override
  String get today => '今天';

  @override
  String get tomorrow => '明天';

  @override
  String get thisWeekend => '本周末';

  @override
  String get undo => '撤销';

  @override
  String get taskMarkedComplete => '已标记为完成';

  @override
  String get taskMarkedIncomplete => '已恢复为未完成';

  @override
  String taskMovedTo(String category) {
    return '已移至“$category”';
  }

  @override
  String get clearCompletedConfirm => '永久清除';

  @override
  String get clearCategoryTasksConfirm => '移除已完成事项';

  @override
  String get deleteCategoryConfirm => '删除分类';

  @override
  String get deleteTaskConfirm => '删除事项';

  @override
  String get clearAllConfirm => '清空全部数据';

  @override
  String get restoreConfirm => '恢复并替换';

  @override
  String taskCount(int count) {
    return '$count 项';
  }

  @override
  String get errorTitle => '加载失败';

  @override
  String get retry => '重试';

  @override
  String get checkForUpdates => '检查更新';

  @override
  String get checkForUpdatesSubtitle => '检查 GitHub 上是否有新版本';

  @override
  String get updateAvailableTitle => '发现新版本';

  @override
  String updateAvailableBody(String version) {
    return 'DDL out! $version 已发布，可以直接在应用内下载并安装。';
  }

  @override
  String get downloadUpdate => '立即更新';

  @override
  String get updateDownloading => '正在下载更新…';

  @override
  String updateDownloadingProgress(int percent) {
    return '正在下载更新… $percent%';
  }

  @override
  String get updateVerifying => '正在校验更新包…';

  @override
  String get updatePreparing => '正在准备安装并重启…';

  @override
  String get updatePermissionRequired => '请允许 DDL out! 安装未知应用，然后再次点击“立即更新”。';

  @override
  String get updateUnsupported => '当前平台暂不支持应用内更新。';

  @override
  String get updatePackageUnavailable => '此版本没有适用于当前设备的更新包。';

  @override
  String get updateVerificationFailed => '更新包校验失败，请稍后重试。';

  @override
  String get updateInstallFailed => '无法安装更新，请稍后重试。';

  @override
  String get alreadyUpToDate => '当前已是最新版本';

  @override
  String aboutVersion(String version) {
    return '版本 $version';
  }

  @override
  String get updateSection => '更新';

  @override
  String get checkUpdatesOnStartup => '启动时自动检查更新';

  @override
  String get checkUpdatesOnStartupSubtitle => '开启后每次启动会连接 GitHub 检查正式版本';

  @override
  String get openLinkFailed => '无法打开链接，请稍后重试';

  @override
  String get documentLoadFailed => '文档加载失败';

  @override
  String get viewRepositorySource => '查看原文';

  @override
  String get authorsSection => '作者';

  @override
  String get legalSection => '法律与许可';

  @override
  String get openSourceLicense => '开源许可证';

  @override
  String get openSourceLicenseSubtitle => 'GNU GPLv3';

  @override
  String get thirdPartyLicenses => '第三方软件许可';

  @override
  String get thirdPartyLicensesSubtitle => '查看依赖与内嵌字体的许可证';

  @override
  String get privacyPolicy => '隐私政策';

  @override
  String get termsOfService => '服务协议';

  @override
  String get projectSection => '项目与反馈';

  @override
  String get sourceCode => '源代码';

  @override
  String get reportBug => '报告缺陷';

  @override
  String get requestFeature => '提出功能建议';

  @override
  String get discussions => '社区讨论';

  @override
  String get communityGuidelinesSection => '参与与规范';

  @override
  String get contributingGuide => '贡献指南';

  @override
  String get codeOfConduct => '社区行为准则';

  @override
  String get reportSecurityIssue => '私密报告安全漏洞';

  @override
  String get reportSecurityIssueSubtitle => '通过 GitHub 私密安全报告提交，请勿公开漏洞细节';

  @override
  String get nearbySync => '附近同步';

  @override
  String get nearbySyncSubtitle => '同一局域网内扫码，点对点同步';

  @override
  String get showSyncQr => '在电脑上显示二维码';

  @override
  String get scanSyncQr => '扫描同步二维码';

  @override
  String get lanSyncPrivacy => '数据只在当前局域网内加密传输，不经过云端；关闭页面后二维码随即失效。';

  @override
  String get syncConflicts => '同步冲突';

  @override
  String get noSyncConflicts => '没有待处理冲突';

  @override
  String syncConflictCount(int count) {
    return '有 $count 项需要选择保留版本';
  }

  @override
  String get pairedDevices => '已配对设备';

  @override
  String get noPairedDevices => '还没有配对过其他设备';

  @override
  String lastSyncedAt(String date) {
    return '最近同步：$date';
  }

  @override
  String get scanWithinTwoMinutes => '请用手机在 2 分钟内扫描；首次连接可能需要允许防火墙访问。';

  @override
  String get computerCreatesQr => '电脑将建立一次性同步会话，手机扫码后双方自动合并改动。';

  @override
  String get phoneScansQr => '扫描电脑上的二维码，双方会先比较版本，只传输缺少的改动。';

  @override
  String get createSyncQr => '生成同步二维码';

  @override
  String get scanAndSync => '扫码并同步';

  @override
  String get preparingSync => '正在准备安全连接…';

  @override
  String get connectingDevice => '正在连接电脑…';

  @override
  String syncingWith(String device) {
    return '正在与 $device 合并改动…';
  }

  @override
  String get otherDevice => '另一台设备';

  @override
  String syncCompleted(int received, int sent, int conflicts) {
    return '同步完成：收到 $received 项，发出 $sent 项，发现 $conflicts 个冲突。';
  }

  @override
  String get done => '完成';

  @override
  String get conflictApprovalHere => '当前设备负责冲突审批。选择一个版本后，该决定会在下次同步时传给另一端。';

  @override
  String get conflictApprovalOnComputer => '默认由生成二维码的电脑审批；当前手机先保持只读，避免两端重复操作。';

  @override
  String get resolveOnThisDevice => '改在此设备审批';

  @override
  String conflictingField(String field) {
    return '冲突字段：$field';
  }

  @override
  String candidateFrom(String device) {
    return '来自 $device';
  }

  @override
  String get categoryOrder => '分类顺序';

  @override
  String get completionState => '完成状态';

  @override
  String get deletionState => '删除状态';

  @override
  String get keepItem => '保留这条内容';

  @override
  String get deleteItem => '删除这条内容';

  @override
  String get emptyValue => '空值';

  @override
  String get forgetDevice => '移除配对设备';

  @override
  String forgetDeviceBody(String device) {
    return '移除“$device”后仍会保留本机数据和同步记录。下次扫码可以重新配对。';
  }
}
