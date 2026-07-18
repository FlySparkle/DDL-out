import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../application/settings.dart';
import 'settings_section_title.dart';
import 'settings_tile_group.dart';

class AppearanceSettingsSection extends ConsumerWidget {
  const AppearanceSettingsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(settingsControllerProvider);
    final controller = ref.read(settingsControllerProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SettingsSectionTitle(l10n.appearanceSection),
        const SizedBox(height: 8),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.language),
          title: Text(l10n.appLanguage),
          trailing: DropdownButtonHideUnderline(
            child: DropdownButton<AppLanguage>(
              value: settings.language,
              items: [
                DropdownMenuItem(
                  value: AppLanguage.system,
                  child: Text(l10n.languageSystem),
                ),
                DropdownMenuItem(
                  value: AppLanguage.simplifiedChinese,
                  child: Text(l10n.languageSimplifiedChinese),
                ),
                DropdownMenuItem(
                  value: AppLanguage.english,
                  child: Text(l10n.languageEnglish),
                ),
                DropdownMenuItem(
                  value: AppLanguage.japanese,
                  child: Text(l10n.languageJapanese),
                ),
              ],
              onChanged: (language) {
                if (language != null) controller.setLanguage(language);
              },
            ),
          ),
        ),
        const SizedBox(height: 12),
        SegmentedButton<ThemeMode>(
          segments: [
            ButtonSegment(
              value: ThemeMode.system,
              icon: const Icon(Icons.brightness_auto),
              label: Text(l10n.themeSystem),
            ),
            ButtonSegment(
              value: ThemeMode.light,
              icon: const Icon(Icons.light_mode),
              label: Text(l10n.themeLight),
            ),
            ButtonSegment(
              value: ThemeMode.dark,
              icon: const Icon(Icons.dark_mode),
              label: Text(l10n.themeDark),
            ),
          ],
          selected: {settings.themeMode},
          onSelectionChanged: (selection) {
            controller.setThemeMode(selection.single);
          },
        ),
        const SizedBox(height: 12),
        SettingsTileGroup(
          children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              secondary: const Icon(Icons.palette_outlined),
              title: Text(l10n.dynamicColor),
              subtitle: Text(l10n.dynamicColorSubtitle),
              value: settings.dynamicColorEnabled,
              onChanged: controller.setDynamicColorEnabled,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              secondary: const Icon(Icons.font_download_outlined),
              title: Text(l10n.useSystemFont),
              subtitle: Text(l10n.useSystemFontSubtitle),
              value: settings.useSystemFont,
              onChanged: controller.setUseSystemFont,
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.format_size),
          title: Text(l10n.fontSize),
          subtitle: Slider(
            value: settings.textScale,
            min: 0.8,
            max: 1.4,
            divisions: 6,
            label: l10n.fontSizeValue((settings.textScale * 100).round()),
            onChanged: controller.setTextScale,
          ),
          trailing: Text(
            l10n.fontSizeValue((settings.textScale * 100).round()),
          ),
        ),
        const SizedBox(height: 12),
        Text(l10n.navigationMode),
        const SizedBox(height: 8),
        SegmentedButton<SidebarMode>(
          segments: [
            ButtonSegment(
              value: SidebarMode.floating,
              icon: const Icon(Icons.menu_open),
              label: Text(l10n.floatingSidebar),
            ),
            ButtonSegment(
              value: SidebarMode.fixed,
              icon: const Icon(Icons.view_sidebar_outlined),
              label: Text(l10n.fixedSidebar),
            ),
          ],
          selected: {settings.sidebarMode},
          onSelectionChanged: (selection) {
            controller.setSidebarMode(selection.single);
          },
        ),
        const SizedBox(height: 8),
        Text(
          settings.sidebarMode == SidebarMode.floating
              ? l10n.floatingSidebarSubtitle
              : l10n.fixedSidebarSubtitle,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        Text(l10n.sidebarAlignment),
        const SizedBox(height: 8),
        SegmentedButton<SidebarAlignment>(
          segments: [
            ButtonSegment(
              value: SidebarAlignment.alignBetween,
              icon: const Icon(Icons.vertical_align_center),
              label: Text(l10n.sidebarAlignBetween),
            ),
            ButtonSegment(
              value: SidebarAlignment.start,
              icon: const Icon(Icons.vertical_align_top),
              label: Text(l10n.sidebarAlignStart),
            ),
            ButtonSegment(
              value: SidebarAlignment.end,
              icon: const Icon(Icons.vertical_align_bottom),
              label: Text(l10n.sidebarAlignEnd),
            ),
          ],
          selected: {settings.sidebarAlignment},
          onSelectionChanged: (selection) {
            controller.setSidebarAlignment(selection.single);
          },
        ),
      ],
    );
  }
}
