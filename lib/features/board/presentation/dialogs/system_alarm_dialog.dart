import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../../core/alarms/system_alarm_service.dart';
import '../../../../l10n/app_localizations.dart';

Future<void> showSystemAlarmDialog(
  BuildContext context, {
  required String title,
  required String notes,
  required DateTime time,
}) => showDialog<void>(
  context: context,
  barrierDismissible: false,
  builder: (_) => _SystemAlarmDialog(title: title, notes: notes, time: time),
);

class _SystemAlarmDialog extends StatefulWidget {
  const _SystemAlarmDialog({
    required this.title,
    required this.notes,
    required this.time,
  });
  final String title;
  final String notes;
  final DateTime time;
  @override
  State<_SystemAlarmDialog> createState() => _SystemAlarmDialogState();
}

class _SystemAlarmDialogState extends State<_SystemAlarmDialog> {
  final _form = GlobalKey<FormState>();
  late final _title = TextEditingController(text: widget.title);
  late final _notes = TextEditingController(
    text: widget.notes.length > 1000
        ? widget.notes.substring(0, 1000)
        : widget.notes,
  );
  final _interval = TextEditingController(text: '3');
  final _repeats = TextEditingController(text: '3');
  late DateTime _time = widget.time;
  bool _multiple = false;
  bool _before = true;
  bool _busy = false;
  String? _error;
  String? _receipt;

  @override
  void dispose() {
    _title.dispose();
    _notes.dispose();
    _interval.dispose();
    _repeats.dispose();
    super.dispose();
  }

