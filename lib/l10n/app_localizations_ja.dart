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
  String get taskTitleSection => 'タイトル';

  @override
  String get taskDetailsSection => '詳細';

  @override
  String get taskDetailsHint => 'Ctrl+V で画像を貼り付けられます';

  @override
  String get taskDetailImages => '詳細画像';

  @override
  String get chooseImages => '写真ライブラリから画像を選択';

  @override
  String get imagePickFailed => '選択した画像を挿入できません。形式またはサイズを確認してください。';

  @override
  String get pasteImage => '画像を貼り付け';

  @override
  String get removeImage => '画像を削除';

  @override
  String get openImageDesktop => 'ダブルクリックして画像を開く';

  @override
  String get openImageMobile => 'タップして画像を全画面表示';

  @override
  String get imageViewerTitle => '画像ビューアー';

  @override
  String get zoomOut => '縮小';

  @override
  String get zoomIn => '拡大';

  @override
  String get resetZoom => '表示倍率をリセット';

  @override
  String get close => '閉じる';

  @override
  String get noImageInClipboard => 'クリップボードに使用できる画像がありません';

  @override
  String get imagePasteFailed => '画像を貼り付けられません。形式とサイズを確認してください。';

  @override
  String get taskCategory => 'カテゴリー';

  @override
  String get deadline => '締切';

  @override
  String get relativeTime => '残り時間';

  @override
  String get absoluteTime => '日時指定';

  @override
  String get noDeadline => '期限なし';

  @override
  String get noDeadlineSubtitle => 'このタスクにはカウントダウンがなく、期限順では期限付きタスクの後に並びます。';

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
  String get sortTasks => '期限順に自動整列';

  @override
  String get tasksSorted => '期限順に並べ替えました';

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
  String get showDragHandles => 'ドラッグハンドルを表示';

  @override
  String get showDragHandlesSubtitle =>
      'オンではタスクとカテゴリーの左側ハンドルから、オフではタスク行またはカテゴリカードを長押ししてドラッグします。';

  @override
  String get fontSize => '文字サイズ';

  @override
  String get fontSizeSmaller => '小さめ';

  @override
  String get fontSizeStandard => '標準';

  @override
  String get fontSizeLarger => '大きめ';

  @override
  String get fontSizeExtraLarge => '特大';

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
  String get deleteTaskBody => 'カウントダウンが終わるまで削除を元に戻せます。';

  @override
  String get deleteCategoryTitle => 'カテゴリーを削除しますか？';

  @override
  String get deleteCategory => 'カテゴリーを削除';

  @override
  String deleteCategoryBody(int count) {
    return 'このカテゴリー内の $count 件のタスクは「未分類」に移動します。カウントダウンが終わるまで元に戻せます。';
  }

  @override
  String get clearCompletedTitle => 'すべての完了済みタスクを削除しますか？';

  @override
  String clearCompletedBody(int count) {
    return '完了済みの $count 件のタスクを削除します。カウントダウンが終わるまで元に戻せます。';
  }

  @override
  String get clearCategoryTasksTitle => 'このカテゴリーの完了済みタスクを削除しますか？';

  @override
  String clearCategoryTasksBody(int count) {
    return 'このカテゴリー内の完了済みタスク $count 件を削除します。カウントダウンが終わるまで元に戻せます。';
  }

  @override
  String get clearAllTitle => 'すべてのデータを削除しますか？';

  @override
  String get clearAllBody => 'すべてのカテゴリーとタスクを削除します。カウントダウンが終わるまで元に戻せます。';

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
  String undoCountdown(int seconds) {
    return '元に戻す（$seconds秒）';
  }

  @override
  String get taskDeleted => 'タスクを削除しました';

  @override
  String get categoryDeleted => 'カテゴリーを削除しました';

  @override
  String completedTasksDeleted(int count) {
    return '完了済みタスクを $count 件削除しました';
  }

  @override
  String get allDataDeleted => 'すべてのデータを削除しました';

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
  String get githubToken => 'GitHub Token（任意）';

  @override
  String get githubTokenSubtitle =>
      'このアプリのローカル設定だけに保存し、GitHub Release API のリクエストだけに使用します。匿名リクエストの制限を軽減できます。';

  @override
  String get showGithubToken => 'Token を表示';

  @override
  String get hideGithubToken => 'Token を隠す';

  @override
  String get clearGithubToken => '消去';

  @override
  String get saveGithubToken => 'Token を保存';

  @override
  String get invalidGithubToken => 'Token に空白や改行は使用できません';

  @override
  String get githubTokenSaved => 'GitHub Token を保存しました';

  @override
  String get githubTokenCleared => 'GitHub Token を消去しました';

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

  @override
  String get nearbySync => '近くの端末と同期';

  @override
  String get nearbySyncSubtitle => '同じ LAN で QR コードまたはペアリングキーを使って端末間同期します';

  @override
  String get showSyncQr => 'パソコンに QR コードを表示';

  @override
  String get scanSyncQr => '同期 QR コードをスキャン';

  @override
  String get lanSyncPrivacy =>
      'データはこの LAN 内だけで暗号化して送信され、クラウドは経由しません。セッションを閉じると QR コードは無効になります。';

  @override
  String get syncConflicts => '同期の競合';

  @override
  String get noSyncConflicts => '確認が必要な競合はありません';

  @override
  String syncConflictCount(int count) {
    return '$count 件で残すバージョンを選択してください';
  }

  @override
  String get pairedDevices => 'ペアリング済み端末';

  @override
  String get noPairedDevices => 'ペアリングした端末はまだありません';

  @override
  String lastSyncedAt(String date) {
    return '最終同期：$date';
  }

  @override
  String get scanWithinTwoMinutes =>
      '2 分以内に別の端末でスキャンするかキーを貼り付けてください。初回はファイアウォールの許可が必要な場合があります。';

  @override
  String get computerCreatesQr =>
      'パソコンが一度限りのセッションを作成し、スマートフォンのスキャン後に双方の変更を自動で統合します。';

  @override
  String get phoneScansQr => 'パソコンのコードをスキャンします。バージョンを比較し、不足している変更だけを転送します。';

  @override
  String get createSyncQr => '同期 QR コードを作成';

  @override
  String get scanAndSync => 'スキャンして同期';

  @override
  String get preparingSync => '安全な接続を準備しています…';

  @override
  String get connectingDevice => '別の端末に接続しています…';

  @override
  String syncingWith(String device) {
    return '$device と変更を統合しています…';
  }

  @override
  String syncTransferProgress(String transferred, String total) {
    return '転送済み $transferred/$total';
  }

  @override
  String get otherDevice => 'もう一方の端末';

  @override
  String syncCompleted(int received, int sent, int conflicts) {
    return '同期完了：受信 $received 件、送信 $sent 件、競合 $conflicts 件。';
  }

  @override
  String get done => '完了';

  @override
  String get conflictApprovalHere => 'この端末で競合を確認します。選択内容は次回の同期で他方へ伝わります。';

  @override
  String get conflictApprovalOnComputer =>
      '既定では同期を開始した端末で競合を確認します。重複操作を防ぐため、この端末は読み取り専用です。';

  @override
  String get conflictApprovalOnInitiator =>
      '既定では同期を開始した端末で競合を確認します。重複操作を防ぐため、この端末は読み取り専用です。';

  @override
  String get syncRoleDescription =>
      'どの端末でも同期を開始または受信できます。開始側が QR コードとワンタイムキーを作成し、受信側がスキャンまたは貼り付けて接続します。';

  @override
  String get joinSyncSession => '同期を受信';

  @override
  String get syncPairingKey => 'ペアリングキー';

  @override
  String get pasteSyncKey => 'キーを貼り付け';

  @override
  String get connectAndSync => '接続して同期';

  @override
  String get copySyncKey => 'キーをコピー';

  @override
  String get syncKeyCopied => 'ペアリングキーをコピーしました';

  @override
  String get largeFileTransfer => '大容量ファイル転送';

  @override
  String get largeFileTransferSubtitle =>
      '両方の端末で有効にすると、分割ストリーミングにアプリ上のサイズ上限はありません。端末容量とシステム資源の制約は適用されます。';

  @override
  String get syncDataConflict => '同期データ';

  @override
  String get syncDataChoice => 'この端末のバージョン';

  @override
  String get orderingConflict => '並び順の競合';

  @override
  String get resolveOnThisDevice => 'この端末で確認';

  @override
  String conflictingField(String field) {
    return '競合フィールド：$field';
  }

  @override
  String candidateFrom(String device) {
    return '$device から';
  }

  @override
  String get categoryOrder => 'カテゴリーの順序';

  @override
  String get completionState => '完了状態';

  @override
  String get deletionState => '削除状態';

  @override
  String get keepItem => 'この項目を残す';

  @override
  String get deleteItem => 'この項目を削除';

  @override
  String get emptyValue => '空の値';

  @override
  String get forgetDevice => 'ペアリング端末を削除';

  @override
  String forgetDeviceBody(String device) {
    return '「$device」を削除しても、この端末のデータと同期履歴は残ります。新しいコードで再度ペアリングできます。';
  }
}
