import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class DeadlinePreset {
  const DeadlinePreset({required this.label, this.minutes, this.localDateTime});

  final String label;
  final int? minutes;
  final DateTime? localDateTime;

  String get durationLabel {
    final value = minutes!;
    return '+${[if (value ~/ 1440 > 0) '${value ~/ 1440}d', if (value % 1440 ~/ 60 > 0) '${value % 1440 ~/ 60}h', if (value % 60 > 0) '${value % 60}m'].join(' ')}';
  }

  Map<String, Object?> toJson() => {
    'label': label,
    'minutes': minutes,
    'utc': localDateTime?.toUtc().toIso8601String(),
  };
}

class DeadlinePresetStore {
  static const storageKey = 'deadline_presets_v1';

  Future<List<DeadlinePreset>> load() async {
    final preferences = await SharedPreferences.getInstance();
    final result = <DeadlinePreset>[];
    for (final source in preferences.getStringList(storageKey) ?? <String>[]) {
      try {
        final value = jsonDecode(source);
        if (value is! Map || value['label'] is! String) continue;
        final label = value['label'] as String;
        final minutes = value['minutes'];
        final utc = value['utc'];
        if (label.isEmpty || label.length > 40) continue;
        if (minutes is int &&
            minutes > 0 &&
            minutes <= 1439999 &&
            utc == null) {
          result.add(DeadlinePreset(label: label, minutes: minutes));
        } else if (minutes == null && utc is String) {
          final date = DateTime.tryParse(utc)?.toLocal();
          if (date != null && date.year >= 2000 && date.year <= 9999) {
            result.add(DeadlinePreset(label: label, localDateTime: date));
          }
        }
      } on FormatException {
        // A damaged preference must not prevent opening the task editor.
      }
    }
    return result;
  }

  Future<void> save(List<DeadlinePreset> presets) async {
    final preferences = await SharedPreferences.getInstance();
    final saved = await preferences.setStringList(storageKey, [
      for (final preset in presets) jsonEncode(preset.toJson()),
    ]);
    if (!saved) throw StateError('Could not save deadline presets');
  }
}
