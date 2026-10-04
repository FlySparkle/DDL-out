import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:window_manager/window_manager.dart';

import '../../core/alarms/system_alarm_service.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../settings/application/settings.dart';

/// Separate entry point: never starts the board, database, sync or updater.
class AlarmWindowApp extends ConsumerWidget {
  const AlarmWindowApp({super.key, required this.id});
  final String id;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    return DynamicColorBuilder(
      builder: (light, dark) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'DDL out! · Alarm',
        locale: settings.language.locale,
        themeMode: settings.themeMode,
        theme: AppTheme.light(
          dynamicScheme: settings.dynamicColorEnabled ? light : null,
          fontFamily: settings.useSystemFont ? null : 'NotoSansSC',
        ),
        darkTheme: AppTheme.dark(
          dynamicScheme: settings.dynamicColorEnabled ? dark : null,
          fontFamily: settings.useSystemFont ? null : 'NotoSansSC',
        ),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: AlarmWindow(id: id),
      ),
    );
  }
}

class AlarmWindow extends StatefulWidget {
  const AlarmWindow({super.key, required this.id});
  final String id;
  @override
  State<AlarmWindow> createState() => _AlarmWindowState();
}

class _AlarmWindowState extends State<AlarmWindow> with WindowListener {
  final _service = SystemAlarmService();
  SystemAlarmEntry? _entry;
  Object? _error;
  bool _closing = false;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    _load();
  }

  Future<void> _load() async {
    try {
      final entry = await _service.get(widget.id);
      if (!mounted) return;
      if (!entry.enabled) {
        await windowManager.destroy();
        return;
      }
      setState(() {
        _entry = entry;
        _error = null;
      });
      await _service.sound();
    } on Object catch (error) {
      if (mounted) setState(() => _error = error);
    }
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowClose() {
    _dismiss();
  }

  Future<void> _dismiss() async {
    if (_closing) return;
    setState(() => _closing = true);
    try {
      await _service.silence();
      if (_entry != null) await _service.disable(widget.id);
      await windowManager.destroy();
    } on Object catch (error) {
      if (mounted) {
        setState(() {
          _error = error;
          _closing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final entry = _entry;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: colors.primaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.alarm,
                            color: colors.onPrimaryContainer,
                            size: 52,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        l10n.alarmRinging,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      if (entry != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          entry.title,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          DateFormat.yMMMd(
                            Localizations.localeOf(context).toLanguageTag(),
                          ).add_Hm().format(entry.time),
                          textAlign: TextAlign.center,
                        ),
                        if (entry.notes.isNotEmpty)
                          Card.filled(
                            margin: const EdgeInsets.only(top: 20),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: SelectableText(entry.notes),
                            ),
                          ),
                      ] else if (_error == null)
                        const Padding(
                          padding: EdgeInsets.all(24),
                          child: LinearProgressIndicator(),
                        ),
                      if (_error != null) ...[
                        const SizedBox(height: 16),
                        SelectableText(
                          '${l10n.alarmFailed}\n${SystemAlarmService.diagnostic(_error!)}',
                        ),
                        TextButton(
                          onPressed: _load,
                          child: Text(l10n.alarmRetry),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _closing ? null : _dismiss,
                icon: const Icon(Icons.check),
                label: Text(l10n.alarmDismiss),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
