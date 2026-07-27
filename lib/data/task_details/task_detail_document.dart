import 'task_detail_image.dart';

sealed class TaskDetailBlock {
  const TaskDetailBlock();
}

final class TaskDetailTextBlock extends TaskDetailBlock {
  const TaskDetailTextBlock(this.text);

  final String text;
}

final class TaskDetailImageBlock extends TaskDetailBlock {
  const TaskDetailImageBlock(this.image);

  final TaskDetailImage image;
}

final class TaskDetailDocument {
  const TaskDetailDocument(this.blocks);

  final List<TaskDetailBlock> blocks;

  List<TaskDetailImage> get images => [
    for (final block in blocks)
      if (block is TaskDetailImageBlock) block.image,
  ];

  int get textLength => blocks.fold(
    0,
    (length, block) =>
        length + (block is TaskDetailTextBlock ? block.text.length : 0),
  );

  bool get isEmpty => blocks.every(
    (block) => block is TaskDetailTextBlock ? block.text.trim().isEmpty : false,
  );
}

abstract final class TaskDetailDocumentCodec {
  static const maximumTextLength = 10000;
  static const _markerPrefix = '\uFFFCddl-out:image:';
  static const _markerSuffix = '\uFFFC';

  static TaskDetailDocument decode({
    required String details,
    required List<TaskDetailImage> images,
  }) {
    final imagesById = {for (final image in images) image.id: image};
    final referencedIds = <String>{};
    final blocks = <TaskDetailBlock>[];
    final textLines = <String>[];

    void flushText() {
      if (textLines.isEmpty) return;
      blocks.add(TaskDetailTextBlock(textLines.join('\n')));
      textLines.clear();
    }

    for (final line in details.split('\n')) {
      final imageId = _imageIdFromMarker(line);
      final image = imageId == null ? null : imagesById[imageId];
      if (image == null || !referencedIds.add(image.id)) {
        textLines.add(line);
        continue;
      }
      flushText();
      blocks.add(TaskDetailImageBlock(image));
    }
    flushText();

    for (final image in images) {
      if (referencedIds.add(image.id)) {
        blocks.add(TaskDetailImageBlock(image));
      }
    }
    if (blocks.isEmpty) blocks.add(const TaskDetailTextBlock(''));
    return TaskDetailDocument(List.unmodifiable(blocks));
  }

  static String encode(TaskDetailDocument document) {
    validate(document);
    return [
      for (final block in document.blocks)
        switch (block) {
          TaskDetailTextBlock() => block.text,
          TaskDetailImageBlock() => _markerFor(block.image.id),
        },
    ].join('\n');
  }

  static void validate(TaskDetailDocument document) {
    if (document.textLength > maximumTextLength) {
      throw const FormatException('Task details text is too long.');
    }
    TaskDetailImageCodec.validate(document.images);
  }

  static String _markerFor(String imageId) =>
      '$_markerPrefix$imageId$_markerSuffix';

  static String? _imageIdFromMarker(String line) {
    if (!line.startsWith(_markerPrefix) || !line.endsWith(_markerSuffix)) {
      return null;
    }
    final id = line.substring(
      _markerPrefix.length,
      line.length - _markerSuffix.length,
    );
    return id.isEmpty ? null : id;
  }
}
