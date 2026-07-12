import 'package:ddl_out/core/time/deadline_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DeadlineService.normalize', () {
    test('carries minutes and hours', () {
      final value = DeadlineService.normalize(0, 23, 120);
      expect(value.days, 1);
      expect(value.hours, 1);
      expect(value.minutes, 0);
    });

    test('clamps negative input and caps at 999 days', () {
      final negative = DeadlineService.normalize(-1, -2, -3);
      expect(negative.totalMinutes, 0);

      final capped = DeadlineService.normalize(1200, 0, 0);
      expect(capped.days, 999);
      expect(capped.hours, 23);
      expect(capped.minutes, 59);
    });
  });

  test('relative input resolves from the supplied instant in UTC', () {
    final now = DateTime.utc(2026, 7, 12, 1);
    final result = DeadlineService.resolveUtc(
      const RelativeDeadline(days: 1, hours: 2, minutes: 30),
      now: now,
    );
    expect(result, DateTime.utc(2026, 7, 13, 3, 30));
  });

  test('progress compares against longest positive remaining time', () {
    final now = DateTime.utc(2026, 7, 12);
    expect(
      DeadlineService.progress(
        now.add(const Duration(hours: 12)),
        const Duration(hours: 24),
        now: now,
      ),
      0.5,
    );
    expect(
      DeadlineService.progress(
        now.subtract(const Duration(minutes: 1)),
        const Duration(hours: 24),
        now: now,
      ),
      0,
    );
  });

  test('urgency thresholds get progressively lighter', () {
    const category = Color(0xFF4A90E2);
    final now = DateTime.utc(2026, 7, 12);
    final scheme = ColorScheme.fromSeed(seedColor: category);
    final urgent = DeadlineService.urgencyColor(
      category,
      now.add(const Duration(hours: 12)),
      scheme,
      now: now,
    );
    final distant = DeadlineService.urgencyColor(
      category,
      now.add(const Duration(hours: 100)),
      scheme,
      now: now,
    );
    expect(distant.computeLuminance(), greaterThan(urgent.computeLuminance()));
  });
}
