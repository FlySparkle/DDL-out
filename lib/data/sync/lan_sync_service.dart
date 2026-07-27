import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../database/app_database.dart';
import '../repositories/repositories.dart';
import 'sync_models.dart';

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
    this.isCoordinator = false,
  });

  final LanSyncPhase phase;
  final String? qrData;
  final String? peerName;
  final String? errorMessage;
  final int sentOperations;
  final int receivedOperations;
  final int conflictCount;
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
      isCoordinator: isCoordinator ?? this.isCoordinator,
    );
  }
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
  static const _messageTimeout = Duration(seconds: 30);
  static const _maximumEncryptedFrameBytes = 8 * 1024 * 1024;

  final _uuid = const Uuid();
  final _cipher = AesGcm.with256bits();

  HttpServer? _server;
  WebSocket? _socket;
  Timer? _expiryTimer;
  bool _claimed = false;

  AppDatabase get _database => ref.read(appDatabaseProvider);

  @override
  LanSyncState build() {
    ref.onDispose(() {
      unawaited(_closeTransport());
    });
    return const LanSyncState();
  }

  Future<void> startHosting() async {
    await _closeTransport();
    state = const LanSyncState(
      phase: LanSyncPhase.preparing,
      isCoordinator: true,
    );
    try {
      final identity = await _database.readSyncIdentity();
      final addresses = await _privateIpv4Addresses();
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
      final qrData = jsonEncode({
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
          await _runHostSession(socket, SecretKey(keyBytes), token, expiresAt);
        } on Object catch (error) {
          _setError(error);
        }
      });
    } on Object catch (error) {
      _setError(error);
      await _closeTransport();
    }
  }

  Future<void> connectFromQr(String rawQrData) async {
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
      await _runClientSession(socket, key, token, spaceId);
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
  ) async {
    final iterator = StreamIterator<dynamic>(socket);
    try {
      final hello = await _nextMessage(iterator, key);
      if (hello['type'] != 'hello' ||
          hello['token'] != expectedToken ||
          DateTime.now().toUtc().isAfter(expiresAt)) {
        throw const FormatException('连接凭证无效或已经过期');
      }
      final peer = _identityFromJson(hello['identity']);
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
      });

      final push = await _nextMessage(iterator, key);
      if (push['type'] != 'push') {
        throw const FormatException('同步消息顺序不正确');
      }
      final incoming = _operationsFromJson(push['operations']);
      final applyReport = await _database.applyRemoteOperations(incoming);
      final outgoing = await _database.readOperationsMissingFrom(peer.vector);
      await _sendMessage(socket, key, {
        'type': 'pull',
        'operations': outgoing.map((operation) => operation.toJson()).toList(),
        'hostApplied': applyReport.applied,
      });

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
      state = state.copyWith(
        phase: LanSyncPhase.success,
        sentOperations: outgoing.length,
        receivedOperations: applyReport.applied,
        conflictCount: conflictCount,
        clearQrData: true,
        clearError: true,
      );
    } finally {
      await iterator.cancel();
      await _closeTransport(keepState: true);
    }
  }

  Future<void> _runClientSession(
    WebSocket socket,
    SecretKey key,
    String token,
    String expectedSpaceId,
  ) async {
    final iterator = StreamIterator<dynamic>(socket);
    try {
      final local = await _database.readSyncIdentity();
      await _sendMessage(socket, key, {
        'type': 'hello',
        'token': token,
        'identity': local.toJson(),
      });
      final acknowledgement = await _nextMessage(iterator, key);
      if (acknowledgement['type'] != 'helloAck') {
        throw const FormatException('电脑没有接受连接');
      }
      final host = _identityFromJson(acknowledgement['identity']);
      if (host.spaceId != expectedSpaceId) {
        throw const FormatException('电脑的同步空间发生了变化');
      }
      state = state.copyWith(
        phase: LanSyncPhase.transferring,
        peerName: host.deviceName,
      );
      final outgoing = await _database.readOperationsMissingFrom(host.vector);
      await _sendMessage(socket, key, {
        'type': 'push',
        'operations': outgoing.map((operation) => operation.toJson()).toList(),
      });
      final pull = await _nextMessage(iterator, key);
      if (pull['type'] != 'pull') {
        throw const FormatException('电脑返回了无效的同步内容');
      }
      final incoming = _operationsFromJson(pull['operations']);
      final report = await _database.applyRemoteOperations(incoming);
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
      state = state.copyWith(
        phase: LanSyncPhase.success,
        peerName: host.deviceName,
        sentOperations: outgoing.length,
        receivedOperations: report.applied,
        conflictCount: done['conflicts']! as int,
        clearError: true,
      );
    } finally {
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
    final socket = _socket;
    _socket = null;
    final server = _server;
    _server = null;
    _claimed = false;
    await socket?.close();
    await server?.close(force: true);
    if (!keepState && ref.mounted) state = const LanSyncState();
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
    final plainText = utf8.encode(jsonEncode(message));
    final nonce = _cipher.newNonce();
    final box = await _cipher.encrypt(plainText, secretKey: key, nonce: nonce);
    socket.add(
      jsonEncode({
        'nonce': base64UrlEncode(box.nonce),
        'cipherText': base64UrlEncode(box.cipherText),
        'mac': base64UrlEncode(box.mac.bytes),
      }),
    );
  }

  Future<Map<String, dynamic>> _decryptMessage(
    Object? raw,
    SecretKey key,
  ) async {
    if (raw is! String || raw.length > _maximumEncryptedFrameBytes) {
      throw const FormatException('同步消息格式无效');
    }
    final frame = jsonDecode(raw);
    if (frame is! Map<String, dynamic>) {
      throw const FormatException('同步消息格式无效');
    }
    final box = SecretBox(
      base64Url.decode(frame['cipherText']! as String),
      nonce: base64Url.decode(frame['nonce']! as String),
      mac: Mac(base64Url.decode(frame['mac']! as String)),
    );
    final clearText = await _cipher.decrypt(box, secretKey: key);
    final message = jsonDecode(utf8.decode(clearText));
    if (message is! Map<String, dynamic>) {
      throw const FormatException('同步消息内容无效');
    }
    return message;
  }

  Map<String, dynamic> _parseQrPayload(String source) {
    final value = jsonDecode(source);
    if (value is! Map<String, dynamic> ||
        value['type'] != 'ddl-out-lan-sync' ||
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

  List<SyncOperationEnvelope> _operationsFromJson(Object? raw) {
    if (raw is! List) throw const FormatException('同步操作列表无效');
    return raw
        .map(
          (item) => SyncOperationEnvelope.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList(growable: false);
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
