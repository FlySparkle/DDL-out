import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/time/deadline_service.dart';
import '../../../../data/database/app_database.dart';
import '../../../../data/repositories/board_providers.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../settings/application/settings.dart';
import 'adaptive_editor.dart';
import 'confirmation_dialog.dart';
import 'editor_frame.dart';

Future<void> showTaskEditor(
  BuildContext context, {
  required BoardSnapshot snapshot,
  required int? initialCategoryId,
  Task? task,
}) {
  return showAdaptiveEditor(
    context,
    child: TaskEditor(
      snapshot: snapshot,
      initialCategoryId: initialCategoryId,
      task: task,
    ),
  );
}

class TaskEditor extends ConsumerStatefulWidget {
  const TaskEditor({
    required this.snapshot,
    required this.initialCategoryId,
    required this.task,
    super.key,
  });

  final BoardSnapshot snapshot;
  final int? initialCategoryId;
  final Task? task;

  @override
  ConsumerState<TaskEditor> createState() => _TaskEditorState();
}

class _TaskEditorState extends ConsumerState<TaskEditor> {
  static const _uncategorizedValue = -1;

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _daysController;
  late final TextEditingController _hoursController;
  late final TextEditingController _minutesController;
  late DeadlineMode _mode;
  late DateTime _absoluteLocal;
  late int _categoryValue;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsControllerProvider);
    _nameController = TextEditingController(text: widget.task?.name ?? '');
    _categoryValue =
        widget.task?.categoryId ??
        widget.initialCategoryId ??
        _uncategorizedValue;
    _mode = widget.task == null ? settings.deadlineMode : DeadlineMode.absolute;

    final now = DateTime.now();
    final initialAbsolute =
        widget.task?.deadlineUtc.toLocal() ??
        now.add(
          Duration(
            days: settings.relativeDays,
            hours: settings.relativeHours,
            minutes: settings.relativeMinutes,
          ),
        );
    _absoluteLocal = DateTime(
      initialAbsolute.year,
      initialAbsolute.month,
      initialAbsolute.day,
      initialAbsolute.hour,
      initialAbsolute.minute,
    );
    final remaining = widget.task == null
        ? NormalizedDuration(
            days: settings.relativeDays,
            hours: settings.relativeHours,
            minutes: settings.relativeMinutes,
          )
        : _durationFromAbsolute(_absoluteLocal);
    _daysController = TextEditingController(text: remaining.days.toString());
    _hoursController = TextEditingController(text: remaining.hours.toString());
    _minutesController = TextEditingController(
      text: remaining.minutes.toString(),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _daysController.dispose();
    _hoursController.dispose();
    _minutesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return EditorFrame(
      title: widget.task == null ? l10n.newTask : l10n.editTask,
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _nameController,
              autofocus: widget.task == null,
              maxLength: 200,
              decoration: InputDecoration(labelText: l10n.taskName),
              validator: (value) {
                final name = value?.trim() ?? '';
                if (name.isEmpty) return l10n.nameRequired;
                if (name.length > 200) return l10n.nameTooLong;
                return null;
              },
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              initialValue: _categoryValue,
              decoration: InputDecoration(labelText: l10n.taskCategory),
              items: [
                DropdownMenuItem(
                  value: _uncategorizedValue,
                  child: Text(l10n.uncategorized),
                ),
                for (final category in widget.snapshot.categories)
                  DropdownMenuItem(
                    value: category.id,
                    child: Text(category.name, overflow: TextOverflow.ellipsis),
                  ),
              ],
              onChanged: (value) {
                if (value != null) _categoryValue = value;
              },
            ),
            const SizedBox(height: 16),
            SegmentedButton<DeadlineMode>(
              segments: [
                ButtonSegment(
                  value: DeadlineMode.relative,
                  label: Text(l10n.relativeTime),
                  icon: const Icon(Icons.timer_outlined),
                ),
                ButtonSegment(
                  value: DeadlineMode.absolute,
                  label: Text(l10n.absoluteTime),
                  icon: const Icon(Icons.event_outlined),
                ),
              ],
              selected: {_mode},
              onSelectionChanged: (selection) => _switchMode(selection.single),
            ),
            const SizedBox(height: 16),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: _mode == DeadlineMode.relative
                  ? _relativeFields(l10n)
                  : _absoluteFields(),
            ),
          ],
        ),
      ),
      leadingAction: widget.task == null
          ? null
          : TextButton.icon(
              onPressed: _saving ? null : _delete,
              icon: const Icon(Icons.delete_outline),
              label: Text(l10n.delete),
            ),
      primaryAction: FilledButton(
        onPressed: _saving ? null : _save,
        child: Text(l10n.save),
      ),
    );
  }

  Widget _relativeFields(AppLocalizations l10n) {
    return Row(
      key: const ValueKey('relative'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _numberField(_daysController, l10n.days)),
        const SizedBox(width: 8),
        Expanded(child: _numberField(_hoursController, l10n.hours)),
        const SizedBox(width: 8),
        Expanded(child: _numberField(_minutesController, l10n.minutes)),
      ],
    );
  }

  Widget _numberField(TextEditingController controller, String suffix) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(3),
      ],
      decoration: InputDecoration(suffixText: suffix),
      onEditingComplete: () {
        _normalizeRelative();
        FocusScope.of(context).nextFocus();
      },
    );
  }

  Widget _absoluteFields() {
    final locale = Localizations.localeOf(context).toLanguageTag();
    return Row(
      key: const ValueKey('absolute'),
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _pickDate,
            icon: const Icon(Icons.calendar_today_outlined),
            label: Text(DateFormat.yMMMd(locale).format(_absoluteLocal)),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _pickTime,
            icon: const Icon(Icons.schedule),
            label: Text(DateFormat.Hm(locale).format(_absoluteLocal)),
          ),
        ),
      ],
    );
  }

  void _switchMode(DeadlineMode next) {
    if (_mode == next) return;
    setState(() {
      if (next == DeadlineMode.absolute) {
        final value = _normalizeRelative();
        _absoluteLocal = DateTime.now().add(
          Duration(minutes: value.totalMinutes),
        );
      } else {
        _setRelative(_durationFromAbsolute(_absoluteLocal));
      }
      _mode = next;
    });
  }

  NormalizedDuration _normalizeRelative() {
    final value = DeadlineService.normalize(
      int.tryParse(_daysController.text) ?? 0,
      int.tryParse(_hoursController.text) ?? 0,
      int.tryParse(_minutesController.text) ?? 0,
    );
    _setRelative(value);
    return value;
  }

  NormalizedDuration _durationFromAbsolute(DateTime value) {
    final minutes = math.max(0, value.difference(DateTime.now()).inMinutes);
    return DeadlineService.normalize(0, 0, minutes);
  }

  void _setRelative(NormalizedDuration value) {
    _daysController.text = value.days.toString();
    _hoursController.text = value.hours.toString();
    _minutesController.text = value.minutes.toString();
  }

  Future<void> _pickDate() async {
    final value = await showDatePicker(
      context: context,
      initialDate: _absoluteLocal,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365 * 20)),
    );
    if (value == null) return;
    setState(() {
      _absoluteLocal = DateTime(
        value.year,
        value.month,
        value.day,
        _absoluteLocal.hour,
        _absoluteLocal.minute,
      );
    });
  }

  Future<void> _pickTime() async {
    final value = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_absoluteLocal),
    );
    if (value == null) return;
    setState(() {
      _absoluteLocal = DateTime(
        _absoluteLocal.year,
        _absoluteLocal.month,
        _absoluteLocal.day,
        value.hour,
        value.minute,
      );
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final normalized = _normalizeRelative();
    final deadline = DeadlineService.resolveUtc(
      _mode == DeadlineMode.relative
          ? RelativeDeadline(
              days: normalized.days,
              hours: normalized.hours,
              minutes: normalized.minutes,
            )
          : AbsoluteDeadline(_absoluteLocal),
    );
    final categoryId = _categoryValue == _uncategorizedValue
        ? null
        : _categoryValue;
    final repository = ref.read(taskRepositoryProvider);
    if (widget.task == null) {
      await repository.create(
        name: _nameController.text.trim(),
        deadlineUtc: deadline,
        categoryId: categoryId,
      );
    } else {
      await repository.update(
        task: widget.task!,
        name: _nameController.text.trim(),
        deadlineUtc: deadline,
        categoryId: categoryId,
      );
    }
    await ref
        .read(settingsControllerProvider.notifier)
        .rememberDeadline(
          mode: _mode,
          days: normalized.days,
          hours: normalized.hours,
          minutes: normalized.minutes,
        );
    if (mounted) Navigator.pop(context);
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showConfirmation(
      context,
      title: l10n.deleteTaskTitle,
      body: l10n.deleteTaskBody,
      destructive: true,
    );
    if (!confirmed) return;
    await ref.read(taskRepositoryProvider).delete(widget.task!.id);
    if (mounted) Navigator.pop(context);
  }
}
