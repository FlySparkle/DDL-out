import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

import '../../../data/task_details/task_detail_image.dart';

abstract interface class TaskImagePicker {
  Future<List<TaskDetailImage>> pickImages();
}

final taskImagePickerProvider = Provider<TaskImagePicker>(
  (_) => PlatformTaskImagePicker(ImagePicker()),
);

final class PlatformTaskImagePicker implements TaskImagePicker {
  PlatformTaskImagePicker(this._picker);

  final ImagePicker _picker;
  final _uuid = const Uuid();

  @override
  Future<List<TaskDetailImage>> pickImages() async {
    final files = await _picker.pickMultiImage(requestFullMetadata: false);
    final images = <TaskDetailImage>[];
    for (final file in files) {
      final bytes = Uint8List.fromList(await file.readAsBytes());
      final mimeType =
          file.mimeType ?? TaskDetailImageCodec.mimeTypeForPath(file.path);
      if (mimeType == null ||
          !TaskDetailImageCodec.supportedMimeTypes.contains(mimeType)) {
        throw const FormatException('Unsupported image type.');
      }
      images.add(
        TaskDetailImage(
          id: _uuid.v4(),
          mimeType: mimeType,
          bytes: bytes,
          fileName: path.basename(file.name),
        ),
      );
    }
    return images;
  }
}
