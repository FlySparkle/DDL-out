import 'dart:math' as math;

import 'package:flutter/material.dart';

sealed class DeadlineInput {
  const DeadlineInput();
}

final class RelativeDeadline extends DeadlineInput {
  const RelativeDeadline({
    required this.days,
    required this.hours,
    required this.minutes,
  });

  final int days;
  final int hours;
  final int minutes;
}

final class AbsoluteDeadline extends DeadlineInput {
  const AbsoluteDeadline(this.localDateTime);

  final DateTime localDateTime;
}

final class NormalizedDuration {
  const NormalizedDuration({
    required this.days,
    required this.hours,
    required this.minutes,
  });

  final int days;
  final int hours;
  final int minutes;

  int get totalMinutes => days * 24 * 60 + hours * 60 + minutes;
}

abstract final class DeadlineService {
  static NormalizedDuration normalize(int days, int hours, int minutes) {
    final total =
        math.max(0, days) * 24 * 60 +
        math.max(0, hours) * 60 +
        math.max(0, minutes);
    final capped = math.min(total, 999 * 24 * 60 + 23 * 60 + 59).toInt();
    return NormalizedDuration(
      days: capped ~/ (24 * 60),
      hours: (capped % (24 * 60)) ~/ 60,
      minutes: capped % 60,
    );
  }

  static DateTime resolveUtc(DeadlineInput input, {DateTime? now}) {
    switch (input) {
      case RelativeDeadline(:final days, :final hours, :final minutes):
        final normalized = normalize(days, hours, minutes);
        return (now ?? DateTime.now())
            .add(Duration(minutes: normalized.totalMinutes))
            .toUtc();
      case AbsoluteDeadline(:final localDateTime):
        return DateTime(
          localDateTime.year,
          localDateTime.month,
          localDateTime.day,
          localDateTime.hour,
          localDateTime.minute,
        ).toUtc();
    }
  }

  static Duration remaining(DateTime deadlineUtc, {DateTime? now}) {
    return deadlineUtc.toUtc().difference((now ?? DateTime.now()).toUtc());
  }

  static double progress(
    DateTime deadlineUtc,
    Duration longestPositiveRemaining, {
    DateTime? now,
    bool completed = false,
  }) {
    if (completed || longestPositiveRemaining <= Duration.zero) return 0;
    final value = remaining(deadlineUtc, now: now);
    if (value <= Duration.zero) return 0;
    return (value.inSeconds / longestPositiveRemaining.inSeconds).clamp(0, 1);
  }

  static Color urgencyColor(
    Color categoryColor,
    DateTime deadlineUtc,
    ColorScheme scheme, {
    DateTime? now,
  }) {
    final value = remaining(deadlineUtc, now: now);
    if (value.isNegative) return scheme.errorContainer;

    final hours = value.inMinutes / 60;
    final lighten = switch (hours) {
      <= 12 => 0.18,
      <= 24 => 0.36,
      <= 72 => 0.56,
      _ => 0.76,
    };
    final target = scheme.brightness == Brightness.light
        ? Colors.white
        : scheme.surfaceContainerHighest;
    return Color.lerp(categoryColor, target, lighten)!;
  }

  static Color readableForeground(Color background) {
    return ThemeData.estimateBrightnessForColor(background) == Brightness.dark
        ? Colors.white
        : const Color(0xFF111318);
  }
}
