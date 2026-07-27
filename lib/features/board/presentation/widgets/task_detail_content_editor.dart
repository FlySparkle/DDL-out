import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/task_details/task_detail_document.dart';
import '../../../../data/task_details/task_detail_image.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/task_image_clipboard.dart';
import '../../application/task_image_viewer.dart';

abstract final class TaskDetailImageLayout {
  static const maximumEditorLines = 8;
  static const lineHeight = 20.0;
  static const maximumEditorHeight = maximumEditorLines * lineHeight;
  static const maximumCardHeight = 72.0;

  static bool usesDesktopWindow(TargetPlatform platform) => switch (platform) {
    TargetPlatform.windows ||
    TargetPlatform.linux ||
    TargetPlatform.macOS => true,
    _ => false,
  };
}

class TaskDetailContentEditor extends ConsumerStatefulWidget {
  const TaskDetailContentEditor({
    required this.initialDocument,
    required this.onChanged,
    required this.onPastingChanged,
    super.key,
  });

  final TaskDetailDocument initialDocument;
  final ValueChanged<TaskDetailDocument> onChanged;
  final ValueChanged<bool> onPastingChanged;

  @override
  ConsumerState<TaskDetailContentEditor> createState() =>
      TaskDetailContentEditorState();
}

class TaskDetailContentEditorState
    extends ConsumerState<TaskDetailContentEditor> {
  late final List<_DetailEditorEntry> _entries;
  _DetailTextEntry? _activeTextEntry;
  bool _pasting = false;

  TaskDetailDocument get document {
    final blocks = <TaskDetailBlock>[];
    for (final entry in _entries) {
      switch (entry) {
        case _DetailTextEntry():
          if (entry.controller.text.isNotEmpty) {
            blocks.add(TaskDetailTextBlock(entry.controller.text));
          }
        case _DetailImageEntry():
          blocks.add(TaskDetailImageBlock(entry.image));
      }
    }
    if (blocks.isEmpty) blocks.add(const TaskDetailTextBlock(''));
    return TaskDetailDocument(List.unmodifiable(blocks));
  }

  @override
  void initState() {
    super.initState();
    _entries = [];
    for (final block in widget.initialDocument.blocks) {
      switch (block) {
        case TaskDetailTextBlock():
          _entries.add(_createTextEntry(block.text));
        case TaskDetailImageBlock():
          _entries.add(_DetailImageEntry(block.image));
      }
    }
    if (_entries.whereType<_DetailTextEntry>().isEmpty) {
      _entries.add(_createTextEntry(''));
    }
    _activeTextEntry = _entries.whereType<_DetailTextEntry>().first;
  }

  @override
  void dispose() {
    for (final entry in _entries) {
      entry.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: l10n.taskDetailsSection,
      textField: true,
      child: Container(
        key: const ValueKey('task-detail-content-editor'),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLowest,
          border: Border.all(color: scheme.outline),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          key: const ValueKey('task-detail-images'),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var index = 0; index < _entries.length; index++)
              switch (_entries[index]) {
                final _DetailTextEntry entry => _buildTextField(
                  entry,
                  index,
                  l10n,
                ),
                final _DetailImageEntry entry => _buildImageRow(entry, l10n),
              },
          ],
        ),
      ),
    );
  }

  Future<void> pasteImagesOnly() =>
      _pasteFromClipboard(allowTextFallback: false);

  Widget _buildTextField(
    _DetailTextEntry entry,
    int index,
    AppLocalizations l10n,
  ) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyV, control: true): () =>
            _pasteFromClipboard(allowTextFallback: true),
        const SingleActivator(LogicalKeyboardKey.keyV, meta: true): () =>
            _pasteFromClipboard(allowTextFallback: true),
      },
      child: TextField(
        key: index == 0
            ? const ValueKey('task-details-field')
            : ValueKey('task-details-field-$index'),
        controller: entry.controller,
        focusNode: entry.focusNode,
        minLines: 1,
        maxLines: null,
        maxLength: TaskDetailDocumentCodec.maximumTextLength,
        maxLengthEnforcement: MaxLengthEnforcement.enforced,
        buildCounter:
            (_, {required currentLength, required isFocused, maxLength}) =>
                null,
        decoration: InputDecoration(
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 6),
          hintText: _isOnlyEmptyTextEntry(entry) ? l10n.taskDetailsHint : null,
        ),
        onChanged: (value) => _handleTextChanged(entry, value),
      ),
    );
  }

  Widget _buildImageRow(_DetailImageEntry entry, AppLocalizations l10n) {
    final scheme = Theme.of(context).colorScheme;
    final usesDesktopWindow = TaskDetailImageLayout.usesDesktopWindow(
      Theme.of(context).platform,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Stack(
        children: [
          GestureDetector(
            key: ValueKey('task-detail-image-${entry.image.id}'),
            onTap: usesDesktopWindow ? null : () => _openImage(entry.image),
            onDoubleTap: usesDesktopWindow
                ? () => _openImage(entry.image)
                : null,
            child: Tooltip(
              message: usesDesktopWindow
                  ? l10n.openImageDesktop
                  : l10n.openImageMobile,
              child: MouseRegion(
                cursor: usesDesktopWindow
                    ? SystemMouseCursors.zoomIn
                    : MouseCursor.defer,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      minWidth: 120,
                      minHeight: 80,
                      maxWidth: 360,
                      maxHeight: TaskDetailImageLayout.maximumEditorHeight,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.memory(
                        entry.image.bytes,
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => SizedBox(
                          width: 160,
                          height: TaskDetailImageLayout.maximumEditorHeight,
                          child: ColoredBox(
                            color: scheme.surfaceContainerHighest,
                            child: const Icon(Icons.broken_image_outlined),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: IconButton.filledTonal(
              tooltip: l10n.removeImage,
              visualDensity: VisualDensity.compact,
              onPressed: () => _removeImage(entry),
              icon: const Icon(Icons.close, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  _DetailTextEntry _createTextEntry(String text) {
    late final _DetailTextEntry entry;
    entry = _DetailTextEntry(text);
    entry.focusNode.addListener(() {
      if (entry.focusNode.hasFocus) _activeTextEntry = entry;
    });
    return entry;
  }

  bool _isOnlyEmptyTextEntry(_DetailTextEntry entry) =>
      _entries.whereType<_DetailImageEntry>().isEmpty &&
      _entries.whereType<_DetailTextEntry>().length == 1 &&
      entry.controller.text.isEmpty;

  void _handleTextChanged(_DetailTextEntry entry, String value) {
    if (document.textLength > TaskDetailDocumentCodec.maximumTextLength) {
      entry.controller.value = TextEditingValue(
        text: entry.lastValidText,
        selection: TextSelection.collapsed(
          offset: math.min(
            entry.lastValidText.length,
            entry.controller.selection.extentOffset,
          ),
        ),
      );
      return;
    }
    entry.lastValidText = value;
    _notifyChanged();
  }

  Future<void> _pasteFromClipboard({required bool allowTextFallback}) async {
    if (_pasting) return;
    _setPasting(true);
    final l10n = AppLocalizations.of(context);
    try {
      final pasted = await ref.read(taskImageClipboardProvider).readImages();
      if (!mounted) return;
      if (pasted.isNotEmpty) {
        final combined = [...document.images, ...pasted];
        TaskDetailImageCodec.validate(combined);
        _insertImages(pasted);
        return;
      }
      if (allowTextFallback) {
        final data = await Clipboard.getData(Clipboard.kTextPlain);
        if (!mounted) return;
        final text = data?.text;
        if (text != null && text.isNotEmpty) {
          _insertText(text);
          return;
        }
      }
      _showMessage(l10n.noImageInClipboard);
    } on Object {
      if (mounted) _showMessage(l10n.imagePasteFailed);
    } finally {
      if (mounted) _setPasting(false);
    }
  }

  void _insertImages(List<TaskDetailImage> images) {
    final target =
        _activeTextEntry ?? _entries.whereType<_DetailTextEntry>().last;
    final targetIndex = _entries.indexOf(target);
    final value = target.controller.value;
    final selection = value.selection.isValid
        ? value.selection
        : TextSelection.collapsed(offset: value.text.length);
    final start = math.max(0, math.min(selection.start, value.text.length));
    final end = math.max(start, math.min(selection.end, value.text.length));
    final before = value.text.substring(0, start);
    final after = value.text.substring(end);
    target.controller.value = TextEditingValue(
      text: before,
      selection: TextSelection.collapsed(offset: before.length),
    );
    target.lastValidText = before;

    final trailing = _createTextEntry(after);
    _entries.insertAll(targetIndex + 1, [
      for (final image in images) _DetailImageEntry(image),
      trailing,
    ]);
    _activeTextEntry = trailing;
    setState(_notifyChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      trailing.focusNode.requestFocus();
      trailing.controller.selection = const TextSelection.collapsed(offset: 0);
    });
  }

  void _insertText(String text) {
    final target =
        _activeTextEntry ?? _entries.whereType<_DetailTextEntry>().last;
    final value = target.controller.value;
    final selection = value.selection.isValid
        ? value.selection
        : TextSelection.collapsed(offset: value.text.length);
    final start = math.max(0, math.min(selection.start, value.text.length));
    final end = math.max(start, math.min(selection.end, value.text.length));
    final nextText = value.text.replaceRange(start, end, text);
    if (document.textLength - value.text.length + nextText.length >
        TaskDetailDocumentCodec.maximumTextLength) {
      return;
    }
    final offset = start + text.length;
    target.controller.value = TextEditingValue(
      text: nextText,
      selection: TextSelection.collapsed(offset: offset),
    );
    target.lastValidText = nextText;
    _notifyChanged();
  }

  void _removeImage(_DetailImageEntry imageEntry) {
    final index = _entries.indexOf(imageEntry);
    if (index < 0) return;
    _entries.removeAt(index);
    imageEntry.dispose();

    final left = index > 0 ? _entries[index - 1] : null;
    final right = index < _entries.length ? _entries[index] : null;
    if (left is _DetailTextEntry && right is _DetailTextEntry) {
      final leftLength = left.controller.text.length;
      left.controller.text += right.controller.text;
      left.lastValidText = left.controller.text;
      _entries.remove(right);
      right.dispose();
      _activeTextEntry = left;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        left.focusNode.requestFocus();
        left.controller.selection = TextSelection.collapsed(offset: leftLength);
      });
    }
    if (_entries.whereType<_DetailTextEntry>().isEmpty) {
      final empty = _createTextEntry('');
      _entries.add(empty);
      _activeTextEntry = empty;
    }
    setState(_notifyChanged);
  }

  Future<void> _openImage(TaskDetailImage image) async {
    try {
      await ref.read(taskImageViewerProvider).open(context, image);
    } on Object {
      if (mounted) _showMessage(AppLocalizations.of(context).imagePasteFailed);
    }
  }

  void _setPasting(bool value) {
    _pasting = value;
    widget.onPastingChanged(value);
  }

  void _notifyChanged() => widget.onChanged(document);

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

sealed class _DetailEditorEntry {
  const _DetailEditorEntry();

  void dispose() {}
}

final class _DetailTextEntry extends _DetailEditorEntry {
  _DetailTextEntry(String text)
    : controller = TextEditingController(text: text),
      lastValidText = text;

  final TextEditingController controller;
  final FocusNode focusNode = FocusNode();
  String lastValidText;

  @override
  void dispose() {
    controller.dispose();
    focusNode.dispose();
  }
}

final class _DetailImageEntry extends _DetailEditorEntry {
  const _DetailImageEntry(this.image);

  final TaskDetailImage image;
}
