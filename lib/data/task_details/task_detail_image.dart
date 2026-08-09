import 'dart:convert';
import 'dart:typed_data';

final class TaskDetailImage {
  TaskDetailImage({
    required this.id,
    required this.mimeType,
    required Uint8List bytes,
    this.fileName,
  }) : bytes = Uint8List.fromList(bytes);

  final String id;
  final String mimeType;
  final Uint8List bytes;
  final String? fileName;

  Map<String, Object?> toJson() => {
    'id': id,
    'mimeType': mimeType,
    'base64Data': base64Encode(bytes),
    if (fileName != null) 'fileName': fileName,
  };
}

abstract final class TaskDetailImageCodec {
  static const int maximumImageCount = 12;
  static const int maximumImageBytes = 48 * 1024 * 1024;
  static const int maximumTotalBytes = 144 * 1024 * 1024;

  static const supportedMimeTypes = {
    'image/png',
    'image/jpeg',
    'image/gif',
    'image/webp',
    'image/bmp',
  };

  static String encode(List<TaskDetailImage> images) {
    validate(images);
    return jsonEncode([for (final image in images) image.toJson()]);
  }

  static List<TaskDetailImage> decode(String source) {
    final decoded = jsonDecode(source);
    if (decoded is! List) {
      throw const FormatException('Task detail images must be a JSON list.');
    }
    if (decoded.length > maximumImageCount) {
      throw const FormatException('Too many task detail images.');
    }
    final images = <TaskDetailImage>[];
    for (final value in decoded) {
      if (value is! Map) {
        throw const FormatException('Invalid task detail image.');
      }
      final map = Map<String, Object?>.from(value);
      final id = map['id'];
      final mimeType = map['mimeType'];
      final encoded = map['base64Data'];
      final fileName = map['fileName'];
      if (id is! String ||
          id.isEmpty ||
          id.length > 100 ||
          mimeType is! String ||
          (fileName != null &&
              (fileName is! String || fileName.length > 255)) ||
          encoded is! String ||
          encoded.length > ((maximumImageBytes + 2) ~/ 3) * 4) {
        throw const FormatException('Invalid task detail image fields.');
      }
      Uint8List bytes;
      try {
        bytes = base64Decode(encoded);
      } on FormatException {
        throw const FormatException('Invalid task detail image data.');
      }
      images.add(
        TaskDetailImage(
          id: id,
          mimeType: mimeType,
          bytes: bytes,
          fileName: fileName as String?,
        ),
      );
    }
    validate(images);
    return images;
  }

  static void validate(List<TaskDetailImage> images) {
    if (images.length > maximumImageCount) {
      throw const FormatException('Too many task detail images.');
    }
    final ids = <String>{};
    var totalBytes = 0;
    for (final image in images) {
      if (image.id.isEmpty || image.id.length > 100 || !ids.add(image.id)) {
        throw const FormatException('Invalid task detail image id.');
      }
      if (!supportedMimeTypes.contains(image.mimeType)) {
        throw const FormatException('Unsupported task detail image type.');
      }
      if (image.fileName case final fileName?) {
        if (fileName.isEmpty ||
            fileName.length > 255 ||
            fileName.runes.any((value) => value < 32)) {
          throw const FormatException('Invalid task detail image name.');
        }
      }
      if (image.bytes.isEmpty || image.bytes.length > maximumImageBytes) {
        throw const FormatException('Invalid task detail image size.');
      }
      totalBytes += image.bytes.length;
    }
    if (totalBytes > maximumTotalBytes) {
      throw const FormatException('Task detail images are too large.');
    }
  }

  static String? mimeTypeForPath(String path) {
    final normalized = path.toLowerCase();
    if (normalized.endsWith('.png')) return 'image/png';
    if (normalized.endsWith('.jpg') || normalized.endsWith('.jpeg')) {
      return 'image/jpeg';
    }
    if (normalized.endsWith('.gif')) return 'image/gif';
    if (normalized.endsWith('.webp')) return 'image/webp';
    if (normalized.endsWith('.bmp') || normalized.endsWith('.dib')) {
      return 'image/bmp';
    }
    return null;
  }
}
