import 'dart:async';

import 'package:ddl_out/core/update/update_checker.dart';
import 'package:ddl_out/core/update/update_installer.dart';
import 'package:ddl_out/features/update/update_prompt.dart';
import 'package:ddl_out/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('downloads an update in the app and reports progress', (
    tester,
  ) async {
    final installer = _FakeInstaller();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appUpdateInstallerProvider.overrideWithValue(installer)],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () =>
                  showUpdatePrompt(context, const AppUpdate('2.0.0')),
              child: const Text('show'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('show'));
    await tester.pumpAndSettle();
    expect(find.text('Update now'), findsOneWidget);

    await tester.tap(find.text('Update now'));
    await tester.pump();
    expect(installer.calls, 1);
    expect(find.text('Downloading update… 50%'), findsOneWidget);

    installer.completer.complete(UpdateInstallResult.started);
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('unsupported platforms do not offer a manual download fallback', (
    tester,
  ) async {
    final installer = _FakeInstaller(isSupported: false);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appUpdateInstallerProvider.overrideWithValue(installer)],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () =>
                  showUpdatePrompt(context, const AppUpdate('2.0.0')),
              child: const Text('show'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('show'));
    await tester.pumpAndSettle();

    expect(find.text('Update now'), findsNothing);
    expect(
      find.text('In-app updates are not supported on this platform yet.'),
      findsOneWidget,
    );
  });
}

class _FakeInstaller implements AppUpdateInstaller {
  _FakeInstaller({this.isSupported = true});

  final completer = Completer<UpdateInstallResult>();
  int calls = 0;

  @override
  final bool isSupported;

  @override
  Future<UpdateInstallResult> install(
    AppUpdate update, {
    required UpdateProgressCallback onProgress,
  }) {
    calls += 1;
    onProgress(
      const UpdateInstallProgress(UpdateInstallStage.downloading, 0.5),
    );
    return completer.future;
  }
}
