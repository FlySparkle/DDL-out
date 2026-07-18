import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

void registerAppLicenses() {
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString(
      'assets/fonts/OFL-NotoSansSC.txt',
    );
    yield LicenseEntryWithLineBreaks(const ['Noto Sans SC'], license);
  });
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString(
      'assets/icon/LICENSE-FONT-AWESOME.txt',
    );
    yield LicenseEntryWithLineBreaks(const [
      'Font Awesome Free — Calendar Check icon',
    ], license);
  });
}
