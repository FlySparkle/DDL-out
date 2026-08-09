import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:crypto/crypto.dart' as crypto;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../database/app_database.dart';
import '../repositories/repositories.dart';
import 'sync_models.dart';

sealed class _PreparedOperationPayload {
  const _PreparedOperationPayload();

  int get length;
  String get sha256;
  Stream<Uint8List> chunks();
  Future<void> dispose();
}

final class _MemoryOperationPayload extends _PreparedOperationPayload {
  const _MemoryOperationPayload(this.bytes, this.sha256);

  final Uint8List bytes;
  @override
  final String sha256;

  @override
  int get length => bytes.length;

  @override
  Stream<Uint8List> chunks() async* {
    yield* Stream.fromIterable(SyncTransferCodec.chunks(bytes));
  }

  @override
  Future<void> dispose() async {}
}

final class _FileOperationPayload extends _PreparedOperationPayload {
  const _FileOperationPayload(this.file, this.length, this.sha256);

  final File file;
  @override
  final int length;
  @override
  final String sha256;

  @override
  Stream<Uint8List> chunks() async* {
    final reader = await file.open();
    try {
      while (true) {
        final bytes = await reader.read(SyncTransferCodec.chunkSizeBytes);
        if (bytes.isEmpty) break;
        yield Uint8List.fromList(bytes);
      }
    } finally {
      await reader.close();
    }
  }

  @override
  Future<void> dispose() async {
    if (await file.exists()) await file.delete();
  }
}

final class _PreparedSyncTransfer {
  const _PreparedSyncTransfer(this.payloads, this.totalBytes);

  final List<_PreparedOperationPayload> payloads;
  final int totalBytes;

  int get operationCount => payloads.length;

  Future<void> dispose() async {
    for (final payload in payloads) {
      await payload.dispose();
    }
  }
}

final class _SyncTransferPlan {
  const _SyncTransferPlan(this.operationCount, this.totalBytes);

  final int operationCount;
  final int totalBytes;
}

enum LanSyncPhase {
  idle,
  preparing,
  waiting,
  connecting,
  transferring,
  success,
  error,
}

@immutable
class LanSyncState {
  const LanSyncState({
    this.phase = LanSyncPhase.idle,
    this.qrData,
    this.peerName,
    this.errorMessage,
    this.sentOperations = 0,
    this.receivedOperations = 0,
    this.conflictCount = 0,
    this.transferredBytes = 0,
    this.totalBytes = 0,
    this.isCoordinator = false,
  });

  final LanSyncPhase phase;
  final String? qrData;
  final String? peerName;
  final String? errorMessage;
  final int sentOperations;
  final int receivedOperations;
  final int conflictCount;
  final int transferredBytes;
  final int totalBytes;
  final bool isCoordinator;

  LanSyncState copyWith({
    LanSyncPhase? phase,
    String? qrData,
    bool clearQrData = false,
    String? peerName,
    String? errorMessage,
    bool clearError = false,
    int? sentOperations,
    int? receivedOperations,
    int? conflictCount,
    int? transferredBytes,
    int? totalBytes,
    bool? isCoordinator,
  }) {
    return LanSyncState(
      phase: phase ?? this.phase,
      qrData: clearQrData ? null : qrData ?? this.qrData,
      peerName: peerName ?? this.peerName,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      sentOperations: sentOperations ?? this.sentOperations,
      receivedOperations: receivedOperations ?? this.receivedOperations,
      conflictCount: conflictCount ?? this.conflictCount,
      transferredBytes: transferredBytes ?? this.transferredBytes,
      totalBytes: totalBytes ?? this.totalBytes,
      isCoordinator: isCoordinator ?? this.isCoordinator,
    );
  }
}

String formatSyncByteCount(int byteCount) {
  if (byteCount < 1024) return '$byteCount B';
  final kibibytes = byteCount / 1024;
  if (kibibytes < 1024) return '${_formatSyncUnit(kibibytes)} KB';
  return '${_formatSyncUnit(kibibytes / 1024)} MB';
}

