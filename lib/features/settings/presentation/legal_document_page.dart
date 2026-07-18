import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/navigation/app_navigation_shell.dart';
import '../../../core/links/external_link_launcher.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/legal_document.dart';
import '../settings_page.dart';

class LegalDocumentPage extends ConsumerWidget {
  const LegalDocumentPage({required this.kind, super.key});

  final LegalDocumentKind kind;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final descriptor = LegalDocumentDescriptor.resolve(
      kind,
      Localizations.localeOf(context).languageCode,
    );
    final title = switch (kind) {
      LegalDocumentKind.gpl => l10n.openSourceLicense,
      LegalDocumentKind.privacy => l10n.privacyPolicy,
      LegalDocumentKind.terms => l10n.termsOfService,
      LegalDocumentKind.codeOfConduct => l10n.codeOfConduct,
    };
    final destination = kind == LegalDocumentKind.codeOfConduct
        ? AppNavigationDestinationId.community
        : AppNavigationDestinationId.about;

    return SettingsPageScaffold(
      destination: destination,
      title: title,
      showBackButton: true,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: OutlinedButton.icon(
            onPressed: () =>
                openExternalLink(context, ref, descriptor.sourceUri),
            icon: const Icon(Icons.open_in_new),
            label: Text(l10n.viewRepositorySource),
          ),
        ),
      ],
      body: FutureBuilder<String>(
        future: DefaultAssetBundle.of(context).loadString(descriptor.assetPath),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text(l10n.documentLoadFailed));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!descriptor.markdown) {
            return SelectionArea(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                children: [SelectableText(snapshot.data!)],
              ),
            );
          }
          return Markdown(
            data: snapshot.data!,
            selectable: true,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            onTapLink: (_, href, _) {
              final uri = href == null ? null : Uri.tryParse(href);
              if (uri != null) openExternalLink(context, ref, uri);
            },
          );
        },
      ),
    );
  }
}
