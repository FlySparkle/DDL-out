import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

abstract interface class AppVersionReader {
  Future<String> read();
}

final appVersionReaderProvider = Provider<AppVersionReader>(
  (ref) => const PackageInfoAppVersionReader(),
);

final appVersionProvider = FutureProvider<String>(
  (ref) => ref.watch(appVersionReaderProvider).read(),
);

class PackageInfoAppVersionReader implements AppVersionReader {
  const PackageInfoAppVersionReader();

  @override
  Future<String> read() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final buildNumber = packageInfo.buildNumber;
    return buildNumber.isEmpty
        ? packageInfo.version
        : '${packageInfo.version}+$buildNumber';
  }
}
