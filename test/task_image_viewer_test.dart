import 'dart:convert';

import 'package:ddl_out/features/board/application/task_image_viewer.dart';
import 'package:ddl_out/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('viewer launch arguments only accept the image viewer window type', () {
    final valid = TaskImageViewerLaunch.tryParse(
      jsonEncode({
        'type': taskImageViewerWindowType,
        'path': r'C:\Temp\image.png',
      }),
    );

    expect(valid?.path, r'C:\Temp\image.png');
    expect(TaskImageViewerLaunch.tryParse(''), isNull);
    expect(TaskImageViewerLaunch.tryParse('{broken'), isNull);
    expect(
      TaskImageViewerLaunch.tryParse(
        jsonEncode({'type': 'another-window', 'path': 'image.png'}),
      ),
      isNull,
    );
  });

  testWidgets('viewer supports zoom controls, reset, and Escape close', (
    tester,
  ) async {
    var closeCount = 0;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('zh'),
        home: Scaffold(
          body: TaskImageViewerPane(
            bytes: Uint8List.fromList([1, 2, 3]),
            onClose: () => closeCount += 1,
          ),
        ),
      ),
    );
    await tester.pump();

    expect(
      find.byKey(const ValueKey('task-image-interactive-viewer')),
      findsOneWidget,
    );
    expect(find.text('100%'), findsOneWidget);

    await tester.tap(find.byTooltip('放大'));
    await tester.pump();
    expect(find.text('125%'), findsOneWidget);

    await tester.tap(find.byTooltip('恢复原始比例'));
    await tester.pump();
    expect(find.text('100%'), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();
    expect(closeCount, 1);
  });
}
