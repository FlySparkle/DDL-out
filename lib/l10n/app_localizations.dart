import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('zh'),
    Locale('en'),
    Locale('ja'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In zh, this message translates to:
  /// **'DDL out!'**
  String get appTitle;

  /// No description provided for @boardTitle.
  ///
  /// In zh, this message translates to:
  /// **'截止事项'**
  String get boardTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get settingsTitle;

  /// No description provided for @appearanceSettingsTitle.
  ///
  /// In zh, this message translates to:
  /// **'外观与个性化'**
  String get appearanceSettingsTitle;

  /// No description provided for @systemDataSettingsTitle.
  ///
  /// In zh, this message translates to:
  /// **'系统与数据'**
  String get systemDataSettingsTitle;

  /// No description provided for @aboutSettingsTitle.
  ///
  /// In zh, this message translates to:
  /// **'关于'**
  String get aboutSettingsTitle;

  /// No description provided for @communitySettingsTitle.
  ///
  /// In zh, this message translates to:
  /// **'社区与支持'**
  String get communitySettingsTitle;

  /// No description provided for @newCategory.
  ///
  /// In zh, this message translates to:
  /// **'新建分类'**
  String get newCategory;

  /// No description provided for @editCategory.
  ///
  /// In zh, this message translates to:
  /// **'编辑分类'**
  String get editCategory;

  /// No description provided for @categoryName.
  ///
  /// In zh, this message translates to:
  /// **'分类名称'**
  String get categoryName;

  /// No description provided for @categoryColor.
  ///
  /// In zh, this message translates to:
  /// **'分类颜色'**
  String get categoryColor;

  /// No description provided for @uncategorized.
  ///
  /// In zh, this message translates to:
  /// **'未分类'**
  String get uncategorized;

  /// No description provided for @addTask.
  ///
  /// In zh, this message translates to:
  /// **'添加事项'**
  String get addTask;

  /// No description provided for @newTask.
  ///
  /// In zh, this message translates to:
  /// **'新建事项'**
  String get newTask;

  /// No description provided for @editTask.
  ///
  /// In zh, this message translates to:
  /// **'编辑事项'**
  String get editTask;

  /// No description provided for @taskName.
  ///
  /// In zh, this message translates to:
  /// **'事项名称'**
  String get taskName;

  /// No description provided for @taskCategory.
  ///
  /// In zh, this message translates to:
  /// **'所属分类'**
  String get taskCategory;

  /// No description provided for @deadline.
  ///
  /// In zh, this message translates to:
  /// **'截止时间'**
  String get deadline;

  /// No description provided for @relativeTime.
  ///
  /// In zh, this message translates to:
  /// **'剩余时间'**
  String get relativeTime;

  /// No description provided for @absoluteTime.
  ///
  /// In zh, this message translates to:
  /// **'绝对时间'**
  String get absoluteTime;

  /// No description provided for @days.
  ///
  /// In zh, this message translates to:
  /// **'日'**
  String get days;

  /// No description provided for @hours.
  ///
  /// In zh, this message translates to:
  /// **'时'**
  String get hours;

  /// No description provided for @minutes.
  ///
  /// In zh, this message translates to:
  /// **'分'**
  String get minutes;

  /// No description provided for @date.
  ///
  /// In zh, this message translates to:
  /// **'日期'**
  String get date;

  /// No description provided for @time.
  ///
  /// In zh, this message translates to:
  /// **'时间'**
  String get time;

  /// No description provided for @save.
  ///
  /// In zh, this message translates to:
  /// **'保存'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get delete;

  /// No description provided for @confirm.
  ///
  /// In zh, this message translates to:
  /// **'确认'**
  String get confirm;

  /// No description provided for @moreActions.
  ///
  /// In zh, this message translates to:
  /// **'更多操作'**
  String get moreActions;

  /// No description provided for @customColor.
  ///
  /// In zh, this message translates to:
  /// **'自定义颜色'**
  String get customColor;

  /// No description provided for @expandCategory.
  ///
  /// In zh, this message translates to:
  /// **'展开分类'**
  String get expandCategory;

  /// No description provided for @collapseCategory.
  ///
  /// In zh, this message translates to:
  /// **'折叠分类'**
  String get collapseCategory;

  /// No description provided for @markComplete.
  ///
  /// In zh, this message translates to:
  /// **'标记为已完成'**
  String get markComplete;

  /// No description provided for @markIncomplete.
  ///
  /// In zh, this message translates to:
  /// **'标记为未完成'**
  String get markIncomplete;

  /// No description provided for @completed.
  ///
  /// In zh, this message translates to:
  /// **'已完成'**
  String get completed;

  /// No description provided for @overdue.
  ///
  /// In zh, this message translates to:
  /// **'已过期'**
  String get overdue;

  /// No description provided for @emptyTitle.
  ///
  /// In zh, this message translates to:
  /// **'还没有截止事项'**
  String get emptyTitle;

  /// No description provided for @emptyBody.
  ///
  /// In zh, this message translates to:
  /// **'先创建一个分类，再把要完成的事放进去。'**
  String get emptyBody;

  /// No description provided for @noTasks.
  ///
  /// In zh, this message translates to:
  /// **'这个分类还没有事项'**
  String get noTasks;

  /// No description provided for @clearCompleted.
  ///
  /// In zh, this message translates to:
  /// **'清除已完成'**
  String get clearCompleted;

  /// No description provided for @clearCategoryTasks.
  ///
  /// In zh, this message translates to:
  /// **'清空本分类事项'**
  String get clearCategoryTasks;

  /// No description provided for @clearCategories.
  ///
  /// In zh, this message translates to:
  /// **'清空分类'**
  String get clearCategories;

  /// No description provided for @clearAllData.
  ///
  /// In zh, this message translates to:
  /// **'清空全部数据'**
  String get clearAllData;

  /// No description provided for @themeMode.
  ///
  /// In zh, this message translates to:
  /// **'外观模式'**
  String get themeMode;

  /// No description provided for @themeSystem.
  ///
  /// In zh, this message translates to:
  /// **'跟随系统'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In zh, this message translates to:
  /// **'浅色'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In zh, this message translates to:
  /// **'深色'**
  String get themeDark;

  /// No description provided for @dynamicColor.
  ///
  /// In zh, this message translates to:
  /// **'莫奈动态配色'**
  String get dynamicColor;

  /// No description provided for @dynamicColorSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'Android 12 及以上默认使用系统配色'**
  String get dynamicColorSubtitle;

  /// No description provided for @useSystemFont.
  ///
  /// In zh, this message translates to:
  /// **'使用系统默认字体'**
  String get useSystemFont;

  /// No description provided for @useSystemFontSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'关闭后使用内嵌的思源黑体'**
  String get useSystemFontSubtitle;

  /// No description provided for @fontSize.
  ///
  /// In zh, this message translates to:
  /// **'字号'**
  String get fontSize;

  /// No description provided for @fontSizeValue.
  ///
  /// In zh, this message translates to:
  /// **'{percent}%'**
  String fontSizeValue(int percent);

  /// No description provided for @navigationMode.
  ///
  /// In zh, this message translates to:
  /// **'边栏模式'**
  String get navigationMode;

  /// No description provided for @floatingSidebar.
  ///
  /// In zh, this message translates to:
  /// **'浮动边栏'**
  String get floatingSidebar;

  /// No description provided for @floatingSidebarSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'使用左上角按钮或从页面左侧向右滑动打开边栏。'**
  String get floatingSidebarSubtitle;

  /// No description provided for @fixedSidebar.
  ///
  /// In zh, this message translates to:
  /// **'固定边栏'**
  String get fixedSidebar;

  /// No description provided for @fixedSidebarSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'宽度不足时自动切换为浮动边栏；固定时可手动收展或悬停展开。'**
  String get fixedSidebarSubtitle;

  /// No description provided for @expandSidebar.
  ///
  /// In zh, this message translates to:
  /// **'展开边栏'**
  String get expandSidebar;

  /// No description provided for @collapseSidebar.
  ///
  /// In zh, this message translates to:
  /// **'收起边栏'**
  String get collapseSidebar;

  /// No description provided for @backup.
  ///
  /// In zh, this message translates to:
  /// **'导出备份'**
  String get backup;

  /// No description provided for @restore.
  ///
  /// In zh, this message translates to:
  /// **'恢复备份'**
  String get restore;

  /// No description provided for @exportDialogTitle.
  ///
  /// In zh, this message translates to:
  /// **'导出 DDL out! 备份'**
  String get exportDialogTitle;

  /// No description provided for @restoreFileDialogTitle.
  ///
  /// In zh, this message translates to:
  /// **'选择 DDL out! 备份'**
  String get restoreFileDialogTitle;

  /// No description provided for @dataSection.
  ///
  /// In zh, this message translates to:
  /// **'数据'**
  String get dataSection;

  /// No description provided for @appearanceSection.
  ///
  /// In zh, this message translates to:
  /// **'外观'**
  String get appearanceSection;

  /// No description provided for @backupSuccess.
  ///
  /// In zh, this message translates to:
  /// **'备份已导出'**
  String get backupSuccess;

  /// No description provided for @restoreSuccess.
  ///
  /// In zh, this message translates to:
  /// **'备份恢复完成'**
  String get restoreSuccess;

  /// No description provided for @operationCancelled.
  ///
  /// In zh, this message translates to:
  /// **'操作已取消'**
  String get operationCancelled;

  /// No description provided for @operationFailed.
  ///
  /// In zh, this message translates to:
  /// **'操作失败，请重试'**
  String get operationFailed;

  /// No description provided for @invalidBackup.
  ///
  /// In zh, this message translates to:
  /// **'备份文件无效'**
  String get invalidBackup;

  /// No description provided for @nameRequired.
  ///
  /// In zh, this message translates to:
  /// **'请输入名称'**
  String get nameRequired;

  /// No description provided for @nameTooLong.
  ///
  /// In zh, this message translates to:
  /// **'名称过长'**
  String get nameTooLong;

  /// No description provided for @categoryRequired.
  ///
  /// In zh, this message translates to:
  /// **'请选择分类'**
  String get categoryRequired;

  /// No description provided for @deleteTaskTitle.
  ///
  /// In zh, this message translates to:
  /// **'删除事项？'**
  String get deleteTaskTitle;

  /// No description provided for @deleteTaskBody.
  ///
  /// In zh, this message translates to:
  /// **'此操作无法撤销。'**
  String get deleteTaskBody;

  /// No description provided for @deleteCategoryTitle.
  ///
  /// In zh, this message translates to:
  /// **'删除分类？'**
  String get deleteCategoryTitle;

  /// No description provided for @deleteCategoryBody.
  ///
  /// In zh, this message translates to:
  /// **'分类内的 {count} 个事项将移动到“未分类”。'**
  String deleteCategoryBody(int count);

  /// No description provided for @clearCompletedTitle.
  ///
  /// In zh, this message translates to:
  /// **'清除已完成事项？'**
  String get clearCompletedTitle;

  /// No description provided for @clearCompletedBody.
  ///
  /// In zh, this message translates to:
  /// **'将永久删除 {count} 个已完成事项。'**
  String clearCompletedBody(int count);

  /// No description provided for @clearCategoryTasksTitle.
  ///
  /// In zh, this message translates to:
  /// **'清空本分类的事项？'**
  String get clearCategoryTasksTitle;

  /// No description provided for @clearCategoryTasksBody.
  ///
  /// In zh, this message translates to:
  /// **'将永久删除本分类内的 {count} 个事项。'**
  String clearCategoryTasksBody(int count);

  /// No description provided for @clearCategoriesTitle.
  ///
  /// In zh, this message translates to:
  /// **'清空所有分类？'**
  String get clearCategoriesTitle;

  /// No description provided for @clearCategoriesBody.
  ///
  /// In zh, this message translates to:
  /// **'所有普通分类将被删除，事项会保留到“未分类”。'**
  String get clearCategoriesBody;

  /// No description provided for @clearAllTitle.
  ///
  /// In zh, this message translates to:
  /// **'清空全部数据？'**
  String get clearAllTitle;

  /// No description provided for @clearAllBody.
  ///
  /// In zh, this message translates to:
  /// **'所有分类和事项都将被永久删除。'**
  String get clearAllBody;

  /// No description provided for @restoreTitle.
  ///
  /// In zh, this message translates to:
  /// **'恢复这个备份？'**
  String get restoreTitle;

  /// No description provided for @restoreBody.
  ///
  /// In zh, this message translates to:
  /// **'备份包含 {categories} 个分类和 {tasks} 个事项。当前的 {existingCategories} 个分类和 {existingTasks} 个事项将被替换。'**
  String restoreBody(
    int categories,
    int tasks,
    int existingCategories,
    int existingTasks,
  );

  /// No description provided for @dataCount.
  ///
  /// In zh, this message translates to:
  /// **'{categories} 个分类，{tasks} 个事项'**
  String dataCount(int categories, int tasks);

  /// No description provided for @remainingShort.
  ///
  /// In zh, this message translates to:
  /// **'{hours}h {minutes}m'**
  String remainingShort(int hours, int minutes);

  /// No description provided for @remainingLong.
  ///
  /// In zh, this message translates to:
  /// **'{days}d {hours}h'**
  String remainingLong(int days, int hours);

  /// No description provided for @taskCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 项'**
  String taskCount(int count);

  /// No description provided for @errorTitle.
  ///
  /// In zh, this message translates to:
  /// **'加载失败'**
  String get errorTitle;

  /// No description provided for @retry.
  ///
  /// In zh, this message translates to:
  /// **'重试'**
  String get retry;

  /// No description provided for @checkForUpdates.
  ///
  /// In zh, this message translates to:
  /// **'检查更新'**
  String get checkForUpdates;

  /// No description provided for @checkForUpdatesSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'检查 GitHub 上是否有新版本'**
  String get checkForUpdatesSubtitle;

  /// No description provided for @updateAvailableTitle.
  ///
  /// In zh, this message translates to:
  /// **'发现新版本'**
  String get updateAvailableTitle;

  /// No description provided for @updateAvailableBody.
  ///
  /// In zh, this message translates to:
  /// **'DDL out! {version} 已发布。是否前往 GitHub 下载？'**
  String updateAvailableBody(String version);

  /// No description provided for @downloadUpdate.
  ///
  /// In zh, this message translates to:
  /// **'前往下载'**
  String get downloadUpdate;

  /// No description provided for @alreadyUpToDate.
  ///
  /// In zh, this message translates to:
  /// **'当前已是最新版本'**
  String get alreadyUpToDate;

  /// No description provided for @aboutVersion.
  ///
  /// In zh, this message translates to:
  /// **'版本 {version}'**
  String aboutVersion(String version);

  /// No description provided for @updateSection.
  ///
  /// In zh, this message translates to:
  /// **'更新'**
  String get updateSection;

  /// No description provided for @checkUpdatesOnStartup.
  ///
  /// In zh, this message translates to:
  /// **'启动时自动检查更新'**
  String get checkUpdatesOnStartup;

  /// No description provided for @checkUpdatesOnStartupSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'开启后每次启动会连接 GitHub 检查正式版本'**
  String get checkUpdatesOnStartupSubtitle;

  /// No description provided for @openLinkFailed.
  ///
  /// In zh, this message translates to:
  /// **'无法打开链接，请稍后重试'**
  String get openLinkFailed;

  /// No description provided for @documentLoadFailed.
  ///
  /// In zh, this message translates to:
  /// **'文档加载失败'**
  String get documentLoadFailed;

  /// No description provided for @viewRepositorySource.
  ///
  /// In zh, this message translates to:
  /// **'查看仓库原文'**
  String get viewRepositorySource;

  /// No description provided for @authorsSection.
  ///
  /// In zh, this message translates to:
  /// **'作者'**
  String get authorsSection;

  /// No description provided for @legalSection.
  ///
  /// In zh, this message translates to:
  /// **'法律与许可'**
  String get legalSection;

  /// No description provided for @openSourceLicense.
  ///
  /// In zh, this message translates to:
  /// **'开源许可证'**
  String get openSourceLicense;

  /// No description provided for @openSourceLicenseSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'GNU GPLv3'**
  String get openSourceLicenseSubtitle;

  /// No description provided for @thirdPartyLicenses.
  ///
  /// In zh, this message translates to:
  /// **'第三方软件许可'**
  String get thirdPartyLicenses;

  /// No description provided for @thirdPartyLicensesSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'查看依赖与内嵌字体的许可证'**
  String get thirdPartyLicensesSubtitle;

  /// No description provided for @privacyPolicy.
  ///
  /// In zh, this message translates to:
  /// **'隐私政策'**
  String get privacyPolicy;

  /// No description provided for @termsOfService.
  ///
  /// In zh, this message translates to:
  /// **'服务协议'**
  String get termsOfService;

  /// No description provided for @projectSection.
  ///
  /// In zh, this message translates to:
  /// **'项目与反馈'**
  String get projectSection;

  /// No description provided for @sourceCode.
  ///
  /// In zh, this message translates to:
  /// **'源代码'**
  String get sourceCode;

  /// No description provided for @reportBug.
  ///
  /// In zh, this message translates to:
  /// **'报告缺陷'**
  String get reportBug;

  /// No description provided for @requestFeature.
  ///
  /// In zh, this message translates to:
  /// **'提出功能建议'**
  String get requestFeature;

  /// No description provided for @discussions.
  ///
  /// In zh, this message translates to:
  /// **'社区讨论'**
  String get discussions;

  /// No description provided for @communityGuidelinesSection.
  ///
  /// In zh, this message translates to:
  /// **'参与与规范'**
  String get communityGuidelinesSection;

  /// No description provided for @contributingGuide.
  ///
  /// In zh, this message translates to:
  /// **'贡献指南'**
  String get contributingGuide;

  /// No description provided for @codeOfConduct.
  ///
  /// In zh, this message translates to:
  /// **'社区行为准则'**
  String get codeOfConduct;

  /// No description provided for @codeOfConductSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'离线阅读社区参与规范'**
  String get codeOfConductSubtitle;

  /// No description provided for @reportSecurityIssue.
  ///
  /// In zh, this message translates to:
  /// **'私密报告安全漏洞'**
  String get reportSecurityIssue;

  /// No description provided for @reportSecurityIssueSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'通过 GitHub 私密安全报告提交，请勿公开漏洞细节'**
  String get reportSecurityIssueSubtitle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
