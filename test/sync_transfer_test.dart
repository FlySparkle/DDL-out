import 'dart:convert';
import 'dart:typed_data';

import 'package:ddl_out/data/database/app_database.dart';
import 'package:ddl_out/data/repositories/repositories.dart';
import 'package:ddl_out/data/sync/lan_sync_service.dart';
import 'package:ddl_out/data/sync/sync_models.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  test('pairing key round-trips the session payload', () {
    final payload = <String, Object?>{
      'type': 'ddl-out-lan-sync',
      'version': syncProtocolVersion,
      'hosts': ['192.168.1.20'],
      'port': 4242,
    };

    final key = SyncPairingKeyCodec.encode(payload);

    expect(key, startsWith('DDL5:'));
    expect(SyncPairingKeyCodec.decode(key), payload);
  });

  test('large synchronization operations are split below the frame limit', () {
    final operation = SyncOperationEnvelope(
      operationId: 'operation-1',
      originDeviceId: 'computer',
      originSequence: 1,
      context: VersionVector(),
      hlcMillis: 1,
      hlcCounter: 0,
      entityType: SyncEntityType.task,
      entitySyncId: 'task-1',
      kind: SyncOperationKind.patch,
      changes: {SyncField.details: List.filled(9 * 1024 * 1024, 'x').join()},
      occurredAtUtc: DateTime.utc(2026, 7, 28),
    );

    final payload = SyncTransferCodec.encodeOperation(operation);
    final chunks = SyncTransferCodec.chunks(payload).toList();
    final restored = BytesBuilder(copy: false);
    for (final chunk in chunks) {
      expect(chunk.length, lessThanOrEqualTo(SyncTransferCodec.chunkSizeBytes));
      restored.add(chunk);
    }

    expect(payload.length, greaterThan(8 * 1024 * 1024));
    expect(chunks.length, greaterThan(1));
    expect(restored.takeBytes(), payload);
    expect(
      SyncTransferCodec.decodeOperation(payload).canonicalJson,
      operation.canonicalJson,
    );
  });

  test('byte progress uses readable binary units', () {
    expect(formatSyncByteCount(512), '512 B');
    expect(formatSyncByteCount(1536), '1.5 KB');
    expect(formatSyncByteCount(2 * 1024 * 1024), '2 MB');
  });

  test('LAN sync state carries byte totals through updates', () {
    final state = const LanSyncState(
      phase: LanSyncPhase.transferring,
      transferredBytes: 1024,
      totalBytes: 4096,
    ).copyWith(transferredBytes: 2048);

    expect(state.transferredBytes, 2048);
    expect(state.totalBytes, 4096);
  });

  test(
    'LAN session transfers an image operation larger than the old frame limit',
    () async {
      final computer = AppDatabase(NativeDatabase.memory());
      final phone = AppDatabase(NativeDatabase.memory());
      final computerScope = ProviderContainer(
        overrides: [appDatabaseProvider.overrideWithValue(computer)],
      );
      final phoneScope = ProviderContainer(
        overrides: [appDatabaseProvider.overrideWithValue(phone)],
      );
      addTearDown(() async {
        await computerScope.read(lanSyncControllerProvider.notifier).stop();
        await phoneScope.read(lanSyncControllerProvider.notifier).stop();
        computerScope.dispose();
        phoneScope.dispose();
        await computer.close();
        await phone.close();
      });

      final imageBytes = Uint8List(7 * 1024 * 1024);
      for (var index = 0; index < imageBytes.length; index += 1) {
        imageBytes[index] = index % 251;
      }
      final categoryId = await computer.createCategory('项目', 0xFF4A90E2);
      await computer.createTask(
        name: '带大图事项',
        deadlineUtc: DateTime.utc(2026, 8, 1),
        categoryId: categoryId,
        detailImagesJson: jsonEncode([
          {
            'id': 'large-sync-image',
            'mimeType': 'image/png',
            'base64Data': base64Encode(imageBytes),
          },
        ]),
      );

      final host = computerScope.read(lanSyncControllerProvider.notifier);
      await host.startHosting(hostAddressesOverride: const ['127.0.0.1']);
      final qrData = computerScope.read(lanSyncControllerProvider).qrData;
      expect(qrData, isNotNull);

      final client = phoneScope.read(lanSyncControllerProvider.notifier);
      await client.connectFromQr(qrData!);

      final computerState = computerScope.read(lanSyncControllerProvider);
      final phoneState = phoneScope.read(lanSyncControllerProvider);
      final remoteTask = (await phone.readTasks()).single;
      expect(computerState.phase, LanSyncPhase.success);
      expect(phoneState.phase, LanSyncPhase.success);
      expect(phoneState.totalBytes, greaterThan(8 * 1024 * 1024));
      expect(phoneState.transferredBytes, phoneState.totalBytes);
      expect(remoteTask.detailImagesJson, contains('large-sync-image'));
      expect(
        await computer.computeSyncStateDigest(),
        await phone.computeSyncStateDigest(),
      );
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );
}
