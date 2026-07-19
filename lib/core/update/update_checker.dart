import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../version/app_version.dart';

final githubLatestReleaseUri = Uri.parse(
  'https://api.github.com/repos/FlySparkle/DDL-out/releases/latest',
);

abstract interface class LatestReleaseReader {
  Future<LatestRelease> readLatestRelease();
}

final latestReleaseReaderProvider = Provider<LatestReleaseReader>(
  (ref) => const GitHubLatestReleaseReader(),
);

final updateCheckerProvider = Provider<AppUpdateChecker>(
  (ref) => AppUpdateChecker(
    currentVersionReader: ref.watch(appVersionReaderProvider),
    latestReleaseReader: ref.watch(latestReleaseReaderProvider),
  ),
);

class GitHubLatestReleaseReader implements LatestReleaseReader {
  const GitHubLatestReleaseReader();

  @override
  Future<LatestRelease> readLatestRelease() async {
    final client = HttpClient();
    try {
      final request = await client
          .getUrl(githubLatestReleaseUri)
          .timeout(const Duration(seconds: 5));
      request.headers
        ..set(HttpHeaders.acceptHeader, 'application/vnd.github+json')
        ..set(HttpHeaders.userAgentHeader, 'DDL-out update checker');
      final response = await request.close().timeout(
        const Duration(seconds: 5),
      );
      final body = await response.transform(utf8.decoder).join();
      if (response.statusCode != HttpStatus.ok) {
        throw const UpdateCheckException('Unable to read the latest release.');
      }

      return parseGitHubReleasePayload(jsonDecode(body));
    } finally {
      client.close(force: true);
    }
  }
}

LatestRelease parseGitHubReleasePayload(Object? payload) {
  if (payload is! Map<String, dynamic> || payload['tag_name'] is! String) {
    throw const UpdateCheckException('The latest release has no version tag.');
  }
  final assets = <ReleaseAsset>[];
  final rawAssets = payload['assets'];
  if (rawAssets is List) {
    for (final rawAsset in rawAssets) {
      if (rawAsset is! Map<String, dynamic> ||
          rawAsset['name'] is! String ||
          rawAsset['browser_download_url'] is! String) {
        continue;
      }
      final uri = Uri.tryParse(rawAsset['browser_download_url'] as String);
      if (uri == null || uri.scheme != 'https') continue;
      assets.add(
        ReleaseAsset(
          name: rawAsset['name'] as String,
          downloadUri: uri,
          size: rawAsset['size'] is int ? rawAsset['size'] as int : null,
        ),
      );
    }
  }
  return LatestRelease(version: payload['tag_name'] as String, assets: assets);
}

class AppUpdateChecker {
  const AppUpdateChecker({
    required this.currentVersionReader,
    required this.latestReleaseReader,
  });

  final AppVersionReader currentVersionReader;
  final LatestReleaseReader latestReleaseReader;

  Future<AppUpdate?> checkForUpdate() async {
    final currentVersion = ReleaseVersion.tryParseOrNull(
      await currentVersionReader.read(),
    );
    final latestRelease = await latestReleaseReader.readLatestRelease();
    final latestVersion = ReleaseVersion.tryParseOrNull(latestRelease.version);
    if (currentVersion == null || latestVersion == null) {
      throw const UpdateCheckException('Unable to compare release versions.');
    }
    return latestVersion.compareTo(currentVersion) > 0
        ? AppUpdate(latestVersion.toString(), latestRelease.assets)
        : null;
  }
}

class AppUpdate {
  const AppUpdate(this.version, [this.assets = const []]);

  final String version;
  final List<ReleaseAsset> assets;
}

class LatestRelease {
  const LatestRelease({required this.version, this.assets = const []});

  final String version;
  final List<ReleaseAsset> assets;
}

class ReleaseAsset {
  const ReleaseAsset({
    required this.name,
    required this.downloadUri,
    this.size,
  });

  final String name;
  final Uri downloadUri;
  final int? size;
}

class UpdateCheckException implements Exception {
  const UpdateCheckException(this.message);

  final String message;
}

class ReleaseVersion implements Comparable<ReleaseVersion> {
  const ReleaseVersion._(this.major, this.minor, this.patch, this.preRelease);

  factory ReleaseVersion.parse(String value) {
    final match = RegExp(
      r'^[vV]?(\d+)(?:\.(\d+))?(?:\.(\d+))?(?:-([0-9A-Za-z.-]+))?(?:\+[0-9A-Za-z.-]+)?$',
    ).firstMatch(value.trim());
    if (match == null) throw const FormatException('Invalid version.');

    return ReleaseVersion._(
      int.parse(match.group(1)!),
      int.parse(match.group(2) ?? '0'),
      int.parse(match.group(3) ?? '0'),
      match.group(4),
    );
  }

  static ReleaseVersion? tryParseOrNull(String value) {
    try {
      return ReleaseVersion.parse(value);
    } on FormatException {
      return null;
    }
  }

  final int major;
  final int minor;
  final int patch;
  final String? preRelease;

  @override
  int compareTo(ReleaseVersion other) {
    for (final comparison in [
      major.compareTo(other.major),
      minor.compareTo(other.minor),
      patch.compareTo(other.patch),
    ]) {
      if (comparison != 0) return comparison;
    }
    if (preRelease == null && other.preRelease == null) return 0;
    if (preRelease == null) return 1;
    if (other.preRelease == null) return -1;

    final thisParts = preRelease!.split('.');
    final otherParts = other.preRelease!.split('.');
    for (var index = 0; index < thisParts.length; index++) {
      if (index == otherParts.length) return 1;
      final comparison = _comparePreReleasePart(
        thisParts[index],
        otherParts[index],
      );
      if (comparison != 0) return comparison;
    }
    return thisParts.length.compareTo(otherParts.length);
  }

  static int _comparePreReleasePart(String left, String right) {
    final leftNumber = int.tryParse(left);
    final rightNumber = int.tryParse(right);
    if (leftNumber != null && rightNumber != null) {
      return leftNumber.compareTo(rightNumber);
    }
    if (leftNumber != null) return -1;
    if (rightNumber != null) return 1;
    return left.compareTo(right);
  }

  @override
  String toString() {
    final base = '$major.$minor.$patch';
    return preRelease == null ? base : '$base-$preRelease';
  }
}
