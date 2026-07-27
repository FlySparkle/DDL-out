import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/time/deadline_service.dart';
import '../../../../data/database/app_database.dart';
import '../../../../data/repositories/board_providers.dart';
import '../../../../data/task_details/task_detail_image.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/task_image_clipboard.dart';
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
  late final TextEditingController _detailsController;
  late final TextEditingController _daysController;
  late final TextEditingController _hoursController;
  late final TextEditingController _minutesController;
  late DeadlineMode _mode;
  late DateTime _absoluteLocal;
  late int _categoryValue;
  late bool _relativeDirty;
  late List<TaskDetailImage> _detailImages;
  bool _saving = false;
  bool _pastingImage = false;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsControllerProvider);
    _nameController = TextEditingController(text: widget.task?.name ?? '');
    _detailsController = TextEditingController(
      text: widget.task?.details ?? '',
    );
    _detailImages = _decodeImages(widget.task?.detailImagesJson ?? '[]');
    _categoryValue =
        widget.task?.categoryId ??
        widget.initialCategoryId ??
        _uncategorizedValue;
    _mode = widget.task == null ? settings.deadlineMode : DeadlineMode.absolute;
    _relativeDirty = widget.task == null && _mode == DeadlineMode.relative;

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
    _detailsController.dispose();
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
            Text(
              l10n.taskTitleSection,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
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
            const Divider(height: 32),
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.taskDetailsSection,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                TextButton.icon(
                  onPressed: _pastingImage
                      ? null
                      : () => _pasteFromClipboard(allowTextFallback: false),
                  icon: _pastingImage
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.content_paste_go_outlined),
                  label: Text(l10n.pasteImage),
                ),
              ],
            ),
            const SizedBox(height: 8),
            CallbackShortcuts(
              bindings: {
                const SingleActivator(
                  LogicalKeyboardKey.keyV,
                  control: true,
                ): () =>
                    _pasteFromClipboard(allowTextFallback: true),
                const SingleActivator(
                  LogicalKeyboardKey.keyV,
                  meta: true,
                ): () =>
                    _pasteFromClipboard(allowTextFallback: true),
              },
              child: TextFormField(
                key: const ValueKey('task-details-field'),
                controller: _detailsController,
                minLines: 4,
                maxLines: 8,
                maxLength: 10000,
                decoration: InputDecoration(
                  hintText: l10n.taskDetailsHint,
                  alignLabelWithHint: true,
                ),
              ),
            ),
            if (_detailImages.isNotEmpty) ...[
              const SizedBox(height: 8),
              Semantics(
                label: l10n.taskDetailImages,
                child: Wrap(
                  key: const ValueKey('task-detail-images'),
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final image in _detailImages)
                      _DetailImageTile(
                        image: image,
                        removeTooltip: l10n.removeImage,
                        onRemove: () => setState(
                          () => _detailImages.removeWhere(
                            (candidate) => candidate.id == image.id,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
            const Divider(height: 32),
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
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ActionChip(
                  avatar: const Icon(Icons.timer_outlined, size: 18),
                  label: Text(l10n.inOneHour),
                  onPressed: () => _applyQuickDeadline(
                    DateTime.now().add(const Duration(hours: 1)),
                  ),
                ),
                ActionChip(
                  label: Text(l10n.today),
                  onPressed: () => _applyQuickDeadline(_endOfDay(0)),
                ),
                ActionChip(
                  label: Text(l10n.tomorrow),
                  onPressed: () => _applyQuickDeadline(_endOfDay(1)),
                ),
                ActionChip(
                  label: Text(l10n.thisWeekend),
                  onPressed: () => _applyQuickDeadline(_endOfThisWeek()),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SegmentedButton<DeadlineMode>(
              key: const ValueKey('deadline-mode'),
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
      onChanged: (_) => _relativeDirty = true,
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
        if (_relativeDirty) {
          final value = _normalizeRelative();
          _absoluteLocal = DateTime.now().add(
            Duration(minutes: value.totalMinutes),
          );
          _relativeDirty = false;
        }
      } else {
        _setRelative(_durationFromAbsolute(_absoluteLocal));
        _relativeDirty = false;
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
      _relativeDirty = false;
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
      _relativeDirty = false;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final normalized = _normalizeRelative();
    final deadline = DeadlineService.resolveUtc(
      _mode == DeadlineMode.relative && _relativeDirty
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
        details: _detailsController.text,
        detailImagesJson: TaskDetailImageCodec.encode(_detailImages),
        deadlineUtc: deadline,
        categoryId: categoryId,
      );
    } else {
      await repository.update(
        task: widget.task!,
        name: _nameController.text.trim(),
        details: _detailsController.text,
        detailImagesJson: TaskDetailImageCodec.encode(_detailImages),
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

  List<TaskDetailImage> _decodeImages(String source) {
    try {
      return TaskDetailImageCodec.decode(source);
    } on FormatException {
      return [];
    }
  }

  Future<void> _pasteFromClipboard({required bool allowTextFallback}) async {
    if (_pastingImage) return;
    setState(() => _pastingImage = true);
    final l10n = AppLocalizations.of(context);
    try {
      final pasted = await ref.read(taskImageClipboardProvider).readImages();
      if (!mounted) return;
      if (pasted.isNotEmpty) {
        final combined = [..._detailImages, ...pasted];
        TaskDetailImageCodec.validate(combined);
        setState(() => _detailImages = combined);
        return;
      }
      if (allowTextFallback) {
        final data = await Clipboard.getData(Clipboard.kTextPlain);
        if (!mounted) return;
        final text = data?.text;
        if (text != null && text.isNotEmpty) {
          _insertDetailText(text);
          return;
        }
      }
      _showMessage(l10n.noImageInClipboard);
    } on Object {
      if (mounted) _showMessage(l10n.imagePasteFailed);
    } finally {
      if (mounted) setState(() => _pastingImage = false);
    }
  }

  void _insertDetailText(String text) {
    final value = _detailsController.value;
    final selection = value.selection.isValid
        ? value.selection
        : TextSelection.collapsed(offset: value.text.length);
    final nextText = value.text.replaceRange(
      selection.start,
      selection.end,
      text,
    );
    final offset = selection.start + text.length;
    _detailsController.value = TextEditingValue(
      text: nextText,
      selection: TextSelection.collapsed(offset: offset),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _applyQuickDeadline(DateTime value) {
    setState(() {
      _absoluteLocal = DateTime(
        value.year,
        value.month,
        value.day,
        value.hour,
        value.minute,
      );
      _setRelative(_durationFromAbsolute(_absoluteLocal));
      _relativeDirty = false;
      _mode = DeadlineMode.absolute;
    });
  }

  DateTime _endOfDay(int daysFromToday) {
    final now = DateTime.now().add(Duration(days: daysFromToday));
    return DateTime(now.year, now.month, now.day, 23, 59);
  }

  DateTime _endOfThisWeek() {
    final now = DateTime.now();
    final daysUntilSunday = DateTime.sunday - now.weekday;
    return DateTime(now.year, now.month, now.day + daysUntilSunday, 23, 59);
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showConfirmation(
      context,
      title: l10n.deleteTaskTitle,
      body: l10n.deleteTaskBody,
      destructive: true,
      confirmLabel: l10n.deleteTaskConfirm,
    );
    if (!confirmed) return;
    await ref.read(taskRepositoryProvider).delete(widget.task!.id);
    if (mounted) Navigator.pop(context);
  }
}

class _DetailImageTile extends StatelessWidget {
  const _DetailImageTile({
    required this.image,
    required this.removeTooltip,
    required this.onRemove,
  });

  final TaskDetailImage image;
  final String removeTooltip;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 132,
      height: 100,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.memory(
              image.bytes,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => ColoredBox(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: const Icon(Icons.broken_image_outlined),
              ),
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: IconButton.filledTonal(
              tooltip: removeTooltip,
              visualDensity: VisualDensity.compact,
              onPressed: onRemove,
              icon: const Icon(Icons.close, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}
