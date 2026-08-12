part of 'app_database.dart';

const _syncStateId = 1;
const _positionGap = 1000000000000;
const _syncableFields = <String>{
  SyncField.name,
  SyncField.colorArgb,
  SyncField.positionKey,
  SyncField.details,
  SyncField.detailImages,
  SyncField.deadlineUtc,
  SyncField.categorySyncId,
  SyncField.completion,
  SyncField.deleted,
};

int _compareNullableDeadlines(DateTime? left, DateTime? right) {
  if (left == null) return right == null ? 0 : 1;
  if (right == null) return -1;
  return left.compareTo(right);
}

extension SyncDatabase on AppDatabase {
  Future<int> createSyncedCategory(String name, int colorArgb) async {
    return transaction(() async {
      final syncId = const Uuid().v4();
      final now = DateTime.now().toUtc();
      await _recordLocalOperation(
        entityType: SyncEntityType.category,
        entitySyncId: syncId,
        kind: SyncOperationKind.create,
        changes: {
          SyncField.name: name.trim(),
          SyncField.colorArgb: colorArgb,
          SyncField.positionKey: await nextCategoryPosition(),
          SyncField.deleted: null,
          'createdAtUtc': now.toIso8601String(),
        },
      );
      return (select(categories)..where((row) => row.syncId.equals(syncId)))
          .map((row) => row.id)
          .getSingle();
    });
  }

  Future<void> updateSyncedCategory(
    Category category,
    String name,
    int colorArgb,
  ) async {
    final changes = <String, Object?>{};
    final normalizedName = name.trim();
    if (category.name != normalizedName) {
      changes[SyncField.name] = normalizedName;
    }
    if (category.colorArgb != colorArgb) {
      changes[SyncField.colorArgb] = colorArgb;
    }
    if (changes.isEmpty) return;
    await transaction(() async {
      await ensureSyncReady();
      final current = await (select(
        categories,
      )..where((row) => row.id.equals(category.id))).getSingle();
      await _recordLocalOperation(
        entityType: SyncEntityType.category,
        entitySyncId: current.syncId!,
        kind: SyncOperationKind.patch,
        changes: changes,
      );
    });
  }

  Future<void> reorderSyncedCategories(List<int> categoryIds) async {
    await transaction(() async {
      final current =
          await (select(categories)
                ..where((row) => row.deletedAtUtc.isNull())
                ..orderBy([
                  (row) => OrderingTerm.asc(row.sortOrder),
                  (row) => OrderingTerm.asc(row.id),
                ]))
              .get();
      final oldIds = current.map((row) => row.id).toList();
      if (oldIds.length != categoryIds.length ||
          oldIds.toSet().difference(categoryIds.toSet()).isNotEmpty) {
        throw ArgumentError('分类顺序与当前分类不匹配');
      }
      if (_sameList(oldIds, categoryIds)) return;
      Category? moved;
      for (final id in oldIds) {
        final left = [...oldIds]..remove(id);
        final right = [...categoryIds]..remove(id);
        if (_sameList(left, right)) {
          moved = current.firstWhere((row) => row.id == id);
          break;
        }
      }
      if (moved == null) {
        await _rebalanceCategoryPositions(categoryIds);
        return;
      }
      final newIndex = categoryIds.indexOf(moved.id);
      final byId = {for (final row in current) row.id: row};
      final leftKey = newIndex == 0
          ? null
          : BigInt.tryParse(byId[categoryIds[newIndex - 1]]!.positionKey ?? '');
      final rightKey = newIndex == categoryIds.length - 1
          ? null
          : BigInt.tryParse(byId[categoryIds[newIndex + 1]]!.positionKey ?? '');
      BigInt next;
      if (leftKey == null && rightKey == null) {
        next = BigInt.from(_positionGap);
      } else if (leftKey == null) {
        next = rightKey! ~/ BigInt.two;
      } else if (rightKey == null) {
        next = leftKey + BigInt.from(_positionGap);
      } else {
        next = (leftKey + rightKey) ~/ BigInt.two;
      }
      if ((leftKey != null && next <= leftKey) ||
          (rightKey != null && next >= rightKey)) {
        await _rebalanceCategoryPositions(categoryIds);
        return;
      }
      await _recordLocalOperation(
        entityType: SyncEntityType.category,
        entitySyncId: moved.syncId!,
        kind: SyncOperationKind.patch,
        changes: {SyncField.positionKey: next.toString().padLeft(24, '0')},
      );
    });
  }

  bool _sameList(List<int> left, List<int> right) {
    if (left.length != right.length) return false;
    for (var index = 0; index < left.length; index += 1) {
      if (left[index] != right[index]) return false;
    }
    return true;
  }

  Future<void> _rebalanceCategoryPositions(List<int> ids) async {
    final transactionId = const Uuid().v4();
    for (final (index, id) in ids.indexed) {
      final row = await (select(
        categories,
      )..where((row) => row.id.equals(id))).getSingle();
      final position = _positionForIndex(index);
      if (row.positionKey == position) continue;
      await _recordLocalOperation(
        entityType: SyncEntityType.category,
        entitySyncId: row.syncId!,
        kind: SyncOperationKind.patch,
        changes: {SyncField.positionKey: position},
        transactionId: transactionId,
        transactionIndex: index,
        transactionCount: ids.length,
      );
    }
  }

  Future<void> deleteSyncedCategory(int id) async {
    await transaction(() async {
      final category = await (select(
        categories,
      )..where((row) => row.id.equals(id))).getSingle();
      final affected =
          await (select(tasks)..where(
                (row) => row.categoryId.equals(id) & row.deletedAtUtc.isNull(),
              ))
              .get();
      final transactionId = const Uuid().v4();
      final deletedAt = DateTime.now().toUtc().toIso8601String();
      await _recordLocalOperation(
        entityType: SyncEntityType.category,
        entitySyncId: category.syncId!,
        kind: SyncOperationKind.delete,
        changes: {SyncField.deleted: deletedAt},
        transactionId: transactionId,
        transactionIndex: 0,
        transactionCount: affected.length + 1,
      );
      for (final (index, task) in affected.indexed) {
        await _recordLocalOperation(
          entityType: SyncEntityType.task,
          entitySyncId: task.syncId!,
          kind: SyncOperationKind.patch,
          changes: {SyncField.categorySyncId: null},
          transactionId: transactionId,
          transactionIndex: index + 1,
          transactionCount: affected.length + 1,
        );
      }
    });
  }

