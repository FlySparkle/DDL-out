import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import '../repositories/repositories.dart';

const backupSchemaVersion = 1;

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
  return BackupService(ref.watch(appDatabaseProvider));
});

class BackupService {
  const BackupService(this._database);

  final AppDatabase _database;

  Future<Uint8List> createBackupBytes() async {
    final categories = await _database.readCategories();
    final tasks = await _database.readTasks();
    final payload = <String, Object?>{
      'schemaVersion': backupSchemaVersion,
      'appVersion': '0.1.0',
      'exportedAtUtc': DateTime.now().toUtc().toIso8601String(),
      'categories': categories
          .map(
            (category) => <String, Object?>{
              'id': category.id,
              'name': category.name,
              'colorArgb': category.colorArgb,
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
              'deadlineUtc': task.deadlineUtc.toUtc().toIso8601String(),
              'categoryId': task.categoryId,
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
      if (version is! int || version != backupSchemaVersion) {
        throw const BackupException('不支持的备份版本');
      }
      final categoryRows = _objectList(decoded['categories'], 'categories');
      final taskRows = _objectList(decoded['tasks'], 'tasks');
      _validate(categoryRows, taskRows);
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

  void _validate(
    List<Map<String, Object?>> categoryRows,
    List<Map<String, Object?>> taskRows,
  ) {
    final categoryIds = <int>{};
    for (final row in categoryRows) {
      final id = _positiveInt(row, 'id');
      if (!categoryIds.add(id)) throw const BackupException('分类 ID 重复');
      _name(row, 60);
      final color = row['colorArgb'];
      if (color is! int || color < 0 || color > 0xFFFFFFFF) {
        throw const BackupException('分类颜色无效');
      }
      _utc(row, 'createdAtUtc');
      _utc(row, 'updatedAtUtc');
    }

    final taskIds = <int>{};
    for (final row in taskRows) {
      final id = _positiveInt(row, 'id');
      if (!taskIds.add(id)) throw const BackupException('事项 ID 重复');
      _name(row, 200);
      final categoryId = row['categoryId'];
      if (categoryId != null &&
          (categoryId is! int || !categoryIds.contains(categoryId))) {
        throw const BackupException('事项引用了不存在的分类');
      }
      if (row['isCompleted'] is! bool) {
        throw const BackupException('事项完成状态无效');
      }
      _utc(row, 'deadlineUtc');
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
        createdAtUtc: _utc(row, 'createdAtUtc'),
        updatedAtUtc: _utc(row, 'updatedAtUtc'),
      );
    }).toList();
    final taskRows = preview.tasks.map((row) {
      return TasksCompanion.insert(
        id: Value(row['id']! as int),
        name: _name(row, 200),
        deadlineUtc: _utc(row, 'deadlineUtc'),
        categoryId: Value(row['categoryId'] as int?),
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