String _formatSyncUnit(double value) {
  return value >= 100 || value == value.roundToDouble()
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(1);
}

final lanSyncControllerProvider =
    NotifierProvider<LanSyncController, LanSyncState>(LanSyncController.new);

final syncConflictCountProvider = StreamProvider<int>((ref) {
  return ref.watch(appDatabaseProvider).watchOpenConflictCount();
});

final syncConflictsProvider = StreamProvider<List<SyncConflictView>>((ref) {
  return ref.watch(appDatabaseProvider).watchOpenConflicts();
});

final syncDevicesProvider = StreamProvider<List<SyncDevice>>((ref) {
  return ref.watch(appDatabaseProvider).watchSyncDevices();
});

class LanSyncController extends Notifier<LanSyncState> {
  static const _sessionLifetime = Duration(minutes: 2);
  static const _messageTimeout = Duration(minutes: 2);
  static const _progressRefreshInterval = Duration(milliseconds: 200);
  static const _maximumEncryptedFrameBytes =
      SyncTransferCodec.chunkSizeBytes + 1024;
  static const _maximumOperationBytes = 256 * 1024 * 1024;
  static const _temporaryFileThresholdBytes = 8 * 1024 * 1024;
  static const _encryptedNonceBytes = 12;
  static const _encryptedMacBytes = 16;
  static const _pushChunkKind = 1;
  static const _pullChunkKind = 2;

  final _uuid = const Uuid();
  final _cipher = AesGcm.with256bits();

  HttpServer? _server;
  WebSocket? _socket;
  Timer? _expiryTimer;
  Timer? _progressTimer;
  bool _claimed = false;
  int _transferredBytes = 0;
  int _totalBytes = 0;
  final Set<File> _temporaryFiles = {};

  AppDatabase get _database => ref.read(appDatabaseProvider);

  @override
  LanSyncState build() {
    ref.onDispose(() {
      unawaited(_closeTransport());
    });
    return const LanSyncState();
  }

  Future<void> startHosting({
    bool largeTransferEnabled = false,
    @visibleForTesting List<String>? hostAddressesOverride,
  }) async {
    await _closeTransport();
    state = const LanSyncState(
      phase: LanSyncPhase.preparing,
      isCoordinator: true,
    );
    try {
      final identity = await _database.readSyncIdentity();
      final addresses = hostAddressesOverride ?? await _privateIpv4Addresses();
      if (addresses.isEmpty) {
        throw const SocketException('没有可用的局域网 IPv4 地址');
      }
      final server = await HttpServer.bind(InternetAddress.anyIPv4, 0);
      _server = server;
      final token = _uuid.v4();
      final keyBytes = List<int>.generate(
        32,
        (_) => Random.secure().nextInt(256),
        growable: false,
      );
      final expiresAt = DateTime.now().toUtc().add(_sessionLifetime);
      final qrData = SyncPairingKeyCodec.encode({
        'type': 'ddl-out-lan-sync',
        'version': syncProtocolVersion,
        'hosts': addresses,
        'port': server.port,
        'token': token,
        'key': base64UrlEncode(keyBytes),
        'spaceId': identity.spaceId,
        'expiresAtUtc': expiresAt.toIso8601String(),
      });
      state = LanSyncState(
        phase: LanSyncPhase.waiting,
        qrData: qrData,
        isCoordinator: true,
      );
      _expiryTimer = Timer(_sessionLifetime, () {
        if (state.phase == LanSyncPhase.waiting) {
          unawaited(stop());
        }
      });
      server.listen((request) async {
        if (request.uri.path != '/sync' ||
            !WebSocketTransformer.isUpgradeRequest(request) ||
            _claimed) {
          request.response.statusCode = HttpStatus.forbidden;
          await request.response.close();
          return;
        }
        _claimed = true;
        try {
          final socket = await WebSocketTransformer.upgrade(request);
          _socket = socket;
          await _runHostSession(
            socket,
            SecretKey(keyBytes),
            token,
            expiresAt,
            largeTransferEnabled,
          );
        } on Object catch (error) {
          _setError(error);
        }
      });
    } on Object catch (error) {
      _setError(error);
      await _closeTransport();
    }
  }