  Future<void> restoreSyncedCategory(int id) async {
    await transaction(() async {
      final category = await (select(
        categories,
      )..where((row) => row.id.equals(id))).getSingle();
      if (category.deletedAtUtc == null) return;
      await _recordLocalOperation(
        entityType: SyncEntityType.category,
        entitySyncId: category.syncId!,
        kind: SyncOperationKind.restore,
        changes: {SyncField.deleted: null},
      );
    });
  }

  Future<void> clearSyncedCategories() async {
    final rows = await readCategories();
    for (final row in rows) {
      await deleteSyncedCategory(row.id);
    }
  }

  Future<int> createSyncedTask({
    required String name,
    required DateTime? deadlineUtc,
    required int? categoryId,
    String details = '',
    String detailImagesJson = '[]',
  }) async {
    return transaction(() async {
      final syncId = const Uuid().v4();
      final now = DateTime.now().toUtc();
      await _recordLocalOperation(
        entityType: SyncEntityType.task,
        entitySyncId: syncId,
        kind: SyncOperationKind.create,
        changes: {
          SyncField.name: name.trim(),
          SyncField.details: details,
          SyncField.detailImages: jsonDecode(detailImagesJson),
          SyncField.deadlineUtc: deadlineUtc?.toUtc().toIso8601String(),
          SyncField.categorySyncId: await _categorySyncId(categoryId),
          SyncField.positionKey: await nextTaskPosition(categoryId),
          SyncField.completion: {'isCompleted': false, 'completedAtUtc': null},
          SyncField.deleted: null,
          'createdAtUtc': now.toIso8601String(),
        },
      );
      return (select(tasks)..where((row) => row.syncId.equals(syncId)))
          .map((row) => row.id)
          .getSingle();
    });
  }

  Future<void> updateSyncedTask({
    required Task task,
    required String name,
    required DateTime? deadlineUtc,
    required int? categoryId,
    required String details,
    required String detailImagesJson,
  }) async {
    final changes = <String, Object?>{};
    final normalizedName = name.trim();
    if (task.name != normalizedName) changes[SyncField.name] = normalizedName;
    if (task.details != details) changes[SyncField.details] = details;
    if (task.detailImagesJson != detailImagesJson) {
      changes[SyncField.detailImages] = jsonDecode(detailImagesJson);
    }
    final normalizedDeadline = deadlineUtc?.toUtc();
    if (task.deadlineUtc?.toUtc() != normalizedDeadline) {
      changes[SyncField.deadlineUtc] = normalizedDeadline?.toIso8601String();
    }
    final currentCategorySyncId = await _categorySyncId(task.categoryId);
    final nextCategorySyncId = await _categorySyncId(categoryId);
    if (currentCategorySyncId != nextCategorySyncId) {
      changes[SyncField.categorySyncId] = nextCategorySyncId;
    }
    if (changes.isEmpty) return;
    await transaction(() async {
      final current = await (select(
        tasks,
      )..where((row) => row.id.equals(task.id))).getSingle();
      await _recordLocalOperation(
        entityType: SyncEntityType.task,
        entitySyncId: current.syncId!,
        kind: SyncOperationKind.patch,
        changes: changes,
      );
    });
  }

  Future<void> moveSyncedTask(int taskId, int? categoryId, {int? index}) async {
    await transaction(() async {
      final task = await (select(
        tasks,
      )..where((row) => row.id.equals(taskId))).getSingle();
      final targetRows =
          await (select(tasks)
                ..where(
                  (row) =>
                      (categoryId == null
                          ? row.categoryId.isNull()
                          : row.categoryId.equals(categoryId)) &
                      row.deletedAtUtc.isNull() &
                      row.id.equals(taskId).not(),
                )
                ..orderBy([
                  (row) => OrderingTerm.asc(row.positionKey),
                  (row) => OrderingTerm.asc(row.id),
                ]))
              .get();
      final targetIndex = (index ?? targetRows.length).clamp(
        0,
        targetRows.length,
      );
      final ordered = [...targetRows]..insert(targetIndex, task);
      final newCategorySyncId = await _categorySyncId(categoryId);
      final operations = <({Task task, Map<String, Object?> changes})>[];
      for (final (positionIndex, row) in ordered.indexed) {
        final position = _positionForIndex(positionIndex);
        final changes = <String, Object?>{};
        if (row.positionKey != position) {
          changes[SyncField.positionKey] = position;
        }
        if (row.id == taskId && task.categoryId != categoryId) {
          changes[SyncField.categorySyncId] = newCategorySyncId;
        }
        if (changes.isNotEmpty) {
          operations.add((task: row, changes: changes));
        }
      }
      if (operations.isEmpty) return;
      final transactionId = const Uuid().v4();
      for (final (operationIndex, operation) in operations.indexed) {
        await _recordLocalOperation(
          entityType: SyncEntityType.task,
          entitySyncId: operation.task.syncId!,
          kind: SyncOperationKind.patch,
          changes: operation.changes,
          transactionId: transactionId,
          transactionIndex: operationIndex,
          transactionCount: operations.length,
        );
      }
    });
  }

  Future<void> sortSyncedTasksByDeadline(int? categoryId) async {
    await transaction(() async {
      final rows =
          await (select(tasks)..where(
                (row) =>
                    (categoryId == null
                        ? row.categoryId.isNull()
                        : row.categoryId.equals(categoryId)) &
                    row.deletedAtUtc.isNull(),
              ))
              .get();
      final operations = <({Task task, String position})>[];
      rows.sort((left, right) {
        final completion = left.isCompleted == right.isCompleted
            ? 0
            : left.isCompleted
            ? 1
            : -1;
        if (completion != 0) return completion;
        final deadline = _compareNullableDeadlines(
          left.deadlineUtc,
          right.deadlineUtc,
        );
        if (deadline != 0) return deadline;
        return left.id.compareTo(right.id);
      });
      for (final (index, task) in rows.indexed) {
        final position = _positionForIndex(index);
        if (task.positionKey != position) {
          operations.add((task: task, position: position));
        }
      }
      if (operations.isEmpty) return;
      final transactionId = const Uuid().v4();
      for (final (index, operation) in operations.indexed) {
        await _recordLocalOperation(
          entityType: SyncEntityType.task,
          entitySyncId: operation.task.syncId!,
          kind: SyncOperationKind.patch,
          changes: {SyncField.positionKey: operation.position},
          transactionId: transactionId,
          transactionIndex: index,
          transactionCount: operations.length,
        );
      }
    });
  }

