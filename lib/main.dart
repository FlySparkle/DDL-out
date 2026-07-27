import 'dart:io';
import 'dart:typed_data';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

import 'app/app.dart';
import 'core/licenses/app_licenses.dart';
import 'features/board/application/task_image_viewer.dart';

Future<void> main(List<String> arguments) async {
  WidgetsFlutterBinding.ensureInitialized();
  registerAppLicenses();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await windowManager.ensureInitialized();
    final currentWindow = await WindowController.fromCurrentEngine();
    final viewerLaunch = TaskImageViewerLaunch.tryParse(
      currentWindow.arguments,
    );
    if (viewerLaunch != null) {
      Uint8List bytes;
      try {
        bytes = await viewerLaunch.readAndDelete();
      } on FileSystemException {
        bytes = Uint8List(0);
      }
      const viewerOptions = WindowOptions(
        size: Size(920, 720),
        minimumSize: Size(360, 300),
        center: true,
        title: 'DDL out! · Image viewer',
      );
      final ready = windowManager.waitUntilReadyToShow(viewerOptions, () async {
        await windowManager.show();
        await windowManager.focus();
      });
      runApp(TaskImageViewerApp(bytes: bytes));
      await ready;
      return;
    }

    const options = WindowOptions(
      size: Size(540, 960),
      minimumSize: Size(360, 480),
      center: true,
      title: 'DDL out!',
    );
    await windowManager.waitUntilReadyToShow(options, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  runApp(const ProviderScope(child: DdlOutApp()));
}
