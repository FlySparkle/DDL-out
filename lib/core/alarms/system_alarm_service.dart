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

  /// ACTION_SET_ALARM accepts hour/minute, not a calendar date. Only export
  /// dates that exactly match the clock's next occurrence, including DST.
  static bool isNextClockOccurrence(DateTime time, DateTime now) {
    var next = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    if (!next.isAfter(now)) {
      next = DateTime(now.year, now.month, now.day + 1, time.hour, time.minute);
    }
    return next.isAtSameMomentAs(time);
  }
}