  Future<void> setSyncedTaskCompleted(int taskId, bool completed) async {
    await transaction(() async {
      final task = await (select(
        tasks,
      )..where((row) => row.id.equals(taskId))).getSingle();
      if (task.isCompleted == completed) return;
      final now = DateTime.now().toUtc();
      await _recordLocalOperation(
        entityType: SyncEntityType.task,
        entitySyncId: task.syncId!,
        kind: SyncOperationKind.patch,
        changes: {
          SyncField.completion: {
            'isCompleted': completed,
            'completedAtUtc': completed ? now.toIso8601String() : null,
          },
        },
      );
    });
  }

  Future<void> deleteSyncedTask(int id) async {
    await transaction(() async {
      final task = await (select(
        tasks,
      )..where((row) => row.id.equals(id))).getSingle();
      if (task.deletedAtUtc != null) return;
      await _recordLocalOperation(
        entityType: SyncEntityType.task,
        entitySyncId: task.syncId!,
        kind: SyncOperationKind.delete,
        changes: {SyncField.deleted: DateTime.now().toUtc().toIso8601String()},
      );
    });
  }

  Future<void> restoreSyncedTasks(Iterable<int> ids) async {
    final uniqueIds = ids.toSet();
    if (uniqueIds.isEmpty) return;
    await transaction(() async {
      final rows = await (select(
        tasks,
      )..where((row) => row.id.isIn(uniqueIds))).get();
      final deletedRows = rows
          .where((row) => row.deletedAtUtc != null)
          .toList(growable: false);
      if (deletedRows.isEmpty) return;
      final transactionId = const Uuid().v4();
      for (final (index, task) in deletedRows.indexed) {
        await _recordLocalOperation(
          entityType: SyncEntityType.task,
          entitySyncId: task.syncId!,
          kind: SyncOperationKind.restore,
          changes: {SyncField.deleted: null},
          transactionId: transactionId,
          transactionIndex: index,
          transactionCount: deletedRows.length,
        );
      }
    });
  }

  Future<void> restoreSyncedSnapshot(BoardSnapshot snapshot) async {
    await transaction(() async {
      for (final category in snapshot.categories) {
        await restoreSyncedCategory(category.id);
      }
      await restoreSyncedTasks(snapshot.tasks.map((task) => task.id));
      for (final task in snapshot.tasks) {
        await moveSyncedTask(task.id, task.categoryId);
      }
    });
  }

  Future<void> clearSyncedCompleted() async {
    final rows =
        await (select(tasks)..where(
              (row) => row.isCompleted.equals(true) & row.deletedAtUtc.isNull(),
            ))
            .get();
    await _deleteTaskBatch(rows);
  }

  Future<void> clearSyncedCompletedInCategory(int? categoryId) async {
    final query = select(tasks)
      ..where(
        (row) =>
            row.isCompleted.equals(true) &
            (categoryId == null
                ? row.categoryId.isNull()
                : row.categoryId.equals(categoryId)) &
            row.deletedAtUtc.isNull(),
      );
    await _deleteTaskBatch(await query.get());
  }

  Future<void> _deleteTaskBatch(List<Task> rows) async {
    if (rows.isEmpty) return;
    await transaction(() async {
      final transactionId = const Uuid().v4();
      final deletedAt = DateTime.now().toUtc().toIso8601String();
      for (final (index, task) in rows.indexed) {
        await _recordLocalOperation(
          entityType: SyncEntityType.task,
          entitySyncId: task.syncId!,
          kind: SyncOperationKind.delete,
          changes: {SyncField.deleted: deletedAt},
          transactionId: transactionId,
          transactionIndex: index,
          transactionCount: rows.length,
        );
      }
    });
  }

  Future<void> clearAllSyncedData() async {
    await _deleteTaskBatch(await readTasks());
    await clearSyncedCategories();
  }

  Future<void> prepareForWholeDatabaseRestore() async {
    final paired = await (select(
      syncDevices,
    )..where((row) => row.isTrusted.equals(true))).get();
    if (paired.isNotEmpty) {
      throw StateError('请先移除已配对设备，再恢复整库备份');
    }
  }

  Future<void> resetSyncHistoryAfterRestore() async {
    await transaction(() async {
      await delete(syncConflicts).go();
      await delete(syncFieldHeads).go();
      await delete(syncOperations).go();
      await _ensureLocalSyncState();
      await (update(
        localSyncStates,
      )..where((row) => row.id.equals(_syncStateId))).write(
        LocalSyncStatesCompanion(
          spaceId: Value(const Uuid().v4()),
          nextSequence: const Value(0),
          vectorJson: const Value('{}'),
          hlcMillis: const Value(0),
          hlcCounter: const Value(0),
        ),
      );
      await (update(categories)).write(
        const CategoriesCompanion(
          syncId: Value(null),
          positionKey: Value(null),
          deletedAtUtc: Value(null),
        ),
      );
      await (update(tasks)).write(
        const TasksCompanion(syncId: Value(null), deletedAtUtc: Value(null)),
      );
    });
    await ensureSyncReady();
  }

