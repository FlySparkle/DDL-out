import 'package:ddl_out/core/update/update_checker.dart';
import 'package:ddl_out/core/version/app_version.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ReleaseVersion', () {
    test('ignores a GitHub tag prefix and a local build number', () {
      expect(
        ReleaseVersion.parse(
          'v0.1.2',
        ).compareTo(ReleaseVersion.parse('0.1.2+1')),
        0,
      );
    });

    test('treats a stable release as newer than its prerelease', () {
      expect(
        ReleaseVersion.parse(
          '1.0.0',
        ).compareTo(ReleaseVersion.parse('1.0.0-beta.1')),
        greaterThan(0),
      );
    });
  });

  group('AppUpdateChecker', () {
    test('returns an update only when the latest release is newer', () async {
      final checker = AppUpdateChecker(
        currentVersionReader: const _FakeAppVersionReader('0.1.2+1'),
        latestReleaseReader: const _FakeLatestReleaseReader('v0.2.0'),
      );

      expect((await checker.checkForUpdate())?.version, '0.2.0');
    });

    test('does not report the same release as an update', () async {
      final checker = AppUpdateChecker(
        currentVersionReader: const _FakeAppVersionReader('0.1.2+1'),
        latestReleaseReader: const _FakeLatestReleaseReader('v0.1.2'),
      );

      expect(await checker.checkForUpdate(), isNull);
    });
  });

  test('parses release assets and rejects non-HTTPS download URLs', () {
    final release = parseGitHubReleasePayload({
      'tag_name': 'v1.2.0',
      'assets': [
        {
          'name': 'DDL_out_v1.2.0-windows-x64-portable.zip',
          'browser_download_url': 'https://example.com/app.zip',
          'size': 42,
        },
        {
          'name': 'unsafe.zip',
          'browser_download_url': 'http://example.com/unsafe.zip',
        },
      ],
    });

    expect(release.version, 'v1.2.0');
    expect(release.assets, hasLength(1));
    expect(release.assets.single.size, 42);
  });
}

class _FakeAppVersionReader implements AppVersionReader {
  const _FakeAppVersionReader(this.version);

  final String version;

  @override
  Future<String> read() async => version;
}

class _FakeLatestReleaseReader implements LatestReleaseReader {
  const _FakeLatestReleaseReader(this.version);

  final String version;

  @override
  Future<LatestRelease> readLatestRelease() async =>
      LatestRelease(version: version);
}
