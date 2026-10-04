import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Native clock export is intentionally independent of saving the task.
class SystemAlarmService {
  static const _channel = MethodChannel('ddl_out/system_alarms');
  static const maxRepeats = 99;

  static bool get supported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.windows);
  static bool get usesAndroidClock =>
      defaultTargetPlatform == TargetPlatform.android;

  Future<int> submit({
    required String title,
    required String notes,
    required List<DateTime> times,
  }) async {
    final count = await _channel.invokeMethod<int>('schedule', {
      'title': title.trim(),
      'notes': notes.trim(),
      'times': times
          .map((time) => time.toUtc().millisecondsSinceEpoch)
          .toList(),
    });
    return count ?? 0;
  }

  Future<List<SystemAlarmEntry>> list() async {
    final values = await _channel.invokeListMethod<Object?>('list') ?? [];
    return values
        .map((value) => SystemAlarmEntry.fromMap(value as Map))
        .toList()
      ..sort((a, b) => a.time.compareTo(b.time));
  }

  Future<SystemAlarmEntry> get(String id) async => SystemAlarmEntry.fromMap(
    (await _channel.invokeMapMethod<Object?, Object?>('get', {'id': id}))!,
  );

  Future<void> delete(String id) => _channel.invokeMethod('delete', {'id': id});
  Future<void> disable(String id) =>
      _channel.invokeMethod('disable', {'id': id});
  Future<void> forget(String id) => _channel.invokeMethod('forget', {'id': id});
  Future<void> clearEntries(Iterable<SystemAlarmEntry> entries) async {
    for (final entry in entries) {
      if (usesAndroidClock) {
        await forget(entry.id);
      } else {
        await delete(entry.id);
      }
    }
  }

  Future<void> openClock() => _channel.invokeMethod('openClock');
  Future<void> sound() => _channel.invokeMethod('sound');
  Future<void> silence() => _channel.invokeMethod('silence');

  static String diagnostic(Object error) {
    if (error is! PlatformException) return error.toString();
    final details = error.details;
    return [
      error.code,
      if (details is Map) ...[
        if (details['stage'] != null) details['stage'].toString(),
        if (details['hresult'] != null) details['hresult'].toString(),
      ],
      if (error.message?.isNotEmpty ?? false) error.message!,
    ].join(' · ');
  }
}

class SystemAlarmEntry {
  const SystemAlarmEntry({
    required this.id,
    required this.title,
    required this.notes,
    required this.time,
    required this.enabled,
    required this.weekly,
    this.lastResult = 0,
  });
  factory SystemAlarmEntry.fromMap(Map value) => SystemAlarmEntry(
    id: value['id'] as String,
    title: value['title'] as String,
    notes: value['notes'] as String,
    time: DateTime.fromMillisecondsSinceEpoch(value['time'] as int).toLocal(),
    enabled: value['enabled'] as bool? ?? true,
    weekly: value['weekly'] as bool? ?? false,
    lastResult: value['lastResult'] as int? ?? 0,
  );
  final String id;
  final String title;
  final String notes;
  final DateTime time;
  final bool enabled;
  final bool weekly;
  final int lastResult;
}

class SystemAlarmPlan {
  const SystemAlarmPlan({
    required this.time,
    this.multiple = false,
    this.before = true,
    this.intervalMinutes = 3,
    this.repeats = 3,
  });

  final DateTime time;
  final bool multiple;
  final bool before;
  final int intervalMinutes;
  final int repeats;

  List<DateTime> get times {
    final anchor = DateTime(
      time.year,
      time.month,
      time.day,
      time.hour,
      time.minute,
    );
    final values = [anchor];
    if (multiple) {
      for (var index = 1; index <= repeats; index++) {
        values.add(
          anchor.add(
            Duration(minutes: intervalMinutes * index * (before ? -1 : 1)),
          ),
        );
      }
    }
    return values..sort();
  }

  /// ACTION_SET_ALARM accepts hour/minute, not a calendar date. Later dates
  /// require a weekly alarm on their local weekday, including DST.
  static bool isNextClockOccurrence(DateTime time, DateTime now) {
    var next = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    if (!next.isAfter(now)) {
      next = DateTime(now.year, now.month, now.day + 1, time.hour, time.minute);
    }
    return next.isAtSameMomentAs(time);
  }
}