  Future<void> ensureSyncReady() async {
    await _ensureLocalSyncState();

    final categoryRows = await select(categories).get();
    for (final category in categoryRows) {
      final syncId =
          category.syncId ??
          'legacy-category-${category.id}-${category.createdAtUtc.microsecondsSinceEpoch}';
      final positionKey =
          category.positionKey ?? _positionForIndex(category.sortOrder);
      if (category.syncId == null || category.positionKey == null) {
        await (update(
          categories,
        )..where((row) => row.id.equals(category.id))).write(
          CategoriesCompanion(
            syncId: Value(syncId),
            positionKey: Value(positionKey),
          ),
        );
      }
      if (!await _hasEntityOperation(SyncEntityType.category, syncId)) {
        await _recordLocalOperation(
          entityType: SyncEntityType.category,
          entitySyncId: syncId,
          kind: SyncOperationKind.create,
          occurredAtUtc: category.updatedAtUtc,
          changes: {
            SyncField.name: category.name,
            SyncField.colorArgb: category.colorArgb,
            SyncField.positionKey: positionKey,
            SyncField.deleted: category.deletedAtUtc?.toIso8601String(),
            'createdAtUtc': category.createdAtUtc.toUtc().toIso8601String(),
          },
        );
      }
    }

    final taskRows = await select(tasks).get();
    for (final task in taskRows) {
      final syncId =
          task.syncId ??
          'legacy-task-${task.id}-${task.createdAtUtc.microsecondsSinceEpoch}';
      final positionKey =
          task.positionKey ?? await nextTaskPosition(task.categoryId);
      if (task.syncId == null || task.positionKey == null) {
        await (update(tasks)..where((row) => row.id.equals(task.id))).write(
          TasksCompanion(
            syncId: Value(syncId),
            positionKey: Value(positionKey),
          ),
        );
      }
      final hasEntityOperation = await _hasEntityOperation(
        SyncEntityType.task,
        syncId,
      );
      if (!hasEntityOperation) {
        await _recordLocalOperation(
          entityType: SyncEntityType.task,
          entitySyncId: syncId,
          kind: SyncOperationKind.create,
          occurredAtUtc: task.updatedAtUtc,
          changes: {
            SyncField.name: task.name,
            SyncField.details: task.details,
            SyncField.detailImages: jsonDecode(task.detailImagesJson),
            SyncField.deadlineUtc: task.deadlineUtc?.toUtc().toIso8601String(),
            SyncField.categorySyncId: await _categorySyncId(task.categoryId),
            SyncField.positionKey: positionKey,
            SyncField.completion: {
              'isCompleted': task.isCompleted,
              'completedAtUtc': task.completedAtUtc?.toUtc().toIso8601String(),
            },
            SyncField.deleted: task.deletedAtUtc?.toIso8601String(),
            'createdAtUtc': task.createdAtUtc.toUtc().toIso8601String(),
          },
        );
      } else if (!await _hasFieldHead(
        SyncEntityType.task,
        syncId,
        SyncField.positionKey,
      )) {
        await _recordLocalOperation(
          entityType: SyncEntityType.task,
          entitySyncId: syncId,
          kind: SyncOperationKind.patch,
          changes: {SyncField.positionKey: positionKey},
        );
      }
    }
    await _normalizeCategoryOrder();
  }

  Future<LocalSyncState> _ensureLocalSyncState() async {
    final existing = await (select(
      localSyncStates,
    )..where((row) => row.id.equals(_syncStateId))).getSingleOrNull();
    if (existing != null) return existing;
    final uuid = const Uuid();
    final deviceId = uuid.v4();
    final platform = Platform.operatingSystem;
    final name =
        '${platform[0].toUpperCase()}${platform.substring(1)} '
        '${deviceId.substring(0, 4)}';
    await into(localSyncStates).insert(
      LocalSyncStatesCompanion.insert(
        id: const Value(_syncStateId),
        spaceId: uuid.v4(),
        deviceId: deviceId,
        deviceName: name,
      ),
    );
    return (select(
      localSyncStates,
    )..where((row) => row.id.equals(_syncStateId))).getSingle();
  }

  Future<bool> _hasEntityOperation(String entityType, String syncId) async {
    final row =
        await (select(syncOperations)
              ..where(
                (operation) =>
                    operation.entityType.equals(entityType) &
                    operation.entitySyncId.equals(syncId),
              )
              ..limit(1))
            .getSingleOrNull();
    return row != null;
  }

  Future<bool> _hasFieldHead(
    String entityType,
    String syncId,
    String fieldName,
  ) async {
    final row =
        await (select(syncFieldHeads)
              ..where(
                (head) =>
                    head.entityType.equals(entityType) &
                    head.entitySyncId.equals(syncId) &
                    head.fieldName.equals(fieldName),
              )
              ..limit(1))
            .getSingleOrNull();
    return row != null;
  }

  Future<String?> _categorySyncId(int? categoryId) async {
    if (categoryId == null) return null;
    return (select(categories)..where((row) => row.id.equals(categoryId)))
        .map((row) => row.syncId)
        .getSingleOrNull();
  }

  Future<int?> _categoryLocalId(String? syncId) async {
    if (syncId == null) return null;
    return (select(categories)..where(
          (row) => row.syncId.equals(syncId) & row.deletedAtUtc.isNull(),
        ))
        .map((row) => row.id)
        .getSingleOrNull();
  }

  String _positionForIndex(int index) =>
      ((index + 1) * _positionGap).toString().padLeft(24, '0');

  Future<String> nextCategoryPosition() async {
    final rows =
        await (select(categories)
              ..where((row) => row.deletedAtUtc.isNull())
              ..orderBy([(row) => OrderingTerm.desc(row.positionKey)])
              ..limit(1))
            .get();
    if (rows.isEmpty || rows.single.positionKey == null) {
      return _positionForIndex(rows.length);
    }
    final value = BigInt.tryParse(rows.single.positionKey!) ?? BigInt.zero;
    return (value + BigInt.from(_positionGap)).toString().padLeft(24, '0');
  }

  Future<String> nextTaskPosition(int? categoryId) async {
    final rows =
        await (select(tasks)
              ..where(
                (row) =>
                    (categoryId == null
                        ? row.categoryId.isNull()
                        : row.categoryId.equals(categoryId)) &
                    row.deletedAtUtc.isNull(),
              )
              ..orderBy([(row) => OrderingTerm.desc(row.positionKey)])
              ..limit(1))
            .get();
    if (rows.isEmpty || rows.single.positionKey == null) {
      return _positionForIndex(rows.length);
    }
    final value = BigInt.tryParse(rows.single.positionKey!) ?? BigInt.zero;
    return (value + BigInt.from(_positionGap)).toString().padLeft(24, '0');
  }