  Future<void> connectFromQr(
    String rawQrData, {
    bool largeTransferEnabled = false,
  }) async {
    await _closeTransport();
    state = const LanSyncState(phase: LanSyncPhase.connecting);
    try {
      final payload = _parseQrPayload(rawQrData);
      final expiresAt = DateTime.parse(payload['expiresAtUtc']! as String);
      if (DateTime.now().toUtc().isAfter(expiresAt)) {
        throw const FormatException('二维码已经过期，请在电脑上刷新');
      }
      final spaceId = payload['spaceId']! as String;
      await _database.adoptSyncSpace(spaceId);
      final hosts = (payload['hosts']! as List).cast<String>();
      final port = payload['port']! as int;
      final token = payload['token']! as String;
      final key = SecretKey(base64Url.decode(payload['key']! as String));
      Object? lastError;
      WebSocket? socket;
      for (final host in hosts) {
        try {
          socket = await WebSocket.connect(
            'ws://$host:$port/sync',
          ).timeout(const Duration(seconds: 5));
          break;
        } on Object catch (error) {
          lastError = error;
        }
      }
      if (socket == null) {
        throw SocketException('无法连接电脑，请确认两端在同一局域网：$lastError');
      }
      _socket = socket;
      await _runClientSession(
        socket,
        key,
        token,
        spaceId,
        largeTransferEnabled,
      );
    } on Object catch (error) {
      _setError(error);
      await _closeTransport(keepState: true);
    }
  }

  Future<void> _runHostSession(
    WebSocket socket,
    SecretKey key,
    String expectedToken,
    DateTime expiresAt,
    bool localLargeTransferEnabled,
  ) async {
    final iterator = StreamIterator<dynamic>(socket);
    _PreparedSyncTransfer? outgoingTransfer;
    try {
      final hello = await _nextMessage(iterator, key);
      if (hello['type'] != 'hello' ||
          hello['token'] != expectedToken ||
          DateTime.now().toUtc().isAfter(expiresAt)) {
        throw const FormatException('连接凭证无效或已经过期');
      }
      final peer = _identityFromJson(hello['identity']);
      final useLargeTransfer =
          localLargeTransferEnabled && hello['largeTransferEnabled'] == true;
      final local = await _database.readSyncIdentity();
      if (peer.spaceId != local.spaceId) {
        throw const FormatException('两端不属于同一个同步空间');
      }
      state = state.copyWith(
        phase: LanSyncPhase.transferring,
        peerName: peer.deviceName,
        clearQrData: true,
      );
      await _database.registerSyncPeer(
        peer.deviceId,
        peer.deviceName,
        peer.vector,
      );
      await _sendMessage(socket, key, {
        'type': 'helloAck',
        'identity': local.toJson(),
        'largeTransferEnabled': localLargeTransferEnabled,
      });

      final incomingPlan = _transferPlanFromMessage(
        await _nextMessage(iterator, key),
        'pushPlan',
        useLargeTransfer,
      );
      final outgoing = await _database.readOperationsMissingFrom(peer.vector);
      outgoingTransfer = await _prepareTransfer(
        outgoing,
        allowLargeTransfer: useLargeTransfer,
      );
      await _sendMessage(socket, key, {
        'type': 'pullPlan',
        'operationCount': outgoingTransfer.operationCount,
        'totalBytes': outgoingTransfer.totalBytes,
        'largeTransfer': useLargeTransfer,
      });
      _beginTransferProgress(
        incomingPlan.totalBytes + outgoingTransfer.totalBytes,
      );
      final applyReport = await _receiveOperationTransfer(
        socket: socket,
        iterator: iterator,
        key: key,
        direction: 'push',
        chunkKind: _pushChunkKind,
        plan: incomingPlan,
        allowLargeTransfer: useLargeTransfer,
      );
      await _sendOperationTransfer(
        socket: socket,
        iterator: iterator,
        key: key,
        direction: 'pull',
        chunkKind: _pullChunkKind,
        transfer: outgoingTransfer,
      );

      final complete = await _nextMessage(iterator, key);
      if (complete['type'] != 'complete') {
        throw const FormatException('同步未正常完成');
      }
      final finalPeer = _identityFromJson(complete['identity']);
      final localDigest = await _database.computeSyncStateDigest();
      final digestMatches = complete['digest'] == localDigest;
      await _database.registerSyncPeer(
        finalPeer.deviceId,
        finalPeer.deviceName,
        finalPeer.vector,
      );
      final conflictCount = await _database.openConflictCount();
      await _sendMessage(socket, key, {
        'type': 'done',
        'digestMatches': digestMatches,
        'conflicts': conflictCount,
        'identity': (await _database.readSyncIdentity()).toJson(),
      });
      if (!digestMatches) {
        throw const FormatException('两端校验结果不一致，请重新同步');
      }
      _publishTransferProgress();
      state = state.copyWith(
        phase: LanSyncPhase.success,
        sentOperations: outgoingTransfer.operationCount,
        receivedOperations: applyReport.applied,
        conflictCount: conflictCount,
        clearQrData: true,
        clearError: true,
      );
    } finally {
      await outgoingTransfer?.dispose();
      await iterator.cancel();
      await _closeTransport(keepState: true);
    }
  }

