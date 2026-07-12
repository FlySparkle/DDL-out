// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'DDL out!';

  @override
  String get boardTitle => '締切タスク';

  @override
  String get settingsTitle => '設定';

  @override
  String get newCategory => 'カテゴリーを作成';

  @override
  String get editCategory => 'カテゴリーを編集';

  @override
  String get categoryName => 'カテゴリー名';

  @override
  String get categoryColor => 'カテゴリーの色';

  @override
  String get uncategorized => '未分類';

  @override
  String get addTask => 'タスクを追加';

  @override
  String get newTask => 'タスクを作成';

  @override
  String get editTask => 'タスクを編集';

  @override
  String get taskName => 'タスク名';

  @override
  String get taskCategory => 'カテゴリー';

  @override
  String get deadline => '締切';

  @override
  String get relativeTime => '残り時間';

  @override
  String get absoluteTime => '日時指定';

  @override
  String get days => '日';

  @override
  String get hours => '時間';

  @override
  String get minutes => '分';

  @override
  String get date => '日付';

  @override
  String get time => '時刻';

  @override
  String get save => '保存';

  @override
  String get cancel => 'キャンセル';

  @override
  String get delete => '削除';

  @override
  String get confirm => '確認';

  @override
  String get moreActions => 'その他の操作';

  @override
  String get customColor => 'カスタムカラー';

  @override
  String get expandCategory => 'カテゴリーを展開';

  @override
  String get collapseCategory => 'カテゴリーを折りたたむ';

  @override
  String get markComplete => '完了にする';

  @override
  String get markIncomplete => '未完了に戻す';

  @override
  String get completed => '完了';

  @override
  String get overdue => '期限切れ';

  @override
  String get emptyTitle => '締切タスクはまだありません';

  @override
  String get emptyBody => 'カテゴリーを作成して、完了したいことを追加しましょう。';

  @override
  String get noTasks => 'このカテゴリーにはタスクがありません';

  @override
  String get clearCompleted => '完了済みを削除';

  @override
  String get clearCategories => 'カテゴリーを削除';

  @override
  String get clearAllData => 'すべてのデータを削除';

  @override
  String get themeMode => 'テーマ';

  @override
  String get themeSystem => 'システム設定';

  @override
  String get themeLight => 'ライト';

  @override
  String get themeDark => 'ダーク';

  @override
  String get dynamicColor => 'ダイナミックカラー';

  @override
  String get dynamicColorSubtitle => 'Android 12 以降では、システムの配色をデフォルトで使用します';

  @override
  String get backup => 'バックアップをエクスポート';

  @override
  String get restore => 'バックアップを復元';

  @override
  String get exportDialogTitle => 'DDL out! のバックアップをエクスポート';

  @override
  String get restoreFileDialogTitle => 'DDL out! のバックアップを選択';

  @override
  String get dataSection => 'データ';

  @override
  String get appearanceSection => '外観';

  @override
  String get backupSuccess => 'バックアップをエクスポートしました';

  @override
  String get restoreSuccess => 'バックアップを復元しました';

  @override
  String get operationCancelled => '操作をキャンセルしました';

  @override
  String get operationFailed => '操作に失敗しました。もう一度お試しください。';

  @override
  String get invalidBackup => 'バックアップファイルが無効です';

  @override
  String get nameRequired => '名前を入力してください';

  @override
  String get nameTooLong => '名前が長すぎます';

  @override
  String get categoryRequired => 'カテゴリーを選択してください';

  @override
  String get deleteTaskTitle => 'タスクを削除しますか？';

  @override
  String get deleteTaskBody => 'この操作は元に戻せません。';

  @override
  String get deleteCategoryTitle => 'カテゴリーを削除しますか？';

  @override
  String deleteCategoryBody(int count) {
    return 'このカテゴリー内の $count 件のタスクは「未分類」に移動します。';
  }

  @override
  String get clearCompletedTitle => '完了済みタスクを削除しますか？';

  @override
  String clearCompletedBody(int count) {
    return '完了済みの $count 件のタスクを完全に削除します。';
  }

  @override
  String get clearCategoriesTitle => 'すべてのカテゴリーを削除しますか？';

  @override
  String get clearCategoriesBody => 'すべてのカテゴリーが削除され、タスクは「未分類」に残ります。';

  @override
  String get clearAllTitle => 'すべてのデータを削除しますか？';

  @override
  String get clearAllBody => 'すべてのカテゴリーとタスクが完全に削除されます。';

  @override
  String get restoreTitle => 'このバックアップを復元しますか？';

  @override
  String restoreBody(
    int categories,
    int tasks,
    int existingCategories,
    int existingTasks,
  ) {
    return 'バックアップには $categories 件のカテゴリーと $tasks 件のタスクがあります。現在の $existingCategories 件のカテゴリーと $existingTasks 件のタスクは置き換えられます。';
  }

  @override
  String dataCount(int categories, int tasks) {
    return '$categories 件のカテゴリー、$tasks 件のタスク';
  }

  @override
  String remainingShort(int hours, int minutes) {
    return '残り $hours時間$minutes分';
  }

  @override
  String remainingLong(int days, int hours) {
    return '残り $days日$hours時間';
  }

  @override
  String taskCount(int count) {
    return '$count 件';
  }

  @override
  String get errorTitle => '読み込めませんでした';

  @override
  String get retry => '再試行';

  @override
  String aboutVersion(String version) {
    return 'バージョン $version';
  }
}