  Future<SyncOperationEnvelope> _recordLocalOperation({
    required String entityType,
    required String entitySyncId,
    required String kind,
    required Map<String, Object?> changes,
    DateTime? occurredAtUtc,
    String? transactionId,
    int? transactionIndex,
    int? transactionCount,
    List<String> resolves = const [],
  }) async {
    final state = await _ensureLocalSyncState();
    final vector = VersionVector.fromJsonString(state.vectorJson);
    final sequence = state.nextSequence + 1;
    final now = DateTime.now().toUtc();
    final millis = now.millisecondsSinceEpoch > state.hlcMillis
        ? now.millisecondsSinceEpoch
        : state.hlcMillis;
    final counter = millis == state.hlcMillis ? state.hlcCounter + 1 : 0;
    final operation = SyncOperationEnvelope(
      operationId: const Uuid().v4(),
      originDeviceId: state.deviceId,
      originSequence: sequence,
      context: vector.copy(),
      hlcMillis: millis,
      hlcCounter: counter,
      transactionId: transactionId,
      transactionIndex: transactionIndex,
      transactionCount: transactionCount,
      entityType: entityType,
      entitySyncId: entitySyncId,
      kind: kind,
      changes: changes,
      resolves: resolves,
      occurredAtUtc: (occurredAtUtc ?? now).toUtc(),
    );
    await into(syncOperations).insert(_operationCompanion(operation));
    vector.observe(state.deviceId, sequence);
    await (update(
      localSyncStates,
    )..where((row) => row.id.equals(_syncStateId))).write(
      LocalSyncStatesCompanion(
        nextSequence: Value(sequence),
        vectorJson: Value(vector.toJsonString()),
        hlcMillis: Value(millis),
        hlcCounter: Value(counter),
      ),
    );
    await _mergeStoredOperation(operation);
    return operation;
  }

  SyncOperationsCompanion _operationCompanion(
    SyncOperationEnvelope operation,
  ) => SyncOperationsCompanion.insert(
    operationId: operation.operationId,
    originDeviceId: operation.originDeviceId,
    originSequence: operation.originSequence,
    contextJson: operation.context.toJsonString(),
    hlcMillis: operation.hlcMillis,
    hlcCounter: operation.hlcCounter,
    transactionId: Value(operation.transactionId),
    transactionIndex: Value(operation.transactionIndex),
    transactionCount: Value(operation.transactionCount),
    entityType: operation.entityType,
    entitySyncId: operation.entitySyncId,
    operationKind: operation.kind,
    changesJson: jsonEncode(operation.changes),
    resolvesJson: Value(jsonEncode(operation.resolves)),
    occurredAtUtc: operation.occurredAtUtc,
  );

  SyncOperationEnvelope _operationEnvelope(SyncOperation row) {
    final rawChanges = jsonDecode(row.changesJson) as Map<String, dynamic>;
    final rawResolves = jsonDecode(row.resolvesJson) as List<dynamic>;
    return SyncOperationEnvelope(
      operationId: row.operationId,
      originDeviceId: row.originDeviceId,
      originSequence: row.originSequence,
      context: VersionVector.fromJsonString(row.contextJson),
      hlcMillis: row.hlcMillis,
      hlcCounter: row.hlcCounter,
      transactionId: row.transactionId,
      transactionIndex: row.transactionIndex,
      transactionCount: row.transactionCount,
      entityType: row.entityType,
      entitySyncId: row.entitySyncId,
      kind: row.operationKind,
      changes: Map<String, Object?>.from(rawChanges),
      resolves: rawResolves.whereType<String>().toList(growable: false),
      occurredAtUtc: row.occurredAtUtc,
    );
  }

  Future<void> _mergeStoredOperation(SyncOperationEnvelope operation) async {
    await _ensureEntityExists(operation);
    for (final entry in operation.changes.entries) {
      if (!_syncableFields.contains(entry.key)) continue;
      await _mergeFieldCandidate(operation, entry.key);
    }
  }

  Future<void> _ensureEntityExists(SyncOperationEnvelope operation) async {
    if (operation.entityType == SyncEntityType.category) {
      final existing =
          await (select(categories)
                ..where((row) => row.syncId.equals(operation.entitySyncId)))
              .getSingleOrNull();
      if (existing != null) return;
      final changes = operation.changes;
      await into(categories).insert(
        CategoriesCompanion.insert(
          syncId: Value(operation.entitySyncId),
          name: (changes[SyncField.name] as String?) ?? '未命名分类',
          colorArgb: (changes[SyncField.colorArgb] as int?) ?? 0xFF4A90E2,
          sortOrder: const Value(0),
          positionKey: Value(
            (changes[SyncField.positionKey] as String?) ??
                await nextCategoryPosition(),
          ),
          createdAtUtc:
              DateTime.tryParse(
                changes['createdAtUtc'] as String? ?? '',
              )?.toUtc() ??
              operation.occurredAtUtc,
          updatedAtUtc: operation.occurredAtUtc,
          deletedAtUtc: Value(_nullableUtc(changes[SyncField.deleted])),
        ),
      );
      return;
    }

    final existing =
        await (select(tasks)
              ..where((row) => row.syncId.equals(operation.entitySyncId)))
            .getSingleOrNull();
    if (existing != null) return;
    final changes = operation.changes;
    final completion = changes[SyncField.completion];
    final completionMap = completion is Map
        ? Map<String, dynamic>.from(completion)
        : const <String, dynamic>{};
    await into(tasks).insert(
      TasksCompanion.insert(
        syncId: Value(operation.entitySyncId),
        name: (changes[SyncField.name] as String?) ?? '未命名事项',
        details: Value((changes[SyncField.details] as String?) ?? ''),
        detailImagesJson: Value(
          jsonEncode(changes[SyncField.detailImages] ?? const []),
        ),
        deadlineUtc: Value(_nullableUtc(changes[SyncField.deadlineUtc])),
        categoryId: Value(
          await _categoryLocalId(changes[SyncField.categorySyncId] as String?),
        ),
        positionKey: Value(
          (changes[SyncField.positionKey] as String?) ??
              await nextTaskPosition(
                await _categoryLocalId(
                  changes[SyncField.categorySyncId] as String?,
                ),
              ),
        ),
        isCompleted: Value(completionMap['isCompleted'] as bool? ?? false),
        createdAtUtc:
            DateTime.tryParse(
              changes['createdAtUtc'] as String? ?? '',
            )?.toUtc() ??
            operation.occurredAtUtc,
        updatedAtUtc: operation.occurredAtUtc,
        completedAtUtc: Value(_nullableUtc(completionMap['completedAtUtc'])),
        deletedAtUtc: Value(_nullableUtc(changes[SyncField.deleted])),
      ),
    );
  }

