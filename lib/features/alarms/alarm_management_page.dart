import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/alarms/system_alarm_service.dart';
import '../../l10n/app_localizations.dart';

class AlarmManagementPage extends StatefulWidget {
  const AlarmManagementPage({super.key});
  @override
  State<AlarmManagementPage> createState() => _AlarmManagementPageState();
}

class _AlarmManagementPageState extends State<AlarmManagementPage>
    with WidgetsBindingObserver {
  final _service = SystemAlarmService();
  List<SystemAlarmEntry>? _entries;
  Object? _error;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !_busy) _load();
  }

  Future<void> _load() async {
    try {
      final entries = await _service.list();
      if (mounted) {
        setState(() {
          _entries = entries;
          _error = null;
        });
      }
    } on Object catch (error) {
      if (mounted) setState(() => _error = error);
    }
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
      await _load();
    } on Object catch (error) {
      // Bulk deletion may have removed some entries before failing.
      await _load();
      if (mounted) setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _clearAll() async {
    final entries = List<SystemAlarmEntry>.of(_entries ?? []);
    if (_busy || entries.isEmpty) return;
    final l10n = AppLocalizations.of(context);
    final android = SystemAlarmService.usesAndroidClock;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(android ? l10n.alarmClearRecords : l10n.alarmClearAll),
        content: Text(
          android
              ? l10n.alarmClearRecordsConfirm(entries.length)
              : l10n.alarmClearAllConfirm(entries.length),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(android ? l10n.alarmClearRecords : l10n.alarmClearAll),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await _run(() => _service.clearEntries(entries));
    }
  }

  Future<void> _remove(SystemAlarmEntry entry) async {
    final l10n = AppLocalizations.of(context);
    final android = SystemAlarmService.usesAndroidClock;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(entry.title),
        content: Text(
          android ? l10n.alarmForgetConfirm : l10n.alarmDeleteConfirm,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(android ? l10n.alarmForget : l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await _run(
        () => android ? _service.forget(entry.id) : _service.delete(entry.id),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final android = SystemAlarmService.usesAndroidClock;
    final locale = Localizations.localeOf(context).toLanguageTag();
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _busy || (_entries?.isEmpty ?? true) || _error != null
            ? null
            : _clearAll,
        icon: const Icon(Icons.delete_sweep_outlined),
        label: Text(android ? l10n.alarmClearRecords : l10n.alarmClearAll),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      appBar: AppBar(
        title: Text(l10n.alarmManagerTitle),
        actions: [
          IconButton(
            onPressed: _busy ? null : _load,
            tooltip: l10n.alarmRetry,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 112),
            children: [
              Card.filled(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    android
                        ? l10n.alarmAndroidManagerInfo
                        : l10n.alarmManagerInfo,
                  ),
                ),
              ),
              if (android)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: FilledButton.tonalIcon(
                    onPressed: _busy ? null : () => _run(_service.openClock),
                    icon: const Icon(Icons.open_in_new),
                    label: Text(l10n.alarmOpenClock),
                  ),
                ),
              if (_busy || (_entries == null && _error == null))
                const LinearProgressIndicator(),
              if (_error != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SelectableText(
                      '${l10n.alarmFailed}\n${SystemAlarmService.diagnostic(_error!)}',
                    ),
                  ),
                ),
              if (_entries?.isEmpty ?? false)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 64),
                  child: Column(
                    children: [
                      const Icon(Icons.alarm_off_outlined, size: 48),
                      const SizedBox(height: 16),
                      Text(l10n.alarmManagerEmpty),
                    ],
                  ),
                ),
              for (final entry in _entries ?? <SystemAlarmEntry>[])
                Card(
                  margin: const EdgeInsets.only(top: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.title,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          DateFormat.yMMMd(locale).add_Hm().format(entry.time),
                        ),
                        if (entry.weekly)
                          Text(
                            l10n.alarmWeekly(
                              DateFormat.EEEE(locale).format(entry.time),
                              DateFormat.Hm(locale).format(entry.time),
                            ),
                          ),
                        Text(
                          android
                              ? l10n.alarmExported
                              : !entry.enabled
                              ? l10n.alarmDisabled
                              : entry.time.isAfter(DateTime.now())
                              ? l10n.alarmEnabled
                              : l10n.alarmElapsed,
                        ),
                        if (entry.notes.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(entry.notes),
                          ),
                        // 0x41303 means the task has not run yet, not a failure.
                        if (!android &&
                            entry.lastResult != 0 &&
                            entry.lastResult != 0x41303 &&
                            entry.lastResult != 0x41301)
                          Text(
                            '${l10n.alarmTechnicalDetails}: 0x${(entry.lastResult & 0xffffffff).toRadixString(16)}',
                          ),
                        Wrap(
                          spacing: 8,
                          children: [
                            if (!android && entry.enabled)
                              TextButton.icon(
                                onPressed: _busy
                                    ? null
                                    : () => _run(
                                        () => _service.disable(entry.id),
                                      ),
                                icon: const Icon(Icons.alarm_off),
                                label: Text(l10n.alarmDisable),
                              ),
                            TextButton.icon(
                              onPressed: _busy ? null : () => _remove(entry),
                              icon: const Icon(Icons.delete_outline),
                              label: Text(
                                android ? l10n.alarmForget : l10n.delete,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
