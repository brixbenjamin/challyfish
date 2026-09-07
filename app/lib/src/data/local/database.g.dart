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

abstract class _$FeralDatabase extends GeneratedDatabase {
  _$FeralDatabase(QueryExecutor e) : super(e);
  $FeralDatabaseManager get managers => $FeralDatabaseManager(this);
  late final $ArchetypesTable archetypes = $ArchetypesTable(this);
  late final $PacksTable packs = $PacksTable(this);
  late final $CampaignsTable campaigns = $CampaignsTable(this);
  late final $ActionsTable actions = $ActionsTable(this);
  late final $CampaignRunsTable campaignRuns = $CampaignRunsTable(this);
  late final $DayLogsTable dayLogs = $DayLogsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    archetypes,
    packs,
    campaigns,
    actions,
    campaignRuns,
    dayLogs,
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

class $FeralDatabaseManager {
  final _$FeralDatabase _db;
  $FeralDatabaseManager(this._db);
  $$ArchetypesTableTableManager get archetypes =>
      $$ArchetypesTableTableManager(_db, _db.archetypes);
  $$PacksTableTableManager get packs =>
      $$PacksTableTableManager(_db, _db.packs);
  $$CampaignsTableTableManager get campaigns =>
      $$CampaignsTableTableManager(_db, _db.campaigns);
  $$ActionsTableTableManager get actions =>
      $$ActionsTableTableManager(_db, _db.actions);
  $$CampaignRunsTableTableManager get campaignRuns =>
      $$CampaignRunsTableTableManager(_db, _db.campaignRuns);
  $$DayLogsTableTableManager get dayLogs =>
      $$DayLogsTableTableManager(_db, _db.dayLogs);
}