  DateTime? _nullableUtc(Object? value) {
    if (value is! String) return null;
    return DateTime.tryParse(value)?.toUtc();
  }

  Future<void> _mergeFieldCandidate(
    SyncOperationEnvelope incoming,
    String fieldName,
  ) async {
    final head =
        await (select(syncFieldHeads)..where(
              (row) =>
                  row.entityType.equals(incoming.entityType) &
                  row.entitySyncId.equals(incoming.entitySyncId) &
                  row.fieldName.equals(fieldName),
            ))
            .getSingleOrNull();
    final candidateIds = head == null
        ? <String>[]
        : (jsonDecode(head.candidateOperationIdsJson) as List<dynamic>)
              .whereType<String>()
              .toList();
    final candidates = <SyncOperationEnvelope>[];
    for (final id in candidateIds) {
      final row =
          await (select(syncOperations)
                ..where((operation) => operation.operationId.equals(id)))
              .getSingleOrNull();
      if (row != null) candidates.add(_operationEnvelope(row));
    }

    if (candidates.any((candidate) => candidate.causallyIncludes(incoming))) {
      return;
    }
    candidates.removeWhere(incoming.causallyIncludes);
    if (!candidates.any(
      (candidate) => candidate.operationId == incoming.operationId,
    )) {
      candidates.add(incoming);
    }
    candidates.sort(_compareOperations);
    final ids = candidates.map((candidate) => candidate.operationId).toList();
    await into(syncFieldHeads).insertOnConflictUpdate(
      SyncFieldHeadsCompanion.insert(
        entityType: incoming.entityType,
        entitySyncId: incoming.entitySyncId,
        fieldName: fieldName,
        candidateOperationIdsJson: jsonEncode(ids),
      ),
    );

    final distinctValues = <String>{
      for (final candidate in candidates)
        jsonEncode(candidate.changes[fieldName]),
    };
    final hasConflict = distinctValues.length > 1;
    await _updateConflict(
      incoming: incoming,
      fieldName: fieldName,
      candidateIds: ids,
      hasConflict: hasConflict,
    );

    var winner = candidates.last;
    if (fieldName == SyncField.deleted && hasConflict) {
      winner = candidates.lastWhere(
        (candidate) => candidate.changes[fieldName] != null,
        orElse: () => candidates.last,
      );
    }
    await _materializeField(
      incoming.entityType,
      incoming.entitySyncId,
      fieldName,
      winner.changes[fieldName],
      winner.occurredAtUtc,
    );
  }

  int _compareOperations(
    SyncOperationEnvelope left,
    SyncOperationEnvelope right,
  ) {
    var result = left.hlcMillis.compareTo(right.hlcMillis);
    if (result != 0) return result;
    result = left.hlcCounter.compareTo(right.hlcCounter);
    if (result != 0) return result;
    result = left.originDeviceId.compareTo(right.originDeviceId);
    if (result != 0) return result;
    return left.originSequence.compareTo(right.originSequence);
  }

  Future<void> _updateConflict({
    required SyncOperationEnvelope incoming,
    required String fieldName,
    required List<String> candidateIds,
    required bool hasConflict,
  }) async {
    final open =
        await (select(syncConflicts)..where(
              (row) =>
                  row.entityType.equals(incoming.entityType) &
                  row.entitySyncId.equals(incoming.entitySyncId) &
                  row.fieldName.equals(fieldName) &
                  row.resolvedByOperationId.isNull(),
            ))
            .getSingleOrNull();
    final now = DateTime.now().toUtc();
    if (!hasConflict) {
      if (open != null) {
        await (update(
          syncConflicts,
        )..where((row) => row.conflictId.equals(open.conflictId))).write(
          SyncConflictsCompanion(
            resolvedByOperationId: Value(incoming.operationId),
            updatedAtUtc: Value(now),
          ),
        );
      }
      return;
    }
    if (open == null) {
      await into(syncConflicts).insert(
        SyncConflictsCompanion.insert(
          conflictId: const Uuid().v4(),
          entityType: incoming.entityType,
          entitySyncId: incoming.entitySyncId,
          fieldName: fieldName,
          candidateOperationIdsJson: jsonEncode(candidateIds),
          detectedAtUtc: now,
          updatedAtUtc: now,
        ),
      );
    } else {
      await (update(
        syncConflicts,
      )..where((row) => row.conflictId.equals(open.conflictId))).write(
        SyncConflictsCompanion(
          candidateOperationIdsJson: Value(jsonEncode(candidateIds)),
          updatedAtUtc: Value(now),
        ),
      );
    }
  }

  Future<void> _materializeField(
    String entityType,
    String syncId,
    String fieldName,
    Object? value,
    DateTime occurredAtUtc,
  ) async {
    if (entityType == SyncEntityType.category) {
      final query = update(categories)
        ..where((row) => row.syncId.equals(syncId));
      final companion = switch (fieldName) {
        SyncField.name => CategoriesCompanion(
          name: Value(value! as String),
          updatedAtUtc: Value(occurredAtUtc),
        ),
        SyncField.colorArgb => CategoriesCompanion(
          colorArgb: Value(value! as int),
          updatedAtUtc: Value(occurredAtUtc),
        ),
        SyncField.positionKey => CategoriesCompanion(
          positionKey: Value(value! as String),
          updatedAtUtc: Value(occurredAtUtc),
        ),
        SyncField.deleted => CategoriesCompanion(
          deletedAtUtc: Value(_nullableUtc(value)),
          updatedAtUtc: Value(occurredAtUtc),
        ),
        _ => const CategoriesCompanion(),
      };
      await query.write(companion);
      if (fieldName == SyncField.deleted && value != null) {
        final category = await (select(
          categories,
        )..where((row) => row.syncId.equals(syncId))).getSingleOrNull();
        if (category != null) {
          await (update(tasks)
                ..where((row) => row.categoryId.equals(category.id)))
              .write(const TasksCompanion(categoryId: Value(null)));
        }
      }
      if (fieldName == SyncField.positionKey ||
          fieldName == SyncField.deleted) {
        await _normalizeCategoryOrder();
      }
      return;
    }

    final query = update(tasks)..where((row) => row.syncId.equals(syncId));
    final companion = switch (fieldName) {
      SyncField.name => TasksCompanion(
        name: Value(value! as String),
        updatedAtUtc: Value(occurredAtUtc),
      ),
      SyncField.details => TasksCompanion(
        details: Value(value! as String),
        updatedAtUtc: Value(occurredAtUtc),
      ),
      SyncField.detailImages => TasksCompanion(
        detailImagesJson: Value(jsonEncode(value ?? const [])),
        updatedAtUtc: Value(occurredAtUtc),
      ),
      SyncField.deadlineUtc => TasksCompanion(
        deadlineUtc: Value(_nullableUtc(value)),
        updatedAtUtc: Value(occurredAtUtc),
      ),
      SyncField.categorySyncId => TasksCompanion(
        categoryId: Value(await _categoryLocalId(value as String?)),
        updatedAtUtc: Value(occurredAtUtc),
      ),
      SyncField.positionKey => TasksCompanion(
        positionKey: Value(value! as String),
        updatedAtUtc: Value(occurredAtUtc),
      ),
      SyncField.completion => _completionCompanion(value, occurredAtUtc),
      SyncField.deleted => TasksCompanion(
        deletedAtUtc: Value(_nullableUtc(value)),
        updatedAtUtc: Value(occurredAtUtc),
      ),
      _ => const TasksCompanion(),
    };
    await query.write(companion);
  }

