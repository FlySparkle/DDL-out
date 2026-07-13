import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

const _gitCommit = String.fromEnvironment('GIT_COMMIT');

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
  const PackageInfoAppVersionReader({this.gitCommit = _gitCommit});

  final String gitCommit;

  @override
  Future<String> read() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final version = packageInfo.version;
    return gitCommit.isNotEmpty ? '$version+$gitCommit' : version;
  }
}
