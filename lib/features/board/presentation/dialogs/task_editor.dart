import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/time/deadline_service.dart';
import '../../../../data/database/app_database.dart';
import '../../../../data/repositories/board_providers.dart';
import '../../../../data/task_details/task_detail_document.dart';
import '../../../../data/task_details/task_detail_image.dart';
import '../../../../core/widgets/destructive_undo_snack_bar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../settings/application/settings.dart';
import '../widgets/task_detail_content_editor.dart';
import '../widgets/deadline_presets.dart';
import '../widgets/task_markdown_preview.dart';
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
  final _detailEditorKey = GlobalKey<TaskDetailContentEditorState>();
  late final TextEditingController _nameController;
  late final TextEditingController _daysController;
  late final TextEditingController _hoursController;
  late final TextEditingController _minutesController;
  late DeadlineMode _mode;
  late DateTime _absoluteLocal;
  late int _categoryValue;
  late bool _relativeDirty;
  late TaskDetailDocument _detailDocument;
  bool _saving = false;
  bool _preview = false;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsControllerProvider);
    _nameController = TextEditingController(text: widget.task?.name ?? '');
    _detailDocument = TaskDetailDocumentCodec.decode(
      details: widget.task?.details ?? '',
      images: _decodeImages(widget.task?.detailImagesJson ?? '[]'),
    );
    _categoryValue =
        widget.task?.categoryId ??
        widget.initialCategoryId ??
        _uncategorizedValue;
    _mode = widget.task == null
        ? settings.deadlineMode
        : widget.task!.deadlineUtc == null
        ? DeadlineMode.none
        : DeadlineMode.absolute;
    _relativeDirty = widget.task == null && _mode == DeadlineMode.relative;

    final now = DateTime.now();
    final initialAbsolute = widget.task?.deadlineUtc?.toLocal() ?? now;
    _absoluteLocal = DateTime(
      initialAbsolute.year,
      initialAbsolute.month,
      initialAbsolute.day,
      initialAbsolute.hour,
      initialAbsolute.minute,
    );
    final remaining = widget.task == null || widget.task!.deadlineUtc == null
        ? const NormalizedDuration(days: 0, hours: 0, minutes: 0)
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
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  l10n.taskDetailsSection,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                if (_preview)
                  IconButton(
                    tooltip: l10n.editMarkdown,
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => setState(() => _preview = false),
                  ),
                TextButton.icon(
                  key: const ValueKey('preview-task-markdown'),
                  icon: Icon(
                    _preview ? Icons.fullscreen : Icons.preview_outlined,
                  ),
                  label: Text(
                    _preview ? l10n.markdownFullscreen : l10n.renderMarkdown,
                  ),
                  onPressed: () {
                    if (_preview) {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          fullscreenDialog: true,
                          builder: (_) => TaskMarkdownPage(
                            title: _nameController.text,
                            document: _detailDocument,
                          ),
                        ),
                      );
                    } else {
                      FocusScope.of(context).unfocus();
                      setState(() {
                        _detailDocument =
                            _detailEditorKey.currentState?.document ??
                            _detailDocument;
                        _preview = true;
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Offstage(
              offstage: _preview,
              child: TaskDetailContentEditor(
                key: _detailEditorKey,
                initialDocument: _detailDocument,
                onChanged: (document) => _detailDocument = document,
              ),
            ),
            if (_preview) TaskMarkdownPreview(document: _detailDocument),
            const SizedBox(height: 12),
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
            if (_mode != DeadlineMode.none) ...[
              DeadlinePresets(
                mode: _mode,
                onRelative: (minutes) => setState(() {
                  final current = _normalizeRelative();
                  _setRelative(
                    DeadlineService.normalize(
                      0,
                      0,
                      current.totalMinutes + minutes,
                    ),
                  );
                  _relativeDirty = true;
                }),
                onAbsolute: _applyQuickDeadline,
              ),
              const SizedBox(height: 12),
            ],
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
                ButtonSegment(
                  value: DeadlineMode.none,
                  label: Text(l10n.noDeadline),
                  icon: const Icon(Icons.all_inclusive),
                ),
              ],
              selected: {_mode},
              onSelectionChanged: (selection) => _switchMode(selection.single),
            ),
            const SizedBox(height: 16),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: switch (_mode) {
                DeadlineMode.relative => _relativeFields(l10n),
                DeadlineMode.absolute => _absoluteFields(),
                DeadlineMode.none => _noDeadlineFields(l10n),
              },
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

  Widget _noDeadlineFields(AppLocalizations l10n) {
    return Container(
      key: const ValueKey('no-deadline'),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(l10n.noDeadlineSubtitle),
    );
  }

  void _switchMode(DeadlineMode next) {
    if (_mode == next) return;
    setState(() {
      if (next == DeadlineMode.absolute) {
        if (_mode == DeadlineMode.relative && _relativeDirty) {
          final value = _normalizeRelative();
          _absoluteLocal = DateTime.now().add(
            Duration(minutes: value.totalMinutes),
          );
          _relativeDirty = false;
        }
      } else if (next == DeadlineMode.relative &&
          _mode == DeadlineMode.absolute) {
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
    final deadline = _mode == DeadlineMode.none
        ? null
        : DeadlineService.resolveUtc(
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
    final detailDocument =
        _detailEditorKey.currentState?.document ?? _detailDocument;
    TaskDetailDocumentCodec.validate(detailDocument);
    final encodedDetails = TaskDetailDocumentCodec.encode(detailDocument);
    final encodedImages = TaskDetailImageCodec.encode(detailDocument.images);
    if (widget.task == null) {
      await repository.create(
        name: _nameController.text.trim(),
        details: encodedDetails,
        detailImagesJson: encodedImages,
        deadlineUtc: deadline,
        categoryId: categoryId,
      );
    } else {
      await repository.update(
        task: widget.task!,
        name: _nameController.text.trim(),
        details: encodedDetails,
        detailImagesJson: encodedImages,
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

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context);
    final taskId = widget.task!.id;
    final repository = ref.read(taskRepositoryProvider);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final confirmed = await showConfirmation(
      context,
      title: l10n.deleteTaskTitle,
      body: l10n.deleteTaskBody,
      destructive: true,
      confirmLabel: l10n.deleteTaskConfirm,
    );
    if (!confirmed || !mounted) return;
    await repository.delete(taskId);
    if (!mounted) return;
    navigator.pop();
    showDestructiveUndoSnackBar(
      messenger: messenger,
      message: l10n.taskDeleted,
      undoLabel: l10n.undoCountdown,
      onUndo: () => repository.restore(taskId),
    );
  }
}
