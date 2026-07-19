import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import 'update_checker.dart';

final appUpdateInstallerProvider = Provider<AppUpdateInstaller>(
  (ref) => const PlatformAppUpdateInstaller(),
);

enum UpdateInstallStage { downloading, verifying, preparing }

enum UpdateInstallResult { started, permissionRequired }

class UpdateInstallProgress {
  const UpdateInstallProgress(this.stage, [this.fraction]);

  final UpdateInstallStage stage;
  final double? fraction;
}

typedef UpdateProgressCallback = void Function(UpdateInstallProgress progress);

abstract interface class AppUpdateInstaller {
  bool get isSupported;

  Future<UpdateInstallResult> install(
    AppUpdate update, {
    required UpdateProgressCallback onProgress,
  });
}

class UpdateInstallException implements Exception {
  const UpdateInstallException(this.reason);

  final UpdateInstallFailure reason;
}

enum UpdateInstallFailure {
  unsupportedPlatform,
  assetUnavailable,
  checksumUnavailable,
  checksumMismatch,
  downloadFailed,
  installFailed,
}

class PlatformAppUpdateInstaller implements AppUpdateInstaller {
  const PlatformAppUpdateInstaller();

  static const _androidChannel = MethodChannel('ddl_out/app_update');
  static const _windowsChannel = MethodChannel('ddl_out/windows_update');

  @override
  bool get isSupported => Platform.isWindows || Platform.isAndroid;

  @override
  Future<UpdateInstallResult> install(
    AppUpdate update, {
    required UpdateProgressCallback onProgress,
  }) async {
    if (!isSupported) {
      throw const UpdateInstallException(
        UpdateInstallFailure.unsupportedPlatform,
      );
    }

    final packageAsset = selectPackageAsset(
      update.assets,
      platform: Platform.isWindows
          ? UpdateTargetPlatform.windows
          : UpdateTargetPlatform.android,
      abi: Abi.current(),
    );
    if (packageAsset == null) {
      throw const UpdateInstallException(UpdateInstallFailure.assetUnavailable);
    }
    if (Platform.isAndroid && !await _ensureAndroidInstallPermission()) {
      return UpdateInstallResult.permissionRequired;
    }
    final checksumAsset = update.assets
        .where((asset) => asset.name == 'SHA256SUMS.txt')
        .firstOrNull;
    if (checksumAsset == null) {
      throw const UpdateInstallException(
        UpdateInstallFailure.checksumUnavailable,
      );
    }

    final expectedChecksum = await _readExpectedChecksum(
      checksumAsset.downloadUri,
      packageAsset.name,
    );
    final temporaryRoot = await getTemporaryDirectory();
    final safeVersion = update.version.replaceAll(
      RegExp(r'[^0-9A-Za-z._-]'),
      '_',
    );
    final updateDirectory = Directory(
      path.join(temporaryRoot.path, 'ddl_out_update_$safeVersion'),
    );
    if (await updateDirectory.exists()) {
      await updateDirectory.delete(recursive: true);
    }
    await updateDirectory.create(recursive: true);

    final packageFile = File(
      path.join(updateDirectory.path, packageAsset.name),
    );
    try {
      await _download(
        packageAsset.downloadUri,
        packageFile,
        expectedSize: packageAsset.size,
        onProgress: (fraction) => onProgress(
          UpdateInstallProgress(UpdateInstallStage.downloading, fraction),
        ),
      );
    } on UpdateInstallException {
      rethrow;
    } on Object {
      throw const UpdateInstallException(UpdateInstallFailure.downloadFailed);
    }

    onProgress(const UpdateInstallProgress(UpdateInstallStage.verifying));
    final actualChecksum = await sha256.bind(packageFile.openRead()).first;
    if (actualChecksum.toString().toLowerCase() != expectedChecksum) {
      throw const UpdateInstallException(UpdateInstallFailure.checksumMismatch);
    }

    onProgress(const UpdateInstallProgress(UpdateInstallStage.preparing));
    if (Platform.isWindows) {
      await _startWindowsUpdater(packageFile, updateDirectory);
      Future<void>.delayed(const Duration(milliseconds: 500), () => exit(0));
      return UpdateInstallResult.started;
    }
    return _openAndroidInstaller(packageFile);
  }

