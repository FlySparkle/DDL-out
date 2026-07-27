// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, Category> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _syncIdMeta = const VerificationMeta('syncId');
  @override
  late final GeneratedColumn<String> syncId = GeneratedColumn<String>(
    'sync_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 60,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorArgbMeta = const VerificationMeta(
    'colorArgb',
  );
  @override
  late final GeneratedColumn<int> colorArgb = GeneratedColumn<int>(
    'color_argb',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _positionKeyMeta = const VerificationMeta(
    'positionKey',
  );
  @override
  late final GeneratedColumn<String> positionKey = GeneratedColumn<String>(
    'position_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtUtcMeta = const VerificationMeta(
    'createdAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> createdAtUtc = GeneratedColumn<DateTime>(
    'created_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtUtcMeta = const VerificationMeta(
    'updatedAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAtUtc = GeneratedColumn<DateTime>(
    'updated_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtUtcMeta = const VerificationMeta(
    'deletedAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAtUtc = GeneratedColumn<DateTime>(
    'deleted_at_utc',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    syncId,
    name,
    colorArgb,
    sortOrder,
    positionKey,
    createdAtUtc,
    updatedAtUtc,
    deletedAtUtc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<Category> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('sync_id')) {
      context.handle(
        _syncIdMeta,
        syncId.isAcceptableOrUnknown(data['sync_id']!, _syncIdMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('color_argb')) {
      context.handle(
        _colorArgbMeta,
        colorArgb.isAcceptableOrUnknown(data['color_argb']!, _colorArgbMeta),
      );
    } else if (isInserting) {
      context.missing(_colorArgbMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('position_key')) {
      context.handle(
        _positionKeyMeta,
        positionKey.isAcceptableOrUnknown(
          data['position_key']!,
          _positionKeyMeta,
        ),
      );
    }
    if (data.containsKey('created_at_utc')) {
      context.handle(
        _createdAtUtcMeta,
        createdAtUtc.isAcceptableOrUnknown(
          data['created_at_utc']!,
          _createdAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtUtcMeta);
    }
    if (data.containsKey('updated_at_utc')) {
      context.handle(
        _updatedAtUtcMeta,
        updatedAtUtc.isAcceptableOrUnknown(
          data['updated_at_utc']!,
          _updatedAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtUtcMeta);
    }
    if (data.containsKey('deleted_at_utc')) {
      context.handle(
        _deletedAtUtcMeta,
        deletedAtUtc.isAcceptableOrUnknown(
          data['deleted_at_utc']!,
          _deletedAtUtcMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Category map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Category(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      syncId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      colorArgb: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color_argb'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      positionKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}position_key'],
      ),
      createdAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at_utc'],
      )!,
      updatedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at_utc'],
      )!,
      deletedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at_utc'],
      ),
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class Category extends DataClass implements Insertable<Category> {
  final int id;
  final String? syncId;
  final String name;
  final int colorArgb;
  final int sortOrder;
  final String? positionKey;
  final DateTime createdAtUtc;
  final DateTime updatedAtUtc;
  final DateTime? deletedAtUtc;
  const Category({
    required this.id,
    this.syncId,
    required this.name,
    required this.colorArgb,
    required this.sortOrder,
    this.positionKey,
    required this.createdAtUtc,
    required this.updatedAtUtc,
    this.deletedAtUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || syncId != null) {
      map['sync_id'] = Variable<String>(syncId);
    }
    map['name'] = Variable<String>(name);
    map['color_argb'] = Variable<int>(colorArgb);
    map['sort_order'] = Variable<int>(sortOrder);
    if (!nullToAbsent || positionKey != null) {
      map['position_key'] = Variable<String>(positionKey);
    }
    map['created_at_utc'] = Variable<DateTime>(createdAtUtc);
    map['updated_at_utc'] = Variable<DateTime>(updatedAtUtc);
    if (!nullToAbsent || deletedAtUtc != null) {
      map['deleted_at_utc'] = Variable<DateTime>(deletedAtUtc);
    }
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      syncId: syncId == null && nullToAbsent
          ? const Value.absent()
          : Value(syncId),
      name: Value(name),
      colorArgb: Value(colorArgb),
      sortOrder: Value(sortOrder),
      positionKey: positionKey == null && nullToAbsent
          ? const Value.absent()
          : Value(positionKey),
      createdAtUtc: Value(createdAtUtc),
      updatedAtUtc: Value(updatedAtUtc),
      deletedAtUtc: deletedAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAtUtc),
    );
  }

  factory Category.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Category(
      id: serializer.fromJson<int>(json['id']),
      syncId: serializer.fromJson<String?>(json['syncId']),
      name: serializer.fromJson<String>(json['name']),
      colorArgb: serializer.fromJson<int>(json['colorArgb']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      positionKey: serializer.fromJson<String?>(json['positionKey']),
      createdAtUtc: serializer.fromJson<DateTime>(json['createdAtUtc']),
      updatedAtUtc: serializer.fromJson<DateTime>(json['updatedAtUtc']),
      deletedAtUtc: serializer.fromJson<DateTime?>(json['deletedAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'syncId': serializer.toJson<String?>(syncId),
      'name': serializer.toJson<String>(name),
      'colorArgb': serializer.toJson<int>(colorArgb),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'positionKey': serializer.toJson<String?>(positionKey),
      'createdAtUtc': serializer.toJson<DateTime>(createdAtUtc),
      'updatedAtUtc': serializer.toJson<DateTime>(updatedAtUtc),
      'deletedAtUtc': serializer.toJson<DateTime?>(deletedAtUtc),
    };
  }

  Category copyWith({
    int? id,
    Value<String?> syncId = const Value.absent(),
    String? name,
    int? colorArgb,
    int? sortOrder,
    Value<String?> positionKey = const Value.absent(),
    DateTime? createdAtUtc,
    DateTime? updatedAtUtc,
    Value<DateTime?> deletedAtUtc = const Value.absent(),
  }) => Category(
    id: id ?? this.id,
    syncId: syncId.present ? syncId.value : this.syncId,
    name: name ?? this.name,
    colorArgb: colorArgb ?? this.colorArgb,
    sortOrder: sortOrder ?? this.sortOrder,
    positionKey: positionKey.present ? positionKey.value : this.positionKey,
    createdAtUtc: createdAtUtc ?? this.createdAtUtc,
    updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
    deletedAtUtc: deletedAtUtc.present ? deletedAtUtc.value : this.deletedAtUtc,
  );
  Category copyWithCompanion(CategoriesCompanion data) {
    return Category(
      id: data.id.present ? data.id.value : this.id,
      syncId: data.syncId.present ? data.syncId.value : this.syncId,
      name: data.name.present ? data.name.value : this.name,
      colorArgb: data.colorArgb.present ? data.colorArgb.value : this.colorArgb,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      positionKey: data.positionKey.present
          ? data.positionKey.value
          : this.positionKey,
      createdAtUtc: data.createdAtUtc.present
          ? data.createdAtUtc.value
          : this.createdAtUtc,
      updatedAtUtc: data.updatedAtUtc.present
          ? data.updatedAtUtc.value
          : this.updatedAtUtc,
      deletedAtUtc: data.deletedAtUtc.present
          ? data.deletedAtUtc.value
          : this.deletedAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Category(')
          ..write('id: $id, ')
          ..write('syncId: $syncId, ')
          ..write('name: $name, ')
          ..write('colorArgb: $colorArgb, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('positionKey: $positionKey, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc, ')
          ..write('deletedAtUtc: $deletedAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    syncId,
    name,
    colorArgb,
    sortOrder,
    positionKey,
    createdAtUtc,
    updatedAtUtc,
    deletedAtUtc,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Category &&
          other.id == this.id &&
          other.syncId == this.syncId &&
          other.name == this.name &&
          other.colorArgb == this.colorArgb &&
          other.sortOrder == this.sortOrder &&
          other.positionKey == this.positionKey &&
          other.createdAtUtc == this.createdAtUtc &&
          other.updatedAtUtc == this.updatedAtUtc &&
          other.deletedAtUtc == this.deletedAtUtc);
}

class CategoriesCompanion extends UpdateCompanion<Category> {
  final Value<int> id;
  final Value<String?> syncId;
  final Value<String> name;
  final Value<int> colorArgb;
  final Value<int> sortOrder;
  final Value<String?> positionKey;
  final Value<DateTime> createdAtUtc;
  final Value<DateTime> updatedAtUtc;
  final Value<DateTime?> deletedAtUtc;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.syncId = const Value.absent(),
    this.name = const Value.absent(),
    this.colorArgb = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.positionKey = const Value.absent(),
    this.createdAtUtc = const Value.absent(),
    this.updatedAtUtc = const Value.absent(),
    this.deletedAtUtc = const Value.absent(),
  });
  CategoriesCompanion.insert({
    this.id = const Value.absent(),
    this.syncId = const Value.absent(),
    required String name,
    required int colorArgb,
    this.sortOrder = const Value.absent(),
    this.positionKey = const Value.absent(),
    required DateTime createdAtUtc,
    required DateTime updatedAtUtc,
    this.deletedAtUtc = const Value.absent(),
  }) : name = Value(name),
       colorArgb = Value(colorArgb),
       createdAtUtc = Value(createdAtUtc),
       updatedAtUtc = Value(updatedAtUtc);
  static Insertable<Category> custom({
    Expression<int>? id,
    Expression<String>? syncId,
    Expression<String>? name,
    Expression<int>? colorArgb,
    Expression<int>? sortOrder,
    Expression<String>? positionKey,
    Expression<DateTime>? createdAtUtc,
    Expression<DateTime>? updatedAtUtc,
    Expression<DateTime>? deletedAtUtc,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (syncId != null) 'sync_id': syncId,
      if (name != null) 'name': name,
      if (colorArgb != null) 'color_argb': colorArgb,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (positionKey != null) 'position_key': positionKey,
      if (createdAtUtc != null) 'created_at_utc': createdAtUtc,
      if (updatedAtUtc != null) 'updated_at_utc': updatedAtUtc,
      if (deletedAtUtc != null) 'deleted_at_utc': deletedAtUtc,
    });
  }

  CategoriesCompanion copyWith({
    Value<int>? id,
    Value<String?>? syncId,
    Value<String>? name,
    Value<int>? colorArgb,
    Value<int>? sortOrder,
    Value<String?>? positionKey,
    Value<DateTime>? createdAtUtc,
    Value<DateTime>? updatedAtUtc,
    Value<DateTime?>? deletedAtUtc,
  }) {
    return CategoriesCompanion(
      id: id ?? this.id,
      syncId: syncId ?? this.syncId,
      name: name ?? this.name,
      colorArgb: colorArgb ?? this.colorArgb,
      sortOrder: sortOrder ?? this.sortOrder,
      positionKey: positionKey ?? this.positionKey,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
      updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
      deletedAtUtc: deletedAtUtc ?? this.deletedAtUtc,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (syncId.present) {
      map['sync_id'] = Variable<String>(syncId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (colorArgb.present) {
      map['color_argb'] = Variable<int>(colorArgb.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (positionKey.present) {
      map['position_key'] = Variable<String>(positionKey.value);
    }
    if (createdAtUtc.present) {
      map['created_at_utc'] = Variable<DateTime>(createdAtUtc.value);
    }
    if (updatedAtUtc.present) {
      map['updated_at_utc'] = Variable<DateTime>(updatedAtUtc.value);
    }
    if (deletedAtUtc.present) {
      map['deleted_at_utc'] = Variable<DateTime>(deletedAtUtc.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('syncId: $syncId, ')
          ..write('name: $name, ')
          ..write('colorArgb: $colorArgb, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('positionKey: $positionKey, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc, ')
          ..write('deletedAtUtc: $deletedAtUtc')
          ..write(')'))
        .toString();
  }
}

class $TasksTable extends Tasks with TableInfo<$TasksTable, Task> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _syncIdMeta = const VerificationMeta('syncId');
  @override
  late final GeneratedColumn<String> syncId = GeneratedColumn<String>(
    'sync_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 200,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _detailsMeta = const VerificationMeta(
    'details',
  );
  @override
  late final GeneratedColumn<String> details = GeneratedColumn<String>(
    'details',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _detailImagesJsonMeta = const VerificationMeta(
    'detailImagesJson',
  );
  @override
  late final GeneratedColumn<String> detailImagesJson = GeneratedColumn<String>(
    'detail_images_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _deadlineUtcMeta = const VerificationMeta(
    'deadlineUtc',
  );
  @override
  late final GeneratedColumn<DateTime> deadlineUtc = GeneratedColumn<DateTime>(
    'deadline_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _positionKeyMeta = const VerificationMeta(
    'positionKey',
  );
  @override
  late final GeneratedColumn<String> positionKey = GeneratedColumn<String>(
    'position_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isCompletedMeta = const VerificationMeta(
    'isCompleted',
  );
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
    'is_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtUtcMeta = const VerificationMeta(
    'createdAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> createdAtUtc = GeneratedColumn<DateTime>(
    'created_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtUtcMeta = const VerificationMeta(
    'updatedAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAtUtc = GeneratedColumn<DateTime>(
    'updated_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtUtcMeta = const VerificationMeta(
    'completedAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> completedAtUtc =
      GeneratedColumn<DateTime>(
        'completed_at_utc',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _deletedAtUtcMeta = const VerificationMeta(
    'deletedAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAtUtc = GeneratedColumn<DateTime>(
    'deleted_at_utc',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    syncId,
    name,
    details,
    detailImagesJson,
    deadlineUtc,
    categoryId,
    positionKey,
    isCompleted,
    createdAtUtc,
    updatedAtUtc,
    completedAtUtc,
    deletedAtUtc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tasks';
  @override
  VerificationContext validateIntegrity(
    Insertable<Task> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('sync_id')) {
      context.handle(
        _syncIdMeta,
        syncId.isAcceptableOrUnknown(data['sync_id']!, _syncIdMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('details')) {
      context.handle(
        _detailsMeta,
        details.isAcceptableOrUnknown(data['details']!, _detailsMeta),
      );
    }
    if (data.containsKey('detail_images_json')) {
      context.handle(
        _detailImagesJsonMeta,
        detailImagesJson.isAcceptableOrUnknown(
          data['detail_images_json']!,
          _detailImagesJsonMeta,
        ),
      );
    }
    if (data.containsKey('deadline_utc')) {
      context.handle(
        _deadlineUtcMeta,
        deadlineUtc.isAcceptableOrUnknown(
          data['deadline_utc']!,
          _deadlineUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_deadlineUtcMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('position_key')) {
      context.handle(
        _positionKeyMeta,
        positionKey.isAcceptableOrUnknown(
          data['position_key']!,
          _positionKeyMeta,
        ),
      );
    }
    if (data.containsKey('is_completed')) {
      context.handle(
        _isCompletedMeta,
        isCompleted.isAcceptableOrUnknown(
          data['is_completed']!,
          _isCompletedMeta,
        ),
      );
    }
    if (data.containsKey('created_at_utc')) {
      context.handle(
        _createdAtUtcMeta,
        createdAtUtc.isAcceptableOrUnknown(
          data['created_at_utc']!,
          _createdAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtUtcMeta);
    }
    if (data.containsKey('updated_at_utc')) {
      context.handle(
        _updatedAtUtcMeta,
        updatedAtUtc.isAcceptableOrUnknown(
          data['updated_at_utc']!,
          _updatedAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtUtcMeta);
    }
    if (data.containsKey('completed_at_utc')) {
      context.handle(
        _completedAtUtcMeta,
        completedAtUtc.isAcceptableOrUnknown(
          data['completed_at_utc']!,
          _completedAtUtcMeta,
        ),
      );
    }
    if (data.containsKey('deleted_at_utc')) {
      context.handle(
        _deletedAtUtcMeta,
        deletedAtUtc.isAcceptableOrUnknown(
          data['deleted_at_utc']!,
          _deletedAtUtcMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Task map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Task(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      syncId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      details: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}details'],
      )!,
      detailImagesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}detail_images_json'],
      )!,
      deadlineUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deadline_utc'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}category_id'],
      ),
      positionKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}position_key'],
      ),
      isCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_completed'],
      )!,
      createdAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at_utc'],
      )!,
      updatedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at_utc'],
      )!,
      completedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at_utc'],
      ),
      deletedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at_utc'],
      ),
    );
  }

  @override
  $TasksTable createAlias(String alias) {
    return $TasksTable(attachedDatabase, alias);
  }
}

class Task extends DataClass implements Insertable<Task> {
  final int id;
  final String? syncId;
  final String name;
  final String details;
  final String detailImagesJson;
  final DateTime deadlineUtc;
  final int? categoryId;
  final String? positionKey;
  final bool isCompleted;
  final DateTime createdAtUtc;
  final DateTime updatedAtUtc;
  final DateTime? completedAtUtc;
  final DateTime? deletedAtUtc;
  const Task({
    required this.id,
    this.syncId,
    required this.name,
    required this.details,
    required this.detailImagesJson,
    required this.deadlineUtc,
    this.categoryId,
    this.positionKey,
    required this.isCompleted,
    required this.createdAtUtc,
    required this.updatedAtUtc,
    this.completedAtUtc,
    this.deletedAtUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || syncId != null) {
      map['sync_id'] = Variable<String>(syncId);
    }
    map['name'] = Variable<String>(name);
    map['details'] = Variable<String>(details);
    map['detail_images_json'] = Variable<String>(detailImagesJson);
    map['deadline_utc'] = Variable<DateTime>(deadlineUtc);
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<int>(categoryId);
    }
    if (!nullToAbsent || positionKey != null) {
      map['position_key'] = Variable<String>(positionKey);
    }
    map['is_completed'] = Variable<bool>(isCompleted);
    map['created_at_utc'] = Variable<DateTime>(createdAtUtc);
    map['updated_at_utc'] = Variable<DateTime>(updatedAtUtc);
    if (!nullToAbsent || completedAtUtc != null) {
      map['completed_at_utc'] = Variable<DateTime>(completedAtUtc);
    }
    if (!nullToAbsent || deletedAtUtc != null) {
      map['deleted_at_utc'] = Variable<DateTime>(deletedAtUtc);
    }
    return map;
  }

  TasksCompanion toCompanion(bool nullToAbsent) {
    return TasksCompanion(
      id: Value(id),
      syncId: syncId == null && nullToAbsent
          ? const Value.absent()
          : Value(syncId),
      name: Value(name),
      details: Value(details),
      detailImagesJson: Value(detailImagesJson),
      deadlineUtc: Value(deadlineUtc),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      positionKey: positionKey == null && nullToAbsent
          ? const Value.absent()
          : Value(positionKey),
      isCompleted: Value(isCompleted),
      createdAtUtc: Value(createdAtUtc),
      updatedAtUtc: Value(updatedAtUtc),
      completedAtUtc: completedAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAtUtc),
      deletedAtUtc: deletedAtUtc == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAtUtc),
    );
  }

  factory Task.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Task(
      id: serializer.fromJson<int>(json['id']),
      syncId: serializer.fromJson<String?>(json['syncId']),
      name: serializer.fromJson<String>(json['name']),
      details: serializer.fromJson<String>(json['details']),
      detailImagesJson: serializer.fromJson<String>(json['detailImagesJson']),
      deadlineUtc: serializer.fromJson<DateTime>(json['deadlineUtc']),
      categoryId: serializer.fromJson<int?>(json['categoryId']),
      positionKey: serializer.fromJson<String?>(json['positionKey']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      createdAtUtc: serializer.fromJson<DateTime>(json['createdAtUtc']),
      updatedAtUtc: serializer.fromJson<DateTime>(json['updatedAtUtc']),
      completedAtUtc: serializer.fromJson<DateTime?>(json['completedAtUtc']),
      deletedAtUtc: serializer.fromJson<DateTime?>(json['deletedAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'syncId': serializer.toJson<String?>(syncId),
      'name': serializer.toJson<String>(name),
      'details': serializer.toJson<String>(details),
      'detailImagesJson': serializer.toJson<String>(detailImagesJson),
      'deadlineUtc': serializer.toJson<DateTime>(deadlineUtc),
      'categoryId': serializer.toJson<int?>(categoryId),
      'positionKey': serializer.toJson<String?>(positionKey),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'createdAtUtc': serializer.toJson<DateTime>(createdAtUtc),
      'updatedAtUtc': serializer.toJson<DateTime>(updatedAtUtc),
      'completedAtUtc': serializer.toJson<DateTime?>(completedAtUtc),
      'deletedAtUtc': serializer.toJson<DateTime?>(deletedAtUtc),
    };
  }

  Task copyWith({
    int? id,
    Value<String?> syncId = const Value.absent(),
    String? name,
    String? details,
    String? detailImagesJson,
    DateTime? deadlineUtc,
    Value<int?> categoryId = const Value.absent(),
    Value<String?> positionKey = const Value.absent(),
    bool? isCompleted,
    DateTime? createdAtUtc,
    DateTime? updatedAtUtc,
    Value<DateTime?> completedAtUtc = const Value.absent(),
    Value<DateTime?> deletedAtUtc = const Value.absent(),
  }) => Task(
    id: id ?? this.id,
    syncId: syncId.present ? syncId.value : this.syncId,
    name: name ?? this.name,
    details: details ?? this.details,
    detailImagesJson: detailImagesJson ?? this.detailImagesJson,
    deadlineUtc: deadlineUtc ?? this.deadlineUtc,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
    positionKey: positionKey.present ? positionKey.value : this.positionKey,
    isCompleted: isCompleted ?? this.isCompleted,
    createdAtUtc: createdAtUtc ?? this.createdAtUtc,
    updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
    completedAtUtc: completedAtUtc.present
        ? completedAtUtc.value
        : this.completedAtUtc,
    deletedAtUtc: deletedAtUtc.present ? deletedAtUtc.value : this.deletedAtUtc,
  );
  Task copyWithCompanion(TasksCompanion data) {
    return Task(
      id: data.id.present ? data.id.value : this.id,
      syncId: data.syncId.present ? data.syncId.value : this.syncId,
      name: data.name.present ? data.name.value : this.name,
      details: data.details.present ? data.details.value : this.details,
      detailImagesJson: data.detailImagesJson.present
          ? data.detailImagesJson.value
          : this.detailImagesJson,
      deadlineUtc: data.deadlineUtc.present
          ? data.deadlineUtc.value
          : this.deadlineUtc,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      positionKey: data.positionKey.present
          ? data.positionKey.value
          : this.positionKey,
      isCompleted: data.isCompleted.present
          ? data.isCompleted.value
          : this.isCompleted,
      createdAtUtc: data.createdAtUtc.present
          ? data.createdAtUtc.value
          : this.createdAtUtc,
      updatedAtUtc: data.updatedAtUtc.present
          ? data.updatedAtUtc.value
          : this.updatedAtUtc,
      completedAtUtc: data.completedAtUtc.present
          ? data.completedAtUtc.value
          : this.completedAtUtc,
      deletedAtUtc: data.deletedAtUtc.present
          ? data.deletedAtUtc.value
          : this.deletedAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Task(')
          ..write('id: $id, ')
          ..write('syncId: $syncId, ')
          ..write('name: $name, ')
          ..write('details: $details, ')
          ..write('detailImagesJson: $detailImagesJson, ')
          ..write('deadlineUtc: $deadlineUtc, ')
          ..write('categoryId: $categoryId, ')
          ..write('positionKey: $positionKey, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc, ')
          ..write('completedAtUtc: $completedAtUtc, ')
          ..write('deletedAtUtc: $deletedAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    syncId,
    name,
    details,
    detailImagesJson,
    deadlineUtc,
    categoryId,
    positionKey,
    isCompleted,
    createdAtUtc,
    updatedAtUtc,
    completedAtUtc,
    deletedAtUtc,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Task &&
          other.id == this.id &&
          other.syncId == this.syncId &&
          other.name == this.name &&
          other.details == this.details &&
          other.detailImagesJson == this.detailImagesJson &&
          other.deadlineUtc == this.deadlineUtc &&
          other.categoryId == this.categoryId &&
          other.positionKey == this.positionKey &&
          other.isCompleted == this.isCompleted &&
          other.createdAtUtc == this.createdAtUtc &&
          other.updatedAtUtc == this.updatedAtUtc &&
          other.completedAtUtc == this.completedAtUtc &&
          other.deletedAtUtc == this.deletedAtUtc);
}

class TasksCompanion extends UpdateCompanion<Task> {
  final Value<int> id;
  final Value<String?> syncId;
  final Value<String> name;
  final Value<String> details;
  final Value<String> detailImagesJson;
  final Value<DateTime> deadlineUtc;
  final Value<int?> categoryId;
  final Value<String?> positionKey;
  final Value<bool> isCompleted;
  final Value<DateTime> createdAtUtc;
  final Value<DateTime> updatedAtUtc;
  final Value<DateTime?> completedAtUtc;
  final Value<DateTime?> deletedAtUtc;
  const TasksCompanion({
    this.id = const Value.absent(),
    this.syncId = const Value.absent(),
    this.name = const Value.absent(),
    this.details = const Value.absent(),
    this.detailImagesJson = const Value.absent(),
    this.deadlineUtc = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.positionKey = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.createdAtUtc = const Value.absent(),
    this.updatedAtUtc = const Value.absent(),
    this.completedAtUtc = const Value.absent(),
    this.deletedAtUtc = const Value.absent(),
  });
  TasksCompanion.insert({
    this.id = const Value.absent(),
    this.syncId = const Value.absent(),
    required String name,
    this.details = const Value.absent(),
    this.detailImagesJson = const Value.absent(),
    required DateTime deadlineUtc,
    this.categoryId = const Value.absent(),
    this.positionKey = const Value.absent(),
    this.isCompleted = const Value.absent(),
    required DateTime createdAtUtc,
    required DateTime updatedAtUtc,
    this.completedAtUtc = const Value.absent(),
    this.deletedAtUtc = const Value.absent(),
  }) : name = Value(name),
       deadlineUtc = Value(deadlineUtc),
       createdAtUtc = Value(createdAtUtc),
       updatedAtUtc = Value(updatedAtUtc);
  static Insertable<Task> custom({
    Expression<int>? id,
    Expression<String>? syncId,
    Expression<String>? name,
    Expression<String>? details,
    Expression<String>? detailImagesJson,
    Expression<DateTime>? deadlineUtc,
    Expression<int>? categoryId,
    Expression<String>? positionKey,
    Expression<bool>? isCompleted,
    Expression<DateTime>? createdAtUtc,
    Expression<DateTime>? updatedAtUtc,
    Expression<DateTime>? completedAtUtc,
    Expression<DateTime>? deletedAtUtc,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (syncId != null) 'sync_id': syncId,
      if (name != null) 'name': name,
      if (details != null) 'details': details,
      if (detailImagesJson != null) 'detail_images_json': detailImagesJson,
      if (deadlineUtc != null) 'deadline_utc': deadlineUtc,
      if (categoryId != null) 'category_id': categoryId,
      if (positionKey != null) 'position_key': positionKey,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (createdAtUtc != null) 'created_at_utc': createdAtUtc,
      if (updatedAtUtc != null) 'updated_at_utc': updatedAtUtc,
      if (completedAtUtc != null) 'completed_at_utc': completedAtUtc,
      if (deletedAtUtc != null) 'deleted_at_utc': deletedAtUtc,
    });
  }

  TasksCompanion copyWith({
    Value<int>? id,
    Value<String?>? syncId,
    Value<String>? name,
    Value<String>? details,
    Value<String>? detailImagesJson,
    Value<DateTime>? deadlineUtc,
    Value<int?>? categoryId,
    Value<String?>? positionKey,
    Value<bool>? isCompleted,
    Value<DateTime>? createdAtUtc,
    Value<DateTime>? updatedAtUtc,
    Value<DateTime?>? completedAtUtc,
    Value<DateTime?>? deletedAtUtc,
  }) {
    return TasksCompanion(
      id: id ?? this.id,
      syncId: syncId ?? this.syncId,
      name: name ?? this.name,
      details: details ?? this.details,
      detailImagesJson: detailImagesJson ?? this.detailImagesJson,
      deadlineUtc: deadlineUtc ?? this.deadlineUtc,
      categoryId: categoryId ?? this.categoryId,
      positionKey: positionKey ?? this.positionKey,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
      updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
      completedAtUtc: completedAtUtc ?? this.completedAtUtc,
      deletedAtUtc: deletedAtUtc ?? this.deletedAtUtc,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (syncId.present) {
      map['sync_id'] = Variable<String>(syncId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (details.present) {
      map['details'] = Variable<String>(details.value);
    }
    if (detailImagesJson.present) {
      map['detail_images_json'] = Variable<String>(detailImagesJson.value);
    }
    if (deadlineUtc.present) {
      map['deadline_utc'] = Variable<DateTime>(deadlineUtc.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (positionKey.present) {
      map['position_key'] = Variable<String>(positionKey.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (createdAtUtc.present) {
      map['created_at_utc'] = Variable<DateTime>(createdAtUtc.value);
    }
    if (updatedAtUtc.present) {
      map['updated_at_utc'] = Variable<DateTime>(updatedAtUtc.value);
    }
    if (completedAtUtc.present) {
      map['completed_at_utc'] = Variable<DateTime>(completedAtUtc.value);
    }
    if (deletedAtUtc.present) {
      map['deleted_at_utc'] = Variable<DateTime>(deletedAtUtc.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TasksCompanion(')
          ..write('id: $id, ')
          ..write('syncId: $syncId, ')
          ..write('name: $name, ')
          ..write('details: $details, ')
          ..write('detailImagesJson: $detailImagesJson, ')
          ..write('deadlineUtc: $deadlineUtc, ')
          ..write('categoryId: $categoryId, ')
          ..write('positionKey: $positionKey, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('createdAtUtc: $createdAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc, ')
          ..write('completedAtUtc: $completedAtUtc, ')
          ..write('deletedAtUtc: $deletedAtUtc')
          ..write(')'))
        .toString();
  }
}

class $LocalSyncStatesTable extends LocalSyncStates
    with TableInfo<$LocalSyncStatesTable, LocalSyncState> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalSyncStatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _spaceIdMeta = const VerificationMeta(
    'spaceId',
  );
  @override
  late final GeneratedColumn<String> spaceId = GeneratedColumn<String>(
    'space_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceNameMeta = const VerificationMeta(
    'deviceName',
  );
  @override
  late final GeneratedColumn<String> deviceName = GeneratedColumn<String>(
    'device_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nextSequenceMeta = const VerificationMeta(
    'nextSequence',
  );
  @override
  late final GeneratedColumn<int> nextSequence = GeneratedColumn<int>(
    'next_sequence',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _vectorJsonMeta = const VerificationMeta(
    'vectorJson',
  );
  @override
  late final GeneratedColumn<String> vectorJson = GeneratedColumn<String>(
    'vector_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _hlcMillisMeta = const VerificationMeta(
    'hlcMillis',
  );
  @override
  late final GeneratedColumn<int> hlcMillis = GeneratedColumn<int>(
    'hlc_millis',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _hlcCounterMeta = const VerificationMeta(
    'hlcCounter',
  );
  @override
  late final GeneratedColumn<int> hlcCounter = GeneratedColumn<int>(
    'hlc_counter',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    spaceId,
    deviceId,
    deviceName,
    nextSequence,
    vectorJson,
    hlcMillis,
    hlcCounter,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_sync_states';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalSyncState> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('space_id')) {
      context.handle(
        _spaceIdMeta,
        spaceId.isAcceptableOrUnknown(data['space_id']!, _spaceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_spaceIdMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('device_name')) {
      context.handle(
        _deviceNameMeta,
        deviceName.isAcceptableOrUnknown(data['device_name']!, _deviceNameMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceNameMeta);
    }
    if (data.containsKey('next_sequence')) {
      context.handle(
        _nextSequenceMeta,
        nextSequence.isAcceptableOrUnknown(
          data['next_sequence']!,
          _nextSequenceMeta,
        ),
      );
    }
    if (data.containsKey('vector_json')) {
      context.handle(
        _vectorJsonMeta,
        vectorJson.isAcceptableOrUnknown(data['vector_json']!, _vectorJsonMeta),
      );
    }
    if (data.containsKey('hlc_millis')) {
      context.handle(
        _hlcMillisMeta,
        hlcMillis.isAcceptableOrUnknown(data['hlc_millis']!, _hlcMillisMeta),
      );
    }
    if (data.containsKey('hlc_counter')) {
      context.handle(
        _hlcCounterMeta,
        hlcCounter.isAcceptableOrUnknown(data['hlc_counter']!, _hlcCounterMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalSyncState map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalSyncState(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      spaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}space_id'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      deviceName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_name'],
      )!,
      nextSequence: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}next_sequence'],
      )!,
      vectorJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vector_json'],
      )!,
      hlcMillis: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hlc_millis'],
      )!,
      hlcCounter: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hlc_counter'],
      )!,
    );
  }

  @override
  $LocalSyncStatesTable createAlias(String alias) {
    return $LocalSyncStatesTable(attachedDatabase, alias);
  }
}

class LocalSyncState extends DataClass implements Insertable<LocalSyncState> {
  final int id;
  final String spaceId;
  final String deviceId;
  final String deviceName;
  final int nextSequence;
  final String vectorJson;
  final int hlcMillis;
  final int hlcCounter;
  const LocalSyncState({
    required this.id,
    required this.spaceId,
    required this.deviceId,
    required this.deviceName,
    required this.nextSequence,
    required this.vectorJson,
    required this.hlcMillis,
    required this.hlcCounter,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['space_id'] = Variable<String>(spaceId);
    map['device_id'] = Variable<String>(deviceId);
    map['device_name'] = Variable<String>(deviceName);
    map['next_sequence'] = Variable<int>(nextSequence);
    map['vector_json'] = Variable<String>(vectorJson);
    map['hlc_millis'] = Variable<int>(hlcMillis);
    map['hlc_counter'] = Variable<int>(hlcCounter);
    return map;
  }

  LocalSyncStatesCompanion toCompanion(bool nullToAbsent) {
    return LocalSyncStatesCompanion(
      id: Value(id),
      spaceId: Value(spaceId),
      deviceId: Value(deviceId),
      deviceName: Value(deviceName),
      nextSequence: Value(nextSequence),
      vectorJson: Value(vectorJson),
      hlcMillis: Value(hlcMillis),
      hlcCounter: Value(hlcCounter),
    );
  }

  factory LocalSyncState.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalSyncState(
      id: serializer.fromJson<int>(json['id']),
      spaceId: serializer.fromJson<String>(json['spaceId']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      deviceName: serializer.fromJson<String>(json['deviceName']),
      nextSequence: serializer.fromJson<int>(json['nextSequence']),
      vectorJson: serializer.fromJson<String>(json['vectorJson']),
      hlcMillis: serializer.fromJson<int>(json['hlcMillis']),
      hlcCounter: serializer.fromJson<int>(json['hlcCounter']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'spaceId': serializer.toJson<String>(spaceId),
      'deviceId': serializer.toJson<String>(deviceId),
      'deviceName': serializer.toJson<String>(deviceName),
      'nextSequence': serializer.toJson<int>(nextSequence),
      'vectorJson': serializer.toJson<String>(vectorJson),
      'hlcMillis': serializer.toJson<int>(hlcMillis),
      'hlcCounter': serializer.toJson<int>(hlcCounter),
    };
  }

  LocalSyncState copyWith({
    int? id,
    String? spaceId,
    String? deviceId,
    String? deviceName,
    int? nextSequence,
    String? vectorJson,
    int? hlcMillis,
    int? hlcCounter,
  }) => LocalSyncState(
    id: id ?? this.id,
    spaceId: spaceId ?? this.spaceId,
    deviceId: deviceId ?? this.deviceId,
    deviceName: deviceName ?? this.deviceName,
    nextSequence: nextSequence ?? this.nextSequence,
    vectorJson: vectorJson ?? this.vectorJson,
    hlcMillis: hlcMillis ?? this.hlcMillis,
    hlcCounter: hlcCounter ?? this.hlcCounter,
  );
  LocalSyncState copyWithCompanion(LocalSyncStatesCompanion data) {
    return LocalSyncState(
      id: data.id.present ? data.id.value : this.id,
      spaceId: data.spaceId.present ? data.spaceId.value : this.spaceId,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      deviceName: data.deviceName.present
          ? data.deviceName.value
          : this.deviceName,
      nextSequence: data.nextSequence.present
          ? data.nextSequence.value
          : this.nextSequence,
      vectorJson: data.vectorJson.present
          ? data.vectorJson.value
          : this.vectorJson,
      hlcMillis: data.hlcMillis.present ? data.hlcMillis.value : this.hlcMillis,
      hlcCounter: data.hlcCounter.present
          ? data.hlcCounter.value
          : this.hlcCounter,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalSyncState(')
          ..write('id: $id, ')
          ..write('spaceId: $spaceId, ')
          ..write('deviceId: $deviceId, ')
          ..write('deviceName: $deviceName, ')
          ..write('nextSequence: $nextSequence, ')
          ..write('vectorJson: $vectorJson, ')
          ..write('hlcMillis: $hlcMillis, ')
          ..write('hlcCounter: $hlcCounter')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    spaceId,
    deviceId,
    deviceName,
    nextSequence,
    vectorJson,
    hlcMillis,
    hlcCounter,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalSyncState &&
          other.id == this.id &&
          other.spaceId == this.spaceId &&
          other.deviceId == this.deviceId &&
          other.deviceName == this.deviceName &&
          other.nextSequence == this.nextSequence &&
          other.vectorJson == this.vectorJson &&
          other.hlcMillis == this.hlcMillis &&
          other.hlcCounter == this.hlcCounter);
}

class LocalSyncStatesCompanion extends UpdateCompanion<LocalSyncState> {
  final Value<int> id;
  final Value<String> spaceId;
  final Value<String> deviceId;
  final Value<String> deviceName;
  final Value<int> nextSequence;
  final Value<String> vectorJson;
  final Value<int> hlcMillis;
  final Value<int> hlcCounter;
  const LocalSyncStatesCompanion({
    this.id = const Value.absent(),
    this.spaceId = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.deviceName = const Value.absent(),
    this.nextSequence = const Value.absent(),
    this.vectorJson = const Value.absent(),
    this.hlcMillis = const Value.absent(),
    this.hlcCounter = const Value.absent(),
  });
  LocalSyncStatesCompanion.insert({
    this.id = const Value.absent(),
    required String spaceId,
    required String deviceId,
    required String deviceName,
    this.nextSequence = const Value.absent(),
    this.vectorJson = const Value.absent(),
    this.hlcMillis = const Value.absent(),
    this.hlcCounter = const Value.absent(),
  }) : spaceId = Value(spaceId),
       deviceId = Value(deviceId),
       deviceName = Value(deviceName);
  static Insertable<LocalSyncState> custom({
    Expression<int>? id,
    Expression<String>? spaceId,
    Expression<String>? deviceId,
    Expression<String>? deviceName,
    Expression<int>? nextSequence,
    Expression<String>? vectorJson,
    Expression<int>? hlcMillis,
    Expression<int>? hlcCounter,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (spaceId != null) 'space_id': spaceId,
      if (deviceId != null) 'device_id': deviceId,
      if (deviceName != null) 'device_name': deviceName,
      if (nextSequence != null) 'next_sequence': nextSequence,
      if (vectorJson != null) 'vector_json': vectorJson,
      if (hlcMillis != null) 'hlc_millis': hlcMillis,
      if (hlcCounter != null) 'hlc_counter': hlcCounter,
    });
  }

  LocalSyncStatesCompanion copyWith({
    Value<int>? id,
    Value<String>? spaceId,
    Value<String>? deviceId,
    Value<String>? deviceName,
    Value<int>? nextSequence,
    Value<String>? vectorJson,
    Value<int>? hlcMillis,
    Value<int>? hlcCounter,
  }) {
    return LocalSyncStatesCompanion(
      id: id ?? this.id,
      spaceId: spaceId ?? this.spaceId,
      deviceId: deviceId ?? this.deviceId,
      deviceName: deviceName ?? this.deviceName,
      nextSequence: nextSequence ?? this.nextSequence,
      vectorJson: vectorJson ?? this.vectorJson,
      hlcMillis: hlcMillis ?? this.hlcMillis,
      hlcCounter: hlcCounter ?? this.hlcCounter,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (spaceId.present) {
      map['space_id'] = Variable<String>(spaceId.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (deviceName.present) {
      map['device_name'] = Variable<String>(deviceName.value);
    }
    if (nextSequence.present) {
      map['next_sequence'] = Variable<int>(nextSequence.value);
    }
    if (vectorJson.present) {
      map['vector_json'] = Variable<String>(vectorJson.value);
    }
    if (hlcMillis.present) {
      map['hlc_millis'] = Variable<int>(hlcMillis.value);
    }
    if (hlcCounter.present) {
      map['hlc_counter'] = Variable<int>(hlcCounter.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalSyncStatesCompanion(')
          ..write('id: $id, ')
          ..write('spaceId: $spaceId, ')
          ..write('deviceId: $deviceId, ')
          ..write('deviceName: $deviceName, ')
          ..write('nextSequence: $nextSequence, ')
          ..write('vectorJson: $vectorJson, ')
          ..write('hlcMillis: $hlcMillis, ')
          ..write('hlcCounter: $hlcCounter')
          ..write(')'))
        .toString();
  }
}

class $SyncDevicesTable extends SyncDevices
    with TableInfo<$SyncDevicesTable, SyncDevice> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncDevicesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pairedAtUtcMeta = const VerificationMeta(
    'pairedAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> pairedAtUtc = GeneratedColumn<DateTime>(
    'paired_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastSeenAtUtcMeta = const VerificationMeta(
    'lastSeenAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> lastSeenAtUtc =
      GeneratedColumn<DateTime>(
        'last_seen_at_utc',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _acknowledgedVectorJsonMeta =
      const VerificationMeta('acknowledgedVectorJson');
  @override
  late final GeneratedColumn<String> acknowledgedVectorJson =
      GeneratedColumn<String>(
        'acknowledged_vector_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('{}'),
      );
  static const VerificationMeta _isTrustedMeta = const VerificationMeta(
    'isTrusted',
  );
  @override
  late final GeneratedColumn<bool> isTrusted = GeneratedColumn<bool>(
    'is_trusted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_trusted" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    deviceId,
    displayName,
    pairedAtUtc,
    lastSeenAtUtc,
    acknowledgedVectorJson,
    isTrusted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_devices';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncDevice> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('paired_at_utc')) {
      context.handle(
        _pairedAtUtcMeta,
        pairedAtUtc.isAcceptableOrUnknown(
          data['paired_at_utc']!,
          _pairedAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_pairedAtUtcMeta);
    }
    if (data.containsKey('last_seen_at_utc')) {
      context.handle(
        _lastSeenAtUtcMeta,
        lastSeenAtUtc.isAcceptableOrUnknown(
          data['last_seen_at_utc']!,
          _lastSeenAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastSeenAtUtcMeta);
    }
    if (data.containsKey('acknowledged_vector_json')) {
      context.handle(
        _acknowledgedVectorJsonMeta,
        acknowledgedVectorJson.isAcceptableOrUnknown(
          data['acknowledged_vector_json']!,
          _acknowledgedVectorJsonMeta,
        ),
      );
    }
    if (data.containsKey('is_trusted')) {
      context.handle(
        _isTrustedMeta,
        isTrusted.isAcceptableOrUnknown(data['is_trusted']!, _isTrustedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {deviceId};
  @override
  SyncDevice map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncDevice(
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      pairedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}paired_at_utc'],
      )!,
      lastSeenAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_seen_at_utc'],
      )!,
      acknowledgedVectorJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}acknowledged_vector_json'],
      )!,
      isTrusted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_trusted'],
      )!,
    );
  }

  @override
  $SyncDevicesTable createAlias(String alias) {
    return $SyncDevicesTable(attachedDatabase, alias);
  }
}

class SyncDevice extends DataClass implements Insertable<SyncDevice> {
  final String deviceId;
  final String displayName;
  final DateTime pairedAtUtc;
  final DateTime lastSeenAtUtc;
  final String acknowledgedVectorJson;
  final bool isTrusted;
  const SyncDevice({
    required this.deviceId,
    required this.displayName,
    required this.pairedAtUtc,
    required this.lastSeenAtUtc,
    required this.acknowledgedVectorJson,
    required this.isTrusted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['device_id'] = Variable<String>(deviceId);
    map['display_name'] = Variable<String>(displayName);
    map['paired_at_utc'] = Variable<DateTime>(pairedAtUtc);
    map['last_seen_at_utc'] = Variable<DateTime>(lastSeenAtUtc);
    map['acknowledged_vector_json'] = Variable<String>(acknowledgedVectorJson);
    map['is_trusted'] = Variable<bool>(isTrusted);
    return map;
  }

  SyncDevicesCompanion toCompanion(bool nullToAbsent) {
    return SyncDevicesCompanion(
      deviceId: Value(deviceId),
      displayName: Value(displayName),
      pairedAtUtc: Value(pairedAtUtc),
      lastSeenAtUtc: Value(lastSeenAtUtc),
      acknowledgedVectorJson: Value(acknowledgedVectorJson),
      isTrusted: Value(isTrusted),
    );
  }

  factory SyncDevice.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncDevice(
      deviceId: serializer.fromJson<String>(json['deviceId']),
      displayName: serializer.fromJson<String>(json['displayName']),
      pairedAtUtc: serializer.fromJson<DateTime>(json['pairedAtUtc']),
      lastSeenAtUtc: serializer.fromJson<DateTime>(json['lastSeenAtUtc']),
      acknowledgedVectorJson: serializer.fromJson<String>(
        json['acknowledgedVectorJson'],
      ),
      isTrusted: serializer.fromJson<bool>(json['isTrusted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'deviceId': serializer.toJson<String>(deviceId),
      'displayName': serializer.toJson<String>(displayName),
      'pairedAtUtc': serializer.toJson<DateTime>(pairedAtUtc),
      'lastSeenAtUtc': serializer.toJson<DateTime>(lastSeenAtUtc),
      'acknowledgedVectorJson': serializer.toJson<String>(
        acknowledgedVectorJson,
      ),
      'isTrusted': serializer.toJson<bool>(isTrusted),
    };
  }

  SyncDevice copyWith({
    String? deviceId,
    String? displayName,
    DateTime? pairedAtUtc,
    DateTime? lastSeenAtUtc,
    String? acknowledgedVectorJson,
    bool? isTrusted,
  }) => SyncDevice(
    deviceId: deviceId ?? this.deviceId,
    displayName: displayName ?? this.displayName,
    pairedAtUtc: pairedAtUtc ?? this.pairedAtUtc,
    lastSeenAtUtc: lastSeenAtUtc ?? this.lastSeenAtUtc,
    acknowledgedVectorJson:
        acknowledgedVectorJson ?? this.acknowledgedVectorJson,
    isTrusted: isTrusted ?? this.isTrusted,
  );
  SyncDevice copyWithCompanion(SyncDevicesCompanion data) {
    return SyncDevice(
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      pairedAtUtc: data.pairedAtUtc.present
          ? data.pairedAtUtc.value
          : this.pairedAtUtc,
      lastSeenAtUtc: data.lastSeenAtUtc.present
          ? data.lastSeenAtUtc.value
          : this.lastSeenAtUtc,
      acknowledgedVectorJson: data.acknowledgedVectorJson.present
          ? data.acknowledgedVectorJson.value
          : this.acknowledgedVectorJson,
      isTrusted: data.isTrusted.present ? data.isTrusted.value : this.isTrusted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncDevice(')
          ..write('deviceId: $deviceId, ')
          ..write('displayName: $displayName, ')
          ..write('pairedAtUtc: $pairedAtUtc, ')
          ..write('lastSeenAtUtc: $lastSeenAtUtc, ')
          ..write('acknowledgedVectorJson: $acknowledgedVectorJson, ')
          ..write('isTrusted: $isTrusted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    deviceId,
    displayName,
    pairedAtUtc,
    lastSeenAtUtc,
    acknowledgedVectorJson,
    isTrusted,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncDevice &&
          other.deviceId == this.deviceId &&
          other.displayName == this.displayName &&
          other.pairedAtUtc == this.pairedAtUtc &&
          other.lastSeenAtUtc == this.lastSeenAtUtc &&
          other.acknowledgedVectorJson == this.acknowledgedVectorJson &&
          other.isTrusted == this.isTrusted);
}

class SyncDevicesCompanion extends UpdateCompanion<SyncDevice> {
  final Value<String> deviceId;
  final Value<String> displayName;
  final Value<DateTime> pairedAtUtc;
  final Value<DateTime> lastSeenAtUtc;
  final Value<String> acknowledgedVectorJson;
  final Value<bool> isTrusted;
  final Value<int> rowid;
  const SyncDevicesCompanion({
    this.deviceId = const Value.absent(),
    this.displayName = const Value.absent(),
    this.pairedAtUtc = const Value.absent(),
    this.lastSeenAtUtc = const Value.absent(),
    this.acknowledgedVectorJson = const Value.absent(),
    this.isTrusted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncDevicesCompanion.insert({
    required String deviceId,
    required String displayName,
    required DateTime pairedAtUtc,
    required DateTime lastSeenAtUtc,
    this.acknowledgedVectorJson = const Value.absent(),
    this.isTrusted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : deviceId = Value(deviceId),
       displayName = Value(displayName),
       pairedAtUtc = Value(pairedAtUtc),
       lastSeenAtUtc = Value(lastSeenAtUtc);
  static Insertable<SyncDevice> custom({
    Expression<String>? deviceId,
    Expression<String>? displayName,
    Expression<DateTime>? pairedAtUtc,
    Expression<DateTime>? lastSeenAtUtc,
    Expression<String>? acknowledgedVectorJson,
    Expression<bool>? isTrusted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (deviceId != null) 'device_id': deviceId,
      if (displayName != null) 'display_name': displayName,
      if (pairedAtUtc != null) 'paired_at_utc': pairedAtUtc,
      if (lastSeenAtUtc != null) 'last_seen_at_utc': lastSeenAtUtc,
      if (acknowledgedVectorJson != null)
        'acknowledged_vector_json': acknowledgedVectorJson,
      if (isTrusted != null) 'is_trusted': isTrusted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncDevicesCompanion copyWith({
    Value<String>? deviceId,
    Value<String>? displayName,
    Value<DateTime>? pairedAtUtc,
    Value<DateTime>? lastSeenAtUtc,
    Value<String>? acknowledgedVectorJson,
    Value<bool>? isTrusted,
    Value<int>? rowid,
  }) {
    return SyncDevicesCompanion(
      deviceId: deviceId ?? this.deviceId,
      displayName: displayName ?? this.displayName,
      pairedAtUtc: pairedAtUtc ?? this.pairedAtUtc,
      lastSeenAtUtc: lastSeenAtUtc ?? this.lastSeenAtUtc,
      acknowledgedVectorJson:
          acknowledgedVectorJson ?? this.acknowledgedVectorJson,
      isTrusted: isTrusted ?? this.isTrusted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (pairedAtUtc.present) {
      map['paired_at_utc'] = Variable<DateTime>(pairedAtUtc.value);
    }
    if (lastSeenAtUtc.present) {
      map['last_seen_at_utc'] = Variable<DateTime>(lastSeenAtUtc.value);
    }
    if (acknowledgedVectorJson.present) {
      map['acknowledged_vector_json'] = Variable<String>(
        acknowledgedVectorJson.value,
      );
    }
    if (isTrusted.present) {
      map['is_trusted'] = Variable<bool>(isTrusted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncDevicesCompanion(')
          ..write('deviceId: $deviceId, ')
          ..write('displayName: $displayName, ')
          ..write('pairedAtUtc: $pairedAtUtc, ')
          ..write('lastSeenAtUtc: $lastSeenAtUtc, ')
          ..write('acknowledgedVectorJson: $acknowledgedVectorJson, ')
          ..write('isTrusted: $isTrusted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncOperationsTable extends SyncOperations
    with TableInfo<$SyncOperationsTable, SyncOperation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncOperationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _operationIdMeta = const VerificationMeta(
    'operationId',
  );
  @override
  late final GeneratedColumn<String> operationId = GeneratedColumn<String>(
    'operation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _originDeviceIdMeta = const VerificationMeta(
    'originDeviceId',
  );
  @override
  late final GeneratedColumn<String> originDeviceId = GeneratedColumn<String>(
    'origin_device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _originSequenceMeta = const VerificationMeta(
    'originSequence',
  );
  @override
  late final GeneratedColumn<int> originSequence = GeneratedColumn<int>(
    'origin_sequence',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contextJsonMeta = const VerificationMeta(
    'contextJson',
  );
  @override
  late final GeneratedColumn<String> contextJson = GeneratedColumn<String>(
    'context_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hlcMillisMeta = const VerificationMeta(
    'hlcMillis',
  );
  @override
  late final GeneratedColumn<int> hlcMillis = GeneratedColumn<int>(
    'hlc_millis',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hlcCounterMeta = const VerificationMeta(
    'hlcCounter',
  );
  @override
  late final GeneratedColumn<int> hlcCounter = GeneratedColumn<int>(
    'hlc_counter',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _transactionIdMeta = const VerificationMeta(
    'transactionId',
  );
  @override
  late final GeneratedColumn<String> transactionId = GeneratedColumn<String>(
    'transaction_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _transactionIndexMeta = const VerificationMeta(
    'transactionIndex',
  );
  @override
  late final GeneratedColumn<int> transactionIndex = GeneratedColumn<int>(
    'transaction_index',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _transactionCountMeta = const VerificationMeta(
    'transactionCount',
  );
  @override
  late final GeneratedColumn<int> transactionCount = GeneratedColumn<int>(
    'transaction_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entitySyncIdMeta = const VerificationMeta(
    'entitySyncId',
  );
  @override
  late final GeneratedColumn<String> entitySyncId = GeneratedColumn<String>(
    'entity_sync_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _operationKindMeta = const VerificationMeta(
    'operationKind',
  );
  @override
  late final GeneratedColumn<String> operationKind = GeneratedColumn<String>(
    'operation_kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _changesJsonMeta = const VerificationMeta(
    'changesJson',
  );
  @override
  late final GeneratedColumn<String> changesJson = GeneratedColumn<String>(
    'changes_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _resolvesJsonMeta = const VerificationMeta(
    'resolvesJson',
  );
  @override
  late final GeneratedColumn<String> resolvesJson = GeneratedColumn<String>(
    'resolves_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _occurredAtUtcMeta = const VerificationMeta(
    'occurredAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> occurredAtUtc =
      GeneratedColumn<DateTime>(
        'occurred_at_utc',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [
    operationId,
    originDeviceId,
    originSequence,
    contextJson,
    hlcMillis,
    hlcCounter,
    transactionId,
    transactionIndex,
    transactionCount,
    entityType,
    entitySyncId,
    operationKind,
    changesJson,
    resolvesJson,
    occurredAtUtc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_operations';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncOperation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('operation_id')) {
      context.handle(
        _operationIdMeta,
        operationId.isAcceptableOrUnknown(
          data['operation_id']!,
          _operationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_operationIdMeta);
    }
    if (data.containsKey('origin_device_id')) {
      context.handle(
        _originDeviceIdMeta,
        originDeviceId.isAcceptableOrUnknown(
          data['origin_device_id']!,
          _originDeviceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_originDeviceIdMeta);
    }
    if (data.containsKey('origin_sequence')) {
      context.handle(
        _originSequenceMeta,
        originSequence.isAcceptableOrUnknown(
          data['origin_sequence']!,
          _originSequenceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_originSequenceMeta);
    }
    if (data.containsKey('context_json')) {
      context.handle(
        _contextJsonMeta,
        contextJson.isAcceptableOrUnknown(
          data['context_json']!,
          _contextJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contextJsonMeta);
    }
    if (data.containsKey('hlc_millis')) {
      context.handle(
        _hlcMillisMeta,
        hlcMillis.isAcceptableOrUnknown(data['hlc_millis']!, _hlcMillisMeta),
      );
    } else if (isInserting) {
      context.missing(_hlcMillisMeta);
    }
    if (data.containsKey('hlc_counter')) {
      context.handle(
        _hlcCounterMeta,
        hlcCounter.isAcceptableOrUnknown(data['hlc_counter']!, _hlcCounterMeta),
      );
    } else if (isInserting) {
      context.missing(_hlcCounterMeta);
    }
    if (data.containsKey('transaction_id')) {
      context.handle(
        _transactionIdMeta,
        transactionId.isAcceptableOrUnknown(
          data['transaction_id']!,
          _transactionIdMeta,
        ),
      );
    }
    if (data.containsKey('transaction_index')) {
      context.handle(
        _transactionIndexMeta,
        transactionIndex.isAcceptableOrUnknown(
          data['transaction_index']!,
          _transactionIndexMeta,
        ),
      );
    }
    if (data.containsKey('transaction_count')) {
      context.handle(
        _transactionCountMeta,
        transactionCount.isAcceptableOrUnknown(
          data['transaction_count']!,
          _transactionCountMeta,
        ),
      );
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_sync_id')) {
      context.handle(
        _entitySyncIdMeta,
        entitySyncId.isAcceptableOrUnknown(
          data['entity_sync_id']!,
          _entitySyncIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_entitySyncIdMeta);
    }
    if (data.containsKey('operation_kind')) {
      context.handle(
        _operationKindMeta,
        operationKind.isAcceptableOrUnknown(
          data['operation_kind']!,
          _operationKindMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_operationKindMeta);
    }
    if (data.containsKey('changes_json')) {
      context.handle(
        _changesJsonMeta,
        changesJson.isAcceptableOrUnknown(
          data['changes_json']!,
          _changesJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_changesJsonMeta);
    }
    if (data.containsKey('resolves_json')) {
      context.handle(
        _resolvesJsonMeta,
        resolvesJson.isAcceptableOrUnknown(
          data['resolves_json']!,
          _resolvesJsonMeta,
        ),
      );
    }
    if (data.containsKey('occurred_at_utc')) {
      context.handle(
        _occurredAtUtcMeta,
        occurredAtUtc.isAcceptableOrUnknown(
          data['occurred_at_utc']!,
          _occurredAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_occurredAtUtcMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {operationId};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {originDeviceId, originSequence},
  ];
  @override
  SyncOperation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncOperation(
      operationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation_id'],
      )!,
      originDeviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin_device_id'],
      )!,
      originSequence: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}origin_sequence'],
      )!,
      contextJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}context_json'],
      )!,
      hlcMillis: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hlc_millis'],
      )!,
      hlcCounter: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hlc_counter'],
      )!,
      transactionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transaction_id'],
      ),
      transactionIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}transaction_index'],
      ),
      transactionCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}transaction_count'],
      ),
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entitySyncId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_sync_id'],
      )!,
      operationKind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation_kind'],
      )!,
      changesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}changes_json'],
      )!,
      resolvesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}resolves_json'],
      )!,
      occurredAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}occurred_at_utc'],
      )!,
    );
  }

  @override
  $SyncOperationsTable createAlias(String alias) {
    return $SyncOperationsTable(attachedDatabase, alias);
  }
}

class SyncOperation extends DataClass implements Insertable<SyncOperation> {
  final String operationId;
  final String originDeviceId;
  final int originSequence;
  final String contextJson;
  final int hlcMillis;
  final int hlcCounter;
  final String? transactionId;
  final int? transactionIndex;
  final int? transactionCount;
  final String entityType;
  final String entitySyncId;
  final String operationKind;
  final String changesJson;
  final String resolvesJson;
  final DateTime occurredAtUtc;
  const SyncOperation({
    required this.operationId,
    required this.originDeviceId,
    required this.originSequence,
    required this.contextJson,
    required this.hlcMillis,
    required this.hlcCounter,
    this.transactionId,
    this.transactionIndex,
    this.transactionCount,
    required this.entityType,
    required this.entitySyncId,
    required this.operationKind,
    required this.changesJson,
    required this.resolvesJson,
    required this.occurredAtUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['operation_id'] = Variable<String>(operationId);
    map['origin_device_id'] = Variable<String>(originDeviceId);
    map['origin_sequence'] = Variable<int>(originSequence);
    map['context_json'] = Variable<String>(contextJson);
    map['hlc_millis'] = Variable<int>(hlcMillis);
    map['hlc_counter'] = Variable<int>(hlcCounter);
    if (!nullToAbsent || transactionId != null) {
      map['transaction_id'] = Variable<String>(transactionId);
    }
    if (!nullToAbsent || transactionIndex != null) {
      map['transaction_index'] = Variable<int>(transactionIndex);
    }
    if (!nullToAbsent || transactionCount != null) {
      map['transaction_count'] = Variable<int>(transactionCount);
    }
    map['entity_type'] = Variable<String>(entityType);
    map['entity_sync_id'] = Variable<String>(entitySyncId);
    map['operation_kind'] = Variable<String>(operationKind);
    map['changes_json'] = Variable<String>(changesJson);
    map['resolves_json'] = Variable<String>(resolvesJson);
    map['occurred_at_utc'] = Variable<DateTime>(occurredAtUtc);
    return map;
  }

  SyncOperationsCompanion toCompanion(bool nullToAbsent) {
    return SyncOperationsCompanion(
      operationId: Value(operationId),
      originDeviceId: Value(originDeviceId),
      originSequence: Value(originSequence),
      contextJson: Value(contextJson),
      hlcMillis: Value(hlcMillis),
      hlcCounter: Value(hlcCounter),
      transactionId: transactionId == null && nullToAbsent
          ? const Value.absent()
          : Value(transactionId),
      transactionIndex: transactionIndex == null && nullToAbsent
          ? const Value.absent()
          : Value(transactionIndex),
      transactionCount: transactionCount == null && nullToAbsent
          ? const Value.absent()
          : Value(transactionCount),
      entityType: Value(entityType),
      entitySyncId: Value(entitySyncId),
      operationKind: Value(operationKind),
      changesJson: Value(changesJson),
      resolvesJson: Value(resolvesJson),
      occurredAtUtc: Value(occurredAtUtc),
    );
  }

  factory SyncOperation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncOperation(
      operationId: serializer.fromJson<String>(json['operationId']),
      originDeviceId: serializer.fromJson<String>(json['originDeviceId']),
      originSequence: serializer.fromJson<int>(json['originSequence']),
      contextJson: serializer.fromJson<String>(json['contextJson']),
      hlcMillis: serializer.fromJson<int>(json['hlcMillis']),
      hlcCounter: serializer.fromJson<int>(json['hlcCounter']),
      transactionId: serializer.fromJson<String?>(json['transactionId']),
      transactionIndex: serializer.fromJson<int?>(json['transactionIndex']),
      transactionCount: serializer.fromJson<int?>(json['transactionCount']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entitySyncId: serializer.fromJson<String>(json['entitySyncId']),
      operationKind: serializer.fromJson<String>(json['operationKind']),
      changesJson: serializer.fromJson<String>(json['changesJson']),
      resolvesJson: serializer.fromJson<String>(json['resolvesJson']),
      occurredAtUtc: serializer.fromJson<DateTime>(json['occurredAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'operationId': serializer.toJson<String>(operationId),
      'originDeviceId': serializer.toJson<String>(originDeviceId),
      'originSequence': serializer.toJson<int>(originSequence),
      'contextJson': serializer.toJson<String>(contextJson),
      'hlcMillis': serializer.toJson<int>(hlcMillis),
      'hlcCounter': serializer.toJson<int>(hlcCounter),
      'transactionId': serializer.toJson<String?>(transactionId),
      'transactionIndex': serializer.toJson<int?>(transactionIndex),
      'transactionCount': serializer.toJson<int?>(transactionCount),
      'entityType': serializer.toJson<String>(entityType),
      'entitySyncId': serializer.toJson<String>(entitySyncId),
      'operationKind': serializer.toJson<String>(operationKind),
      'changesJson': serializer.toJson<String>(changesJson),
      'resolvesJson': serializer.toJson<String>(resolvesJson),
      'occurredAtUtc': serializer.toJson<DateTime>(occurredAtUtc),
    };
  }

  SyncOperation copyWith({
    String? operationId,
    String? originDeviceId,
    int? originSequence,
    String? contextJson,
    int? hlcMillis,
    int? hlcCounter,
    Value<String?> transactionId = const Value.absent(),
    Value<int?> transactionIndex = const Value.absent(),
    Value<int?> transactionCount = const Value.absent(),
    String? entityType,
    String? entitySyncId,
    String? operationKind,
    String? changesJson,
    String? resolvesJson,
    DateTime? occurredAtUtc,
  }) => SyncOperation(
    operationId: operationId ?? this.operationId,
    originDeviceId: originDeviceId ?? this.originDeviceId,
    originSequence: originSequence ?? this.originSequence,
    contextJson: contextJson ?? this.contextJson,
    hlcMillis: hlcMillis ?? this.hlcMillis,
    hlcCounter: hlcCounter ?? this.hlcCounter,
    transactionId: transactionId.present
        ? transactionId.value
        : this.transactionId,
    transactionIndex: transactionIndex.present
        ? transactionIndex.value
        : this.transactionIndex,
    transactionCount: transactionCount.present
        ? transactionCount.value
        : this.transactionCount,
    entityType: entityType ?? this.entityType,
    entitySyncId: entitySyncId ?? this.entitySyncId,
    operationKind: operationKind ?? this.operationKind,
    changesJson: changesJson ?? this.changesJson,
    resolvesJson: resolvesJson ?? this.resolvesJson,
    occurredAtUtc: occurredAtUtc ?? this.occurredAtUtc,
  );
  SyncOperation copyWithCompanion(SyncOperationsCompanion data) {
    return SyncOperation(
      operationId: data.operationId.present
          ? data.operationId.value
          : this.operationId,
      originDeviceId: data.originDeviceId.present
          ? data.originDeviceId.value
          : this.originDeviceId,
      originSequence: data.originSequence.present
          ? data.originSequence.value
          : this.originSequence,
      contextJson: data.contextJson.present
          ? data.contextJson.value
          : this.contextJson,
      hlcMillis: data.hlcMillis.present ? data.hlcMillis.value : this.hlcMillis,
      hlcCounter: data.hlcCounter.present
          ? data.hlcCounter.value
          : this.hlcCounter,
      transactionId: data.transactionId.present
          ? data.transactionId.value
          : this.transactionId,
      transactionIndex: data.transactionIndex.present
          ? data.transactionIndex.value
          : this.transactionIndex,
      transactionCount: data.transactionCount.present
          ? data.transactionCount.value
          : this.transactionCount,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entitySyncId: data.entitySyncId.present
          ? data.entitySyncId.value
          : this.entitySyncId,
      operationKind: data.operationKind.present
          ? data.operationKind.value
          : this.operationKind,
      changesJson: data.changesJson.present
          ? data.changesJson.value
          : this.changesJson,
      resolvesJson: data.resolvesJson.present
          ? data.resolvesJson.value
          : this.resolvesJson,
      occurredAtUtc: data.occurredAtUtc.present
          ? data.occurredAtUtc.value
          : this.occurredAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncOperation(')
          ..write('operationId: $operationId, ')
          ..write('originDeviceId: $originDeviceId, ')
          ..write('originSequence: $originSequence, ')
          ..write('contextJson: $contextJson, ')
          ..write('hlcMillis: $hlcMillis, ')
          ..write('hlcCounter: $hlcCounter, ')
          ..write('transactionId: $transactionId, ')
          ..write('transactionIndex: $transactionIndex, ')
          ..write('transactionCount: $transactionCount, ')
          ..write('entityType: $entityType, ')
          ..write('entitySyncId: $entitySyncId, ')
          ..write('operationKind: $operationKind, ')
          ..write('changesJson: $changesJson, ')
          ..write('resolvesJson: $resolvesJson, ')
          ..write('occurredAtUtc: $occurredAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    operationId,
    originDeviceId,
    originSequence,
    contextJson,
    hlcMillis,
    hlcCounter,
    transactionId,
    transactionIndex,
    transactionCount,
    entityType,
    entitySyncId,
    operationKind,
    changesJson,
    resolvesJson,
    occurredAtUtc,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncOperation &&
          other.operationId == this.operationId &&
          other.originDeviceId == this.originDeviceId &&
          other.originSequence == this.originSequence &&
          other.contextJson == this.contextJson &&
          other.hlcMillis == this.hlcMillis &&
          other.hlcCounter == this.hlcCounter &&
          other.transactionId == this.transactionId &&
          other.transactionIndex == this.transactionIndex &&
          other.transactionCount == this.transactionCount &&
          other.entityType == this.entityType &&
          other.entitySyncId == this.entitySyncId &&
          other.operationKind == this.operationKind &&
          other.changesJson == this.changesJson &&
          other.resolvesJson == this.resolvesJson &&
          other.occurredAtUtc == this.occurredAtUtc);
}

class SyncOperationsCompanion extends UpdateCompanion<SyncOperation> {
  final Value<String> operationId;
  final Value<String> originDeviceId;
  final Value<int> originSequence;
  final Value<String> contextJson;
  final Value<int> hlcMillis;
  final Value<int> hlcCounter;
  final Value<String?> transactionId;
  final Value<int?> transactionIndex;
  final Value<int?> transactionCount;
  final Value<String> entityType;
  final Value<String> entitySyncId;
  final Value<String> operationKind;
  final Value<String> changesJson;
  final Value<String> resolvesJson;
  final Value<DateTime> occurredAtUtc;
  final Value<int> rowid;
  const SyncOperationsCompanion({
    this.operationId = const Value.absent(),
    this.originDeviceId = const Value.absent(),
    this.originSequence = const Value.absent(),
    this.contextJson = const Value.absent(),
    this.hlcMillis = const Value.absent(),
    this.hlcCounter = const Value.absent(),
    this.transactionId = const Value.absent(),
    this.transactionIndex = const Value.absent(),
    this.transactionCount = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entitySyncId = const Value.absent(),
    this.operationKind = const Value.absent(),
    this.changesJson = const Value.absent(),
    this.resolvesJson = const Value.absent(),
    this.occurredAtUtc = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncOperationsCompanion.insert({
    required String operationId,
    required String originDeviceId,
    required int originSequence,
    required String contextJson,
    required int hlcMillis,
    required int hlcCounter,
    this.transactionId = const Value.absent(),
    this.transactionIndex = const Value.absent(),
    this.transactionCount = const Value.absent(),
    required String entityType,
    required String entitySyncId,
    required String operationKind,
    required String changesJson,
    this.resolvesJson = const Value.absent(),
    required DateTime occurredAtUtc,
    this.rowid = const Value.absent(),
  }) : operationId = Value(operationId),
       originDeviceId = Value(originDeviceId),
       originSequence = Value(originSequence),
       contextJson = Value(contextJson),
       hlcMillis = Value(hlcMillis),
       hlcCounter = Value(hlcCounter),
       entityType = Value(entityType),
       entitySyncId = Value(entitySyncId),
       operationKind = Value(operationKind),
       changesJson = Value(changesJson),
       occurredAtUtc = Value(occurredAtUtc);
  static Insertable<SyncOperation> custom({
    Expression<String>? operationId,
    Expression<String>? originDeviceId,
    Expression<int>? originSequence,
    Expression<String>? contextJson,
    Expression<int>? hlcMillis,
    Expression<int>? hlcCounter,
    Expression<String>? transactionId,
    Expression<int>? transactionIndex,
    Expression<int>? transactionCount,
    Expression<String>? entityType,
    Expression<String>? entitySyncId,
    Expression<String>? operationKind,
    Expression<String>? changesJson,
    Expression<String>? resolvesJson,
    Expression<DateTime>? occurredAtUtc,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (operationId != null) 'operation_id': operationId,
      if (originDeviceId != null) 'origin_device_id': originDeviceId,
      if (originSequence != null) 'origin_sequence': originSequence,
      if (contextJson != null) 'context_json': contextJson,
      if (hlcMillis != null) 'hlc_millis': hlcMillis,
      if (hlcCounter != null) 'hlc_counter': hlcCounter,
      if (transactionId != null) 'transaction_id': transactionId,
      if (transactionIndex != null) 'transaction_index': transactionIndex,
      if (transactionCount != null) 'transaction_count': transactionCount,
      if (entityType != null) 'entity_type': entityType,
      if (entitySyncId != null) 'entity_sync_id': entitySyncId,
      if (operationKind != null) 'operation_kind': operationKind,
      if (changesJson != null) 'changes_json': changesJson,
      if (resolvesJson != null) 'resolves_json': resolvesJson,
      if (occurredAtUtc != null) 'occurred_at_utc': occurredAtUtc,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncOperationsCompanion copyWith({
    Value<String>? operationId,
    Value<String>? originDeviceId,
    Value<int>? originSequence,
    Value<String>? contextJson,
    Value<int>? hlcMillis,
    Value<int>? hlcCounter,
    Value<String?>? transactionId,
    Value<int?>? transactionIndex,
    Value<int?>? transactionCount,
    Value<String>? entityType,
    Value<String>? entitySyncId,
    Value<String>? operationKind,
    Value<String>? changesJson,
    Value<String>? resolvesJson,
    Value<DateTime>? occurredAtUtc,
    Value<int>? rowid,
  }) {
    return SyncOperationsCompanion(
      operationId: operationId ?? this.operationId,
      originDeviceId: originDeviceId ?? this.originDeviceId,
      originSequence: originSequence ?? this.originSequence,
      contextJson: contextJson ?? this.contextJson,
      hlcMillis: hlcMillis ?? this.hlcMillis,
      hlcCounter: hlcCounter ?? this.hlcCounter,
      transactionId: transactionId ?? this.transactionId,
      transactionIndex: transactionIndex ?? this.transactionIndex,
      transactionCount: transactionCount ?? this.transactionCount,
      entityType: entityType ?? this.entityType,
      entitySyncId: entitySyncId ?? this.entitySyncId,
      operationKind: operationKind ?? this.operationKind,
      changesJson: changesJson ?? this.changesJson,
      resolvesJson: resolvesJson ?? this.resolvesJson,
      occurredAtUtc: occurredAtUtc ?? this.occurredAtUtc,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (operationId.present) {
      map['operation_id'] = Variable<String>(operationId.value);
    }
    if (originDeviceId.present) {
      map['origin_device_id'] = Variable<String>(originDeviceId.value);
    }
    if (originSequence.present) {
      map['origin_sequence'] = Variable<int>(originSequence.value);
    }
    if (contextJson.present) {
      map['context_json'] = Variable<String>(contextJson.value);
    }
    if (hlcMillis.present) {
      map['hlc_millis'] = Variable<int>(hlcMillis.value);
    }
    if (hlcCounter.present) {
      map['hlc_counter'] = Variable<int>(hlcCounter.value);
    }
    if (transactionId.present) {
      map['transaction_id'] = Variable<String>(transactionId.value);
    }
    if (transactionIndex.present) {
      map['transaction_index'] = Variable<int>(transactionIndex.value);
    }
    if (transactionCount.present) {
      map['transaction_count'] = Variable<int>(transactionCount.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entitySyncId.present) {
      map['entity_sync_id'] = Variable<String>(entitySyncId.value);
    }
    if (operationKind.present) {
      map['operation_kind'] = Variable<String>(operationKind.value);
    }
    if (changesJson.present) {
      map['changes_json'] = Variable<String>(changesJson.value);
    }
    if (resolvesJson.present) {
      map['resolves_json'] = Variable<String>(resolvesJson.value);
    }
    if (occurredAtUtc.present) {
      map['occurred_at_utc'] = Variable<DateTime>(occurredAtUtc.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncOperationsCompanion(')
          ..write('operationId: $operationId, ')
          ..write('originDeviceId: $originDeviceId, ')
          ..write('originSequence: $originSequence, ')
          ..write('contextJson: $contextJson, ')
          ..write('hlcMillis: $hlcMillis, ')
          ..write('hlcCounter: $hlcCounter, ')
          ..write('transactionId: $transactionId, ')
          ..write('transactionIndex: $transactionIndex, ')
          ..write('transactionCount: $transactionCount, ')
          ..write('entityType: $entityType, ')
          ..write('entitySyncId: $entitySyncId, ')
          ..write('operationKind: $operationKind, ')
          ..write('changesJson: $changesJson, ')
          ..write('resolvesJson: $resolvesJson, ')
          ..write('occurredAtUtc: $occurredAtUtc, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncFieldHeadsTable extends SyncFieldHeads
    with TableInfo<$SyncFieldHeadsTable, SyncFieldHead> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncFieldHeadsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entitySyncIdMeta = const VerificationMeta(
    'entitySyncId',
  );
  @override
  late final GeneratedColumn<String> entitySyncId = GeneratedColumn<String>(
    'entity_sync_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fieldNameMeta = const VerificationMeta(
    'fieldName',
  );
  @override
  late final GeneratedColumn<String> fieldName = GeneratedColumn<String>(
    'field_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _candidateOperationIdsJsonMeta =
      const VerificationMeta('candidateOperationIdsJson');
  @override
  late final GeneratedColumn<String> candidateOperationIdsJson =
      GeneratedColumn<String>(
        'candidate_operation_ids_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [
    entityType,
    entitySyncId,
    fieldName,
    candidateOperationIdsJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_field_heads';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncFieldHead> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_sync_id')) {
      context.handle(
        _entitySyncIdMeta,
        entitySyncId.isAcceptableOrUnknown(
          data['entity_sync_id']!,
          _entitySyncIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_entitySyncIdMeta);
    }
    if (data.containsKey('field_name')) {
      context.handle(
        _fieldNameMeta,
        fieldName.isAcceptableOrUnknown(data['field_name']!, _fieldNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fieldNameMeta);
    }
    if (data.containsKey('candidate_operation_ids_json')) {
      context.handle(
        _candidateOperationIdsJsonMeta,
        candidateOperationIdsJson.isAcceptableOrUnknown(
          data['candidate_operation_ids_json']!,
          _candidateOperationIdsJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_candidateOperationIdsJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {entityType, entitySyncId, fieldName};
  @override
  SyncFieldHead map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncFieldHead(
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entitySyncId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_sync_id'],
      )!,
      fieldName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}field_name'],
      )!,
      candidateOperationIdsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}candidate_operation_ids_json'],
      )!,
    );
  }

  @override
  $SyncFieldHeadsTable createAlias(String alias) {
    return $SyncFieldHeadsTable(attachedDatabase, alias);
  }
}

class SyncFieldHead extends DataClass implements Insertable<SyncFieldHead> {
  final String entityType;
  final String entitySyncId;
  final String fieldName;
  final String candidateOperationIdsJson;
  const SyncFieldHead({
    required this.entityType,
    required this.entitySyncId,
    required this.fieldName,
    required this.candidateOperationIdsJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['entity_type'] = Variable<String>(entityType);
    map['entity_sync_id'] = Variable<String>(entitySyncId);
    map['field_name'] = Variable<String>(fieldName);
    map['candidate_operation_ids_json'] = Variable<String>(
      candidateOperationIdsJson,
    );
    return map;
  }

  SyncFieldHeadsCompanion toCompanion(bool nullToAbsent) {
    return SyncFieldHeadsCompanion(
      entityType: Value(entityType),
      entitySyncId: Value(entitySyncId),
      fieldName: Value(fieldName),
      candidateOperationIdsJson: Value(candidateOperationIdsJson),
    );
  }

  factory SyncFieldHead.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncFieldHead(
      entityType: serializer.fromJson<String>(json['entityType']),
      entitySyncId: serializer.fromJson<String>(json['entitySyncId']),
      fieldName: serializer.fromJson<String>(json['fieldName']),
      candidateOperationIdsJson: serializer.fromJson<String>(
        json['candidateOperationIdsJson'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'entityType': serializer.toJson<String>(entityType),
      'entitySyncId': serializer.toJson<String>(entitySyncId),
      'fieldName': serializer.toJson<String>(fieldName),
      'candidateOperationIdsJson': serializer.toJson<String>(
        candidateOperationIdsJson,
      ),
    };
  }

  SyncFieldHead copyWith({
    String? entityType,
    String? entitySyncId,
    String? fieldName,
    String? candidateOperationIdsJson,
  }) => SyncFieldHead(
    entityType: entityType ?? this.entityType,
    entitySyncId: entitySyncId ?? this.entitySyncId,
    fieldName: fieldName ?? this.fieldName,
    candidateOperationIdsJson:
        candidateOperationIdsJson ?? this.candidateOperationIdsJson,
  );
  SyncFieldHead copyWithCompanion(SyncFieldHeadsCompanion data) {
    return SyncFieldHead(
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entitySyncId: data.entitySyncId.present
          ? data.entitySyncId.value
          : this.entitySyncId,
      fieldName: data.fieldName.present ? data.fieldName.value : this.fieldName,
      candidateOperationIdsJson: data.candidateOperationIdsJson.present
          ? data.candidateOperationIdsJson.value
          : this.candidateOperationIdsJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncFieldHead(')
          ..write('entityType: $entityType, ')
          ..write('entitySyncId: $entitySyncId, ')
          ..write('fieldName: $fieldName, ')
          ..write('candidateOperationIdsJson: $candidateOperationIdsJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    entityType,
    entitySyncId,
    fieldName,
    candidateOperationIdsJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncFieldHead &&
          other.entityType == this.entityType &&
          other.entitySyncId == this.entitySyncId &&
          other.fieldName == this.fieldName &&
          other.candidateOperationIdsJson == this.candidateOperationIdsJson);
}

class SyncFieldHeadsCompanion extends UpdateCompanion<SyncFieldHead> {
  final Value<String> entityType;
  final Value<String> entitySyncId;
  final Value<String> fieldName;
  final Value<String> candidateOperationIdsJson;
  final Value<int> rowid;
  const SyncFieldHeadsCompanion({
    this.entityType = const Value.absent(),
    this.entitySyncId = const Value.absent(),
    this.fieldName = const Value.absent(),
    this.candidateOperationIdsJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncFieldHeadsCompanion.insert({
    required String entityType,
    required String entitySyncId,
    required String fieldName,
    required String candidateOperationIdsJson,
    this.rowid = const Value.absent(),
  }) : entityType = Value(entityType),
       entitySyncId = Value(entitySyncId),
       fieldName = Value(fieldName),
       candidateOperationIdsJson = Value(candidateOperationIdsJson);
  static Insertable<SyncFieldHead> custom({
    Expression<String>? entityType,
    Expression<String>? entitySyncId,
    Expression<String>? fieldName,
    Expression<String>? candidateOperationIdsJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (entityType != null) 'entity_type': entityType,
      if (entitySyncId != null) 'entity_sync_id': entitySyncId,
      if (fieldName != null) 'field_name': fieldName,
      if (candidateOperationIdsJson != null)
        'candidate_operation_ids_json': candidateOperationIdsJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncFieldHeadsCompanion copyWith({
    Value<String>? entityType,
    Value<String>? entitySyncId,
    Value<String>? fieldName,
    Value<String>? candidateOperationIdsJson,
    Value<int>? rowid,
  }) {
    return SyncFieldHeadsCompanion(
      entityType: entityType ?? this.entityType,
      entitySyncId: entitySyncId ?? this.entitySyncId,
      fieldName: fieldName ?? this.fieldName,
      candidateOperationIdsJson:
          candidateOperationIdsJson ?? this.candidateOperationIdsJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entitySyncId.present) {
      map['entity_sync_id'] = Variable<String>(entitySyncId.value);
    }
    if (fieldName.present) {
      map['field_name'] = Variable<String>(fieldName.value);
    }
    if (candidateOperationIdsJson.present) {
      map['candidate_operation_ids_json'] = Variable<String>(
        candidateOperationIdsJson.value,
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncFieldHeadsCompanion(')
          ..write('entityType: $entityType, ')
          ..write('entitySyncId: $entitySyncId, ')
          ..write('fieldName: $fieldName, ')
          ..write('candidateOperationIdsJson: $candidateOperationIdsJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncConflictsTable extends SyncConflicts
    with TableInfo<$SyncConflictsTable, SyncConflict> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncConflictsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _conflictIdMeta = const VerificationMeta(
    'conflictId',
  );
  @override
  late final GeneratedColumn<String> conflictId = GeneratedColumn<String>(
    'conflict_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entitySyncIdMeta = const VerificationMeta(
    'entitySyncId',
  );
  @override
  late final GeneratedColumn<String> entitySyncId = GeneratedColumn<String>(
    'entity_sync_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fieldNameMeta = const VerificationMeta(
    'fieldName',
  );
  @override
  late final GeneratedColumn<String> fieldName = GeneratedColumn<String>(
    'field_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _candidateOperationIdsJsonMeta =
      const VerificationMeta('candidateOperationIdsJson');
  @override
  late final GeneratedColumn<String> candidateOperationIdsJson =
      GeneratedColumn<String>(
        'candidate_operation_ids_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _resolvedByOperationIdMeta =
      const VerificationMeta('resolvedByOperationId');
  @override
  late final GeneratedColumn<String> resolvedByOperationId =
      GeneratedColumn<String>(
        'resolved_by_operation_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _detectedAtUtcMeta = const VerificationMeta(
    'detectedAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> detectedAtUtc =
      GeneratedColumn<DateTime>(
        'detected_at_utc',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _updatedAtUtcMeta = const VerificationMeta(
    'updatedAtUtc',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAtUtc = GeneratedColumn<DateTime>(
    'updated_at_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    conflictId,
    entityType,
    entitySyncId,
    fieldName,
    candidateOperationIdsJson,
    resolvedByOperationId,
    detectedAtUtc,
    updatedAtUtc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_conflicts';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncConflict> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('conflict_id')) {
      context.handle(
        _conflictIdMeta,
        conflictId.isAcceptableOrUnknown(data['conflict_id']!, _conflictIdMeta),
      );
    } else if (isInserting) {
      context.missing(_conflictIdMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_sync_id')) {
      context.handle(
        _entitySyncIdMeta,
        entitySyncId.isAcceptableOrUnknown(
          data['entity_sync_id']!,
          _entitySyncIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_entitySyncIdMeta);
    }
    if (data.containsKey('field_name')) {
      context.handle(
        _fieldNameMeta,
        fieldName.isAcceptableOrUnknown(data['field_name']!, _fieldNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fieldNameMeta);
    }
    if (data.containsKey('candidate_operation_ids_json')) {
      context.handle(
        _candidateOperationIdsJsonMeta,
        candidateOperationIdsJson.isAcceptableOrUnknown(
          data['candidate_operation_ids_json']!,
          _candidateOperationIdsJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_candidateOperationIdsJsonMeta);
    }
    if (data.containsKey('resolved_by_operation_id')) {
      context.handle(
        _resolvedByOperationIdMeta,
        resolvedByOperationId.isAcceptableOrUnknown(
          data['resolved_by_operation_id']!,
          _resolvedByOperationIdMeta,
        ),
      );
    }
    if (data.containsKey('detected_at_utc')) {
      context.handle(
        _detectedAtUtcMeta,
        detectedAtUtc.isAcceptableOrUnknown(
          data['detected_at_utc']!,
          _detectedAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_detectedAtUtcMeta);
    }
    if (data.containsKey('updated_at_utc')) {
      context.handle(
        _updatedAtUtcMeta,
        updatedAtUtc.isAcceptableOrUnknown(
          data['updated_at_utc']!,
          _updatedAtUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtUtcMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {conflictId};
  @override
  SyncConflict map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncConflict(
      conflictId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}conflict_id'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entitySyncId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_sync_id'],
      )!,
      fieldName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}field_name'],
      )!,
      candidateOperationIdsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}candidate_operation_ids_json'],
      )!,
      resolvedByOperationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}resolved_by_operation_id'],
      ),
      detectedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}detected_at_utc'],
      )!,
      updatedAtUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at_utc'],
      )!,
    );
  }

  @override
  $SyncConflictsTable createAlias(String alias) {
    return $SyncConflictsTable(attachedDatabase, alias);
  }
}

class SyncConflict extends DataClass implements Insertable<SyncConflict> {
  final String conflictId;
  final String entityType;
  final String entitySyncId;
  final String fieldName;
  final String candidateOperationIdsJson;
  final String? resolvedByOperationId;
  final DateTime detectedAtUtc;
  final DateTime updatedAtUtc;
  const SyncConflict({
    required this.conflictId,
    required this.entityType,
    required this.entitySyncId,
    required this.fieldName,
    required this.candidateOperationIdsJson,
    this.resolvedByOperationId,
    required this.detectedAtUtc,
    required this.updatedAtUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['conflict_id'] = Variable<String>(conflictId);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_sync_id'] = Variable<String>(entitySyncId);
    map['field_name'] = Variable<String>(fieldName);
    map['candidate_operation_ids_json'] = Variable<String>(
      candidateOperationIdsJson,
    );
    if (!nullToAbsent || resolvedByOperationId != null) {
      map['resolved_by_operation_id'] = Variable<String>(resolvedByOperationId);
    }
    map['detected_at_utc'] = Variable<DateTime>(detectedAtUtc);
    map['updated_at_utc'] = Variable<DateTime>(updatedAtUtc);
    return map;
  }

  SyncConflictsCompanion toCompanion(bool nullToAbsent) {
    return SyncConflictsCompanion(
      conflictId: Value(conflictId),
      entityType: Value(entityType),
      entitySyncId: Value(entitySyncId),
      fieldName: Value(fieldName),
      candidateOperationIdsJson: Value(candidateOperationIdsJson),
      resolvedByOperationId: resolvedByOperationId == null && nullToAbsent
          ? const Value.absent()
          : Value(resolvedByOperationId),
      detectedAtUtc: Value(detectedAtUtc),
      updatedAtUtc: Value(updatedAtUtc),
    );
  }

  factory SyncConflict.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncConflict(
      conflictId: serializer.fromJson<String>(json['conflictId']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entitySyncId: serializer.fromJson<String>(json['entitySyncId']),
      fieldName: serializer.fromJson<String>(json['fieldName']),
      candidateOperationIdsJson: serializer.fromJson<String>(
        json['candidateOperationIdsJson'],
      ),
      resolvedByOperationId: serializer.fromJson<String?>(
        json['resolvedByOperationId'],
      ),
      detectedAtUtc: serializer.fromJson<DateTime>(json['detectedAtUtc']),
      updatedAtUtc: serializer.fromJson<DateTime>(json['updatedAtUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'conflictId': serializer.toJson<String>(conflictId),
      'entityType': serializer.toJson<String>(entityType),
      'entitySyncId': serializer.toJson<String>(entitySyncId),
      'fieldName': serializer.toJson<String>(fieldName),
      'candidateOperationIdsJson': serializer.toJson<String>(
        candidateOperationIdsJson,
      ),
      'resolvedByOperationId': serializer.toJson<String?>(
        resolvedByOperationId,
      ),
      'detectedAtUtc': serializer.toJson<DateTime>(detectedAtUtc),
      'updatedAtUtc': serializer.toJson<DateTime>(updatedAtUtc),
    };
  }

  SyncConflict copyWith({
    String? conflictId,
    String? entityType,
    String? entitySyncId,
    String? fieldName,
    String? candidateOperationIdsJson,
    Value<String?> resolvedByOperationId = const Value.absent(),
    DateTime? detectedAtUtc,
    DateTime? updatedAtUtc,
  }) => SyncConflict(
    conflictId: conflictId ?? this.conflictId,
    entityType: entityType ?? this.entityType,
    entitySyncId: entitySyncId ?? this.entitySyncId,
    fieldName: fieldName ?? this.fieldName,
    candidateOperationIdsJson:
        candidateOperationIdsJson ?? this.candidateOperationIdsJson,
    resolvedByOperationId: resolvedByOperationId.present
        ? resolvedByOperationId.value
        : this.resolvedByOperationId,
    detectedAtUtc: detectedAtUtc ?? this.detectedAtUtc,
    updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
  );
  SyncConflict copyWithCompanion(SyncConflictsCompanion data) {
    return SyncConflict(
      conflictId: data.conflictId.present
          ? data.conflictId.value
          : this.conflictId,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entitySyncId: data.entitySyncId.present
          ? data.entitySyncId.value
          : this.entitySyncId,
      fieldName: data.fieldName.present ? data.fieldName.value : this.fieldName,
      candidateOperationIdsJson: data.candidateOperationIdsJson.present
          ? data.candidateOperationIdsJson.value
          : this.candidateOperationIdsJson,
      resolvedByOperationId: data.resolvedByOperationId.present
          ? data.resolvedByOperationId.value
          : this.resolvedByOperationId,
      detectedAtUtc: data.detectedAtUtc.present
          ? data.detectedAtUtc.value
          : this.detectedAtUtc,
      updatedAtUtc: data.updatedAtUtc.present
          ? data.updatedAtUtc.value
          : this.updatedAtUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncConflict(')
          ..write('conflictId: $conflictId, ')
          ..write('entityType: $entityType, ')
          ..write('entitySyncId: $entitySyncId, ')
          ..write('fieldName: $fieldName, ')
          ..write('candidateOperationIdsJson: $candidateOperationIdsJson, ')
          ..write('resolvedByOperationId: $resolvedByOperationId, ')
          ..write('detectedAtUtc: $detectedAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    conflictId,
    entityType,
    entitySyncId,
    fieldName,
    candidateOperationIdsJson,
    resolvedByOperationId,
    detectedAtUtc,
    updatedAtUtc,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncConflict &&
          other.conflictId == this.conflictId &&
          other.entityType == this.entityType &&
          other.entitySyncId == this.entitySyncId &&
          other.fieldName == this.fieldName &&
          other.candidateOperationIdsJson == this.candidateOperationIdsJson &&
          other.resolvedByOperationId == this.resolvedByOperationId &&
          other.detectedAtUtc == this.detectedAtUtc &&
          other.updatedAtUtc == this.updatedAtUtc);
}

class SyncConflictsCompanion extends UpdateCompanion<SyncConflict> {
  final Value<String> conflictId;
  final Value<String> entityType;
  final Value<String> entitySyncId;
  final Value<String> fieldName;
  final Value<String> candidateOperationIdsJson;
  final Value<String?> resolvedByOperationId;
  final Value<DateTime> detectedAtUtc;
  final Value<DateTime> updatedAtUtc;
  final Value<int> rowid;
  const SyncConflictsCompanion({
    this.conflictId = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entitySyncId = const Value.absent(),
    this.fieldName = const Value.absent(),
    this.candidateOperationIdsJson = const Value.absent(),
    this.resolvedByOperationId = const Value.absent(),
    this.detectedAtUtc = const Value.absent(),
    this.updatedAtUtc = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncConflictsCompanion.insert({
    required String conflictId,
    required String entityType,
    required String entitySyncId,
    required String fieldName,
    required String candidateOperationIdsJson,
    this.resolvedByOperationId = const Value.absent(),
    required DateTime detectedAtUtc,
    required DateTime updatedAtUtc,
    this.rowid = const Value.absent(),
  }) : conflictId = Value(conflictId),
       entityType = Value(entityType),
       entitySyncId = Value(entitySyncId),
       fieldName = Value(fieldName),
       candidateOperationIdsJson = Value(candidateOperationIdsJson),
       detectedAtUtc = Value(detectedAtUtc),
       updatedAtUtc = Value(updatedAtUtc);
  static Insertable<SyncConflict> custom({
    Expression<String>? conflictId,
    Expression<String>? entityType,
    Expression<String>? entitySyncId,
    Expression<String>? fieldName,
    Expression<String>? candidateOperationIdsJson,
    Expression<String>? resolvedByOperationId,
    Expression<DateTime>? detectedAtUtc,
    Expression<DateTime>? updatedAtUtc,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (conflictId != null) 'conflict_id': conflictId,
      if (entityType != null) 'entity_type': entityType,
      if (entitySyncId != null) 'entity_sync_id': entitySyncId,
      if (fieldName != null) 'field_name': fieldName,
      if (candidateOperationIdsJson != null)
        'candidate_operation_ids_json': candidateOperationIdsJson,
      if (resolvedByOperationId != null)
        'resolved_by_operation_id': resolvedByOperationId,
      if (detectedAtUtc != null) 'detected_at_utc': detectedAtUtc,
      if (updatedAtUtc != null) 'updated_at_utc': updatedAtUtc,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncConflictsCompanion copyWith({
    Value<String>? conflictId,
    Value<String>? entityType,
    Value<String>? entitySyncId,
    Value<String>? fieldName,
    Value<String>? candidateOperationIdsJson,
    Value<String?>? resolvedByOperationId,
    Value<DateTime>? detectedAtUtc,
    Value<DateTime>? updatedAtUtc,
    Value<int>? rowid,
  }) {
    return SyncConflictsCompanion(
      conflictId: conflictId ?? this.conflictId,
      entityType: entityType ?? this.entityType,
      entitySyncId: entitySyncId ?? this.entitySyncId,
      fieldName: fieldName ?? this.fieldName,
      candidateOperationIdsJson:
          candidateOperationIdsJson ?? this.candidateOperationIdsJson,
      resolvedByOperationId:
          resolvedByOperationId ?? this.resolvedByOperationId,
      detectedAtUtc: detectedAtUtc ?? this.detectedAtUtc,
      updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (conflictId.present) {
      map['conflict_id'] = Variable<String>(conflictId.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entitySyncId.present) {
      map['entity_sync_id'] = Variable<String>(entitySyncId.value);
    }
    if (fieldName.present) {
      map['field_name'] = Variable<String>(fieldName.value);
    }
    if (candidateOperationIdsJson.present) {
      map['candidate_operation_ids_json'] = Variable<String>(
        candidateOperationIdsJson.value,
      );
    }
    if (resolvedByOperationId.present) {
      map['resolved_by_operation_id'] = Variable<String>(
        resolvedByOperationId.value,
      );
    }
    if (detectedAtUtc.present) {
      map['detected_at_utc'] = Variable<DateTime>(detectedAtUtc.value);
    }
    if (updatedAtUtc.present) {
      map['updated_at_utc'] = Variable<DateTime>(updatedAtUtc.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncConflictsCompanion(')
          ..write('conflictId: $conflictId, ')
          ..write('entityType: $entityType, ')
          ..write('entitySyncId: $entitySyncId, ')
          ..write('fieldName: $fieldName, ')
          ..write('candidateOperationIdsJson: $candidateOperationIdsJson, ')
          ..write('resolvedByOperationId: $resolvedByOperationId, ')
          ..write('detectedAtUtc: $detectedAtUtc, ')
          ..write('updatedAtUtc: $updatedAtUtc, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $TasksTable tasks = $TasksTable(this);
  late final $LocalSyncStatesTable localSyncStates = $LocalSyncStatesTable(
    this,
  );
  late final $SyncDevicesTable syncDevices = $SyncDevicesTable(this);
  late final $SyncOperationsTable syncOperations = $SyncOperationsTable(this);
  late final $SyncFieldHeadsTable syncFieldHeads = $SyncFieldHeadsTable(this);
  late final $SyncConflictsTable syncConflicts = $SyncConflictsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    categories,
    tasks,
    localSyncStates,
    syncDevices,
    syncOperations,
    syncFieldHeads,
    syncConflicts,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'categories',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('tasks', kind: UpdateKind.update)],
    ),
  ]);
}

typedef $$CategoriesTableCreateCompanionBuilder =
    CategoriesCompanion Function({
      Value<int> id,
      Value<String?> syncId,
      required String name,
      required int colorArgb,
      Value<int> sortOrder,
      Value<String?> positionKey,
      required DateTime createdAtUtc,
      required DateTime updatedAtUtc,
      Value<DateTime?> deletedAtUtc,
    });
typedef $$CategoriesTableUpdateCompanionBuilder =
    CategoriesCompanion Function({
      Value<int> id,
      Value<String?> syncId,
      Value<String> name,
      Value<int> colorArgb,
      Value<int> sortOrder,
      Value<String?> positionKey,
      Value<DateTime> createdAtUtc,
      Value<DateTime> updatedAtUtc,
      Value<DateTime?> deletedAtUtc,
    });

final class $$CategoriesTableReferences
    extends BaseReferences<_$AppDatabase, $CategoriesTable, Category> {
  $$CategoriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TasksTable, List<Task>> _tasksRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.tasks,
    aliasName: 'categories__id__tasks__category_id',
  );

  $$TasksTableProcessedTableManager get tasksRefs {
    final manager = $$TasksTableTableManager(
      $_db,
      $_db.tasks,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_tasksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get colorArgb => $composableBuilder(
    column: $table.colorArgb,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get positionKey => $composableBuilder(
    column: $table.positionKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAtUtc => $composableBuilder(
    column: $table.deletedAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> tasksRefs(
    Expression<bool> Function($$TasksTableFilterComposer f) f,
  ) {
    final $$TasksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableFilterComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get colorArgb => $composableBuilder(
    column: $table.colorArgb,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get positionKey => $composableBuilder(
    column: $table.positionKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAtUtc => $composableBuilder(
    column: $table.deletedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get syncId =>
      $composableBuilder(column: $table.syncId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get colorArgb =>
      $composableBuilder(column: $table.colorArgb, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<String> get positionKey => $composableBuilder(
    column: $table.positionKey,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get deletedAtUtc => $composableBuilder(
    column: $table.deletedAtUtc,
    builder: (column) => column,
  );

  Expression<T> tasksRefs<T extends Object>(
    Expression<T> Function($$TasksTableAnnotationComposer a) f,
  ) {
    final $$TasksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableAnnotationComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoriesTable,
          Category,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (Category, $$CategoriesTableReferences),
          Category,
          PrefetchHooks Function({bool tasksRefs})
        > {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> syncId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> colorArgb = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<String?> positionKey = const Value.absent(),
                Value<DateTime> createdAtUtc = const Value.absent(),
                Value<DateTime> updatedAtUtc = const Value.absent(),
                Value<DateTime?> deletedAtUtc = const Value.absent(),
              }) => CategoriesCompanion(
                id: id,
                syncId: syncId,
                name: name,
                colorArgb: colorArgb,
                sortOrder: sortOrder,
                positionKey: positionKey,
                createdAtUtc: createdAtUtc,
                updatedAtUtc: updatedAtUtc,
                deletedAtUtc: deletedAtUtc,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> syncId = const Value.absent(),
                required String name,
                required int colorArgb,
                Value<int> sortOrder = const Value.absent(),
                Value<String?> positionKey = const Value.absent(),
                required DateTime createdAtUtc,
                required DateTime updatedAtUtc,
                Value<DateTime?> deletedAtUtc = const Value.absent(),
              }) => CategoriesCompanion.insert(
                id: id,
                syncId: syncId,
                name: name,
                colorArgb: colorArgb,
                sortOrder: sortOrder,
                positionKey: positionKey,
                createdAtUtc: createdAtUtc,
                updatedAtUtc: updatedAtUtc,
                deletedAtUtc: deletedAtUtc,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CategoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({tasksRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (tasksRefs) db.tasks],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (tasksRefs)
                    await $_getPrefetchedData<Category, $CategoriesTable, Task>(
                      currentTable: table,
                      referencedTable: $$CategoriesTableReferences
                          ._tasksRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$CategoriesTableReferences(db, table, p0).tasksRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.categoryId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoriesTable,
      Category,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (Category, $$CategoriesTableReferences),
      Category,
      PrefetchHooks Function({bool tasksRefs})
    >;
typedef $$TasksTableCreateCompanionBuilder =
    TasksCompanion Function({
      Value<int> id,
      Value<String?> syncId,
      required String name,
      Value<String> details,
      Value<String> detailImagesJson,
      required DateTime deadlineUtc,
      Value<int?> categoryId,
      Value<String?> positionKey,
      Value<bool> isCompleted,
      required DateTime createdAtUtc,
      required DateTime updatedAtUtc,
      Value<DateTime?> completedAtUtc,
      Value<DateTime?> deletedAtUtc,
    });
typedef $$TasksTableUpdateCompanionBuilder =
    TasksCompanion Function({
      Value<int> id,
      Value<String?> syncId,
      Value<String> name,
      Value<String> details,
      Value<String> detailImagesJson,
      Value<DateTime> deadlineUtc,
      Value<int?> categoryId,
      Value<String?> positionKey,
      Value<bool> isCompleted,
      Value<DateTime> createdAtUtc,
      Value<DateTime> updatedAtUtc,
      Value<DateTime?> completedAtUtc,
      Value<DateTime?> deletedAtUtc,
    });

final class $$TasksTableReferences
    extends BaseReferences<_$AppDatabase, $TasksTable, Task> {
  $$TasksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.categories.createAlias('tasks__category_id__categories__id');

  $$CategoriesTableProcessedTableManager? get categoryId {
    final $_column = $_itemColumn<int>('category_id');
    if ($_column == null) return null;
    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TasksTableFilterComposer extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get details => $composableBuilder(
    column: $table.details,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get detailImagesJson => $composableBuilder(
    column: $table.detailImagesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deadlineUtc => $composableBuilder(
    column: $table.deadlineUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get positionKey => $composableBuilder(
    column: $table.positionKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAtUtc => $composableBuilder(
    column: $table.completedAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAtUtc => $composableBuilder(
    column: $table.deletedAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TasksTableOrderingComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get details => $composableBuilder(
    column: $table.details,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get detailImagesJson => $composableBuilder(
    column: $table.detailImagesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deadlineUtc => $composableBuilder(
    column: $table.deadlineUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get positionKey => $composableBuilder(
    column: $table.positionKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAtUtc => $composableBuilder(
    column: $table.completedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAtUtc => $composableBuilder(
    column: $table.deletedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get syncId =>
      $composableBuilder(column: $table.syncId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get details =>
      $composableBuilder(column: $table.details, builder: (column) => column);

  GeneratedColumn<String> get detailImagesJson => $composableBuilder(
    column: $table.detailImagesJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get deadlineUtc => $composableBuilder(
    column: $table.deadlineUtc,
    builder: (column) => column,
  );

  GeneratedColumn<String> get positionKey => $composableBuilder(
    column: $table.positionKey,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAtUtc => $composableBuilder(
    column: $table.createdAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get completedAtUtc => $composableBuilder(
    column: $table.completedAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get deletedAtUtc => $composableBuilder(
    column: $table.deletedAtUtc,
    builder: (column) => column,
  );

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TasksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TasksTable,
          Task,
          $$TasksTableFilterComposer,
          $$TasksTableOrderingComposer,
          $$TasksTableAnnotationComposer,
          $$TasksTableCreateCompanionBuilder,
          $$TasksTableUpdateCompanionBuilder,
          (Task, $$TasksTableReferences),
          Task,
          PrefetchHooks Function({bool categoryId})
        > {
  $$TasksTableTableManager(_$AppDatabase db, $TasksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> syncId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> details = const Value.absent(),
                Value<String> detailImagesJson = const Value.absent(),
                Value<DateTime> deadlineUtc = const Value.absent(),
                Value<int?> categoryId = const Value.absent(),
                Value<String?> positionKey = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<DateTime> createdAtUtc = const Value.absent(),
                Value<DateTime> updatedAtUtc = const Value.absent(),
                Value<DateTime?> completedAtUtc = const Value.absent(),
                Value<DateTime?> deletedAtUtc = const Value.absent(),
              }) => TasksCompanion(
                id: id,
                syncId: syncId,
                name: name,
                details: details,
                detailImagesJson: detailImagesJson,
                deadlineUtc: deadlineUtc,
                categoryId: categoryId,
                positionKey: positionKey,
                isCompleted: isCompleted,
                createdAtUtc: createdAtUtc,
                updatedAtUtc: updatedAtUtc,
                completedAtUtc: completedAtUtc,
                deletedAtUtc: deletedAtUtc,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> syncId = const Value.absent(),
                required String name,
                Value<String> details = const Value.absent(),
                Value<String> detailImagesJson = const Value.absent(),
                required DateTime deadlineUtc,
                Value<int?> categoryId = const Value.absent(),
                Value<String?> positionKey = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                required DateTime createdAtUtc,
                required DateTime updatedAtUtc,
                Value<DateTime?> completedAtUtc = const Value.absent(),
                Value<DateTime?> deletedAtUtc = const Value.absent(),
              }) => TasksCompanion.insert(
                id: id,
                syncId: syncId,
                name: name,
                details: details,
                detailImagesJson: detailImagesJson,
                deadlineUtc: deadlineUtc,
                categoryId: categoryId,
                positionKey: positionKey,
                isCompleted: isCompleted,
                createdAtUtc: createdAtUtc,
                updatedAtUtc: updatedAtUtc,
                completedAtUtc: completedAtUtc,
                deletedAtUtc: deletedAtUtc,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$TasksTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({categoryId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (categoryId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.categoryId,
                                referencedTable: $$TasksTableReferences
                                    ._categoryIdTable(db),
                                referencedColumn: $$TasksTableReferences
                                    ._categoryIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TasksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TasksTable,
      Task,
      $$TasksTableFilterComposer,
      $$TasksTableOrderingComposer,
      $$TasksTableAnnotationComposer,
      $$TasksTableCreateCompanionBuilder,
      $$TasksTableUpdateCompanionBuilder,
      (Task, $$TasksTableReferences),
      Task,
      PrefetchHooks Function({bool categoryId})
    >;
typedef $$LocalSyncStatesTableCreateCompanionBuilder =
    LocalSyncStatesCompanion Function({
      Value<int> id,
      required String spaceId,
      required String deviceId,
      required String deviceName,
      Value<int> nextSequence,
      Value<String> vectorJson,
      Value<int> hlcMillis,
      Value<int> hlcCounter,
    });
typedef $$LocalSyncStatesTableUpdateCompanionBuilder =
    LocalSyncStatesCompanion Function({
      Value<int> id,
      Value<String> spaceId,
      Value<String> deviceId,
      Value<String> deviceName,
      Value<int> nextSequence,
      Value<String> vectorJson,
      Value<int> hlcMillis,
      Value<int> hlcCounter,
    });

class $$LocalSyncStatesTableFilterComposer
    extends Composer<_$AppDatabase, $LocalSyncStatesTable> {
  $$LocalSyncStatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get spaceId => $composableBuilder(
    column: $table.spaceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceName => $composableBuilder(
    column: $table.deviceName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get nextSequence => $composableBuilder(
    column: $table.nextSequence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vectorJson => $composableBuilder(
    column: $table.vectorJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hlcMillis => $composableBuilder(
    column: $table.hlcMillis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hlcCounter => $composableBuilder(
    column: $table.hlcCounter,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalSyncStatesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalSyncStatesTable> {
  $$LocalSyncStatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get spaceId => $composableBuilder(
    column: $table.spaceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceName => $composableBuilder(
    column: $table.deviceName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get nextSequence => $composableBuilder(
    column: $table.nextSequence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vectorJson => $composableBuilder(
    column: $table.vectorJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hlcMillis => $composableBuilder(
    column: $table.hlcMillis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hlcCounter => $composableBuilder(
    column: $table.hlcCounter,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalSyncStatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalSyncStatesTable> {
  $$LocalSyncStatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get spaceId =>
      $composableBuilder(column: $table.spaceId, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get deviceName => $composableBuilder(
    column: $table.deviceName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get nextSequence => $composableBuilder(
    column: $table.nextSequence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get vectorJson => $composableBuilder(
    column: $table.vectorJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get hlcMillis =>
      $composableBuilder(column: $table.hlcMillis, builder: (column) => column);

  GeneratedColumn<int> get hlcCounter => $composableBuilder(
    column: $table.hlcCounter,
    builder: (column) => column,
  );
}

class $$LocalSyncStatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalSyncStatesTable,
          LocalSyncState,
          $$LocalSyncStatesTableFilterComposer,
          $$LocalSyncStatesTableOrderingComposer,
          $$LocalSyncStatesTableAnnotationComposer,
          $$LocalSyncStatesTableCreateCompanionBuilder,
          $$LocalSyncStatesTableUpdateCompanionBuilder,
          (
            LocalSyncState,
            BaseReferences<
              _$AppDatabase,
              $LocalSyncStatesTable,
              LocalSyncState
            >,
          ),
          LocalSyncState,
          PrefetchHooks Function()
        > {
  $$LocalSyncStatesTableTableManager(
    _$AppDatabase db,
    $LocalSyncStatesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalSyncStatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalSyncStatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalSyncStatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> spaceId = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<String> deviceName = const Value.absent(),
                Value<int> nextSequence = const Value.absent(),
                Value<String> vectorJson = const Value.absent(),
                Value<int> hlcMillis = const Value.absent(),
                Value<int> hlcCounter = const Value.absent(),
              }) => LocalSyncStatesCompanion(
                id: id,
                spaceId: spaceId,
                deviceId: deviceId,
                deviceName: deviceName,
                nextSequence: nextSequence,
                vectorJson: vectorJson,
                hlcMillis: hlcMillis,
                hlcCounter: hlcCounter,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String spaceId,
                required String deviceId,
                required String deviceName,
                Value<int> nextSequence = const Value.absent(),
                Value<String> vectorJson = const Value.absent(),
                Value<int> hlcMillis = const Value.absent(),
                Value<int> hlcCounter = const Value.absent(),
              }) => LocalSyncStatesCompanion.insert(
                id: id,
                spaceId: spaceId,
                deviceId: deviceId,
                deviceName: deviceName,
                nextSequence: nextSequence,
                vectorJson: vectorJson,
                hlcMillis: hlcMillis,
                hlcCounter: hlcCounter,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalSyncStatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalSyncStatesTable,
      LocalSyncState,
      $$LocalSyncStatesTableFilterComposer,
      $$LocalSyncStatesTableOrderingComposer,
      $$LocalSyncStatesTableAnnotationComposer,
      $$LocalSyncStatesTableCreateCompanionBuilder,
      $$LocalSyncStatesTableUpdateCompanionBuilder,
      (
        LocalSyncState,
        BaseReferences<_$AppDatabase, $LocalSyncStatesTable, LocalSyncState>,
      ),
      LocalSyncState,
      PrefetchHooks Function()
    >;
typedef $$SyncDevicesTableCreateCompanionBuilder =
    SyncDevicesCompanion Function({
      required String deviceId,
      required String displayName,
      required DateTime pairedAtUtc,
      required DateTime lastSeenAtUtc,
      Value<String> acknowledgedVectorJson,
      Value<bool> isTrusted,
      Value<int> rowid,
    });
typedef $$SyncDevicesTableUpdateCompanionBuilder =
    SyncDevicesCompanion Function({
      Value<String> deviceId,
      Value<String> displayName,
      Value<DateTime> pairedAtUtc,
      Value<DateTime> lastSeenAtUtc,
      Value<String> acknowledgedVectorJson,
      Value<bool> isTrusted,
      Value<int> rowid,
    });

class $$SyncDevicesTableFilterComposer
    extends Composer<_$AppDatabase, $SyncDevicesTable> {
  $$SyncDevicesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get pairedAtUtc => $composableBuilder(
    column: $table.pairedAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSeenAtUtc => $composableBuilder(
    column: $table.lastSeenAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get acknowledgedVectorJson => $composableBuilder(
    column: $table.acknowledgedVectorJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isTrusted => $composableBuilder(
    column: $table.isTrusted,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncDevicesTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncDevicesTable> {
  $$SyncDevicesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get pairedAtUtc => $composableBuilder(
    column: $table.pairedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSeenAtUtc => $composableBuilder(
    column: $table.lastSeenAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get acknowledgedVectorJson => $composableBuilder(
    column: $table.acknowledgedVectorJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isTrusted => $composableBuilder(
    column: $table.isTrusted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncDevicesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncDevicesTable> {
  $$SyncDevicesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get pairedAtUtc => $composableBuilder(
    column: $table.pairedAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastSeenAtUtc => $composableBuilder(
    column: $table.lastSeenAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<String> get acknowledgedVectorJson => $composableBuilder(
    column: $table.acknowledgedVectorJson,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isTrusted =>
      $composableBuilder(column: $table.isTrusted, builder: (column) => column);
}

class $$SyncDevicesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncDevicesTable,
          SyncDevice,
          $$SyncDevicesTableFilterComposer,
          $$SyncDevicesTableOrderingComposer,
          $$SyncDevicesTableAnnotationComposer,
          $$SyncDevicesTableCreateCompanionBuilder,
          $$SyncDevicesTableUpdateCompanionBuilder,
          (
            SyncDevice,
            BaseReferences<_$AppDatabase, $SyncDevicesTable, SyncDevice>,
          ),
          SyncDevice,
          PrefetchHooks Function()
        > {
  $$SyncDevicesTableTableManager(_$AppDatabase db, $SyncDevicesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncDevicesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncDevicesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncDevicesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> deviceId = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<DateTime> pairedAtUtc = const Value.absent(),
                Value<DateTime> lastSeenAtUtc = const Value.absent(),
                Value<String> acknowledgedVectorJson = const Value.absent(),
                Value<bool> isTrusted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncDevicesCompanion(
                deviceId: deviceId,
                displayName: displayName,
                pairedAtUtc: pairedAtUtc,
                lastSeenAtUtc: lastSeenAtUtc,
                acknowledgedVectorJson: acknowledgedVectorJson,
                isTrusted: isTrusted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String deviceId,
                required String displayName,
                required DateTime pairedAtUtc,
                required DateTime lastSeenAtUtc,
                Value<String> acknowledgedVectorJson = const Value.absent(),
                Value<bool> isTrusted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncDevicesCompanion.insert(
                deviceId: deviceId,
                displayName: displayName,
                pairedAtUtc: pairedAtUtc,
                lastSeenAtUtc: lastSeenAtUtc,
                acknowledgedVectorJson: acknowledgedVectorJson,
                isTrusted: isTrusted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncDevicesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncDevicesTable,
      SyncDevice,
      $$SyncDevicesTableFilterComposer,
      $$SyncDevicesTableOrderingComposer,
      $$SyncDevicesTableAnnotationComposer,
      $$SyncDevicesTableCreateCompanionBuilder,
      $$SyncDevicesTableUpdateCompanionBuilder,
      (
        SyncDevice,
        BaseReferences<_$AppDatabase, $SyncDevicesTable, SyncDevice>,
      ),
      SyncDevice,
      PrefetchHooks Function()
    >;
typedef $$SyncOperationsTableCreateCompanionBuilder =
    SyncOperationsCompanion Function({
      required String operationId,
      required String originDeviceId,
      required int originSequence,
      required String contextJson,
      required int hlcMillis,
      required int hlcCounter,
      Value<String?> transactionId,
      Value<int?> transactionIndex,
      Value<int?> transactionCount,
      required String entityType,
      required String entitySyncId,
      required String operationKind,
      required String changesJson,
      Value<String> resolvesJson,
      required DateTime occurredAtUtc,
      Value<int> rowid,
    });
typedef $$SyncOperationsTableUpdateCompanionBuilder =
    SyncOperationsCompanion Function({
      Value<String> operationId,
      Value<String> originDeviceId,
      Value<int> originSequence,
      Value<String> contextJson,
      Value<int> hlcMillis,
      Value<int> hlcCounter,
      Value<String?> transactionId,
      Value<int?> transactionIndex,
      Value<int?> transactionCount,
      Value<String> entityType,
      Value<String> entitySyncId,
      Value<String> operationKind,
      Value<String> changesJson,
      Value<String> resolvesJson,
      Value<DateTime> occurredAtUtc,
      Value<int> rowid,
    });

class $$SyncOperationsTableFilterComposer
    extends Composer<_$AppDatabase, $SyncOperationsTable> {
  $$SyncOperationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get operationId => $composableBuilder(
    column: $table.operationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originDeviceId => $composableBuilder(
    column: $table.originDeviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get originSequence => $composableBuilder(
    column: $table.originSequence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contextJson => $composableBuilder(
    column: $table.contextJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hlcMillis => $composableBuilder(
    column: $table.hlcMillis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hlcCounter => $composableBuilder(
    column: $table.hlcCounter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transactionId => $composableBuilder(
    column: $table.transactionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get transactionIndex => $composableBuilder(
    column: $table.transactionIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get transactionCount => $composableBuilder(
    column: $table.transactionCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entitySyncId => $composableBuilder(
    column: $table.entitySyncId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operationKind => $composableBuilder(
    column: $table.operationKind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get changesJson => $composableBuilder(
    column: $table.changesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resolvesJson => $composableBuilder(
    column: $table.resolvesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get occurredAtUtc => $composableBuilder(
    column: $table.occurredAtUtc,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncOperationsTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncOperationsTable> {
  $$SyncOperationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get operationId => $composableBuilder(
    column: $table.operationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originDeviceId => $composableBuilder(
    column: $table.originDeviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get originSequence => $composableBuilder(
    column: $table.originSequence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contextJson => $composableBuilder(
    column: $table.contextJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hlcMillis => $composableBuilder(
    column: $table.hlcMillis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hlcCounter => $composableBuilder(
    column: $table.hlcCounter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transactionId => $composableBuilder(
    column: $table.transactionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get transactionIndex => $composableBuilder(
    column: $table.transactionIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get transactionCount => $composableBuilder(
    column: $table.transactionCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entitySyncId => $composableBuilder(
    column: $table.entitySyncId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operationKind => $composableBuilder(
    column: $table.operationKind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get changesJson => $composableBuilder(
    column: $table.changesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resolvesJson => $composableBuilder(
    column: $table.resolvesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get occurredAtUtc => $composableBuilder(
    column: $table.occurredAtUtc,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncOperationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncOperationsTable> {
  $$SyncOperationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get operationId => $composableBuilder(
    column: $table.operationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get originDeviceId => $composableBuilder(
    column: $table.originDeviceId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get originSequence => $composableBuilder(
    column: $table.originSequence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contextJson => $composableBuilder(
    column: $table.contextJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get hlcMillis =>
      $composableBuilder(column: $table.hlcMillis, builder: (column) => column);

  GeneratedColumn<int> get hlcCounter => $composableBuilder(
    column: $table.hlcCounter,
    builder: (column) => column,
  );

  GeneratedColumn<String> get transactionId => $composableBuilder(
    column: $table.transactionId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get transactionIndex => $composableBuilder(
    column: $table.transactionIndex,
    builder: (column) => column,
  );

  GeneratedColumn<int> get transactionCount => $composableBuilder(
    column: $table.transactionCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entitySyncId => $composableBuilder(
    column: $table.entitySyncId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get operationKind => $composableBuilder(
    column: $table.operationKind,
    builder: (column) => column,
  );

  GeneratedColumn<String> get changesJson => $composableBuilder(
    column: $table.changesJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get resolvesJson => $composableBuilder(
    column: $table.resolvesJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get occurredAtUtc => $composableBuilder(
    column: $table.occurredAtUtc,
    builder: (column) => column,
  );
}

class $$SyncOperationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncOperationsTable,
          SyncOperation,
          $$SyncOperationsTableFilterComposer,
          $$SyncOperationsTableOrderingComposer,
          $$SyncOperationsTableAnnotationComposer,
          $$SyncOperationsTableCreateCompanionBuilder,
          $$SyncOperationsTableUpdateCompanionBuilder,
          (
            SyncOperation,
            BaseReferences<_$AppDatabase, $SyncOperationsTable, SyncOperation>,
          ),
          SyncOperation,
          PrefetchHooks Function()
        > {
  $$SyncOperationsTableTableManager(
    _$AppDatabase db,
    $SyncOperationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncOperationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncOperationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncOperationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> operationId = const Value.absent(),
                Value<String> originDeviceId = const Value.absent(),
                Value<int> originSequence = const Value.absent(),
                Value<String> contextJson = const Value.absent(),
                Value<int> hlcMillis = const Value.absent(),
                Value<int> hlcCounter = const Value.absent(),
                Value<String?> transactionId = const Value.absent(),
                Value<int?> transactionIndex = const Value.absent(),
                Value<int?> transactionCount = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> entitySyncId = const Value.absent(),
                Value<String> operationKind = const Value.absent(),
                Value<String> changesJson = const Value.absent(),
                Value<String> resolvesJson = const Value.absent(),
                Value<DateTime> occurredAtUtc = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncOperationsCompanion(
                operationId: operationId,
                originDeviceId: originDeviceId,
                originSequence: originSequence,
                contextJson: contextJson,
                hlcMillis: hlcMillis,
                hlcCounter: hlcCounter,
                transactionId: transactionId,
                transactionIndex: transactionIndex,
                transactionCount: transactionCount,
                entityType: entityType,
                entitySyncId: entitySyncId,
                operationKind: operationKind,
                changesJson: changesJson,
                resolvesJson: resolvesJson,
                occurredAtUtc: occurredAtUtc,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String operationId,
                required String originDeviceId,
                required int originSequence,
                required String contextJson,
                required int hlcMillis,
                required int hlcCounter,
                Value<String?> transactionId = const Value.absent(),
                Value<int?> transactionIndex = const Value.absent(),
                Value<int?> transactionCount = const Value.absent(),
                required String entityType,
                required String entitySyncId,
                required String operationKind,
                required String changesJson,
                Value<String> resolvesJson = const Value.absent(),
                required DateTime occurredAtUtc,
                Value<int> rowid = const Value.absent(),
              }) => SyncOperationsCompanion.insert(
                operationId: operationId,
                originDeviceId: originDeviceId,
                originSequence: originSequence,
                contextJson: contextJson,
                hlcMillis: hlcMillis,
                hlcCounter: hlcCounter,
                transactionId: transactionId,
                transactionIndex: transactionIndex,
                transactionCount: transactionCount,
                entityType: entityType,
                entitySyncId: entitySyncId,
                operationKind: operationKind,
                changesJson: changesJson,
                resolvesJson: resolvesJson,
                occurredAtUtc: occurredAtUtc,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncOperationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncOperationsTable,
      SyncOperation,
      $$SyncOperationsTableFilterComposer,
      $$SyncOperationsTableOrderingComposer,
      $$SyncOperationsTableAnnotationComposer,
      $$SyncOperationsTableCreateCompanionBuilder,
      $$SyncOperationsTableUpdateCompanionBuilder,
      (
        SyncOperation,
        BaseReferences<_$AppDatabase, $SyncOperationsTable, SyncOperation>,
      ),
      SyncOperation,
      PrefetchHooks Function()
    >;
typedef $$SyncFieldHeadsTableCreateCompanionBuilder =
    SyncFieldHeadsCompanion Function({
      required String entityType,
      required String entitySyncId,
      required String fieldName,
      required String candidateOperationIdsJson,
      Value<int> rowid,
    });
typedef $$SyncFieldHeadsTableUpdateCompanionBuilder =
    SyncFieldHeadsCompanion Function({
      Value<String> entityType,
      Value<String> entitySyncId,
      Value<String> fieldName,
      Value<String> candidateOperationIdsJson,
      Value<int> rowid,
    });

class $$SyncFieldHeadsTableFilterComposer
    extends Composer<_$AppDatabase, $SyncFieldHeadsTable> {
  $$SyncFieldHeadsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entitySyncId => $composableBuilder(
    column: $table.entitySyncId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fieldName => $composableBuilder(
    column: $table.fieldName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get candidateOperationIdsJson => $composableBuilder(
    column: $table.candidateOperationIdsJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncFieldHeadsTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncFieldHeadsTable> {
  $$SyncFieldHeadsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entitySyncId => $composableBuilder(
    column: $table.entitySyncId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fieldName => $composableBuilder(
    column: $table.fieldName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get candidateOperationIdsJson => $composableBuilder(
    column: $table.candidateOperationIdsJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncFieldHeadsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncFieldHeadsTable> {
  $$SyncFieldHeadsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entitySyncId => $composableBuilder(
    column: $table.entitySyncId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fieldName =>
      $composableBuilder(column: $table.fieldName, builder: (column) => column);

  GeneratedColumn<String> get candidateOperationIdsJson => $composableBuilder(
    column: $table.candidateOperationIdsJson,
    builder: (column) => column,
  );
}

class $$SyncFieldHeadsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncFieldHeadsTable,
          SyncFieldHead,
          $$SyncFieldHeadsTableFilterComposer,
          $$SyncFieldHeadsTableOrderingComposer,
          $$SyncFieldHeadsTableAnnotationComposer,
          $$SyncFieldHeadsTableCreateCompanionBuilder,
          $$SyncFieldHeadsTableUpdateCompanionBuilder,
          (
            SyncFieldHead,
            BaseReferences<_$AppDatabase, $SyncFieldHeadsTable, SyncFieldHead>,
          ),
          SyncFieldHead,
          PrefetchHooks Function()
        > {
  $$SyncFieldHeadsTableTableManager(
    _$AppDatabase db,
    $SyncFieldHeadsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncFieldHeadsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncFieldHeadsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncFieldHeadsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> entityType = const Value.absent(),
                Value<String> entitySyncId = const Value.absent(),
                Value<String> fieldName = const Value.absent(),
                Value<String> candidateOperationIdsJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncFieldHeadsCompanion(
                entityType: entityType,
                entitySyncId: entitySyncId,
                fieldName: fieldName,
                candidateOperationIdsJson: candidateOperationIdsJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String entityType,
                required String entitySyncId,
                required String fieldName,
                required String candidateOperationIdsJson,
                Value<int> rowid = const Value.absent(),
              }) => SyncFieldHeadsCompanion.insert(
                entityType: entityType,
                entitySyncId: entitySyncId,
                fieldName: fieldName,
                candidateOperationIdsJson: candidateOperationIdsJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncFieldHeadsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncFieldHeadsTable,
      SyncFieldHead,
      $$SyncFieldHeadsTableFilterComposer,
      $$SyncFieldHeadsTableOrderingComposer,
      $$SyncFieldHeadsTableAnnotationComposer,
      $$SyncFieldHeadsTableCreateCompanionBuilder,
      $$SyncFieldHeadsTableUpdateCompanionBuilder,
      (
        SyncFieldHead,
        BaseReferences<_$AppDatabase, $SyncFieldHeadsTable, SyncFieldHead>,
      ),
      SyncFieldHead,
      PrefetchHooks Function()
    >;
typedef $$SyncConflictsTableCreateCompanionBuilder =
    SyncConflictsCompanion Function({
      required String conflictId,
      required String entityType,
      required String entitySyncId,
      required String fieldName,
      required String candidateOperationIdsJson,
      Value<String?> resolvedByOperationId,
      required DateTime detectedAtUtc,
      required DateTime updatedAtUtc,
      Value<int> rowid,
    });
typedef $$SyncConflictsTableUpdateCompanionBuilder =
    SyncConflictsCompanion Function({
      Value<String> conflictId,
      Value<String> entityType,
      Value<String> entitySyncId,
      Value<String> fieldName,
      Value<String> candidateOperationIdsJson,
      Value<String?> resolvedByOperationId,
      Value<DateTime> detectedAtUtc,
      Value<DateTime> updatedAtUtc,
      Value<int> rowid,
    });

class $$SyncConflictsTableFilterComposer
    extends Composer<_$AppDatabase, $SyncConflictsTable> {
  $$SyncConflictsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get conflictId => $composableBuilder(
    column: $table.conflictId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entitySyncId => $composableBuilder(
    column: $table.entitySyncId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fieldName => $composableBuilder(
    column: $table.fieldName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get candidateOperationIdsJson => $composableBuilder(
    column: $table.candidateOperationIdsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resolvedByOperationId => $composableBuilder(
    column: $table.resolvedByOperationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get detectedAtUtc => $composableBuilder(
    column: $table.detectedAtUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncConflictsTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncConflictsTable> {
  $$SyncConflictsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get conflictId => $composableBuilder(
    column: $table.conflictId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entitySyncId => $composableBuilder(
    column: $table.entitySyncId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fieldName => $composableBuilder(
    column: $table.fieldName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get candidateOperationIdsJson => $composableBuilder(
    column: $table.candidateOperationIdsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resolvedByOperationId => $composableBuilder(
    column: $table.resolvedByOperationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get detectedAtUtc => $composableBuilder(
    column: $table.detectedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncConflictsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncConflictsTable> {
  $$SyncConflictsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get conflictId => $composableBuilder(
    column: $table.conflictId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entitySyncId => $composableBuilder(
    column: $table.entitySyncId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fieldName =>
      $composableBuilder(column: $table.fieldName, builder: (column) => column);

  GeneratedColumn<String> get candidateOperationIdsJson => $composableBuilder(
    column: $table.candidateOperationIdsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get resolvedByOperationId => $composableBuilder(
    column: $table.resolvedByOperationId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get detectedAtUtc => $composableBuilder(
    column: $table.detectedAtUtc,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAtUtc => $composableBuilder(
    column: $table.updatedAtUtc,
    builder: (column) => column,
  );
}

class $$SyncConflictsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncConflictsTable,
          SyncConflict,
          $$SyncConflictsTableFilterComposer,
          $$SyncConflictsTableOrderingComposer,
          $$SyncConflictsTableAnnotationComposer,
          $$SyncConflictsTableCreateCompanionBuilder,
          $$SyncConflictsTableUpdateCompanionBuilder,
          (
            SyncConflict,
            BaseReferences<_$AppDatabase, $SyncConflictsTable, SyncConflict>,
          ),
          SyncConflict,
          PrefetchHooks Function()
        > {
  $$SyncConflictsTableTableManager(_$AppDatabase db, $SyncConflictsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncConflictsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncConflictsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncConflictsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> conflictId = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> entitySyncId = const Value.absent(),
                Value<String> fieldName = const Value.absent(),
                Value<String> candidateOperationIdsJson = const Value.absent(),
                Value<String?> resolvedByOperationId = const Value.absent(),
                Value<DateTime> detectedAtUtc = const Value.absent(),
                Value<DateTime> updatedAtUtc = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncConflictsCompanion(
                conflictId: conflictId,
                entityType: entityType,
                entitySyncId: entitySyncId,
                fieldName: fieldName,
                candidateOperationIdsJson: candidateOperationIdsJson,
                resolvedByOperationId: resolvedByOperationId,
                detectedAtUtc: detectedAtUtc,
                updatedAtUtc: updatedAtUtc,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String conflictId,
                required String entityType,
                required String entitySyncId,
                required String fieldName,
                required String candidateOperationIdsJson,
                Value<String?> resolvedByOperationId = const Value.absent(),
                required DateTime detectedAtUtc,
                required DateTime updatedAtUtc,
                Value<int> rowid = const Value.absent(),
              }) => SyncConflictsCompanion.insert(
                conflictId: conflictId,
                entityType: entityType,
                entitySyncId: entitySyncId,
                fieldName: fieldName,
                candidateOperationIdsJson: candidateOperationIdsJson,
                resolvedByOperationId: resolvedByOperationId,
                detectedAtUtc: detectedAtUtc,
                updatedAtUtc: updatedAtUtc,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncConflictsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncConflictsTable,
      SyncConflict,
      $$SyncConflictsTableFilterComposer,
      $$SyncConflictsTableOrderingComposer,
      $$SyncConflictsTableAnnotationComposer,
      $$SyncConflictsTableCreateCompanionBuilder,
      $$SyncConflictsTableUpdateCompanionBuilder,
      (
        SyncConflict,
        BaseReferences<_$AppDatabase, $SyncConflictsTable, SyncConflict>,
      ),
      SyncConflict,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$TasksTableTableManager get tasks =>
      $$TasksTableTableManager(_db, _db.tasks);
  $$LocalSyncStatesTableTableManager get localSyncStates =>
      $$LocalSyncStatesTableTableManager(_db, _db.localSyncStates);
  $$SyncDevicesTableTableManager get syncDevices =>
      $$SyncDevicesTableTableManager(_db, _db.syncDevices);
  $$SyncOperationsTableTableManager get syncOperations =>
      $$SyncOperationsTableTableManager(_db, _db.syncOperations);
  $$SyncFieldHeadsTableTableManager get syncFieldHeads =>
      $$SyncFieldHeadsTableTableManager(_db, _db.syncFieldHeads);
  $$SyncConflictsTableTableManager get syncConflicts =>
      $$SyncConflictsTableTableManager(_db, _db.syncConflicts);
}
