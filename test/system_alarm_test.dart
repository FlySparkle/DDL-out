import 'package:ddl_out/core/alarms/system_alarm_service.dart';
import 'package:ddl_out/features/alarms/alarm_management_page.dart';
import 'package:ddl_out/features/alarms/alarm_window.dart';
import 'package:ddl_out/features/board/presentation/dialogs/system_alarm_dialog.dart';
import 'package:ddl_out/features/board/presentation/dialogs/adaptive_editor.dart';
import 'package:ddl_out/features/board/presentation/dialogs/editor_frame.dart';
import 'package:ddl_out/l10n/app_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('ddl_out/system_alarms');
  final calls = <MethodCall>[];
  final time = DateTime.now().add(const Duration(days: 30));
  Map<String, Object> record() => {
    'id': '{12345678-1234-1234-1234-123456789012}',
    'title': 'Native alarm',
    'notes': 'Notes',
    'enabled': true,
    'weekly': false,
    'time': time.millisecondsSinceEpoch,
  };
  Widget app(Widget child) => MaterialApp(
    locale: const Locale('en'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: child,
  );
  setUp(() {
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          if (call.method == 'list') return [record()];
          if (call.method == 'schedule') return 1;
          return null;
        });
  });
  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test(
    'multi-alarm offsets cross date/year boundaries before weekly conversion',
    () {
      final times = SystemAlarmPlan(
        time: DateTime(2027, 1, 1, 0, 5),
        multiple: true,
        before: true,
        intervalMinutes: 10,
        repeats: 2,
      ).times;
      expect(times, [
        DateTime(2026, 12, 31, 23, 45),
        DateTime(2026, 12, 31, 23, 55),
        DateTime(2027, 1, 1, 0, 5),
      ]);
      expect(times.map((t) => t.weekday), [
        DateTime.thursday,
        DateTime.thursday,
        DateTime.friday,
      ]);
    },
  );
  test('only the next local occurrence is a one-time Clock alarm', () {
    final now = DateTime(2026, 12, 31, 23, 50);
    expect(
      SystemAlarmPlan.isNextClockOccurrence(DateTime(2027, 1, 1, 0, 5), now),
      isTrue,
    );
    expect(
      SystemAlarmPlan.isNextClockOccurrence(DateTime(2027, 1, 8, 0, 5), now),
      isFalse,
    );
    expect(
      SystemAlarmPlan.isNextClockOccurrence(
        DateTime(2026, 12, 31, 23, 49),
        now,
      ),
      isFalse,
    );
  });
  test('native errors retain operation stage, HRESULT and system message', () {
    final message = SystemAlarmService.diagnostic(
      PlatformException(
        code: 'scheduler_failed',
        message: 'Access denied',
        details: {'stage': 'register_task', 'hresult': '0x80070005'},
      ),
    );
    expect(message, contains('register_task'));
    expect(message, contains('0x80070005'));
    expect(message, contains('Access denied'));
  });
  test(
    'submission keeps full UTC timestamp for arbitrary future dates',
    () async {
      await SystemAlarmService().submit(
        title: ' Future ',
        notes: ' notes ',
        times: [time],
      );
      expect(calls.single.arguments['times'], [
        time.toUtc().millisecondsSinceEpoch,
      ]);
      expect(calls.single.arguments['title'], 'Future');
    },
  );
  testWidgets(
    'manager lists alarms and requires confirmation before deletion',
    (tester) async {
      await tester.pumpWidget(app(const AlarmManagementPage()));
      await tester.pumpAndSettle();
      expect(find.text('Native alarm'), findsOneWidget);
      await tester.tap(find.widgetWithText(TextButton, 'Delete'));
      await tester.pumpAndSettle();
      expect(calls.where((c) => c.method == 'delete'), isEmpty);
      await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
      await tester.pumpAndSettle();
      expect(calls.where((c) => c.method == 'delete').length, 1);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.windows),
  );
  testWidgets(
    'Android manager distinguishes record removal from system deletion',
    (tester) async {
      await tester.pumpWidget(app(const AlarmManagementPage()));
      await tester.pumpAndSettle();
      expect(find.text('Open system Clock'), findsOneWidget);
      await tester.tap(find.widgetWithText(TextButton, 'Remove record'));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('The system alarm will remain'),
        findsOneWidget,
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Remove record'));
      await tester.pumpAndSettle();
      expect(calls.where((c) => c.method == 'forget').length, 1);
      expect(calls.where((c) => c.method == 'delete'), isEmpty);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.android),
  );
  testWidgets(
    'remote Android date shows weekly warning and permits submission',
    (tester) async {
      tester.view.physicalSize = const Size(1000, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        app(
          Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => showSystemAlarmDialog(
                  context,
                  title: 'Future',
                  notes: 'Notes',
                  time: time,
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('possibly before the task date'),
        findsOneWidget,
      );
      await tester.tap(find.text('Add alarms'));
      await tester.pumpAndSettle();
      expect(calls.where((c) => c.method == 'schedule').length, 1);
      expect(find.textContaining('Submitted 1 requests'), findsOneWidget);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.android),
  );
  for (final width in [390.0, 900.0]) {
    testWidgets(
      'Android alarm matches editor width at $width with keyboard avoidance',
      (tester) async {
        tester.view.physicalSize = Size(width, 1200);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetViewInsets);
        await tester.pumpWidget(
          app(
            Builder(
              builder: (context) => Scaffold(
                body: Column(
                  children: [
                    TextButton(
                      onPressed: () => showAdaptiveEditor(
                        context,
                        child: EditorFrame(
                          title: 'Edit task',
                          body: const Text('Task fields'),
                          primaryAction: const SizedBox.shrink(),
                        ),
                      ),
                      child: const Text('Editor'),
                    ),
                    TextButton(
                      onPressed: () => showSystemAlarmDialog(
                        context,
                        title: 'Task',
                        notes: '',
                        time: time,
                      ),
                      child: const Text('Alarm'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Editor'));
        await tester.pumpAndSettle();
        final editorWidth = tester.getSize(find.byType(EditorFrame)).width;
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Alarm'));
        await tester.pumpAndSettle();
        expect(
          tester.getSize(find.byType(AlertDialog)).width,
          closeTo(editorWidth, 0.01),
        );
        tester.view.viewInsets = const FakeViewPadding(bottom: 300);
        await tester.pumpAndSettle();
        expect(
          tester.getSize(find.byType(AlertDialog)).width,
          closeTo(editorWidth, 0.01),
        );
        expect(
          tester.getBottomLeft(find.byType(AlertDialog)).dy,
          closeTo(900, 0.01),
        );
        expect(tester.takeException(), isNull);
      },
      variant: TargetPlatformVariant.only(TargetPlatform.android),
    );
  }
  testWidgets(
    'bulk clear confirms once, deletes the listed alarms and disables when empty',
    (tester) async {
      final records = [
        record(),
        {...record(), 'id': 'second-alarm'},
      ];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            calls.add(call);
            if (call.method == 'list') return List.of(records);
            if (call.method == 'delete') {
              records.removeWhere(
                (entry) => entry['id'] == call.arguments['id'],
              );
            }
            return null;
          });
      await tester.pumpWidget(app(const AlarmManagementPage()));
      await tester.pumpAndSettle();
      final clear = find.widgetWithText(
        FloatingActionButton,
        'Clear all alarms',
      );
      await tester.tap(clear);
      await tester.pumpAndSettle();
      expect(find.textContaining('all 2 DDL out! alarms'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(calls.where((call) => call.method == 'delete'), isEmpty);
      await tester.tap(clear);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Clear all alarms'));
      await tester.pumpAndSettle();
      expect(calls.where((call) => call.method == 'delete').length, 2);
      expect(find.text('No alarms added through DDL out! yet'), findsOneWidget);
      expect(tester.widget<FloatingActionButton>(clear).onPressed, isNull);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.windows),
  );
  testWidgets(
    'bulk deletion failure refreshes remaining alarms and exposes the error',
    (tester) async {
      final records = [
        record(),
        {...record(), 'id': 'second-alarm'},
      ];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            calls.add(call);
            if (call.method == 'list') return List.of(records);
            if (call.method == 'delete') {
              if (call.arguments['id'] == 'second-alarm') {
                throw PlatformException(
                  code: 'scheduler_failed',
                  message: 'Delete failed',
                );
              }
              records.removeWhere(
                (entry) => entry['id'] == call.arguments['id'],
              );
            }
            return null;
          });
      await tester.pumpWidget(app(const AlarmManagementPage()));
      await tester.pumpAndSettle();
      await tester.tap(
        find.widgetWithText(FloatingActionButton, 'Clear all alarms'),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Clear all alarms'));
      await tester.pumpAndSettle();
      expect(find.text('Native alarm'), findsOneWidget);
      expect(find.textContaining('Delete failed'), findsOneWidget);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.windows),
  );
  testWidgets(
    'Android bulk clear removes export records without deleting system alarms',
    (tester) async {
      await tester.pumpWidget(app(const AlarmManagementPage()));
      await tester.pumpAndSettle();
      await tester.tap(
        find.widgetWithText(FloatingActionButton, 'Clear all records'),
      );
      await tester.pumpAndSettle();
      expect(
        find.textContaining('will not delete system alarms'),
        findsOneWidget,
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Clear all records'));
      await tester.pumpAndSettle();
      expect(calls.where((call) => call.method == 'forget').length, 1);
      expect(calls.where((call) => call.method == 'delete'), isEmpty);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.android),
  );
  testWidgets(
    'alarm dismiss button silences, disables and destroys its own window',
    (tester) async {
      const windowChannel = MethodChannel('window_manager');
      final windowCalls = <MethodCall>[];
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(windowChannel, (call) async {
        windowCalls.add(call);
        return null;
      });
      addTearDown(
        () => messenger.setMockMethodCallHandler(windowChannel, null),
      );
      messenger.setMockMethodCallHandler(channel, (call) async {
        calls.add(call);
        if (call.method == 'get') return record();
        return null;
      });
      await tester.pumpWidget(app(AlarmWindow(id: record()['id']! as String)));
      await tester.pumpAndSettle();
      expect(calls.map((call) => call.method), ['get', 'sound']);
      await tester.tap(find.text('Dismiss alarm'));
      await tester.pumpAndSettle();
      expect(calls.map((call) => call.method), [
        'get',
        'sound',
        'silence',
        'disable',
      ]);
      expect(windowCalls.map((call) => call.method), contains('destroy'));
      await tester.pumpWidget(const SizedBox.shrink());
    },
    variant: TargetPlatformVariant.only(TargetPlatform.windows),
  );
  testWidgets(
    'manager displays actionable native errors instead of swallowing them',
    (tester) async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            channel,
            (_) async => throw PlatformException(
              code: 'scheduler_failed',
              message: 'Service unavailable',
              details: {'stage': 'connect_scheduler', 'hresult': '0x80041315'},
            ),
          );
      await tester.pumpWidget(app(const AlarmManagementPage()));
      await tester.pumpAndSettle();
      expect(find.textContaining('0x80041315'), findsOneWidget);
      expect(find.textContaining('connect_scheduler'), findsOneWidget);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.windows),
  );
}