  Future<String> _readExpectedChecksum(Uri uri, String fileName) async {
    final client = HttpClient();
    try {
      final request = await client
          .getUrl(uri)
          .timeout(const Duration(seconds: 10));
      request.headers.set(HttpHeaders.userAgentHeader, 'DDL-out updater');
      final response = await request.close().timeout(
        const Duration(seconds: 10),
      );
      if (response.statusCode != HttpStatus.ok) {
        throw const UpdateInstallException(
          UpdateInstallFailure.checksumUnavailable,
        );
      }
      final bytes = <int>[];
      await for (final chunk in response.timeout(const Duration(seconds: 15))) {
        bytes.addAll(chunk);
        if (bytes.length > 1024 * 1024) {
          throw const UpdateInstallException(
            UpdateInstallFailure.checksumUnavailable,
          );
        }
      }
      final checksums = parseChecksums(utf8.decode(bytes));
      final checksum = checksums[fileName];
      if (checksum == null) {
        throw const UpdateInstallException(
          UpdateInstallFailure.checksumUnavailable,
        );
      }
      return checksum;
    } on UpdateInstallException {
      rethrow;
    } on Object {
      throw const UpdateInstallException(
        UpdateInstallFailure.checksumUnavailable,
      );
    } finally {
      client.close(force: true);
    }
  }

  Future<void> _download(
    Uri uri,
    File destination, {
    required int? expectedSize,
    required void Function(double? fraction) onProgress,
  }) async {
    final client = HttpClient();
    IOSink? sink;
    try {
      final request = await client
          .getUrl(uri)
          .timeout(const Duration(seconds: 15));
      request.headers.set(HttpHeaders.userAgentHeader, 'DDL-out updater');
      final response = await request.close().timeout(
        const Duration(seconds: 15),
      );
      if (response.statusCode != HttpStatus.ok) {
        throw const UpdateInstallException(UpdateInstallFailure.downloadFailed);
      }
      sink = destination.openWrite();
      final total = response.contentLength > 0
          ? response.contentLength
          : expectedSize;
      var received = 0;
      await for (final chunk in response.timeout(const Duration(seconds: 30))) {
        sink.add(chunk);
        received += chunk.length;
        final fraction = total == null || total <= 0 ? null : received / total;
        onProgress(
          fraction == null
              ? null
              : fraction > 1
              ? 1
              : fraction,
        );
      }
      await sink.flush();
      await sink.close();
      sink = null;
      if (expectedSize != null &&
          expectedSize > 0 &&
          received != expectedSize) {
        throw const UpdateInstallException(UpdateInstallFailure.downloadFailed);
      }
    } finally {
      await sink?.close();
      client.close(force: true);
    }
  }

  Future<void> _startWindowsUpdater(
    File packageFile,
    Directory updateDirectory,
  ) async {
    final payload = Directory(path.join(updateDirectory.path, 'payload'));
    await payload.create(recursive: true);
    await extractFileToDisk(packageFile.path, payload.path);
    final executableName = path.basename(Platform.resolvedExecutable);
    if (!await File(path.join(payload.path, executableName)).exists()) {
      throw const UpdateInstallException(UpdateInstallFailure.installFailed);
    }

    final script = File(path.join(updateDirectory.path, 'apply_update.ps1'));
    await script.writeAsString(windowsUpdaterScript, flush: true);
    final started = await _windowsChannel.invokeMethod<bool>('startUpdater', {
      'scriptPath': script.path,
      'processId': pid.toString(),
      'source': payload.path,
      'destination': File(Platform.resolvedExecutable).parent.path,
      'executableName': executableName,
    });
    if (started != true) {
      throw const UpdateInstallException(UpdateInstallFailure.installFailed);
    }
  }