  Future<void> _runClientSession(
    WebSocket socket,
    SecretKey key,
    String token,
    String expectedSpaceId,
    bool localLargeTransferEnabled,
  ) async {
    final iterator = StreamIterator<dynamic>(socket);
    _PreparedSyncTransfer? outgoingTransfer;
    try {
      final local = await _database.readSyncIdentity();
      await _sendMessage(socket, key, {
        'type': 'hello',
        'token': token,
        'identity': local.toJson(),
        'largeTransferEnabled': localLargeTransferEnabled,
      });
      final acknowledgement = await _nextMessage(iterator, key);
      if (acknowledgement['type'] != 'helloAck') {
        throw const FormatException('电脑没有接受连接');
      }
      final host = _identityFromJson(acknowledgement['identity']);
      final useLargeTransfer =
          localLargeTransferEnabled &&
          acknowledgement['largeTransferEnabled'] == true;
      if (host.spaceId != expectedSpaceId) {
        throw const FormatException('电脑的同步空间发生了变化');
      }
      state = state.copyWith(
        phase: LanSyncPhase.transferring,
        peerName: host.deviceName,
      );
      final outgoing = await _database.readOperationsMissingFrom(host.vector);
      outgoingTransfer = await _prepareTransfer(
        outgoing,
        allowLargeTransfer: useLargeTransfer,
      );
      await _sendMessage(socket, key, {
        'type': 'pushPlan',
        'operationCount': outgoingTransfer.operationCount,
        'totalBytes': outgoingTransfer.totalBytes,
        'largeTransfer': useLargeTransfer,
      });
      final incomingPlan = _transferPlanFromMessage(
        await _nextMessage(iterator, key),
        'pullPlan',
        useLargeTransfer,
      );
      _beginTransferProgress(
        outgoingTransfer.totalBytes + incomingPlan.totalBytes,
      );
      await _sendOperationTransfer(
        socket: socket,
        iterator: iterator,
        key: key,
        direction: 'push',
        chunkKind: _pushChunkKind,
        transfer: outgoingTransfer,
      );
      final report = await _receiveOperationTransfer(
        socket: socket,
        iterator: iterator,
        key: key,
        direction: 'pull',
        chunkKind: _pullChunkKind,
        plan: incomingPlan,
        allowLargeTransfer: useLargeTransfer,
      );
      await _sendMessage(socket, key, {
        'type': 'complete',
        'digest': await _database.computeSyncStateDigest(),
        'identity': (await _database.readSyncIdentity()).toJson(),
      });
      final done = await _nextMessage(iterator, key);
      if (done['type'] != 'done' || done['digestMatches'] != true) {
        throw const FormatException('两端校验结果不一致，请重新同步');
      }
      final finalHost = _identityFromJson(done['identity']);
      await _database.registerSyncPeer(
        finalHost.deviceId,
        finalHost.deviceName,
        finalHost.vector,
      );
      _publishTransferProgress();
      state = state.copyWith(
        phase: LanSyncPhase.success,
        peerName: host.deviceName,
        sentOperations: outgoingTransfer.operationCount,
        receivedOperations: report.applied,
        conflictCount: done['conflicts']! as int,
        clearError: true,
      );
    } finally {
      await outgoingTransfer?.dispose();
      await iterator.cancel();
      await _closeTransport(keepState: true);
    }
  }

