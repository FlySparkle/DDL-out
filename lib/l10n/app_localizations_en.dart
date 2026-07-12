// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'DDL out!';

  @override
  String get boardTitle => 'Deadlines';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get newCategory => 'New category';

  @override
  String get editCategory => 'Edit category';

  @override
  String get categoryName => 'Category name';

  @override
  String get categoryColor => 'Category color';

  @override
  String get uncategorized => 'Uncategorized';

  @override
  String get addTask => 'Add task';

  @override
  String get newTask => 'New task';

  @override
  String get editTask => 'Edit task';

  @override
  String get taskName => 'Task name';

  @override
  String get taskCategory => 'Category';

  @override
  String get deadline => 'Deadline';

  @override
  String get relativeTime => 'Remaining time';

  @override
  String get absoluteTime => 'Date and time';

  @override
  String get days => 'days';

  @override
  String get hours => 'hours';

  @override
  String get minutes => 'minutes';

  @override
  String get date => 'Date';

  @override
  String get time => 'Time';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get confirm => 'Confirm';

  @override
  String get moreActions => 'More actions';

  @override
  String get customColor => 'Custom color';

  @override
  String get expandCategory => 'Expand category';

  @override
  String get collapseCategory => 'Collapse category';

  @override
  String get markComplete => 'Mark complete';

  @override
  String get markIncomplete => 'Mark incomplete';

  @override
  String get completed => 'Completed';

  @override
  String get overdue => 'Overdue';

  @override
  String get emptyTitle => 'No deadlines yet';

  @override
  String get emptyBody =>
      'Create a category, then add the things you need to finish.';

  @override
  String get noTasks => 'No tasks in this category';

  @override
  String get clearCompleted => 'Clear completed';

  @override
  String get clearCategoryTasks => 'Clear tasks in this category';

  @override
  String get clearCategories => 'Clear categories';

  @override
  String get clearAllData => 'Clear all data';

  @override
  String get themeMode => 'Theme';

  @override
  String get themeSystem => 'System default';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get dynamicColor => 'Dynamic color';

  @override
  String get dynamicColorSubtitle =>
      'Uses the system color scheme by default on Android 12 and later';

  @override
  String get fontFamily => 'Interface font';

  @override
  String get fontSystem => 'System default';

  @override
  String get fontSansSerif => 'Sans serif';

  @override
  String get fontSerif => 'Serif';

  @override
  String get fontMonospace => 'Monospace';

  @override
  String get fontSize => 'Text size';

  @override
  String fontSizeValue(int percent) {
    return '$percent%';
  }

  @override
  String get adaptiveDesktopSidebar => 'Adaptive desktop sidebar';

  @override
  String get adaptiveDesktopSidebarSubtitle =>
      'On wide windows, keep the sidebar visible. On narrow windows, collapse it until the pointer hovers over the edge.';

  @override
  String get backup => 'Export backup';

  @override
  String get restore => 'Restore backup';

  @override
  String get exportDialogTitle => 'Export DDL out! backup';

  @override
  String get restoreFileDialogTitle => 'Choose a DDL out! backup';

  @override
  String get dataSection => 'Data';

  @override
  String get appearanceSection => 'Appearance';

  @override
  String get backupSuccess => 'Backup exported';

  @override
  String get restoreSuccess => 'Backup restored';

  @override
  String get operationCancelled => 'Operation cancelled';

  @override
  String get operationFailed => 'Operation failed. Please try again.';

  @override
  String get invalidBackup => 'Invalid backup file';

  @override
  String get nameRequired => 'Enter a name';

  @override
  String get nameTooLong => 'Name is too long';

  @override
  String get categoryRequired => 'Choose a category';

  @override
  String get deleteTaskTitle => 'Delete task?';

  @override
  String get deleteTaskBody => 'This action cannot be undone.';

  @override
  String get deleteCategoryTitle => 'Delete category?';

  @override
  String deleteCategoryBody(int count) {
    return 'The $count tasks in this category will move to Uncategorized.';
  }

  @override
  String get clearCompletedTitle => 'Clear completed tasks?';

  @override
  String clearCompletedBody(int count) {
    return 'This will permanently delete $count completed tasks.';
  }

  @override
  String get clearCategoryTasksTitle => 'Clear tasks in this category?';

  @override
  String clearCategoryTasksBody(int count) {
    return 'This will permanently delete the $count tasks in this category.';
  }

  @override
  String get clearCategoriesTitle => 'Clear all categories?';

  @override
  String get clearCategoriesBody =>
      'All categories will be deleted. Tasks will remain in Uncategorized.';

  @override
  String get clearAllTitle => 'Clear all data?';

  @override
  String get clearAllBody =>
      'All categories and tasks will be permanently deleted.';

  @override
  String get restoreTitle => 'Restore this backup?';

  @override
  String restoreBody(
    int categories,
    int tasks,
    int existingCategories,
    int existingTasks,
  ) {
    return 'The backup has $categories categories and $tasks tasks. It will replace the current $existingCategories categories and $existingTasks tasks.';
  }

  @override
  String dataCount(int categories, int tasks) {
    return '$categories categories, $tasks tasks';
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
    return '$count tasks';
  }

  @override
  String get errorTitle => 'Unable to load';

  @override
  String get retry => 'Retry';

  @override
  String get checkForUpdates => 'Check for updates';

  @override
  String get checkForUpdatesSubtitle => 'Check GitHub for a newer release';

  @override
  String get updateAvailableTitle => 'Update available';

  @override
  String updateAvailableBody(String version) {
    return 'DDL out! $version is available. Open GitHub to download it?';
  }

  @override
  String get downloadUpdate => 'Download';

  @override
  String get alreadyUpToDate => 'You\'re up to date';

  @override
  String aboutVersion(String version) {
    return 'Version $version';
  }
}
