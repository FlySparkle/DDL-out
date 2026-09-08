import 'dart:convert';

import 'package:ddl_out/features/board/application/deadline_preset_store.dart';
import 'package:ddl_out/features/board/presentation/widgets/deadline_presets.dart';
import 'package:ddl_out/features/settings/application/settings.dart';
import 'package:ddl_out/l10n/app_localizations.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'custom presets persist with UTC timestamps and skip corrupt entries',
    () async {
      SharedPreferences.setMockInitialValues({});
      final store = DeadlinePresetStore();
      final date = DateTime(2026, 10, 1, 10, 30);
      await store.save([
        DeadlinePreset(label: 'Break', minutes: 30),
        DeadlinePreset(label: 'Meeting', localDateTime: date),
      ]);
      final loaded = await DeadlinePresetStore().load();
      expect(loaded.first.minutes, 30);
      expect(loaded.last.localDateTime, date);
      final prefs = await SharedPreferences.getInstance();
      final entries = prefs.getStringList(DeadlinePresetStore.storageKey)!;
      expect(jsonDecode(entries.last)['utc'], date.toUtc().toIso8601String());
      await prefs.setStringList(DeadlinePresetStore.storageKey, [
        ...entries,
        '{broken',
        '{"label":"bad","minutes":-1}',
      ]);
      expect(await store.load(), hasLength(2));
    },
  );

  testWidgets(
    'wheel scrolls presets horizontally and custom duration is reusable',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      int? minutes;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 220,
                child: DeadlinePresets(
                  mode: DeadlineMode.relative,
                  onRelative: (value) => minutes = value,
                  onAbsolute: (_) {},
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final strip = find.byKey(const ValueKey('deadline-presets'));
      await tester.sendEventToBinding(
        PointerScrollEvent(
          position: tester.getCenter(strip),
          scrollDelta: const Offset(0, 200),
        ),
      );
      await tester.pumpAndSettle();
      final scroll = tester.widget<SingleChildScrollView>(strip).controller!;
      expect(scroll.offset, greaterThan(0));
      await tester.tap(find.byKey(const ValueKey('add-deadline-preset')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Preset name'),
        'Break',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'minutes'),
        '30',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('+30m'));
      await tester.tap(find.text('+30m'));
      expect(minutes, 30);
      expect((await DeadlinePresetStore().load()).single.minutes, 30);
    },
  );
}