  Future<void> stop() async {
    await _closeTransport();
    state = const LanSyncState();
  }

  void allowResolveHere() {
    state = state.copyWith(isCoordinator: true);
  }

  Future<void> _closeTransport({bool keepState = false}) async {
    _expiryTimer?.cancel();
    _expiryTimer = null;
    _progressTimer?.cancel();
    _progressTimer = null;
    final socket = _socket;
    _socket = null;
    final server = _server;
    _server = null;
    _claimed = false;
    await socket?.close();
    await server?.close(force: true);
    for (final file in _temporaryFiles.toList()) {
      if (await file.exists()) await file.delete();
      _temporaryFiles.remove(file);
    }
    if (!keepState && ref.mounted) state = const LanSyncState();
  }

  Future<_PreparedSyncTransfer> _prepareTransfer(
    List<SyncOperationEnvelope> operations, {
    required bool allowLargeTransfer,
  }) async {
    final payloads = <_PreparedOperationPayload>[];
    var totalBytes = 0;
    for (final operation in operations) {
      final payload = SyncTransferCodec.encodeOperation(operation);
      if (!allowLargeTransfer && payload.length > _maximumOperationBytes) {
        throw const FormatException('单项同步数据过大，无法安全传输');
      }
      final digest = crypto.sha256.convert(payload).toString();
      if (allowLargeTransfer && payload.length > _temporaryFileThresholdBytes) {
        final file = _createTemporaryFile();
        await file.writeAsBytes(payload, flush: true);
        payloads.add(_FileOperationPayload(file, payload.length, digest));
      } else {
        payloads.add(_MemoryOperationPayload(payload, digest));
      }
      totalBytes += payload.length;
    }
    return _PreparedSyncTransfer(payloads, totalBytes);
  }

  _SyncTransferPlan _transferPlanFromMessage(
    Map<String, dynamic> message,
    String expectedType,
    bool expectedLargeTransfer,
  ) {
    final operationCount = message['operationCount'];
    final totalBytes = message['totalBytes'];
    if (message['type'] != expectedType ||
        operationCount is! int ||
        operationCount < 0 ||
        operationCount > 1000000 ||
        totalBytes is! int ||
        totalBytes < 0 ||
        message['largeTransfer'] != expectedLargeTransfer ||
        (operationCount == 0 && totalBytes != 0) ||
        (operationCount > 0 && totalBytes == 0)) {
      throw const FormatException('同步传输计划无效');
    }
    return _SyncTransferPlan(operationCount, totalBytes);
  }

