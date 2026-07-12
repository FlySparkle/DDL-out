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
  String get moreActions => '更多操作';

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
  String get emptyBody => '先创建一个分类，再把要完成的事放进去。';

  @override
  String get noTasks => '这个分类还没有事项';

  @override
  String get clearCompleted => '清除已完成';

  @override
  String get clearCategories => '清空分类';

  @override
  String get clearAllData => '清空全部数据';

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
  String get fontFamily => '界面字体';

  @override
  String get fontSystem => '系统默认';

  @override
  String get fontSansSerif => '无衬线字体';

  @override
  String get fontSerif => '衬线字体';

  @override
  String get fontMonospace => '等宽字体';

  @override
  String get fontSize => '字号';

  @override
  String fontSizeValue(int percent) {
    return '$percent%';
  }

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
  String deleteCategoryBody(int count) {
    return '分类内的 $count 个事项将移动到“未分类”。';
  }

  @override
  String get clearCompletedTitle => '清除已完成事项？';

  @override
  String clearCompletedBody(int count) {
    return '将永久删除 $count 个已完成事项。';
  }

  @override
  String get clearCategoriesTitle => '清空所有分类？';

  @override
  String get clearCategoriesBody => '所有普通分类将被删除，事项会保留到“未分类”。';

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
    return '${hours}h ${minutes}m';
  }

  @override
  String remainingLong(int days, int hours) {
    return '${days}d ${hours}h';
  }

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
    return 'DDL out! $version 已发布。是否前往 GitHub 下载？';
  }

  @override
  String get downloadUpdate => '前往下载';

  @override
  String get alreadyUpToDate => '当前已是最新版本';

  @override
  String aboutVersion(String version) {
    return '版本 $version';
  }
}
