import 'dart:convert';
import 'dart:typed_data';

const syncProtocolVersion = 5;

abstract final class SyncPairingKeyCodec {
  static const prefix = 'DDL5:';

  static String encode(Map<String, Object?> payload) {
    final encoded = base64Url.encode(utf8.encode(jsonEncode(payload)));
    return '$prefix${encoded.replaceAll('=', '')}';
  }

  static Map<String, dynamic> decode(String source) {
    final normalized = source.trim();
    if (normalized.startsWith('{')) {
      final decoded = jsonDecode(normalized);
      if (decoded is Map<String, dynamic>) return decoded;
      throw const FormatException('Invalid pairing information.');
    }
    if (!normalized.startsWith(prefix)) {
      throw const FormatException('Invalid pairing key.');
    }
    final body = normalized.substring(prefix.length);
    final padded = body.padRight(body.length + (4 - body.length % 4) % 4, '=');
    final decoded = jsonDecode(utf8.decode(base64Url.decode(padded)));
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid pairing information.');
    }
    return decoded;
  }
}

abstract final class SyncEntityType {
  static const category = 'category';
  static const task = 'task';
}

abstract final class SyncOperationKind {
  static const create = 'create';
  static const patch = 'patch';
  static const delete = 'delete';
  static const restore = 'restore';
  static const resolve = 'resolve';
}

abstract final class SyncField {
  static const name = 'name';
  static const colorArgb = 'colorArgb';
  static const positionKey = 'positionKey';
  static const details = 'details';
  static const detailImages = 'detailImages';
  static const deadlineUtc = 'deadlineUtc';
  static const categorySyncId = 'categorySyncId';
  static const completion = 'completion';
  static const deleted = '__deleted';
}

final class VersionVector {
  VersionVector([Map<String, int>? values]) : _values = {...?values};

  factory VersionVector.fromJsonString(String source) {
    final decoded = jsonDecode(source);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Version vector must be an object');
    }
    return VersionVector({
      for (final entry in decoded.entries)
        if (entry.value is int && (entry.value as int) >= 0)
          entry.key: entry.value as int,
    });
  }

  final Map<String, int> _values;

  int operator [](String deviceId) => _values[deviceId] ?? 0;

  Map<String, int> toJson() => Map.unmodifiable(_values);

  String toJsonString() {
    final keys = _values.keys.toList()..sort();
    return jsonEncode({for (final key in keys) key: _values[key]});
  }

  void observe(String deviceId, int sequence) {
    if (sequence > this[deviceId]) _values[deviceId] = sequence;
  }

  void join(VersionVector other) {
    for (final entry in other._values.entries) {
      observe(entry.key, entry.value);
    }
  }

  bool containsDot(String deviceId, int sequence) => this[deviceId] >= sequence;

  bool covers(VersionVector other) {
    return other._values.entries.every(
      (entry) => this[entry.key] >= entry.value,
    );
  }

  VersionVector copy() => VersionVector(_values);
}

final class SyncOperationEnvelope {
  const SyncOperationEnvelope({
    required this.operationId,
    required this.originDeviceId,
    required this.originSequence,
    required this.context,
    required this.hlcMillis,
    required this.hlcCounter,
    required this.entityType,
    required this.entitySyncId,
    required this.kind,
    required this.changes,
    required this.occurredAtUtc,
    this.transactionId,
    this.transactionIndex,
    this.transactionCount,
    this.resolves = const [],
  });

  factory SyncOperationEnvelope.fromJson(Map<String, dynamic> json) {
    final rawContext = json['context'];
    final rawChanges = json['changes'];
    final rawResolves = json['resolves'];
    if (rawContext is! Map<String, dynamic> ||
        rawChanges is! Map<String, dynamic>) {
      throw const FormatException('Invalid synchronization operation');
    }
    return SyncOperationEnvelope(
      operationId: json['operationId']! as String,
      originDeviceId: json['originDeviceId']! as String,
      originSequence: json['originSequence']! as int,
      context: VersionVector({
        for (final entry in rawContext.entries) entry.key: entry.value as int,
      }),
      hlcMillis: json['hlcMillis']! as int,
      hlcCounter: json['hlcCounter']! as int,
      transactionId: json['transactionId'] as String?,
      transactionIndex: json['transactionIndex'] as int?,
      transactionCount: json['transactionCount'] as int?,
      entityType: json['entityType']! as String,
      entitySyncId: json['entitySyncId']! as String,
      kind: json['kind']! as String,
      changes: Map<String, Object?>.from(rawChanges),
      resolves: rawResolves is List
          ? rawResolves.whereType<String>().toList(growable: false)
          : const [],
      occurredAtUtc: DateTime.parse(json['occurredAtUtc']! as String).toUtc(),
    );
  }