  Future<void> _sendOperationTransfer({
    required WebSocket socket,
    required StreamIterator<dynamic> iterator,
    required SecretKey key,
    required String direction,
    required int chunkKind,
    required _PreparedSyncTransfer transfer,
  }) async {
    for (final (index, payload) in transfer.payloads.indexed) {
      await _sendMessage(socket, key, {
        'type': '${direction}Operation',
        'index': index,
        'byteLength': payload.length,
        'sha256': payload.sha256,
      });
      final operationAck = await _nextMessage(iterator, key);
      if (operationAck['type'] != '${direction}OperationAck' ||
          operationAck['index'] != index) {
        throw const FormatException('同步操作确认无效');
      }
      var offset = 0;
      await for (final chunk in payload.chunks()) {
        await _sendPayloadChunk(
          socket: socket,
          key: key,
          chunkKind: chunkKind,
          offset: offset,
          bytes: chunk,
        );
        final chunkAck = await _nextMessage(iterator, key);
        final nextOffset = offset + chunk.length;
        if (chunkAck['type'] != '${direction}ChunkAck' ||
            chunkAck['index'] != index ||
            chunkAck['nextOffset'] != nextOffset) {
          throw const FormatException('同步分块确认无效');
        }
        offset = nextOffset;
        _recordTransferredBytes(chunk.length);
      }
    }
  }

  Future<SyncApplyReport> _receiveOperationTransfer({
    required WebSocket socket,
    required StreamIterator<dynamic> iterator,
    required SecretKey key,
    required String direction,
    required int chunkKind,
    required _SyncTransferPlan plan,
    required bool allowLargeTransfer,
  }) async {
    var applied = 0;
    var duplicates = 0;
    var receivedBytes = 0;
    for (var index = 0; index < plan.operationCount; index += 1) {
      final operationMessage = await _nextMessage(iterator, key);
      final byteLength = operationMessage['byteLength'];
      final expectedDigest = operationMessage['sha256'];
      if (operationMessage['type'] != '${direction}Operation' ||
          operationMessage['index'] != index ||
          byteLength is! int ||
          byteLength <= 0 ||
          (!allowLargeTransfer && byteLength > _maximumOperationBytes) ||
          expectedDigest is! String ||
          !RegExp(r'^[0-9a-f]{64}$').hasMatch(expectedDigest) ||
          receivedBytes + byteLength > plan.totalBytes) {
        throw const FormatException('同步操作分块信息无效');
      }
      await _sendMessage(socket, key, {
        'type': '${direction}OperationAck',
        'index': index,
      });
      final builder = BytesBuilder(copy: false);
      final useTemporaryFile =
          allowLargeTransfer && byteLength > _temporaryFileThresholdBytes;
      final temporaryFile = useTemporaryFile ? _createTemporaryFile() : null;
      final sink = temporaryFile?.openWrite();
      var operationBytes = 0;
      while (operationBytes < byteLength) {
        final chunk = await _nextPayloadChunk(
          iterator: iterator,
          key: key,
          expectedChunkKind: chunkKind,
          expectedOffset: operationBytes,
        );
        if (operationBytes + chunk.length > byteLength) {
          throw const FormatException('同步分块超出声明大小');
        }
        if (sink != null) {
          sink.add(chunk);
        } else {
          builder.add(chunk);
        }
        operationBytes += chunk.length;
        receivedBytes += chunk.length;
        _recordTransferredBytes(chunk.length);
        await _sendMessage(socket, key, {
          'type': '${direction}ChunkAck',
          'index': index,
          'nextOffset': operationBytes,
        });
      }
      await sink?.flush();
      await sink?.close();
      final bytes = temporaryFile == null
          ? builder.takeBytes()
          : await temporaryFile.readAsBytes();
      if (crypto.sha256.convert(bytes).toString() != expectedDigest) {
        throw const FormatException('同步数据校验失败');
      }
      final operation = SyncTransferCodec.decodeOperation(bytes);
      if (temporaryFile != null) {
        await temporaryFile.delete();
        _temporaryFiles.remove(temporaryFile);
      }
      final report = await _database.applyRemoteOperations([operation]);
      applied += report.applied;
      duplicates += report.duplicates;
    }
    if (receivedBytes != plan.totalBytes) {
      throw const FormatException('同步传输大小与计划不一致');
    }
    return SyncApplyReport(
      applied: applied,
      duplicates: duplicates,
      conflicts: await _database.openConflictCount(),
    );
  }

