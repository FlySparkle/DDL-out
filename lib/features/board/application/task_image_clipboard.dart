import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pasteboard/pasteboard.dart';
import 'package:path/path.dart' as path_utils;
import 'package:uuid/uuid.dart';

import '../../../data/task_details/task_detail_image.dart';

final taskImageClipboardProvider = Provider<TaskImageClipboard>((ref) {
  return const SystemTaskImageClipboard();
});

abstract interface class TaskImageClipboard {
  Future<List<TaskDetailImage>> readImages();
}

final class SystemTaskImageClipboard implements TaskImageClipboard {
  const SystemTaskImageClipboard();

  @override
  Future<List<TaskDetailImage>> readImages() async {
    final fileImages = <TaskDetailImage>[];
    final desktop = Platform.isWindows || Platform.isLinux || Platform.isMacOS;
    if (desktop) {
      for (final path in await Pasteboard.files()) {
        final mimeType = TaskDetailImageCodec.mimeTypeForPath(path);
        if (mimeType == null) continue;
        final file = File(path);
        if (!await file.exists()) continue;
        final bytes = await file.readAsBytes();
        fileImages.add(
          TaskDetailImage(
            id: const Uuid().v4(),
            mimeType: mimeType,
            bytes: bytes,
            fileName: path_utils.basename(path),
          ),
        );
      }
    }
    if (fileImages.isNotEmpty) {
      TaskDetailImageCodec.validate(fileImages);
      return fileImages;
    }

    final bytes = await Pasteboard.image;
    if (bytes == null || bytes.isEmpty) return const [];
    final image = TaskDetailImage(
      id: const Uuid().v4(),
      mimeType: Platform.isWindows ? 'image/bmp' : 'image/png',
      bytes: bytes,
      fileName: Platform.isWindows
          ? 'clipboard-image.bmp'
          : 'clipboard-image.png',
    );
    TaskDetailImageCodec.validate([image]);
    return [image];
  }
}
