import 'dart:convert';

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
  const TaskDetailDocument(this.blocks, {this.deltaOperations});

  final List<TaskDetailBlock> blocks;
  final List<Object?>? deltaOperations;

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
  static const maximumEncodedLength = 50000;
  static const format = 'quill-delta-v1';
  static const imageSourcePrefix = 'ddlout-image://';

  static const _markerPrefix = '\uFFFCddl-out:image:';
  static const _markerSuffix = '\uFFFC';

  static TaskDetailDocument decode({
    required String details,
    required List<TaskDetailImage> images,
  }) {
    final delta = _tryDecodeDelta(details);
    if (delta != null) {
      return fromDelta(operations: delta, images: images);
    }
    return _decodeLegacy(details: details, images: images);
  }

  static TaskDetailDocument fromDelta({
    required List<Object?> operations,
    required List<TaskDetailImage> images,
  }) {
    final normalized = _normalizeOperations(operations);
    final imagesById = {for (final image in images) image.id: image};
    final blocks = <TaskDetailBlock>[];
    final text = StringBuffer();
    var skipStructuralNewline = false;

    void flushText({bool beforeImage = false, bool atEnd = false}) {
      var value = text.toString();
      text.clear();
      if (beforeImage && value.endsWith('\n')) {
        value = value.substring(0, value.length - 1);
      }
      if (atEnd && value.endsWith('\n')) {
        value = value.substring(0, value.length - 1);
      }
      if (value.isNotEmpty) blocks.add(TaskDetailTextBlock(value));
    }

    for (final operation in normalized) {
      final insert = operation['insert'];
      if (insert is String) {
        var value = insert;
        if (skipStructuralNewline && value.startsWith('\n')) {
          value = value.substring(1);
        }
        skipStructuralNewline = false;
        text.write(value);
        continue;
      }

      final imageId = _imageIdFromInsert(insert);
      if (imageId == null) continue;
      final image = imagesById[imageId];
      if (image == null) continue;
      flushText(beforeImage: true);
      blocks.add(TaskDetailImageBlock(image));
      skipStructuralNewline = true;
    }
    flushText(atEnd: true);

    if (blocks.isEmpty) blocks.add(const TaskDetailTextBlock(''));
    final document = TaskDetailDocument(
      List.unmodifiable(blocks),
      deltaOperations: List.unmodifiable(normalized),
    );
    validate(document);
    return document;
  }

  static List<Object?> toDelta(TaskDetailDocument document) {
    validate(document);
    final operations = document.deltaOperations;
    if (operations != null) {
      final imageIds = document.images.map((image) => image.id).toSet();
      return _normalizeOperations(operations)
          .where((operation) {
            final insert = operation['insert'];
            return insert is String ||
                imageIds.contains(_imageIdFromInsert(insert));
          })
          .cast<Object?>()
          .toList(growable: false);
    }

    final result = <Object?>[];
    final text = StringBuffer();

    void flushText() {
      if (text.isEmpty) return;
      result.add(<String, Object?>{'insert': text.toString()});
      text.clear();
    }

    for (final block in document.blocks) {
      switch (block) {
        case TaskDetailTextBlock():
          text.write(block.text);
        case TaskDetailImageBlock():
          if (text.isNotEmpty && !text.toString().endsWith('\n')) {
            text.write('\n');
          }
          flushText();
          result.add(<String, Object?>{
            'insert': <String, Object?>{
              'image': imageSourceFor(block.image.id),
            },
          });
          text.write('\n');
      }
    }
    if (text.isEmpty || !text.toString().endsWith('\n')) text.write('\n');
    flushText();
    return _normalizeOperations(result);
  }

  static String encode(TaskDetailDocument document) {
    final encoded = jsonEncode(<String, Object?>{
      'format': format,
      'ops': toDelta(document),
    });
    if (encoded.length > maximumEncodedLength) {
      throw const FormatException('Task details document is too large.');
    }
    return encoded;
  }

  static void validate(TaskDetailDocument document) {
    if (document.textLength > maximumTextLength) {
      throw const FormatException('Task details text is too long.');
    }
    TaskDetailImageCodec.validate(document.images);
  }

  static String imageSourceFor(String imageId) => '$imageSourcePrefix$imageId';

  static String? imageIdFromSource(String source) {
    if (!source.startsWith(imageSourcePrefix)) return null;
    final id = source.substring(imageSourcePrefix.length);
    return id.isEmpty ? null : id;
  }

  static TaskDetailDocument _decodeLegacy({
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
    final document = TaskDetailDocument(List.unmodifiable(blocks));
    validate(document);
    return document;
  }

  static List<Object?>? _tryDecodeDelta(String details) {
    if (details.isEmpty || !details.startsWith('{')) return null;
    try {
      final decoded = jsonDecode(details);
      if (decoded is! Map || decoded['format'] != format) return null;
      final operations = decoded['ops'];
      if (operations is! List) {
        throw const FormatException('Task detail delta is missing.');
      }
      return operations.cast<Object?>();
    } on FormatException {
      rethrow;
    } on Object {
      return null;
    }
  }

  static List<Map<String, Object?>> _normalizeOperations(
    List<Object?> operations,
  ) {
    final normalized = <Map<String, Object?>>[];
    var textLength = 0;

    for (final value in operations) {
      if (value is! Map) {
        throw const FormatException('Task detail delta operation is invalid.');
      }
      final operation = Map<String, Object?>.from(value);
      if (!operation.containsKey('insert') ||
          operation.containsKey('delete') ||
          operation.containsKey('retain')) {
        throw const FormatException('Task detail delta operation is invalid.');
      }

      final insert = operation['insert'];
      if (insert is String) {
        textLength += insert.length;
      } else if (_imageIdFromInsert(insert) == null) {
        throw const FormatException('Task detail embed is invalid.');
      }
      final attributes = operation['attributes'];
      if (attributes != null && attributes is! Map) {
        throw const FormatException('Task detail attributes are invalid.');
      }
      normalized.add(operation);
    }

    if (normalized.isEmpty) {
      normalized.add(<String, Object?>{'insert': '\n'});
    } else {
      final lastInsert = normalized.last['insert'];
      if (lastInsert is! String || !lastInsert.endsWith('\n')) {
        normalized.add(<String, Object?>{'insert': '\n'});
      }
    }
    if (textLength > maximumTextLength + 1) {
      throw const FormatException('Task details text is too long.');
    }
    return normalized;
  }

  static String? _imageIdFromInsert(Object? insert) {
    if (insert is! Map || insert.length != 1) return null;
    final source = insert['image'];
    return source is String ? imageIdFromSource(source) : null;
  }

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