  void _beginTransferProgress(int totalBytes) {
    _progressTimer?.cancel();
    _progressTimer = null;
    _transferredBytes = 0;
    _totalBytes = totalBytes;
    if (!ref.mounted) return;
    state = state.copyWith(transferredBytes: 0, totalBytes: totalBytes);
  }

  File _createTemporaryFile() {
    final file = File(
      '${Directory.systemTemp.path}${Platform.pathSeparator}'
      'ddl_out_sync_${_uuid.v4()}.part',
    );
    _temporaryFiles.add(file);
    return file;
  }

  void _recordTransferredBytes(int byteCount) {
    _transferredBytes += byteCount;
    if (_progressTimer != null) return;
    _progressTimer = Timer(_progressRefreshInterval, () {
      _progressTimer = null;
      _publishTransferProgress();
    });
  }

  void _publishTransferProgress() {
    _progressTimer?.cancel();
    _progressTimer = null;
    if (!ref.mounted) return;
    state = state.copyWith(
      transferredBytes: _transferredBytes.clamp(0, _totalBytes),
      totalBytes: _totalBytes,
    );
  }

  Future<Map<String, dynamic>> _nextMessage(
    StreamIterator<dynamic> iterator,
    SecretKey key,
  ) async {
    final hasMessage = await iterator.moveNext().timeout(_messageTimeout);
    if (!hasMessage) throw const SocketException('连接已关闭');
    return _decryptMessage(iterator.current, key);
  }

  Future<void> _sendMessage(
    WebSocket socket,
    SecretKey key,
    Map<String, Object?> message,
  ) async {
    final plainText = Uint8List.fromList(utf8.encode(jsonEncode(message)));
    await _sendEncryptedFrame(socket, key, plainText);
  }

  Future<void> _sendPayloadChunk({
    required WebSocket socket,
    required SecretKey key,
    required int chunkKind,
    required int offset,
    required Uint8List bytes,
  }) async {
    final plainText = Uint8List(9 + bytes.length);
    plainText[0] = chunkKind;
    ByteData.sublistView(plainText, 1, 9).setUint64(0, offset, Endian.big);
    plainText.setRange(9, plainText.length, bytes);
    await _sendEncryptedFrame(socket, key, plainText);
  }

  Future<void> _sendEncryptedFrame(
    WebSocket socket,
    SecretKey key,
    Uint8List plainText,
  ) async {
    final nonce = _cipher.newNonce();
    final box = await _cipher.encrypt(plainText, secretKey: key, nonce: nonce);
    final frame = Uint8List(
      _encryptedNonceBytes + _encryptedMacBytes + box.cipherText.length,
    );
    frame.setRange(0, _encryptedNonceBytes, box.nonce);
    frame.setRange(
      _encryptedNonceBytes,
      _encryptedNonceBytes + _encryptedMacBytes,
      box.mac.bytes,
    );
    frame.setRange(
      _encryptedNonceBytes + _encryptedMacBytes,
      frame.length,
      box.cipherText,
    );
    socket.add(frame);
  }

  Future<Map<String, dynamic>> _decryptMessage(
    Object? raw,
    SecretKey key,
  ) async {
    final clearText = await _decryptFrame(raw, key);
    final message = jsonDecode(utf8.decode(clearText));
    if (message is! Map<String, dynamic>) {
      throw const FormatException('同步消息内容无效');
    }
    return message;
  }