  SystemAlarmPlan get _plan => SystemAlarmPlan(
    time: _time,
    multiple: _multiple,
    before: _before,
    intervalMinutes: (int.tryParse(_interval.text) ?? 3).clamp(1, 9999),
    repeats: (int.tryParse(_repeats.text) ?? 3).clamp(
      1,
      SystemAlarmService.maxRepeats,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final times = _plan.times;
    return PopScope(
      canPop: !_busy,
      child: AlertDialog(
        icon: const Icon(Icons.alarm_add_outlined),
        title: Text(l10n.addSystemAlarm),
        content: SizedBox(
          width: 460,
          child: SingleChildScrollView(
            child: Form(
              key: _form,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colors.secondaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      SystemAlarmService.usesAndroidClock
                          ? l10n.alarmAndroidInfo
                          : l10n.alarmWindowsInfo,
                      style: TextStyle(color: colors.onSecondaryContainer),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _title,
                    enabled: !_busy && _receipt == null,
                    maxLength: 200,
                    decoration: InputDecoration(
                      labelText: l10n.alarmTitle,
                      prefixIcon: const Icon(Icons.label_outline),
                    ),
                    validator: (value) =>
                        value!.trim().isEmpty ? l10n.nameRequired : null,
                  ),
                  TextFormField(
                    controller: _notes,
                    enabled: !_busy && _receipt == null,
                    minLines: 2,
                    maxLines: 4,
                    maxLength: 1000,
                    decoration: InputDecoration(
                      labelText: l10n.alarmNotes,
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton.icon(
                        icon: const Icon(Icons.calendar_today_outlined),
                        label: Text(DateFormat.yMMMd(locale).format(_time)),
                        onPressed: _busy || _receipt != null
                            ? null
                            : () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: _time,
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(9999),
                                );
                                if (date != null && mounted)
                                  setState(() {
                                    _time = DateTime(
                                      date.year,
                                      date.month,
                                      date.day,
                                      _time.hour,
                                      _time.minute,
                                    );
                                    _error = null;
                                  });
                              },
                      ),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.schedule),
                        label: Text(DateFormat.Hm(locale).format(_time)),
                        onPressed: _busy || _receipt != null
                            ? null
                            : () async {
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.fromDateTime(_time),
                                );
                                if (time != null && mounted)
                                  setState(() {
                                    _time = DateTime(
                                      _time.year,
                                      _time.month,
                                      _time.day,
                                      time.hour,
                                      time.minute,
                                    );
                                    _error = null;
                                  });
                              },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.alarmPreview(times.length),
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    constraints: const BoxConstraints(maxHeight: 150),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: times.length,
                      itemBuilder: (_, index) => Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              index ==
                                      (_before && _multiple
                                          ? times.length - 1
                                          : 0)
                                  ? Icons.alarm
                                  : Icons.notifications_active_outlined,
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                DateFormat.yMMMd(
                                  locale,
                                ).add_Hm().format(times[index]),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: _busy || _receipt != null
                        ? null
                        : () => setState(() {
                            _multiple = !_multiple;
                            _error = null;
                          }),
                    icon: Icon(
                      _multiple ? Icons.check_circle_outline : Icons.add_alarm,
                    ),
                    label: Text(l10n.multipleAlarms),
                  ),
                  if (_multiple)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 12,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(l10n.alarmRelativeTo),
                          DropdownButton<bool>(
                            value: _before,
                            borderRadius: BorderRadius.circular(12),
                            items: [
                              DropdownMenuItem(
                                value: true,
                                child: Text(l10n.alarmBefore),
                              ),
                              DropdownMenuItem(
                                value: false,
                                child: Text(l10n.alarmAfter),
                              ),
                            ],
                            onChanged: _busy || _receipt != null
                                ? null
                                : (value) => setState(() {
                                    _before = value!;
                                    _error = null;
                                  }),
                          ),
                          Text(l10n.alarmInterval),
                          _number(_interval, 9999, l10n.minutes),
                          Text(l10n.alarmRepeat),
                          _number(
                            _repeats,
                            SystemAlarmService.maxRepeats,
                            l10n.alarmTimes,
                          ),
                        ],
                      ),
                    ),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        _error!,
                        style: TextStyle(color: colors.error),
                      ),
                    ),
                  if (_receipt != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        _receipt!,
                        style: TextStyle(color: colors.primary),
                      ),
                    ),
                  if (_busy)
                    const Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: LinearProgressIndicator(),
                    ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _busy ? null : () => Navigator.pop(context),
            child: Text(_receipt == null ? l10n.cancel : l10n.alarmDone),
          ),
          if (_receipt == null)
            FilledButton.icon(
              onPressed: _busy ? null : _submit,
              icon: const Icon(Icons.alarm_add_outlined),
              label: Text(l10n.alarmConfirm),
            ),
        ],
      ),
    );
  }

  Widget _number(TextEditingController controller, int max, String suffix) {
    final l10n = AppLocalizations.of(context);
    return SizedBox(
      width: 116,
      child: TextFormField(
        controller: controller,
        enabled: !_busy && _receipt == null,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(max.toString().length),
        ],
        decoration: InputDecoration(
          suffixText: suffix,
          helperText: '1–$max',
          isDense: true,
        ),
        onChanged: (_) => setState(() => _error = null),
        validator: (value) {
          final number = int.tryParse(value ?? '');
          return number == null || number < 1 || number > max
              ? l10n.alarmInvalidNumber
              : null;
        },
      ),
    );
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context);
    final times = _plan.times;
    final now = DateTime.now();
    if (times.any((time) => !time.isAfter(now))) {
      setState(() => _error = l10n.alarmPastTime);
      return;
    }
    if (SystemAlarmService.usesAndroidClock &&
        times.any(
          (time) => !SystemAlarmPlan.isNextClockOccurrence(time, now),
        )) {
      setState(() => _error = l10n.alarmClockDateUnsupported);
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final count = await SystemAlarmService().submit(
        title: _title.text,
        notes: _notes.text,
        times: times,
      );
      if (mounted)
        setState(
          () => _receipt = SystemAlarmService.usesAndroidClock
              ? l10n.alarmClockSubmitted(count)
              : l10n.alarmScheduled(count),
        );
    } on PlatformException catch (error) {
      if (mounted)
        setState(() {
          _error = switch (error.code) {
            'clock_unavailable' => l10n.alarmClockUnavailable,
            'date_unsupported' => l10n.alarmClockDateUnsupported,
            'past_time' => l10n.alarmPastTime,
            'notifications_disabled' => l10n.alarmNotificationsDisabled,
            _ => l10n.alarmFailed,
          };
          final details = error.details;
          if (details is int && details > 0)
            _receipt = l10n.alarmPartial(details);
        });
    } on Object {
      if (mounted) setState(() => _error = l10n.alarmFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
