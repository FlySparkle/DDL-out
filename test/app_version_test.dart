import 'package:ddl_out/core/version/app_version.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() {
  test('reads the package version and build number', () async {
    PackageInfo.setMockInitialValues(
      appName: 'DDL out!',
      packageName: 'com.flysparkle.ddl_out',
      version: '0.1.1',
      buildNumber: '1',
      buildSignature: '',
    );

    expect(await const PackageInfoAppVersionReader().read(), '0.1.1+1');
  });

  test('omits the separator when the package has no build number', () async {
    PackageInfo.setMockInitialValues(
      appName: 'DDL out!',
      packageName: 'com.flysparkle.ddl_out',
      version: '0.1.1',
      buildNumber: '',
      buildSignature: '',
    );

    expect(await const PackageInfoAppVersionReader().read(), '0.1.1');
  });
}