  Future<Uint8List> _nextPayloadChunk({
    required StreamIterator<dynamic> iterator,
    required SecretKey key,
    required int expectedChunkKind,
    required int expectedOffset,
  }) async {
    final hasMessage = await iterator.moveNext().timeout(_messageTimeout);
    if (!hasMessage) throw const SocketException('连接已关闭');
    final clearText = await _decryptFrame(iterator.current, key);
    if (clearText.length <= 9 ||
        clearText[0] != expectedChunkKind ||
        clearText.length - 9 > SyncTransferCodec.chunkSizeBytes) {
      throw const FormatException('同步数据分块无效');
    }
    final offset = ByteData.sublistView(
      clearText,
      1,
      9,
    ).getUint64(0, Endian.big);
    if (offset != expectedOffset) {
      throw const FormatException('同步数据分块顺序无效');
    }
    return Uint8List.sublistView(clearText, 9);
  }

  Future<Uint8List> _decryptFrame(Object? raw, SecretKey key) async {
    if (raw is! List<int> ||
        raw.length < _encryptedNonceBytes + _encryptedMacBytes + 1 ||
        raw.length > _maximumEncryptedFrameBytes) {
      throw const FormatException('同步消息格式无效');
    }
    final frame = Uint8List.fromList(raw);
    final cipherTextStart = _encryptedNonceBytes + _encryptedMacBytes;
    final box = SecretBox(
      Uint8List.sublistView(frame, cipherTextStart),
      nonce: Uint8List.sublistView(frame, 0, _encryptedNonceBytes),
      mac: Mac(
        Uint8List.sublistView(frame, _encryptedNonceBytes, cipherTextStart),
      ),
    );
    return Uint8List.fromList(await _cipher.decrypt(box, secretKey: key));
  }

  Map<String, dynamic> _parseQrPayload(String source) {
    final value = SyncPairingKeyCodec.decode(source);
    if (value['type'] != 'ddl-out-lan-sync' ||
        value['version'] != syncProtocolVersion ||
        value['hosts'] is! List ||
        value['port'] is! int ||
        value['token'] is! String ||
        value['key'] is! String ||
        value['spaceId'] is! String ||
        value['expiresAtUtc'] is! String) {
      throw const FormatException('这不是有效的 DDL out! 同步二维码');
    }
    return value;
  }

  SyncIdentity _identityFromJson(Object? raw) {
    if (raw is! Map<String, dynamic> ||
        raw['protocolVersion'] != syncProtocolVersion ||
        raw['spaceId'] is! String ||
        raw['deviceId'] is! String ||
        raw['deviceName'] is! String ||
        raw['vector'] is! Map<String, dynamic>) {
      throw const FormatException('设备身份信息无效');
    }
    return SyncIdentity(
      spaceId: raw['spaceId']! as String,
      deviceId: raw['deviceId']! as String,
      deviceName: raw['deviceName']! as String,
      vector: VersionVector({
        for (final entry in (raw['vector']! as Map<String, dynamic>).entries)
          entry.key: entry.value as int,
      }),
    );
  }

  Future<List<String>> _privateIpv4Addresses() async {
    final interfaces = await NetworkInterface.list(
      type: InternetAddressType.IPv4,
      includeLoopback: false,
      includeLinkLocal: false,
    );
    final addresses = <String>{};
    for (final interface in interfaces) {
      for (final address in interface.addresses) {
        if (_isPrivateIpv4(address.address)) addresses.add(address.address);
      }
    }
    return addresses.toList(growable: false);
  }

  bool _isPrivateIpv4(String value) {
    final parts = value.split('.').map(int.tryParse).toList();
    if (parts.length != 4 || parts.any((part) => part == null)) return false;
    final first = parts[0]!;
    final second = parts[1]!;
    return first == 10 ||
        (first == 172 && second >= 16 && second <= 31) ||
        (first == 192 && second == 168);
  }

  void _setError(Object error) {
    if (!ref.mounted) return;
    final message = switch (error) {
      FormatException(:final message) => message,
      SocketException(:final message) => message,
      TimeoutException() => '连接超时，请确认两端在同一局域网',
      _ => '同步失败：$error',
    };
    state = state.copyWith(
      phase: LanSyncPhase.error,
      errorMessage: message,
      clearQrData: true,
    );
  }
}
