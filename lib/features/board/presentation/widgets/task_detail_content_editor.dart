import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import '../../../../data/task_details/task_detail_document.dart';
import '../../../../data/task_details/task_detail_image.dart';
import '../../../../l10n/app_localizations.dart';
import '../../application/task_image_clipboard.dart';
import '../../application/task_image_viewer.dart';

abstract final class TaskDetailImageLayout {
  static double maximumEditorHeight(BuildContext context) =>
      math.min(720, MediaQuery.sizeOf(context).height * 0.55);

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
    super.key,
  });

  final TaskDetailDocument initialDocument;
  final ValueChanged<TaskDetailDocument> onChanged;

  @override
  ConsumerState<TaskDetailContentEditor> createState() =>
      TaskDetailContentEditorState();
}

class TaskDetailContentEditorState
    extends ConsumerState<TaskDetailContentEditor> {
  late final QuillController _controller;
  late final StreamSubscription<DocChange> _documentChanges;
  final _focusNode = FocusNode();
  final _scrollController = ScrollController();
  final _imagesById = <String, TaskDetailImage>{};
  bool _pasting = false;

  QuillController get controller => _controller;

  TaskDetailDocument get document => TaskDetailDocumentCodec.fromDelta(
    operations: _controller.document.toDelta().toJson().cast<Object?>(),
    images: _imagesById.values.toList(growable: false),
  );

  @override
  void initState() {
    super.initState();
    _imagesById.addEntries(
      widget.initialDocument.images.map((image) => MapEntry(image.id, image)),
    );
    _controller = QuillController(
      document: Document.fromJson(
        TaskDetailDocumentCodec.toDelta(widget.initialDocument),
      ),
      selection: const TextSelection.collapsed(offset: 0),
      onReplaceText: _allowReplacement,
    );
    _documentChanges = _controller.document.changes.listen((_) {
      widget.onChanged(document);
    });
  }

  @override
  void dispose() {
    _documentChanges.cancel();
    _controller.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final defaultStyles = DefaultStyles.getInstance(context);
    final defaultPlaceholderStyle = defaultStyles.placeHolder!;
    final placeholderStyle = defaultPlaceholderStyle.copyWith(
      style: defaultPlaceholderStyle.style.copyWith(fontSize: 12),
    );
    return Semantics(
      label: l10n.taskDetailsSection,
      textField: true,
      child: Container(
        key: const ValueKey('task-detail-content-editor'),
        constraints: const BoxConstraints(minHeight: 144),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLowest,
          border: Border.all(color: scheme.outline),
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: QuillEditor(
          key: const ValueKey('task-details-field'),
          controller: _controller,
          focusNode: _focusNode,
          scrollController: _scrollController,
          config: QuillEditorConfig(
            scrollable: false,
            minHeight: 142,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            placeholder: l10n.taskDetailsHint,
            customStyles: DefaultStyles(placeHolder: placeholderStyle),
            customShortcuts: const {
              SingleActivator(LogicalKeyboardKey.keyV, control: true):
                  _PasteTaskDetailIntent(),
              SingleActivator(LogicalKeyboardKey.keyV, meta: true):
                  _PasteTaskDetailIntent(),
            },
            customActions: {
              _PasteTaskDetailIntent: CallbackAction<Intent>(
                onInvoke: (_) {
                  unawaited(
                    _pasteFromClipboard(
                      showEmptyMessage: false,
                      allowTextFallback: true,
                    ),
                  );
                  return null;
                },
              ),
            },
            embedBuilders: [
              _TaskDetailImageEmbedBuilder(
                imagesById: _imagesById,
                onOpen: _openImage,
                onRemove: _removeImage,
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _allowReplacement(int index, int length, Object? data) {
    try {
      final candidate = Document.fromDelta(_controller.document.toDelta());
      candidate.replace(index, length, data);
      final candidateDocument = TaskDetailDocumentCodec.fromDelta(
        operations: candidate.toDelta().toJson().cast<Object?>(),
        images: _imagesById.values.toList(growable: false),
      );
      return candidateDocument.textLength <=
          TaskDetailDocumentCodec.maximumTextLength;
    } on Object {
      return false;
    }
  }

  Future<void> _pasteFromClipboard({
    required bool showEmptyMessage,
    required bool allowTextFallback,
  }) async {
    if (_pasting) return;
    _setPasting(true);
    final l10n = AppLocalizations.of(context);
    try {
      final pasted = await ref.read(taskImageClipboardProvider).readImages();
      if (!mounted) return;
      if (pasted.isEmpty) {
        if (allowTextFallback) {
          final clipboard = await Clipboard.getData(Clipboard.kTextPlain);
          if (!mounted) return;
          final text = clipboard?.text;
          if (text != null && text.isNotEmpty) {
            _insertText(text);
            return;
          }
        }
        if (showEmptyMessage) _showMessage(l10n.noImageInClipboard);
        return;
      }

      final combined = [...document.images, ...pasted];
      TaskDetailImageCodec.validate(combined);
      _insertImages(pasted);
    } on Object {
      if (mounted) _showMessage(l10n.imagePasteFailed);
    } finally {
      if (mounted) _setPasting(false);
    }
  }

  void _insertText(String text) {
    final selection = _controller.selection;
    final start = math.max(
      0,
      math.min(selection.start, _controller.document.length - 1),
    );
    final end = math.max(
      start,
      math.min(selection.end, _controller.document.length - 1),
    );
    _controller.replaceText(
      start,
      end - start,
      text,
      TextSelection.collapsed(offset: end + text.length),
    );
    _focusNode.requestFocus();
  }

  void _insertImages(List<TaskDetailImage> images) {
    for (final image in images) {
      _imagesById[image.id] = image;
    }

    final selection = _controller.selection;
    final start = math.max(
      0,
      math.min(selection.start, _controller.document.length - 1),
    );
    final end = math.max(
      start,
      math.min(selection.end, _controller.document.length - 1),
    );
    final plainText = _controller.document.toPlainText();
    final replacement = Delta();

    if (start > 0 && plainText[start - 1] != '\n') {
      replacement.insert('\n');
    }
    for (final image in images) {
      replacement
        ..insert(
          BlockEmbed.image(
            TaskDetailDocumentCodec.imageSourceFor(image.id),
          ).toJson(),
        )
        ..insert('\n');
    }

    _controller.replaceText(
      start,
      end - start,
      replacement,
      TextSelection.collapsed(offset: end),
    );
    _focusNode.requestFocus();
  }

  void _removeImage(String imageId, int documentOffset) {
    if (!_imagesById.containsKey(imageId)) return;
    _controller.replaceText(
      documentOffset,
      1,
      '',
      TextSelection.collapsed(offset: documentOffset),
    );
    _imagesById.remove(imageId);
    widget.onChanged(document);
    _focusNode.requestFocus();
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
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

final class _PasteTaskDetailIntent extends Intent {
  const _PasteTaskDetailIntent();
}

final class _TaskDetailImageEmbedBuilder extends EmbedBuilder {
  const _TaskDetailImageEmbedBuilder({
    required this.imagesById,
    required this.onOpen,
    required this.onRemove,
  });

  final Map<String, TaskDetailImage> imagesById;
  final ValueChanged<TaskDetailImage> onOpen;
  final void Function(String imageId, int documentOffset) onRemove;

  @override
  String get key => BlockEmbed.imageType;

  @override
  Widget build(BuildContext context, EmbedContext embedContext) {
    final source = embedContext.node.value.data;
    final imageId = source is String
        ? TaskDetailDocumentCodec.imageIdFromSource(source)
        : null;
    final image = imageId == null ? null : imagesById[imageId];
    if (image == null) {
      return SizedBox(
        height: TaskDetailImageLayout.maximumEditorHeight(context),
        child: const Center(child: Icon(Icons.broken_image_outlined)),
      );
    }

    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final usesDesktopWindow = TaskDetailImageLayout.usesDesktopWindow(
      Theme.of(context).platform,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Stack(
        children: [
          GestureDetector(
            key: ValueKey('task-detail-image-${image.id}'),
            onTap: usesDesktopWindow ? null : () => onOpen(image),
            onDoubleTap: usesDesktopWindow ? () => onOpen(image) : null,
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
                      maxWidth: double.infinity,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: TaskDetailImageLayout.maximumEditorHeight(
                          context,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.memory(
                          image.bytes,
                          width: double.infinity,
                          fit: BoxFit.contain,
                          errorBuilder: (_, _, _) => SizedBox(
                            width: double.infinity,
                            height: TaskDetailImageLayout.maximumEditorHeight(
                              context,
                            ),
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
          ),
          Positioned(
            top: 4,
            right: 4,
            child: IconButton.filledTonal(
              tooltip: l10n.removeImage,
              visualDensity: VisualDensity.compact,
              onPressed: () =>
                  onRemove(image.id, embedContext.node.documentOffset),
              icon: const Icon(Icons.close, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}
