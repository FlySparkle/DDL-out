import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../app/navigation/app_navigation_shell.dart';
import '../../data/database/app_database.dart';
import '../../data/repositories/repositories.dart';
import '../../data/sync/lan_sync_service.dart';
import '../../data/sync/sync_models.dart';
import '../../data/task_details/task_detail_document.dart';
import '../../l10n/app_localizations.dart';
import '../settings/application/settings_controller.dart';
import '../settings/settings_page.dart';

class SyncPage extends ConsumerWidget {
  const SyncPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final sync = ref.watch(lanSyncControllerProvider);
    final conflicts = ref.watch(syncConflictCountProvider).value ?? 0;
    final devices = ref.watch(syncDevicesProvider);
    final settings = ref.watch(settingsControllerProvider);
    return SettingsPageScaffold(
      destination: AppNavigationDestinationId.sync,
      title: l10n.nearbySync,
      body: ListView(
        padding: SettingsPageScaffold.contentPadding,
        children: [
          const _IntroCard(),
          const SizedBox(height: 12),
          _SessionCard(sync: sync),
          const SizedBox(height: 12),
          Card(
            child: SwitchListTile(
              secondary: const Icon(Icons.data_saver_off_outlined),
              title: Text(l10n.largeFileTransfer),
              subtitle: Text(l10n.largeFileTransferSubtitle),
              value: settings.largeSyncTransferEnabled,
              onChanged: ref
                  .read(settingsControllerProvider.notifier)
                  .setLargeSyncTransferEnabled,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: Badge(
                isLabelVisible: conflicts > 0,
                label: Text('$conflicts'),
                child: const Icon(Icons.rule_outlined),
              ),
              title: Text(l10n.syncConflicts),
              subtitle: Text(
                conflicts == 0
                    ? l10n.noSyncConflicts
                    : l10n.syncConflictCount(conflicts),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/sync/conflicts'),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.pairedDevices,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          devices.when(
            data: (items) => items.isEmpty
                ? ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.devices_other_outlined),
                    title: Text(l10n.noPairedDevices),
                  )
                : Column(
                    children: [
                      for (final device in items)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.devices_outlined),
                          title: Text(device.displayName),
                          subtitle: Text(
                            l10n.lastSyncedAt(
                              MaterialLocalizations.of(
                                context,
                              ).formatFullDate(device.lastSeenAtUtc.toLocal()),
                            ),
                          ),
                          trailing: IconButton(
                            tooltip: l10n.forgetDevice,
                            icon: const Icon(Icons.link_off),
                            onPressed: () =>
                                _forgetDevice(context, ref, device),
                          ),
                        ),
                    ],
                  ),
            loading: () => const LinearProgressIndicator(),
            error: (_, _) => Text(l10n.operationFailed),
          ),
        ],
      ),
    );
  }

  Future<void> _forgetDevice(
    BuildContext context,
    WidgetRef ref,
    SyncDevice device,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.forgetDevice),
        content: Text(l10n.forgetDeviceBody(device.displayName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(appDatabaseProvider).forgetSyncPeer(device.deviceId);
    }
  }
}

class _IntroCard extends StatelessWidget {
  const _IntroCard();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    return Card(
      color: colors.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.sync_alt, color: colors.onSecondaryContainer, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.nearbySync,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.lanSyncPrivacy,
                    style: TextStyle(color: colors.onSecondaryContainer),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SessionCard extends ConsumerWidget {
  const _SessionCard({required this.sync});

  final LanSyncState sync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final controller = ref.read(lanSyncControllerProvider.notifier);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 280),
          child: switch (sync.phase) {
            LanSyncPhase.idle => _IdleSession(key: const ValueKey('idle')),
            LanSyncPhase.preparing ||
            LanSyncPhase.connecting ||
            LanSyncPhase.transferring => _ProgressSession(
              key: ValueKey(sync.phase),
              sync: sync,
            ),
            LanSyncPhase.waiting => Column(
              key: const ValueKey('waiting'),
              children: [
                Text(l10n.scanWithinTwoMinutes),
                const SizedBox(height: 16),
                if (sync.qrData case final data?) ...[
                  ColoredBox(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: QrImageView(data: data, size: 232),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SelectableText(
                    data,
                    maxLines: 2,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  FilledButton.tonalIcon(
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: data));
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.syncKeyCopied)),
                      );
                    },
                    icon: const Icon(Icons.content_copy),
                    label: Text(l10n.copySyncKey),
                  ),
                ],
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: controller.stop,
                  icon: const Icon(Icons.close),
                  label: Text(l10n.cancel),
                ),
              ],
            ),
            LanSyncPhase.success => _ResultSession(
              key: const ValueKey('success'),
              sync: sync,
              successful: true,
            ),
            LanSyncPhase.error => _ResultSession(
              key: const ValueKey('error'),
              sync: sync,
              successful: false,
            ),
          },
        ),
      ),
    );
  }
}