  final String operationId;
  final String originDeviceId;
  final int originSequence;
  final VersionVector context;
  final int hlcMillis;
  final int hlcCounter;
  final String? transactionId;
  final int? transactionIndex;
  final int? transactionCount;
  final String entityType;
  final String entitySyncId;
  final String kind;
  final Map<String, Object?> changes;
  final List<String> resolves;
  final DateTime occurredAtUtc;

  Map<String, Object?> toJson() => {
    'protocolVersion': syncProtocolVersion,
    'operationId': operationId,
    'originDeviceId': originDeviceId,
    'originSequence': originSequence,
    'context': context.toJson(),
    'hlcMillis': hlcMillis,
    'hlcCounter': hlcCounter,
    'transactionId': transactionId,
    'transactionIndex': transactionIndex,
    'transactionCount': transactionCount,
    'entityType': entityType,
    'entitySyncId': entitySyncId,
    'kind': kind,
    'changes': changes,
    'resolves': resolves,
    'occurredAtUtc': occurredAtUtc.toUtc().toIso8601String(),
  };

  bool causallyIncludes(SyncOperationEnvelope other) =>
      context.containsDot(other.originDeviceId, other.originSequence);

  String get canonicalJson => jsonEncode(toJson());
}

abstract final class SyncTransferCodec {
  static const int chunkSizeBytes = 512 * 1024;

  static Uint8List encodeOperation(SyncOperationEnvelope operation) {
    return Uint8List.fromList(utf8.encode(jsonEncode(operation.toJson())));
  }

  static SyncOperationEnvelope decodeOperation(List<int> bytes) {
    final decoded = jsonDecode(utf8.decode(bytes));
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException(
        'Synchronization operation must be an object',
      );
    }
    return SyncOperationEnvelope.fromJson(decoded);
  }

  static Iterable<Uint8List> chunks(Uint8List payload) sync* {
    for (var offset = 0; offset < payload.length; offset += chunkSizeBytes) {
      final end = (offset + chunkSizeBytes).clamp(0, payload.length);
      yield Uint8List.sublistView(payload, offset, end);
    }
  }
}

final class SyncConflictView {
  const SyncConflictView({
    required this.id,
    required this.entityType,
    required this.entitySyncId,
    required this.entityName,
    required this.fieldName,
    required this.candidates,
    required this.detectedAtUtc,
  });

  final String id;
  final String entityType;
  final String entitySyncId;
  final String entityName;
  final String fieldName;
  final List<SyncConflictCandidate> candidates;
  final DateTime detectedAtUtc;
}

final class SyncConflictCandidate {
  const SyncConflictCandidate({
    required this.operationId,
    required this.deviceId,
    required this.deviceName,
    required this.value,
    required this.occurredAtUtc,
    this.displayValue,
  });

  final String operationId;
  final String deviceId;
  final String deviceName;
  final Object? value;
  final Object? displayValue;
  final DateTime occurredAtUtc;
}

final class SyncApplyReport {
  const SyncApplyReport({
    required this.applied,
    required this.duplicates,
    required this.conflicts,
  });

  final int applied;
  final int duplicates;
  final int conflicts;
}

final class SyncIdentity {
  const SyncIdentity({
    required this.spaceId,
    required this.deviceId,
    required this.deviceName,
    required this.vector,
  });

  final String spaceId;
  final String deviceId;
  final String deviceName;
  final VersionVector vector;

  Map<String, Object?> toJson() => {
    'protocolVersion': syncProtocolVersion,
    'spaceId': spaceId,
    'deviceId': deviceId,
    'deviceName': deviceName,
    'vector': vector.toJson(),
  };
}
