// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ArchetypesTable extends Archetypes
    with TableInfo<$ArchetypesTable, ArchetypeRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ArchetypesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _blurbMeta = const VerificationMeta('blurb');
  @override
  late final GeneratedColumn<String> blurb = GeneratedColumn<String>(
    'blurb',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortMeta = const VerificationMeta('sort');
  @override
  late final GeneratedColumn<int> sort = GeneratedColumn<int>(
    'sort',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    key,
    name,
    blurb,
    color,
    sort,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'archetypes';
  @override
  VerificationContext validateIntegrity(
    Insertable<ArchetypeRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('blurb')) {
      context.handle(
        _blurbMeta,
        blurb.isAcceptableOrUnknown(data['blurb']!, _blurbMeta),
      );
    } else if (isInserting) {
      context.missing(_blurbMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    } else if (isInserting) {
      context.missing(_colorMeta);
    }
    if (data.containsKey('sort')) {
      context.handle(
        _sortMeta,
        sort.isAcceptableOrUnknown(data['sort']!, _sortMeta),
      );
    } else if (isInserting) {
      context.missing(_sortMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ArchetypeRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ArchetypeRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      blurb: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}blurb'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      )!,
      sort: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ArchetypesTable createAlias(String alias) {
    return $ArchetypesTable(attachedDatabase, alias);
  }
}

class ArchetypeRow extends DataClass implements Insertable<ArchetypeRow> {
  final String id;
  final String key;
  final String name;
  final String blurb;
  final String color;
  final int sort;
  final DateTime updatedAt;
  const ArchetypeRow({
    required this.id,
    required this.key,
    required this.name,
    required this.blurb,
    required this.color,
    required this.sort,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['key'] = Variable<String>(key);
    map['name'] = Variable<String>(name);
    map['blurb'] = Variable<String>(blurb);
    map['color'] = Variable<String>(color);
    map['sort'] = Variable<int>(sort);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ArchetypesCompanion toCompanion(bool nullToAbsent) {
    return ArchetypesCompanion(
      id: Value(id),
      key: Value(key),
      name: Value(name),
      blurb: Value(blurb),
      color: Value(color),
      sort: Value(sort),
      updatedAt: Value(updatedAt),
    );
  }

  factory ArchetypeRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ArchetypeRow(
      id: serializer.fromJson<String>(json['id']),
      key: serializer.fromJson<String>(json['key']),
      name: serializer.fromJson<String>(json['name']),
      blurb: serializer.fromJson<String>(json['blurb']),
      color: serializer.fromJson<String>(json['color']),
      sort: serializer.fromJson<int>(json['sort']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'key': serializer.toJson<String>(key),
      'name': serializer.toJson<String>(name),
      'blurb': serializer.toJson<String>(blurb),
      'color': serializer.toJson<String>(color),
      'sort': serializer.toJson<int>(sort),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ArchetypeRow copyWith({
    String? id,
    String? key,
    String? name,
    String? blurb,
    String? color,
    int? sort,
    DateTime? updatedAt,
  }) => ArchetypeRow(
    id: id ?? this.id,
    key: key ?? this.key,
    name: name ?? this.name,
    blurb: blurb ?? this.blurb,
    color: color ?? this.color,
    sort: sort ?? this.sort,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ArchetypeRow copyWithCompanion(ArchetypesCompanion data) {
    return ArchetypeRow(
      id: data.id.present ? data.id.value : this.id,
      key: data.key.present ? data.key.value : this.key,
      name: data.name.present ? data.name.value : this.name,
      blurb: data.blurb.present ? data.blurb.value : this.blurb,
      color: data.color.present ? data.color.value : this.color,
      sort: data.sort.present ? data.sort.value : this.sort,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ArchetypeRow(')
          ..write('id: $id, ')
          ..write('key: $key, ')
          ..write('name: $name, ')
          ..write('blurb: $blurb, ')
          ..write('color: $color, ')
          ..write('sort: $sort, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, key, name, blurb, color, sort, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ArchetypeRow &&
          other.id == this.id &&
          other.key == this.key &&
          other.name == this.name &&
          other.blurb == this.blurb &&
          other.color == this.color &&
          other.sort == this.sort &&
          other.updatedAt == this.updatedAt);
}

class ArchetypesCompanion extends UpdateCompanion<ArchetypeRow> {
  final Value<String> id;
  final Value<String> key;
  final Value<String> name;
  final Value<String> blurb;
  final Value<String> color;
  final Value<int> sort;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ArchetypesCompanion({
    this.id = const Value.absent(),
    this.key = const Value.absent(),
    this.name = const Value.absent(),
    this.blurb = const Value.absent(),
    this.color = const Value.absent(),
    this.sort = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ArchetypesCompanion.insert({
    required String id,
    required String key,
    required String name,
    required String blurb,
    required String color,
    required int sort,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       key = Value(key),
       name = Value(name),
       blurb = Value(blurb),
       color = Value(color),
       sort = Value(sort),
       updatedAt = Value(updatedAt);
  static Insertable<ArchetypeRow> custom({
    Expression<String>? id,
    Expression<String>? key,
    Expression<String>? name,
    Expression<String>? blurb,
    Expression<String>? color,
    Expression<int>? sort,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (key != null) 'key': key,
      if (name != null) 'name': name,
      if (blurb != null) 'blurb': blurb,
      if (color != null) 'color': color,
      if (sort != null) 'sort': sort,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ArchetypesCompanion copyWith({
    Value<String>? id,
    Value<String>? key,
    Value<String>? name,
    Value<String>? blurb,
    Value<String>? color,
    Value<int>? sort,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ArchetypesCompanion(
      id: id ?? this.id,
      key: key ?? this.key,
      name: name ?? this.name,
      blurb: blurb ?? this.blurb,
      color: color ?? this.color,
      sort: sort ?? this.sort,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (blurb.present) {
      map['blurb'] = Variable<String>(blurb.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (sort.present) {
      map['sort'] = Variable<int>(sort.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ArchetypesCompanion(')
          ..write('id: $id, ')
          ..write('key: $key, ')
          ..write('name: $name, ')
          ..write('blurb: $blurb, ')
          ..write('color: $color, ')
          ..write('sort: $sort, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PacksTable extends Packs with TableInfo<$PacksTable, PackRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PacksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isCoreMeta = const VerificationMeta('isCore');
  @override
  late final GeneratedColumn<bool> isCore = GeneratedColumn<bool>(
    'is_core',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_core" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _storeProductIdMeta = const VerificationMeta(
    'storeProductId',
  );
  @override
  late final GeneratedColumn<String> storeProductId = GeneratedColumn<String>(
    'store_product_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _coverPathMeta = const VerificationMeta(
    'coverPath',
  );
  @override
  late final GeneratedColumn<String> coverPath = GeneratedColumn<String>(
    'cover_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortMeta = const VerificationMeta('sort');
  @override
  late final GeneratedColumn<int> sort = GeneratedColumn<int>(
    'sort',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    key,
    title,
    description,
    isCore,
    storeProductId,
    coverPath,
    sort,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'packs';
  @override
  VerificationContext validateIntegrity(
    Insertable<PackRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('is_core')) {
      context.handle(
        _isCoreMeta,
        isCore.isAcceptableOrUnknown(data['is_core']!, _isCoreMeta),
      );
    }
    if (data.containsKey('store_product_id')) {
      context.handle(
        _storeProductIdMeta,
        storeProductId.isAcceptableOrUnknown(
          data['store_product_id']!,
          _storeProductIdMeta,
        ),
      );
    }
    if (data.containsKey('cover_path')) {
      context.handle(
        _coverPathMeta,
        coverPath.isAcceptableOrUnknown(data['cover_path']!, _coverPathMeta),
      );
    }
    if (data.containsKey('sort')) {
      context.handle(
        _sortMeta,
        sort.isAcceptableOrUnknown(data['sort']!, _sortMeta),
      );
    } else if (isInserting) {
      context.missing(_sortMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PackRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PackRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      isCore: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_core'],
      )!,
      storeProductId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}store_product_id'],
      ),
      coverPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_path'],
      ),
      sort: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $PacksTable createAlias(String alias) {
    return $PacksTable(attachedDatabase, alias);
  }
}

class PackRow extends DataClass implements Insertable<PackRow> {
  final String id;
  final String key;
  final String title;
  final String description;
  final bool isCore;
  final String? storeProductId;
  final String? coverPath;
  final int sort;
  final DateTime updatedAt;
  const PackRow({
    required this.id,
    required this.key,
    required this.title,
    required this.description,
    required this.isCore,
    this.storeProductId,
    this.coverPath,
    required this.sort,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['key'] = Variable<String>(key);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    map['is_core'] = Variable<bool>(isCore);
    if (!nullToAbsent || storeProductId != null) {
      map['store_product_id'] = Variable<String>(storeProductId);
    }
    if (!nullToAbsent || coverPath != null) {
      map['cover_path'] = Variable<String>(coverPath);
    }
    map['sort'] = Variable<int>(sort);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PacksCompanion toCompanion(bool nullToAbsent) {
    return PacksCompanion(
      id: Value(id),
      key: Value(key),
      title: Value(title),
      description: Value(description),
      isCore: Value(isCore),
      storeProductId: storeProductId == null && nullToAbsent
          ? const Value.absent()
          : Value(storeProductId),
      coverPath: coverPath == null && nullToAbsent
          ? const Value.absent()
          : Value(coverPath),
      sort: Value(sort),
      updatedAt: Value(updatedAt),
    );
  }

  factory PackRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PackRow(
      id: serializer.fromJson<String>(json['id']),
      key: serializer.fromJson<String>(json['key']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      isCore: serializer.fromJson<bool>(json['isCore']),
      storeProductId: serializer.fromJson<String?>(json['storeProductId']),
      coverPath: serializer.fromJson<String?>(json['coverPath']),
      sort: serializer.fromJson<int>(json['sort']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'key': serializer.toJson<String>(key),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'isCore': serializer.toJson<bool>(isCore),
      'storeProductId': serializer.toJson<String?>(storeProductId),
      'coverPath': serializer.toJson<String?>(coverPath),
      'sort': serializer.toJson<int>(sort),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  PackRow copyWith({
    String? id,
    String? key,
    String? title,
    String? description,
    bool? isCore,
    Value<String?> storeProductId = const Value.absent(),
    Value<String?> coverPath = const Value.absent(),
    int? sort,
    DateTime? updatedAt,
  }) => PackRow(
    id: id ?? this.id,
    key: key ?? this.key,
    title: title ?? this.title,
    description: description ?? this.description,
    isCore: isCore ?? this.isCore,
    storeProductId: storeProductId.present
        ? storeProductId.value
        : this.storeProductId,
    coverPath: coverPath.present ? coverPath.value : this.coverPath,
    sort: sort ?? this.sort,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  PackRow copyWithCompanion(PacksCompanion data) {
    return PackRow(
      id: data.id.present ? data.id.value : this.id,
      key: data.key.present ? data.key.value : this.key,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      isCore: data.isCore.present ? data.isCore.value : this.isCore,
      storeProductId: data.storeProductId.present
          ? data.storeProductId.value
          : this.storeProductId,
      coverPath: data.coverPath.present ? data.coverPath.value : this.coverPath,
      sort: data.sort.present ? data.sort.value : this.sort,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PackRow(')
          ..write('id: $id, ')
          ..write('key: $key, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('isCore: $isCore, ')
          ..write('storeProductId: $storeProductId, ')
          ..write('coverPath: $coverPath, ')
          ..write('sort: $sort, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    key,
    title,
    description,
    isCore,
    storeProductId,
    coverPath,
    sort,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PackRow &&
          other.id == this.id &&
          other.key == this.key &&
          other.title == this.title &&
          other.description == this.description &&
          other.isCore == this.isCore &&
          other.storeProductId == this.storeProductId &&
          other.coverPath == this.coverPath &&
          other.sort == this.sort &&
          other.updatedAt == this.updatedAt);
}

class PacksCompanion extends UpdateCompanion<PackRow> {
  final Value<String> id;
  final Value<String> key;
  final Value<String> title;
  final Value<String> description;
  final Value<bool> isCore;
  final Value<String?> storeProductId;
  final Value<String?> coverPath;
  final Value<int> sort;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const PacksCompanion({
    this.id = const Value.absent(),
    this.key = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.isCore = const Value.absent(),
    this.storeProductId = const Value.absent(),
    this.coverPath = const Value.absent(),
    this.sort = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PacksCompanion.insert({
    required String id,
    required String key,
    required String title,
    required String description,
    this.isCore = const Value.absent(),
    this.storeProductId = const Value.absent(),
    this.coverPath = const Value.absent(),
    required int sort,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       key = Value(key),
       title = Value(title),
       description = Value(description),
       sort = Value(sort),
       updatedAt = Value(updatedAt);
  static Insertable<PackRow> custom({
    Expression<String>? id,
    Expression<String>? key,
    Expression<String>? title,
    Expression<String>? description,
    Expression<bool>? isCore,
    Expression<String>? storeProductId,
    Expression<String>? coverPath,
    Expression<int>? sort,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (key != null) 'key': key,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (isCore != null) 'is_core': isCore,
      if (storeProductId != null) 'store_product_id': storeProductId,
      if (coverPath != null) 'cover_path': coverPath,
      if (sort != null) 'sort': sort,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PacksCompanion copyWith({
    Value<String>? id,
    Value<String>? key,
    Value<String>? title,
    Value<String>? description,
    Value<bool>? isCore,
    Value<String?>? storeProductId,
    Value<String?>? coverPath,
    Value<int>? sort,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return PacksCompanion(
      id: id ?? this.id,
      key: key ?? this.key,
      title: title ?? this.title,
      description: description ?? this.description,
      isCore: isCore ?? this.isCore,
      storeProductId: storeProductId ?? this.storeProductId,
      coverPath: coverPath ?? this.coverPath,
      sort: sort ?? this.sort,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (isCore.present) {
      map['is_core'] = Variable<bool>(isCore.value);
    }
    if (storeProductId.present) {
      map['store_product_id'] = Variable<String>(storeProductId.value);
    }
    if (coverPath.present) {
      map['cover_path'] = Variable<String>(coverPath.value);
    }
    if (sort.present) {
      map['sort'] = Variable<int>(sort.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PacksCompanion(')
          ..write('id: $id, ')
          ..write('key: $key, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('isCore: $isCore, ')
          ..write('storeProductId: $storeProductId, ')
          ..write('coverPath: $coverPath, ')
          ..write('sort: $sort, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CampaignsTable extends Campaigns
    with TableInfo<$CampaignsTable, CampaignRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CampaignsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _packIdMeta = const VerificationMeta('packId');
  @override
  late final GeneratedColumn<String> packId = GeneratedColumn<String>(
    'pack_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subtitleMeta = const VerificationMeta(
    'subtitle',
  );
  @override
  late final GeneratedColumn<String> subtitle = GeneratedColumn<String>(
    'subtitle',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _introMdMeta = const VerificationMeta(
    'introMd',
  );
  @override
  late final GeneratedColumn<String> introMd = GeneratedColumn<String>(
    'intro_md',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lengthDaysMeta = const VerificationMeta(
    'lengthDays',
  );
  @override
  late final GeneratedColumn<int> lengthDays = GeneratedColumn<int>(
    'length_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rampDaysMeta = const VerificationMeta(
    'rampDays',
  );
  @override
  late final GeneratedColumn<int> rampDays = GeneratedColumn<int>(
    'ramp_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _difficultyMeta = const VerificationMeta(
    'difficulty',
  );
  @override
  late final GeneratedColumn<int> difficulty = GeneratedColumn<int>(
    'difficulty',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _coverPathMeta = const VerificationMeta(
    'coverPath',
  );
  @override
  late final GeneratedColumn<String> coverPath = GeneratedColumn<String>(
    'cover_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortMeta = const VerificationMeta('sort');
  @override
  late final GeneratedColumn<int> sort = GeneratedColumn<int>(
    'sort',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    packId,
    key,
    title,
    subtitle,
    introMd,
    lengthDays,
    rampDays,
    difficulty,
    coverPath,
    sort,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'campaigns';
  @override
  VerificationContext validateIntegrity(
    Insertable<CampaignRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('pack_id')) {
      context.handle(
        _packIdMeta,
        packId.isAcceptableOrUnknown(data['pack_id']!, _packIdMeta),
      );
    } else if (isInserting) {
      context.missing(_packIdMeta);
    }
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('subtitle')) {
      context.handle(
        _subtitleMeta,
        subtitle.isAcceptableOrUnknown(data['subtitle']!, _subtitleMeta),
      );
    }
    if (data.containsKey('intro_md')) {
      context.handle(
        _introMdMeta,
        introMd.isAcceptableOrUnknown(data['intro_md']!, _introMdMeta),
      );
    } else if (isInserting) {
      context.missing(_introMdMeta);
    }
    if (data.containsKey('length_days')) {
      context.handle(
        _lengthDaysMeta,
        lengthDays.isAcceptableOrUnknown(data['length_days']!, _lengthDaysMeta),
      );
    } else if (isInserting) {
      context.missing(_lengthDaysMeta);
    }
    if (data.containsKey('ramp_days')) {
      context.handle(
        _rampDaysMeta,
        rampDays.isAcceptableOrUnknown(data['ramp_days']!, _rampDaysMeta),
      );
    }
    if (data.containsKey('difficulty')) {
      context.handle(
        _difficultyMeta,
        difficulty.isAcceptableOrUnknown(data['difficulty']!, _difficultyMeta),
      );
    }
    if (data.containsKey('cover_path')) {
      context.handle(
        _coverPathMeta,
        coverPath.isAcceptableOrUnknown(data['cover_path']!, _coverPathMeta),
      );
    }
    if (data.containsKey('sort')) {
      context.handle(
        _sortMeta,
        sort.isAcceptableOrUnknown(data['sort']!, _sortMeta),
      );
    } else if (isInserting) {
      context.missing(_sortMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CampaignRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CampaignRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      packId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pack_id'],
      )!,
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      subtitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subtitle'],
      ),
      introMd: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}intro_md'],
      )!,
      lengthDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}length_days'],
      )!,
      rampDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ramp_days'],
      )!,
      difficulty: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}difficulty'],
      )!,
      coverPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_path'],
      ),
      sort: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CampaignsTable createAlias(String alias) {
    return $CampaignsTable(attachedDatabase, alias);
  }
}

class CampaignRow extends DataClass implements Insertable<CampaignRow> {
  final String id;
  final String packId;
  final String key;
  final String title;
  final String? subtitle;
  final String introMd;
  final int lengthDays;
  final int rampDays;
  final int difficulty;
  final String? coverPath;
  final int sort;
  final DateTime updatedAt;
  const CampaignRow({
    required this.id,
    required this.packId,
    required this.key,
    required this.title,
    this.subtitle,
    required this.introMd,
    required this.lengthDays,
    required this.rampDays,
    required this.difficulty,
    this.coverPath,
    required this.sort,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['pack_id'] = Variable<String>(packId);
    map['key'] = Variable<String>(key);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || subtitle != null) {
      map['subtitle'] = Variable<String>(subtitle);
    }
    map['intro_md'] = Variable<String>(introMd);
    map['length_days'] = Variable<int>(lengthDays);
    map['ramp_days'] = Variable<int>(rampDays);
    map['difficulty'] = Variable<int>(difficulty);
    if (!nullToAbsent || coverPath != null) {
      map['cover_path'] = Variable<String>(coverPath);
    }
    map['sort'] = Variable<int>(sort);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CampaignsCompanion toCompanion(bool nullToAbsent) {
    return CampaignsCompanion(
      id: Value(id),
      packId: Value(packId),
      key: Value(key),
      title: Value(title),
      subtitle: subtitle == null && nullToAbsent
          ? const Value.absent()
          : Value(subtitle),
      introMd: Value(introMd),
      lengthDays: Value(lengthDays),
      rampDays: Value(rampDays),
      difficulty: Value(difficulty),
      coverPath: coverPath == null && nullToAbsent
          ? const Value.absent()
          : Value(coverPath),
      sort: Value(sort),
      updatedAt: Value(updatedAt),
    );
  }

  factory CampaignRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CampaignRow(
      id: serializer.fromJson<String>(json['id']),
      packId: serializer.fromJson<String>(json['packId']),
      key: serializer.fromJson<String>(json['key']),
      title: serializer.fromJson<String>(json['title']),
      subtitle: serializer.fromJson<String?>(json['subtitle']),
      introMd: serializer.fromJson<String>(json['introMd']),
      lengthDays: serializer.fromJson<int>(json['lengthDays']),
      rampDays: serializer.fromJson<int>(json['rampDays']),
      difficulty: serializer.fromJson<int>(json['difficulty']),
      coverPath: serializer.fromJson<String?>(json['coverPath']),
      sort: serializer.fromJson<int>(json['sort']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'packId': serializer.toJson<String>(packId),
      'key': serializer.toJson<String>(key),
      'title': serializer.toJson<String>(title),
      'subtitle': serializer.toJson<String?>(subtitle),
      'introMd': serializer.toJson<String>(introMd),
      'lengthDays': serializer.toJson<int>(lengthDays),
      'rampDays': serializer.toJson<int>(rampDays),
      'difficulty': serializer.toJson<int>(difficulty),
      'coverPath': serializer.toJson<String?>(coverPath),
      'sort': serializer.toJson<int>(sort),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CampaignRow copyWith({
    String? id,
    String? packId,
    String? key,
    String? title,
    Value<String?> subtitle = const Value.absent(),
    String? introMd,
    int? lengthDays,
    int? rampDays,
    int? difficulty,
    Value<String?> coverPath = const Value.absent(),
    int? sort,
    DateTime? updatedAt,
  }) => CampaignRow(
    id: id ?? this.id,
    packId: packId ?? this.packId,
    key: key ?? this.key,
    title: title ?? this.title,
    subtitle: subtitle.present ? subtitle.value : this.subtitle,
    introMd: introMd ?? this.introMd,
    lengthDays: lengthDays ?? this.lengthDays,
    rampDays: rampDays ?? this.rampDays,
    difficulty: difficulty ?? this.difficulty,
    coverPath: coverPath.present ? coverPath.value : this.coverPath,
    sort: sort ?? this.sort,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  CampaignRow copyWithCompanion(CampaignsCompanion data) {
    return CampaignRow(
      id: data.id.present ? data.id.value : this.id,
      packId: data.packId.present ? data.packId.value : this.packId,
      key: data.key.present ? data.key.value : this.key,
      title: data.title.present ? data.title.value : this.title,
      subtitle: data.subtitle.present ? data.subtitle.value : this.subtitle,
      introMd: data.introMd.present ? data.introMd.value : this.introMd,
      lengthDays: data.lengthDays.present
          ? data.lengthDays.value
          : this.lengthDays,
      rampDays: data.rampDays.present ? data.rampDays.value : this.rampDays,
      difficulty: data.difficulty.present
          ? data.difficulty.value
          : this.difficulty,
      coverPath: data.coverPath.present ? data.coverPath.value : this.coverPath,
      sort: data.sort.present ? data.sort.value : this.sort,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CampaignRow(')
          ..write('id: $id, ')
          ..write('packId: $packId, ')
          ..write('key: $key, ')
          ..write('title: $title, ')
          ..write('subtitle: $subtitle, ')
          ..write('introMd: $introMd, ')
          ..write('lengthDays: $lengthDays, ')
          ..write('rampDays: $rampDays, ')
          ..write('difficulty: $difficulty, ')
          ..write('coverPath: $coverPath, ')
          ..write('sort: $sort, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    packId,
    key,
    title,
    subtitle,
    introMd,
    lengthDays,
    rampDays,
    difficulty,
    coverPath,
    sort,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CampaignRow &&
          other.id == this.id &&
          other.packId == this.packId &&
          other.key == this.key &&
          other.title == this.title &&
          other.subtitle == this.subtitle &&
          other.introMd == this.introMd &&
          other.lengthDays == this.lengthDays &&
          other.rampDays == this.rampDays &&
          other.difficulty == this.difficulty &&
          other.coverPath == this.coverPath &&
          other.sort == this.sort &&
          other.updatedAt == this.updatedAt);
}

class CampaignsCompanion extends UpdateCompanion<CampaignRow> {
  final Value<String> id;
  final Value<String> packId;
  final Value<String> key;
  final Value<String> title;
  final Value<String?> subtitle;
  final Value<String> introMd;
  final Value<int> lengthDays;
  final Value<int> rampDays;
  final Value<int> difficulty;
  final Value<String?> coverPath;
  final Value<int> sort;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CampaignsCompanion({
    this.id = const Value.absent(),
    this.packId = const Value.absent(),
    this.key = const Value.absent(),
    this.title = const Value.absent(),
    this.subtitle = const Value.absent(),
    this.introMd = const Value.absent(),
    this.lengthDays = const Value.absent(),
    this.rampDays = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.coverPath = const Value.absent(),
    this.sort = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CampaignsCompanion.insert({
    required String id,
    required String packId,
    required String key,
    required String title,
    this.subtitle = const Value.absent(),
    required String introMd,
    required int lengthDays,
    this.rampDays = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.coverPath = const Value.absent(),
    required int sort,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       packId = Value(packId),
       key = Value(key),
       title = Value(title),
       introMd = Value(introMd),
       lengthDays = Value(lengthDays),
       sort = Value(sort),
       updatedAt = Value(updatedAt);
  static Insertable<CampaignRow> custom({
    Expression<String>? id,
    Expression<String>? packId,
    Expression<String>? key,
    Expression<String>? title,
    Expression<String>? subtitle,
    Expression<String>? introMd,
    Expression<int>? lengthDays,
    Expression<int>? rampDays,
    Expression<int>? difficulty,
    Expression<String>? coverPath,
    Expression<int>? sort,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (packId != null) 'pack_id': packId,
      if (key != null) 'key': key,
      if (title != null) 'title': title,
      if (subtitle != null) 'subtitle': subtitle,
      if (introMd != null) 'intro_md': introMd,
      if (lengthDays != null) 'length_days': lengthDays,
      if (rampDays != null) 'ramp_days': rampDays,
      if (difficulty != null) 'difficulty': difficulty,
      if (coverPath != null) 'cover_path': coverPath,
      if (sort != null) 'sort': sort,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CampaignsCompanion copyWith({
    Value<String>? id,
    Value<String>? packId,
    Value<String>? key,
    Value<String>? title,
    Value<String?>? subtitle,
    Value<String>? introMd,
    Value<int>? lengthDays,
    Value<int>? rampDays,
    Value<int>? difficulty,
    Value<String?>? coverPath,
    Value<int>? sort,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return CampaignsCompanion(
      id: id ?? this.id,
      packId: packId ?? this.packId,
      key: key ?? this.key,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      introMd: introMd ?? this.introMd,
      lengthDays: lengthDays ?? this.lengthDays,
      rampDays: rampDays ?? this.rampDays,
      difficulty: difficulty ?? this.difficulty,
      coverPath: coverPath ?? this.coverPath,
      sort: sort ?? this.sort,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (packId.present) {
      map['pack_id'] = Variable<String>(packId.value);
    }
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (subtitle.present) {
      map['subtitle'] = Variable<String>(subtitle.value);
    }
    if (introMd.present) {
      map['intro_md'] = Variable<String>(introMd.value);
    }
    if (lengthDays.present) {
      map['length_days'] = Variable<int>(lengthDays.value);
    }
    if (rampDays.present) {
      map['ramp_days'] = Variable<int>(rampDays.value);
    }
    if (difficulty.present) {
      map['difficulty'] = Variable<int>(difficulty.value);
    }
    if (coverPath.present) {
      map['cover_path'] = Variable<String>(coverPath.value);
    }
    if (sort.present) {
      map['sort'] = Variable<int>(sort.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CampaignsCompanion(')
          ..write('id: $id, ')
          ..write('packId: $packId, ')
          ..write('key: $key, ')
          ..write('title: $title, ')
          ..write('subtitle: $subtitle, ')
          ..write('introMd: $introMd, ')
          ..write('lengthDays: $lengthDays, ')
          ..write('rampDays: $rampDays, ')
          ..write('difficulty: $difficulty, ')
          ..write('coverPath: $coverPath, ')
          ..write('sort: $sort, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CampaignArchetypesTable extends CampaignArchetypes
    with TableInfo<$CampaignArchetypesTable, CampaignArchetypeRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CampaignArchetypesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _campaignIdMeta = const VerificationMeta(
    'campaignId',
  );
  @override
  late final GeneratedColumn<String> campaignId = GeneratedColumn<String>(
    'campaign_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _archetypeIdMeta = const VerificationMeta(
    'archetypeId',
  );
  @override
  late final GeneratedColumn<String> archetypeId = GeneratedColumn<String>(
    'archetype_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weightMeta = const VerificationMeta('weight');
  @override
  late final GeneratedColumn<double> weight = GeneratedColumn<double>(
    'weight',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    campaignId,
    archetypeId,
    weight,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'campaign_archetypes';
  @override
  VerificationContext validateIntegrity(
    Insertable<CampaignArchetypeRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('campaign_id')) {
      context.handle(
        _campaignIdMeta,
        campaignId.isAcceptableOrUnknown(data['campaign_id']!, _campaignIdMeta),
      );
    } else if (isInserting) {
      context.missing(_campaignIdMeta);
    }
    if (data.containsKey('archetype_id')) {
      context.handle(
        _archetypeIdMeta,
        archetypeId.isAcceptableOrUnknown(
          data['archetype_id']!,
          _archetypeIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_archetypeIdMeta);
    }
    if (data.containsKey('weight')) {
      context.handle(
        _weightMeta,
        weight.isAcceptableOrUnknown(data['weight']!, _weightMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {campaignId, archetypeId};
  @override
  CampaignArchetypeRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CampaignArchetypeRow(
      campaignId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}campaign_id'],
      )!,
      archetypeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}archetype_id'],
      )!,
      weight: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CampaignArchetypesTable createAlias(String alias) {
    return $CampaignArchetypesTable(attachedDatabase, alias);
  }
}

class CampaignArchetypeRow extends DataClass
    implements Insertable<CampaignArchetypeRow> {
  final String campaignId;
  final String archetypeId;
  final double weight;
  final DateTime updatedAt;
  const CampaignArchetypeRow({
    required this.campaignId,
    required this.archetypeId,
    required this.weight,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['campaign_id'] = Variable<String>(campaignId);
    map['archetype_id'] = Variable<String>(archetypeId);
    map['weight'] = Variable<double>(weight);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CampaignArchetypesCompanion toCompanion(bool nullToAbsent) {
    return CampaignArchetypesCompanion(
      campaignId: Value(campaignId),
      archetypeId: Value(archetypeId),
      weight: Value(weight),
      updatedAt: Value(updatedAt),
    );
  }

  factory CampaignArchetypeRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CampaignArchetypeRow(
      campaignId: serializer.fromJson<String>(json['campaignId']),
      archetypeId: serializer.fromJson<String>(json['archetypeId']),
      weight: serializer.fromJson<double>(json['weight']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'campaignId': serializer.toJson<String>(campaignId),
      'archetypeId': serializer.toJson<String>(archetypeId),
      'weight': serializer.toJson<double>(weight),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CampaignArchetypeRow copyWith({
    String? campaignId,
    String? archetypeId,
    double? weight,
    DateTime? updatedAt,
  }) => CampaignArchetypeRow(
    campaignId: campaignId ?? this.campaignId,
    archetypeId: archetypeId ?? this.archetypeId,
    weight: weight ?? this.weight,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  CampaignArchetypeRow copyWithCompanion(CampaignArchetypesCompanion data) {
    return CampaignArchetypeRow(
      campaignId: data.campaignId.present
          ? data.campaignId.value
          : this.campaignId,
      archetypeId: data.archetypeId.present
          ? data.archetypeId.value
          : this.archetypeId,
      weight: data.weight.present ? data.weight.value : this.weight,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CampaignArchetypeRow(')
          ..write('campaignId: $campaignId, ')
          ..write('archetypeId: $archetypeId, ')
          ..write('weight: $weight, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(campaignId, archetypeId, weight, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CampaignArchetypeRow &&
          other.campaignId == this.campaignId &&
          other.archetypeId == this.archetypeId &&
          other.weight == this.weight &&
          other.updatedAt == this.updatedAt);
}

class CampaignArchetypesCompanion
    extends UpdateCompanion<CampaignArchetypeRow> {
  final Value<String> campaignId;
  final Value<String> archetypeId;
  final Value<double> weight;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CampaignArchetypesCompanion({
    this.campaignId = const Value.absent(),
    this.archetypeId = const Value.absent(),
    this.weight = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CampaignArchetypesCompanion.insert({
    required String campaignId,
    required String archetypeId,
    this.weight = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : campaignId = Value(campaignId),
       archetypeId = Value(archetypeId),
       updatedAt = Value(updatedAt);
  static Insertable<CampaignArchetypeRow> custom({
    Expression<String>? campaignId,
    Expression<String>? archetypeId,
    Expression<double>? weight,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (campaignId != null) 'campaign_id': campaignId,
      if (archetypeId != null) 'archetype_id': archetypeId,
      if (weight != null) 'weight': weight,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CampaignArchetypesCompanion copyWith({
    Value<String>? campaignId,
    Value<String>? archetypeId,
    Value<double>? weight,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return CampaignArchetypesCompanion(
      campaignId: campaignId ?? this.campaignId,
      archetypeId: archetypeId ?? this.archetypeId,
      weight: weight ?? this.weight,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (campaignId.present) {
      map['campaign_id'] = Variable<String>(campaignId.value);
    }
    if (archetypeId.present) {
      map['archetype_id'] = Variable<String>(archetypeId.value);
    }
    if (weight.present) {
      map['weight'] = Variable<double>(weight.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CampaignArchetypesCompanion(')
          ..write('campaignId: $campaignId, ')
          ..write('archetypeId: $archetypeId, ')
          ..write('weight: $weight, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ActionsTable extends Actions with TableInfo<$ActionsTable, ActionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ActionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _campaignIdMeta = const VerificationMeta(
    'campaignId',
  );
  @override
  late final GeneratedColumn<String> campaignId = GeneratedColumn<String>(
    'campaign_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dayIndexMeta = const VerificationMeta(
    'dayIndex',
  );
  @override
  late final GeneratedColumn<int> dayIndex = GeneratedColumn<int>(
    'day_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMdMeta = const VerificationMeta('bodyMd');
  @override
  late final GeneratedColumn<String> bodyMd = GeneratedColumn<String>(
    'body_md',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _archetypeIdMeta = const VerificationMeta(
    'archetypeId',
  );
  @override
  late final GeneratedColumn<String> archetypeId = GeneratedColumn<String>(
    'archetype_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _whyDoctrineIdMeta = const VerificationMeta(
    'whyDoctrineId',
  );
  @override
  late final GeneratedColumn<String> whyDoctrineId = GeneratedColumn<String>(
    'why_doctrine_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _effortMeta = const VerificationMeta('effort');
  @override
  late final GeneratedColumn<int> effort = GeneratedColumn<int>(
    'effort',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    campaignId,
    dayIndex,
    title,
    bodyMd,
    archetypeId,
    whyDoctrineId,
    effort,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'actions';
  @override
  VerificationContext validateIntegrity(
    Insertable<ActionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('campaign_id')) {
      context.handle(
        _campaignIdMeta,
        campaignId.isAcceptableOrUnknown(data['campaign_id']!, _campaignIdMeta),
      );
    } else if (isInserting) {
      context.missing(_campaignIdMeta);
    }
    if (data.containsKey('day_index')) {
      context.handle(
        _dayIndexMeta,
        dayIndex.isAcceptableOrUnknown(data['day_index']!, _dayIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_dayIndexMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('body_md')) {
      context.handle(
        _bodyMdMeta,
        bodyMd.isAcceptableOrUnknown(data['body_md']!, _bodyMdMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMdMeta);
    }
    if (data.containsKey('archetype_id')) {
      context.handle(
        _archetypeIdMeta,
        archetypeId.isAcceptableOrUnknown(
          data['archetype_id']!,
          _archetypeIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_archetypeIdMeta);
    }
    if (data.containsKey('why_doctrine_id')) {
      context.handle(
        _whyDoctrineIdMeta,
        whyDoctrineId.isAcceptableOrUnknown(
          data['why_doctrine_id']!,
          _whyDoctrineIdMeta,
        ),
      );
    }
    if (data.containsKey('effort')) {
      context.handle(
        _effortMeta,
        effort.isAcceptableOrUnknown(data['effort']!, _effortMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {campaignId, dayIndex},
  ];
  @override
  ActionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ActionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      campaignId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}campaign_id'],
      )!,
      dayIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}day_index'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      bodyMd: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body_md'],
      )!,
      archetypeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}archetype_id'],
      )!,
      whyDoctrineId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}why_doctrine_id'],
      ),
      effort: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}effort'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ActionsTable createAlias(String alias) {
    return $ActionsTable(attachedDatabase, alias);
  }
}

class ActionRow extends DataClass implements Insertable<ActionRow> {
  final String id;
  final String campaignId;
  final int dayIndex;
  final String title;
  final String bodyMd;

  /// Exactly one archetype per action (ADR-0004). Not nullable.
  final String archetypeId;
  final String? whyDoctrineId;
  final int effort;
  final DateTime updatedAt;
  const ActionRow({
    required this.id,
    required this.campaignId,
    required this.dayIndex,
    required this.title,
    required this.bodyMd,
    required this.archetypeId,
    this.whyDoctrineId,
    required this.effort,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['campaign_id'] = Variable<String>(campaignId);
    map['day_index'] = Variable<int>(dayIndex);
    map['title'] = Variable<String>(title);
    map['body_md'] = Variable<String>(bodyMd);
    map['archetype_id'] = Variable<String>(archetypeId);
    if (!nullToAbsent || whyDoctrineId != null) {
      map['why_doctrine_id'] = Variable<String>(whyDoctrineId);
    }
    map['effort'] = Variable<int>(effort);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ActionsCompanion toCompanion(bool nullToAbsent) {
    return ActionsCompanion(
      id: Value(id),
      campaignId: Value(campaignId),
      dayIndex: Value(dayIndex),
      title: Value(title),
      bodyMd: Value(bodyMd),
      archetypeId: Value(archetypeId),
      whyDoctrineId: whyDoctrineId == null && nullToAbsent
          ? const Value.absent()
          : Value(whyDoctrineId),
      effort: Value(effort),
      updatedAt: Value(updatedAt),
    );
  }

  factory ActionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ActionRow(
      id: serializer.fromJson<String>(json['id']),
      campaignId: serializer.fromJson<String>(json['campaignId']),
      dayIndex: serializer.fromJson<int>(json['dayIndex']),
      title: serializer.fromJson<String>(json['title']),
      bodyMd: serializer.fromJson<String>(json['bodyMd']),
      archetypeId: serializer.fromJson<String>(json['archetypeId']),
      whyDoctrineId: serializer.fromJson<String?>(json['whyDoctrineId']),
      effort: serializer.fromJson<int>(json['effort']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'campaignId': serializer.toJson<String>(campaignId),
      'dayIndex': serializer.toJson<int>(dayIndex),
      'title': serializer.toJson<String>(title),
      'bodyMd': serializer.toJson<String>(bodyMd),
      'archetypeId': serializer.toJson<String>(archetypeId),
      'whyDoctrineId': serializer.toJson<String?>(whyDoctrineId),
      'effort': serializer.toJson<int>(effort),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ActionRow copyWith({
    String? id,
    String? campaignId,
    int? dayIndex,
    String? title,
    String? bodyMd,
    String? archetypeId,
    Value<String?> whyDoctrineId = const Value.absent(),
    int? effort,
    DateTime? updatedAt,
  }) => ActionRow(
    id: id ?? this.id,
    campaignId: campaignId ?? this.campaignId,
    dayIndex: dayIndex ?? this.dayIndex,
    title: title ?? this.title,
    bodyMd: bodyMd ?? this.bodyMd,
    archetypeId: archetypeId ?? this.archetypeId,
    whyDoctrineId: whyDoctrineId.present
        ? whyDoctrineId.value
        : this.whyDoctrineId,
    effort: effort ?? this.effort,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ActionRow copyWithCompanion(ActionsCompanion data) {
    return ActionRow(
      id: data.id.present ? data.id.value : this.id,
      campaignId: data.campaignId.present
          ? data.campaignId.value
          : this.campaignId,
      dayIndex: data.dayIndex.present ? data.dayIndex.value : this.dayIndex,
      title: data.title.present ? data.title.value : this.title,
      bodyMd: data.bodyMd.present ? data.bodyMd.value : this.bodyMd,
      archetypeId: data.archetypeId.present
          ? data.archetypeId.value
          : this.archetypeId,
      whyDoctrineId: data.whyDoctrineId.present
          ? data.whyDoctrineId.value
          : this.whyDoctrineId,
      effort: data.effort.present ? data.effort.value : this.effort,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ActionRow(')
          ..write('id: $id, ')
          ..write('campaignId: $campaignId, ')
          ..write('dayIndex: $dayIndex, ')
          ..write('title: $title, ')
          ..write('bodyMd: $bodyMd, ')
          ..write('archetypeId: $archetypeId, ')
          ..write('whyDoctrineId: $whyDoctrineId, ')
          ..write('effort: $effort, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    campaignId,
    dayIndex,
    title,
    bodyMd,
    archetypeId,
    whyDoctrineId,
    effort,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ActionRow &&
          other.id == this.id &&
          other.campaignId == this.campaignId &&
          other.dayIndex == this.dayIndex &&
          other.title == this.title &&
          other.bodyMd == this.bodyMd &&
          other.archetypeId == this.archetypeId &&
          other.whyDoctrineId == this.whyDoctrineId &&
          other.effort == this.effort &&
          other.updatedAt == this.updatedAt);
}

class ActionsCompanion extends UpdateCompanion<ActionRow> {
  final Value<String> id;
  final Value<String> campaignId;
  final Value<int> dayIndex;
  final Value<String> title;
  final Value<String> bodyMd;
  final Value<String> archetypeId;
  final Value<String?> whyDoctrineId;
  final Value<int> effort;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ActionsCompanion({
    this.id = const Value.absent(),
    this.campaignId = const Value.absent(),
    this.dayIndex = const Value.absent(),
    this.title = const Value.absent(),
    this.bodyMd = const Value.absent(),
    this.archetypeId = const Value.absent(),
    this.whyDoctrineId = const Value.absent(),
    this.effort = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ActionsCompanion.insert({
    required String id,
    required String campaignId,
    required int dayIndex,
    required String title,
    required String bodyMd,
    required String archetypeId,
    this.whyDoctrineId = const Value.absent(),
    this.effort = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       campaignId = Value(campaignId),
       dayIndex = Value(dayIndex),
       title = Value(title),
       bodyMd = Value(bodyMd),
       archetypeId = Value(archetypeId),
       updatedAt = Value(updatedAt);
  static Insertable<ActionRow> custom({
    Expression<String>? id,
    Expression<String>? campaignId,
    Expression<int>? dayIndex,
    Expression<String>? title,
    Expression<String>? bodyMd,
    Expression<String>? archetypeId,
    Expression<String>? whyDoctrineId,
    Expression<int>? effort,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (campaignId != null) 'campaign_id': campaignId,
      if (dayIndex != null) 'day_index': dayIndex,
      if (title != null) 'title': title,
      if (bodyMd != null) 'body_md': bodyMd,
      if (archetypeId != null) 'archetype_id': archetypeId,
      if (whyDoctrineId != null) 'why_doctrine_id': whyDoctrineId,
      if (effort != null) 'effort': effort,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ActionsCompanion copyWith({
    Value<String>? id,
    Value<String>? campaignId,
    Value<int>? dayIndex,
    Value<String>? title,
    Value<String>? bodyMd,
    Value<String>? archetypeId,
    Value<String?>? whyDoctrineId,
    Value<int>? effort,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ActionsCompanion(
      id: id ?? this.id,
      campaignId: campaignId ?? this.campaignId,
      dayIndex: dayIndex ?? this.dayIndex,
      title: title ?? this.title,
      bodyMd: bodyMd ?? this.bodyMd,
      archetypeId: archetypeId ?? this.archetypeId,
      whyDoctrineId: whyDoctrineId ?? this.whyDoctrineId,
      effort: effort ?? this.effort,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (campaignId.present) {
      map['campaign_id'] = Variable<String>(campaignId.value);
    }
    if (dayIndex.present) {
      map['day_index'] = Variable<int>(dayIndex.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (bodyMd.present) {
      map['body_md'] = Variable<String>(bodyMd.value);
    }
    if (archetypeId.present) {
      map['archetype_id'] = Variable<String>(archetypeId.value);
    }
    if (whyDoctrineId.present) {
      map['why_doctrine_id'] = Variable<String>(whyDoctrineId.value);
    }
    if (effort.present) {
      map['effort'] = Variable<int>(effort.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ActionsCompanion(')
          ..write('id: $id, ')
          ..write('campaignId: $campaignId, ')
          ..write('dayIndex: $dayIndex, ')
          ..write('title: $title, ')
          ..write('bodyMd: $bodyMd, ')
          ..write('archetypeId: $archetypeId, ')
          ..write('whyDoctrineId: $whyDoctrineId, ')
          ..write('effort: $effort, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DoctrineGroupsTable extends DoctrineGroups
    with TableInfo<$DoctrineGroupsTable, DoctrineGroupRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DoctrineGroupsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _blurbMeta = const VerificationMeta('blurb');
  @override
  late final GeneratedColumn<String> blurb = GeneratedColumn<String>(
    'blurb',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortMeta = const VerificationMeta('sort');
  @override
  late final GeneratedColumn<int> sort = GeneratedColumn<int>(
    'sort',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, title, blurb, sort, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'doctrine_groups';
  @override
  VerificationContext validateIntegrity(
    Insertable<DoctrineGroupRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('blurb')) {
      context.handle(
        _blurbMeta,
        blurb.isAcceptableOrUnknown(data['blurb']!, _blurbMeta),
      );
    }
    if (data.containsKey('sort')) {
      context.handle(
        _sortMeta,
        sort.isAcceptableOrUnknown(data['sort']!, _sortMeta),
      );
    } else if (isInserting) {
      context.missing(_sortMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DoctrineGroupRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DoctrineGroupRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      blurb: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}blurb'],
      ),
      sort: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $DoctrineGroupsTable createAlias(String alias) {
    return $DoctrineGroupsTable(attachedDatabase, alias);
  }
}

class DoctrineGroupRow extends DataClass
    implements Insertable<DoctrineGroupRow> {
  final String id;
  final String title;
  final String? blurb;
  final int sort;
  final DateTime updatedAt;
  const DoctrineGroupRow({
    required this.id,
    required this.title,
    this.blurb,
    required this.sort,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || blurb != null) {
      map['blurb'] = Variable<String>(blurb);
    }
    map['sort'] = Variable<int>(sort);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  DoctrineGroupsCompanion toCompanion(bool nullToAbsent) {
    return DoctrineGroupsCompanion(
      id: Value(id),
      title: Value(title),
      blurb: blurb == null && nullToAbsent
          ? const Value.absent()
          : Value(blurb),
      sort: Value(sort),
      updatedAt: Value(updatedAt),
    );
  }

  factory DoctrineGroupRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DoctrineGroupRow(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      blurb: serializer.fromJson<String?>(json['blurb']),
      sort: serializer.fromJson<int>(json['sort']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'blurb': serializer.toJson<String?>(blurb),
      'sort': serializer.toJson<int>(sort),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DoctrineGroupRow copyWith({
    String? id,
    String? title,
    Value<String?> blurb = const Value.absent(),
    int? sort,
    DateTime? updatedAt,
  }) => DoctrineGroupRow(
    id: id ?? this.id,
    title: title ?? this.title,
    blurb: blurb.present ? blurb.value : this.blurb,
    sort: sort ?? this.sort,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  DoctrineGroupRow copyWithCompanion(DoctrineGroupsCompanion data) {
    return DoctrineGroupRow(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      blurb: data.blurb.present ? data.blurb.value : this.blurb,
      sort: data.sort.present ? data.sort.value : this.sort,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DoctrineGroupRow(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('blurb: $blurb, ')
          ..write('sort: $sort, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, blurb, sort, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DoctrineGroupRow &&
          other.id == this.id &&
          other.title == this.title &&
          other.blurb == this.blurb &&
          other.sort == this.sort &&
          other.updatedAt == this.updatedAt);
}

class DoctrineGroupsCompanion extends UpdateCompanion<DoctrineGroupRow> {
  final Value<String> id;
  final Value<String> title;
  final Value<String?> blurb;
  final Value<int> sort;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const DoctrineGroupsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.blurb = const Value.absent(),
    this.sort = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DoctrineGroupsCompanion.insert({
    required String id,
    required String title,
    this.blurb = const Value.absent(),
    required int sort,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       sort = Value(sort),
       updatedAt = Value(updatedAt);
  static Insertable<DoctrineGroupRow> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? blurb,
    Expression<int>? sort,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (blurb != null) 'blurb': blurb,
      if (sort != null) 'sort': sort,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DoctrineGroupsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String?>? blurb,
    Value<int>? sort,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return DoctrineGroupsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      blurb: blurb ?? this.blurb,
      sort: sort ?? this.sort,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (blurb.present) {
      map['blurb'] = Variable<String>(blurb.value);
    }
    if (sort.present) {
      map['sort'] = Variable<int>(sort.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DoctrineGroupsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('blurb: $blurb, ')
          ..write('sort: $sort, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DoctrineEntriesTable extends DoctrineEntries
    with TableInfo<$DoctrineEntriesTable, DoctrineEntryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DoctrineEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _groupIdMeta = const VerificationMeta(
    'groupId',
  );
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
    'group_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMdMeta = const VerificationMeta('bodyMd');
  @override
  late final GeneratedColumn<String> bodyMd = GeneratedColumn<String>(
    'body_md',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _relatedArchetypeIdMeta =
      const VerificationMeta('relatedArchetypeId');
  @override
  late final GeneratedColumn<String> relatedArchetypeId =
      GeneratedColumn<String>(
        'related_archetype_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _sortMeta = const VerificationMeta('sort');
  @override
  late final GeneratedColumn<int> sort = GeneratedColumn<int>(
    'sort',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    groupId,
    title,
    bodyMd,
    relatedArchetypeId,
    sort,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'doctrine_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<DoctrineEntryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('group_id')) {
      context.handle(
        _groupIdMeta,
        groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta),
      );
    } else if (isInserting) {
      context.missing(_groupIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('body_md')) {
      context.handle(
        _bodyMdMeta,
        bodyMd.isAcceptableOrUnknown(data['body_md']!, _bodyMdMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMdMeta);
    }
    if (data.containsKey('related_archetype_id')) {
      context.handle(
        _relatedArchetypeIdMeta,
        relatedArchetypeId.isAcceptableOrUnknown(
          data['related_archetype_id']!,
          _relatedArchetypeIdMeta,
        ),
      );
    }
    if (data.containsKey('sort')) {
      context.handle(
        _sortMeta,
        sort.isAcceptableOrUnknown(data['sort']!, _sortMeta),
      );
    } else if (isInserting) {
      context.missing(_sortMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DoctrineEntryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DoctrineEntryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      groupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      bodyMd: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body_md'],
      )!,
      relatedArchetypeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}related_archetype_id'],
      ),
      sort: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $DoctrineEntriesTable createAlias(String alias) {
    return $DoctrineEntriesTable(attachedDatabase, alias);
  }
}

class DoctrineEntryRow extends DataClass
    implements Insertable<DoctrineEntryRow> {
  final String id;
  final String groupId;
  final String title;
  final String bodyMd;
  final String? relatedArchetypeId;
  final int sort;
  final DateTime updatedAt;
  const DoctrineEntryRow({
    required this.id,
    required this.groupId,
    required this.title,
    required this.bodyMd,
    this.relatedArchetypeId,
    required this.sort,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['group_id'] = Variable<String>(groupId);
    map['title'] = Variable<String>(title);
    map['body_md'] = Variable<String>(bodyMd);
    if (!nullToAbsent || relatedArchetypeId != null) {
      map['related_archetype_id'] = Variable<String>(relatedArchetypeId);
    }
    map['sort'] = Variable<int>(sort);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  DoctrineEntriesCompanion toCompanion(bool nullToAbsent) {
    return DoctrineEntriesCompanion(
      id: Value(id),
      groupId: Value(groupId),
      title: Value(title),
      bodyMd: Value(bodyMd),
      relatedArchetypeId: relatedArchetypeId == null && nullToAbsent
          ? const Value.absent()
          : Value(relatedArchetypeId),
      sort: Value(sort),
      updatedAt: Value(updatedAt),
    );
  }

  factory DoctrineEntryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DoctrineEntryRow(
      id: serializer.fromJson<String>(json['id']),
      groupId: serializer.fromJson<String>(json['groupId']),
      title: serializer.fromJson<String>(json['title']),
      bodyMd: serializer.fromJson<String>(json['bodyMd']),
      relatedArchetypeId: serializer.fromJson<String?>(
        json['relatedArchetypeId'],
      ),
      sort: serializer.fromJson<int>(json['sort']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'groupId': serializer.toJson<String>(groupId),
      'title': serializer.toJson<String>(title),
      'bodyMd': serializer.toJson<String>(bodyMd),
      'relatedArchetypeId': serializer.toJson<String?>(relatedArchetypeId),
      'sort': serializer.toJson<int>(sort),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DoctrineEntryRow copyWith({
    String? id,
    String? groupId,
    String? title,
    String? bodyMd,
    Value<String?> relatedArchetypeId = const Value.absent(),
    int? sort,
    DateTime? updatedAt,
  }) => DoctrineEntryRow(
    id: id ?? this.id,
    groupId: groupId ?? this.groupId,
    title: title ?? this.title,
    bodyMd: bodyMd ?? this.bodyMd,
    relatedArchetypeId: relatedArchetypeId.present
        ? relatedArchetypeId.value
        : this.relatedArchetypeId,
    sort: sort ?? this.sort,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  DoctrineEntryRow copyWithCompanion(DoctrineEntriesCompanion data) {
    return DoctrineEntryRow(
      id: data.id.present ? data.id.value : this.id,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      title: data.title.present ? data.title.value : this.title,
      bodyMd: data.bodyMd.present ? data.bodyMd.value : this.bodyMd,
      relatedArchetypeId: data.relatedArchetypeId.present
          ? data.relatedArchetypeId.value
          : this.relatedArchetypeId,
      sort: data.sort.present ? data.sort.value : this.sort,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DoctrineEntryRow(')
          ..write('id: $id, ')
          ..write('groupId: $groupId, ')
          ..write('title: $title, ')
          ..write('bodyMd: $bodyMd, ')
          ..write('relatedArchetypeId: $relatedArchetypeId, ')
          ..write('sort: $sort, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    groupId,
    title,
    bodyMd,
    relatedArchetypeId,
    sort,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DoctrineEntryRow &&
          other.id == this.id &&
          other.groupId == this.groupId &&
          other.title == this.title &&
          other.bodyMd == this.bodyMd &&
          other.relatedArchetypeId == this.relatedArchetypeId &&
          other.sort == this.sort &&
          other.updatedAt == this.updatedAt);
}

class DoctrineEntriesCompanion extends UpdateCompanion<DoctrineEntryRow> {
  final Value<String> id;
  final Value<String> groupId;
  final Value<String> title;
  final Value<String> bodyMd;
  final Value<String?> relatedArchetypeId;
  final Value<int> sort;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const DoctrineEntriesCompanion({
    this.id = const Value.absent(),
    this.groupId = const Value.absent(),
    this.title = const Value.absent(),
    this.bodyMd = const Value.absent(),
    this.relatedArchetypeId = const Value.absent(),
    this.sort = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DoctrineEntriesCompanion.insert({
    required String id,
    required String groupId,
    required String title,
    required String bodyMd,
    this.relatedArchetypeId = const Value.absent(),
    required int sort,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       groupId = Value(groupId),
       title = Value(title),
       bodyMd = Value(bodyMd),
       sort = Value(sort),
       updatedAt = Value(updatedAt);
  static Insertable<DoctrineEntryRow> custom({
    Expression<String>? id,
    Expression<String>? groupId,
    Expression<String>? title,
    Expression<String>? bodyMd,
    Expression<String>? relatedArchetypeId,
    Expression<int>? sort,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (groupId != null) 'group_id': groupId,
      if (title != null) 'title': title,
      if (bodyMd != null) 'body_md': bodyMd,
      if (relatedArchetypeId != null)
        'related_archetype_id': relatedArchetypeId,
      if (sort != null) 'sort': sort,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DoctrineEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? groupId,
    Value<String>? title,
    Value<String>? bodyMd,
    Value<String?>? relatedArchetypeId,
    Value<int>? sort,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return DoctrineEntriesCompanion(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      title: title ?? this.title,
      bodyMd: bodyMd ?? this.bodyMd,
      relatedArchetypeId: relatedArchetypeId ?? this.relatedArchetypeId,
      sort: sort ?? this.sort,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (bodyMd.present) {
      map['body_md'] = Variable<String>(bodyMd.value);
    }
    if (relatedArchetypeId.present) {
      map['related_archetype_id'] = Variable<String>(relatedArchetypeId.value);
    }
    if (sort.present) {
      map['sort'] = Variable<int>(sort.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DoctrineEntriesCompanion(')
          ..write('id: $id, ')
          ..write('groupId: $groupId, ')
          ..write('title: $title, ')
          ..write('bodyMd: $bodyMd, ')
          ..write('relatedArchetypeId: $relatedArchetypeId, ')
          ..write('sort: $sort, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DiagnosticQuestionsTable extends DiagnosticQuestions
    with TableInfo<$DiagnosticQuestionsTable, DiagnosticQuestionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DiagnosticQuestionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _promptMeta = const VerificationMeta('prompt');
  @override
  late final GeneratedColumn<String> prompt = GeneratedColumn<String>(
    'prompt',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortMeta = const VerificationMeta('sort');
  @override
  late final GeneratedColumn<int> sort = GeneratedColumn<int>(
    'sort',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, prompt, sort, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'diagnostic_questions';
  @override
  VerificationContext validateIntegrity(
    Insertable<DiagnosticQuestionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('prompt')) {
      context.handle(
        _promptMeta,
        prompt.isAcceptableOrUnknown(data['prompt']!, _promptMeta),
      );
    } else if (isInserting) {
      context.missing(_promptMeta);
    }
    if (data.containsKey('sort')) {
      context.handle(
        _sortMeta,
        sort.isAcceptableOrUnknown(data['sort']!, _sortMeta),
      );
    } else if (isInserting) {
      context.missing(_sortMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DiagnosticQuestionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DiagnosticQuestionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      prompt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prompt'],
      )!,
      sort: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $DiagnosticQuestionsTable createAlias(String alias) {
    return $DiagnosticQuestionsTable(attachedDatabase, alias);
  }
}

class DiagnosticQuestionRow extends DataClass
    implements Insertable<DiagnosticQuestionRow> {
  final String id;
  final String prompt;
  final int sort;
  final DateTime updatedAt;
  const DiagnosticQuestionRow({
    required this.id,
    required this.prompt,
    required this.sort,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['prompt'] = Variable<String>(prompt);
    map['sort'] = Variable<int>(sort);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  DiagnosticQuestionsCompanion toCompanion(bool nullToAbsent) {
    return DiagnosticQuestionsCompanion(
      id: Value(id),
      prompt: Value(prompt),
      sort: Value(sort),
      updatedAt: Value(updatedAt),
    );
  }

  factory DiagnosticQuestionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DiagnosticQuestionRow(
      id: serializer.fromJson<String>(json['id']),
      prompt: serializer.fromJson<String>(json['prompt']),
      sort: serializer.fromJson<int>(json['sort']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'prompt': serializer.toJson<String>(prompt),
      'sort': serializer.toJson<int>(sort),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DiagnosticQuestionRow copyWith({
    String? id,
    String? prompt,
    int? sort,
    DateTime? updatedAt,
  }) => DiagnosticQuestionRow(
    id: id ?? this.id,
    prompt: prompt ?? this.prompt,
    sort: sort ?? this.sort,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  DiagnosticQuestionRow copyWithCompanion(DiagnosticQuestionsCompanion data) {
    return DiagnosticQuestionRow(
      id: data.id.present ? data.id.value : this.id,
      prompt: data.prompt.present ? data.prompt.value : this.prompt,
      sort: data.sort.present ? data.sort.value : this.sort,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DiagnosticQuestionRow(')
          ..write('id: $id, ')
          ..write('prompt: $prompt, ')
          ..write('sort: $sort, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, prompt, sort, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DiagnosticQuestionRow &&
          other.id == this.id &&
          other.prompt == this.prompt &&
          other.sort == this.sort &&
          other.updatedAt == this.updatedAt);
}

class DiagnosticQuestionsCompanion
    extends UpdateCompanion<DiagnosticQuestionRow> {
  final Value<String> id;
  final Value<String> prompt;
  final Value<int> sort;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const DiagnosticQuestionsCompanion({
    this.id = const Value.absent(),
    this.prompt = const Value.absent(),
    this.sort = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DiagnosticQuestionsCompanion.insert({
    required String id,
    required String prompt,
    required int sort,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       prompt = Value(prompt),
       sort = Value(sort),
       updatedAt = Value(updatedAt);
  static Insertable<DiagnosticQuestionRow> custom({
    Expression<String>? id,
    Expression<String>? prompt,
    Expression<int>? sort,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (prompt != null) 'prompt': prompt,
      if (sort != null) 'sort': sort,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DiagnosticQuestionsCompanion copyWith({
    Value<String>? id,
    Value<String>? prompt,
    Value<int>? sort,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return DiagnosticQuestionsCompanion(
      id: id ?? this.id,
      prompt: prompt ?? this.prompt,
      sort: sort ?? this.sort,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (prompt.present) {
      map['prompt'] = Variable<String>(prompt.value);
    }
    if (sort.present) {
      map['sort'] = Variable<int>(sort.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DiagnosticQuestionsCompanion(')
          ..write('id: $id, ')
          ..write('prompt: $prompt, ')
          ..write('sort: $sort, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DiagnosticOptionsTable extends DiagnosticOptions
    with TableInfo<$DiagnosticOptionsTable, DiagnosticOptionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DiagnosticOptionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _questionIdMeta = const VerificationMeta(
    'questionId',
  );
  @override
  late final GeneratedColumn<String> questionId = GeneratedColumn<String>(
    'question_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _archetypeIdMeta = const VerificationMeta(
    'archetypeId',
  );
  @override
  late final GeneratedColumn<String> archetypeId = GeneratedColumn<String>(
    'archetype_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortMeta = const VerificationMeta('sort');
  @override
  late final GeneratedColumn<int> sort = GeneratedColumn<int>(
    'sort',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    questionId,
    label,
    archetypeId,
    sort,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'diagnostic_options';
  @override
  VerificationContext validateIntegrity(
    Insertable<DiagnosticOptionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('question_id')) {
      context.handle(
        _questionIdMeta,
        questionId.isAcceptableOrUnknown(data['question_id']!, _questionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_questionIdMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('archetype_id')) {
      context.handle(
        _archetypeIdMeta,
        archetypeId.isAcceptableOrUnknown(
          data['archetype_id']!,
          _archetypeIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_archetypeIdMeta);
    }
    if (data.containsKey('sort')) {
      context.handle(
        _sortMeta,
        sort.isAcceptableOrUnknown(data['sort']!, _sortMeta),
      );
    } else if (isInserting) {
      context.missing(_sortMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {questionId, sort},
  ];
  @override
  DiagnosticOptionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DiagnosticOptionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      questionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}question_id'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      archetypeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}archetype_id'],
      )!,
      sort: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $DiagnosticOptionsTable createAlias(String alias) {
    return $DiagnosticOptionsTable(attachedDatabase, alias);
  }
}

class DiagnosticOptionRow extends DataClass
    implements Insertable<DiagnosticOptionRow> {
  final String id;
  final String questionId;
  final String label;
  final String archetypeId;
  final int sort;
  final DateTime updatedAt;
  const DiagnosticOptionRow({
    required this.id,
    required this.questionId,
    required this.label,
    required this.archetypeId,
    required this.sort,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['question_id'] = Variable<String>(questionId);
    map['label'] = Variable<String>(label);
    map['archetype_id'] = Variable<String>(archetypeId);
    map['sort'] = Variable<int>(sort);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  DiagnosticOptionsCompanion toCompanion(bool nullToAbsent) {
    return DiagnosticOptionsCompanion(
      id: Value(id),
      questionId: Value(questionId),
      label: Value(label),
      archetypeId: Value(archetypeId),
      sort: Value(sort),
      updatedAt: Value(updatedAt),
    );
  }

  factory DiagnosticOptionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DiagnosticOptionRow(
      id: serializer.fromJson<String>(json['id']),
      questionId: serializer.fromJson<String>(json['questionId']),
      label: serializer.fromJson<String>(json['label']),
      archetypeId: serializer.fromJson<String>(json['archetypeId']),
      sort: serializer.fromJson<int>(json['sort']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'questionId': serializer.toJson<String>(questionId),
      'label': serializer.toJson<String>(label),
      'archetypeId': serializer.toJson<String>(archetypeId),
      'sort': serializer.toJson<int>(sort),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DiagnosticOptionRow copyWith({
    String? id,
    String? questionId,
    String? label,
    String? archetypeId,
    int? sort,
    DateTime? updatedAt,
  }) => DiagnosticOptionRow(
    id: id ?? this.id,
    questionId: questionId ?? this.questionId,
    label: label ?? this.label,
    archetypeId: archetypeId ?? this.archetypeId,
    sort: sort ?? this.sort,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  DiagnosticOptionRow copyWithCompanion(DiagnosticOptionsCompanion data) {
    return DiagnosticOptionRow(
      id: data.id.present ? data.id.value : this.id,
      questionId: data.questionId.present
          ? data.questionId.value
          : this.questionId,
      label: data.label.present ? data.label.value : this.label,
      archetypeId: data.archetypeId.present
          ? data.archetypeId.value
          : this.archetypeId,
      sort: data.sort.present ? data.sort.value : this.sort,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DiagnosticOptionRow(')
          ..write('id: $id, ')
          ..write('questionId: $questionId, ')
          ..write('label: $label, ')
          ..write('archetypeId: $archetypeId, ')
          ..write('sort: $sort, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, questionId, label, archetypeId, sort, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DiagnosticOptionRow &&
          other.id == this.id &&
          other.questionId == this.questionId &&
          other.label == this.label &&
          other.archetypeId == this.archetypeId &&
          other.sort == this.sort &&
          other.updatedAt == this.updatedAt);
}

class DiagnosticOptionsCompanion extends UpdateCompanion<DiagnosticOptionRow> {
  final Value<String> id;
  final Value<String> questionId;
  final Value<String> label;
  final Value<String> archetypeId;
  final Value<int> sort;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const DiagnosticOptionsCompanion({
    this.id = const Value.absent(),
    this.questionId = const Value.absent(),
    this.label = const Value.absent(),
    this.archetypeId = const Value.absent(),
    this.sort = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DiagnosticOptionsCompanion.insert({
    required String id,
    required String questionId,
    required String label,
    required String archetypeId,
    required int sort,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       questionId = Value(questionId),
       label = Value(label),
       archetypeId = Value(archetypeId),
       sort = Value(sort),
       updatedAt = Value(updatedAt);
  static Insertable<DiagnosticOptionRow> custom({
    Expression<String>? id,
    Expression<String>? questionId,
    Expression<String>? label,
    Expression<String>? archetypeId,
    Expression<int>? sort,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (questionId != null) 'question_id': questionId,
      if (label != null) 'label': label,
      if (archetypeId != null) 'archetype_id': archetypeId,
      if (sort != null) 'sort': sort,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DiagnosticOptionsCompanion copyWith({
    Value<String>? id,
    Value<String>? questionId,
    Value<String>? label,
    Value<String>? archetypeId,
    Value<int>? sort,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return DiagnosticOptionsCompanion(
      id: id ?? this.id,
      questionId: questionId ?? this.questionId,
      label: label ?? this.label,
      archetypeId: archetypeId ?? this.archetypeId,
      sort: sort ?? this.sort,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (questionId.present) {
      map['question_id'] = Variable<String>(questionId.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (archetypeId.present) {
      map['archetype_id'] = Variable<String>(archetypeId.value);
    }
    if (sort.present) {
      map['sort'] = Variable<int>(sort.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DiagnosticOptionsCompanion(')
          ..write('id: $id, ')
          ..write('questionId: $questionId, ')
          ..write('label: $label, ')
          ..write('archetypeId: $archetypeId, ')
          ..write('sort: $sort, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProfilesTable extends Profiles
    with TableInfo<$ProfilesTable, ProfileRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
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
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _onboardedAtMeta = const VerificationMeta(
    'onboardedAt',
  );
  @override
  late final GeneratedColumn<DateTime> onboardedAt = GeneratedColumn<DateTime>(
    'onboarded_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dirtyMeta = const VerificationMeta('dirty');
  @override
  late final GeneratedColumn<bool> dirty = GeneratedColumn<bool>(
    'dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    userId,
    displayName,
    onboardedAt,
    updatedAt,
    dirty,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProfileRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    }
    if (data.containsKey('onboarded_at')) {
      context.handle(
        _onboardedAtMeta,
        onboardedAt.isAcceptableOrUnknown(
          data['onboarded_at']!,
          _onboardedAtMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('dirty')) {
      context.handle(
        _dirtyMeta,
        dirty.isAcceptableOrUnknown(data['dirty']!, _dirtyMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId};
  @override
  ProfileRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProfileRow(
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      ),
      onboardedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}onboarded_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      dirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}dirty'],
      )!,
    );
  }

  @override
  $ProfilesTable createAlias(String alias) {
    return $ProfilesTable(attachedDatabase, alias);
  }
}

class ProfileRow extends DataClass implements Insertable<ProfileRow> {
  final String userId;
  final String? displayName;
  final DateTime? onboardedAt;
  final DateTime updatedAt;
  final bool dirty;
  const ProfileRow({
    required this.userId,
    this.displayName,
    this.onboardedAt,
    required this.updatedAt,
    required this.dirty,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    if (!nullToAbsent || displayName != null) {
      map['display_name'] = Variable<String>(displayName);
    }
    if (!nullToAbsent || onboardedAt != null) {
      map['onboarded_at'] = Variable<DateTime>(onboardedAt);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['dirty'] = Variable<bool>(dirty);
    return map;
  }

  ProfilesCompanion toCompanion(bool nullToAbsent) {
    return ProfilesCompanion(
      userId: Value(userId),
      displayName: displayName == null && nullToAbsent
          ? const Value.absent()
          : Value(displayName),
      onboardedAt: onboardedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(onboardedAt),
      updatedAt: Value(updatedAt),
      dirty: Value(dirty),
    );
  }

  factory ProfileRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProfileRow(
      userId: serializer.fromJson<String>(json['userId']),
      displayName: serializer.fromJson<String?>(json['displayName']),
      onboardedAt: serializer.fromJson<DateTime?>(json['onboardedAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      dirty: serializer.fromJson<bool>(json['dirty']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'displayName': serializer.toJson<String?>(displayName),
      'onboardedAt': serializer.toJson<DateTime?>(onboardedAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'dirty': serializer.toJson<bool>(dirty),
    };
  }

  ProfileRow copyWith({
    String? userId,
    Value<String?> displayName = const Value.absent(),
    Value<DateTime?> onboardedAt = const Value.absent(),
    DateTime? updatedAt,
    bool? dirty,
  }) => ProfileRow(
    userId: userId ?? this.userId,
    displayName: displayName.present ? displayName.value : this.displayName,
    onboardedAt: onboardedAt.present ? onboardedAt.value : this.onboardedAt,
    updatedAt: updatedAt ?? this.updatedAt,
    dirty: dirty ?? this.dirty,
  );
  ProfileRow copyWithCompanion(ProfilesCompanion data) {
    return ProfileRow(
      userId: data.userId.present ? data.userId.value : this.userId,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      onboardedAt: data.onboardedAt.present
          ? data.onboardedAt.value
          : this.onboardedAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProfileRow(')
          ..write('userId: $userId, ')
          ..write('displayName: $displayName, ')
          ..write('onboardedAt: $onboardedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('dirty: $dirty')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(userId, displayName, onboardedAt, updatedAt, dirty);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProfileRow &&
          other.userId == this.userId &&
          other.displayName == this.displayName &&
          other.onboardedAt == this.onboardedAt &&
          other.updatedAt == this.updatedAt &&
          other.dirty == this.dirty);
}

class ProfilesCompanion extends UpdateCompanion<ProfileRow> {
  final Value<String> userId;
  final Value<String?> displayName;
  final Value<DateTime?> onboardedAt;
  final Value<DateTime> updatedAt;
  final Value<bool> dirty;
  final Value<int> rowid;
  const ProfilesCompanion({
    this.userId = const Value.absent(),
    this.displayName = const Value.absent(),
    this.onboardedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.dirty = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProfilesCompanion.insert({
    required String userId,
    this.displayName = const Value.absent(),
    this.onboardedAt = const Value.absent(),
    required DateTime updatedAt,
    this.dirty = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : userId = Value(userId),
       updatedAt = Value(updatedAt);
  static Insertable<ProfileRow> custom({
    Expression<String>? userId,
    Expression<String>? displayName,
    Expression<DateTime>? onboardedAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? dirty,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (displayName != null) 'display_name': displayName,
      if (onboardedAt != null) 'onboarded_at': onboardedAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (dirty != null) 'dirty': dirty,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProfilesCompanion copyWith({
    Value<String>? userId,
    Value<String?>? displayName,
    Value<DateTime?>? onboardedAt,
    Value<DateTime>? updatedAt,
    Value<bool>? dirty,
    Value<int>? rowid,
  }) {
    return ProfilesCompanion(
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      onboardedAt: onboardedAt ?? this.onboardedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      dirty: dirty ?? this.dirty,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (onboardedAt.present) {
      map['onboarded_at'] = Variable<DateTime>(onboardedAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<bool>(dirty.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfilesCompanion(')
          ..write('userId: $userId, ')
          ..write('displayName: $displayName, ')
          ..write('onboardedAt: $onboardedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('dirty: $dirty, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CampaignRunsTable extends CampaignRuns
    with TableInfo<$CampaignRunsTable, CampaignRunRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CampaignRunsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _campaignIdMeta = const VerificationMeta(
    'campaignId',
  );
  @override
  late final GeneratedColumn<String> campaignId = GeneratedColumn<String>(
    'campaign_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isHardenedMeta = const VerificationMeta(
    'isHardened',
  );
  @override
  late final GeneratedColumn<bool> isHardened = GeneratedColumn<bool>(
    'is_hardened',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_hardened" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gradeMeta = const VerificationMeta('grade');
  @override
  late final GeneratedColumn<String> grade = GeneratedColumn<String>(
    'grade',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dirtyMeta = const VerificationMeta('dirty');
  @override
  late final GeneratedColumn<bool> dirty = GeneratedColumn<bool>(
    'dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    campaignId,
    status,
    isHardened,
    startedAt,
    completedAt,
    grade,
    updatedAt,
    dirty,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'campaign_runs';
  @override
  VerificationContext validateIntegrity(
    Insertable<CampaignRunRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('campaign_id')) {
      context.handle(
        _campaignIdMeta,
        campaignId.isAcceptableOrUnknown(data['campaign_id']!, _campaignIdMeta),
      );
    } else if (isInserting) {
      context.missing(_campaignIdMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('is_hardened')) {
      context.handle(
        _isHardenedMeta,
        isHardened.isAcceptableOrUnknown(data['is_hardened']!, _isHardenedMeta),
      );
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('grade')) {
      context.handle(
        _gradeMeta,
        grade.isAcceptableOrUnknown(data['grade']!, _gradeMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('dirty')) {
      context.handle(
        _dirtyMeta,
        dirty.isAcceptableOrUnknown(data['dirty']!, _dirtyMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CampaignRunRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CampaignRunRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      campaignId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}campaign_id'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      isHardened: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_hardened'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
      grade: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}grade'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      dirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}dirty'],
      )!,
    );
  }

  @override
  $CampaignRunsTable createAlias(String alias) {
    return $CampaignRunsTable(attachedDatabase, alias);
  }
}

class CampaignRunRow extends DataClass implements Insertable<CampaignRunRow> {
  final String id;
  final String userId;
  final String campaignId;
  final String status;
  final bool isHardened;
  final DateTime startedAt;
  final DateTime? completedAt;

  /// Materialized once at completion only. Null while the run is active.
  final String? grade;
  final DateTime updatedAt;

  /// Written locally and not yet pushed. The push worker is Plan 3.
  final bool dirty;
  const CampaignRunRow({
    required this.id,
    required this.userId,
    required this.campaignId,
    required this.status,
    required this.isHardened,
    required this.startedAt,
    this.completedAt,
    this.grade,
    required this.updatedAt,
    required this.dirty,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['campaign_id'] = Variable<String>(campaignId);
    map['status'] = Variable<String>(status);
    map['is_hardened'] = Variable<bool>(isHardened);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    if (!nullToAbsent || grade != null) {
      map['grade'] = Variable<String>(grade);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['dirty'] = Variable<bool>(dirty);
    return map;
  }

  CampaignRunsCompanion toCompanion(bool nullToAbsent) {
    return CampaignRunsCompanion(
      id: Value(id),
      userId: Value(userId),
      campaignId: Value(campaignId),
      status: Value(status),
      isHardened: Value(isHardened),
      startedAt: Value(startedAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      grade: grade == null && nullToAbsent
          ? const Value.absent()
          : Value(grade),
      updatedAt: Value(updatedAt),
      dirty: Value(dirty),
    );
  }

  factory CampaignRunRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CampaignRunRow(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      campaignId: serializer.fromJson<String>(json['campaignId']),
      status: serializer.fromJson<String>(json['status']),
      isHardened: serializer.fromJson<bool>(json['isHardened']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      grade: serializer.fromJson<String?>(json['grade']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      dirty: serializer.fromJson<bool>(json['dirty']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'campaignId': serializer.toJson<String>(campaignId),
      'status': serializer.toJson<String>(status),
      'isHardened': serializer.toJson<bool>(isHardened),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'grade': serializer.toJson<String?>(grade),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'dirty': serializer.toJson<bool>(dirty),
    };
  }

  CampaignRunRow copyWith({
    String? id,
    String? userId,
    String? campaignId,
    String? status,
    bool? isHardened,
    DateTime? startedAt,
    Value<DateTime?> completedAt = const Value.absent(),
    Value<String?> grade = const Value.absent(),
    DateTime? updatedAt,
    bool? dirty,
  }) => CampaignRunRow(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    campaignId: campaignId ?? this.campaignId,
    status: status ?? this.status,
    isHardened: isHardened ?? this.isHardened,
    startedAt: startedAt ?? this.startedAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    grade: grade.present ? grade.value : this.grade,
    updatedAt: updatedAt ?? this.updatedAt,
    dirty: dirty ?? this.dirty,
  );
  CampaignRunRow copyWithCompanion(CampaignRunsCompanion data) {
    return CampaignRunRow(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      campaignId: data.campaignId.present
          ? data.campaignId.value
          : this.campaignId,
      status: data.status.present ? data.status.value : this.status,
      isHardened: data.isHardened.present
          ? data.isHardened.value
          : this.isHardened,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      grade: data.grade.present ? data.grade.value : this.grade,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CampaignRunRow(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('campaignId: $campaignId, ')
          ..write('status: $status, ')
          ..write('isHardened: $isHardened, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('grade: $grade, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('dirty: $dirty')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    campaignId,
    status,
    isHardened,
    startedAt,
    completedAt,
    grade,
    updatedAt,
    dirty,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CampaignRunRow &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.campaignId == this.campaignId &&
          other.status == this.status &&
          other.isHardened == this.isHardened &&
          other.startedAt == this.startedAt &&
          other.completedAt == this.completedAt &&
          other.grade == this.grade &&
          other.updatedAt == this.updatedAt &&
          other.dirty == this.dirty);
}

class CampaignRunsCompanion extends UpdateCompanion<CampaignRunRow> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> campaignId;
  final Value<String> status;
  final Value<bool> isHardened;
  final Value<DateTime> startedAt;
  final Value<DateTime?> completedAt;
  final Value<String?> grade;
  final Value<DateTime> updatedAt;
  final Value<bool> dirty;
  final Value<int> rowid;
  const CampaignRunsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.campaignId = const Value.absent(),
    this.status = const Value.absent(),
    this.isHardened = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.grade = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.dirty = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CampaignRunsCompanion.insert({
    required String id,
    required String userId,
    required String campaignId,
    required String status,
    this.isHardened = const Value.absent(),
    required DateTime startedAt,
    this.completedAt = const Value.absent(),
    this.grade = const Value.absent(),
    required DateTime updatedAt,
    this.dirty = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       campaignId = Value(campaignId),
       status = Value(status),
       startedAt = Value(startedAt),
       updatedAt = Value(updatedAt);
  static Insertable<CampaignRunRow> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? campaignId,
    Expression<String>? status,
    Expression<bool>? isHardened,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? completedAt,
    Expression<String>? grade,
    Expression<DateTime>? updatedAt,
    Expression<bool>? dirty,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (campaignId != null) 'campaign_id': campaignId,
      if (status != null) 'status': status,
      if (isHardened != null) 'is_hardened': isHardened,
      if (startedAt != null) 'started_at': startedAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (grade != null) 'grade': grade,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (dirty != null) 'dirty': dirty,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CampaignRunsCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? campaignId,
    Value<String>? status,
    Value<bool>? isHardened,
    Value<DateTime>? startedAt,
    Value<DateTime?>? completedAt,
    Value<String?>? grade,
    Value<DateTime>? updatedAt,
    Value<bool>? dirty,
    Value<int>? rowid,
  }) {
    return CampaignRunsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      campaignId: campaignId ?? this.campaignId,
      status: status ?? this.status,
      isHardened: isHardened ?? this.isHardened,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      grade: grade ?? this.grade,
      updatedAt: updatedAt ?? this.updatedAt,
      dirty: dirty ?? this.dirty,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (campaignId.present) {
      map['campaign_id'] = Variable<String>(campaignId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (isHardened.present) {
      map['is_hardened'] = Variable<bool>(isHardened.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (grade.present) {
      map['grade'] = Variable<String>(grade.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<bool>(dirty.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CampaignRunsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('campaignId: $campaignId, ')
          ..write('status: $status, ')
          ..write('isHardened: $isHardened, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('grade: $grade, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('dirty: $dirty, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DayLogsTable extends DayLogs with TableInfo<$DayLogsTable, DayLogRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DayLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _runIdMeta = const VerificationMeta('runId');
  @override
  late final GeneratedColumn<String> runId = GeneratedColumn<String>(
    'run_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dayIndexMeta = const VerificationMeta(
    'dayIndex',
  );
  @override
  late final GeneratedColumn<int> dayIndex = GeneratedColumn<int>(
    'day_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actionIdMeta = const VerificationMeta(
    'actionId',
  );
  @override
  late final GeneratedColumn<String> actionId = GeneratedColumn<String>(
    'action_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _committedAtMeta = const VerificationMeta(
    'committedAt',
  );
  @override
  late final GeneratedColumn<DateTime> committedAt = GeneratedColumn<DateTime>(
    'committed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _outcomeMeta = const VerificationMeta(
    'outcome',
  );
  @override
  late final GeneratedColumn<String> outcome = GeneratedColumn<String>(
    'outcome',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dirtyMeta = const VerificationMeta('dirty');
  @override
  late final GeneratedColumn<bool> dirty = GeneratedColumn<bool>(
    'dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    runId,
    dayIndex,
    actionId,
    committedAt,
    outcome,
    note,
    updatedAt,
    dirty,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'day_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<DayLogRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('run_id')) {
      context.handle(
        _runIdMeta,
        runId.isAcceptableOrUnknown(data['run_id']!, _runIdMeta),
      );
    } else if (isInserting) {
      context.missing(_runIdMeta);
    }
    if (data.containsKey('day_index')) {
      context.handle(
        _dayIndexMeta,
        dayIndex.isAcceptableOrUnknown(data['day_index']!, _dayIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_dayIndexMeta);
    }
    if (data.containsKey('action_id')) {
      context.handle(
        _actionIdMeta,
        actionId.isAcceptableOrUnknown(data['action_id']!, _actionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_actionIdMeta);
    }
    if (data.containsKey('committed_at')) {
      context.handle(
        _committedAtMeta,
        committedAt.isAcceptableOrUnknown(
          data['committed_at']!,
          _committedAtMeta,
        ),
      );
    }
    if (data.containsKey('outcome')) {
      context.handle(
        _outcomeMeta,
        outcome.isAcceptableOrUnknown(data['outcome']!, _outcomeMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('dirty')) {
      context.handle(
        _dirtyMeta,
        dirty.isAcceptableOrUnknown(data['dirty']!, _dirtyMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {runId, dayIndex},
  ];
  @override
  DayLogRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DayLogRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      runId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}run_id'],
      )!,
      dayIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}day_index'],
      )!,
      actionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action_id'],
      )!,
      committedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}committed_at'],
      ),
      outcome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}outcome'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      dirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}dirty'],
      )!,
    );
  }

  @override
  $DayLogsTable createAlias(String alias) {
    return $DayLogsTable(attachedDatabase, alias);
  }
}

class DayLogRow extends DataClass implements Insertable<DayLogRow> {
  final String id;
  final String userId;
  final String runId;
  final int dayIndex;
  final String actionId;
  final DateTime? committedAt;
  final String? outcome;
  final String? note;
  final DateTime updatedAt;
  final bool dirty;
  const DayLogRow({
    required this.id,
    required this.userId,
    required this.runId,
    required this.dayIndex,
    required this.actionId,
    this.committedAt,
    this.outcome,
    this.note,
    required this.updatedAt,
    required this.dirty,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['run_id'] = Variable<String>(runId);
    map['day_index'] = Variable<int>(dayIndex);
    map['action_id'] = Variable<String>(actionId);
    if (!nullToAbsent || committedAt != null) {
      map['committed_at'] = Variable<DateTime>(committedAt);
    }
    if (!nullToAbsent || outcome != null) {
      map['outcome'] = Variable<String>(outcome);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['dirty'] = Variable<bool>(dirty);
    return map;
  }

  DayLogsCompanion toCompanion(bool nullToAbsent) {
    return DayLogsCompanion(
      id: Value(id),
      userId: Value(userId),
      runId: Value(runId),
      dayIndex: Value(dayIndex),
      actionId: Value(actionId),
      committedAt: committedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(committedAt),
      outcome: outcome == null && nullToAbsent
          ? const Value.absent()
          : Value(outcome),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      updatedAt: Value(updatedAt),
      dirty: Value(dirty),
    );
  }

  factory DayLogRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DayLogRow(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      runId: serializer.fromJson<String>(json['runId']),
      dayIndex: serializer.fromJson<int>(json['dayIndex']),
      actionId: serializer.fromJson<String>(json['actionId']),
      committedAt: serializer.fromJson<DateTime?>(json['committedAt']),
      outcome: serializer.fromJson<String?>(json['outcome']),
      note: serializer.fromJson<String?>(json['note']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      dirty: serializer.fromJson<bool>(json['dirty']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'runId': serializer.toJson<String>(runId),
      'dayIndex': serializer.toJson<int>(dayIndex),
      'actionId': serializer.toJson<String>(actionId),
      'committedAt': serializer.toJson<DateTime?>(committedAt),
      'outcome': serializer.toJson<String?>(outcome),
      'note': serializer.toJson<String?>(note),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'dirty': serializer.toJson<bool>(dirty),
    };
  }

  DayLogRow copyWith({
    String? id,
    String? userId,
    String? runId,
    int? dayIndex,
    String? actionId,
    Value<DateTime?> committedAt = const Value.absent(),
    Value<String?> outcome = const Value.absent(),
    Value<String?> note = const Value.absent(),
    DateTime? updatedAt,
    bool? dirty,
  }) => DayLogRow(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    runId: runId ?? this.runId,
    dayIndex: dayIndex ?? this.dayIndex,
    actionId: actionId ?? this.actionId,
    committedAt: committedAt.present ? committedAt.value : this.committedAt,
    outcome: outcome.present ? outcome.value : this.outcome,
    note: note.present ? note.value : this.note,
    updatedAt: updatedAt ?? this.updatedAt,
    dirty: dirty ?? this.dirty,
  );
  DayLogRow copyWithCompanion(DayLogsCompanion data) {
    return DayLogRow(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      runId: data.runId.present ? data.runId.value : this.runId,
      dayIndex: data.dayIndex.present ? data.dayIndex.value : this.dayIndex,
      actionId: data.actionId.present ? data.actionId.value : this.actionId,
      committedAt: data.committedAt.present
          ? data.committedAt.value
          : this.committedAt,
      outcome: data.outcome.present ? data.outcome.value : this.outcome,
      note: data.note.present ? data.note.value : this.note,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DayLogRow(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('runId: $runId, ')
          ..write('dayIndex: $dayIndex, ')
          ..write('actionId: $actionId, ')
          ..write('committedAt: $committedAt, ')
          ..write('outcome: $outcome, ')
          ..write('note: $note, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('dirty: $dirty')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    runId,
    dayIndex,
    actionId,
    committedAt,
    outcome,
    note,
    updatedAt,
    dirty,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DayLogRow &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.runId == this.runId &&
          other.dayIndex == this.dayIndex &&
          other.actionId == this.actionId &&
          other.committedAt == this.committedAt &&
          other.outcome == this.outcome &&
          other.note == this.note &&
          other.updatedAt == this.updatedAt &&
          other.dirty == this.dirty);
}

class DayLogsCompanion extends UpdateCompanion<DayLogRow> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> runId;
  final Value<int> dayIndex;
  final Value<String> actionId;
  final Value<DateTime?> committedAt;
  final Value<String?> outcome;
  final Value<String?> note;
  final Value<DateTime> updatedAt;
  final Value<bool> dirty;
  final Value<int> rowid;
  const DayLogsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.runId = const Value.absent(),
    this.dayIndex = const Value.absent(),
    this.actionId = const Value.absent(),
    this.committedAt = const Value.absent(),
    this.outcome = const Value.absent(),
    this.note = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.dirty = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DayLogsCompanion.insert({
    required String id,
    required String userId,
    required String runId,
    required int dayIndex,
    required String actionId,
    this.committedAt = const Value.absent(),
    this.outcome = const Value.absent(),
    this.note = const Value.absent(),
    required DateTime updatedAt,
    this.dirty = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       runId = Value(runId),
       dayIndex = Value(dayIndex),
       actionId = Value(actionId),
       updatedAt = Value(updatedAt);
  static Insertable<DayLogRow> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? runId,
    Expression<int>? dayIndex,
    Expression<String>? actionId,
    Expression<DateTime>? committedAt,
    Expression<String>? outcome,
    Expression<String>? note,
    Expression<DateTime>? updatedAt,
    Expression<bool>? dirty,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (runId != null) 'run_id': runId,
      if (dayIndex != null) 'day_index': dayIndex,
      if (actionId != null) 'action_id': actionId,
      if (committedAt != null) 'committed_at': committedAt,
      if (outcome != null) 'outcome': outcome,
      if (note != null) 'note': note,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (dirty != null) 'dirty': dirty,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DayLogsCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? runId,
    Value<int>? dayIndex,
    Value<String>? actionId,
    Value<DateTime?>? committedAt,
    Value<String?>? outcome,
    Value<String?>? note,
    Value<DateTime>? updatedAt,
    Value<bool>? dirty,
    Value<int>? rowid,
  }) {
    return DayLogsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      runId: runId ?? this.runId,
      dayIndex: dayIndex ?? this.dayIndex,
      actionId: actionId ?? this.actionId,
      committedAt: committedAt ?? this.committedAt,
      outcome: outcome ?? this.outcome,
      note: note ?? this.note,
      updatedAt: updatedAt ?? this.updatedAt,
      dirty: dirty ?? this.dirty,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (runId.present) {
      map['run_id'] = Variable<String>(runId.value);
    }
    if (dayIndex.present) {
      map['day_index'] = Variable<int>(dayIndex.value);
    }
    if (actionId.present) {
      map['action_id'] = Variable<String>(actionId.value);
    }
    if (committedAt.present) {
      map['committed_at'] = Variable<DateTime>(committedAt.value);
    }
    if (outcome.present) {
      map['outcome'] = Variable<String>(outcome.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<bool>(dirty.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DayLogsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('runId: $runId, ')
          ..write('dayIndex: $dayIndex, ')
          ..write('actionId: $actionId, ')
          ..write('committedAt: $committedAt, ')
          ..write('outcome: $outcome, ')
          ..write('note: $note, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('dirty: $dirty, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DiagnosticResultsTable extends DiagnosticResults
    with TableInfo<$DiagnosticResultsTable, DiagnosticResultRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DiagnosticResultsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _takenAtMeta = const VerificationMeta(
    'takenAt',
  );
  @override
  late final GeneratedColumn<DateTime> takenAt = GeneratedColumn<DateTime>(
    'taken_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scoresMeta = const VerificationMeta('scores');
  @override
  late final GeneratedColumn<String> scores = GeneratedColumn<String>(
    'scores',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weakestArchetypeIdMeta =
      const VerificationMeta('weakestArchetypeId');
  @override
  late final GeneratedColumn<String> weakestArchetypeId =
      GeneratedColumn<String>(
        'weakest_archetype_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _recommendedCampaignIdMeta =
      const VerificationMeta('recommendedCampaignId');
  @override
  late final GeneratedColumn<String> recommendedCampaignId =
      GeneratedColumn<String>(
        'recommended_campaign_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dirtyMeta = const VerificationMeta('dirty');
  @override
  late final GeneratedColumn<bool> dirty = GeneratedColumn<bool>(
    'dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    takenAt,
    scores,
    weakestArchetypeId,
    recommendedCampaignId,
    updatedAt,
    dirty,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'diagnostic_results';
  @override
  VerificationContext validateIntegrity(
    Insertable<DiagnosticResultRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('taken_at')) {
      context.handle(
        _takenAtMeta,
        takenAt.isAcceptableOrUnknown(data['taken_at']!, _takenAtMeta),
      );
    } else if (isInserting) {
      context.missing(_takenAtMeta);
    }
    if (data.containsKey('scores')) {
      context.handle(
        _scoresMeta,
        scores.isAcceptableOrUnknown(data['scores']!, _scoresMeta),
      );
    } else if (isInserting) {
      context.missing(_scoresMeta);
    }
    if (data.containsKey('weakest_archetype_id')) {
      context.handle(
        _weakestArchetypeIdMeta,
        weakestArchetypeId.isAcceptableOrUnknown(
          data['weakest_archetype_id']!,
          _weakestArchetypeIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_weakestArchetypeIdMeta);
    }
    if (data.containsKey('recommended_campaign_id')) {
      context.handle(
        _recommendedCampaignIdMeta,
        recommendedCampaignId.isAcceptableOrUnknown(
          data['recommended_campaign_id']!,
          _recommendedCampaignIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_recommendedCampaignIdMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('dirty')) {
      context.handle(
        _dirtyMeta,
        dirty.isAcceptableOrUnknown(data['dirty']!, _dirtyMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DiagnosticResultRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DiagnosticResultRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      takenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}taken_at'],
      )!,
      scores: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scores'],
      )!,
      weakestArchetypeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}weakest_archetype_id'],
      )!,
      recommendedCampaignId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recommended_campaign_id'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      dirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}dirty'],
      )!,
    );
  }

  @override
  $DiagnosticResultsTable createAlias(String alias) {
    return $DiagnosticResultsTable(attachedDatabase, alias);
  }
}

class DiagnosticResultRow extends DataClass
    implements Insertable<DiagnosticResultRow> {
  final String id;
  final String userId;
  final DateTime takenAt;

  /// JSON: archetype key to relative score, 0 to 1.
  final String scores;
  final String weakestArchetypeId;
  final String recommendedCampaignId;
  final DateTime updatedAt;
  final bool dirty;
  const DiagnosticResultRow({
    required this.id,
    required this.userId,
    required this.takenAt,
    required this.scores,
    required this.weakestArchetypeId,
    required this.recommendedCampaignId,
    required this.updatedAt,
    required this.dirty,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['taken_at'] = Variable<DateTime>(takenAt);
    map['scores'] = Variable<String>(scores);
    map['weakest_archetype_id'] = Variable<String>(weakestArchetypeId);
    map['recommended_campaign_id'] = Variable<String>(recommendedCampaignId);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['dirty'] = Variable<bool>(dirty);
    return map;
  }

  DiagnosticResultsCompanion toCompanion(bool nullToAbsent) {
    return DiagnosticResultsCompanion(
      id: Value(id),
      userId: Value(userId),
      takenAt: Value(takenAt),
      scores: Value(scores),
      weakestArchetypeId: Value(weakestArchetypeId),
      recommendedCampaignId: Value(recommendedCampaignId),
      updatedAt: Value(updatedAt),
      dirty: Value(dirty),
    );
  }

  factory DiagnosticResultRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DiagnosticResultRow(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      takenAt: serializer.fromJson<DateTime>(json['takenAt']),
      scores: serializer.fromJson<String>(json['scores']),
      weakestArchetypeId: serializer.fromJson<String>(
        json['weakestArchetypeId'],
      ),
      recommendedCampaignId: serializer.fromJson<String>(
        json['recommendedCampaignId'],
      ),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      dirty: serializer.fromJson<bool>(json['dirty']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'takenAt': serializer.toJson<DateTime>(takenAt),
      'scores': serializer.toJson<String>(scores),
      'weakestArchetypeId': serializer.toJson<String>(weakestArchetypeId),
      'recommendedCampaignId': serializer.toJson<String>(recommendedCampaignId),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'dirty': serializer.toJson<bool>(dirty),
    };
  }

  DiagnosticResultRow copyWith({
    String? id,
    String? userId,
    DateTime? takenAt,
    String? scores,
    String? weakestArchetypeId,
    String? recommendedCampaignId,
    DateTime? updatedAt,
    bool? dirty,
  }) => DiagnosticResultRow(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    takenAt: takenAt ?? this.takenAt,
    scores: scores ?? this.scores,
    weakestArchetypeId: weakestArchetypeId ?? this.weakestArchetypeId,
    recommendedCampaignId: recommendedCampaignId ?? this.recommendedCampaignId,
    updatedAt: updatedAt ?? this.updatedAt,
    dirty: dirty ?? this.dirty,
  );
  DiagnosticResultRow copyWithCompanion(DiagnosticResultsCompanion data) {
    return DiagnosticResultRow(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      takenAt: data.takenAt.present ? data.takenAt.value : this.takenAt,
      scores: data.scores.present ? data.scores.value : this.scores,
      weakestArchetypeId: data.weakestArchetypeId.present
          ? data.weakestArchetypeId.value
          : this.weakestArchetypeId,
      recommendedCampaignId: data.recommendedCampaignId.present
          ? data.recommendedCampaignId.value
          : this.recommendedCampaignId,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DiagnosticResultRow(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('takenAt: $takenAt, ')
          ..write('scores: $scores, ')
          ..write('weakestArchetypeId: $weakestArchetypeId, ')
          ..write('recommendedCampaignId: $recommendedCampaignId, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('dirty: $dirty')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    takenAt,
    scores,
    weakestArchetypeId,
    recommendedCampaignId,
    updatedAt,
    dirty,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DiagnosticResultRow &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.takenAt == this.takenAt &&
          other.scores == this.scores &&
          other.weakestArchetypeId == this.weakestArchetypeId &&
          other.recommendedCampaignId == this.recommendedCampaignId &&
          other.updatedAt == this.updatedAt &&
          other.dirty == this.dirty);
}

class DiagnosticResultsCompanion extends UpdateCompanion<DiagnosticResultRow> {
  final Value<String> id;
  final Value<String> userId;
  final Value<DateTime> takenAt;
  final Value<String> scores;
  final Value<String> weakestArchetypeId;
  final Value<String> recommendedCampaignId;
  final Value<DateTime> updatedAt;
  final Value<bool> dirty;
  final Value<int> rowid;
  const DiagnosticResultsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.takenAt = const Value.absent(),
    this.scores = const Value.absent(),
    this.weakestArchetypeId = const Value.absent(),
    this.recommendedCampaignId = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.dirty = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DiagnosticResultsCompanion.insert({
    required String id,
    required String userId,
    required DateTime takenAt,
    required String scores,
    required String weakestArchetypeId,
    required String recommendedCampaignId,
    required DateTime updatedAt,
    this.dirty = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       takenAt = Value(takenAt),
       scores = Value(scores),
       weakestArchetypeId = Value(weakestArchetypeId),
       recommendedCampaignId = Value(recommendedCampaignId),
       updatedAt = Value(updatedAt);
  static Insertable<DiagnosticResultRow> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<DateTime>? takenAt,
    Expression<String>? scores,
    Expression<String>? weakestArchetypeId,
    Expression<String>? recommendedCampaignId,
    Expression<DateTime>? updatedAt,
    Expression<bool>? dirty,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (takenAt != null) 'taken_at': takenAt,
      if (scores != null) 'scores': scores,
      if (weakestArchetypeId != null)
        'weakest_archetype_id': weakestArchetypeId,
      if (recommendedCampaignId != null)
        'recommended_campaign_id': recommendedCampaignId,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (dirty != null) 'dirty': dirty,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DiagnosticResultsCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<DateTime>? takenAt,
    Value<String>? scores,
    Value<String>? weakestArchetypeId,
    Value<String>? recommendedCampaignId,
    Value<DateTime>? updatedAt,
    Value<bool>? dirty,
    Value<int>? rowid,
  }) {
    return DiagnosticResultsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      takenAt: takenAt ?? this.takenAt,
      scores: scores ?? this.scores,
      weakestArchetypeId: weakestArchetypeId ?? this.weakestArchetypeId,
      recommendedCampaignId:
          recommendedCampaignId ?? this.recommendedCampaignId,
      updatedAt: updatedAt ?? this.updatedAt,
      dirty: dirty ?? this.dirty,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (takenAt.present) {
      map['taken_at'] = Variable<DateTime>(takenAt.value);
    }
    if (scores.present) {
      map['scores'] = Variable<String>(scores.value);
    }
    if (weakestArchetypeId.present) {
      map['weakest_archetype_id'] = Variable<String>(weakestArchetypeId.value);
    }
    if (recommendedCampaignId.present) {
      map['recommended_campaign_id'] = Variable<String>(
        recommendedCampaignId.value,
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<bool>(dirty.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DiagnosticResultsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('takenAt: $takenAt, ')
          ..write('scores: $scores, ')
          ..write('weakestArchetypeId: $weakestArchetypeId, ')
          ..write('recommendedCampaignId: $recommendedCampaignId, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('dirty: $dirty, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncStateTable extends SyncState
    with TableInfo<$SyncStateTable, SyncStateRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncStateTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _syncTableMeta = const VerificationMeta(
    'syncTable',
  );
  @override
  late final GeneratedColumn<String> syncTable = GeneratedColumn<String>(
    'table_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _watermarkMeta = const VerificationMeta(
    'watermark',
  );
  @override
  late final GeneratedColumn<DateTime> watermark = GeneratedColumn<DateTime>(
    'watermark',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastPulledAtMeta = const VerificationMeta(
    'lastPulledAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastPulledAt = GeneratedColumn<DateTime>(
    'last_pulled_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [syncTable, watermark, lastPulledAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_state';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncStateRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('table_name')) {
      context.handle(
        _syncTableMeta,
        syncTable.isAcceptableOrUnknown(data['table_name']!, _syncTableMeta),
      );
    } else if (isInserting) {
      context.missing(_syncTableMeta);
    }
    if (data.containsKey('watermark')) {
      context.handle(
        _watermarkMeta,
        watermark.isAcceptableOrUnknown(data['watermark']!, _watermarkMeta),
      );
    }
    if (data.containsKey('last_pulled_at')) {
      context.handle(
        _lastPulledAtMeta,
        lastPulledAt.isAcceptableOrUnknown(
          data['last_pulled_at']!,
          _lastPulledAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {syncTable};
  @override
  SyncStateRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncStateRow(
      syncTable: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}table_name'],
      )!,
      watermark: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}watermark'],
      ),
      lastPulledAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_pulled_at'],
      ),
    );
  }

  @override
  $SyncStateTable createAlias(String alias) {
    return $SyncStateTable(attachedDatabase, alias);
  }
}

class SyncStateRow extends DataClass implements Insertable<SyncStateRow> {
  /// The remote table name, e.g. `campaigns` or `day_logs`.
  ///
  /// Named `syncTable` in Dart because `tableName` is drift's own hook for
  /// overriding a table's SQL name; the column itself is still `table_name`.
  final String syncTable;

  /// Newest `updated_at` committed locally. Null means "never pulled".
  final DateTime? watermark;

  /// When the last successful pull for this table finished. Diagnostics only —
  /// never used to decide what to fetch.
  final DateTime? lastPulledAt;
  const SyncStateRow({
    required this.syncTable,
    this.watermark,
    this.lastPulledAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['table_name'] = Variable<String>(syncTable);
    if (!nullToAbsent || watermark != null) {
      map['watermark'] = Variable<DateTime>(watermark);
    }
    if (!nullToAbsent || lastPulledAt != null) {
      map['last_pulled_at'] = Variable<DateTime>(lastPulledAt);
    }
    return map;
  }

  SyncStateCompanion toCompanion(bool nullToAbsent) {
    return SyncStateCompanion(
      syncTable: Value(syncTable),
      watermark: watermark == null && nullToAbsent
          ? const Value.absent()
          : Value(watermark),
      lastPulledAt: lastPulledAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPulledAt),
    );
  }

  factory SyncStateRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncStateRow(
      syncTable: serializer.fromJson<String>(json['syncTable']),
      watermark: serializer.fromJson<DateTime?>(json['watermark']),
      lastPulledAt: serializer.fromJson<DateTime?>(json['lastPulledAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'syncTable': serializer.toJson<String>(syncTable),
      'watermark': serializer.toJson<DateTime?>(watermark),
      'lastPulledAt': serializer.toJson<DateTime?>(lastPulledAt),
    };
  }

  SyncStateRow copyWith({
    String? syncTable,
    Value<DateTime?> watermark = const Value.absent(),
    Value<DateTime?> lastPulledAt = const Value.absent(),
  }) => SyncStateRow(
    syncTable: syncTable ?? this.syncTable,
    watermark: watermark.present ? watermark.value : this.watermark,
    lastPulledAt: lastPulledAt.present ? lastPulledAt.value : this.lastPulledAt,
  );
  SyncStateRow copyWithCompanion(SyncStateCompanion data) {
    return SyncStateRow(
      syncTable: data.syncTable.present ? data.syncTable.value : this.syncTable,
      watermark: data.watermark.present ? data.watermark.value : this.watermark,
      lastPulledAt: data.lastPulledAt.present
          ? data.lastPulledAt.value
          : this.lastPulledAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncStateRow(')
          ..write('syncTable: $syncTable, ')
          ..write('watermark: $watermark, ')
          ..write('lastPulledAt: $lastPulledAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(syncTable, watermark, lastPulledAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncStateRow &&
          other.syncTable == this.syncTable &&
          other.watermark == this.watermark &&
          other.lastPulledAt == this.lastPulledAt);
}

class SyncStateCompanion extends UpdateCompanion<SyncStateRow> {
  final Value<String> syncTable;
  final Value<DateTime?> watermark;
  final Value<DateTime?> lastPulledAt;
  final Value<int> rowid;
  const SyncStateCompanion({
    this.syncTable = const Value.absent(),
    this.watermark = const Value.absent(),
    this.lastPulledAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncStateCompanion.insert({
    required String syncTable,
    this.watermark = const Value.absent(),
    this.lastPulledAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : syncTable = Value(syncTable);
  static Insertable<SyncStateRow> custom({
    Expression<String>? syncTable,
    Expression<DateTime>? watermark,
    Expression<DateTime>? lastPulledAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (syncTable != null) 'table_name': syncTable,
      if (watermark != null) 'watermark': watermark,
      if (lastPulledAt != null) 'last_pulled_at': lastPulledAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncStateCompanion copyWith({
    Value<String>? syncTable,
    Value<DateTime?>? watermark,
    Value<DateTime?>? lastPulledAt,
    Value<int>? rowid,
  }) {
    return SyncStateCompanion(
      syncTable: syncTable ?? this.syncTable,
      watermark: watermark ?? this.watermark,
      lastPulledAt: lastPulledAt ?? this.lastPulledAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (syncTable.present) {
      map['table_name'] = Variable<String>(syncTable.value);
    }
    if (watermark.present) {
      map['watermark'] = Variable<DateTime>(watermark.value);
    }
    if (lastPulledAt.present) {
      map['last_pulled_at'] = Variable<DateTime>(lastPulledAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncStateCompanion(')
          ..write('syncTable: $syncTable, ')
          ..write('watermark: $watermark, ')
          ..write('lastPulledAt: $lastPulledAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$FeralDatabase extends GeneratedDatabase {
  _$FeralDatabase(QueryExecutor e) : super(e);
  $FeralDatabaseManager get managers => $FeralDatabaseManager(this);
  late final $ArchetypesTable archetypes = $ArchetypesTable(this);
  late final $PacksTable packs = $PacksTable(this);
  late final $CampaignsTable campaigns = $CampaignsTable(this);
  late final $CampaignArchetypesTable campaignArchetypes =
      $CampaignArchetypesTable(this);
  late final $ActionsTable actions = $ActionsTable(this);
  late final $DoctrineGroupsTable doctrineGroups = $DoctrineGroupsTable(this);
  late final $DoctrineEntriesTable doctrineEntries = $DoctrineEntriesTable(
    this,
  );
  late final $DiagnosticQuestionsTable diagnosticQuestions =
      $DiagnosticQuestionsTable(this);
  late final $DiagnosticOptionsTable diagnosticOptions =
      $DiagnosticOptionsTable(this);
  late final $ProfilesTable profiles = $ProfilesTable(this);
  late final $CampaignRunsTable campaignRuns = $CampaignRunsTable(this);
  late final $DayLogsTable dayLogs = $DayLogsTable(this);
  late final $DiagnosticResultsTable diagnosticResults =
      $DiagnosticResultsTable(this);
  late final $SyncStateTable syncState = $SyncStateTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    archetypes,
    packs,
    campaigns,
    campaignArchetypes,
    actions,
    doctrineGroups,
    doctrineEntries,
    diagnosticQuestions,
    diagnosticOptions,
    profiles,
    campaignRuns,
    dayLogs,
    diagnosticResults,
    syncState,
  ];
}

typedef $$ArchetypesTableCreateCompanionBuilder =
    ArchetypesCompanion Function({
      required String id,
      required String key,
      required String name,
      required String blurb,
      required String color,
      required int sort,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$ArchetypesTableUpdateCompanionBuilder =
    ArchetypesCompanion Function({
      Value<String> id,
      Value<String> key,
      Value<String> name,
      Value<String> blurb,
      Value<String> color,
      Value<int> sort,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$ArchetypesTableFilterComposer
    extends Composer<_$FeralDatabase, $ArchetypesTable> {
  $$ArchetypesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get blurb => $composableBuilder(
    column: $table.blurb,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sort => $composableBuilder(
    column: $table.sort,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ArchetypesTableOrderingComposer
    extends Composer<_$FeralDatabase, $ArchetypesTable> {
  $$ArchetypesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get blurb => $composableBuilder(
    column: $table.blurb,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sort => $composableBuilder(
    column: $table.sort,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ArchetypesTableAnnotationComposer
    extends Composer<_$FeralDatabase, $ArchetypesTable> {
  $$ArchetypesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get blurb =>
      $composableBuilder(column: $table.blurb, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<int> get sort =>
      $composableBuilder(column: $table.sort, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ArchetypesTableTableManager
    extends
        RootTableManager<
          _$FeralDatabase,
          $ArchetypesTable,
          ArchetypeRow,
          $$ArchetypesTableFilterComposer,
          $$ArchetypesTableOrderingComposer,
          $$ArchetypesTableAnnotationComposer,
          $$ArchetypesTableCreateCompanionBuilder,
          $$ArchetypesTableUpdateCompanionBuilder,
          (
            ArchetypeRow,
            BaseReferences<_$FeralDatabase, $ArchetypesTable, ArchetypeRow>,
          ),
          ArchetypeRow,
          PrefetchHooks Function()
        > {
  $$ArchetypesTableTableManager(_$FeralDatabase db, $ArchetypesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ArchetypesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ArchetypesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ArchetypesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> key = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> blurb = const Value.absent(),
                Value<String> color = const Value.absent(),
                Value<int> sort = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ArchetypesCompanion(
                id: id,
                key: key,
                name: name,
                blurb: blurb,
                color: color,
                sort: sort,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String key,
                required String name,
                required String blurb,
                required String color,
                required int sort,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => ArchetypesCompanion.insert(
                id: id,
                key: key,
                name: name,
                blurb: blurb,
                color: color,
                sort: sort,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ArchetypesTableProcessedTableManager =
    ProcessedTableManager<
      _$FeralDatabase,
      $ArchetypesTable,
      ArchetypeRow,
      $$ArchetypesTableFilterComposer,
      $$ArchetypesTableOrderingComposer,
      $$ArchetypesTableAnnotationComposer,
      $$ArchetypesTableCreateCompanionBuilder,
      $$ArchetypesTableUpdateCompanionBuilder,
      (
        ArchetypeRow,
        BaseReferences<_$FeralDatabase, $ArchetypesTable, ArchetypeRow>,
      ),
      ArchetypeRow,
      PrefetchHooks Function()
    >;
typedef $$PacksTableCreateCompanionBuilder =
    PacksCompanion Function({
      required String id,
      required String key,
      required String title,
      required String description,
      Value<bool> isCore,
      Value<String?> storeProductId,
      Value<String?> coverPath,
      required int sort,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$PacksTableUpdateCompanionBuilder =
    PacksCompanion Function({
      Value<String> id,
      Value<String> key,
      Value<String> title,
      Value<String> description,
      Value<bool> isCore,
      Value<String?> storeProductId,
      Value<String?> coverPath,
      Value<int> sort,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$PacksTableFilterComposer
    extends Composer<_$FeralDatabase, $PacksTable> {
  $$PacksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCore => $composableBuilder(
    column: $table.isCore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get storeProductId => $composableBuilder(
    column: $table.storeProductId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverPath => $composableBuilder(
    column: $table.coverPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sort => $composableBuilder(
    column: $table.sort,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PacksTableOrderingComposer
    extends Composer<_$FeralDatabase, $PacksTable> {
  $$PacksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCore => $composableBuilder(
    column: $table.isCore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get storeProductId => $composableBuilder(
    column: $table.storeProductId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverPath => $composableBuilder(
    column: $table.coverPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sort => $composableBuilder(
    column: $table.sort,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PacksTableAnnotationComposer
    extends Composer<_$FeralDatabase, $PacksTable> {
  $$PacksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isCore =>
      $composableBuilder(column: $table.isCore, builder: (column) => column);

  GeneratedColumn<String> get storeProductId => $composableBuilder(
    column: $table.storeProductId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get coverPath =>
      $composableBuilder(column: $table.coverPath, builder: (column) => column);

  GeneratedColumn<int> get sort =>
      $composableBuilder(column: $table.sort, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$PacksTableTableManager
    extends
        RootTableManager<
          _$FeralDatabase,
          $PacksTable,
          PackRow,
          $$PacksTableFilterComposer,
          $$PacksTableOrderingComposer,
          $$PacksTableAnnotationComposer,
          $$PacksTableCreateCompanionBuilder,
          $$PacksTableUpdateCompanionBuilder,
          (PackRow, BaseReferences<_$FeralDatabase, $PacksTable, PackRow>),
          PackRow,
          PrefetchHooks Function()
        > {
  $$PacksTableTableManager(_$FeralDatabase db, $PacksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PacksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PacksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PacksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> key = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<bool> isCore = const Value.absent(),
                Value<String?> storeProductId = const Value.absent(),
                Value<String?> coverPath = const Value.absent(),
                Value<int> sort = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PacksCompanion(
                id: id,
                key: key,
                title: title,
                description: description,
                isCore: isCore,
                storeProductId: storeProductId,
                coverPath: coverPath,
                sort: sort,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String key,
                required String title,
                required String description,
                Value<bool> isCore = const Value.absent(),
                Value<String?> storeProductId = const Value.absent(),
                Value<String?> coverPath = const Value.absent(),
                required int sort,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => PacksCompanion.insert(
                id: id,
                key: key,
                title: title,
                description: description,
                isCore: isCore,
                storeProductId: storeProductId,
                coverPath: coverPath,
                sort: sort,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PacksTableProcessedTableManager =
    ProcessedTableManager<
      _$FeralDatabase,
      $PacksTable,
      PackRow,
      $$PacksTableFilterComposer,
      $$PacksTableOrderingComposer,
      $$PacksTableAnnotationComposer,
      $$PacksTableCreateCompanionBuilder,
      $$PacksTableUpdateCompanionBuilder,
      (PackRow, BaseReferences<_$FeralDatabase, $PacksTable, PackRow>),
      PackRow,
      PrefetchHooks Function()
    >;
typedef $$CampaignsTableCreateCompanionBuilder =
    CampaignsCompanion Function({
      required String id,
      required String packId,
      required String key,
      required String title,
      Value<String?> subtitle,
      required String introMd,
      required int lengthDays,
      Value<int> rampDays,
      Value<int> difficulty,
      Value<String?> coverPath,
      required int sort,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$CampaignsTableUpdateCompanionBuilder =
    CampaignsCompanion Function({
      Value<String> id,
      Value<String> packId,
      Value<String> key,
      Value<String> title,
      Value<String?> subtitle,
      Value<String> introMd,
      Value<int> lengthDays,
      Value<int> rampDays,
      Value<int> difficulty,
      Value<String?> coverPath,
      Value<int> sort,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$CampaignsTableFilterComposer
    extends Composer<_$FeralDatabase, $CampaignsTable> {
  $$CampaignsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get packId => $composableBuilder(
    column: $table.packId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subtitle => $composableBuilder(
    column: $table.subtitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get introMd => $composableBuilder(
    column: $table.introMd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lengthDays => $composableBuilder(
    column: $table.lengthDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rampDays => $composableBuilder(
    column: $table.rampDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverPath => $composableBuilder(
    column: $table.coverPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sort => $composableBuilder(
    column: $table.sort,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CampaignsTableOrderingComposer
    extends Composer<_$FeralDatabase, $CampaignsTable> {
  $$CampaignsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get packId => $composableBuilder(
    column: $table.packId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subtitle => $composableBuilder(
    column: $table.subtitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get introMd => $composableBuilder(
    column: $table.introMd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lengthDays => $composableBuilder(
    column: $table.lengthDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rampDays => $composableBuilder(
    column: $table.rampDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverPath => $composableBuilder(
    column: $table.coverPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sort => $composableBuilder(
    column: $table.sort,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CampaignsTableAnnotationComposer
    extends Composer<_$FeralDatabase, $CampaignsTable> {
  $$CampaignsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get packId =>
      $composableBuilder(column: $table.packId, builder: (column) => column);

  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get subtitle =>
      $composableBuilder(column: $table.subtitle, builder: (column) => column);

  GeneratedColumn<String> get introMd =>
      $composableBuilder(column: $table.introMd, builder: (column) => column);

  GeneratedColumn<int> get lengthDays => $composableBuilder(
    column: $table.lengthDays,
    builder: (column) => column,
  );

  GeneratedColumn<int> get rampDays =>
      $composableBuilder(column: $table.rampDays, builder: (column) => column);

  GeneratedColumn<int> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => column,
  );

  GeneratedColumn<String> get coverPath =>
      $composableBuilder(column: $table.coverPath, builder: (column) => column);

  GeneratedColumn<int> get sort =>
      $composableBuilder(column: $table.sort, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CampaignsTableTableManager
    extends
        RootTableManager<
          _$FeralDatabase,
          $CampaignsTable,
          CampaignRow,
          $$CampaignsTableFilterComposer,
          $$CampaignsTableOrderingComposer,
          $$CampaignsTableAnnotationComposer,
          $$CampaignsTableCreateCompanionBuilder,
          $$CampaignsTableUpdateCompanionBuilder,
          (
            CampaignRow,
            BaseReferences<_$FeralDatabase, $CampaignsTable, CampaignRow>,
          ),
          CampaignRow,
          PrefetchHooks Function()
        > {
  $$CampaignsTableTableManager(_$FeralDatabase db, $CampaignsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CampaignsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CampaignsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CampaignsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> packId = const Value.absent(),
                Value<String> key = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> subtitle = const Value.absent(),
                Value<String> introMd = const Value.absent(),
                Value<int> lengthDays = const Value.absent(),
                Value<int> rampDays = const Value.absent(),
                Value<int> difficulty = const Value.absent(),
                Value<String?> coverPath = const Value.absent(),
                Value<int> sort = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CampaignsCompanion(
                id: id,
                packId: packId,
                key: key,
                title: title,
                subtitle: subtitle,
                introMd: introMd,
                lengthDays: lengthDays,
                rampDays: rampDays,
                difficulty: difficulty,
                coverPath: coverPath,
                sort: sort,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String packId,
                required String key,
                required String title,
                Value<String?> subtitle = const Value.absent(),
                required String introMd,
                required int lengthDays,
                Value<int> rampDays = const Value.absent(),
                Value<int> difficulty = const Value.absent(),
                Value<String?> coverPath = const Value.absent(),
                required int sort,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => CampaignsCompanion.insert(
                id: id,
                packId: packId,
                key: key,
                title: title,
                subtitle: subtitle,
                introMd: introMd,
                lengthDays: lengthDays,
                rampDays: rampDays,
                difficulty: difficulty,
                coverPath: coverPath,
                sort: sort,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CampaignsTableProcessedTableManager =
    ProcessedTableManager<
      _$FeralDatabase,
      $CampaignsTable,
      CampaignRow,
      $$CampaignsTableFilterComposer,
      $$CampaignsTableOrderingComposer,
      $$CampaignsTableAnnotationComposer,
      $$CampaignsTableCreateCompanionBuilder,
      $$CampaignsTableUpdateCompanionBuilder,
      (
        CampaignRow,
        BaseReferences<_$FeralDatabase, $CampaignsTable, CampaignRow>,
      ),
      CampaignRow,
      PrefetchHooks Function()
    >;
typedef $$CampaignArchetypesTableCreateCompanionBuilder =
    CampaignArchetypesCompanion Function({
      required String campaignId,
      required String archetypeId,
      Value<double> weight,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$CampaignArchetypesTableUpdateCompanionBuilder =
    CampaignArchetypesCompanion Function({
      Value<String> campaignId,
      Value<String> archetypeId,
      Value<double> weight,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$CampaignArchetypesTableFilterComposer
    extends Composer<_$FeralDatabase, $CampaignArchetypesTable> {
  $$CampaignArchetypesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get campaignId => $composableBuilder(
    column: $table.campaignId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get archetypeId => $composableBuilder(
    column: $table.archetypeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weight => $composableBuilder(
    column: $table.weight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CampaignArchetypesTableOrderingComposer
    extends Composer<_$FeralDatabase, $CampaignArchetypesTable> {
  $$CampaignArchetypesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get campaignId => $composableBuilder(
    column: $table.campaignId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get archetypeId => $composableBuilder(
    column: $table.archetypeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weight => $composableBuilder(
    column: $table.weight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CampaignArchetypesTableAnnotationComposer
    extends Composer<_$FeralDatabase, $CampaignArchetypesTable> {
  $$CampaignArchetypesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get campaignId => $composableBuilder(
    column: $table.campaignId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get archetypeId => $composableBuilder(
    column: $table.archetypeId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get weight =>
      $composableBuilder(column: $table.weight, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CampaignArchetypesTableTableManager
    extends
        RootTableManager<
          _$FeralDatabase,
          $CampaignArchetypesTable,
          CampaignArchetypeRow,
          $$CampaignArchetypesTableFilterComposer,
          $$CampaignArchetypesTableOrderingComposer,
          $$CampaignArchetypesTableAnnotationComposer,
          $$CampaignArchetypesTableCreateCompanionBuilder,
          $$CampaignArchetypesTableUpdateCompanionBuilder,
          (
            CampaignArchetypeRow,
            BaseReferences<
              _$FeralDatabase,
              $CampaignArchetypesTable,
              CampaignArchetypeRow
            >,
          ),
          CampaignArchetypeRow,
          PrefetchHooks Function()
        > {
  $$CampaignArchetypesTableTableManager(
    _$FeralDatabase db,
    $CampaignArchetypesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CampaignArchetypesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CampaignArchetypesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CampaignArchetypesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> campaignId = const Value.absent(),
                Value<String> archetypeId = const Value.absent(),
                Value<double> weight = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CampaignArchetypesCompanion(
                campaignId: campaignId,
                archetypeId: archetypeId,
                weight: weight,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String campaignId,
                required String archetypeId,
                Value<double> weight = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => CampaignArchetypesCompanion.insert(
                campaignId: campaignId,
                archetypeId: archetypeId,
                weight: weight,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CampaignArchetypesTableProcessedTableManager =
    ProcessedTableManager<
      _$FeralDatabase,
      $CampaignArchetypesTable,
      CampaignArchetypeRow,
      $$CampaignArchetypesTableFilterComposer,
      $$CampaignArchetypesTableOrderingComposer,
      $$CampaignArchetypesTableAnnotationComposer,
      $$CampaignArchetypesTableCreateCompanionBuilder,
      $$CampaignArchetypesTableUpdateCompanionBuilder,
      (
        CampaignArchetypeRow,
        BaseReferences<
          _$FeralDatabase,
          $CampaignArchetypesTable,
          CampaignArchetypeRow
        >,
      ),
      CampaignArchetypeRow,
      PrefetchHooks Function()
    >;
typedef $$ActionsTableCreateCompanionBuilder =
    ActionsCompanion Function({
      required String id,
      required String campaignId,
      required int dayIndex,
      required String title,
      required String bodyMd,
      required String archetypeId,
      Value<String?> whyDoctrineId,
      Value<int> effort,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$ActionsTableUpdateCompanionBuilder =
    ActionsCompanion Function({
      Value<String> id,
      Value<String> campaignId,
      Value<int> dayIndex,
      Value<String> title,
      Value<String> bodyMd,
      Value<String> archetypeId,
      Value<String?> whyDoctrineId,
      Value<int> effort,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$ActionsTableFilterComposer
    extends Composer<_$FeralDatabase, $ActionsTable> {
  $$ActionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get campaignId => $composableBuilder(
    column: $table.campaignId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dayIndex => $composableBuilder(
    column: $table.dayIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bodyMd => $composableBuilder(
    column: $table.bodyMd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get archetypeId => $composableBuilder(
    column: $table.archetypeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get whyDoctrineId => $composableBuilder(
    column: $table.whyDoctrineId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get effort => $composableBuilder(
    column: $table.effort,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ActionsTableOrderingComposer
    extends Composer<_$FeralDatabase, $ActionsTable> {
  $$ActionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get campaignId => $composableBuilder(
    column: $table.campaignId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dayIndex => $composableBuilder(
    column: $table.dayIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bodyMd => $composableBuilder(
    column: $table.bodyMd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get archetypeId => $composableBuilder(
    column: $table.archetypeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get whyDoctrineId => $composableBuilder(
    column: $table.whyDoctrineId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get effort => $composableBuilder(
    column: $table.effort,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ActionsTableAnnotationComposer
    extends Composer<_$FeralDatabase, $ActionsTable> {
  $$ActionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get campaignId => $composableBuilder(
    column: $table.campaignId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dayIndex =>
      $composableBuilder(column: $table.dayIndex, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get bodyMd =>
      $composableBuilder(column: $table.bodyMd, builder: (column) => column);

  GeneratedColumn<String> get archetypeId => $composableBuilder(
    column: $table.archetypeId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get whyDoctrineId => $composableBuilder(
    column: $table.whyDoctrineId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get effort =>
      $composableBuilder(column: $table.effort, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ActionsTableTableManager
    extends
        RootTableManager<
          _$FeralDatabase,
          $ActionsTable,
          ActionRow,
          $$ActionsTableFilterComposer,
          $$ActionsTableOrderingComposer,
          $$ActionsTableAnnotationComposer,
          $$ActionsTableCreateCompanionBuilder,
          $$ActionsTableUpdateCompanionBuilder,
          (
            ActionRow,
            BaseReferences<_$FeralDatabase, $ActionsTable, ActionRow>,
          ),
          ActionRow,
          PrefetchHooks Function()
        > {
  $$ActionsTableTableManager(_$FeralDatabase db, $ActionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ActionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ActionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ActionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> campaignId = const Value.absent(),
                Value<int> dayIndex = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> bodyMd = const Value.absent(),
                Value<String> archetypeId = const Value.absent(),
                Value<String?> whyDoctrineId = const Value.absent(),
                Value<int> effort = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ActionsCompanion(
                id: id,
                campaignId: campaignId,
                dayIndex: dayIndex,
                title: title,
                bodyMd: bodyMd,
                archetypeId: archetypeId,
                whyDoctrineId: whyDoctrineId,
                effort: effort,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String campaignId,
                required int dayIndex,
                required String title,
                required String bodyMd,
                required String archetypeId,
                Value<String?> whyDoctrineId = const Value.absent(),
                Value<int> effort = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => ActionsCompanion.insert(
                id: id,
                campaignId: campaignId,
                dayIndex: dayIndex,
                title: title,
                bodyMd: bodyMd,
                archetypeId: archetypeId,
                whyDoctrineId: whyDoctrineId,
                effort: effort,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ActionsTableProcessedTableManager =
    ProcessedTableManager<
      _$FeralDatabase,
      $ActionsTable,
      ActionRow,
      $$ActionsTableFilterComposer,
      $$ActionsTableOrderingComposer,
      $$ActionsTableAnnotationComposer,
      $$ActionsTableCreateCompanionBuilder,
      $$ActionsTableUpdateCompanionBuilder,
      (ActionRow, BaseReferences<_$FeralDatabase, $ActionsTable, ActionRow>),
      ActionRow,
      PrefetchHooks Function()
    >;
typedef $$DoctrineGroupsTableCreateCompanionBuilder =
    DoctrineGroupsCompanion Function({
      required String id,
      required String title,
      Value<String?> blurb,
      required int sort,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$DoctrineGroupsTableUpdateCompanionBuilder =
    DoctrineGroupsCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String?> blurb,
      Value<int> sort,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$DoctrineGroupsTableFilterComposer
    extends Composer<_$FeralDatabase, $DoctrineGroupsTable> {
  $$DoctrineGroupsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get blurb => $composableBuilder(
    column: $table.blurb,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sort => $composableBuilder(
    column: $table.sort,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DoctrineGroupsTableOrderingComposer
    extends Composer<_$FeralDatabase, $DoctrineGroupsTable> {
  $$DoctrineGroupsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get blurb => $composableBuilder(
    column: $table.blurb,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sort => $composableBuilder(
    column: $table.sort,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DoctrineGroupsTableAnnotationComposer
    extends Composer<_$FeralDatabase, $DoctrineGroupsTable> {
  $$DoctrineGroupsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get blurb =>
      $composableBuilder(column: $table.blurb, builder: (column) => column);

  GeneratedColumn<int> get sort =>
      $composableBuilder(column: $table.sort, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$DoctrineGroupsTableTableManager
    extends
        RootTableManager<
          _$FeralDatabase,
          $DoctrineGroupsTable,
          DoctrineGroupRow,
          $$DoctrineGroupsTableFilterComposer,
          $$DoctrineGroupsTableOrderingComposer,
          $$DoctrineGroupsTableAnnotationComposer,
          $$DoctrineGroupsTableCreateCompanionBuilder,
          $$DoctrineGroupsTableUpdateCompanionBuilder,
          (
            DoctrineGroupRow,
            BaseReferences<
              _$FeralDatabase,
              $DoctrineGroupsTable,
              DoctrineGroupRow
            >,
          ),
          DoctrineGroupRow,
          PrefetchHooks Function()
        > {
  $$DoctrineGroupsTableTableManager(
    _$FeralDatabase db,
    $DoctrineGroupsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DoctrineGroupsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DoctrineGroupsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DoctrineGroupsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> blurb = const Value.absent(),
                Value<int> sort = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DoctrineGroupsCompanion(
                id: id,
                title: title,
                blurb: blurb,
                sort: sort,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                Value<String?> blurb = const Value.absent(),
                required int sort,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => DoctrineGroupsCompanion.insert(
                id: id,
                title: title,
                blurb: blurb,
                sort: sort,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DoctrineGroupsTableProcessedTableManager =
    ProcessedTableManager<
      _$FeralDatabase,
      $DoctrineGroupsTable,
      DoctrineGroupRow,
      $$DoctrineGroupsTableFilterComposer,
      $$DoctrineGroupsTableOrderingComposer,
      $$DoctrineGroupsTableAnnotationComposer,
      $$DoctrineGroupsTableCreateCompanionBuilder,
      $$DoctrineGroupsTableUpdateCompanionBuilder,
      (
        DoctrineGroupRow,
        BaseReferences<_$FeralDatabase, $DoctrineGroupsTable, DoctrineGroupRow>,
      ),
      DoctrineGroupRow,
      PrefetchHooks Function()
    >;
typedef $$DoctrineEntriesTableCreateCompanionBuilder =
    DoctrineEntriesCompanion Function({
      required String id,
      required String groupId,
      required String title,
      required String bodyMd,
      Value<String?> relatedArchetypeId,
      required int sort,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$DoctrineEntriesTableUpdateCompanionBuilder =
    DoctrineEntriesCompanion Function({
      Value<String> id,
      Value<String> groupId,
      Value<String> title,
      Value<String> bodyMd,
      Value<String?> relatedArchetypeId,
      Value<int> sort,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$DoctrineEntriesTableFilterComposer
    extends Composer<_$FeralDatabase, $DoctrineEntriesTable> {
  $$DoctrineEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get groupId => $composableBuilder(
    column: $table.groupId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bodyMd => $composableBuilder(
    column: $table.bodyMd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get relatedArchetypeId => $composableBuilder(
    column: $table.relatedArchetypeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sort => $composableBuilder(
    column: $table.sort,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DoctrineEntriesTableOrderingComposer
    extends Composer<_$FeralDatabase, $DoctrineEntriesTable> {
  $$DoctrineEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get groupId => $composableBuilder(
    column: $table.groupId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bodyMd => $composableBuilder(
    column: $table.bodyMd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get relatedArchetypeId => $composableBuilder(
    column: $table.relatedArchetypeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sort => $composableBuilder(
    column: $table.sort,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DoctrineEntriesTableAnnotationComposer
    extends Composer<_$FeralDatabase, $DoctrineEntriesTable> {
  $$DoctrineEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get groupId =>
      $composableBuilder(column: $table.groupId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get bodyMd =>
      $composableBuilder(column: $table.bodyMd, builder: (column) => column);

  GeneratedColumn<String> get relatedArchetypeId => $composableBuilder(
    column: $table.relatedArchetypeId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sort =>
      $composableBuilder(column: $table.sort, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$DoctrineEntriesTableTableManager
    extends
        RootTableManager<
          _$FeralDatabase,
          $DoctrineEntriesTable,
          DoctrineEntryRow,
          $$DoctrineEntriesTableFilterComposer,
          $$DoctrineEntriesTableOrderingComposer,
          $$DoctrineEntriesTableAnnotationComposer,
          $$DoctrineEntriesTableCreateCompanionBuilder,
          $$DoctrineEntriesTableUpdateCompanionBuilder,
          (
            DoctrineEntryRow,
            BaseReferences<
              _$FeralDatabase,
              $DoctrineEntriesTable,
              DoctrineEntryRow
            >,
          ),
          DoctrineEntryRow,
          PrefetchHooks Function()
        > {
  $$DoctrineEntriesTableTableManager(
    _$FeralDatabase db,
    $DoctrineEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DoctrineEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DoctrineEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DoctrineEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> groupId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> bodyMd = const Value.absent(),
                Value<String?> relatedArchetypeId = const Value.absent(),
                Value<int> sort = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DoctrineEntriesCompanion(
                id: id,
                groupId: groupId,
                title: title,
                bodyMd: bodyMd,
                relatedArchetypeId: relatedArchetypeId,
                sort: sort,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String groupId,
                required String title,
                required String bodyMd,
                Value<String?> relatedArchetypeId = const Value.absent(),
                required int sort,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => DoctrineEntriesCompanion.insert(
                id: id,
                groupId: groupId,
                title: title,
                bodyMd: bodyMd,
                relatedArchetypeId: relatedArchetypeId,
                sort: sort,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DoctrineEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$FeralDatabase,
      $DoctrineEntriesTable,
      DoctrineEntryRow,
      $$DoctrineEntriesTableFilterComposer,
      $$DoctrineEntriesTableOrderingComposer,
      $$DoctrineEntriesTableAnnotationComposer,
      $$DoctrineEntriesTableCreateCompanionBuilder,
      $$DoctrineEntriesTableUpdateCompanionBuilder,
      (
        DoctrineEntryRow,
        BaseReferences<
          _$FeralDatabase,
          $DoctrineEntriesTable,
          DoctrineEntryRow
        >,
      ),
      DoctrineEntryRow,
      PrefetchHooks Function()
    >;
typedef $$DiagnosticQuestionsTableCreateCompanionBuilder =
    DiagnosticQuestionsCompanion Function({
      required String id,
      required String prompt,
      required int sort,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$DiagnosticQuestionsTableUpdateCompanionBuilder =
    DiagnosticQuestionsCompanion Function({
      Value<String> id,
      Value<String> prompt,
      Value<int> sort,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$DiagnosticQuestionsTableFilterComposer
    extends Composer<_$FeralDatabase, $DiagnosticQuestionsTable> {
  $$DiagnosticQuestionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get prompt => $composableBuilder(
    column: $table.prompt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sort => $composableBuilder(
    column: $table.sort,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DiagnosticQuestionsTableOrderingComposer
    extends Composer<_$FeralDatabase, $DiagnosticQuestionsTable> {
  $$DiagnosticQuestionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get prompt => $composableBuilder(
    column: $table.prompt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sort => $composableBuilder(
    column: $table.sort,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DiagnosticQuestionsTableAnnotationComposer
    extends Composer<_$FeralDatabase, $DiagnosticQuestionsTable> {
  $$DiagnosticQuestionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get prompt =>
      $composableBuilder(column: $table.prompt, builder: (column) => column);

  GeneratedColumn<int> get sort =>
      $composableBuilder(column: $table.sort, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$DiagnosticQuestionsTableTableManager
    extends
        RootTableManager<
          _$FeralDatabase,
          $DiagnosticQuestionsTable,
          DiagnosticQuestionRow,
          $$DiagnosticQuestionsTableFilterComposer,
          $$DiagnosticQuestionsTableOrderingComposer,
          $$DiagnosticQuestionsTableAnnotationComposer,
          $$DiagnosticQuestionsTableCreateCompanionBuilder,
          $$DiagnosticQuestionsTableUpdateCompanionBuilder,
          (
            DiagnosticQuestionRow,
            BaseReferences<
              _$FeralDatabase,
              $DiagnosticQuestionsTable,
              DiagnosticQuestionRow
            >,
          ),
          DiagnosticQuestionRow,
          PrefetchHooks Function()
        > {
  $$DiagnosticQuestionsTableTableManager(
    _$FeralDatabase db,
    $DiagnosticQuestionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DiagnosticQuestionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DiagnosticQuestionsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$DiagnosticQuestionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> prompt = const Value.absent(),
                Value<int> sort = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DiagnosticQuestionsCompanion(
                id: id,
                prompt: prompt,
                sort: sort,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String prompt,
                required int sort,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => DiagnosticQuestionsCompanion.insert(
                id: id,
                prompt: prompt,
                sort: sort,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DiagnosticQuestionsTableProcessedTableManager =
    ProcessedTableManager<
      _$FeralDatabase,
      $DiagnosticQuestionsTable,
      DiagnosticQuestionRow,
      $$DiagnosticQuestionsTableFilterComposer,
      $$DiagnosticQuestionsTableOrderingComposer,
      $$DiagnosticQuestionsTableAnnotationComposer,
      $$DiagnosticQuestionsTableCreateCompanionBuilder,
      $$DiagnosticQuestionsTableUpdateCompanionBuilder,
      (
        DiagnosticQuestionRow,
        BaseReferences<
          _$FeralDatabase,
          $DiagnosticQuestionsTable,
          DiagnosticQuestionRow
        >,
      ),
      DiagnosticQuestionRow,
      PrefetchHooks Function()
    >;
typedef $$DiagnosticOptionsTableCreateCompanionBuilder =
    DiagnosticOptionsCompanion Function({
      required String id,
      required String questionId,
      required String label,
      required String archetypeId,
      required int sort,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$DiagnosticOptionsTableUpdateCompanionBuilder =
    DiagnosticOptionsCompanion Function({
      Value<String> id,
      Value<String> questionId,
      Value<String> label,
      Value<String> archetypeId,
      Value<int> sort,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$DiagnosticOptionsTableFilterComposer
    extends Composer<_$FeralDatabase, $DiagnosticOptionsTable> {
  $$DiagnosticOptionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get archetypeId => $composableBuilder(
    column: $table.archetypeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sort => $composableBuilder(
    column: $table.sort,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DiagnosticOptionsTableOrderingComposer
    extends Composer<_$FeralDatabase, $DiagnosticOptionsTable> {
  $$DiagnosticOptionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get archetypeId => $composableBuilder(
    column: $table.archetypeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sort => $composableBuilder(
    column: $table.sort,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DiagnosticOptionsTableAnnotationComposer
    extends Composer<_$FeralDatabase, $DiagnosticOptionsTable> {
  $$DiagnosticOptionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get archetypeId => $composableBuilder(
    column: $table.archetypeId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sort =>
      $composableBuilder(column: $table.sort, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$DiagnosticOptionsTableTableManager
    extends
        RootTableManager<
          _$FeralDatabase,
          $DiagnosticOptionsTable,
          DiagnosticOptionRow,
          $$DiagnosticOptionsTableFilterComposer,
          $$DiagnosticOptionsTableOrderingComposer,
          $$DiagnosticOptionsTableAnnotationComposer,
          $$DiagnosticOptionsTableCreateCompanionBuilder,
          $$DiagnosticOptionsTableUpdateCompanionBuilder,
          (
            DiagnosticOptionRow,
            BaseReferences<
              _$FeralDatabase,
              $DiagnosticOptionsTable,
              DiagnosticOptionRow
            >,
          ),
          DiagnosticOptionRow,
          PrefetchHooks Function()
        > {
  $$DiagnosticOptionsTableTableManager(
    _$FeralDatabase db,
    $DiagnosticOptionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DiagnosticOptionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DiagnosticOptionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DiagnosticOptionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> questionId = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<String> archetypeId = const Value.absent(),
                Value<int> sort = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DiagnosticOptionsCompanion(
                id: id,
                questionId: questionId,
                label: label,
                archetypeId: archetypeId,
                sort: sort,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String questionId,
                required String label,
                required String archetypeId,
                required int sort,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => DiagnosticOptionsCompanion.insert(
                id: id,
                questionId: questionId,
                label: label,
                archetypeId: archetypeId,
                sort: sort,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DiagnosticOptionsTableProcessedTableManager =
    ProcessedTableManager<
      _$FeralDatabase,
      $DiagnosticOptionsTable,
      DiagnosticOptionRow,
      $$DiagnosticOptionsTableFilterComposer,
      $$DiagnosticOptionsTableOrderingComposer,
      $$DiagnosticOptionsTableAnnotationComposer,
      $$DiagnosticOptionsTableCreateCompanionBuilder,
      $$DiagnosticOptionsTableUpdateCompanionBuilder,
      (
        DiagnosticOptionRow,
        BaseReferences<
          _$FeralDatabase,
          $DiagnosticOptionsTable,
          DiagnosticOptionRow
        >,
      ),
      DiagnosticOptionRow,
      PrefetchHooks Function()
    >;
typedef $$ProfilesTableCreateCompanionBuilder =
    ProfilesCompanion Function({
      required String userId,
      Value<String?> displayName,
      Value<DateTime?> onboardedAt,
      required DateTime updatedAt,
      Value<bool> dirty,
      Value<int> rowid,
    });
typedef $$ProfilesTableUpdateCompanionBuilder =
    ProfilesCompanion Function({
      Value<String> userId,
      Value<String?> displayName,
      Value<DateTime?> onboardedAt,
      Value<DateTime> updatedAt,
      Value<bool> dirty,
      Value<int> rowid,
    });

class $$ProfilesTableFilterComposer
    extends Composer<_$FeralDatabase, $ProfilesTable> {
  $$ProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get onboardedAt => $composableBuilder(
    column: $table.onboardedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProfilesTableOrderingComposer
    extends Composer<_$FeralDatabase, $ProfilesTable> {
  $$ProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get onboardedAt => $composableBuilder(
    column: $table.onboardedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProfilesTableAnnotationComposer
    extends Composer<_$FeralDatabase, $ProfilesTable> {
  $$ProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get onboardedAt => $composableBuilder(
    column: $table.onboardedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => column);
}

class $$ProfilesTableTableManager
    extends
        RootTableManager<
          _$FeralDatabase,
          $ProfilesTable,
          ProfileRow,
          $$ProfilesTableFilterComposer,
          $$ProfilesTableOrderingComposer,
          $$ProfilesTableAnnotationComposer,
          $$ProfilesTableCreateCompanionBuilder,
          $$ProfilesTableUpdateCompanionBuilder,
          (
            ProfileRow,
            BaseReferences<_$FeralDatabase, $ProfilesTable, ProfileRow>,
          ),
          ProfileRow,
          PrefetchHooks Function()
        > {
  $$ProfilesTableTableManager(_$FeralDatabase db, $ProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> userId = const Value.absent(),
                Value<String?> displayName = const Value.absent(),
                Value<DateTime?> onboardedAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProfilesCompanion(
                userId: userId,
                displayName: displayName,
                onboardedAt: onboardedAt,
                updatedAt: updatedAt,
                dirty: dirty,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String userId,
                Value<String?> displayName = const Value.absent(),
                Value<DateTime?> onboardedAt = const Value.absent(),
                required DateTime updatedAt,
                Value<bool> dirty = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProfilesCompanion.insert(
                userId: userId,
                displayName: displayName,
                onboardedAt: onboardedAt,
                updatedAt: updatedAt,
                dirty: dirty,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$FeralDatabase,
      $ProfilesTable,
      ProfileRow,
      $$ProfilesTableFilterComposer,
      $$ProfilesTableOrderingComposer,
      $$ProfilesTableAnnotationComposer,
      $$ProfilesTableCreateCompanionBuilder,
      $$ProfilesTableUpdateCompanionBuilder,
      (ProfileRow, BaseReferences<_$FeralDatabase, $ProfilesTable, ProfileRow>),
      ProfileRow,
      PrefetchHooks Function()
    >;
typedef $$CampaignRunsTableCreateCompanionBuilder =
    CampaignRunsCompanion Function({
      required String id,
      required String userId,
      required String campaignId,
      required String status,
      Value<bool> isHardened,
      required DateTime startedAt,
      Value<DateTime?> completedAt,
      Value<String?> grade,
      required DateTime updatedAt,
      Value<bool> dirty,
      Value<int> rowid,
    });
typedef $$CampaignRunsTableUpdateCompanionBuilder =
    CampaignRunsCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> campaignId,
      Value<String> status,
      Value<bool> isHardened,
      Value<DateTime> startedAt,
      Value<DateTime?> completedAt,
      Value<String?> grade,
      Value<DateTime> updatedAt,
      Value<bool> dirty,
      Value<int> rowid,
    });

class $$CampaignRunsTableFilterComposer
    extends Composer<_$FeralDatabase, $CampaignRunsTable> {
  $$CampaignRunsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get campaignId => $composableBuilder(
    column: $table.campaignId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isHardened => $composableBuilder(
    column: $table.isHardened,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get grade => $composableBuilder(
    column: $table.grade,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CampaignRunsTableOrderingComposer
    extends Composer<_$FeralDatabase, $CampaignRunsTable> {
  $$CampaignRunsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get campaignId => $composableBuilder(
    column: $table.campaignId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isHardened => $composableBuilder(
    column: $table.isHardened,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get grade => $composableBuilder(
    column: $table.grade,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CampaignRunsTableAnnotationComposer
    extends Composer<_$FeralDatabase, $CampaignRunsTable> {
  $$CampaignRunsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get campaignId => $composableBuilder(
    column: $table.campaignId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<bool> get isHardened => $composableBuilder(
    column: $table.isHardened,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get grade =>
      $composableBuilder(column: $table.grade, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => column);
}

class $$CampaignRunsTableTableManager
    extends
        RootTableManager<
          _$FeralDatabase,
          $CampaignRunsTable,
          CampaignRunRow,
          $$CampaignRunsTableFilterComposer,
          $$CampaignRunsTableOrderingComposer,
          $$CampaignRunsTableAnnotationComposer,
          $$CampaignRunsTableCreateCompanionBuilder,
          $$CampaignRunsTableUpdateCompanionBuilder,
          (
            CampaignRunRow,
            BaseReferences<_$FeralDatabase, $CampaignRunsTable, CampaignRunRow>,
          ),
          CampaignRunRow,
          PrefetchHooks Function()
        > {
  $$CampaignRunsTableTableManager(_$FeralDatabase db, $CampaignRunsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CampaignRunsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CampaignRunsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CampaignRunsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> campaignId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<bool> isHardened = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<String?> grade = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CampaignRunsCompanion(
                id: id,
                userId: userId,
                campaignId: campaignId,
                status: status,
                isHardened: isHardened,
                startedAt: startedAt,
                completedAt: completedAt,
                grade: grade,
                updatedAt: updatedAt,
                dirty: dirty,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String campaignId,
                required String status,
                Value<bool> isHardened = const Value.absent(),
                required DateTime startedAt,
                Value<DateTime?> completedAt = const Value.absent(),
                Value<String?> grade = const Value.absent(),
                required DateTime updatedAt,
                Value<bool> dirty = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CampaignRunsCompanion.insert(
                id: id,
                userId: userId,
                campaignId: campaignId,
                status: status,
                isHardened: isHardened,
                startedAt: startedAt,
                completedAt: completedAt,
                grade: grade,
                updatedAt: updatedAt,
                dirty: dirty,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CampaignRunsTableProcessedTableManager =
    ProcessedTableManager<
      _$FeralDatabase,
      $CampaignRunsTable,
      CampaignRunRow,
      $$CampaignRunsTableFilterComposer,
      $$CampaignRunsTableOrderingComposer,
      $$CampaignRunsTableAnnotationComposer,
      $$CampaignRunsTableCreateCompanionBuilder,
      $$CampaignRunsTableUpdateCompanionBuilder,
      (
        CampaignRunRow,
        BaseReferences<_$FeralDatabase, $CampaignRunsTable, CampaignRunRow>,
      ),
      CampaignRunRow,
      PrefetchHooks Function()
    >;
typedef $$DayLogsTableCreateCompanionBuilder =
    DayLogsCompanion Function({
      required String id,
      required String userId,
      required String runId,
      required int dayIndex,
      required String actionId,
      Value<DateTime?> committedAt,
      Value<String?> outcome,
      Value<String?> note,
      required DateTime updatedAt,
      Value<bool> dirty,
      Value<int> rowid,
    });
typedef $$DayLogsTableUpdateCompanionBuilder =
    DayLogsCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> runId,
      Value<int> dayIndex,
      Value<String> actionId,
      Value<DateTime?> committedAt,
      Value<String?> outcome,
      Value<String?> note,
      Value<DateTime> updatedAt,
      Value<bool> dirty,
      Value<int> rowid,
    });

class $$DayLogsTableFilterComposer
    extends Composer<_$FeralDatabase, $DayLogsTable> {
  $$DayLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get runId => $composableBuilder(
    column: $table.runId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dayIndex => $composableBuilder(
    column: $table.dayIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get actionId => $composableBuilder(
    column: $table.actionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get committedAt => $composableBuilder(
    column: $table.committedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get outcome => $composableBuilder(
    column: $table.outcome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DayLogsTableOrderingComposer
    extends Composer<_$FeralDatabase, $DayLogsTable> {
  $$DayLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get runId => $composableBuilder(
    column: $table.runId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dayIndex => $composableBuilder(
    column: $table.dayIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get actionId => $composableBuilder(
    column: $table.actionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get committedAt => $composableBuilder(
    column: $table.committedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get outcome => $composableBuilder(
    column: $table.outcome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DayLogsTableAnnotationComposer
    extends Composer<_$FeralDatabase, $DayLogsTable> {
  $$DayLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get runId =>
      $composableBuilder(column: $table.runId, builder: (column) => column);

  GeneratedColumn<int> get dayIndex =>
      $composableBuilder(column: $table.dayIndex, builder: (column) => column);

  GeneratedColumn<String> get actionId =>
      $composableBuilder(column: $table.actionId, builder: (column) => column);

  GeneratedColumn<DateTime> get committedAt => $composableBuilder(
    column: $table.committedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get outcome =>
      $composableBuilder(column: $table.outcome, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => column);
}

class $$DayLogsTableTableManager
    extends
        RootTableManager<
          _$FeralDatabase,
          $DayLogsTable,
          DayLogRow,
          $$DayLogsTableFilterComposer,
          $$DayLogsTableOrderingComposer,
          $$DayLogsTableAnnotationComposer,
          $$DayLogsTableCreateCompanionBuilder,
          $$DayLogsTableUpdateCompanionBuilder,
          (
            DayLogRow,
            BaseReferences<_$FeralDatabase, $DayLogsTable, DayLogRow>,
          ),
          DayLogRow,
          PrefetchHooks Function()
        > {
  $$DayLogsTableTableManager(_$FeralDatabase db, $DayLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DayLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DayLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DayLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> runId = const Value.absent(),
                Value<int> dayIndex = const Value.absent(),
                Value<String> actionId = const Value.absent(),
                Value<DateTime?> committedAt = const Value.absent(),
                Value<String?> outcome = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DayLogsCompanion(
                id: id,
                userId: userId,
                runId: runId,
                dayIndex: dayIndex,
                actionId: actionId,
                committedAt: committedAt,
                outcome: outcome,
                note: note,
                updatedAt: updatedAt,
                dirty: dirty,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String runId,
                required int dayIndex,
                required String actionId,
                Value<DateTime?> committedAt = const Value.absent(),
                Value<String?> outcome = const Value.absent(),
                Value<String?> note = const Value.absent(),
                required DateTime updatedAt,
                Value<bool> dirty = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DayLogsCompanion.insert(
                id: id,
                userId: userId,
                runId: runId,
                dayIndex: dayIndex,
                actionId: actionId,
                committedAt: committedAt,
                outcome: outcome,
                note: note,
                updatedAt: updatedAt,
                dirty: dirty,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DayLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$FeralDatabase,
      $DayLogsTable,
      DayLogRow,
      $$DayLogsTableFilterComposer,
      $$DayLogsTableOrderingComposer,
      $$DayLogsTableAnnotationComposer,
      $$DayLogsTableCreateCompanionBuilder,
      $$DayLogsTableUpdateCompanionBuilder,
      (DayLogRow, BaseReferences<_$FeralDatabase, $DayLogsTable, DayLogRow>),
      DayLogRow,
      PrefetchHooks Function()
    >;
typedef $$DiagnosticResultsTableCreateCompanionBuilder =
    DiagnosticResultsCompanion Function({
      required String id,
      required String userId,
      required DateTime takenAt,
      required String scores,
      required String weakestArchetypeId,
      required String recommendedCampaignId,
      required DateTime updatedAt,
      Value<bool> dirty,
      Value<int> rowid,
    });
typedef $$DiagnosticResultsTableUpdateCompanionBuilder =
    DiagnosticResultsCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<DateTime> takenAt,
      Value<String> scores,
      Value<String> weakestArchetypeId,
      Value<String> recommendedCampaignId,
      Value<DateTime> updatedAt,
      Value<bool> dirty,
      Value<int> rowid,
    });

class $$DiagnosticResultsTableFilterComposer
    extends Composer<_$FeralDatabase, $DiagnosticResultsTable> {
  $$DiagnosticResultsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get takenAt => $composableBuilder(
    column: $table.takenAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scores => $composableBuilder(
    column: $table.scores,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get weakestArchetypeId => $composableBuilder(
    column: $table.weakestArchetypeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recommendedCampaignId => $composableBuilder(
    column: $table.recommendedCampaignId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DiagnosticResultsTableOrderingComposer
    extends Composer<_$FeralDatabase, $DiagnosticResultsTable> {
  $$DiagnosticResultsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get takenAt => $composableBuilder(
    column: $table.takenAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scores => $composableBuilder(
    column: $table.scores,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get weakestArchetypeId => $composableBuilder(
    column: $table.weakestArchetypeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recommendedCampaignId => $composableBuilder(
    column: $table.recommendedCampaignId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DiagnosticResultsTableAnnotationComposer
    extends Composer<_$FeralDatabase, $DiagnosticResultsTable> {
  $$DiagnosticResultsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<DateTime> get takenAt =>
      $composableBuilder(column: $table.takenAt, builder: (column) => column);

  GeneratedColumn<String> get scores =>
      $composableBuilder(column: $table.scores, builder: (column) => column);

  GeneratedColumn<String> get weakestArchetypeId => $composableBuilder(
    column: $table.weakestArchetypeId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get recommendedCampaignId => $composableBuilder(
    column: $table.recommendedCampaignId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => column);
}

class $$DiagnosticResultsTableTableManager
    extends
        RootTableManager<
          _$FeralDatabase,
          $DiagnosticResultsTable,
          DiagnosticResultRow,
          $$DiagnosticResultsTableFilterComposer,
          $$DiagnosticResultsTableOrderingComposer,
          $$DiagnosticResultsTableAnnotationComposer,
          $$DiagnosticResultsTableCreateCompanionBuilder,
          $$DiagnosticResultsTableUpdateCompanionBuilder,
          (
            DiagnosticResultRow,
            BaseReferences<
              _$FeralDatabase,
              $DiagnosticResultsTable,
              DiagnosticResultRow
            >,
          ),
          DiagnosticResultRow,
          PrefetchHooks Function()
        > {
  $$DiagnosticResultsTableTableManager(
    _$FeralDatabase db,
    $DiagnosticResultsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DiagnosticResultsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DiagnosticResultsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DiagnosticResultsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<DateTime> takenAt = const Value.absent(),
                Value<String> scores = const Value.absent(),
                Value<String> weakestArchetypeId = const Value.absent(),
                Value<String> recommendedCampaignId = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DiagnosticResultsCompanion(
                id: id,
                userId: userId,
                takenAt: takenAt,
                scores: scores,
                weakestArchetypeId: weakestArchetypeId,
                recommendedCampaignId: recommendedCampaignId,
                updatedAt: updatedAt,
                dirty: dirty,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required DateTime takenAt,
                required String scores,
                required String weakestArchetypeId,
                required String recommendedCampaignId,
                required DateTime updatedAt,
                Value<bool> dirty = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DiagnosticResultsCompanion.insert(
                id: id,
                userId: userId,
                takenAt: takenAt,
                scores: scores,
                weakestArchetypeId: weakestArchetypeId,
                recommendedCampaignId: recommendedCampaignId,
                updatedAt: updatedAt,
                dirty: dirty,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DiagnosticResultsTableProcessedTableManager =
    ProcessedTableManager<
      _$FeralDatabase,
      $DiagnosticResultsTable,
      DiagnosticResultRow,
      $$DiagnosticResultsTableFilterComposer,
      $$DiagnosticResultsTableOrderingComposer,
      $$DiagnosticResultsTableAnnotationComposer,
      $$DiagnosticResultsTableCreateCompanionBuilder,
      $$DiagnosticResultsTableUpdateCompanionBuilder,
      (
        DiagnosticResultRow,
        BaseReferences<
          _$FeralDatabase,
          $DiagnosticResultsTable,
          DiagnosticResultRow
        >,
      ),
      DiagnosticResultRow,
      PrefetchHooks Function()
    >;
typedef $$SyncStateTableCreateCompanionBuilder =
    SyncStateCompanion Function({
      required String syncTable,
      Value<DateTime?> watermark,
      Value<DateTime?> lastPulledAt,
      Value<int> rowid,
    });
typedef $$SyncStateTableUpdateCompanionBuilder =
    SyncStateCompanion Function({
      Value<String> syncTable,
      Value<DateTime?> watermark,
      Value<DateTime?> lastPulledAt,
      Value<int> rowid,
    });

class $$SyncStateTableFilterComposer
    extends Composer<_$FeralDatabase, $SyncStateTable> {
  $$SyncStateTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get syncTable => $composableBuilder(
    column: $table.syncTable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get watermark => $composableBuilder(
    column: $table.watermark,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastPulledAt => $composableBuilder(
    column: $table.lastPulledAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncStateTableOrderingComposer
    extends Composer<_$FeralDatabase, $SyncStateTable> {
  $$SyncStateTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get syncTable => $composableBuilder(
    column: $table.syncTable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get watermark => $composableBuilder(
    column: $table.watermark,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastPulledAt => $composableBuilder(
    column: $table.lastPulledAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncStateTableAnnotationComposer
    extends Composer<_$FeralDatabase, $SyncStateTable> {
  $$SyncStateTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get syncTable =>
      $composableBuilder(column: $table.syncTable, builder: (column) => column);

  GeneratedColumn<DateTime> get watermark =>
      $composableBuilder(column: $table.watermark, builder: (column) => column);

  GeneratedColumn<DateTime> get lastPulledAt => $composableBuilder(
    column: $table.lastPulledAt,
    builder: (column) => column,
  );
}

class $$SyncStateTableTableManager
    extends
        RootTableManager<
          _$FeralDatabase,
          $SyncStateTable,
          SyncStateRow,
          $$SyncStateTableFilterComposer,
          $$SyncStateTableOrderingComposer,
          $$SyncStateTableAnnotationComposer,
          $$SyncStateTableCreateCompanionBuilder,
          $$SyncStateTableUpdateCompanionBuilder,
          (
            SyncStateRow,
            BaseReferences<_$FeralDatabase, $SyncStateTable, SyncStateRow>,
          ),
          SyncStateRow,
          PrefetchHooks Function()
        > {
  $$SyncStateTableTableManager(_$FeralDatabase db, $SyncStateTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncStateTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncStateTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncStateTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> syncTable = const Value.absent(),
                Value<DateTime?> watermark = const Value.absent(),
                Value<DateTime?> lastPulledAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncStateCompanion(
                syncTable: syncTable,
                watermark: watermark,
                lastPulledAt: lastPulledAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String syncTable,
                Value<DateTime?> watermark = const Value.absent(),
                Value<DateTime?> lastPulledAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncStateCompanion.insert(
                syncTable: syncTable,
                watermark: watermark,
                lastPulledAt: lastPulledAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncStateTableProcessedTableManager =
    ProcessedTableManager<
      _$FeralDatabase,
      $SyncStateTable,
      SyncStateRow,
      $$SyncStateTableFilterComposer,
      $$SyncStateTableOrderingComposer,
      $$SyncStateTableAnnotationComposer,
      $$SyncStateTableCreateCompanionBuilder,
      $$SyncStateTableUpdateCompanionBuilder,
      (
        SyncStateRow,
        BaseReferences<_$FeralDatabase, $SyncStateTable, SyncStateRow>,
      ),
      SyncStateRow,
      PrefetchHooks Function()
    >;

class $FeralDatabaseManager {
  final _$FeralDatabase _db;
  $FeralDatabaseManager(this._db);
  $$ArchetypesTableTableManager get archetypes =>
      $$ArchetypesTableTableManager(_db, _db.archetypes);
  $$PacksTableTableManager get packs =>
      $$PacksTableTableManager(_db, _db.packs);
  $$CampaignsTableTableManager get campaigns =>
      $$CampaignsTableTableManager(_db, _db.campaigns);
  $$CampaignArchetypesTableTableManager get campaignArchetypes =>
      $$CampaignArchetypesTableTableManager(_db, _db.campaignArchetypes);
  $$ActionsTableTableManager get actions =>
      $$ActionsTableTableManager(_db, _db.actions);
  $$DoctrineGroupsTableTableManager get doctrineGroups =>
      $$DoctrineGroupsTableTableManager(_db, _db.doctrineGroups);
  $$DoctrineEntriesTableTableManager get doctrineEntries =>
      $$DoctrineEntriesTableTableManager(_db, _db.doctrineEntries);
  $$DiagnosticQuestionsTableTableManager get diagnosticQuestions =>
      $$DiagnosticQuestionsTableTableManager(_db, _db.diagnosticQuestions);
  $$DiagnosticOptionsTableTableManager get diagnosticOptions =>
      $$DiagnosticOptionsTableTableManager(_db, _db.diagnosticOptions);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db, _db.profiles);
  $$CampaignRunsTableTableManager get campaignRuns =>
      $$CampaignRunsTableTableManager(_db, _db.campaignRuns);
  $$DayLogsTableTableManager get dayLogs =>
      $$DayLogsTableTableManager(_db, _db.dayLogs);
  $$DiagnosticResultsTableTableManager get diagnosticResults =>
      $$DiagnosticResultsTableTableManager(_db, _db.diagnosticResults);
  $$SyncStateTableTableManager get syncState =>
      $$SyncStateTableTableManager(_db, _db.syncState);
}