  Future<UpdateInstallResult> _openAndroidInstaller(File packageFile) async {
    try {
      final result = await _androidChannel.invokeMethod<String>('installApk', {
        'path': packageFile.path,
      });
      return result == 'permission_required'
          ? UpdateInstallResult.permissionRequired
          : UpdateInstallResult.started;
    } on PlatformException {
      throw const UpdateInstallException(UpdateInstallFailure.installFailed);
    }
  }

  Future<bool> _ensureAndroidInstallPermission() async {
    try {
      return await _androidChannel.invokeMethod<bool>(
            'ensureInstallPermission',
          ) ??
          false;
    } on PlatformException {
      throw const UpdateInstallException(UpdateInstallFailure.installFailed);
    }
  }
}

enum UpdateTargetPlatform { windows, android }

ReleaseAsset? selectPackageAsset(
  List<ReleaseAsset> assets, {
  required UpdateTargetPlatform platform,
  required Abi abi,
}) {
  final suffix = switch ((platform, abi)) {
    (UpdateTargetPlatform.windows, Abi.windowsX64) =>
      '-windows-x64-portable.zip',
    (UpdateTargetPlatform.windows, Abi.windowsArm64) =>
      '-windows-arm64-portable.zip',
    (UpdateTargetPlatform.android, Abi.androidArm64) =>
      '-android-arm64-v8a.apk',
    (UpdateTargetPlatform.android, Abi.androidX64) => '-android-x64.apk',
    _ => null,
  };
  if (suffix == null) return null;
  return assets
      .where(
        (asset) =>
            isSafeReleaseAssetName(asset.name) && asset.name.endsWith(suffix),
      )
      .firstOrNull;
}

bool isSafeReleaseAssetName(String name) {
  return name.isNotEmpty &&
      name != '.' &&
      name != '..' &&
      !name.contains('/') &&
      !name.contains('\\');
}

Map<String, String> parseChecksums(String contents) {
  final result = <String, String>{};
  final pattern = RegExp(r'^([0-9a-fA-F]{64})\s+\*?(.+)$');
  for (final line in const LineSplitter().convert(contents)) {
    final match = pattern.firstMatch(line.trim());
    if (match == null) continue;
    result[match.group(2)!] = match.group(1)!.toLowerCase();
  }
  return result;
}

@visibleForTesting
const windowsUpdaterScript = r'''
param(
  [Parameter(Mandatory=$true)][int]$ProcessId,
  [Parameter(Mandatory=$true)][string]$Source,
  [Parameter(Mandatory=$true)][string]$Destination,
  [Parameter(Mandatory=$true)][string]$ExecutableName
)
$ErrorActionPreference = 'Stop'
Wait-Process -Id $ProcessId -ErrorAction SilentlyContinue
Start-Sleep -Milliseconds 300
$parent = [System.IO.Path]::GetDirectoryName($Destination)
$leaf = [System.IO.Path]::GetFileName($Destination)
$backup = Join-Path $parent ($leaf + '.previous')
if (Test-Path -LiteralPath $backup) {
  Remove-Item -LiteralPath $backup -Recurse -Force
}
Move-Item -LiteralPath $Destination -Destination $backup
try {
  Move-Item -LiteralPath $Source -Destination $Destination
  $updatedProcess = Start-Process -FilePath (Join-Path $Destination $ExecutableName) -WorkingDirectory $Destination -PassThru
  Start-Sleep -Seconds 3
  if ($updatedProcess.HasExited) {
    throw 'The updated application exited during startup.'
  }
  Remove-Item -LiteralPath $backup -Recurse -Force
} catch {
  if (Test-Path -LiteralPath $Destination) {
    Remove-Item -LiteralPath $Destination -Recurse -Force
  }
  Move-Item -LiteralPath $backup -Destination $Destination
  Start-Process -FilePath (Join-Path $Destination $ExecutableName) -WorkingDirectory $Destination
  throw
}
''';
