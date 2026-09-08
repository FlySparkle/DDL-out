import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../settings/application/settings.dart';
import '../../application/deadline_preset_store.dart';

class DeadlinePresets extends StatefulWidget {
  const DeadlinePresets({
    required this.mode,
    required this.onRelative,
    required this.onAbsolute,
    super.key,
  });

  final DeadlineMode mode;
  final ValueChanged<int> onRelative;
  final ValueChanged<DateTime> onAbsolute;

  @override
  State<DeadlinePresets> createState() => _DeadlinePresetsState();
}

class _DeadlinePresetsState extends State<DeadlinePresets> {
  final _scroll = ScrollController();
  final _store = DeadlinePresetStore();
  List<DeadlinePreset> _custom = [];
  bool _ready = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final values = await _store.load();
      if (mounted) {
        setState(() {
          _custom = values;
          _ready = true;
        });
      }
    } on Object {
      if (mounted) _showError();
    }
  }

  @override
  void didUpdateWidget(DeadlinePresets oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mode != widget.mode && _scroll.hasClients) _scroll.jumpTo(0);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final relative = widget.mode == DeadlineMode.relative;
    final now = DateTime.now();
    DateTime endOfDay(int offset) =>
        DateTime(now.year, now.month, now.day + offset, 23, 59);
    return Listener(
      onPointerSignal: (event) {
        if (event is PointerScrollEvent &&
            _scroll.hasClients &&
            _scroll.position.maxScrollExtent > 0) {
          GestureBinding.instance.pointerSignalResolver.register(event, (_) {
            final delta = event.scrollDelta.dx != 0
                ? event.scrollDelta.dx
                : event.scrollDelta.dy;
            _scroll.jumpTo(
              (_scroll.offset + delta).clamp(
                0.0,
                _scroll.position.maxScrollExtent,
              ),
            );
          });
        }
      },
      child: SingleChildScrollView(
        key: const ValueKey('deadline-presets'),
        controller: _scroll,
        scrollDirection: Axis.horizontal,
        child: Row(
          spacing: 8,
          children: [
            if (relative)
              for (final entry in const {
                '+1d': 1440,
                '+1h': 60,
                '+15m': 15,
              }.entries)
                ActionChip(
                  label: Text(entry.key),
                  onPressed: () => widget.onRelative(entry.value),
                )
            else ...[
              ActionChip(
                label: Text(l10n.today),
                onPressed: () => widget.onAbsolute(endOfDay(0)),
              ),
              ActionChip(
                label: Text(l10n.tomorrow),
                onPressed: () => widget.onAbsolute(endOfDay(1)),
              ),
              ActionChip(
                label: Text(l10n.thisWeekend),
                onPressed: () =>
                    widget.onAbsolute(endOfDay(DateTime.sunday - now.weekday)),
              ),
            ],
            for (final preset in _custom.where(
              (p) => (p.minutes != null) == relative,
            ))
              InputChip(
                label: Tooltip(
                  message: preset.label,
                  child: Text(relative ? preset.durationLabel : preset.label),
                ),
                onPressed: () => relative
                    ? widget.onRelative(preset.minutes!)
                    : widget.onAbsolute(preset.localDateTime!),
                onDeleted: _saving
                    ? null
                    : () => _persist([..._custom]..remove(preset)),
                deleteButtonTooltipMessage: l10n.delete,
              ),
            IconButton.outlined(
              key: const ValueKey('add-deadline-preset'),
              tooltip: l10n.customDeadlinePreset,
              onPressed: _ready && !_saving ? _add : null,
              icon: const Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }

  void _showError() => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(AppLocalizations.of(context).presetSaveFailed)),
  );

  Future<void> _persist(List<DeadlinePreset> values) async {
    setState(() => _saving = true);
    try {
      await _store.save(values);
      if (mounted) setState(() => _custom = values);
    } on Object {
      if (mounted) _showError();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _add() async {
    final preset = await showDialog<DeadlinePreset>(
      context: context,
      builder: (_) =>
          _PresetDialog(relative: widget.mode == DeadlineMode.relative),
    );
    if (preset != null && mounted) await _persist([..._custom, preset]);
  }
}

class _PresetDialog extends StatefulWidget {
  const _PresetDialog({required this.relative});
  final bool relative;
  @override
  State<_PresetDialog> createState() => _PresetDialogState();
}

class _PresetDialogState extends State<_PresetDialog> {
  final _form = GlobalKey<FormState>();
  final _label = TextEditingController();
  final _numbers = List.generate(3, (_) => TextEditingController(text: '0'));
  DateTime _date = DateTime.now();

  @override
  void dispose() {
    _label.dispose();
    for (final value in _numbers) {
      value.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    return AlertDialog(
      title: Text(l10n.customDeadlinePreset),
      content: SizedBox(
        width: 360,
        child: SingleChildScrollView(
          child: Form(
            key: _form,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _label,
                  maxLength: 40,
                  decoration: InputDecoration(labelText: l10n.presetName),
                  validator: (value) =>
                      value!.trim().isEmpty ? l10n.nameRequired : null,
                ),
                if (widget.relative) ...[
                  Row(
                    spacing: 8,
                    children: [
                      for (var i = 0; i < 3; i++)
                        Expanded(
                          child: TextFormField(
                            controller: _numbers[i],
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(3),
                            ],
                            decoration: InputDecoration(
                              labelText: [
                                l10n.days,
                                l10n.hours,
                                l10n.minutes,
                              ][i],
                            ),
                          ),
                        ),
                    ],
                  ),
                  FormField<int>(
                    validator: (_) => _total > 0 && _total <= 1439999
                        ? null
                        : l10n.presetDurationRequired,
                    builder: (state) => state.hasError
                        ? Text(
                            state.errorText!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ] else ...[
                  OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_today_outlined),
                    label: Text(DateFormat.yMMMd(locale).format(_date)),
                    onPressed: () async {
                      final value = await showDatePicker(
                        context: context,
                        initialDate: _date,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(9999),
                      );
                      if (value != null && mounted) {
                        setState(
                          () => _date = DateTime(
                            value.year,
                            value.month,
                            value.day,
                            _date.hour,
                            _date.minute,
                          ),
                        );
                      }
                    },
                  ),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.schedule),
                    label: Text(DateFormat.Hm(locale).format(_date)),
                    onPressed: () async {
                      final value = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(_date),
                      );
                      if (value != null && mounted) {
                        setState(
                          () => _date = DateTime(
                            _date.year,
                            _date.month,
                            _date.day,
                            value.hour,
                            value.minute,
                          ),
                        );
                      }
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () {
            if (!_form.currentState!.validate()) return;
            Navigator.pop(
              context,
              DeadlinePreset(
                label: _label.text.trim(),
                minutes: widget.relative ? _total : null,
                localDateTime: widget.relative
                    ? null
                    : DateTime(
                        _date.year,
                        _date.month,
                        _date.day,
                        _date.hour,
                        _date.minute,
                      ),
              ),
            );
          },
          child: Text(l10n.save),
        ),
      ],
    );
  }

  int get _total =>
      (int.tryParse(_numbers[0].text) ?? 0) * 1440 +
      (int.tryParse(_numbers[1].text) ?? 0) * 60 +
      (int.tryParse(_numbers[2].text) ?? 0);
}
