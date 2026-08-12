import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/version/app_version.dart';
import '../database/app_database.dart';
import '../repositories/board_providers.dart';
import '../task_details/task_detail_document.dart';
import '../task_details/task_detail_image.dart';

const backupSchemaVersion = 6;
const _backupPositionGap = 1000000000000;

class BackupException implements Exception {
  const BackupException(this.message);

  final String message;

  @override
  String toString() => message;
}

class BackupPreview {
  const BackupPreview({
    required this.categories,
    required this.tasks,
    required this.sourceName,
  });

  final List<Map<String, Object?>> categories;
  final List<Map<String, Object?>> tasks;
  final String sourceName;

  int get categoryCount => categories.length;
  int get taskCount => tasks.length;
}

final backupServiceProvider = Provider<BackupService>((ref) {
  return BackupService(
    ref.watch(appDatabaseProvider),
    ref.watch(appVersionReaderProvider),
  );
});

class BackupService {
  const BackupService(this._database, this._appVersionReader);

  final AppDatabase _database;
  final AppVersionReader _appVersionReader;

  Future<Uint8List> createBackupBytes() async {
    final categories = await _database.readCategories();
    final tasks = await _database.readTasks();
    final appVersion = await _appVersionReader.read();
    final payload = <String, Object?>{
      'schemaVersion': backupSchemaVersion,
      'appVersion': appVersion,
      'exportedAtUtc': DateTime.now().toUtc().toIso8601String(),
      'categories': categories
          .map(
            (category) => <String, Object?>{
              'id': category.id,
              'name': category.name,
              'colorArgb': category.colorArgb,
              'sortOrder': category.sortOrder,
              'createdAtUtc': category.createdAtUtc.toUtc().toIso8601String(),
              'updatedAtUtc': category.updatedAtUtc.toUtc().toIso8601String(),
            },
          )
          .toList(),
      'tasks': tasks
          .map(
            (task) => <String, Object?>{
              'id': task.id,
              'name': task.name,
              'details': task.details,
              'detailImages': jsonDecode(task.detailImagesJson),
              'deadlineUtc': task.deadlineUtc?.toUtc().toIso8601String(),
              'categoryId': task.categoryId,
              'positionKey': task.positionKey,
              'isCompleted': task.isCompleted,
              'createdAtUtc': task.createdAtUtc.toUtc().toIso8601String(),
              'updatedAtUtc': task.updatedAtUtc.toUtc().toIso8601String(),
              'completedAtUtc': task.completedAtUtc?.toUtc().toIso8601String(),
            },
          )
          .toList(),
    };
    return Uint8List.fromList(
      utf8.encode(const JsonEncoder.withIndent('  ').convert(payload)),
    );
  }

  Future<bool> exportToFile({required String dialogTitle}) async {
    final bytes = await createBackupBytes();
    final date = DateTime.now().toIso8601String().split('T').first;
    final fileName = 'ddl-out-backup-$date.json';
    final path = await FilePicker.platform.saveFile(
      dialogTitle: dialogTitle,
      fileName: fileName,
      type: FileType.custom,
      allowedExtensions: const ['json'],
      bytes: Platform.isAndroid ? bytes : null,
      lockParentWindow: Platform.isWindows,
    );
    if (path == null) return false;
    if (!Platform.isAndroid) await File(path).writeAsBytes(bytes, flush: true);
    return true;
  }

