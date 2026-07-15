enum LegalDocumentKind { gpl, privacy, terms, codeOfConduct }

class LegalDocumentDescriptor {
  const LegalDocumentDescriptor({
    required this.kind,
    required this.assetPath,
    required this.sourceUri,
    required this.markdown,
  });

  final LegalDocumentKind kind;
  final String assetPath;
  final Uri sourceUri;
  final bool markdown;

  factory LegalDocumentDescriptor.resolve(
    LegalDocumentKind kind,
    String languageCode,
  ) {
    if (kind == LegalDocumentKind.gpl) {
      return LegalDocumentDescriptor(
        kind: kind,
        assetPath: 'LICENSE',
        sourceUri: Uri.parse(
          'https://github.com/FlySparkle/DDL-out/blob/main/LICENSE',
        ),
        markdown: false,
      );
    }
    final locale = switch (languageCode) {
      'en' => 'en',
      'ja' => 'ja',
      _ => 'zh',
    };
    final fileName = switch (kind) {
      LegalDocumentKind.privacy => 'privacy.md',
      LegalDocumentKind.terms => 'terms.md',
      LegalDocumentKind.codeOfConduct => 'code_of_conduct.md',
      LegalDocumentKind.gpl => throw StateError('Handled above.'),
    };
    final assetPath = 'assets/legal/$locale/$fileName';
    return LegalDocumentDescriptor(
      kind: kind,
      assetPath: assetPath,
      sourceUri: Uri.parse(
        'https://github.com/FlySparkle/DDL-out/blob/main/$assetPath',
      ),
      markdown: true,
    );
  }
}
