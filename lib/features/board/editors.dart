import 'dart:math' as math;

import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/time/deadline_service.dart';
import '../../data/database/app_database.dart';
import '../../data/repositories/repositories.dart';
import '../../data/settings/app_settings.dart';
import '../../l10n/app_localizations.dart';
import 'board_page.dart';

const _presetColors = <Color>[
  Color(0xFF4A90E2),
  Color(0xFF50E3C2),
  Color(0xFF8BC34A),
  Color(0xFFF5A623),
  Color(0xFFFF4D4F),
  Color(0xFF7E57C2),
  Color(0xFFBD10E0),
  Color(0xFF4A4A4A),
];

Future<void> showCategoryEditor(
  BuildContext context,
  WidgetRef ref, {
  Category? category,
  int taskCount = 0,
}) {
  return _showAdaptiveEditor(
    context,
    child: _CategoryEditor(category: category, taskCount: taskCount),
  );
}

Future<void> showTaskEditor(
  BuildContext context,
  WidgetRef ref, {
  required BoardSnapshot snapshot,
  required int? initialCategoryId,
  Task? task,
}) {
  return _showAdaptiveEditor(
    context,
    child: _TaskEditor(
      snapshot: snapshot,
      initialCategoryId: initialCategoryId,
      task: task,
    ),
  );
}

Future<void> _showAdaptiveEditor(
  BuildContext context, {
  required Widget child,
}) async {
  final isAndroid = Theme.of(context).platform == TargetPlatform.android;
  if (isAndroid) {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: child,
      ),
    );
  } else {
    await showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460, maxHeight: 760),
          child: child,
        ),
      ),
    );
  }
}

class _CategoryEditor extends ConsumerStatefulWidget {
  const _CategoryEditor({required this.category, required this.taskCount});

  final Category? category;
  final int taskCount;

  @override
  ConsumerState<_CategoryEditor> createState() => _CategoryEditorState();
}

class _CategoryEditorState extends ConsumerState<_CategoryEditor> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late Color _color;
  bool _showCustom = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _color = Color(
      widget.category?.colorArgb ?? _presetColors.first.toARGB32(),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _EditorFrame(
      title: widget.category == null ? l10n.newCategory : l10n.editCategory,
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _nameController,
              autofocus: true,
              maxLength: 60,
              decoration: InputDecoration(labelText: l10n.categoryName),
              validator: (value) {
                final name = value?.trim() ?? '';
                if (name.isEmpty) return l10n.nameRequired;
                if (name.length > 60) return l10n.nameTooLong;
                return null;
              },
            ),
            const SizedBox(height: 8),
            Text(l10n.categoryColor),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final value in _presetColors)
                  _ColorSwatch(
                    color: value,
                    selected: value.toARGB32() == _color.toARGB32(),
                    onTap: () => setState(() => _color = value),
                  ),
                IconButton.filledTonal(
                  tooltip: l10n.customColor,
                  onPressed: () => setState(() => _showCustom = !_showCustom),
                  icon: const Icon(Icons.colorize),
                ),
              ],
            ),
            if (_showCustom)
              ColorPicker(
                color: _color,
                onColorChanged: (value) => setState(() => _color = value),
                pickersEnabled: const {
                  ColorPickerType.both: false,
                  ColorPickerType.primary: false,
                  ColorPickerType.accent: false,
                  ColorPickerType.bw: false,
                  ColorPickerType.custom: false,
                  ColorPickerType.customSecondary: false,
                  ColorPickerType.wheel: true,
                },
                enableShadesSelection: false,
                showColorCode: true,
                colorCodeHasColor: true,
                wheelDiameter: 180,
                padding: const EdgeInsets.only(top: 16),
              ),
          ],
        ),
      ),
      leadingAction: widget.category == null
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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final repository = ref.read(categoryRepositoryProvider);
    if (widget.category == null) {
      await repository.create(_nameController.text.trim(), _color.toARGB32());
    } else {
      await repository.update(
        widget.category!,
        _nameController.text.trim(),
        _color.toARGB32(),
      );
    }
    if (mounted) Navigator.pop(context);
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showConfirmation(
      context,
      title: l10n.deleteCategoryTitle,
      body: l10n.deleteCategoryBody(widget.taskCount),
      destructive: true,
    );
    if (!confirmed) return;
    await ref.read(categoryRepositoryProvider).delete(widget.category!.id);
    await ref
        .read(settingsControllerProvider.notifier)
        .removeCategoryPreference(widget.category!.id);
    if (mounted) Navigator.pop(context);
  }
}

class _TaskEditor extends ConsumerStatefulWidget {
  const _TaskEditor({
    required this.snapshot,
    required this.initialCategoryId,
    required this.task,
  });

  final BoardSnapshot snapshot;
  final int? initialCategoryId;
  final Task? task;

  @override
  ConsumerState<_TaskEditor> createState() => _TaskEditorState();
}

class _TaskEditorState extends ConsumerState<_TaskEditor> {
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
    return _EditorFrame(
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
                  : _absoluteFields(l10n),
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
        Expanded(child: _numberField(_daysController, l10n.days, 3)),
        const SizedBox(width: 8),
        Expanded(child: _numberField(_hoursController, l10n.hours, 3)),
        const SizedBox(width: 8),
        Expanded(child: _numberField(_minutesController, l10n.minutes, 3)),
      ],
    );
  }

  Widget _numberField(
    TextEditingController controller,
    String suffix,
    int max,
  ) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(max),
      ],
      decoration: InputDecoration(suffixText: suffix),
      onEditingComplete: () {
        _normalizeRelative();
        FocusScope.of(context).nextFocus();
      },
    );
  }

  Widget _absoluteFields(AppLocalizations l10n) {
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
        final value = _durationFromAbsolute(_absoluteLocal);
        _setRelative(value);
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

class _EditorFrame extends StatelessWidget {
  const _EditorFrame({
    required this.title,
    required this.body,
    required this.primaryAction,
    this.leadingAction,
  });

  final String title;
  final Widget body;
  final Widget primaryAction;
  final Widget? leadingAction;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  tooltip: l10n.cancel,
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Flexible(child: SingleChildScrollView(child: body)),
            const SizedBox(height: 16),
            Row(
              children: [
                ?leadingAction,
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(l10n.cancel),
                ),
                const SizedBox(width: 8),
                primaryAction,
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message:
          '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
      child: InkResponse(
        onTap: onTap,
        radius: 24,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: selected
                  ? Theme.of(context).colorScheme.onSurface
                  : Colors.transparent,
              width: 3,
            ),
          ),
          child: selected
              ? Icon(
                  Icons.check,
                  color: DeadlineService.readableForeground(color),
                )
              : null,
        ),
      ),
    );
  }
}
