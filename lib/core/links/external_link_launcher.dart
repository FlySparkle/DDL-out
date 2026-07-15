import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_localizations.dart';

abstract interface class ExternalLinkLauncher {
  Future<bool> open(Uri uri);
}

class UrlExternalLinkLauncher implements ExternalLinkLauncher {
  const UrlExternalLinkLauncher();

  @override
  Future<bool> open(Uri uri) {
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

final externalLinkLauncherProvider = Provider<ExternalLinkLauncher>(
  (ref) => const UrlExternalLinkLauncher(),
);

Future<void> openExternalLink(
  BuildContext context,
  WidgetRef ref,
  Uri uri,
) async {
  final supported = uri.scheme == 'http' || uri.scheme == 'https';
  try {
    final opened =
        supported && await ref.read(externalLinkLauncherProvider).open(uri);
    if (opened || !context.mounted) return;
  } on Object {
    if (!context.mounted) return;
  }
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).openLinkFailed)),
    );
}
