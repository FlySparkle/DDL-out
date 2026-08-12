import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/navigation/app_navigation_shell.dart';
import '../../l10n/app_localizations.dart';
import 'application/settings.dart';
import 'presentation/data_settings_section.dart';
import 'presentation/settings_section_title.dart';
import 'settings_page.dart';

class SystemDataSettingsPage extends ConsumerWidget {
  const SystemDataSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(settingsControllerProvider);
    final controller = ref.read(settingsControllerProvider.notifier);
    return SettingsPageScaffold(
      destination: AppNavigationDestinationId.settings,
      showBackButton: true,
      title: l10n.systemDataSettingsTitle,
      body: ListView(
        padding: SettingsPageScaffold.contentPadding,
        children: [
          SettingsSectionTitle(l10n.updateSection),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: const Icon(Icons.system_update_outlined),
            title: Text(l10n.checkUpdatesOnStartup),
            subtitle: Text(l10n.checkUpdatesOnStartupSubtitle),
            value: settings.checkForUpdatesOnStartup,
            onChanged: settings.hydrated
                ? controller.setCheckForUpdatesOnStartup
                : null,
          ),
          const SizedBox(height: 8),
          _GitHubTokenField(
            token: settings.githubToken,
            enabled: settings.hydrated,
            onSave: controller.setGithubToken,
          ),
          const DataSettingsSection(),
        ],
      ),
    );
  }
}

class _GitHubTokenField extends StatefulWidget {
  const _GitHubTokenField({
    required this.token,
    required this.enabled,
    required this.onSave,
  });

  final String token;
  final bool enabled;
  final Future<void> Function(String value) onSave;

  @override
  State<_GitHubTokenField> createState() => _GitHubTokenFieldState();
}

class _GitHubTokenFieldState extends State<_GitHubTokenField> {
  late final TextEditingController _controller;
  bool _obscureText = true;
  bool _dirty = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.token);
  }

  @override
  void didUpdateWidget(_GitHubTokenField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_dirty && oldWidget.token != widget.token) {
      _controller.text = widget.token;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          key: const ValueKey('github-token-field'),
          controller: _controller,
          enabled: widget.enabled && !_saving,
          obscureText: _obscureText,
          autocorrect: false,
          enableSuggestions: false,
          maxLength: 255,
          decoration: InputDecoration(
            labelText: l10n.githubToken,
            helperText: l10n.githubTokenSubtitle,
            helperMaxLines: 3,
            prefixIcon: const Icon(Icons.key_outlined),
            suffixIcon: IconButton(
              tooltip: _obscureText
                  ? l10n.showGithubToken
                  : l10n.hideGithubToken,
              onPressed: () => setState(() => _obscureText = !_obscureText),
              icon: Icon(
                _obscureText ? Icons.visibility_outlined : Icons.visibility_off,
              ),
            ),
          ),
          onChanged: (_) => setState(() => _dirty = true),
          onFieldSubmitted: (_) => _save(),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: !widget.enabled || _saving || widget.token.isEmpty
                  ? null
                  : _clear,
              child: Text(l10n.clearGithubToken),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: !widget.enabled || _saving || !_dirty ? null : _save,
              child: Text(l10n.saveGithubToken),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _save() async {
    if (_saving) return;
    final value = _controller.text.trim();
    if (value.contains(RegExp(r'\s'))) {
      _showMessage(AppLocalizations.of(context).invalidGithubToken);
      return;
    }
    setState(() => _saving = true);
    try {
      await widget.onSave(value);
    } on Object {
      if (mounted) {
        setState(() => _saving = false);
        _showMessage(AppLocalizations.of(context).operationFailed);
      }
      return;
    }
    if (!mounted) return;
    setState(() {
      _saving = false;
      _dirty = false;
      _controller.text = value;
    });
    _showMessage(AppLocalizations.of(context).githubTokenSaved);
  }

  Future<void> _clear() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await widget.onSave('');
    } on Object {
      if (mounted) {
        setState(() => _saving = false);
        _showMessage(AppLocalizations.of(context).operationFailed);
      }
      return;
    }
    if (!mounted) return;
    setState(() {
      _saving = false;
      _dirty = false;
      _controller.clear();
    });
    _showMessage(AppLocalizations.of(context).githubTokenCleared);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