  TasksCompanion _completionCompanion(Object? value, DateTime occurredAtUtc) {
    final map = Map<String, dynamic>.from(value! as Map);
    return TasksCompanion(
      isCompleted: Value(map['isCompleted']! as bool),
      completedAtUtc: Value(_nullableUtc(map['completedAtUtc'])),
      updatedAtUtc: Value(occurredAtUtc),
    );
  }

  Future<void> _normalizeCategoryOrder() async {
    final rows =
        await (select(categories)
              ..where((row) => row.deletedAtUtc.isNull())
              ..orderBy([
                (row) => OrderingTerm.asc(row.positionKey),
                (row) => OrderingTerm.asc(row.syncId),
                (row) => OrderingTerm.asc(row.id),
              ]))
            .get();
    await batch((batch) {
      for (final (index, row) in rows.indexed) {
        if (row.sortOrder == index) continue;
        batch.update(
          categories,
          CategoriesCompanion(sortOrder: Value(index)),
          where: (target) => target.id.equals(row.id),
        );
      }
    });
  }

  Future<SyncIdentity> readSyncIdentity() async {
    await ensureSyncReady();
    final state = await _ensureLocalSyncState();
    return SyncIdentity(
      spaceId: state.spaceId,
      deviceId: state.deviceId,
      deviceName: state.deviceName,
      vector: VersionVector.fromJsonString(state.vectorJson),
    );
  }

  Future<void> adoptSyncSpace(String spaceId) async {
    final trustedCount =
        await (select(syncDevices)..where((row) => row.isTrusted.equals(true)))
            .get()
            .then((rows) => rows.length);
    final state = await _ensureLocalSyncState();
    if (state.spaceId == spaceId) return;
    if (trustedCount > 0) {
      throw StateError('该设备已经加入另一个同步空间');
    }
    await (update(localSyncStates)..where((row) => row.id.equals(_syncStateId)))
        .write(LocalSyncStatesCompanion(spaceId: Value(spaceId)));
  }

  Future<void> registerSyncPeer(
    String deviceId,
    String displayName,
    VersionVector acknowledgedVector,
  ) async {
    final now = DateTime.now().toUtc();
    await into(syncDevices).insertOnConflictUpdate(
      SyncDevicesCompanion.insert(
        deviceId: deviceId,
        displayName: displayName,
        pairedAtUtc: now,
        lastSeenAtUtc: now,
        acknowledgedVectorJson: Value(acknowledgedVector.toJsonString()),
        isTrusted: const Value(true),
      ),
    );
  }

  Stream<List<SyncDevice>> watchSyncDevices() => (select(
    syncDevices,
  )..orderBy([(row) => OrderingTerm.desc(row.lastSeenAtUtc)])).watch();

  Future<void> forgetSyncPeer(String deviceId) async {
    await (delete(
      syncDevices,
    )..where((row) => row.deviceId.equals(deviceId))).go();
  }

  Future<List<SyncOperationEnvelope>> readOperationsMissingFrom(
    VersionVector peerVector,
  ) async {
    await ensureSyncReady();
    final rows =
        await (select(syncOperations)..orderBy([
              (row) => OrderingTerm.asc(row.hlcMillis),
              (row) => OrderingTerm.asc(row.hlcCounter),
              (row) => OrderingTerm.asc(row.originDeviceId),
              (row) => OrderingTerm.asc(row.originSequence),
            ]))
            .get();
    return [
      for (final row in rows)
        if (row.originSequence > peerVector[row.originDeviceId])
          _operationEnvelope(row),
    ];
  }

  Future<SyncApplyReport> applyRemoteOperations(
    List<SyncOperationEnvelope> incoming,
  ) async {
    await ensureSyncReady();
    var applied = 0;
    var duplicates = 0;
    await transaction(() async {
      final state = await _ensureLocalSyncState();
      final vector = VersionVector.fromJsonString(state.vectorJson);
      final pending = [...incoming];
      while (pending.isNotEmpty) {
        var progressed = false;
        for (final operation in [...pending]) {
          final existing =
              await (select(syncOperations)..where(
                    (row) => row.operationId.equals(operation.operationId),
                  ))
                  .getSingleOrNull();
          if (existing != null) {
            if (_operationEnvelope(existing).canonicalJson !=
                operation.canonicalJson) {
              throw const FormatException('检测到重复操作 ID 的内容不一致');
            }
            vector.observe(operation.originDeviceId, operation.originSequence);
            pending.remove(operation);
            duplicates += 1;
            progressed = true;
            continue;
          }
          if (!vector.covers(operation.context)) continue;
          if (operation.originSequence > vector[operation.originDeviceId] + 1) {
            continue;
          }
          await into(syncOperations).insert(_operationCompanion(operation));
          await _mergeStoredOperation(operation);
          vector.observe(operation.originDeviceId, operation.originSequence);
          pending.remove(operation);
          applied += 1;
          progressed = true;
        }
        if (!progressed) {
          throw const FormatException('同步操作缺少前置版本，无法安全合并');
        }
      }
      final latestMillis = incoming.fold<int>(
        state.hlcMillis,
        (value, operation) =>
            operation.hlcMillis > value ? operation.hlcMillis : value,
      );
      await (update(
        localSyncStates,
      )..where((row) => row.id.equals(_syncStateId))).write(
        LocalSyncStatesCompanion(
          vectorJson: Value(vector.toJsonString()),
          hlcMillis: Value(latestMillis),
        ),
      );
      await _normalizeCategoryOrder();
    });
    final conflicts = await openConflictCount();
    return SyncApplyReport(
      applied: applied,
      duplicates: duplicates,
      conflicts: conflicts,
    );
  }

