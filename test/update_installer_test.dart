import 'dart:ffi';
import 'dart:io';

import 'package:ddl_out/core/update/update_checker.dart';
import 'package:ddl_out/core/update/update_installer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final assets = [
    ReleaseAsset(
      name: 'DDL_out_v1.0.0-windows-x64-portable.zip',
      downloadUri: Uri.parse('https://example.com/windows-x64.zip'),
    ),
    ReleaseAsset(
      name: 'DDL_out_v1.0.0-windows-arm64-portable.zip',
      downloadUri: Uri.parse('https://example.com/windows-arm64.zip'),
    ),
    ReleaseAsset(
      name: 'DDL_out_v1.0.0-android-arm64-v8a.apk',
      downloadUri: Uri.parse('https://example.com/android-arm64.apk'),
    ),
  ];

  test('selects the package matching platform and ABI', () {
    expect(
      selectPackageAsset(
        assets,
        platform: UpdateTargetPlatform.windows,
        abi: Abi.windowsX64,
      )?.name,
      'DDL_out_v1.0.0-windows-x64-portable.zip',
    );
    expect(
      selectPackageAsset(
        assets,
        platform: UpdateTargetPlatform.android,
        abi: Abi.androidArm64,
      )?.name,
      'DDL_out_v1.0.0-android-arm64-v8a.apk',
    );
    expect(
      selectPackageAsset(
        assets,
        platform: UpdateTargetPlatform.android,
        abi: Abi.androidArm,
      ),
      isNull,
    );
    expect(
      selectPackageAsset(
        [
          ReleaseAsset(
            name: '..\\DDL_out_v1.0.0-windows-x64-portable.zip',
            downloadUri: Uri.parse('https://example.com/unsafe.zip'),
          ),
        ],
        platform: UpdateTargetPlatform.windows,
        abi: Abi.windowsX64,
      ),
      isNull,
    );
  });

  test('parses sha256sum manifests with binary and text markers', () {
    final checksums = parseChecksums('''
0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef  first.zip
abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789 *second.apk
invalid line
''');

    expect(
      checksums['first.zip'],
      '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef',
    );
    expect(
      checksums['second.apk'],
      'abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789',
    );
    expect(checksums, hasLength(2));
  });

  test(
    'windows updater replaces the app directory and removes its backup',
    () async {
      if (!Platform.isWindows) return;
      final root = await Directory.systemTemp.createTemp(
        'ddlout-updater-test-',
      );
      try {
        final destination = Directory('${root.path}\\installed');
        final payload = Directory('${root.path}\\payload');
        await destination.create();
        await payload.create();
        await File('${destination.path}\\version.txt').writeAsString('old');
        await File('${payload.path}\\version.txt').writeAsString('new');
        await File(
          '${destination.path}\\restart.cmd',
        ).writeAsString('@exit /b 0');
        await File(
          '${payload.path}\\restart.cmd',
        ).writeAsString('@ping 127.0.0.1 -n 6 > nul');
        final script = File('${root.path}\\apply_update.ps1');
        await script.writeAsString(windowsUpdaterScript);

        final result = await Process.run('powershell.exe', [
          '-NoProfile',
          '-NonInteractive',
          '-WindowStyle',
          'Hidden',
          '-ExecutionPolicy',
          'Bypass',
          '-File',
          script.path,
          '-ProcessId',
          '999999',
          '-Source',
          payload.path,
          '-Destination',
          destination.path,
          '-ExecutableName',
          'restart.cmd',
        ]);

        expect(result.exitCode, 0, reason: '${result.stderr}');
        expect(
          await File('${destination.path}\\version.txt').readAsString(),
          'new',
        );
        expect(
          await Directory('${destination.path}.previous').exists(),
          isFalse,
        );
      } finally {
        await Future<void>.delayed(const Duration(seconds: 3));
        await root.delete(recursive: true);
      }
    },
  );
}
