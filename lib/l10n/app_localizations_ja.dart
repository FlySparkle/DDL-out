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
  String get appearanceSettingsTitle => '外観とカスタマイズ';

  @override
  String get systemDataSettingsTitle => 'システムとデータ';

  @override
  String get aboutSettingsTitle => 'このアプリについて';

  @override
  String get communitySettingsTitle => 'コミュニティとサポート';

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
  String get emptyBody => 'まずやることを記録しましょう。カテゴリー分けは後からでもできます。';

  @override
  String get noTasks => 'このカテゴリーにはタスクがありません';

  @override
  String get clearCompleted => '完了済みタスクを削除';

  @override
  String get clearCategoryTasks => 'このカテゴリーの完了済みを削除';

  @override
  String get categoryActions => 'カテゴリー操作';

  @override
  String get reorderCategory => 'ドラッグしてカテゴリーを並べ替え';

  @override
  String get moveTask => 'ドラッグしてタスクを移動';

  @override
  String get taskActions => 'タスク操作';

  @override
  String get clearAllData => 'すべてのデータを削除';

  @override
  String get appLanguage => '言語';

  @override
  String get languageSystem => 'システム設定に従う';

  @override
  String get languageSimplifiedChinese => '简体中文';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageJapanese => '日本語';

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
  String get useSystemFont => 'システムのデフォルトフォントを使用';

  @override
  String get useSystemFontSubtitle => 'オフにすると内蔵の Noto Sans SC を使用します';

  @override
  String get fontSize => '文字サイズ';

  @override
  String fontSizeValue(int percent) {
    return '$percent%';
  }

  @override
  String get navigationMode => 'サイドバーのモード';

  @override
  String get floatingSidebar => 'フローティング';

  @override
  String get floatingSidebarSubtitle => '左上のボタン、または画面左端から右へスワイプして開きます。';

  @override
  String get fixedSidebar => '固定';

  @override
  String get fixedSidebarSubtitle =>
      '幅が足りない場合はフローティングに切り替わり、固定時は手動またはホバーで展開できます。';

  @override
  String get sidebarAlignment => 'サイドバーの配置';

  @override
  String get sidebarAlignBetween => '上下に分割';

  @override
  String get sidebarAlignStart => '上寄せ';

  @override
  String get sidebarAlignEnd => '下寄せ';

  @override
  String get expandSidebar => 'サイドバーを展開';

  @override
  String get collapseSidebar => 'サイドバーを折りたたむ';

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
  String get deleteCategory => 'カテゴリーを削除';

  @override
  String deleteCategoryBody(int count) {
    return 'このカテゴリー内の $count 件のタスクは「未分類」に移動します。';
  }

  @override
  String get clearCompletedTitle => 'すべての完了済みタスクを削除しますか？';

  @override
  String clearCompletedBody(int count) {
    return '完了済みの $count 件のタスクを完全に削除します。';
  }

  @override
  String get clearCategoryTasksTitle => 'このカテゴリーの完了済みタスクを削除しますか？';

  @override
  String clearCategoryTasksBody(int count) {
    return 'このカテゴリー内の完了済みタスク $count 件を完全に削除します。';
  }

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
  String overdueByShort(int hours, int minutes) {
    return '$hours時間$minutes分超過';
  }

  @override
  String overdueByLong(int days, int hours) {
    return '$days日$hours時間超過';
  }

  @override
  String get inOneHour => '1時間後';

  @override
  String get today => '今日';

  @override
  String get tomorrow => '明日';

  @override
  String get thisWeekend => '今週末';

  @override
  String get undo => '元に戻す';

  @override
  String get taskMarkedComplete => '完了にしました';

  @override
  String get taskMarkedIncomplete => '未完了に戻しました';

  @override
  String taskMovedTo(String category) {
    return '「$category」へ移動しました';
  }

  @override
  String get clearCompletedConfirm => '完全に削除';

  @override
  String get clearCategoryTasksConfirm => '完了済みを削除';

  @override
  String get deleteCategoryConfirm => 'カテゴリーを削除';

  @override
  String get deleteTaskConfirm => 'タスクを削除';

  @override
  String get clearAllConfirm => 'すべてのデータを消去';

  @override
  String get restoreConfirm => '復元して置き換え';

  @override
  String taskCount(int count) {
    return '$count 件';
  }

  @override
  String get errorTitle => '読み込めませんでした';

  @override
  String get retry => '再試行';

  @override
  String get checkForUpdates => 'アップデートを確認';

  @override
  String get checkForUpdatesSubtitle => 'GitHub で新しいリリースを確認';

  @override
  String get updateAvailableTitle => 'アップデートがあります';

  @override
  String updateAvailableBody(String version) {
    return 'DDL out! $version が公開されました。アプリ内でダウンロードしてインストールできます。';
  }

  @override
  String get downloadUpdate => '今すぐ更新';

  @override
  String get updateDownloading => 'アップデートをダウンロードしています…';

  @override
  String updateDownloadingProgress(int percent) {
    return 'アップデートをダウンロードしています… $percent%';
  }

  @override
  String get updateVerifying => 'アップデートを検証しています…';

  @override
  String get updatePreparing => 'インストールと再起動を準備しています…';

  @override
  String get updatePermissionRequired =>
      'DDL out! に不明なアプリのインストールを許可し、もう一度「今すぐ更新」をタップしてください。';

  @override
  String get updateUnsupported => 'このプラットフォームではアプリ内更新をまだ利用できません。';

  @override
  String get updatePackageUnavailable => 'このデバイス向けのアップデートパッケージがありません。';

  @override
  String get updateVerificationFailed => 'アップデートを検証できませんでした。後でもう一度お試しください。';

  @override
  String get updateInstallFailed => 'アップデートをインストールできませんでした。後でもう一度お試しください。';

  @override
  String get alreadyUpToDate => '最新バージョンです';

  @override
  String aboutVersion(String version) {
    return 'バージョン $version';
  }

  @override
  String get updateSection => '更新';

  @override
  String get checkUpdatesOnStartup => '起動時に更新を確認';

  @override
  String get checkUpdatesOnStartupSubtitle => '起動時に GitHub へ接続して正式版を確認します';

  @override
  String get openLinkFailed => 'リンクを開けませんでした。後でもう一度お試しください';

  @override
  String get documentLoadFailed => '文書を読み込めませんでした';

  @override
  String get viewRepositorySource => '原文を見る';

  @override
  String get authorsSection => '作者';

  @override
  String get legalSection => '法的情報とライセンス';

  @override
  String get openSourceLicense => 'オープンソースライセンス';

  @override
  String get openSourceLicenseSubtitle => 'GNU GPLv3';

  @override
  String get thirdPartyLicenses => '第三者ソフトウェアのライセンス';

  @override
  String get thirdPartyLicensesSubtitle => '依存関係と同梱フォントのライセンス';

  @override
  String get privacyPolicy => 'プライバシーポリシー';

  @override
  String get termsOfService => 'サービス利用規約';

  @override
  String get projectSection => 'プロジェクトとフィードバック';

  @override
  String get sourceCode => 'ソースコード';

  @override
  String get reportBug => '不具合を報告';

  @override
  String get requestFeature => '機能を提案';

  @override
  String get discussions => 'コミュニティディスカッション';

  @override
  String get communityGuidelinesSection => '参加とガイドライン';

  @override
  String get contributingGuide => '貢献ガイド';

  @override
  String get codeOfConduct => 'コミュニティ行動規範';

  @override
  String get reportSecurityIssue => '脆弱性を非公開で報告';

  @override
  String get reportSecurityIssueSubtitle =>
      'GitHub の非公開報告を使用し、脆弱性の詳細を公開しないでください';
}
