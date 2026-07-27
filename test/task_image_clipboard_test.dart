import 'dart:io';

import 'package:ddl_out/features/board/application/task_image_clipboard.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('pasteboard');
  late Directory temporaryDirectory;

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'ddl-out-clipboard-test-',
    );
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    if (await temporaryDirectory.exists()) {
      await temporaryDirectory.delete(recursive: true);
    }
  });

  test('reads image files copied from the file manager', () async {
    final file = File(
      '${temporaryDirectory.path}${Platform.pathSeparator}a.png',
    );
    await file.writeAsBytes([1, 2, 3, 4]);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          if (call.method == 'files') return [file.path];
          fail('The bitmap clipboard should not be read when files exist.');
        });

    final images = await const SystemTaskImageClipboard().readImages();

    expect(images, hasLength(1));
    expect(images.single.mimeType, 'image/png');
    expect(images.single.bytes, [1, 2, 3, 4]);
  });

  test('reads a bitmap copied from an image viewer', () async {
    final bytes = Uint8List.fromList([5, 6, 7, 8]);
    final bitmap = File(
      '${temporaryDirectory.path}${Platform.pathSeparator}clipboard.bmp',
    );
    await bitmap.writeAsBytes(bytes);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          if (call.method == 'files') return <String>[];
          if (call.method == 'image') {
            return Platform.isWindows ? bitmap.path : bytes;
          }
          return null;
        });

    final images = await const SystemTaskImageClipboard().readImages();

    expect(images, hasLength(1));
    expect(
      images.single.mimeType,
      Platform.isWindows ? 'image/bmp' : 'image/png',
    );
    expect(images.single.bytes, bytes);
  });
}
