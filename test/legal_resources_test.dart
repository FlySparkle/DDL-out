import 'dart:io';

import 'package:ddl_out/core/licenses/app_licenses.dart';
import 'package:ddl_out/features/settings/domain/legal_document.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('all localized legal documents are present and non-empty', () {
    for (final locale in ['zh', 'en', 'ja']) {
      for (final fileName in ['privacy.md', 'terms.md', 'code_of_conduct.md']) {
        final file = File('assets/legal/$locale/$fileName');
        expect(file.existsSync(), isTrue, reason: file.path);
        final contents = file.readAsStringSync();
        expect(contents.trim(), isNotEmpty, reason: file.path);
        expect(contents, contains('2026-07-15'), reason: file.path);
      }
    }
  });

  test('legal document resolver selects supported locales and fallback', () {
    expect(
      LegalDocumentDescriptor.resolve(
        LegalDocumentKind.privacy,
        'ja',
      ).assetPath,
      'assets/legal/ja/privacy.md',
    );
    expect(
      LegalDocumentDescriptor.resolve(LegalDocumentKind.terms, 'fr').assetPath,
      'assets/legal/zh/terms.md',
    );
    expect(
      LegalDocumentDescriptor.resolve(LegalDocumentKind.gpl, 'en').assetPath,
      'LICENSE',
    );
  });

  test('registers the bundled Noto Sans SC licence', () async {
    registerAppLicenses();
    final entries = await LicenseRegistry.licenses.toList();
    expect(
      entries.any((entry) => entry.packages.contains('Noto Sans SC')),
      isTrue,
    );
  });
}