  Stream<int> watchOpenConflictCount() {
    final query = select(syncConflicts)
      ..where((row) => row.resolvedByOperationId.isNull());
    return query.watch().map((rows) => rows.length);
  }

  Future<int> openConflictCount() async {
    final rows = await (select(
      syncConflicts,
    )..where((row) => row.resolvedByOperationId.isNull())).get();
    return rows.length;
  }

  Stream<List<SyncConflictView>> watchOpenConflicts() {
    final query = select(syncConflicts)
      ..where((row) => row.resolvedByOperationId.isNull())
      ..orderBy([(row) => OrderingTerm.desc(row.updatedAtUtc)]);
    return query.watch().asyncMap((rows) async {
      final result = <SyncConflictView>[];
      for (final row in rows) {
        final candidateIds =
            (jsonDecode(row.candidateOperationIdsJson) as List<dynamic>)
                .whereType<String>();
        final candidates = <SyncConflictCandidate>[];
        for (final id in candidateIds) {
          final operationRow =
              await (select(syncOperations)
                    ..where((operation) => operation.operationId.equals(id)))
                  .getSingleOrNull();
          if (operationRow == null) continue;
          final operation = _operationEnvelope(operationRow);
          candidates.add(
            SyncConflictCandidate(
              operationId: operation.operationId,
              deviceId: operation.originDeviceId,
              deviceName: await _deviceName(operation.originDeviceId),
              value: operation.changes[row.fieldName],
              displayValue: await _conflictDisplayValue(
                row.fieldName,
                operation.changes[row.fieldName],
              ),
              occurredAtUtc: operation.occurredAtUtc,
            ),
          );
        }
        result.add(
          SyncConflictView(
            id: row.conflictId,
            entityType: row.entityType,
            entitySyncId: row.entitySyncId,
            entityName: await _entityName(row.entityType, row.entitySyncId),
            fieldName: row.fieldName,
            candidates: candidates,
            detectedAtUtc: row.detectedAtUtc,
          ),
        );
      }
      return result;
    });
  }

  Future<String> _deviceName(String deviceId) async {
    final state = await _ensureLocalSyncState();
    if (state.deviceId == deviceId) return state.deviceName;
    return await (select(syncDevices)
              ..where((row) => row.deviceId.equals(deviceId)))
            .map((row) => row.displayName)
            .getSingleOrNull() ??
        '其他设备';
  }

  Future<Object?> _conflictDisplayValue(String field, Object? value) async {
    if (field != SyncField.categorySyncId || value is! String) return null;
    return (select(categories)..where((row) => row.syncId.equals(value)))
        .map((row) => row.name)
        .getSingleOrNull();
  }

  Future<String> _entityName(String type, String syncId) async {
    if (type == SyncEntityType.category) {
      return await (select(categories)
                ..where((row) => row.syncId.equals(syncId)))
              .map((row) => row.name)
              .getSingleOrNull() ??
          '已删除分类';
    }
    return await (select(tasks)..where((row) => row.syncId.equals(syncId)))
            .map((row) => row.name)
            .getSingleOrNull() ??
        '已删除事项';
  }

  Future<void> resolveSyncConflict(String conflictId, Object? value) async {
    await transaction(() async {
      final conflict = await (select(
        syncConflicts,
      )..where((row) => row.conflictId.equals(conflictId))).getSingle();
      if (conflict.resolvedByOperationId != null) return;
      final candidates =
          (jsonDecode(conflict.candidateOperationIdsJson) as List<dynamic>)
              .whereType<String>()
              .toList(growable: false);
      await _recordLocalOperation(
        entityType: conflict.entityType,
        entitySyncId: conflict.entitySyncId,
        kind: SyncOperationKind.resolve,
        changes: {conflict.fieldName: value},
        resolves: candidates,
      );
    });
  }

  Future<String> computeSyncStateDigest() async {
    final categoryRows = await (select(
      categories,
    )..orderBy([(row) => OrderingTerm.asc(row.syncId)])).get();
    final taskRows = await (select(
      tasks,
    )..orderBy([(row) => OrderingTerm.asc(row.syncId)])).get();
    final heads =
        await (select(syncFieldHeads)..orderBy([
              (row) => OrderingTerm.asc(row.entityType),
              (row) => OrderingTerm.asc(row.entitySyncId),
              (row) => OrderingTerm.asc(row.fieldName),
            ]))
            .get();
    final identity = await readSyncIdentity();
    final canonical = jsonEncode({
      'vector': jsonDecode(identity.vector.toJsonString()),
      'categories': [
        for (final row in categoryRows)
          {
            'syncId': row.syncId,
            'name': row.name,
            'colorArgb': row.colorArgb,
            'positionKey': row.positionKey,
            'deletedAtUtc': row.deletedAtUtc?.toUtc().toIso8601String(),
          },
      ],
      'tasks': [
        for (final row in taskRows)
          {
            'syncId': row.syncId,
            'name': row.name,
            'details': row.details,
            'detailImages': jsonDecode(row.detailImagesJson),
            'deadlineUtc': row.deadlineUtc?.toUtc().toIso8601String(),
            'categorySyncId': await _categorySyncId(row.categoryId),
            'positionKey': row.positionKey,
            'isCompleted': row.isCompleted,
            'completedAtUtc': row.completedAtUtc?.toUtc().toIso8601String(),
            'deletedAtUtc': row.deletedAtUtc?.toUtc().toIso8601String(),
          },
      ],
      'heads': [
        for (final row in heads)
          {
            'entityType': row.entityType,
            'entitySyncId': row.entitySyncId,
            'fieldName': row.fieldName,
            'candidates': (jsonDecode(row.candidateOperationIdsJson) as List)
              ..sort(),
          },
      ],
    });
    final digest = await Sha256().hash(utf8.encode(canonical));
    return digest.bytes
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join();
  }
}
