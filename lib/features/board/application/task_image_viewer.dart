import 'dart:convert';
import 'dart:io';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:window_manager/window_manager.dart';

import '../../../data/task_details/task_detail_image.dart';
import '../../../l10n/app_localizations.dart';

const taskImageViewerWindowType = 'task-image-viewer';

final taskImageViewerProvider = Provider<TaskImageViewer>((ref) {
  return const SystemTaskImageViewer();
});

abstract interface class TaskImageViewer {
  Future<void> open(BuildContext context, TaskDetailImage image);
}

final class SystemTaskImageViewer implements TaskImageViewer {
  const SystemTaskImageViewer();

  @override
  Future<void> open(BuildContext context, TaskDetailImage image) async {
    if (!Platform.isWindows && !Platform.isLinux && !Platform.isMacOS) {
      await showDialog<void>(
        context: context,
        builder: (_) => Dialog.fullscreen(
          child: TaskImageViewerPane(
            bytes: image.bytes,
            onClose: () => Navigator.pop(context),
          ),
        ),
      );
      return;
    }

    final directory = Directory(
      '${Directory.systemTemp.path}${Platform.pathSeparator}'
      'ddl_out_image_viewer',
    );
    await directory.create(recursive: true);
    final extension = _extensionForMimeType(image.mimeType);
    final file = File(
      '${directory.path}${Platform.pathSeparator}'
      '${const Uuid().v4()}.$extension',
    );
    await file.writeAsBytes(image.bytes, flush: true);

    try {
      final controller = await WindowController.create(
        WindowConfiguration(
          hiddenAtLaunch: true,
          arguments: jsonEncode({
            'type': taskImageViewerWindowType,
            'path': file.path,
          }),
        ),
      );
      await controller.show();
    } on Object {
      if (await file.exists()) await file.delete();
      rethrow;
    }
  }

  static String _extensionForMimeType(String mimeType) => switch (mimeType) {
    'image/jpeg' => 'jpg',
    'image/gif' => 'gif',
    'image/webp' => 'webp',
    'image/bmp' => 'bmp',
    _ => 'png',
  };
}

final class TaskImageViewerLaunch {
  const TaskImageViewerLaunch({required this.path});

  final String path;

  static TaskImageViewerLaunch? tryParse(String arguments) {
    if (arguments.isEmpty) return null;
    try {
      final decoded = jsonDecode(arguments);
      if (decoded is! Map) return null;
      final values = Map<String, Object?>.from(decoded);
      if (values['type'] != taskImageViewerWindowType) return null;
      final path = values['path'];
      if (path is! String || path.isEmpty) return null;
      return TaskImageViewerLaunch(path: path);
    } on FormatException {
      return null;
    }
  }

  Future<Uint8List> readAndDelete() async {
    final file = File(path);
    final bytes = await file.readAsBytes();
    try {
      await file.delete();
    } on FileSystemException {
      // The viewer already owns the bytes; a later temp cleanup may remove it.
    }
    return bytes;
  }
}

class TaskImageViewerApp extends StatelessWidget {
  const TaskImageViewerApp({required this.bytes, super.key});

  final Uint8List bytes;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) =>
          'DDL out! · ${AppLocalizations.of(context).imageViewerTitle}',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: const Color(0xFF287FF0),
      ),
      home: Scaffold(
        backgroundColor: Colors.black,
        body: TaskImageViewerPane(
          bytes: bytes,
          onClose: () => windowManager.close(),
        ),
      ),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}

class TaskImageViewerPane extends StatefulWidget {
  const TaskImageViewerPane({
    required this.bytes,
    required this.onClose,
    super.key,
  });

  final Uint8List bytes;
  final VoidCallback onClose;

  @override
  State<TaskImageViewerPane> createState() => _TaskImageViewerPaneState();
}

class _TaskImageViewerPaneState extends State<TaskImageViewerPane> {
  final _transformationController = TransformationController();
  double _scale = 1;

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): widget.onClose,
      },
      child: Focus(
        autofocus: true,
        child: Stack(
          children: [
            Positioned.fill(
              child: InteractiveViewer(
                key: const ValueKey('task-image-interactive-viewer'),
                transformationController: _transformationController,
                boundaryMargin: const EdgeInsets.all(240),
                minScale: 0.1,
                maxScale: 8,
                trackpadScrollCausesScale: true,
                onInteractionUpdate: (_) => setState(
                  () => _scale = _transformationController.value
                      .getMaxScaleOnAxis()
                      .clamp(0.1, 8),
                ),
                child: Center(
                  child: Image.memory(
                    widget.bytes,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) =>
                        const Icon(Icons.broken_image_outlined, size: 64),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Center(
                child: Material(
                  color: const Color(0xCC202124),
                  borderRadius: BorderRadius.circular(28),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: l10n.zoomOut,
                        onPressed: () => _setScale(_scale / 1.25),
                        icon: const Icon(Icons.remove),
                      ),
                      SizedBox(
                        width: 58,
                        child: Text(
                          '${(_scale * 100).round()}%',
                          textAlign: TextAlign.center,
                        ),
                      ),
                      IconButton(
                        tooltip: l10n.zoomIn,
                        onPressed: () => _setScale(_scale * 1.25),
                        icon: const Icon(Icons.add),
                      ),
                      IconButton(
                        tooltip: l10n.resetZoom,
                        onPressed: () => _setScale(1),
                        icon: const Icon(Icons.center_focus_strong_outlined),
                      ),
                      IconButton(
                        tooltip: l10n.close,
                        onPressed: widget.onClose,
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _setScale(double value) {
    final next = value.clamp(0.1, 8.0);
    _transformationController.value = Matrix4.diagonal3Values(next, next, 1);
    setState(() => _scale = next);
  }
}