class _IdleSession extends ConsumerWidget {
  const _IdleSession({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.syncRoleDescription,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: () async {
            final controller = ref.read(lanSyncControllerProvider.notifier);
            final largeTransfer = ref
                .read(settingsControllerProvider)
                .largeSyncTransferEnabled;
            await controller.startHosting(largeTransferEnabled: largeTransfer);
          },
          icon: const Icon(Icons.qr_code_2),
          label: Text(l10n.createSyncQr),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => _joinSession(context, ref),
          icon: const Icon(Icons.qr_code_scanner),
          label: Text(l10n.joinSyncSession),
        ),
      ],
    );
  }

  Future<void> _joinSession(BuildContext context, WidgetRef ref) async {
    final value = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => const _JoinSyncSheet(),
    );
    if (value == null || !context.mounted) return;
    await ref
        .read(lanSyncControllerProvider.notifier)
        .connectFromQr(
          value,
          largeTransferEnabled: ref
              .read(settingsControllerProvider)
              .largeSyncTransferEnabled,
        );
  }
}

class _JoinSyncSheet extends StatefulWidget {
  const _JoinSyncSheet();

  @override
  State<_JoinSyncSheet> createState() => _JoinSyncSheetState();
}

class _JoinSyncSheetState extends State<_JoinSyncSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          0,
          24,
          24 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.joinSyncSession,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              minLines: 2,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: l10n.syncPairingKey,
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  tooltip: l10n.pasteSyncKey,
                  icon: const Icon(Icons.content_paste),
                  onPressed: () async {
                    final data = await Clipboard.getData(Clipboard.kTextPlain);
                    if (data?.text case final text?) {
                      _controller.text = text;
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () async {
                final value = await Navigator.of(context).push<String>(
                  MaterialPageRoute(builder: (_) => const SyncScannerPage()),
                );
                if (value != null && context.mounted) {
                  Navigator.of(context).pop(value);
                }
              },
              icon: const Icon(Icons.qr_code_scanner),
              label: Text(l10n.scanSyncQr),
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: () {
                final value = _controller.text.trim();
                if (value.isNotEmpty) Navigator.of(context).pop(value);
              },
              child: Text(l10n.connectAndSync),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressSession extends StatelessWidget {
  const _ProgressSession({required this.sync, super.key});

  final LanSyncState sync;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isTransferring = sync.phase == LanSyncPhase.transferring;
    final text = switch (sync.phase) {
      LanSyncPhase.preparing => l10n.preparingSync,
      LanSyncPhase.connecting => l10n.connectingDevice,
      _ => l10n.syncingWith(sync.peerName ?? l10n.otherDevice),
    };
    final progress = sync.totalBytes == 0
        ? 1.0
        : (sync.transferredBytes / sync.totalBytes).clamp(0.0, 1.0);
    return Column(
      children: [
        if (isTransferring)
          LinearProgressIndicator(
            key: const ValueKey('sync-byte-progress'),
            value: progress,
          )
        else
          const CircularProgressIndicator(),
        const SizedBox(height: 16),
        Text(text, textAlign: TextAlign.center),
        if (isTransferring) ...[
          const SizedBox(height: 8),
          Text(
            l10n.syncTransferProgress(
              formatSyncByteCount(sync.transferredBytes),
              formatSyncByteCount(sync.totalBytes),
            ),
            key: const ValueKey('sync-byte-progress-label'),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ],
    );
  }
}

class _ResultSession extends ConsumerWidget {
  const _ResultSession({
    required this.sync,
    required this.successful,
    super.key,
  });

  final LanSyncState sync;
  final bool successful;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    return Column(
      children: [
        Icon(
          successful ? Icons.check_circle_outline : Icons.error_outline,
          size: 42,
          color: successful ? colors.primary : colors.error,
        ),
        const SizedBox(height: 10),
        Text(
          successful
              ? l10n.syncCompleted(
                  sync.receivedOperations,
                  sync.sentOperations,
                  sync.conflictCount,
                )
              : sync.errorMessage ?? l10n.operationFailed,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: ref.read(lanSyncControllerProvider.notifier).stop,
          child: Text(l10n.done),
        ),
      ],
    );
  }
}

class SyncScannerPage extends StatefulWidget {
  const SyncScannerPage({super.key});

  @override
  State<SyncScannerPage> createState() => _SyncScannerPageState();
}

class _SyncScannerPageState extends State<SyncScannerPage> {
  bool _handled = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.scanSyncQr)),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            onDetect: (capture) {
              if (_handled) return;
              final value = capture.barcodes
                  .map((barcode) => barcode.rawValue)
                  .whereType<String>()
                  .firstOrNull;
              if (value == null) return;
              _handled = true;
              Navigator.of(context).pop(value);
            },
          ),
          IgnorePointer(
            child: Center(
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 3),
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SyncConflictsPage extends ConsumerWidget {
  const SyncConflictsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final sync = ref.watch(lanSyncControllerProvider);
    final canResolve = sync.isCoordinator;
    final conflicts = ref.watch(syncConflictsProvider);
    return SettingsPageScaffold(
      destination: AppNavigationDestinationId.sync,
      showBackButton: true,
      title: l10n.syncConflicts,
      body: conflicts.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(child: Text(l10n.operationFailed)),
        data: (items) => ListView(
          padding: SettingsPageScaffold.contentPadding,
          children: [
            Card(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      canResolve
                          ? l10n.conflictApprovalHere
                          : l10n.conflictApprovalOnInitiator,
                    ),
                    if (!canResolve) ...[
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: ref
                            .read(lanSyncControllerProvider.notifier)
                            .allowResolveHere,
                        icon: const Icon(Icons.phone_android),
                        label: Text(l10n.resolveOnThisDevice),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (items.isEmpty)
              _EmptyConflicts()
            else
              for (final conflict in items)
                _ConflictCard(conflict: conflict, canResolve: canResolve),
          ],
        ),
      ),
    );
  }
}