  Future<BackupPreview?> pickBackup({required String dialogTitle}) async {
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: dialogTitle,
      type: FileType.custom,
      allowedExtensions: const ['json'],
      withData: true,
      lockParentWindow: Platform.isWindows,
    );
    if (result == null || result.files.isEmpty) return null;
    final file = result.files.single;
    final bytes =
        file.bytes ??
        (file.path == null ? null : await File(file.path!).readAsBytes());
    if (bytes == null) throw const BackupException('无法读取备份文件');
    return parseBackup(bytes, sourceName: file.name);
  }

  BackupPreview parseBackup(
    List<int> bytes, {
    String sourceName = 'backup.json',
  }) {
    try {
      final decoded = jsonDecode(utf8.decode(bytes));
      if (decoded is! Map<String, dynamic>) {
        throw const BackupException('备份顶层必须是 JSON 对象');
      }
      final version = decoded['schemaVersion'];
      if (version is! int || version < 1 || version > backupSchemaVersion) {
        throw const BackupException('不支持的备份版本');
      }
      final rawCategoryRows = _objectList(decoded['categories'], 'categories');
      final categoryRows = [
        for (final (index, row) in rawCategoryRows.indexed)
          <String, Object?>{...row, if (version == 1) 'sortOrder': index},
      ];
      final rawTaskRows = _objectList(decoded['tasks'], 'tasks');
      final legacyPositions = version < 5
          ? _legacyTaskPositions(rawTaskRows)
          : const <int, String>{};
      final taskRows = [
        for (final row in rawTaskRows)
          <String, Object?>{
            ...row,
            if (version < 3) 'details': '',
            if (version < 3) 'detailImages': const <Object?>[],
            if (version < 5) 'positionKey': legacyPositions[row['id'] as int],
          },
      ];
      _validate(categoryRows, taskRows, allowNoDeadline: version >= 6);
      return BackupPreview(
        categories: categoryRows,
        tasks: taskRows,
        sourceName: sourceName,
      );
    } on BackupException {
      rethrow;
    } on Object catch (error) {
      throw BackupException('备份解析失败：$error');
    }
  }

  List<Map<String, Object?>> _objectList(Object? value, String field) {
    if (value is! List) throw BackupException('$field 必须是数组');
    return value.map((row) {
      if (row is! Map<String, dynamic>) {
        throw BackupException('$field 中存在无效记录');
      }
      return row.cast<String, Object?>();
    }).toList();
  }

  Map<int, String> _legacyTaskPositions(List<Map<String, Object?>> taskRows) {
    final sorted = [...taskRows]
      ..sort((left, right) {
        final leftCategory = left['categoryId'] as int? ?? -1;
        final rightCategory = right['categoryId'] as int? ?? -1;
        final category = leftCategory.compareTo(rightCategory);
        if (category != 0) return category;
        final leftCompleted = left['isCompleted'] == true;
        final rightCompleted = right['isCompleted'] == true;
        if (leftCompleted != rightCompleted) return leftCompleted ? 1 : -1;
        final deadline = (left['deadlineUtc'] as String).compareTo(
          right['deadlineUtc'] as String,
        );
        if (deadline != 0) return deadline;
        return (left['id'] as int).compareTo(right['id'] as int);
      });
    final indexes = <int?, int>{};
    final positions = <int, String>{};
    for (final row in sorted) {
      final categoryId = row['categoryId'] as int?;
      final index = indexes[categoryId] ?? 0;
      indexes[categoryId] = index + 1;
      positions[row['id']! as int] = _backupPositionForIndex(index);
    }
    return positions;
  }

  String _backupPositionForIndex(int index) =>
      ((index + 1) * _backupPositionGap).toString().padLeft(24, '0');

  void _validate(
    List<Map<String, Object?>> categoryRows,
    List<Map<String, Object?>> taskRows, {
    required bool allowNoDeadline,
  }) {
    final categoryIds = <int>{};
    final categoryOrders = <int>{};
    for (final row in categoryRows) {
      final id = _positiveInt(row, 'id');
      if (!categoryIds.add(id)) throw const BackupException('分类 ID 重复');
      _name(row, 60);
      final sortOrder = row['sortOrder'];
      if (sortOrder is! int ||
          sortOrder < 0 ||
          !categoryOrders.add(sortOrder)) {
        throw const BackupException('分类顺序无效');
      }
      final color = row['colorArgb'];
      if (color is! int || color < 0 || color > 0xFFFFFFFF) {
        throw const BackupException('分类颜色无效');
      }
      _utc(row, 'createdAtUtc');
      _utc(row, 'updatedAtUtc');
    }

    final taskIds = <int>{};
    final taskPositions = <int?, Set<String>>{};
    for (final row in taskRows) {
      final id = _positiveInt(row, 'id');
      if (!taskIds.add(id)) throw const BackupException('事项 ID 重复');
      _name(row, 200);
      final details = row['details'];
      if (details is! String ||
          details.length > TaskDetailDocumentCodec.maximumEncodedLength) {
        throw const BackupException('事项详情无效');
      }
      final detailImages = row['detailImages'];
      if (detailImages is! List) {
        throw const BackupException('事项详情图片无效');
      }
      try {
        final images = TaskDetailImageCodec.decode(jsonEncode(detailImages));
        TaskDetailDocumentCodec.decode(details: details, images: images);
      } on FormatException {
        throw const BackupException('事项详情图片无效');
      }
      final categoryId = row['categoryId'];
      if (categoryId != null &&
          (categoryId is! int || !categoryIds.contains(categoryId))) {
        throw const BackupException('事项引用了不存在的分类');
      }
      if (row['isCompleted'] is! bool) {
        throw const BackupException('事项完成状态无效');
      }
      final positionKey = row['positionKey'];
      if (positionKey is! String ||
          positionKey.isEmpty ||
          positionKey.length > 100 ||
          BigInt.tryParse(positionKey) == null ||
          !taskPositions
              .putIfAbsent(categoryId as int?, () => <String>{})
              .add(positionKey)) {
        throw const BackupException('事项顺序无效');
      }
      if (!row.containsKey('deadlineUtc')) {
        throw const BackupException('事项缺少截止时间字段');
      }
      if (row['deadlineUtc'] == null) {
        if (!allowNoDeadline) {
          throw const BackupException('旧版备份的事项必须包含截止时间');
        }
      } else {
        _utc(row, 'deadlineUtc');
      }
      _utc(row, 'createdAtUtc');
      _utc(row, 'updatedAtUtc');
      if (row['completedAtUtc'] != null) {
        _utc(row, 'completedAtUtc');
      }
    }
  }

  int _positiveInt(Map<String, Object?> row, String field) {
    final value = row[field];
    if (value is! int || value <= 0) throw BackupException('$field 无效');
    return value;
  }

  String _name(Map<String, Object?> row, int max) {
    final value = row['name'];
    if (value is! String || value.trim().isEmpty || value.trim().length > max) {
      throw const BackupException('名称无效');
    }
    return value.trim();
  }

  DateTime _utc(Map<String, Object?> row, String field) {
    final value = row[field];
    if (value is! String) throw BackupException('$field 无效');
    final parsed = DateTime.tryParse(value);
    if (parsed == null || !parsed.isUtc) {
      throw BackupException('$field 必须是 UTC');
    }
    return parsed;
  }

  Future<void> restore(BackupPreview preview) async {
    final categoryRows = preview.categories.map((row) {
      return CategoriesCompanion.insert(
        id: Value(row['id']! as int),
        name: _name(row, 60),
        colorArgb: row['colorArgb']! as int,
        sortOrder: Value(row['sortOrder']! as int),
        createdAtUtc: _utc(row, 'createdAtUtc'),
        updatedAtUtc: _utc(row, 'updatedAtUtc'),
      );
    }).toList();
    final taskRows = preview.tasks.map((row) {
      return TasksCompanion.insert(
        id: Value(row['id']! as int),
        name: _name(row, 200),
        details: Value(row['details']! as String),
        detailImagesJson: Value(jsonEncode(row['detailImages']! as List)),
        deadlineUtc: Value(
          row['deadlineUtc'] == null ? null : _utc(row, 'deadlineUtc'),
        ),
        categoryId: Value(row['categoryId'] as int?),
        positionKey: Value(row['positionKey']! as String),
        isCompleted: Value(row['isCompleted']! as bool),
        createdAtUtc: _utc(row, 'createdAtUtc'),
        updatedAtUtc: _utc(row, 'updatedAtUtc'),
        completedAtUtc: Value(
          row['completedAtUtc'] == null ? null : _utc(row, 'completedAtUtc'),
        ),
      );
    }).toList();
    await _database.replaceAll(categoryRows: categoryRows, taskRows: taskRows);
  }
}
