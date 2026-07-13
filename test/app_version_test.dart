import 'package:ddl_out/core/version/app_version.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() {
  test('appends git commit when provided', () async {
    PackageInfo.setMockInitialValues(
      appName: 'DDL out!',
      packageName: 'com.flysparkle.ddl_out',
      version: '0.1.1',
      buildNumber: '1',
      buildSignature: '',
    );

    expect(
      await const PackageInfoAppVersionReader(gitCommit: 'abc1234').read(),
      '0.1.1+abc1234',
    );
  });

  test('omits the separator when git commit is empty', () async {
    PackageInfo.setMockInitialValues(
      appName: 'DDL out!',
      packageName: 'com.flysparkle.ddl_out',
      version: '0.1.1',
      buildNumber: '1',
      buildSignature: '',
    );

    expect(await const PackageInfoAppVersionReader().read(), '0.1.1');
  });
}