class _EmptyConflicts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(
            Icons.done_all,
            size: 48,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 12),
          Text(l10n.noSyncConflicts),
        ],
      ),
    );
  }
}

class _ConflictCard extends ConsumerWidget {
  const _ConflictCard({required this.conflict, required this.canResolve});

  final SyncConflictView conflict;
  final bool canResolve;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              conflict.entityName,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 2),
            Text(
              l10n.conflictingField(_fieldLabel(l10n, conflict.fieldName)),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            for (final candidate in conflict.candidates)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                  onPressed: canResolve
                      ? () => ref
                            .read(appDatabaseProvider)
                            .resolveSyncConflict(conflict.id, candidate.value)
                      : null,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _valueLabel(
                          context,
                          l10n,
                          conflict.fieldName,
                          candidate,
                        ),
                      ),
                      Text(
                        l10n.candidateFrom(candidate.deviceName),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _fieldLabel(AppLocalizations l10n, String field) => switch (field) {
    SyncField.name => l10n.taskName,
    SyncField.details => l10n.taskDetailsSection,
    SyncField.detailImages => l10n.taskDetailImages,
    SyncField.colorArgb => l10n.categoryColor,
    SyncField.positionKey => l10n.categoryOrder,
    SyncField.deadlineUtc => l10n.deadline,
    SyncField.categorySyncId => l10n.taskCategory,
    SyncField.completion => l10n.completionState,
    SyncField.deleted => l10n.deletionState,
    _ => l10n.syncDataConflict,
  };

  String _valueLabel(
    BuildContext context,
    AppLocalizations l10n,
    String field,
    SyncConflictCandidate candidate,
  ) {
    final value = candidate.value;
    if (field == SyncField.positionKey) return l10n.orderingConflict;
    if (field == SyncField.deleted) {
      return value == null ? l10n.keepItem : l10n.deleteItem;
    }
    if (field == SyncField.completion && value is Map) {
      return value['isCompleted'] == true
          ? l10n.completed
          : l10n.markIncomplete;
    }
    if (field == SyncField.deadlineUtc && value is String) {
      final date = DateTime.tryParse(value)?.toLocal();
      if (date != null) {
        return '${MaterialLocalizations.of(context).formatMediumDate(date)} '
            '${MaterialLocalizations.of(context).formatTimeOfDay(TimeOfDay.fromDateTime(date))}';
      }
    }
    if (field == SyncField.categorySyncId && value == null) {
      return l10n.uncategorized;
    }
    if (field == SyncField.categorySyncId) {
      return candidate.displayValue?.toString() ?? l10n.syncDataChoice;
    }
    if (field == SyncField.details && value is String) {
      try {
        final document = TaskDetailDocumentCodec.decode(
          details: value,
          images: const [],
        );
        final text = document.blocks
            .whereType<TaskDetailTextBlock>()
            .map((block) => block.text)
            .join('\n')
            .trim();
        return text.isEmpty ? l10n.emptyValue : text;
      } on FormatException {
        return l10n.syncDataChoice;
      }
    }
    if (field == SyncField.detailImages && value is List) {
      final names = <String>[];
      for (final (index, raw) in value.indexed) {
        final map = raw is Map ? Map<Object?, Object?>.from(raw) : null;
        final name = map?['fileName'];
        names.add(
          name is String && name.isNotEmpty
              ? name
              : '${l10n.taskDetailImages} ${index + 1}',
        );
      }
      return names.isEmpty ? l10n.emptyValue : names.join('\n');
    }
    if (field == SyncField.name) {
      return value?.toString() ?? l10n.emptyValue;
    }
    return l10n.syncDataChoice;
  }
}
