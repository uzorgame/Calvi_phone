// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $MealsTable extends Meals with TableInfo<$MealsTable, MealRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MealsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dirtyMeta = const VerificationMeta('dirty');
  @override
  late final GeneratedColumn<bool> dirty = GeneratedColumn<bool>(
    'dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("dirty" IN (0, 1))'),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _seqMeta = const VerificationMeta('seq');
  @override
  late final GeneratedColumn<int> seq = GeneratedColumn<int>(
    'seq',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<String> day = GeneratedColumn<String>(
    'day',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(minTextLength: 10, maxTextLength: 10),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _atMeta = const VerificationMeta('at');
  @override
  late final GeneratedColumn<DateTime> at = GeneratedColumn<DateTime>(
    'at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tzOffsetMinMeta = const VerificationMeta('tzOffsetMin');
  @override
  late final GeneratedColumn<int> tzOffsetMin = GeneratedColumn<int>(
    'tz_offset_min',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _slotMeta = const VerificationMeta('slot');
  @override
  late final GeneratedColumn<String> slot = GeneratedColumn<String>(
    'slot',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _canonicalNameMeta = const VerificationMeta('canonicalName');
  @override
  late final GeneratedColumn<String> canonicalName = GeneratedColumn<String>(
    'canonical_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('plate'),
  );
  static const VerificationMeta _gramsMeta = const VerificationMeta('grams');
  @override
  late final GeneratedColumn<double> grams = GeneratedColumn<double>(
    'grams',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _kcalMeta = const VerificationMeta('kcal');
  @override
  late final GeneratedColumn<int> kcal = GeneratedColumn<int>(
    'kcal',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _proteinGMeta = const VerificationMeta('proteinG');
  @override
  late final GeneratedColumn<double> proteinG = GeneratedColumn<double>(
    'protein_g',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _fatGMeta = const VerificationMeta('fatG');
  @override
  late final GeneratedColumn<double> fatG = GeneratedColumn<double>(
    'fat_g',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _carbsGMeta = const VerificationMeta('carbsG');
  @override
  late final GeneratedColumn<double> carbsG = GeneratedColumn<double>(
    'carbs_g',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('manual'),
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    updatedAt,
    deletedAt,
    dirty,
    seq,
    day,
    at,
    tzOffsetMin,
    slot,
    name,
    canonicalName,
    icon,
    grams,
    kcal,
    proteinG,
    fatG,
    carbsG,
    source,
    note,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'meals';
  @override
  VerificationContext validateIntegrity(Insertable<MealRow> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('dirty')) {
      context.handle(_dirtyMeta, dirty.isAcceptableOrUnknown(data['dirty']!, _dirtyMeta));
    }
    if (data.containsKey('seq')) {
      context.handle(_seqMeta, seq.isAcceptableOrUnknown(data['seq']!, _seqMeta));
    }
    if (data.containsKey('day')) {
      context.handle(_dayMeta, day.isAcceptableOrUnknown(data['day']!, _dayMeta));
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('at')) {
      context.handle(_atMeta, at.isAcceptableOrUnknown(data['at']!, _atMeta));
    } else if (isInserting) {
      context.missing(_atMeta);
    }
    if (data.containsKey('tz_offset_min')) {
      context.handle(
        _tzOffsetMinMeta,
        tzOffsetMin.isAcceptableOrUnknown(data['tz_offset_min']!, _tzOffsetMinMeta),
      );
    }
    if (data.containsKey('slot')) {
      context.handle(_slotMeta, slot.isAcceptableOrUnknown(data['slot']!, _slotMeta));
    } else if (isInserting) {
      context.missing(_slotMeta);
    }
    if (data.containsKey('name')) {
      context.handle(_nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('canonical_name')) {
      context.handle(
        _canonicalNameMeta,
        canonicalName.isAcceptableOrUnknown(data['canonical_name']!, _canonicalNameMeta),
      );
    }
    if (data.containsKey('icon')) {
      context.handle(_iconMeta, icon.isAcceptableOrUnknown(data['icon']!, _iconMeta));
    }
    if (data.containsKey('grams')) {
      context.handle(_gramsMeta, grams.isAcceptableOrUnknown(data['grams']!, _gramsMeta));
    }
    if (data.containsKey('kcal')) {
      context.handle(_kcalMeta, kcal.isAcceptableOrUnknown(data['kcal']!, _kcalMeta));
    } else if (isInserting) {
      context.missing(_kcalMeta);
    }
    if (data.containsKey('protein_g')) {
      context.handle(
        _proteinGMeta,
        proteinG.isAcceptableOrUnknown(data['protein_g']!, _proteinGMeta),
      );
    }
    if (data.containsKey('fat_g')) {
      context.handle(_fatGMeta, fatG.isAcceptableOrUnknown(data['fat_g']!, _fatGMeta));
    }
    if (data.containsKey('carbs_g')) {
      context.handle(_carbsGMeta, carbsG.isAcceptableOrUnknown(data['carbs_g']!, _carbsGMeta));
    }
    if (data.containsKey('source')) {
      context.handle(_sourceMeta, source.isAcceptableOrUnknown(data['source']!, _sourceMeta));
    }
    if (data.containsKey('note')) {
      context.handle(_noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MealRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MealRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      dirty: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}dirty'])!,
      seq: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}seq']),
      day: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}day'])!,
      at: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}at'])!,
      tzOffsetMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tz_offset_min'],
      )!,
      slot: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}slot'])!,
      name: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      canonicalName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}canonical_name'],
      ),
      icon: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}icon'])!,
      grams: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}grams'],
      ),
      kcal: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}kcal'])!,
      proteinG: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}protein_g'],
      )!,
      fatG: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fat_g'],
      )!,
      carbsG: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}carbs_g'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      note: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}note']),
    );
  }

  @override
  $MealsTable createAlias(String alias) {
    return $MealsTable(attachedDatabase, alias);
  }
}

class MealRow extends DataClass implements Insertable<MealRow> {
  final String id;

  /// When this device last changed the row. Not a sync cursor: the server's
  /// [seq] is the cursor, because a phone clock is not evidence.
  final DateTime updatedAt;

  /// Set instead of deleting the row.
  final DateTime? deletedAt;

  /// True while the server has not acknowledged this version.
  final bool dirty;

  /// The number the server gave this version, null while it has never been sent.
  final int? seq;

  /// The local calendar day it belongs to, as yyyy-mm-dd. Stored apart from the
  /// instant so that moving to another timezone does not move last week's
  /// breakfasts to another hour.
  final String day;
  final DateTime at;
  final int tzOffsetMin;

  /// breakfast, lunch, dinner, snack.
  final String slot;
  final String name;

  /// What the food reference knows it by, which is what keeps «борщ» at the same
  /// numbers every time. Null while nothing matched.
  final String? canonicalName;
  final String icon;
  final double? grams;
  final int kcal;
  final double proteinG;
  final double fatG;
  final double carbsG;

  /// manual, chat, photo, barcode, copy. Decides whether it cost a token.
  final String source;
  final String? note;
  const MealRow({
    required this.id,
    required this.updatedAt,
    this.deletedAt,
    required this.dirty,
    this.seq,
    required this.day,
    required this.at,
    required this.tzOffsetMin,
    required this.slot,
    required this.name,
    this.canonicalName,
    required this.icon,
    this.grams,
    required this.kcal,
    required this.proteinG,
    required this.fatG,
    required this.carbsG,
    required this.source,
    this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['dirty'] = Variable<bool>(dirty);
    if (!nullToAbsent || seq != null) {
      map['seq'] = Variable<int>(seq);
    }
    map['day'] = Variable<String>(day);
    map['at'] = Variable<DateTime>(at);
    map['tz_offset_min'] = Variable<int>(tzOffsetMin);
    map['slot'] = Variable<String>(slot);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || canonicalName != null) {
      map['canonical_name'] = Variable<String>(canonicalName);
    }
    map['icon'] = Variable<String>(icon);
    if (!nullToAbsent || grams != null) {
      map['grams'] = Variable<double>(grams);
    }
    map['kcal'] = Variable<int>(kcal);
    map['protein_g'] = Variable<double>(proteinG);
    map['fat_g'] = Variable<double>(fatG);
    map['carbs_g'] = Variable<double>(carbsG);
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  MealsCompanion toCompanion(bool nullToAbsent) {
    return MealsCompanion(
      id: Value(id),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent ? const Value.absent() : Value(deletedAt),
      dirty: Value(dirty),
      seq: seq == null && nullToAbsent ? const Value.absent() : Value(seq),
      day: Value(day),
      at: Value(at),
      tzOffsetMin: Value(tzOffsetMin),
      slot: Value(slot),
      name: Value(name),
      canonicalName: canonicalName == null && nullToAbsent
          ? const Value.absent()
          : Value(canonicalName),
      icon: Value(icon),
      grams: grams == null && nullToAbsent ? const Value.absent() : Value(grams),
      kcal: Value(kcal),
      proteinG: Value(proteinG),
      fatG: Value(fatG),
      carbsG: Value(carbsG),
      source: Value(source),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory MealRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MealRow(
      id: serializer.fromJson<String>(json['id']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      dirty: serializer.fromJson<bool>(json['dirty']),
      seq: serializer.fromJson<int?>(json['seq']),
      day: serializer.fromJson<String>(json['day']),
      at: serializer.fromJson<DateTime>(json['at']),
      tzOffsetMin: serializer.fromJson<int>(json['tzOffsetMin']),
      slot: serializer.fromJson<String>(json['slot']),
      name: serializer.fromJson<String>(json['name']),
      canonicalName: serializer.fromJson<String?>(json['canonicalName']),
      icon: serializer.fromJson<String>(json['icon']),
      grams: serializer.fromJson<double?>(json['grams']),
      kcal: serializer.fromJson<int>(json['kcal']),
      proteinG: serializer.fromJson<double>(json['proteinG']),
      fatG: serializer.fromJson<double>(json['fatG']),
      carbsG: serializer.fromJson<double>(json['carbsG']),
      source: serializer.fromJson<String>(json['source']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'dirty': serializer.toJson<bool>(dirty),
      'seq': serializer.toJson<int?>(seq),
      'day': serializer.toJson<String>(day),
      'at': serializer.toJson<DateTime>(at),
      'tzOffsetMin': serializer.toJson<int>(tzOffsetMin),
      'slot': serializer.toJson<String>(slot),
      'name': serializer.toJson<String>(name),
      'canonicalName': serializer.toJson<String?>(canonicalName),
      'icon': serializer.toJson<String>(icon),
      'grams': serializer.toJson<double?>(grams),
      'kcal': serializer.toJson<int>(kcal),
      'proteinG': serializer.toJson<double>(proteinG),
      'fatG': serializer.toJson<double>(fatG),
      'carbsG': serializer.toJson<double>(carbsG),
      'source': serializer.toJson<String>(source),
      'note': serializer.toJson<String?>(note),
    };
  }

  MealRow copyWith({
    String? id,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    bool? dirty,
    Value<int?> seq = const Value.absent(),
    String? day,
    DateTime? at,
    int? tzOffsetMin,
    String? slot,
    String? name,
    Value<String?> canonicalName = const Value.absent(),
    String? icon,
    Value<double?> grams = const Value.absent(),
    int? kcal,
    double? proteinG,
    double? fatG,
    double? carbsG,
    String? source,
    Value<String?> note = const Value.absent(),
  }) => MealRow(
    id: id ?? this.id,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    dirty: dirty ?? this.dirty,
    seq: seq.present ? seq.value : this.seq,
    day: day ?? this.day,
    at: at ?? this.at,
    tzOffsetMin: tzOffsetMin ?? this.tzOffsetMin,
    slot: slot ?? this.slot,
    name: name ?? this.name,
    canonicalName: canonicalName.present ? canonicalName.value : this.canonicalName,
    icon: icon ?? this.icon,
    grams: grams.present ? grams.value : this.grams,
    kcal: kcal ?? this.kcal,
    proteinG: proteinG ?? this.proteinG,
    fatG: fatG ?? this.fatG,
    carbsG: carbsG ?? this.carbsG,
    source: source ?? this.source,
    note: note.present ? note.value : this.note,
  );
  MealRow copyWithCompanion(MealsCompanion data) {
    return MealRow(
      id: data.id.present ? data.id.value : this.id,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
      seq: data.seq.present ? data.seq.value : this.seq,
      day: data.day.present ? data.day.value : this.day,
      at: data.at.present ? data.at.value : this.at,
      tzOffsetMin: data.tzOffsetMin.present ? data.tzOffsetMin.value : this.tzOffsetMin,
      slot: data.slot.present ? data.slot.value : this.slot,
      name: data.name.present ? data.name.value : this.name,
      canonicalName: data.canonicalName.present ? data.canonicalName.value : this.canonicalName,
      icon: data.icon.present ? data.icon.value : this.icon,
      grams: data.grams.present ? data.grams.value : this.grams,
      kcal: data.kcal.present ? data.kcal.value : this.kcal,
      proteinG: data.proteinG.present ? data.proteinG.value : this.proteinG,
      fatG: data.fatG.present ? data.fatG.value : this.fatG,
      carbsG: data.carbsG.present ? data.carbsG.value : this.carbsG,
      source: data.source.present ? data.source.value : this.source,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MealRow(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('dirty: $dirty, ')
          ..write('seq: $seq, ')
          ..write('day: $day, ')
          ..write('at: $at, ')
          ..write('tzOffsetMin: $tzOffsetMin, ')
          ..write('slot: $slot, ')
          ..write('name: $name, ')
          ..write('canonicalName: $canonicalName, ')
          ..write('icon: $icon, ')
          ..write('grams: $grams, ')
          ..write('kcal: $kcal, ')
          ..write('proteinG: $proteinG, ')
          ..write('fatG: $fatG, ')
          ..write('carbsG: $carbsG, ')
          ..write('source: $source, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    updatedAt,
    deletedAt,
    dirty,
    seq,
    day,
    at,
    tzOffsetMin,
    slot,
    name,
    canonicalName,
    icon,
    grams,
    kcal,
    proteinG,
    fatG,
    carbsG,
    source,
    note,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MealRow &&
          other.id == this.id &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.dirty == this.dirty &&
          other.seq == this.seq &&
          other.day == this.day &&
          other.at == this.at &&
          other.tzOffsetMin == this.tzOffsetMin &&
          other.slot == this.slot &&
          other.name == this.name &&
          other.canonicalName == this.canonicalName &&
          other.icon == this.icon &&
          other.grams == this.grams &&
          other.kcal == this.kcal &&
          other.proteinG == this.proteinG &&
          other.fatG == this.fatG &&
          other.carbsG == this.carbsG &&
          other.source == this.source &&
          other.note == this.note);
}

class MealsCompanion extends UpdateCompanion<MealRow> {
  final Value<String> id;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<bool> dirty;
  final Value<int?> seq;
  final Value<String> day;
  final Value<DateTime> at;
  final Value<int> tzOffsetMin;
  final Value<String> slot;
  final Value<String> name;
  final Value<String?> canonicalName;
  final Value<String> icon;
  final Value<double?> grams;
  final Value<int> kcal;
  final Value<double> proteinG;
  final Value<double> fatG;
  final Value<double> carbsG;
  final Value<String> source;
  final Value<String?> note;
  final Value<int> rowid;
  const MealsCompanion({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.dirty = const Value.absent(),
    this.seq = const Value.absent(),
    this.day = const Value.absent(),
    this.at = const Value.absent(),
    this.tzOffsetMin = const Value.absent(),
    this.slot = const Value.absent(),
    this.name = const Value.absent(),
    this.canonicalName = const Value.absent(),
    this.icon = const Value.absent(),
    this.grams = const Value.absent(),
    this.kcal = const Value.absent(),
    this.proteinG = const Value.absent(),
    this.fatG = const Value.absent(),
    this.carbsG = const Value.absent(),
    this.source = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MealsCompanion.insert({
    required String id,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.dirty = const Value.absent(),
    this.seq = const Value.absent(),
    required String day,
    required DateTime at,
    this.tzOffsetMin = const Value.absent(),
    required String slot,
    required String name,
    this.canonicalName = const Value.absent(),
    this.icon = const Value.absent(),
    this.grams = const Value.absent(),
    required int kcal,
    this.proteinG = const Value.absent(),
    this.fatG = const Value.absent(),
    this.carbsG = const Value.absent(),
    this.source = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       updatedAt = Value(updatedAt),
       day = Value(day),
       at = Value(at),
       slot = Value(slot),
       name = Value(name),
       kcal = Value(kcal);
  static Insertable<MealRow> custom({
    Expression<String>? id,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<bool>? dirty,
    Expression<int>? seq,
    Expression<String>? day,
    Expression<DateTime>? at,
    Expression<int>? tzOffsetMin,
    Expression<String>? slot,
    Expression<String>? name,
    Expression<String>? canonicalName,
    Expression<String>? icon,
    Expression<double>? grams,
    Expression<int>? kcal,
    Expression<double>? proteinG,
    Expression<double>? fatG,
    Expression<double>? carbsG,
    Expression<String>? source,
    Expression<String>? note,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (dirty != null) 'dirty': dirty,
      if (seq != null) 'seq': seq,
      if (day != null) 'day': day,
      if (at != null) 'at': at,
      if (tzOffsetMin != null) 'tz_offset_min': tzOffsetMin,
      if (slot != null) 'slot': slot,
      if (name != null) 'name': name,
      if (canonicalName != null) 'canonical_name': canonicalName,
      if (icon != null) 'icon': icon,
      if (grams != null) 'grams': grams,
      if (kcal != null) 'kcal': kcal,
      if (proteinG != null) 'protein_g': proteinG,
      if (fatG != null) 'fat_g': fatG,
      if (carbsG != null) 'carbs_g': carbsG,
      if (source != null) 'source': source,
      if (note != null) 'note': note,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MealsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<bool>? dirty,
    Value<int?>? seq,
    Value<String>? day,
    Value<DateTime>? at,
    Value<int>? tzOffsetMin,
    Value<String>? slot,
    Value<String>? name,
    Value<String?>? canonicalName,
    Value<String>? icon,
    Value<double?>? grams,
    Value<int>? kcal,
    Value<double>? proteinG,
    Value<double>? fatG,
    Value<double>? carbsG,
    Value<String>? source,
    Value<String?>? note,
    Value<int>? rowid,
  }) {
    return MealsCompanion(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      dirty: dirty ?? this.dirty,
      seq: seq ?? this.seq,
      day: day ?? this.day,
      at: at ?? this.at,
      tzOffsetMin: tzOffsetMin ?? this.tzOffsetMin,
      slot: slot ?? this.slot,
      name: name ?? this.name,
      canonicalName: canonicalName ?? this.canonicalName,
      icon: icon ?? this.icon,
      grams: grams ?? this.grams,
      kcal: kcal ?? this.kcal,
      proteinG: proteinG ?? this.proteinG,
      fatG: fatG ?? this.fatG,
      carbsG: carbsG ?? this.carbsG,
      source: source ?? this.source,
      note: note ?? this.note,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<bool>(dirty.value);
    }
    if (seq.present) {
      map['seq'] = Variable<int>(seq.value);
    }
    if (day.present) {
      map['day'] = Variable<String>(day.value);
    }
    if (at.present) {
      map['at'] = Variable<DateTime>(at.value);
    }
    if (tzOffsetMin.present) {
      map['tz_offset_min'] = Variable<int>(tzOffsetMin.value);
    }
    if (slot.present) {
      map['slot'] = Variable<String>(slot.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (canonicalName.present) {
      map['canonical_name'] = Variable<String>(canonicalName.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (grams.present) {
      map['grams'] = Variable<double>(grams.value);
    }
    if (kcal.present) {
      map['kcal'] = Variable<int>(kcal.value);
    }
    if (proteinG.present) {
      map['protein_g'] = Variable<double>(proteinG.value);
    }
    if (fatG.present) {
      map['fat_g'] = Variable<double>(fatG.value);
    }
    if (carbsG.present) {
      map['carbs_g'] = Variable<double>(carbsG.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MealsCompanion(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('dirty: $dirty, ')
          ..write('seq: $seq, ')
          ..write('day: $day, ')
          ..write('at: $at, ')
          ..write('tzOffsetMin: $tzOffsetMin, ')
          ..write('slot: $slot, ')
          ..write('name: $name, ')
          ..write('canonicalName: $canonicalName, ')
          ..write('icon: $icon, ')
          ..write('grams: $grams, ')
          ..write('kcal: $kcal, ')
          ..write('proteinG: $proteinG, ')
          ..write('fatG: $fatG, ')
          ..write('carbsG: $carbsG, ')
          ..write('source: $source, ')
          ..write('note: $note, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WaterLogsTable extends WaterLogs with TableInfo<$WaterLogsTable, WaterLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WaterLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dirtyMeta = const VerificationMeta('dirty');
  @override
  late final GeneratedColumn<bool> dirty = GeneratedColumn<bool>(
    'dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("dirty" IN (0, 1))'),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _seqMeta = const VerificationMeta('seq');
  @override
  late final GeneratedColumn<int> seq = GeneratedColumn<int>(
    'seq',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<String> day = GeneratedColumn<String>(
    'day',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(minTextLength: 10, maxTextLength: 10),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _atMeta = const VerificationMeta('at');
  @override
  late final GeneratedColumn<DateTime> at = GeneratedColumn<DateTime>(
    'at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mlMeta = const VerificationMeta('ml');
  @override
  late final GeneratedColumn<int> ml = GeneratedColumn<int>(
    'ml',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, updatedAt, deletedAt, dirty, seq, day, at, ml];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'water_logs';
  @override
  VerificationContext validateIntegrity(Insertable<WaterLog> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('dirty')) {
      context.handle(_dirtyMeta, dirty.isAcceptableOrUnknown(data['dirty']!, _dirtyMeta));
    }
    if (data.containsKey('seq')) {
      context.handle(_seqMeta, seq.isAcceptableOrUnknown(data['seq']!, _seqMeta));
    }
    if (data.containsKey('day')) {
      context.handle(_dayMeta, day.isAcceptableOrUnknown(data['day']!, _dayMeta));
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('at')) {
      context.handle(_atMeta, at.isAcceptableOrUnknown(data['at']!, _atMeta));
    } else if (isInserting) {
      context.missing(_atMeta);
    }
    if (data.containsKey('ml')) {
      context.handle(_mlMeta, ml.isAcceptableOrUnknown(data['ml']!, _mlMeta));
    } else if (isInserting) {
      context.missing(_mlMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WaterLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WaterLog(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      dirty: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}dirty'])!,
      seq: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}seq']),
      day: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}day'])!,
      at: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}at'])!,
      ml: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}ml'])!,
    );
  }

  @override
  $WaterLogsTable createAlias(String alias) {
    return $WaterLogsTable(attachedDatabase, alias);
  }
}

class WaterLog extends DataClass implements Insertable<WaterLog> {
  final String id;

  /// When this device last changed the row. Not a sync cursor: the server's
  /// [seq] is the cursor, because a phone clock is not evidence.
  final DateTime updatedAt;

  /// Set instead of deleting the row.
  final DateTime? deletedAt;

  /// True while the server has not acknowledged this version.
  final bool dirty;

  /// The number the server gave this version, null while it has never been sent.
  final int? seq;
  final String day;
  final DateTime at;
  final int ml;
  const WaterLog({
    required this.id,
    required this.updatedAt,
    this.deletedAt,
    required this.dirty,
    this.seq,
    required this.day,
    required this.at,
    required this.ml,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['dirty'] = Variable<bool>(dirty);
    if (!nullToAbsent || seq != null) {
      map['seq'] = Variable<int>(seq);
    }
    map['day'] = Variable<String>(day);
    map['at'] = Variable<DateTime>(at);
    map['ml'] = Variable<int>(ml);
    return map;
  }

  WaterLogsCompanion toCompanion(bool nullToAbsent) {
    return WaterLogsCompanion(
      id: Value(id),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent ? const Value.absent() : Value(deletedAt),
      dirty: Value(dirty),
      seq: seq == null && nullToAbsent ? const Value.absent() : Value(seq),
      day: Value(day),
      at: Value(at),
      ml: Value(ml),
    );
  }

  factory WaterLog.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WaterLog(
      id: serializer.fromJson<String>(json['id']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      dirty: serializer.fromJson<bool>(json['dirty']),
      seq: serializer.fromJson<int?>(json['seq']),
      day: serializer.fromJson<String>(json['day']),
      at: serializer.fromJson<DateTime>(json['at']),
      ml: serializer.fromJson<int>(json['ml']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'dirty': serializer.toJson<bool>(dirty),
      'seq': serializer.toJson<int?>(seq),
      'day': serializer.toJson<String>(day),
      'at': serializer.toJson<DateTime>(at),
      'ml': serializer.toJson<int>(ml),
    };
  }

  WaterLog copyWith({
    String? id,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    bool? dirty,
    Value<int?> seq = const Value.absent(),
    String? day,
    DateTime? at,
    int? ml,
  }) => WaterLog(
    id: id ?? this.id,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    dirty: dirty ?? this.dirty,
    seq: seq.present ? seq.value : this.seq,
    day: day ?? this.day,
    at: at ?? this.at,
    ml: ml ?? this.ml,
  );
  WaterLog copyWithCompanion(WaterLogsCompanion data) {
    return WaterLog(
      id: data.id.present ? data.id.value : this.id,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
      seq: data.seq.present ? data.seq.value : this.seq,
      day: data.day.present ? data.day.value : this.day,
      at: data.at.present ? data.at.value : this.at,
      ml: data.ml.present ? data.ml.value : this.ml,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WaterLog(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('dirty: $dirty, ')
          ..write('seq: $seq, ')
          ..write('day: $day, ')
          ..write('at: $at, ')
          ..write('ml: $ml')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, updatedAt, deletedAt, dirty, seq, day, at, ml);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WaterLog &&
          other.id == this.id &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.dirty == this.dirty &&
          other.seq == this.seq &&
          other.day == this.day &&
          other.at == this.at &&
          other.ml == this.ml);
}

class WaterLogsCompanion extends UpdateCompanion<WaterLog> {
  final Value<String> id;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<bool> dirty;
  final Value<int?> seq;
  final Value<String> day;
  final Value<DateTime> at;
  final Value<int> ml;
  final Value<int> rowid;
  const WaterLogsCompanion({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.dirty = const Value.absent(),
    this.seq = const Value.absent(),
    this.day = const Value.absent(),
    this.at = const Value.absent(),
    this.ml = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WaterLogsCompanion.insert({
    required String id,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.dirty = const Value.absent(),
    this.seq = const Value.absent(),
    required String day,
    required DateTime at,
    required int ml,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       updatedAt = Value(updatedAt),
       day = Value(day),
       at = Value(at),
       ml = Value(ml);
  static Insertable<WaterLog> custom({
    Expression<String>? id,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<bool>? dirty,
    Expression<int>? seq,
    Expression<String>? day,
    Expression<DateTime>? at,
    Expression<int>? ml,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (dirty != null) 'dirty': dirty,
      if (seq != null) 'seq': seq,
      if (day != null) 'day': day,
      if (at != null) 'at': at,
      if (ml != null) 'ml': ml,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WaterLogsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<bool>? dirty,
    Value<int?>? seq,
    Value<String>? day,
    Value<DateTime>? at,
    Value<int>? ml,
    Value<int>? rowid,
  }) {
    return WaterLogsCompanion(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      dirty: dirty ?? this.dirty,
      seq: seq ?? this.seq,
      day: day ?? this.day,
      at: at ?? this.at,
      ml: ml ?? this.ml,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<bool>(dirty.value);
    }
    if (seq.present) {
      map['seq'] = Variable<int>(seq.value);
    }
    if (day.present) {
      map['day'] = Variable<String>(day.value);
    }
    if (at.present) {
      map['at'] = Variable<DateTime>(at.value);
    }
    if (ml.present) {
      map['ml'] = Variable<int>(ml.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WaterLogsCompanion(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('dirty: $dirty, ')
          ..write('seq: $seq, ')
          ..write('day: $day, ')
          ..write('at: $at, ')
          ..write('ml: $ml, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WeightsTable extends Weights with TableInfo<$WeightsTable, Weight> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WeightsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dirtyMeta = const VerificationMeta('dirty');
  @override
  late final GeneratedColumn<bool> dirty = GeneratedColumn<bool>(
    'dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("dirty" IN (0, 1))'),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _seqMeta = const VerificationMeta('seq');
  @override
  late final GeneratedColumn<int> seq = GeneratedColumn<int>(
    'seq',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<String> day = GeneratedColumn<String>(
    'day',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(minTextLength: 10, maxTextLength: 10),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _atMeta = const VerificationMeta('at');
  @override
  late final GeneratedColumn<DateTime> at = GeneratedColumn<DateTime>(
    'at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kgMeta = const VerificationMeta('kg');
  @override
  late final GeneratedColumn<double> kg = GeneratedColumn<double>(
    'kg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, updatedAt, deletedAt, dirty, seq, day, at, kg];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'weights';
  @override
  VerificationContext validateIntegrity(Insertable<Weight> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('dirty')) {
      context.handle(_dirtyMeta, dirty.isAcceptableOrUnknown(data['dirty']!, _dirtyMeta));
    }
    if (data.containsKey('seq')) {
      context.handle(_seqMeta, seq.isAcceptableOrUnknown(data['seq']!, _seqMeta));
    }
    if (data.containsKey('day')) {
      context.handle(_dayMeta, day.isAcceptableOrUnknown(data['day']!, _dayMeta));
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('at')) {
      context.handle(_atMeta, at.isAcceptableOrUnknown(data['at']!, _atMeta));
    } else if (isInserting) {
      context.missing(_atMeta);
    }
    if (data.containsKey('kg')) {
      context.handle(_kgMeta, kg.isAcceptableOrUnknown(data['kg']!, _kgMeta));
    } else if (isInserting) {
      context.missing(_kgMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Weight map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Weight(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      dirty: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}dirty'])!,
      seq: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}seq']),
      day: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}day'])!,
      at: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}at'])!,
      kg: attachedDatabase.typeMapping.read(DriftSqlType.double, data['${effectivePrefix}kg'])!,
    );
  }

  @override
  $WeightsTable createAlias(String alias) {
    return $WeightsTable(attachedDatabase, alias);
  }
}

class Weight extends DataClass implements Insertable<Weight> {
  final String id;

  /// When this device last changed the row. Not a sync cursor: the server's
  /// [seq] is the cursor, because a phone clock is not evidence.
  final DateTime updatedAt;

  /// Set instead of deleting the row.
  final DateTime? deletedAt;

  /// True while the server has not acknowledged this version.
  final bool dirty;

  /// The number the server gave this version, null while it has never been sent.
  final int? seq;
  final String day;
  final DateTime at;
  final double kg;
  const Weight({
    required this.id,
    required this.updatedAt,
    this.deletedAt,
    required this.dirty,
    this.seq,
    required this.day,
    required this.at,
    required this.kg,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['dirty'] = Variable<bool>(dirty);
    if (!nullToAbsent || seq != null) {
      map['seq'] = Variable<int>(seq);
    }
    map['day'] = Variable<String>(day);
    map['at'] = Variable<DateTime>(at);
    map['kg'] = Variable<double>(kg);
    return map;
  }

  WeightsCompanion toCompanion(bool nullToAbsent) {
    return WeightsCompanion(
      id: Value(id),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent ? const Value.absent() : Value(deletedAt),
      dirty: Value(dirty),
      seq: seq == null && nullToAbsent ? const Value.absent() : Value(seq),
      day: Value(day),
      at: Value(at),
      kg: Value(kg),
    );
  }

  factory Weight.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Weight(
      id: serializer.fromJson<String>(json['id']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      dirty: serializer.fromJson<bool>(json['dirty']),
      seq: serializer.fromJson<int?>(json['seq']),
      day: serializer.fromJson<String>(json['day']),
      at: serializer.fromJson<DateTime>(json['at']),
      kg: serializer.fromJson<double>(json['kg']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'dirty': serializer.toJson<bool>(dirty),
      'seq': serializer.toJson<int?>(seq),
      'day': serializer.toJson<String>(day),
      'at': serializer.toJson<DateTime>(at),
      'kg': serializer.toJson<double>(kg),
    };
  }

  Weight copyWith({
    String? id,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    bool? dirty,
    Value<int?> seq = const Value.absent(),
    String? day,
    DateTime? at,
    double? kg,
  }) => Weight(
    id: id ?? this.id,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    dirty: dirty ?? this.dirty,
    seq: seq.present ? seq.value : this.seq,
    day: day ?? this.day,
    at: at ?? this.at,
    kg: kg ?? this.kg,
  );
  Weight copyWithCompanion(WeightsCompanion data) {
    return Weight(
      id: data.id.present ? data.id.value : this.id,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
      seq: data.seq.present ? data.seq.value : this.seq,
      day: data.day.present ? data.day.value : this.day,
      at: data.at.present ? data.at.value : this.at,
      kg: data.kg.present ? data.kg.value : this.kg,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Weight(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('dirty: $dirty, ')
          ..write('seq: $seq, ')
          ..write('day: $day, ')
          ..write('at: $at, ')
          ..write('kg: $kg')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, updatedAt, deletedAt, dirty, seq, day, at, kg);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Weight &&
          other.id == this.id &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.dirty == this.dirty &&
          other.seq == this.seq &&
          other.day == this.day &&
          other.at == this.at &&
          other.kg == this.kg);
}

class WeightsCompanion extends UpdateCompanion<Weight> {
  final Value<String> id;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<bool> dirty;
  final Value<int?> seq;
  final Value<String> day;
  final Value<DateTime> at;
  final Value<double> kg;
  final Value<int> rowid;
  const WeightsCompanion({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.dirty = const Value.absent(),
    this.seq = const Value.absent(),
    this.day = const Value.absent(),
    this.at = const Value.absent(),
    this.kg = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WeightsCompanion.insert({
    required String id,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.dirty = const Value.absent(),
    this.seq = const Value.absent(),
    required String day,
    required DateTime at,
    required double kg,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       updatedAt = Value(updatedAt),
       day = Value(day),
       at = Value(at),
       kg = Value(kg);
  static Insertable<Weight> custom({
    Expression<String>? id,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<bool>? dirty,
    Expression<int>? seq,
    Expression<String>? day,
    Expression<DateTime>? at,
    Expression<double>? kg,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (dirty != null) 'dirty': dirty,
      if (seq != null) 'seq': seq,
      if (day != null) 'day': day,
      if (at != null) 'at': at,
      if (kg != null) 'kg': kg,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WeightsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<bool>? dirty,
    Value<int?>? seq,
    Value<String>? day,
    Value<DateTime>? at,
    Value<double>? kg,
    Value<int>? rowid,
  }) {
    return WeightsCompanion(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      dirty: dirty ?? this.dirty,
      seq: seq ?? this.seq,
      day: day ?? this.day,
      at: at ?? this.at,
      kg: kg ?? this.kg,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<bool>(dirty.value);
    }
    if (seq.present) {
      map['seq'] = Variable<int>(seq.value);
    }
    if (day.present) {
      map['day'] = Variable<String>(day.value);
    }
    if (at.present) {
      map['at'] = Variable<DateTime>(at.value);
    }
    if (kg.present) {
      map['kg'] = Variable<double>(kg.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WeightsCompanion(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('dirty: $dirty, ')
          ..write('seq: $seq, ')
          ..write('day: $day, ')
          ..write('at: $at, ')
          ..write('kg: $kg, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MeasurementsTable extends Measurements with TableInfo<$MeasurementsTable, Measurement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MeasurementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dirtyMeta = const VerificationMeta('dirty');
  @override
  late final GeneratedColumn<bool> dirty = GeneratedColumn<bool>(
    'dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("dirty" IN (0, 1))'),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _seqMeta = const VerificationMeta('seq');
  @override
  late final GeneratedColumn<int> seq = GeneratedColumn<int>(
    'seq',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<String> day = GeneratedColumn<String>(
    'day',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(minTextLength: 10, maxTextLength: 10),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _atMeta = const VerificationMeta('at');
  @override
  late final GeneratedColumn<DateTime> at = GeneratedColumn<DateTime>(
    'at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _partMeta = const VerificationMeta('part');
  @override
  late final GeneratedColumn<String> part = GeneratedColumn<String>(
    'part',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cmMeta = const VerificationMeta('cm');
  @override
  late final GeneratedColumn<double> cm = GeneratedColumn<double>(
    'cm',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, updatedAt, deletedAt, dirty, seq, day, at, part, cm];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'measurements';
  @override
  VerificationContext validateIntegrity(
    Insertable<Measurement> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('dirty')) {
      context.handle(_dirtyMeta, dirty.isAcceptableOrUnknown(data['dirty']!, _dirtyMeta));
    }
    if (data.containsKey('seq')) {
      context.handle(_seqMeta, seq.isAcceptableOrUnknown(data['seq']!, _seqMeta));
    }
    if (data.containsKey('day')) {
      context.handle(_dayMeta, day.isAcceptableOrUnknown(data['day']!, _dayMeta));
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('at')) {
      context.handle(_atMeta, at.isAcceptableOrUnknown(data['at']!, _atMeta));
    } else if (isInserting) {
      context.missing(_atMeta);
    }
    if (data.containsKey('part')) {
      context.handle(_partMeta, part.isAcceptableOrUnknown(data['part']!, _partMeta));
    } else if (isInserting) {
      context.missing(_partMeta);
    }
    if (data.containsKey('cm')) {
      context.handle(_cmMeta, cm.isAcceptableOrUnknown(data['cm']!, _cmMeta));
    } else if (isInserting) {
      context.missing(_cmMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Measurement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Measurement(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      dirty: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}dirty'])!,
      seq: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}seq']),
      day: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}day'])!,
      at: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}at'])!,
      part: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}part'])!,
      cm: attachedDatabase.typeMapping.read(DriftSqlType.double, data['${effectivePrefix}cm'])!,
    );
  }

  @override
  $MeasurementsTable createAlias(String alias) {
    return $MeasurementsTable(attachedDatabase, alias);
  }
}

class Measurement extends DataClass implements Insertable<Measurement> {
  final String id;

  /// When this device last changed the row. Not a sync cursor: the server's
  /// [seq] is the cursor, because a phone clock is not evidence.
  final DateTime updatedAt;

  /// Set instead of deleting the row.
  final DateTime? deletedAt;

  /// True while the server has not acknowledged this version.
  final bool dirty;

  /// The number the server gave this version, null while it has never been sent.
  final int? seq;
  final String day;
  final DateTime at;
  final String part;
  final double cm;
  const Measurement({
    required this.id,
    required this.updatedAt,
    this.deletedAt,
    required this.dirty,
    this.seq,
    required this.day,
    required this.at,
    required this.part,
    required this.cm,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['dirty'] = Variable<bool>(dirty);
    if (!nullToAbsent || seq != null) {
      map['seq'] = Variable<int>(seq);
    }
    map['day'] = Variable<String>(day);
    map['at'] = Variable<DateTime>(at);
    map['part'] = Variable<String>(part);
    map['cm'] = Variable<double>(cm);
    return map;
  }

  MeasurementsCompanion toCompanion(bool nullToAbsent) {
    return MeasurementsCompanion(
      id: Value(id),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent ? const Value.absent() : Value(deletedAt),
      dirty: Value(dirty),
      seq: seq == null && nullToAbsent ? const Value.absent() : Value(seq),
      day: Value(day),
      at: Value(at),
      part: Value(part),
      cm: Value(cm),
    );
  }

  factory Measurement.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Measurement(
      id: serializer.fromJson<String>(json['id']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      dirty: serializer.fromJson<bool>(json['dirty']),
      seq: serializer.fromJson<int?>(json['seq']),
      day: serializer.fromJson<String>(json['day']),
      at: serializer.fromJson<DateTime>(json['at']),
      part: serializer.fromJson<String>(json['part']),
      cm: serializer.fromJson<double>(json['cm']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'dirty': serializer.toJson<bool>(dirty),
      'seq': serializer.toJson<int?>(seq),
      'day': serializer.toJson<String>(day),
      'at': serializer.toJson<DateTime>(at),
      'part': serializer.toJson<String>(part),
      'cm': serializer.toJson<double>(cm),
    };
  }

  Measurement copyWith({
    String? id,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    bool? dirty,
    Value<int?> seq = const Value.absent(),
    String? day,
    DateTime? at,
    String? part,
    double? cm,
  }) => Measurement(
    id: id ?? this.id,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    dirty: dirty ?? this.dirty,
    seq: seq.present ? seq.value : this.seq,
    day: day ?? this.day,
    at: at ?? this.at,
    part: part ?? this.part,
    cm: cm ?? this.cm,
  );
  Measurement copyWithCompanion(MeasurementsCompanion data) {
    return Measurement(
      id: data.id.present ? data.id.value : this.id,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
      seq: data.seq.present ? data.seq.value : this.seq,
      day: data.day.present ? data.day.value : this.day,
      at: data.at.present ? data.at.value : this.at,
      part: data.part.present ? data.part.value : this.part,
      cm: data.cm.present ? data.cm.value : this.cm,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Measurement(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('dirty: $dirty, ')
          ..write('seq: $seq, ')
          ..write('day: $day, ')
          ..write('at: $at, ')
          ..write('part: $part, ')
          ..write('cm: $cm')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, updatedAt, deletedAt, dirty, seq, day, at, part, cm);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Measurement &&
          other.id == this.id &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.dirty == this.dirty &&
          other.seq == this.seq &&
          other.day == this.day &&
          other.at == this.at &&
          other.part == this.part &&
          other.cm == this.cm);
}

class MeasurementsCompanion extends UpdateCompanion<Measurement> {
  final Value<String> id;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<bool> dirty;
  final Value<int?> seq;
  final Value<String> day;
  final Value<DateTime> at;
  final Value<String> part;
  final Value<double> cm;
  final Value<int> rowid;
  const MeasurementsCompanion({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.dirty = const Value.absent(),
    this.seq = const Value.absent(),
    this.day = const Value.absent(),
    this.at = const Value.absent(),
    this.part = const Value.absent(),
    this.cm = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MeasurementsCompanion.insert({
    required String id,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.dirty = const Value.absent(),
    this.seq = const Value.absent(),
    required String day,
    required DateTime at,
    required String part,
    required double cm,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       updatedAt = Value(updatedAt),
       day = Value(day),
       at = Value(at),
       part = Value(part),
       cm = Value(cm);
  static Insertable<Measurement> custom({
    Expression<String>? id,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<bool>? dirty,
    Expression<int>? seq,
    Expression<String>? day,
    Expression<DateTime>? at,
    Expression<String>? part,
    Expression<double>? cm,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (dirty != null) 'dirty': dirty,
      if (seq != null) 'seq': seq,
      if (day != null) 'day': day,
      if (at != null) 'at': at,
      if (part != null) 'part': part,
      if (cm != null) 'cm': cm,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MeasurementsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<bool>? dirty,
    Value<int?>? seq,
    Value<String>? day,
    Value<DateTime>? at,
    Value<String>? part,
    Value<double>? cm,
    Value<int>? rowid,
  }) {
    return MeasurementsCompanion(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      dirty: dirty ?? this.dirty,
      seq: seq ?? this.seq,
      day: day ?? this.day,
      at: at ?? this.at,
      part: part ?? this.part,
      cm: cm ?? this.cm,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<bool>(dirty.value);
    }
    if (seq.present) {
      map['seq'] = Variable<int>(seq.value);
    }
    if (day.present) {
      map['day'] = Variable<String>(day.value);
    }
    if (at.present) {
      map['at'] = Variable<DateTime>(at.value);
    }
    if (part.present) {
      map['part'] = Variable<String>(part.value);
    }
    if (cm.present) {
      map['cm'] = Variable<double>(cm.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MeasurementsCompanion(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('dirty: $dirty, ')
          ..write('seq: $seq, ')
          ..write('day: $day, ')
          ..write('at: $at, ')
          ..write('part: $part, ')
          ..write('cm: $cm, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkoutsTable extends Workouts with TableInfo<$WorkoutsTable, WorkoutRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dirtyMeta = const VerificationMeta('dirty');
  @override
  late final GeneratedColumn<bool> dirty = GeneratedColumn<bool>(
    'dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("dirty" IN (0, 1))'),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _seqMeta = const VerificationMeta('seq');
  @override
  late final GeneratedColumn<int> seq = GeneratedColumn<int>(
    'seq',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<String> day = GeneratedColumn<String>(
    'day',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(minTextLength: 10, maxTextLength: 10),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _atMeta = const VerificationMeta('at');
  @override
  late final GeneratedColumn<DateTime> at = GeneratedColumn<DateTime>(
    'at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _minutesMeta = const VerificationMeta('minutes');
  @override
  late final GeneratedColumn<int> minutes = GeneratedColumn<int>(
    'minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kcalMeta = const VerificationMeta('kcal');
  @override
  late final GeneratedColumn<int> kcal = GeneratedColumn<int>(
    'kcal',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    updatedAt,
    deletedAt,
    dirty,
    seq,
    day,
    at,
    kind,
    minutes,
    kcal,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workouts';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkoutRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('dirty')) {
      context.handle(_dirtyMeta, dirty.isAcceptableOrUnknown(data['dirty']!, _dirtyMeta));
    }
    if (data.containsKey('seq')) {
      context.handle(_seqMeta, seq.isAcceptableOrUnknown(data['seq']!, _seqMeta));
    }
    if (data.containsKey('day')) {
      context.handle(_dayMeta, day.isAcceptableOrUnknown(data['day']!, _dayMeta));
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('at')) {
      context.handle(_atMeta, at.isAcceptableOrUnknown(data['at']!, _atMeta));
    } else if (isInserting) {
      context.missing(_atMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(_kindMeta, kind.isAcceptableOrUnknown(data['kind']!, _kindMeta));
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('minutes')) {
      context.handle(_minutesMeta, minutes.isAcceptableOrUnknown(data['minutes']!, _minutesMeta));
    } else if (isInserting) {
      context.missing(_minutesMeta);
    }
    if (data.containsKey('kcal')) {
      context.handle(_kcalMeta, kcal.isAcceptableOrUnknown(data['kcal']!, _kcalMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkoutRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkoutRow(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      dirty: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}dirty'])!,
      seq: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}seq']),
      day: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}day'])!,
      at: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}at'])!,
      kind: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}kind'])!,
      minutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}minutes'],
      )!,
      kcal: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}kcal'])!,
    );
  }

  @override
  $WorkoutsTable createAlias(String alias) {
    return $WorkoutsTable(attachedDatabase, alias);
  }
}

class WorkoutRow extends DataClass implements Insertable<WorkoutRow> {
  final String id;

  /// When this device last changed the row. Not a sync cursor: the server's
  /// [seq] is the cursor, because a phone clock is not evidence.
  final DateTime updatedAt;

  /// Set instead of deleting the row.
  final DateTime? deletedAt;

  /// True while the server has not acknowledged this version.
  final bool dirty;

  /// The number the server gave this version, null while it has never been sent.
  final int? seq;
  final String day;
  final DateTime at;
  final String kind;
  final int minutes;
  final int kcal;
  const WorkoutRow({
    required this.id,
    required this.updatedAt,
    this.deletedAt,
    required this.dirty,
    this.seq,
    required this.day,
    required this.at,
    required this.kind,
    required this.minutes,
    required this.kcal,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['dirty'] = Variable<bool>(dirty);
    if (!nullToAbsent || seq != null) {
      map['seq'] = Variable<int>(seq);
    }
    map['day'] = Variable<String>(day);
    map['at'] = Variable<DateTime>(at);
    map['kind'] = Variable<String>(kind);
    map['minutes'] = Variable<int>(minutes);
    map['kcal'] = Variable<int>(kcal);
    return map;
  }

  WorkoutsCompanion toCompanion(bool nullToAbsent) {
    return WorkoutsCompanion(
      id: Value(id),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent ? const Value.absent() : Value(deletedAt),
      dirty: Value(dirty),
      seq: seq == null && nullToAbsent ? const Value.absent() : Value(seq),
      day: Value(day),
      at: Value(at),
      kind: Value(kind),
      minutes: Value(minutes),
      kcal: Value(kcal),
    );
  }

  factory WorkoutRow.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkoutRow(
      id: serializer.fromJson<String>(json['id']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      dirty: serializer.fromJson<bool>(json['dirty']),
      seq: serializer.fromJson<int?>(json['seq']),
      day: serializer.fromJson<String>(json['day']),
      at: serializer.fromJson<DateTime>(json['at']),
      kind: serializer.fromJson<String>(json['kind']),
      minutes: serializer.fromJson<int>(json['minutes']),
      kcal: serializer.fromJson<int>(json['kcal']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'dirty': serializer.toJson<bool>(dirty),
      'seq': serializer.toJson<int?>(seq),
      'day': serializer.toJson<String>(day),
      'at': serializer.toJson<DateTime>(at),
      'kind': serializer.toJson<String>(kind),
      'minutes': serializer.toJson<int>(minutes),
      'kcal': serializer.toJson<int>(kcal),
    };
  }

  WorkoutRow copyWith({
    String? id,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    bool? dirty,
    Value<int?> seq = const Value.absent(),
    String? day,
    DateTime? at,
    String? kind,
    int? minutes,
    int? kcal,
  }) => WorkoutRow(
    id: id ?? this.id,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    dirty: dirty ?? this.dirty,
    seq: seq.present ? seq.value : this.seq,
    day: day ?? this.day,
    at: at ?? this.at,
    kind: kind ?? this.kind,
    minutes: minutes ?? this.minutes,
    kcal: kcal ?? this.kcal,
  );
  WorkoutRow copyWithCompanion(WorkoutsCompanion data) {
    return WorkoutRow(
      id: data.id.present ? data.id.value : this.id,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
      seq: data.seq.present ? data.seq.value : this.seq,
      day: data.day.present ? data.day.value : this.day,
      at: data.at.present ? data.at.value : this.at,
      kind: data.kind.present ? data.kind.value : this.kind,
      minutes: data.minutes.present ? data.minutes.value : this.minutes,
      kcal: data.kcal.present ? data.kcal.value : this.kcal,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutRow(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('dirty: $dirty, ')
          ..write('seq: $seq, ')
          ..write('day: $day, ')
          ..write('at: $at, ')
          ..write('kind: $kind, ')
          ..write('minutes: $minutes, ')
          ..write('kcal: $kcal')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, updatedAt, deletedAt, dirty, seq, day, at, kind, minutes, kcal);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkoutRow &&
          other.id == this.id &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.dirty == this.dirty &&
          other.seq == this.seq &&
          other.day == this.day &&
          other.at == this.at &&
          other.kind == this.kind &&
          other.minutes == this.minutes &&
          other.kcal == this.kcal);
}

class WorkoutsCompanion extends UpdateCompanion<WorkoutRow> {
  final Value<String> id;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<bool> dirty;
  final Value<int?> seq;
  final Value<String> day;
  final Value<DateTime> at;
  final Value<String> kind;
  final Value<int> minutes;
  final Value<int> kcal;
  final Value<int> rowid;
  const WorkoutsCompanion({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.dirty = const Value.absent(),
    this.seq = const Value.absent(),
    this.day = const Value.absent(),
    this.at = const Value.absent(),
    this.kind = const Value.absent(),
    this.minutes = const Value.absent(),
    this.kcal = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkoutsCompanion.insert({
    required String id,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.dirty = const Value.absent(),
    this.seq = const Value.absent(),
    required String day,
    required DateTime at,
    required String kind,
    required int minutes,
    this.kcal = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       updatedAt = Value(updatedAt),
       day = Value(day),
       at = Value(at),
       kind = Value(kind),
       minutes = Value(minutes);
  static Insertable<WorkoutRow> custom({
    Expression<String>? id,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<bool>? dirty,
    Expression<int>? seq,
    Expression<String>? day,
    Expression<DateTime>? at,
    Expression<String>? kind,
    Expression<int>? minutes,
    Expression<int>? kcal,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (dirty != null) 'dirty': dirty,
      if (seq != null) 'seq': seq,
      if (day != null) 'day': day,
      if (at != null) 'at': at,
      if (kind != null) 'kind': kind,
      if (minutes != null) 'minutes': minutes,
      if (kcal != null) 'kcal': kcal,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkoutsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<bool>? dirty,
    Value<int?>? seq,
    Value<String>? day,
    Value<DateTime>? at,
    Value<String>? kind,
    Value<int>? minutes,
    Value<int>? kcal,
    Value<int>? rowid,
  }) {
    return WorkoutsCompanion(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      dirty: dirty ?? this.dirty,
      seq: seq ?? this.seq,
      day: day ?? this.day,
      at: at ?? this.at,
      kind: kind ?? this.kind,
      minutes: minutes ?? this.minutes,
      kcal: kcal ?? this.kcal,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<bool>(dirty.value);
    }
    if (seq.present) {
      map['seq'] = Variable<int>(seq.value);
    }
    if (day.present) {
      map['day'] = Variable<String>(day.value);
    }
    if (at.present) {
      map['at'] = Variable<DateTime>(at.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (minutes.present) {
      map['minutes'] = Variable<int>(minutes.value);
    }
    if (kcal.present) {
      map['kcal'] = Variable<int>(kcal.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutsCompanion(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('dirty: $dirty, ')
          ..write('seq: $seq, ')
          ..write('day: $day, ')
          ..write('at: $at, ')
          ..write('kind: $kind, ')
          ..write('minutes: $minutes, ')
          ..write('kcal: $kcal, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MedicationsTable extends Medications with TableInfo<$MedicationsTable, Medication> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MedicationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dirtyMeta = const VerificationMeta('dirty');
  @override
  late final GeneratedColumn<bool> dirty = GeneratedColumn<bool>(
    'dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("dirty" IN (0, 1))'),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _seqMeta = const VerificationMeta('seq');
  @override
  late final GeneratedColumn<int> seq = GeneratedColumn<int>(
    'seq',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
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
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<String> amount = GeneratedColumn<String>(
    'amount',
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
  static const VerificationMeta _timesMeta = const VerificationMeta('times');
  @override
  late final GeneratedColumn<String> times = GeneratedColumn<String>(
    'times',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _remindMeta = const VerificationMeta('remind');
  @override
  late final GeneratedColumn<bool> remind = GeneratedColumn<bool>(
    'remind',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("remind" IN (0, 1))'),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _scheduleMeta = const VerificationMeta('schedule');
  @override
  late final GeneratedColumn<String> schedule = GeneratedColumn<String>(
    'schedule',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _formMeta = const VerificationMeta('form');
  @override
  late final GeneratedColumn<String> form = GeneratedColumn<String>(
    'form',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('tab'),
  );
  static const VerificationMeta _startDayMeta = const VerificationMeta('startDay');
  @override
  late final GeneratedColumn<String> startDay = GeneratedColumn<String>(
    'start_day',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _endDayMeta = const VerificationMeta('endDay');
  @override
  late final GeneratedColumn<String> endDay = GeneratedColumn<String>(
    'end_day',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    updatedAt,
    deletedAt,
    dirty,
    seq,
    name,
    amount,
    note,
    times,
    remind,
    schedule,
    form,
    startDay,
    endDay,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'medications';
  @override
  VerificationContext validateIntegrity(
    Insertable<Medication> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('dirty')) {
      context.handle(_dirtyMeta, dirty.isAcceptableOrUnknown(data['dirty']!, _dirtyMeta));
    }
    if (data.containsKey('seq')) {
      context.handle(_seqMeta, seq.isAcceptableOrUnknown(data['seq']!, _seqMeta));
    }
    if (data.containsKey('name')) {
      context.handle(_nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta, amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    }
    if (data.containsKey('note')) {
      context.handle(_noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    if (data.containsKey('times')) {
      context.handle(_timesMeta, times.isAcceptableOrUnknown(data['times']!, _timesMeta));
    }
    if (data.containsKey('remind')) {
      context.handle(_remindMeta, remind.isAcceptableOrUnknown(data['remind']!, _remindMeta));
    }
    if (data.containsKey('schedule')) {
      context.handle(
        _scheduleMeta,
        schedule.isAcceptableOrUnknown(data['schedule']!, _scheduleMeta),
      );
    }
    if (data.containsKey('form')) {
      context.handle(_formMeta, form.isAcceptableOrUnknown(data['form']!, _formMeta));
    }
    if (data.containsKey('start_day')) {
      context.handle(
        _startDayMeta,
        startDay.isAcceptableOrUnknown(data['start_day']!, _startDayMeta),
      );
    }
    if (data.containsKey('end_day')) {
      context.handle(_endDayMeta, endDay.isAcceptableOrUnknown(data['end_day']!, _endDayMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Medication map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Medication(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      dirty: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}dirty'])!,
      seq: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}seq']),
      name: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}amount'],
      ),
      note: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}note']),
      times: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}times'],
      )!,
      remind: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}remind'],
      )!,
      schedule: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}schedule'],
      )!,
      form: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}form'])!,
      startDay: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}start_day'],
      )!,
      endDay: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}end_day'],
      ),
    );
  }

  @override
  $MedicationsTable createAlias(String alias) {
    return $MedicationsTable(attachedDatabase, alias);
  }
}

class Medication extends DataClass implements Insertable<Medication> {
  final String id;

  /// When this device last changed the row. Not a sync cursor: the server's
  /// [seq] is the cursor, because a phone clock is not evidence.
  final DateTime updatedAt;

  /// Set instead of deleting the row.
  final DateTime? deletedAt;

  /// True while the server has not acknowledged this version.
  final bool dirty;

  /// The number the server gave this version, null while it has never been sent.
  final int? seq;
  final String name;
  final String? amount;
  final String? note;

  /// Wall clock times as «HH:MM», comma separated. A reminder belongs to the
  /// clock on the wall: 08:00 stays 08:00 after a flight.
  final String times;
  final bool remind;
  final String schedule;
  final String form;
  final String startDay;
  final String? endDay;
  const Medication({
    required this.id,
    required this.updatedAt,
    this.deletedAt,
    required this.dirty,
    this.seq,
    required this.name,
    this.amount,
    this.note,
    required this.times,
    required this.remind,
    required this.schedule,
    required this.form,
    required this.startDay,
    this.endDay,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['dirty'] = Variable<bool>(dirty);
    if (!nullToAbsent || seq != null) {
      map['seq'] = Variable<int>(seq);
    }
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || amount != null) {
      map['amount'] = Variable<String>(amount);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['times'] = Variable<String>(times);
    map['remind'] = Variable<bool>(remind);
    map['schedule'] = Variable<String>(schedule);
    map['form'] = Variable<String>(form);
    map['start_day'] = Variable<String>(startDay);
    if (!nullToAbsent || endDay != null) {
      map['end_day'] = Variable<String>(endDay);
    }
    return map;
  }

  MedicationsCompanion toCompanion(bool nullToAbsent) {
    return MedicationsCompanion(
      id: Value(id),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent ? const Value.absent() : Value(deletedAt),
      dirty: Value(dirty),
      seq: seq == null && nullToAbsent ? const Value.absent() : Value(seq),
      name: Value(name),
      amount: amount == null && nullToAbsent ? const Value.absent() : Value(amount),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      times: Value(times),
      remind: Value(remind),
      schedule: Value(schedule),
      form: Value(form),
      startDay: Value(startDay),
      endDay: endDay == null && nullToAbsent ? const Value.absent() : Value(endDay),
    );
  }

  factory Medication.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Medication(
      id: serializer.fromJson<String>(json['id']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      dirty: serializer.fromJson<bool>(json['dirty']),
      seq: serializer.fromJson<int?>(json['seq']),
      name: serializer.fromJson<String>(json['name']),
      amount: serializer.fromJson<String?>(json['amount']),
      note: serializer.fromJson<String?>(json['note']),
      times: serializer.fromJson<String>(json['times']),
      remind: serializer.fromJson<bool>(json['remind']),
      schedule: serializer.fromJson<String>(json['schedule']),
      form: serializer.fromJson<String>(json['form']),
      startDay: serializer.fromJson<String>(json['startDay']),
      endDay: serializer.fromJson<String?>(json['endDay']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'dirty': serializer.toJson<bool>(dirty),
      'seq': serializer.toJson<int?>(seq),
      'name': serializer.toJson<String>(name),
      'amount': serializer.toJson<String?>(amount),
      'note': serializer.toJson<String?>(note),
      'times': serializer.toJson<String>(times),
      'remind': serializer.toJson<bool>(remind),
      'schedule': serializer.toJson<String>(schedule),
      'form': serializer.toJson<String>(form),
      'startDay': serializer.toJson<String>(startDay),
      'endDay': serializer.toJson<String?>(endDay),
    };
  }

  Medication copyWith({
    String? id,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    bool? dirty,
    Value<int?> seq = const Value.absent(),
    String? name,
    Value<String?> amount = const Value.absent(),
    Value<String?> note = const Value.absent(),
    String? times,
    bool? remind,
    String? schedule,
    String? form,
    String? startDay,
    Value<String?> endDay = const Value.absent(),
  }) => Medication(
    id: id ?? this.id,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    dirty: dirty ?? this.dirty,
    seq: seq.present ? seq.value : this.seq,
    name: name ?? this.name,
    amount: amount.present ? amount.value : this.amount,
    note: note.present ? note.value : this.note,
    times: times ?? this.times,
    remind: remind ?? this.remind,
    schedule: schedule ?? this.schedule,
    form: form ?? this.form,
    startDay: startDay ?? this.startDay,
    endDay: endDay.present ? endDay.value : this.endDay,
  );
  Medication copyWithCompanion(MedicationsCompanion data) {
    return Medication(
      id: data.id.present ? data.id.value : this.id,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
      seq: data.seq.present ? data.seq.value : this.seq,
      name: data.name.present ? data.name.value : this.name,
      amount: data.amount.present ? data.amount.value : this.amount,
      note: data.note.present ? data.note.value : this.note,
      times: data.times.present ? data.times.value : this.times,
      remind: data.remind.present ? data.remind.value : this.remind,
      schedule: data.schedule.present ? data.schedule.value : this.schedule,
      form: data.form.present ? data.form.value : this.form,
      startDay: data.startDay.present ? data.startDay.value : this.startDay,
      endDay: data.endDay.present ? data.endDay.value : this.endDay,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Medication(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('dirty: $dirty, ')
          ..write('seq: $seq, ')
          ..write('name: $name, ')
          ..write('amount: $amount, ')
          ..write('note: $note, ')
          ..write('times: $times, ')
          ..write('remind: $remind, ')
          ..write('schedule: $schedule, ')
          ..write('form: $form, ')
          ..write('startDay: $startDay, ')
          ..write('endDay: $endDay')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    updatedAt,
    deletedAt,
    dirty,
    seq,
    name,
    amount,
    note,
    times,
    remind,
    schedule,
    form,
    startDay,
    endDay,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Medication &&
          other.id == this.id &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.dirty == this.dirty &&
          other.seq == this.seq &&
          other.name == this.name &&
          other.amount == this.amount &&
          other.note == this.note &&
          other.times == this.times &&
          other.remind == this.remind &&
          other.schedule == this.schedule &&
          other.form == this.form &&
          other.startDay == this.startDay &&
          other.endDay == this.endDay);
}

class MedicationsCompanion extends UpdateCompanion<Medication> {
  final Value<String> id;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<bool> dirty;
  final Value<int?> seq;
  final Value<String> name;
  final Value<String?> amount;
  final Value<String?> note;
  final Value<String> times;
  final Value<bool> remind;
  final Value<String> schedule;
  final Value<String> form;
  final Value<String> startDay;
  final Value<String?> endDay;
  final Value<int> rowid;
  const MedicationsCompanion({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.dirty = const Value.absent(),
    this.seq = const Value.absent(),
    this.name = const Value.absent(),
    this.amount = const Value.absent(),
    this.note = const Value.absent(),
    this.times = const Value.absent(),
    this.remind = const Value.absent(),
    this.schedule = const Value.absent(),
    this.form = const Value.absent(),
    this.startDay = const Value.absent(),
    this.endDay = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MedicationsCompanion.insert({
    required String id,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.dirty = const Value.absent(),
    this.seq = const Value.absent(),
    required String name,
    this.amount = const Value.absent(),
    this.note = const Value.absent(),
    this.times = const Value.absent(),
    this.remind = const Value.absent(),
    this.schedule = const Value.absent(),
    this.form = const Value.absent(),
    this.startDay = const Value.absent(),
    this.endDay = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       updatedAt = Value(updatedAt),
       name = Value(name);
  static Insertable<Medication> custom({
    Expression<String>? id,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<bool>? dirty,
    Expression<int>? seq,
    Expression<String>? name,
    Expression<String>? amount,
    Expression<String>? note,
    Expression<String>? times,
    Expression<bool>? remind,
    Expression<String>? schedule,
    Expression<String>? form,
    Expression<String>? startDay,
    Expression<String>? endDay,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (dirty != null) 'dirty': dirty,
      if (seq != null) 'seq': seq,
      if (name != null) 'name': name,
      if (amount != null) 'amount': amount,
      if (note != null) 'note': note,
      if (times != null) 'times': times,
      if (remind != null) 'remind': remind,
      if (schedule != null) 'schedule': schedule,
      if (form != null) 'form': form,
      if (startDay != null) 'start_day': startDay,
      if (endDay != null) 'end_day': endDay,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MedicationsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<bool>? dirty,
    Value<int?>? seq,
    Value<String>? name,
    Value<String?>? amount,
    Value<String?>? note,
    Value<String>? times,
    Value<bool>? remind,
    Value<String>? schedule,
    Value<String>? form,
    Value<String>? startDay,
    Value<String?>? endDay,
    Value<int>? rowid,
  }) {
    return MedicationsCompanion(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      dirty: dirty ?? this.dirty,
      seq: seq ?? this.seq,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      times: times ?? this.times,
      remind: remind ?? this.remind,
      schedule: schedule ?? this.schedule,
      form: form ?? this.form,
      startDay: startDay ?? this.startDay,
      endDay: endDay ?? this.endDay,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<bool>(dirty.value);
    }
    if (seq.present) {
      map['seq'] = Variable<int>(seq.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (amount.present) {
      map['amount'] = Variable<String>(amount.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (times.present) {
      map['times'] = Variable<String>(times.value);
    }
    if (remind.present) {
      map['remind'] = Variable<bool>(remind.value);
    }
    if (schedule.present) {
      map['schedule'] = Variable<String>(schedule.value);
    }
    if (form.present) {
      map['form'] = Variable<String>(form.value);
    }
    if (startDay.present) {
      map['start_day'] = Variable<String>(startDay.value);
    }
    if (endDay.present) {
      map['end_day'] = Variable<String>(endDay.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MedicationsCompanion(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('dirty: $dirty, ')
          ..write('seq: $seq, ')
          ..write('name: $name, ')
          ..write('amount: $amount, ')
          ..write('note: $note, ')
          ..write('times: $times, ')
          ..write('remind: $remind, ')
          ..write('schedule: $schedule, ')
          ..write('form: $form, ')
          ..write('startDay: $startDay, ')
          ..write('endDay: $endDay, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MedicationTakesTable extends MedicationTakes
    with TableInfo<$MedicationTakesTable, MedicationTake> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MedicationTakesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dirtyMeta = const VerificationMeta('dirty');
  @override
  late final GeneratedColumn<bool> dirty = GeneratedColumn<bool>(
    'dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("dirty" IN (0, 1))'),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _seqMeta = const VerificationMeta('seq');
  @override
  late final GeneratedColumn<int> seq = GeneratedColumn<int>(
    'seq',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _medicationIdMeta = const VerificationMeta('medicationId');
  @override
  late final GeneratedColumn<String> medicationId = GeneratedColumn<String>(
    'medication_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<String> day = GeneratedColumn<String>(
    'day',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(minTextLength: 10, maxTextLength: 10),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _atMeta = const VerificationMeta('at');
  @override
  late final GeneratedColumn<DateTime> at = GeneratedColumn<DateTime>(
    'at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _plannedTimeMeta = const VerificationMeta('plannedTime');
  @override
  late final GeneratedColumn<String> plannedTime = GeneratedColumn<String>(
    'planned_time',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    updatedAt,
    deletedAt,
    dirty,
    seq,
    medicationId,
    day,
    at,
    plannedTime,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'medication_takes';
  @override
  VerificationContext validateIntegrity(
    Insertable<MedicationTake> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('dirty')) {
      context.handle(_dirtyMeta, dirty.isAcceptableOrUnknown(data['dirty']!, _dirtyMeta));
    }
    if (data.containsKey('seq')) {
      context.handle(_seqMeta, seq.isAcceptableOrUnknown(data['seq']!, _seqMeta));
    }
    if (data.containsKey('medication_id')) {
      context.handle(
        _medicationIdMeta,
        medicationId.isAcceptableOrUnknown(data['medication_id']!, _medicationIdMeta),
      );
    } else if (isInserting) {
      context.missing(_medicationIdMeta);
    }
    if (data.containsKey('day')) {
      context.handle(_dayMeta, day.isAcceptableOrUnknown(data['day']!, _dayMeta));
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('at')) {
      context.handle(_atMeta, at.isAcceptableOrUnknown(data['at']!, _atMeta));
    } else if (isInserting) {
      context.missing(_atMeta);
    }
    if (data.containsKey('planned_time')) {
      context.handle(
        _plannedTimeMeta,
        plannedTime.isAcceptableOrUnknown(data['planned_time']!, _plannedTimeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MedicationTake map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MedicationTake(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      dirty: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}dirty'])!,
      seq: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}seq']),
      medicationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}medication_id'],
      )!,
      day: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}day'])!,
      at: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}at'])!,
      plannedTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}planned_time'],
      ),
    );
  }

  @override
  $MedicationTakesTable createAlias(String alias) {
    return $MedicationTakesTable(attachedDatabase, alias);
  }
}

class MedicationTake extends DataClass implements Insertable<MedicationTake> {
  final String id;

  /// When this device last changed the row. Not a sync cursor: the server's
  /// [seq] is the cursor, because a phone clock is not evidence.
  final DateTime updatedAt;

  /// Set instead of deleting the row.
  final DateTime? deletedAt;

  /// True while the server has not acknowledged this version.
  final bool dirty;

  /// The number the server gave this version, null while it has never been sent.
  final int? seq;
  final String medicationId;
  final String day;
  final DateTime at;

  /// Which scheduled hour this covers, or null for an unplanned one.
  final String? plannedTime;
  const MedicationTake({
    required this.id,
    required this.updatedAt,
    this.deletedAt,
    required this.dirty,
    this.seq,
    required this.medicationId,
    required this.day,
    required this.at,
    this.plannedTime,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['dirty'] = Variable<bool>(dirty);
    if (!nullToAbsent || seq != null) {
      map['seq'] = Variable<int>(seq);
    }
    map['medication_id'] = Variable<String>(medicationId);
    map['day'] = Variable<String>(day);
    map['at'] = Variable<DateTime>(at);
    if (!nullToAbsent || plannedTime != null) {
      map['planned_time'] = Variable<String>(plannedTime);
    }
    return map;
  }

  MedicationTakesCompanion toCompanion(bool nullToAbsent) {
    return MedicationTakesCompanion(
      id: Value(id),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent ? const Value.absent() : Value(deletedAt),
      dirty: Value(dirty),
      seq: seq == null && nullToAbsent ? const Value.absent() : Value(seq),
      medicationId: Value(medicationId),
      day: Value(day),
      at: Value(at),
      plannedTime: plannedTime == null && nullToAbsent ? const Value.absent() : Value(plannedTime),
    );
  }

  factory MedicationTake.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MedicationTake(
      id: serializer.fromJson<String>(json['id']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      dirty: serializer.fromJson<bool>(json['dirty']),
      seq: serializer.fromJson<int?>(json['seq']),
      medicationId: serializer.fromJson<String>(json['medicationId']),
      day: serializer.fromJson<String>(json['day']),
      at: serializer.fromJson<DateTime>(json['at']),
      plannedTime: serializer.fromJson<String?>(json['plannedTime']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'dirty': serializer.toJson<bool>(dirty),
      'seq': serializer.toJson<int?>(seq),
      'medicationId': serializer.toJson<String>(medicationId),
      'day': serializer.toJson<String>(day),
      'at': serializer.toJson<DateTime>(at),
      'plannedTime': serializer.toJson<String?>(plannedTime),
    };
  }

  MedicationTake copyWith({
    String? id,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    bool? dirty,
    Value<int?> seq = const Value.absent(),
    String? medicationId,
    String? day,
    DateTime? at,
    Value<String?> plannedTime = const Value.absent(),
  }) => MedicationTake(
    id: id ?? this.id,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    dirty: dirty ?? this.dirty,
    seq: seq.present ? seq.value : this.seq,
    medicationId: medicationId ?? this.medicationId,
    day: day ?? this.day,
    at: at ?? this.at,
    plannedTime: plannedTime.present ? plannedTime.value : this.plannedTime,
  );
  MedicationTake copyWithCompanion(MedicationTakesCompanion data) {
    return MedicationTake(
      id: data.id.present ? data.id.value : this.id,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
      seq: data.seq.present ? data.seq.value : this.seq,
      medicationId: data.medicationId.present ? data.medicationId.value : this.medicationId,
      day: data.day.present ? data.day.value : this.day,
      at: data.at.present ? data.at.value : this.at,
      plannedTime: data.plannedTime.present ? data.plannedTime.value : this.plannedTime,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MedicationTake(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('dirty: $dirty, ')
          ..write('seq: $seq, ')
          ..write('medicationId: $medicationId, ')
          ..write('day: $day, ')
          ..write('at: $at, ')
          ..write('plannedTime: $plannedTime')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, updatedAt, deletedAt, dirty, seq, medicationId, day, at, plannedTime);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MedicationTake &&
          other.id == this.id &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.dirty == this.dirty &&
          other.seq == this.seq &&
          other.medicationId == this.medicationId &&
          other.day == this.day &&
          other.at == this.at &&
          other.plannedTime == this.plannedTime);
}

class MedicationTakesCompanion extends UpdateCompanion<MedicationTake> {
  final Value<String> id;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<bool> dirty;
  final Value<int?> seq;
  final Value<String> medicationId;
  final Value<String> day;
  final Value<DateTime> at;
  final Value<String?> plannedTime;
  final Value<int> rowid;
  const MedicationTakesCompanion({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.dirty = const Value.absent(),
    this.seq = const Value.absent(),
    this.medicationId = const Value.absent(),
    this.day = const Value.absent(),
    this.at = const Value.absent(),
    this.plannedTime = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MedicationTakesCompanion.insert({
    required String id,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.dirty = const Value.absent(),
    this.seq = const Value.absent(),
    required String medicationId,
    required String day,
    required DateTime at,
    this.plannedTime = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       updatedAt = Value(updatedAt),
       medicationId = Value(medicationId),
       day = Value(day),
       at = Value(at);
  static Insertable<MedicationTake> custom({
    Expression<String>? id,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<bool>? dirty,
    Expression<int>? seq,
    Expression<String>? medicationId,
    Expression<String>? day,
    Expression<DateTime>? at,
    Expression<String>? plannedTime,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (dirty != null) 'dirty': dirty,
      if (seq != null) 'seq': seq,
      if (medicationId != null) 'medication_id': medicationId,
      if (day != null) 'day': day,
      if (at != null) 'at': at,
      if (plannedTime != null) 'planned_time': plannedTime,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MedicationTakesCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<bool>? dirty,
    Value<int?>? seq,
    Value<String>? medicationId,
    Value<String>? day,
    Value<DateTime>? at,
    Value<String?>? plannedTime,
    Value<int>? rowid,
  }) {
    return MedicationTakesCompanion(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      dirty: dirty ?? this.dirty,
      seq: seq ?? this.seq,
      medicationId: medicationId ?? this.medicationId,
      day: day ?? this.day,
      at: at ?? this.at,
      plannedTime: plannedTime ?? this.plannedTime,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<bool>(dirty.value);
    }
    if (seq.present) {
      map['seq'] = Variable<int>(seq.value);
    }
    if (medicationId.present) {
      map['medication_id'] = Variable<String>(medicationId.value);
    }
    if (day.present) {
      map['day'] = Variable<String>(day.value);
    }
    if (at.present) {
      map['at'] = Variable<DateTime>(at.value);
    }
    if (plannedTime.present) {
      map['planned_time'] = Variable<String>(plannedTime.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MedicationTakesCompanion(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('dirty: $dirty, ')
          ..write('seq: $seq, ')
          ..write('medicationId: $medicationId, ')
          ..write('day: $day, ')
          ..write('at: $at, ')
          ..write('plannedTime: $plannedTime, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AllergiesTable extends Allergies with TableInfo<$AllergiesTable, Allergy> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AllergiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dirtyMeta = const VerificationMeta('dirty');
  @override
  late final GeneratedColumn<bool> dirty = GeneratedColumn<bool>(
    'dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("dirty" IN (0, 1))'),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _seqMeta = const VerificationMeta('seq');
  @override
  late final GeneratedColumn<int> seq = GeneratedColumn<int>(
    'seq',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _allergenIdMeta = const VerificationMeta('allergenId');
  @override
  late final GeneratedColumn<String> allergenId = GeneratedColumn<String>(
    'allergen_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _severeMeta = const VerificationMeta('severe');
  @override
  late final GeneratedColumn<bool> severe = GeneratedColumn<bool>(
    'severe',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("severe" IN (0, 1))'),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [id, updatedAt, deletedAt, dirty, seq, allergenId, severe];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'allergies';
  @override
  VerificationContext validateIntegrity(Insertable<Allergy> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('dirty')) {
      context.handle(_dirtyMeta, dirty.isAcceptableOrUnknown(data['dirty']!, _dirtyMeta));
    }
    if (data.containsKey('seq')) {
      context.handle(_seqMeta, seq.isAcceptableOrUnknown(data['seq']!, _seqMeta));
    }
    if (data.containsKey('allergen_id')) {
      context.handle(
        _allergenIdMeta,
        allergenId.isAcceptableOrUnknown(data['allergen_id']!, _allergenIdMeta),
      );
    } else if (isInserting) {
      context.missing(_allergenIdMeta);
    }
    if (data.containsKey('severe')) {
      context.handle(_severeMeta, severe.isAcceptableOrUnknown(data['severe']!, _severeMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Allergy map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Allergy(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      dirty: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}dirty'])!,
      seq: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}seq']),
      allergenId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}allergen_id'],
      )!,
      severe: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}severe'],
      )!,
    );
  }

  @override
  $AllergiesTable createAlias(String alias) {
    return $AllergiesTable(attachedDatabase, alias);
  }
}

class Allergy extends DataClass implements Insertable<Allergy> {
  final String id;

  /// When this device last changed the row. Not a sync cursor: the server's
  /// [seq] is the cursor, because a phone clock is not evidence.
  final DateTime updatedAt;

  /// Set instead of deleting the row.
  final DateTime? deletedAt;

  /// True while the server has not acknowledged this version.
  final bool dirty;

  /// The number the server gave this version, null while it has never been sent.
  final int? seq;
  final String allergenId;

  /// Severe stops a record and says so. Mild warns in the text.
  final bool severe;
  const Allergy({
    required this.id,
    required this.updatedAt,
    this.deletedAt,
    required this.dirty,
    this.seq,
    required this.allergenId,
    required this.severe,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['dirty'] = Variable<bool>(dirty);
    if (!nullToAbsent || seq != null) {
      map['seq'] = Variable<int>(seq);
    }
    map['allergen_id'] = Variable<String>(allergenId);
    map['severe'] = Variable<bool>(severe);
    return map;
  }

  AllergiesCompanion toCompanion(bool nullToAbsent) {
    return AllergiesCompanion(
      id: Value(id),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent ? const Value.absent() : Value(deletedAt),
      dirty: Value(dirty),
      seq: seq == null && nullToAbsent ? const Value.absent() : Value(seq),
      allergenId: Value(allergenId),
      severe: Value(severe),
    );
  }

  factory Allergy.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Allergy(
      id: serializer.fromJson<String>(json['id']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      dirty: serializer.fromJson<bool>(json['dirty']),
      seq: serializer.fromJson<int?>(json['seq']),
      allergenId: serializer.fromJson<String>(json['allergenId']),
      severe: serializer.fromJson<bool>(json['severe']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'dirty': serializer.toJson<bool>(dirty),
      'seq': serializer.toJson<int?>(seq),
      'allergenId': serializer.toJson<String>(allergenId),
      'severe': serializer.toJson<bool>(severe),
    };
  }

  Allergy copyWith({
    String? id,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    bool? dirty,
    Value<int?> seq = const Value.absent(),
    String? allergenId,
    bool? severe,
  }) => Allergy(
    id: id ?? this.id,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    dirty: dirty ?? this.dirty,
    seq: seq.present ? seq.value : this.seq,
    allergenId: allergenId ?? this.allergenId,
    severe: severe ?? this.severe,
  );
  Allergy copyWithCompanion(AllergiesCompanion data) {
    return Allergy(
      id: data.id.present ? data.id.value : this.id,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
      seq: data.seq.present ? data.seq.value : this.seq,
      allergenId: data.allergenId.present ? data.allergenId.value : this.allergenId,
      severe: data.severe.present ? data.severe.value : this.severe,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Allergy(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('dirty: $dirty, ')
          ..write('seq: $seq, ')
          ..write('allergenId: $allergenId, ')
          ..write('severe: $severe')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, updatedAt, deletedAt, dirty, seq, allergenId, severe);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Allergy &&
          other.id == this.id &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.dirty == this.dirty &&
          other.seq == this.seq &&
          other.allergenId == this.allergenId &&
          other.severe == this.severe);
}

class AllergiesCompanion extends UpdateCompanion<Allergy> {
  final Value<String> id;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<bool> dirty;
  final Value<int?> seq;
  final Value<String> allergenId;
  final Value<bool> severe;
  final Value<int> rowid;
  const AllergiesCompanion({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.dirty = const Value.absent(),
    this.seq = const Value.absent(),
    this.allergenId = const Value.absent(),
    this.severe = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AllergiesCompanion.insert({
    required String id,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.dirty = const Value.absent(),
    this.seq = const Value.absent(),
    required String allergenId,
    this.severe = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       updatedAt = Value(updatedAt),
       allergenId = Value(allergenId);
  static Insertable<Allergy> custom({
    Expression<String>? id,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<bool>? dirty,
    Expression<int>? seq,
    Expression<String>? allergenId,
    Expression<bool>? severe,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (dirty != null) 'dirty': dirty,
      if (seq != null) 'seq': seq,
      if (allergenId != null) 'allergen_id': allergenId,
      if (severe != null) 'severe': severe,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AllergiesCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<bool>? dirty,
    Value<int?>? seq,
    Value<String>? allergenId,
    Value<bool>? severe,
    Value<int>? rowid,
  }) {
    return AllergiesCompanion(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      dirty: dirty ?? this.dirty,
      seq: seq ?? this.seq,
      allergenId: allergenId ?? this.allergenId,
      severe: severe ?? this.severe,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<bool>(dirty.value);
    }
    if (seq.present) {
      map['seq'] = Variable<int>(seq.value);
    }
    if (allergenId.present) {
      map['allergen_id'] = Variable<String>(allergenId.value);
    }
    if (severe.present) {
      map['severe'] = Variable<bool>(severe.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AllergiesCompanion(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('dirty: $dirty, ')
          ..write('seq: $seq, ')
          ..write('allergenId: $allergenId, ')
          ..write('severe: $severe, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProfileTable extends Profile with TableInfo<$ProfileTable, ProfileData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfileTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dirtyMeta = const VerificationMeta('dirty');
  @override
  late final GeneratedColumn<bool> dirty = GeneratedColumn<bool>(
    'dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("dirty" IN (0, 1))'),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _seqMeta = const VerificationMeta('seq');
  @override
  late final GeneratedColumn<int> seq = GeneratedColumn<int>(
    'seq',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sexMeta = const VerificationMeta('sex');
  @override
  late final GeneratedColumn<String> sex = GeneratedColumn<String>(
    'sex',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('m'),
  );
  static const VerificationMeta _birthYearMeta = const VerificationMeta('birthYear');
  @override
  late final GeneratedColumn<int> birthYear = GeneratedColumn<int>(
    'birth_year',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _heightCmMeta = const VerificationMeta('heightCm');
  @override
  late final GeneratedColumn<int> heightCm = GeneratedColumn<int>(
    'height_cm',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _goalStartKgMeta = const VerificationMeta('goalStartKg');
  @override
  late final GeneratedColumn<double> goalStartKg = GeneratedColumn<double>(
    'goal_start_kg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _targetKgMeta = const VerificationMeta('targetKg');
  @override
  late final GeneratedColumn<double> targetKg = GeneratedColumn<double>(
    'target_kg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _directionMeta = const VerificationMeta('direction');
  @override
  late final GeneratedColumn<String> direction = GeneratedColumn<String>(
    'direction',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('lose'),
  );
  static const VerificationMeta _paceMeta = const VerificationMeta('pace');
  @override
  late final GeneratedColumn<double> pace = GeneratedColumn<double>(
    'pace',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.5),
  );
  static const VerificationMeta _activityMeta = const VerificationMeta('activity');
  @override
  late final GeneratedColumn<double> activity = GeneratedColumn<double>(
    'activity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1.55),
  );
  static const VerificationMeta _kcalManualMeta = const VerificationMeta('kcalManual');
  @override
  late final GeneratedColumn<int> kcalManual = GeneratedColumn<int>(
    'kcal_manual',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _proteinGMeta = const VerificationMeta('proteinG');
  @override
  late final GeneratedColumn<int> proteinG = GeneratedColumn<int>(
    'protein_g',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fatGMeta = const VerificationMeta('fatG');
  @override
  late final GeneratedColumn<int> fatG = GeneratedColumn<int>(
    'fat_g',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _carbsGMeta = const VerificationMeta('carbsG');
  @override
  late final GeneratedColumn<int> carbsG = GeneratedColumn<int>(
    'carbs_g',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _waterMlMeta = const VerificationMeta('waterMl');
  @override
  late final GeneratedColumn<int> waterMl = GeneratedColumn<int>(
    'water_ml',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(2000),
  );
  static const VerificationMeta _themeMeta = const VerificationMeta('theme');
  @override
  late final GeneratedColumn<String> theme = GeneratedColumn<String>(
    'theme',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('system'),
  );
  static const VerificationMeta _langMeta = const VerificationMeta('lang');
  @override
  late final GeneratedColumn<String> lang = GeneratedColumn<String>(
    'lang',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('system'),
  );
  static const VerificationMeta _addressAsMeta = const VerificationMeta('addressAs');
  @override
  late final GeneratedColumn<String> addressAs = GeneratedColumn<String>(
    'address_as',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _memoryMeta = const VerificationMeta('memory');
  @override
  late final GeneratedColumn<String> memory = GeneratedColumn<String>(
    'memory',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _remindersMeta = const VerificationMeta('reminders');
  @override
  late final GeneratedColumn<String> reminders = GeneratedColumn<String>(
    'reminders',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _trackedMeta = const VerificationMeta('tracked');
  @override
  late final GeneratedColumn<String> tracked = GeneratedColumn<String>(
    'tracked',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    updatedAt,
    deletedAt,
    dirty,
    seq,
    sex,
    birthYear,
    heightCm,
    goalStartKg,
    targetKg,
    direction,
    pace,
    activity,
    kcalManual,
    proteinG,
    fatG,
    carbsG,
    waterMl,
    theme,
    lang,
    addressAs,
    memory,
    reminders,
    tracked,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profile';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProfileData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('dirty')) {
      context.handle(_dirtyMeta, dirty.isAcceptableOrUnknown(data['dirty']!, _dirtyMeta));
    }
    if (data.containsKey('seq')) {
      context.handle(_seqMeta, seq.isAcceptableOrUnknown(data['seq']!, _seqMeta));
    }
    if (data.containsKey('sex')) {
      context.handle(_sexMeta, sex.isAcceptableOrUnknown(data['sex']!, _sexMeta));
    }
    if (data.containsKey('birth_year')) {
      context.handle(
        _birthYearMeta,
        birthYear.isAcceptableOrUnknown(data['birth_year']!, _birthYearMeta),
      );
    }
    if (data.containsKey('height_cm')) {
      context.handle(
        _heightCmMeta,
        heightCm.isAcceptableOrUnknown(data['height_cm']!, _heightCmMeta),
      );
    }
    if (data.containsKey('goal_start_kg')) {
      context.handle(
        _goalStartKgMeta,
        goalStartKg.isAcceptableOrUnknown(data['goal_start_kg']!, _goalStartKgMeta),
      );
    }
    if (data.containsKey('target_kg')) {
      context.handle(
        _targetKgMeta,
        targetKg.isAcceptableOrUnknown(data['target_kg']!, _targetKgMeta),
      );
    }
    if (data.containsKey('direction')) {
      context.handle(
        _directionMeta,
        direction.isAcceptableOrUnknown(data['direction']!, _directionMeta),
      );
    }
    if (data.containsKey('pace')) {
      context.handle(_paceMeta, pace.isAcceptableOrUnknown(data['pace']!, _paceMeta));
    }
    if (data.containsKey('activity')) {
      context.handle(
        _activityMeta,
        activity.isAcceptableOrUnknown(data['activity']!, _activityMeta),
      );
    }
    if (data.containsKey('kcal_manual')) {
      context.handle(
        _kcalManualMeta,
        kcalManual.isAcceptableOrUnknown(data['kcal_manual']!, _kcalManualMeta),
      );
    }
    if (data.containsKey('protein_g')) {
      context.handle(
        _proteinGMeta,
        proteinG.isAcceptableOrUnknown(data['protein_g']!, _proteinGMeta),
      );
    }
    if (data.containsKey('fat_g')) {
      context.handle(_fatGMeta, fatG.isAcceptableOrUnknown(data['fat_g']!, _fatGMeta));
    }
    if (data.containsKey('carbs_g')) {
      context.handle(_carbsGMeta, carbsG.isAcceptableOrUnknown(data['carbs_g']!, _carbsGMeta));
    }
    if (data.containsKey('water_ml')) {
      context.handle(_waterMlMeta, waterMl.isAcceptableOrUnknown(data['water_ml']!, _waterMlMeta));
    }
    if (data.containsKey('theme')) {
      context.handle(_themeMeta, theme.isAcceptableOrUnknown(data['theme']!, _themeMeta));
    }
    if (data.containsKey('lang')) {
      context.handle(_langMeta, lang.isAcceptableOrUnknown(data['lang']!, _langMeta));
    }
    if (data.containsKey('address_as')) {
      context.handle(
        _addressAsMeta,
        addressAs.isAcceptableOrUnknown(data['address_as']!, _addressAsMeta),
      );
    }
    if (data.containsKey('memory')) {
      context.handle(_memoryMeta, memory.isAcceptableOrUnknown(data['memory']!, _memoryMeta));
    }
    if (data.containsKey('reminders')) {
      context.handle(
        _remindersMeta,
        reminders.isAcceptableOrUnknown(data['reminders']!, _remindersMeta),
      );
    }
    if (data.containsKey('tracked')) {
      context.handle(_trackedMeta, tracked.isAcceptableOrUnknown(data['tracked']!, _trackedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProfileData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProfileData(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      dirty: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}dirty'])!,
      seq: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}seq']),
      sex: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}sex'])!,
      birthYear: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}birth_year'],
      ),
      heightCm: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}height_cm'],
      ),
      goalStartKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}goal_start_kg'],
      ),
      targetKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}target_kg'],
      ),
      direction: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}direction'],
      )!,
      pace: attachedDatabase.typeMapping.read(DriftSqlType.double, data['${effectivePrefix}pace'])!,
      activity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}activity'],
      )!,
      kcalManual: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}kcal_manual'],
      ),
      proteinG: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}protein_g'],
      ),
      fatG: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}fat_g']),
      carbsG: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}carbs_g'],
      ),
      waterMl: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}water_ml'],
      )!,
      theme: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}theme'],
      )!,
      lang: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}lang'])!,
      addressAs: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address_as'],
      ),
      memory: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}memory'],
      )!,
      reminders: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reminders'],
      )!,
      tracked: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tracked'],
      )!,
    );
  }

  @override
  $ProfileTable createAlias(String alias) {
    return $ProfileTable(attachedDatabase, alias);
  }
}

class ProfileData extends DataClass implements Insertable<ProfileData> {
  final String id;

  /// When this device last changed the row. Not a sync cursor: the server's
  /// [seq] is the cursor, because a phone clock is not evidence.
  final DateTime updatedAt;

  /// Set instead of deleting the row.
  final DateTime? deletedAt;

  /// True while the server has not acknowledged this version.
  final bool dirty;

  /// The number the server gave this version, null while it has never been sent.
  final int? seq;
  final String sex;
  final int? birthYear;
  final int? heightCm;
  final double? goalStartKg;
  final double? targetKg;
  final String direction;
  final double pace;
  final double activity;

  /// Null means «count it», a number means the person overrode it.
  final int? kcalManual;
  final int? proteinG;
  final int? fatG;
  final int? carbsG;
  final int waterMl;
  final String theme;
  final String lang;

  /// Як звертатись до людини. Порожньо, поки вона не сказала.
  final String? addressAs;
  final String memory;
  final String reminders;
  final String tracked;
  const ProfileData({
    required this.id,
    required this.updatedAt,
    this.deletedAt,
    required this.dirty,
    this.seq,
    required this.sex,
    this.birthYear,
    this.heightCm,
    this.goalStartKg,
    this.targetKg,
    required this.direction,
    required this.pace,
    required this.activity,
    this.kcalManual,
    this.proteinG,
    this.fatG,
    this.carbsG,
    required this.waterMl,
    required this.theme,
    required this.lang,
    this.addressAs,
    required this.memory,
    required this.reminders,
    required this.tracked,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['dirty'] = Variable<bool>(dirty);
    if (!nullToAbsent || seq != null) {
      map['seq'] = Variable<int>(seq);
    }
    map['sex'] = Variable<String>(sex);
    if (!nullToAbsent || birthYear != null) {
      map['birth_year'] = Variable<int>(birthYear);
    }
    if (!nullToAbsent || heightCm != null) {
      map['height_cm'] = Variable<int>(heightCm);
    }
    if (!nullToAbsent || goalStartKg != null) {
      map['goal_start_kg'] = Variable<double>(goalStartKg);
    }
    if (!nullToAbsent || targetKg != null) {
      map['target_kg'] = Variable<double>(targetKg);
    }
    map['direction'] = Variable<String>(direction);
    map['pace'] = Variable<double>(pace);
    map['activity'] = Variable<double>(activity);
    if (!nullToAbsent || kcalManual != null) {
      map['kcal_manual'] = Variable<int>(kcalManual);
    }
    if (!nullToAbsent || proteinG != null) {
      map['protein_g'] = Variable<int>(proteinG);
    }
    if (!nullToAbsent || fatG != null) {
      map['fat_g'] = Variable<int>(fatG);
    }
    if (!nullToAbsent || carbsG != null) {
      map['carbs_g'] = Variable<int>(carbsG);
    }
    map['water_ml'] = Variable<int>(waterMl);
    map['theme'] = Variable<String>(theme);
    map['lang'] = Variable<String>(lang);
    if (!nullToAbsent || addressAs != null) {
      map['address_as'] = Variable<String>(addressAs);
    }
    map['memory'] = Variable<String>(memory);
    map['reminders'] = Variable<String>(reminders);
    map['tracked'] = Variable<String>(tracked);
    return map;
  }

  ProfileCompanion toCompanion(bool nullToAbsent) {
    return ProfileCompanion(
      id: Value(id),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent ? const Value.absent() : Value(deletedAt),
      dirty: Value(dirty),
      seq: seq == null && nullToAbsent ? const Value.absent() : Value(seq),
      sex: Value(sex),
      birthYear: birthYear == null && nullToAbsent ? const Value.absent() : Value(birthYear),
      heightCm: heightCm == null && nullToAbsent ? const Value.absent() : Value(heightCm),
      goalStartKg: goalStartKg == null && nullToAbsent ? const Value.absent() : Value(goalStartKg),
      targetKg: targetKg == null && nullToAbsent ? const Value.absent() : Value(targetKg),
      direction: Value(direction),
      pace: Value(pace),
      activity: Value(activity),
      kcalManual: kcalManual == null && nullToAbsent ? const Value.absent() : Value(kcalManual),
      proteinG: proteinG == null && nullToAbsent ? const Value.absent() : Value(proteinG),
      fatG: fatG == null && nullToAbsent ? const Value.absent() : Value(fatG),
      carbsG: carbsG == null && nullToAbsent ? const Value.absent() : Value(carbsG),
      waterMl: Value(waterMl),
      theme: Value(theme),
      lang: Value(lang),
      addressAs: addressAs == null && nullToAbsent ? const Value.absent() : Value(addressAs),
      memory: Value(memory),
      reminders: Value(reminders),
      tracked: Value(tracked),
    );
  }

  factory ProfileData.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProfileData(
      id: serializer.fromJson<String>(json['id']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      dirty: serializer.fromJson<bool>(json['dirty']),
      seq: serializer.fromJson<int?>(json['seq']),
      sex: serializer.fromJson<String>(json['sex']),
      birthYear: serializer.fromJson<int?>(json['birthYear']),
      heightCm: serializer.fromJson<int?>(json['heightCm']),
      goalStartKg: serializer.fromJson<double?>(json['goalStartKg']),
      targetKg: serializer.fromJson<double?>(json['targetKg']),
      direction: serializer.fromJson<String>(json['direction']),
      pace: serializer.fromJson<double>(json['pace']),
      activity: serializer.fromJson<double>(json['activity']),
      kcalManual: serializer.fromJson<int?>(json['kcalManual']),
      proteinG: serializer.fromJson<int?>(json['proteinG']),
      fatG: serializer.fromJson<int?>(json['fatG']),
      carbsG: serializer.fromJson<int?>(json['carbsG']),
      waterMl: serializer.fromJson<int>(json['waterMl']),
      theme: serializer.fromJson<String>(json['theme']),
      lang: serializer.fromJson<String>(json['lang']),
      addressAs: serializer.fromJson<String?>(json['addressAs']),
      memory: serializer.fromJson<String>(json['memory']),
      reminders: serializer.fromJson<String>(json['reminders']),
      tracked: serializer.fromJson<String>(json['tracked']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'dirty': serializer.toJson<bool>(dirty),
      'seq': serializer.toJson<int?>(seq),
      'sex': serializer.toJson<String>(sex),
      'birthYear': serializer.toJson<int?>(birthYear),
      'heightCm': serializer.toJson<int?>(heightCm),
      'goalStartKg': serializer.toJson<double?>(goalStartKg),
      'targetKg': serializer.toJson<double?>(targetKg),
      'direction': serializer.toJson<String>(direction),
      'pace': serializer.toJson<double>(pace),
      'activity': serializer.toJson<double>(activity),
      'kcalManual': serializer.toJson<int?>(kcalManual),
      'proteinG': serializer.toJson<int?>(proteinG),
      'fatG': serializer.toJson<int?>(fatG),
      'carbsG': serializer.toJson<int?>(carbsG),
      'waterMl': serializer.toJson<int>(waterMl),
      'theme': serializer.toJson<String>(theme),
      'lang': serializer.toJson<String>(lang),
      'addressAs': serializer.toJson<String?>(addressAs),
      'memory': serializer.toJson<String>(memory),
      'reminders': serializer.toJson<String>(reminders),
      'tracked': serializer.toJson<String>(tracked),
    };
  }

  ProfileData copyWith({
    String? id,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    bool? dirty,
    Value<int?> seq = const Value.absent(),
    String? sex,
    Value<int?> birthYear = const Value.absent(),
    Value<int?> heightCm = const Value.absent(),
    Value<double?> goalStartKg = const Value.absent(),
    Value<double?> targetKg = const Value.absent(),
    String? direction,
    double? pace,
    double? activity,
    Value<int?> kcalManual = const Value.absent(),
    Value<int?> proteinG = const Value.absent(),
    Value<int?> fatG = const Value.absent(),
    Value<int?> carbsG = const Value.absent(),
    int? waterMl,
    String? theme,
    String? lang,
    Value<String?> addressAs = const Value.absent(),
    String? memory,
    String? reminders,
    String? tracked,
  }) => ProfileData(
    id: id ?? this.id,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    dirty: dirty ?? this.dirty,
    seq: seq.present ? seq.value : this.seq,
    sex: sex ?? this.sex,
    birthYear: birthYear.present ? birthYear.value : this.birthYear,
    heightCm: heightCm.present ? heightCm.value : this.heightCm,
    goalStartKg: goalStartKg.present ? goalStartKg.value : this.goalStartKg,
    targetKg: targetKg.present ? targetKg.value : this.targetKg,
    direction: direction ?? this.direction,
    pace: pace ?? this.pace,
    activity: activity ?? this.activity,
    kcalManual: kcalManual.present ? kcalManual.value : this.kcalManual,
    proteinG: proteinG.present ? proteinG.value : this.proteinG,
    fatG: fatG.present ? fatG.value : this.fatG,
    carbsG: carbsG.present ? carbsG.value : this.carbsG,
    waterMl: waterMl ?? this.waterMl,
    theme: theme ?? this.theme,
    lang: lang ?? this.lang,
    addressAs: addressAs.present ? addressAs.value : this.addressAs,
    memory: memory ?? this.memory,
    reminders: reminders ?? this.reminders,
    tracked: tracked ?? this.tracked,
  );
  ProfileData copyWithCompanion(ProfileCompanion data) {
    return ProfileData(
      id: data.id.present ? data.id.value : this.id,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
      seq: data.seq.present ? data.seq.value : this.seq,
      sex: data.sex.present ? data.sex.value : this.sex,
      birthYear: data.birthYear.present ? data.birthYear.value : this.birthYear,
      heightCm: data.heightCm.present ? data.heightCm.value : this.heightCm,
      goalStartKg: data.goalStartKg.present ? data.goalStartKg.value : this.goalStartKg,
      targetKg: data.targetKg.present ? data.targetKg.value : this.targetKg,
      direction: data.direction.present ? data.direction.value : this.direction,
      pace: data.pace.present ? data.pace.value : this.pace,
      activity: data.activity.present ? data.activity.value : this.activity,
      kcalManual: data.kcalManual.present ? data.kcalManual.value : this.kcalManual,
      proteinG: data.proteinG.present ? data.proteinG.value : this.proteinG,
      fatG: data.fatG.present ? data.fatG.value : this.fatG,
      carbsG: data.carbsG.present ? data.carbsG.value : this.carbsG,
      waterMl: data.waterMl.present ? data.waterMl.value : this.waterMl,
      theme: data.theme.present ? data.theme.value : this.theme,
      lang: data.lang.present ? data.lang.value : this.lang,
      addressAs: data.addressAs.present ? data.addressAs.value : this.addressAs,
      memory: data.memory.present ? data.memory.value : this.memory,
      reminders: data.reminders.present ? data.reminders.value : this.reminders,
      tracked: data.tracked.present ? data.tracked.value : this.tracked,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProfileData(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('dirty: $dirty, ')
          ..write('seq: $seq, ')
          ..write('sex: $sex, ')
          ..write('birthYear: $birthYear, ')
          ..write('heightCm: $heightCm, ')
          ..write('goalStartKg: $goalStartKg, ')
          ..write('targetKg: $targetKg, ')
          ..write('direction: $direction, ')
          ..write('pace: $pace, ')
          ..write('activity: $activity, ')
          ..write('kcalManual: $kcalManual, ')
          ..write('proteinG: $proteinG, ')
          ..write('fatG: $fatG, ')
          ..write('carbsG: $carbsG, ')
          ..write('waterMl: $waterMl, ')
          ..write('theme: $theme, ')
          ..write('lang: $lang, ')
          ..write('addressAs: $addressAs, ')
          ..write('memory: $memory, ')
          ..write('reminders: $reminders, ')
          ..write('tracked: $tracked')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    updatedAt,
    deletedAt,
    dirty,
    seq,
    sex,
    birthYear,
    heightCm,
    goalStartKg,
    targetKg,
    direction,
    pace,
    activity,
    kcalManual,
    proteinG,
    fatG,
    carbsG,
    waterMl,
    theme,
    lang,
    addressAs,
    memory,
    reminders,
    tracked,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProfileData &&
          other.id == this.id &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.dirty == this.dirty &&
          other.seq == this.seq &&
          other.sex == this.sex &&
          other.birthYear == this.birthYear &&
          other.heightCm == this.heightCm &&
          other.goalStartKg == this.goalStartKg &&
          other.targetKg == this.targetKg &&
          other.direction == this.direction &&
          other.pace == this.pace &&
          other.activity == this.activity &&
          other.kcalManual == this.kcalManual &&
          other.proteinG == this.proteinG &&
          other.fatG == this.fatG &&
          other.carbsG == this.carbsG &&
          other.waterMl == this.waterMl &&
          other.theme == this.theme &&
          other.lang == this.lang &&
          other.addressAs == this.addressAs &&
          other.memory == this.memory &&
          other.reminders == this.reminders &&
          other.tracked == this.tracked);
}

class ProfileCompanion extends UpdateCompanion<ProfileData> {
  final Value<String> id;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<bool> dirty;
  final Value<int?> seq;
  final Value<String> sex;
  final Value<int?> birthYear;
  final Value<int?> heightCm;
  final Value<double?> goalStartKg;
  final Value<double?> targetKg;
  final Value<String> direction;
  final Value<double> pace;
  final Value<double> activity;
  final Value<int?> kcalManual;
  final Value<int?> proteinG;
  final Value<int?> fatG;
  final Value<int?> carbsG;
  final Value<int> waterMl;
  final Value<String> theme;
  final Value<String> lang;
  final Value<String?> addressAs;
  final Value<String> memory;
  final Value<String> reminders;
  final Value<String> tracked;
  final Value<int> rowid;
  const ProfileCompanion({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.dirty = const Value.absent(),
    this.seq = const Value.absent(),
    this.sex = const Value.absent(),
    this.birthYear = const Value.absent(),
    this.heightCm = const Value.absent(),
    this.goalStartKg = const Value.absent(),
    this.targetKg = const Value.absent(),
    this.direction = const Value.absent(),
    this.pace = const Value.absent(),
    this.activity = const Value.absent(),
    this.kcalManual = const Value.absent(),
    this.proteinG = const Value.absent(),
    this.fatG = const Value.absent(),
    this.carbsG = const Value.absent(),
    this.waterMl = const Value.absent(),
    this.theme = const Value.absent(),
    this.lang = const Value.absent(),
    this.addressAs = const Value.absent(),
    this.memory = const Value.absent(),
    this.reminders = const Value.absent(),
    this.tracked = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProfileCompanion.insert({
    required String id,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.dirty = const Value.absent(),
    this.seq = const Value.absent(),
    this.sex = const Value.absent(),
    this.birthYear = const Value.absent(),
    this.heightCm = const Value.absent(),
    this.goalStartKg = const Value.absent(),
    this.targetKg = const Value.absent(),
    this.direction = const Value.absent(),
    this.pace = const Value.absent(),
    this.activity = const Value.absent(),
    this.kcalManual = const Value.absent(),
    this.proteinG = const Value.absent(),
    this.fatG = const Value.absent(),
    this.carbsG = const Value.absent(),
    this.waterMl = const Value.absent(),
    this.theme = const Value.absent(),
    this.lang = const Value.absent(),
    this.addressAs = const Value.absent(),
    this.memory = const Value.absent(),
    this.reminders = const Value.absent(),
    this.tracked = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       updatedAt = Value(updatedAt);
  static Insertable<ProfileData> custom({
    Expression<String>? id,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<bool>? dirty,
    Expression<int>? seq,
    Expression<String>? sex,
    Expression<int>? birthYear,
    Expression<int>? heightCm,
    Expression<double>? goalStartKg,
    Expression<double>? targetKg,
    Expression<String>? direction,
    Expression<double>? pace,
    Expression<double>? activity,
    Expression<int>? kcalManual,
    Expression<int>? proteinG,
    Expression<int>? fatG,
    Expression<int>? carbsG,
    Expression<int>? waterMl,
    Expression<String>? theme,
    Expression<String>? lang,
    Expression<String>? addressAs,
    Expression<String>? memory,
    Expression<String>? reminders,
    Expression<String>? tracked,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (dirty != null) 'dirty': dirty,
      if (seq != null) 'seq': seq,
      if (sex != null) 'sex': sex,
      if (birthYear != null) 'birth_year': birthYear,
      if (heightCm != null) 'height_cm': heightCm,
      if (goalStartKg != null) 'goal_start_kg': goalStartKg,
      if (targetKg != null) 'target_kg': targetKg,
      if (direction != null) 'direction': direction,
      if (pace != null) 'pace': pace,
      if (activity != null) 'activity': activity,
      if (kcalManual != null) 'kcal_manual': kcalManual,
      if (proteinG != null) 'protein_g': proteinG,
      if (fatG != null) 'fat_g': fatG,
      if (carbsG != null) 'carbs_g': carbsG,
      if (waterMl != null) 'water_ml': waterMl,
      if (theme != null) 'theme': theme,
      if (lang != null) 'lang': lang,
      if (addressAs != null) 'address_as': addressAs,
      if (memory != null) 'memory': memory,
      if (reminders != null) 'reminders': reminders,
      if (tracked != null) 'tracked': tracked,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProfileCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<bool>? dirty,
    Value<int?>? seq,
    Value<String>? sex,
    Value<int?>? birthYear,
    Value<int?>? heightCm,
    Value<double?>? goalStartKg,
    Value<double?>? targetKg,
    Value<String>? direction,
    Value<double>? pace,
    Value<double>? activity,
    Value<int?>? kcalManual,
    Value<int?>? proteinG,
    Value<int?>? fatG,
    Value<int?>? carbsG,
    Value<int>? waterMl,
    Value<String>? theme,
    Value<String>? lang,
    Value<String?>? addressAs,
    Value<String>? memory,
    Value<String>? reminders,
    Value<String>? tracked,
    Value<int>? rowid,
  }) {
    return ProfileCompanion(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      dirty: dirty ?? this.dirty,
      seq: seq ?? this.seq,
      sex: sex ?? this.sex,
      birthYear: birthYear ?? this.birthYear,
      heightCm: heightCm ?? this.heightCm,
      goalStartKg: goalStartKg ?? this.goalStartKg,
      targetKg: targetKg ?? this.targetKg,
      direction: direction ?? this.direction,
      pace: pace ?? this.pace,
      activity: activity ?? this.activity,
      kcalManual: kcalManual ?? this.kcalManual,
      proteinG: proteinG ?? this.proteinG,
      fatG: fatG ?? this.fatG,
      carbsG: carbsG ?? this.carbsG,
      waterMl: waterMl ?? this.waterMl,
      theme: theme ?? this.theme,
      lang: lang ?? this.lang,
      addressAs: addressAs ?? this.addressAs,
      memory: memory ?? this.memory,
      reminders: reminders ?? this.reminders,
      tracked: tracked ?? this.tracked,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<bool>(dirty.value);
    }
    if (seq.present) {
      map['seq'] = Variable<int>(seq.value);
    }
    if (sex.present) {
      map['sex'] = Variable<String>(sex.value);
    }
    if (birthYear.present) {
      map['birth_year'] = Variable<int>(birthYear.value);
    }
    if (heightCm.present) {
      map['height_cm'] = Variable<int>(heightCm.value);
    }
    if (goalStartKg.present) {
      map['goal_start_kg'] = Variable<double>(goalStartKg.value);
    }
    if (targetKg.present) {
      map['target_kg'] = Variable<double>(targetKg.value);
    }
    if (direction.present) {
      map['direction'] = Variable<String>(direction.value);
    }
    if (pace.present) {
      map['pace'] = Variable<double>(pace.value);
    }
    if (activity.present) {
      map['activity'] = Variable<double>(activity.value);
    }
    if (kcalManual.present) {
      map['kcal_manual'] = Variable<int>(kcalManual.value);
    }
    if (proteinG.present) {
      map['protein_g'] = Variable<int>(proteinG.value);
    }
    if (fatG.present) {
      map['fat_g'] = Variable<int>(fatG.value);
    }
    if (carbsG.present) {
      map['carbs_g'] = Variable<int>(carbsG.value);
    }
    if (waterMl.present) {
      map['water_ml'] = Variable<int>(waterMl.value);
    }
    if (theme.present) {
      map['theme'] = Variable<String>(theme.value);
    }
    if (lang.present) {
      map['lang'] = Variable<String>(lang.value);
    }
    if (addressAs.present) {
      map['address_as'] = Variable<String>(addressAs.value);
    }
    if (memory.present) {
      map['memory'] = Variable<String>(memory.value);
    }
    if (reminders.present) {
      map['reminders'] = Variable<String>(reminders.value);
    }
    if (tracked.present) {
      map['tracked'] = Variable<String>(tracked.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfileCompanion(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('dirty: $dirty, ')
          ..write('seq: $seq, ')
          ..write('sex: $sex, ')
          ..write('birthYear: $birthYear, ')
          ..write('heightCm: $heightCm, ')
          ..write('goalStartKg: $goalStartKg, ')
          ..write('targetKg: $targetKg, ')
          ..write('direction: $direction, ')
          ..write('pace: $pace, ')
          ..write('activity: $activity, ')
          ..write('kcalManual: $kcalManual, ')
          ..write('proteinG: $proteinG, ')
          ..write('fatG: $fatG, ')
          ..write('carbsG: $carbsG, ')
          ..write('waterMl: $waterMl, ')
          ..write('theme: $theme, ')
          ..write('lang: $lang, ')
          ..write('addressAs: $addressAs, ')
          ..write('memory: $memory, ')
          ..write('reminders: $reminders, ')
          ..write('tracked: $tracked, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChatMessagesTable extends ChatMessages with TableInfo<$ChatMessagesTable, ChatMessage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChatMessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dirtyMeta = const VerificationMeta('dirty');
  @override
  late final GeneratedColumn<bool> dirty = GeneratedColumn<bool>(
    'dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("dirty" IN (0, 1))'),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _seqMeta = const VerificationMeta('seq');
  @override
  late final GeneratedColumn<int> seq = GeneratedColumn<int>(
    'seq',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _atMeta = const VerificationMeta('at');
  @override
  late final GeneratedColumn<DateTime> at = GeneratedColumn<DateTime>(
    'at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _spentMeta = const VerificationMeta('spent');
  @override
  late final GeneratedColumn<int> spent = GeneratedColumn<int>(
    'spent',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    updatedAt,
    deletedAt,
    dirty,
    seq,
    role,
    body,
    at,
    spent,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chat_messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChatMessage> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('dirty')) {
      context.handle(_dirtyMeta, dirty.isAcceptableOrUnknown(data['dirty']!, _dirtyMeta));
    }
    if (data.containsKey('seq')) {
      context.handle(_seqMeta, seq.isAcceptableOrUnknown(data['seq']!, _seqMeta));
    }
    if (data.containsKey('role')) {
      context.handle(_roleMeta, role.isAcceptableOrUnknown(data['role']!, _roleMeta));
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('body')) {
      context.handle(_bodyMeta, body.isAcceptableOrUnknown(data['body']!, _bodyMeta));
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('at')) {
      context.handle(_atMeta, at.isAcceptableOrUnknown(data['at']!, _atMeta));
    } else if (isInserting) {
      context.missing(_atMeta);
    }
    if (data.containsKey('spent')) {
      context.handle(_spentMeta, spent.isAcceptableOrUnknown(data['spent']!, _spentMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChatMessage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChatMessage(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      dirty: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}dirty'])!,
      seq: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}seq']),
      role: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}role'])!,
      body: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}body'])!,
      at: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}at'])!,
      spent: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}spent'])!,
    );
  }

  @override
  $ChatMessagesTable createAlias(String alias) {
    return $ChatMessagesTable(attachedDatabase, alias);
  }
}

class ChatMessage extends DataClass implements Insertable<ChatMessage> {
  final String id;

  /// When this device last changed the row. Not a sync cursor: the server's
  /// [seq] is the cursor, because a phone clock is not evidence.
  final DateTime updatedAt;

  /// Set instead of deleting the row.
  final DateTime? deletedAt;

  /// True while the server has not acknowledged this version.
  final bool dirty;

  /// The number the server gave this version, null while it has never been sent.
  final int? seq;

  /// user, nora, system.
  final String role;

  /// The message itself. Not «text»: that is the name of Drift's own column
  /// builder, and a column may not shadow it.
  final String body;
  final DateTime at;

  /// What the exchange cost, for the «where did my tokens go» question.
  final int spent;
  const ChatMessage({
    required this.id,
    required this.updatedAt,
    this.deletedAt,
    required this.dirty,
    this.seq,
    required this.role,
    required this.body,
    required this.at,
    required this.spent,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['dirty'] = Variable<bool>(dirty);
    if (!nullToAbsent || seq != null) {
      map['seq'] = Variable<int>(seq);
    }
    map['role'] = Variable<String>(role);
    map['body'] = Variable<String>(body);
    map['at'] = Variable<DateTime>(at);
    map['spent'] = Variable<int>(spent);
    return map;
  }

  ChatMessagesCompanion toCompanion(bool nullToAbsent) {
    return ChatMessagesCompanion(
      id: Value(id),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent ? const Value.absent() : Value(deletedAt),
      dirty: Value(dirty),
      seq: seq == null && nullToAbsent ? const Value.absent() : Value(seq),
      role: Value(role),
      body: Value(body),
      at: Value(at),
      spent: Value(spent),
    );
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChatMessage(
      id: serializer.fromJson<String>(json['id']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      dirty: serializer.fromJson<bool>(json['dirty']),
      seq: serializer.fromJson<int?>(json['seq']),
      role: serializer.fromJson<String>(json['role']),
      body: serializer.fromJson<String>(json['body']),
      at: serializer.fromJson<DateTime>(json['at']),
      spent: serializer.fromJson<int>(json['spent']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'dirty': serializer.toJson<bool>(dirty),
      'seq': serializer.toJson<int?>(seq),
      'role': serializer.toJson<String>(role),
      'body': serializer.toJson<String>(body),
      'at': serializer.toJson<DateTime>(at),
      'spent': serializer.toJson<int>(spent),
    };
  }

  ChatMessage copyWith({
    String? id,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    bool? dirty,
    Value<int?> seq = const Value.absent(),
    String? role,
    String? body,
    DateTime? at,
    int? spent,
  }) => ChatMessage(
    id: id ?? this.id,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    dirty: dirty ?? this.dirty,
    seq: seq.present ? seq.value : this.seq,
    role: role ?? this.role,
    body: body ?? this.body,
    at: at ?? this.at,
    spent: spent ?? this.spent,
  );
  ChatMessage copyWithCompanion(ChatMessagesCompanion data) {
    return ChatMessage(
      id: data.id.present ? data.id.value : this.id,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
      seq: data.seq.present ? data.seq.value : this.seq,
      role: data.role.present ? data.role.value : this.role,
      body: data.body.present ? data.body.value : this.body,
      at: data.at.present ? data.at.value : this.at,
      spent: data.spent.present ? data.spent.value : this.spent,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChatMessage(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('dirty: $dirty, ')
          ..write('seq: $seq, ')
          ..write('role: $role, ')
          ..write('body: $body, ')
          ..write('at: $at, ')
          ..write('spent: $spent')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, updatedAt, deletedAt, dirty, seq, role, body, at, spent);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatMessage &&
          other.id == this.id &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.dirty == this.dirty &&
          other.seq == this.seq &&
          other.role == this.role &&
          other.body == this.body &&
          other.at == this.at &&
          other.spent == this.spent);
}

class ChatMessagesCompanion extends UpdateCompanion<ChatMessage> {
  final Value<String> id;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<bool> dirty;
  final Value<int?> seq;
  final Value<String> role;
  final Value<String> body;
  final Value<DateTime> at;
  final Value<int> spent;
  final Value<int> rowid;
  const ChatMessagesCompanion({
    this.id = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.dirty = const Value.absent(),
    this.seq = const Value.absent(),
    this.role = const Value.absent(),
    this.body = const Value.absent(),
    this.at = const Value.absent(),
    this.spent = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChatMessagesCompanion.insert({
    required String id,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.dirty = const Value.absent(),
    this.seq = const Value.absent(),
    required String role,
    required String body,
    required DateTime at,
    this.spent = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       updatedAt = Value(updatedAt),
       role = Value(role),
       body = Value(body),
       at = Value(at);
  static Insertable<ChatMessage> custom({
    Expression<String>? id,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<bool>? dirty,
    Expression<int>? seq,
    Expression<String>? role,
    Expression<String>? body,
    Expression<DateTime>? at,
    Expression<int>? spent,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (dirty != null) 'dirty': dirty,
      if (seq != null) 'seq': seq,
      if (role != null) 'role': role,
      if (body != null) 'body': body,
      if (at != null) 'at': at,
      if (spent != null) 'spent': spent,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChatMessagesCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<bool>? dirty,
    Value<int?>? seq,
    Value<String>? role,
    Value<String>? body,
    Value<DateTime>? at,
    Value<int>? spent,
    Value<int>? rowid,
  }) {
    return ChatMessagesCompanion(
      id: id ?? this.id,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      dirty: dirty ?? this.dirty,
      seq: seq ?? this.seq,
      role: role ?? this.role,
      body: body ?? this.body,
      at: at ?? this.at,
      spent: spent ?? this.spent,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<bool>(dirty.value);
    }
    if (seq.present) {
      map['seq'] = Variable<int>(seq.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (at.present) {
      map['at'] = Variable<DateTime>(at.value);
    }
    if (spent.present) {
      map['spent'] = Variable<int>(spent.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChatMessagesCompanion(')
          ..write('id: $id, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('dirty: $dirty, ')
          ..write('seq: $seq, ')
          ..write('role: $role, ')
          ..write('body: $body, ')
          ..write('at: $at, ')
          ..write('spent: $spent, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TokenStateTable extends TokenState with TableInfo<$TokenStateTable, TokenStateData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TokenStateTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _balanceMeta = const VerificationMeta('balance');
  @override
  late final GeneratedColumn<int> balance = GeneratedColumn<int>(
    'balance',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _nextGrantAtMeta = const VerificationMeta('nextGrantAt');
  @override
  late final GeneratedColumn<DateTime> nextGrantAt = GeneratedColumn<DateTime>(
    'next_grant_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta('syncedAt');
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, balance, nextGrantAt, syncedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'token_state';
  @override
  VerificationContext validateIntegrity(
    Insertable<TokenStateData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('balance')) {
      context.handle(_balanceMeta, balance.isAcceptableOrUnknown(data['balance']!, _balanceMeta));
    }
    if (data.containsKey('next_grant_at')) {
      context.handle(
        _nextGrantAtMeta,
        nextGrantAt.isAcceptableOrUnknown(data['next_grant_at']!, _nextGrantAtMeta),
      );
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TokenStateData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TokenStateData(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      balance: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}balance'],
      )!,
      nextGrantAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_grant_at'],
      ),
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      ),
    );
  }

  @override
  $TokenStateTable createAlias(String alias) {
    return $TokenStateTable(attachedDatabase, alias);
  }
}

class TokenStateData extends DataClass implements Insertable<TokenStateData> {
  /// Always 1. One row, replaced rather than appended to.
  final int id;
  final int balance;

  /// When the next two arrive. The countdown on screen is drawn from this, but
  /// the grant itself is the server's to make.
  final DateTime? nextGrantAt;
  final DateTime? syncedAt;
  const TokenStateData({required this.id, required this.balance, this.nextGrantAt, this.syncedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['balance'] = Variable<int>(balance);
    if (!nullToAbsent || nextGrantAt != null) {
      map['next_grant_at'] = Variable<DateTime>(nextGrantAt);
    }
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<DateTime>(syncedAt);
    }
    return map;
  }

  TokenStateCompanion toCompanion(bool nullToAbsent) {
    return TokenStateCompanion(
      id: Value(id),
      balance: Value(balance),
      nextGrantAt: nextGrantAt == null && nullToAbsent ? const Value.absent() : Value(nextGrantAt),
      syncedAt: syncedAt == null && nullToAbsent ? const Value.absent() : Value(syncedAt),
    );
  }

  factory TokenStateData.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TokenStateData(
      id: serializer.fromJson<int>(json['id']),
      balance: serializer.fromJson<int>(json['balance']),
      nextGrantAt: serializer.fromJson<DateTime?>(json['nextGrantAt']),
      syncedAt: serializer.fromJson<DateTime?>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'balance': serializer.toJson<int>(balance),
      'nextGrantAt': serializer.toJson<DateTime?>(nextGrantAt),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
    };
  }

  TokenStateData copyWith({
    int? id,
    int? balance,
    Value<DateTime?> nextGrantAt = const Value.absent(),
    Value<DateTime?> syncedAt = const Value.absent(),
  }) => TokenStateData(
    id: id ?? this.id,
    balance: balance ?? this.balance,
    nextGrantAt: nextGrantAt.present ? nextGrantAt.value : this.nextGrantAt,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
  );
  TokenStateData copyWithCompanion(TokenStateCompanion data) {
    return TokenStateData(
      id: data.id.present ? data.id.value : this.id,
      balance: data.balance.present ? data.balance.value : this.balance,
      nextGrantAt: data.nextGrantAt.present ? data.nextGrantAt.value : this.nextGrantAt,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TokenStateData(')
          ..write('id: $id, ')
          ..write('balance: $balance, ')
          ..write('nextGrantAt: $nextGrantAt, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, balance, nextGrantAt, syncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TokenStateData &&
          other.id == this.id &&
          other.balance == this.balance &&
          other.nextGrantAt == this.nextGrantAt &&
          other.syncedAt == this.syncedAt);
}

class TokenStateCompanion extends UpdateCompanion<TokenStateData> {
  final Value<int> id;
  final Value<int> balance;
  final Value<DateTime?> nextGrantAt;
  final Value<DateTime?> syncedAt;
  const TokenStateCompanion({
    this.id = const Value.absent(),
    this.balance = const Value.absent(),
    this.nextGrantAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
  });
  TokenStateCompanion.insert({
    this.id = const Value.absent(),
    this.balance = const Value.absent(),
    this.nextGrantAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
  });
  static Insertable<TokenStateData> custom({
    Expression<int>? id,
    Expression<int>? balance,
    Expression<DateTime>? nextGrantAt,
    Expression<DateTime>? syncedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (balance != null) 'balance': balance,
      if (nextGrantAt != null) 'next_grant_at': nextGrantAt,
      if (syncedAt != null) 'synced_at': syncedAt,
    });
  }

  TokenStateCompanion copyWith({
    Value<int>? id,
    Value<int>? balance,
    Value<DateTime?>? nextGrantAt,
    Value<DateTime?>? syncedAt,
  }) {
    return TokenStateCompanion(
      id: id ?? this.id,
      balance: balance ?? this.balance,
      nextGrantAt: nextGrantAt ?? this.nextGrantAt,
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (balance.present) {
      map['balance'] = Variable<int>(balance.value);
    }
    if (nextGrantAt.present) {
      map['next_grant_at'] = Variable<DateTime>(nextGrantAt.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TokenStateCompanion(')
          ..write('id: $id, ')
          ..write('balance: $balance, ')
          ..write('nextGrantAt: $nextGrantAt, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }
}

class $SyncMetaTable extends SyncMeta with TableInfo<$SyncMetaTable, SyncMetaData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncMetaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _cursorMeta = const VerificationMeta('cursor');
  @override
  late final GeneratedColumn<int> cursor = GeneratedColumn<int>(
    'cursor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastSyncAtMeta = const VerificationMeta('lastSyncAt');
  @override
  late final GeneratedColumn<DateTime> lastSyncAt = GeneratedColumn<DateTime>(
    'last_sync_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _accessTokenMeta = const VerificationMeta('accessToken');
  @override
  late final GeneratedColumn<String> accessToken = GeneratedColumn<String>(
    'access_token',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _refreshTokenMeta = const VerificationMeta('refreshToken');
  @override
  late final GeneratedColumn<String> refreshToken = GeneratedColumn<String>(
    'refresh_token',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _joinedAtMeta = const VerificationMeta('joinedAt');
  @override
  late final GeneratedColumn<DateTime> joinedAt = GeneratedColumn<DateTime>(
    'joined_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    cursor,
    lastSyncAt,
    userId,
    accessToken,
    refreshToken,
    email,
    joinedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_meta';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncMetaData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('cursor')) {
      context.handle(_cursorMeta, cursor.isAcceptableOrUnknown(data['cursor']!, _cursorMeta));
    }
    if (data.containsKey('last_sync_at')) {
      context.handle(
        _lastSyncAtMeta,
        lastSyncAt.isAcceptableOrUnknown(data['last_sync_at']!, _lastSyncAtMeta),
      );
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta, userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    }
    if (data.containsKey('access_token')) {
      context.handle(
        _accessTokenMeta,
        accessToken.isAcceptableOrUnknown(data['access_token']!, _accessTokenMeta),
      );
    }
    if (data.containsKey('refresh_token')) {
      context.handle(
        _refreshTokenMeta,
        refreshToken.isAcceptableOrUnknown(data['refresh_token']!, _refreshTokenMeta),
      );
    }
    if (data.containsKey('email')) {
      context.handle(_emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    }
    if (data.containsKey('joined_at')) {
      context.handle(
        _joinedAtMeta,
        joinedAt.isAcceptableOrUnknown(data['joined_at']!, _joinedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncMetaData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncMetaData(
      id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      cursor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cursor'],
      )!,
      lastSyncAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_sync_at'],
      ),
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      ),
      accessToken: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}access_token'],
      ),
      refreshToken: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}refresh_token'],
      ),
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      joinedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}joined_at'],
      ),
    );
  }

  @override
  $SyncMetaTable createAlias(String alias) {
    return $SyncMetaTable(attachedDatabase, alias);
  }
}

class SyncMetaData extends DataClass implements Insertable<SyncMetaData> {
  final int id;

  /// The last «seq» this device has seen from the server.
  final int cursor;
  final DateTime? lastSyncAt;

  /// Set when the account is signed in, so a fresh install can tell «my data»
  /// from «data left by whoever used this phone before me».
  final String? userId;
  final String? accessToken;
  final String? refreshToken;
  final String? email;
  final DateTime? joinedAt;
  const SyncMetaData({
    required this.id,
    required this.cursor,
    this.lastSyncAt,
    this.userId,
    this.accessToken,
    this.refreshToken,
    this.email,
    this.joinedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['cursor'] = Variable<int>(cursor);
    if (!nullToAbsent || lastSyncAt != null) {
      map['last_sync_at'] = Variable<DateTime>(lastSyncAt);
    }
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<String>(userId);
    }
    if (!nullToAbsent || accessToken != null) {
      map['access_token'] = Variable<String>(accessToken);
    }
    if (!nullToAbsent || refreshToken != null) {
      map['refresh_token'] = Variable<String>(refreshToken);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || joinedAt != null) {
      map['joined_at'] = Variable<DateTime>(joinedAt);
    }
    return map;
  }

  SyncMetaCompanion toCompanion(bool nullToAbsent) {
    return SyncMetaCompanion(
      id: Value(id),
      cursor: Value(cursor),
      lastSyncAt: lastSyncAt == null && nullToAbsent ? const Value.absent() : Value(lastSyncAt),
      userId: userId == null && nullToAbsent ? const Value.absent() : Value(userId),
      accessToken: accessToken == null && nullToAbsent ? const Value.absent() : Value(accessToken),
      refreshToken: refreshToken == null && nullToAbsent
          ? const Value.absent()
          : Value(refreshToken),
      email: email == null && nullToAbsent ? const Value.absent() : Value(email),
      joinedAt: joinedAt == null && nullToAbsent ? const Value.absent() : Value(joinedAt),
    );
  }

  factory SyncMetaData.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncMetaData(
      id: serializer.fromJson<int>(json['id']),
      cursor: serializer.fromJson<int>(json['cursor']),
      lastSyncAt: serializer.fromJson<DateTime?>(json['lastSyncAt']),
      userId: serializer.fromJson<String?>(json['userId']),
      accessToken: serializer.fromJson<String?>(json['accessToken']),
      refreshToken: serializer.fromJson<String?>(json['refreshToken']),
      email: serializer.fromJson<String?>(json['email']),
      joinedAt: serializer.fromJson<DateTime?>(json['joinedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'cursor': serializer.toJson<int>(cursor),
      'lastSyncAt': serializer.toJson<DateTime?>(lastSyncAt),
      'userId': serializer.toJson<String?>(userId),
      'accessToken': serializer.toJson<String?>(accessToken),
      'refreshToken': serializer.toJson<String?>(refreshToken),
      'email': serializer.toJson<String?>(email),
      'joinedAt': serializer.toJson<DateTime?>(joinedAt),
    };
  }

  SyncMetaData copyWith({
    int? id,
    int? cursor,
    Value<DateTime?> lastSyncAt = const Value.absent(),
    Value<String?> userId = const Value.absent(),
    Value<String?> accessToken = const Value.absent(),
    Value<String?> refreshToken = const Value.absent(),
    Value<String?> email = const Value.absent(),
    Value<DateTime?> joinedAt = const Value.absent(),
  }) => SyncMetaData(
    id: id ?? this.id,
    cursor: cursor ?? this.cursor,
    lastSyncAt: lastSyncAt.present ? lastSyncAt.value : this.lastSyncAt,
    userId: userId.present ? userId.value : this.userId,
    accessToken: accessToken.present ? accessToken.value : this.accessToken,
    refreshToken: refreshToken.present ? refreshToken.value : this.refreshToken,
    email: email.present ? email.value : this.email,
    joinedAt: joinedAt.present ? joinedAt.value : this.joinedAt,
  );
  SyncMetaData copyWithCompanion(SyncMetaCompanion data) {
    return SyncMetaData(
      id: data.id.present ? data.id.value : this.id,
      cursor: data.cursor.present ? data.cursor.value : this.cursor,
      lastSyncAt: data.lastSyncAt.present ? data.lastSyncAt.value : this.lastSyncAt,
      userId: data.userId.present ? data.userId.value : this.userId,
      accessToken: data.accessToken.present ? data.accessToken.value : this.accessToken,
      refreshToken: data.refreshToken.present ? data.refreshToken.value : this.refreshToken,
      email: data.email.present ? data.email.value : this.email,
      joinedAt: data.joinedAt.present ? data.joinedAt.value : this.joinedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetaData(')
          ..write('id: $id, ')
          ..write('cursor: $cursor, ')
          ..write('lastSyncAt: $lastSyncAt, ')
          ..write('userId: $userId, ')
          ..write('accessToken: $accessToken, ')
          ..write('refreshToken: $refreshToken, ')
          ..write('email: $email, ')
          ..write('joinedAt: $joinedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, cursor, lastSyncAt, userId, accessToken, refreshToken, email, joinedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncMetaData &&
          other.id == this.id &&
          other.cursor == this.cursor &&
          other.lastSyncAt == this.lastSyncAt &&
          other.userId == this.userId &&
          other.accessToken == this.accessToken &&
          other.refreshToken == this.refreshToken &&
          other.email == this.email &&
          other.joinedAt == this.joinedAt);
}

class SyncMetaCompanion extends UpdateCompanion<SyncMetaData> {
  final Value<int> id;
  final Value<int> cursor;
  final Value<DateTime?> lastSyncAt;
  final Value<String?> userId;
  final Value<String?> accessToken;
  final Value<String?> refreshToken;
  final Value<String?> email;
  final Value<DateTime?> joinedAt;
  const SyncMetaCompanion({
    this.id = const Value.absent(),
    this.cursor = const Value.absent(),
    this.lastSyncAt = const Value.absent(),
    this.userId = const Value.absent(),
    this.accessToken = const Value.absent(),
    this.refreshToken = const Value.absent(),
    this.email = const Value.absent(),
    this.joinedAt = const Value.absent(),
  });
  SyncMetaCompanion.insert({
    this.id = const Value.absent(),
    this.cursor = const Value.absent(),
    this.lastSyncAt = const Value.absent(),
    this.userId = const Value.absent(),
    this.accessToken = const Value.absent(),
    this.refreshToken = const Value.absent(),
    this.email = const Value.absent(),
    this.joinedAt = const Value.absent(),
  });
  static Insertable<SyncMetaData> custom({
    Expression<int>? id,
    Expression<int>? cursor,
    Expression<DateTime>? lastSyncAt,
    Expression<String>? userId,
    Expression<String>? accessToken,
    Expression<String>? refreshToken,
    Expression<String>? email,
    Expression<DateTime>? joinedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cursor != null) 'cursor': cursor,
      if (lastSyncAt != null) 'last_sync_at': lastSyncAt,
      if (userId != null) 'user_id': userId,
      if (accessToken != null) 'access_token': accessToken,
      if (refreshToken != null) 'refresh_token': refreshToken,
      if (email != null) 'email': email,
      if (joinedAt != null) 'joined_at': joinedAt,
    });
  }

  SyncMetaCompanion copyWith({
    Value<int>? id,
    Value<int>? cursor,
    Value<DateTime?>? lastSyncAt,
    Value<String?>? userId,
    Value<String?>? accessToken,
    Value<String?>? refreshToken,
    Value<String?>? email,
    Value<DateTime?>? joinedAt,
  }) {
    return SyncMetaCompanion(
      id: id ?? this.id,
      cursor: cursor ?? this.cursor,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      userId: userId ?? this.userId,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      email: email ?? this.email,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (cursor.present) {
      map['cursor'] = Variable<int>(cursor.value);
    }
    if (lastSyncAt.present) {
      map['last_sync_at'] = Variable<DateTime>(lastSyncAt.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (accessToken.present) {
      map['access_token'] = Variable<String>(accessToken.value);
    }
    if (refreshToken.present) {
      map['refresh_token'] = Variable<String>(refreshToken.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (joinedAt.present) {
      map['joined_at'] = Variable<DateTime>(joinedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetaCompanion(')
          ..write('id: $id, ')
          ..write('cursor: $cursor, ')
          ..write('lastSyncAt: $lastSyncAt, ')
          ..write('userId: $userId, ')
          ..write('accessToken: $accessToken, ')
          ..write('refreshToken: $refreshToken, ')
          ..write('email: $email, ')
          ..write('joinedAt: $joinedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$CalviDb extends GeneratedDatabase {
  _$CalviDb(QueryExecutor e) : super(e);
  $CalviDbManager get managers => $CalviDbManager(this);
  late final $MealsTable meals = $MealsTable(this);
  late final $WaterLogsTable waterLogs = $WaterLogsTable(this);
  late final $WeightsTable weights = $WeightsTable(this);
  late final $MeasurementsTable measurements = $MeasurementsTable(this);
  late final $WorkoutsTable workouts = $WorkoutsTable(this);
  late final $MedicationsTable medications = $MedicationsTable(this);
  late final $MedicationTakesTable medicationTakes = $MedicationTakesTable(this);
  late final $AllergiesTable allergies = $AllergiesTable(this);
  late final $ProfileTable profile = $ProfileTable(this);
  late final $ChatMessagesTable chatMessages = $ChatMessagesTable(this);
  late final $TokenStateTable tokenState = $TokenStateTable(this);
  late final $SyncMetaTable syncMeta = $SyncMetaTable(this);
  late final DiaryDao diaryDao = DiaryDao(this as CalviDb);
  late final SyncDao syncDao = SyncDao(this as CalviDb);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    meals,
    waterLogs,
    weights,
    measurements,
    workouts,
    medications,
    medicationTakes,
    allergies,
    profile,
    chatMessages,
    tokenState,
    syncMeta,
  ];
}

typedef $$MealsTableCreateCompanionBuilder =
    MealsCompanion Function({
      required String id,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<bool> dirty,
      Value<int?> seq,
      required String day,
      required DateTime at,
      Value<int> tzOffsetMin,
      required String slot,
      required String name,
      Value<String?> canonicalName,
      Value<String> icon,
      Value<double?> grams,
      required int kcal,
      Value<double> proteinG,
      Value<double> fatG,
      Value<double> carbsG,
      Value<String> source,
      Value<String?> note,
      Value<int> rowid,
    });
typedef $$MealsTableUpdateCompanionBuilder =
    MealsCompanion Function({
      Value<String> id,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<bool> dirty,
      Value<int?> seq,
      Value<String> day,
      Value<DateTime> at,
      Value<int> tzOffsetMin,
      Value<String> slot,
      Value<String> name,
      Value<String?> canonicalName,
      Value<String> icon,
      Value<double?> grams,
      Value<int> kcal,
      Value<double> proteinG,
      Value<double> fatG,
      Value<double> carbsG,
      Value<String> source,
      Value<String?> note,
      Value<int> rowid,
    });

class $$MealsTableFilterComposer extends Composer<_$CalviDb, $MealsTable> {
  $$MealsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get seq =>
      $composableBuilder(column: $table.seq, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get at =>
      $composableBuilder(column: $table.at, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get tzOffsetMin =>
      $composableBuilder(column: $table.tzOffsetMin, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get slot =>
      $composableBuilder(column: $table.slot, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get canonicalName =>
      $composableBuilder(column: $table.canonicalName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get grams =>
      $composableBuilder(column: $table.grams, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get kcal =>
      $composableBuilder(column: $table.kcal, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get proteinG =>
      $composableBuilder(column: $table.proteinG, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get fatG =>
      $composableBuilder(column: $table.fatG, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get carbsG =>
      $composableBuilder(column: $table.carbsG, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => ColumnFilters(column));
}

class $$MealsTableOrderingComposer extends Composer<_$CalviDb, $MealsTable> {
  $$MealsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get seq =>
      $composableBuilder(column: $table.seq, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get at =>
      $composableBuilder(column: $table.at, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get tzOffsetMin =>
      $composableBuilder(column: $table.tzOffsetMin, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get slot =>
      $composableBuilder(column: $table.slot, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get canonicalName => $composableBuilder(
    column: $table.canonicalName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get grams =>
      $composableBuilder(column: $table.grams, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get kcal =>
      $composableBuilder(column: $table.kcal, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get proteinG =>
      $composableBuilder(column: $table.proteinG, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get fatG =>
      $composableBuilder(column: $table.fatG, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get carbsG =>
      $composableBuilder(column: $table.carbsG, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => ColumnOrderings(column));
}

class $$MealsTableAnnotationComposer extends Composer<_$CalviDb, $MealsTable> {
  $$MealsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<bool> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => column);

  GeneratedColumn<int> get seq =>
      $composableBuilder(column: $table.seq, builder: (column) => column);

  GeneratedColumn<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<DateTime> get at =>
      $composableBuilder(column: $table.at, builder: (column) => column);

  GeneratedColumn<int> get tzOffsetMin =>
      $composableBuilder(column: $table.tzOffsetMin, builder: (column) => column);

  GeneratedColumn<String> get slot =>
      $composableBuilder(column: $table.slot, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get canonicalName =>
      $composableBuilder(column: $table.canonicalName, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<double> get grams =>
      $composableBuilder(column: $table.grams, builder: (column) => column);

  GeneratedColumn<int> get kcal =>
      $composableBuilder(column: $table.kcal, builder: (column) => column);

  GeneratedColumn<double> get proteinG =>
      $composableBuilder(column: $table.proteinG, builder: (column) => column);

  GeneratedColumn<double> get fatG =>
      $composableBuilder(column: $table.fatG, builder: (column) => column);

  GeneratedColumn<double> get carbsG =>
      $composableBuilder(column: $table.carbsG, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);
}

class $$MealsTableTableManager
    extends
        RootTableManager<
          _$CalviDb,
          $MealsTable,
          MealRow,
          $$MealsTableFilterComposer,
          $$MealsTableOrderingComposer,
          $$MealsTableAnnotationComposer,
          $$MealsTableCreateCompanionBuilder,
          $$MealsTableUpdateCompanionBuilder,
          (MealRow, BaseReferences<_$CalviDb, $MealsTable, MealRow>),
          MealRow,
          PrefetchHooks Function()
        > {
  $$MealsTableTableManager(_$CalviDb db, $MealsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$MealsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$MealsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$MealsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                Value<int?> seq = const Value.absent(),
                Value<String> day = const Value.absent(),
                Value<DateTime> at = const Value.absent(),
                Value<int> tzOffsetMin = const Value.absent(),
                Value<String> slot = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> canonicalName = const Value.absent(),
                Value<String> icon = const Value.absent(),
                Value<double?> grams = const Value.absent(),
                Value<int> kcal = const Value.absent(),
                Value<double> proteinG = const Value.absent(),
                Value<double> fatG = const Value.absent(),
                Value<double> carbsG = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MealsCompanion(
                id: id,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                dirty: dirty,
                seq: seq,
                day: day,
                at: at,
                tzOffsetMin: tzOffsetMin,
                slot: slot,
                name: name,
                canonicalName: canonicalName,
                icon: icon,
                grams: grams,
                kcal: kcal,
                proteinG: proteinG,
                fatG: fatG,
                carbsG: carbsG,
                source: source,
                note: note,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                Value<int?> seq = const Value.absent(),
                required String day,
                required DateTime at,
                Value<int> tzOffsetMin = const Value.absent(),
                required String slot,
                required String name,
                Value<String?> canonicalName = const Value.absent(),
                Value<String> icon = const Value.absent(),
                Value<double?> grams = const Value.absent(),
                required int kcal,
                Value<double> proteinG = const Value.absent(),
                Value<double> fatG = const Value.absent(),
                Value<double> carbsG = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MealsCompanion.insert(
                id: id,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                dirty: dirty,
                seq: seq,
                day: day,
                at: at,
                tzOffsetMin: tzOffsetMin,
                slot: slot,
                name: name,
                canonicalName: canonicalName,
                icon: icon,
                grams: grams,
                kcal: kcal,
                proteinG: proteinG,
                fatG: fatG,
                carbsG: carbsG,
                source: source,
                note: note,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MealsTableProcessedTableManager =
    ProcessedTableManager<
      _$CalviDb,
      $MealsTable,
      MealRow,
      $$MealsTableFilterComposer,
      $$MealsTableOrderingComposer,
      $$MealsTableAnnotationComposer,
      $$MealsTableCreateCompanionBuilder,
      $$MealsTableUpdateCompanionBuilder,
      (MealRow, BaseReferences<_$CalviDb, $MealsTable, MealRow>),
      MealRow,
      PrefetchHooks Function()
    >;
typedef $$WaterLogsTableCreateCompanionBuilder =
    WaterLogsCompanion Function({
      required String id,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<bool> dirty,
      Value<int?> seq,
      required String day,
      required DateTime at,
      required int ml,
      Value<int> rowid,
    });
typedef $$WaterLogsTableUpdateCompanionBuilder =
    WaterLogsCompanion Function({
      Value<String> id,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<bool> dirty,
      Value<int?> seq,
      Value<String> day,
      Value<DateTime> at,
      Value<int> ml,
      Value<int> rowid,
    });

class $$WaterLogsTableFilterComposer extends Composer<_$CalviDb, $WaterLogsTable> {
  $$WaterLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get seq =>
      $composableBuilder(column: $table.seq, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get at =>
      $composableBuilder(column: $table.at, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get ml =>
      $composableBuilder(column: $table.ml, builder: (column) => ColumnFilters(column));
}

class $$WaterLogsTableOrderingComposer extends Composer<_$CalviDb, $WaterLogsTable> {
  $$WaterLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get seq =>
      $composableBuilder(column: $table.seq, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get at =>
      $composableBuilder(column: $table.at, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get ml =>
      $composableBuilder(column: $table.ml, builder: (column) => ColumnOrderings(column));
}

class $$WaterLogsTableAnnotationComposer extends Composer<_$CalviDb, $WaterLogsTable> {
  $$WaterLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<bool> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => column);

  GeneratedColumn<int> get seq =>
      $composableBuilder(column: $table.seq, builder: (column) => column);

  GeneratedColumn<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<DateTime> get at =>
      $composableBuilder(column: $table.at, builder: (column) => column);

  GeneratedColumn<int> get ml => $composableBuilder(column: $table.ml, builder: (column) => column);
}

class $$WaterLogsTableTableManager
    extends
        RootTableManager<
          _$CalviDb,
          $WaterLogsTable,
          WaterLog,
          $$WaterLogsTableFilterComposer,
          $$WaterLogsTableOrderingComposer,
          $$WaterLogsTableAnnotationComposer,
          $$WaterLogsTableCreateCompanionBuilder,
          $$WaterLogsTableUpdateCompanionBuilder,
          (WaterLog, BaseReferences<_$CalviDb, $WaterLogsTable, WaterLog>),
          WaterLog,
          PrefetchHooks Function()
        > {
  $$WaterLogsTableTableManager(_$CalviDb db, $WaterLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$WaterLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$WaterLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WaterLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                Value<int?> seq = const Value.absent(),
                Value<String> day = const Value.absent(),
                Value<DateTime> at = const Value.absent(),
                Value<int> ml = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WaterLogsCompanion(
                id: id,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                dirty: dirty,
                seq: seq,
                day: day,
                at: at,
                ml: ml,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                Value<int?> seq = const Value.absent(),
                required String day,
                required DateTime at,
                required int ml,
                Value<int> rowid = const Value.absent(),
              }) => WaterLogsCompanion.insert(
                id: id,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                dirty: dirty,
                seq: seq,
                day: day,
                at: at,
                ml: ml,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WaterLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$CalviDb,
      $WaterLogsTable,
      WaterLog,
      $$WaterLogsTableFilterComposer,
      $$WaterLogsTableOrderingComposer,
      $$WaterLogsTableAnnotationComposer,
      $$WaterLogsTableCreateCompanionBuilder,
      $$WaterLogsTableUpdateCompanionBuilder,
      (WaterLog, BaseReferences<_$CalviDb, $WaterLogsTable, WaterLog>),
      WaterLog,
      PrefetchHooks Function()
    >;
typedef $$WeightsTableCreateCompanionBuilder =
    WeightsCompanion Function({
      required String id,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<bool> dirty,
      Value<int?> seq,
      required String day,
      required DateTime at,
      required double kg,
      Value<int> rowid,
    });
typedef $$WeightsTableUpdateCompanionBuilder =
    WeightsCompanion Function({
      Value<String> id,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<bool> dirty,
      Value<int?> seq,
      Value<String> day,
      Value<DateTime> at,
      Value<double> kg,
      Value<int> rowid,
    });

class $$WeightsTableFilterComposer extends Composer<_$CalviDb, $WeightsTable> {
  $$WeightsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get seq =>
      $composableBuilder(column: $table.seq, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get at =>
      $composableBuilder(column: $table.at, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get kg =>
      $composableBuilder(column: $table.kg, builder: (column) => ColumnFilters(column));
}

class $$WeightsTableOrderingComposer extends Composer<_$CalviDb, $WeightsTable> {
  $$WeightsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get seq =>
      $composableBuilder(column: $table.seq, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get at =>
      $composableBuilder(column: $table.at, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get kg =>
      $composableBuilder(column: $table.kg, builder: (column) => ColumnOrderings(column));
}

class $$WeightsTableAnnotationComposer extends Composer<_$CalviDb, $WeightsTable> {
  $$WeightsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<bool> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => column);

  GeneratedColumn<int> get seq =>
      $composableBuilder(column: $table.seq, builder: (column) => column);

  GeneratedColumn<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<DateTime> get at =>
      $composableBuilder(column: $table.at, builder: (column) => column);

  GeneratedColumn<double> get kg =>
      $composableBuilder(column: $table.kg, builder: (column) => column);
}

class $$WeightsTableTableManager
    extends
        RootTableManager<
          _$CalviDb,
          $WeightsTable,
          Weight,
          $$WeightsTableFilterComposer,
          $$WeightsTableOrderingComposer,
          $$WeightsTableAnnotationComposer,
          $$WeightsTableCreateCompanionBuilder,
          $$WeightsTableUpdateCompanionBuilder,
          (Weight, BaseReferences<_$CalviDb, $WeightsTable, Weight>),
          Weight,
          PrefetchHooks Function()
        > {
  $$WeightsTableTableManager(_$CalviDb db, $WeightsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$WeightsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$WeightsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WeightsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                Value<int?> seq = const Value.absent(),
                Value<String> day = const Value.absent(),
                Value<DateTime> at = const Value.absent(),
                Value<double> kg = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WeightsCompanion(
                id: id,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                dirty: dirty,
                seq: seq,
                day: day,
                at: at,
                kg: kg,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                Value<int?> seq = const Value.absent(),
                required String day,
                required DateTime at,
                required double kg,
                Value<int> rowid = const Value.absent(),
              }) => WeightsCompanion.insert(
                id: id,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                dirty: dirty,
                seq: seq,
                day: day,
                at: at,
                kg: kg,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WeightsTableProcessedTableManager =
    ProcessedTableManager<
      _$CalviDb,
      $WeightsTable,
      Weight,
      $$WeightsTableFilterComposer,
      $$WeightsTableOrderingComposer,
      $$WeightsTableAnnotationComposer,
      $$WeightsTableCreateCompanionBuilder,
      $$WeightsTableUpdateCompanionBuilder,
      (Weight, BaseReferences<_$CalviDb, $WeightsTable, Weight>),
      Weight,
      PrefetchHooks Function()
    >;
typedef $$MeasurementsTableCreateCompanionBuilder =
    MeasurementsCompanion Function({
      required String id,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<bool> dirty,
      Value<int?> seq,
      required String day,
      required DateTime at,
      required String part,
      required double cm,
      Value<int> rowid,
    });
typedef $$MeasurementsTableUpdateCompanionBuilder =
    MeasurementsCompanion Function({
      Value<String> id,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<bool> dirty,
      Value<int?> seq,
      Value<String> day,
      Value<DateTime> at,
      Value<String> part,
      Value<double> cm,
      Value<int> rowid,
    });

class $$MeasurementsTableFilterComposer extends Composer<_$CalviDb, $MeasurementsTable> {
  $$MeasurementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get seq =>
      $composableBuilder(column: $table.seq, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get at =>
      $composableBuilder(column: $table.at, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get part =>
      $composableBuilder(column: $table.part, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get cm =>
      $composableBuilder(column: $table.cm, builder: (column) => ColumnFilters(column));
}

class $$MeasurementsTableOrderingComposer extends Composer<_$CalviDb, $MeasurementsTable> {
  $$MeasurementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get seq =>
      $composableBuilder(column: $table.seq, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get at =>
      $composableBuilder(column: $table.at, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get part =>
      $composableBuilder(column: $table.part, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get cm =>
      $composableBuilder(column: $table.cm, builder: (column) => ColumnOrderings(column));
}

class $$MeasurementsTableAnnotationComposer extends Composer<_$CalviDb, $MeasurementsTable> {
  $$MeasurementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<bool> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => column);

  GeneratedColumn<int> get seq =>
      $composableBuilder(column: $table.seq, builder: (column) => column);

  GeneratedColumn<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<DateTime> get at =>
      $composableBuilder(column: $table.at, builder: (column) => column);

  GeneratedColumn<String> get part =>
      $composableBuilder(column: $table.part, builder: (column) => column);

  GeneratedColumn<double> get cm =>
      $composableBuilder(column: $table.cm, builder: (column) => column);
}

class $$MeasurementsTableTableManager
    extends
        RootTableManager<
          _$CalviDb,
          $MeasurementsTable,
          Measurement,
          $$MeasurementsTableFilterComposer,
          $$MeasurementsTableOrderingComposer,
          $$MeasurementsTableAnnotationComposer,
          $$MeasurementsTableCreateCompanionBuilder,
          $$MeasurementsTableUpdateCompanionBuilder,
          (Measurement, BaseReferences<_$CalviDb, $MeasurementsTable, Measurement>),
          Measurement,
          PrefetchHooks Function()
        > {
  $$MeasurementsTableTableManager(_$CalviDb db, $MeasurementsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$MeasurementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$MeasurementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MeasurementsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                Value<int?> seq = const Value.absent(),
                Value<String> day = const Value.absent(),
                Value<DateTime> at = const Value.absent(),
                Value<String> part = const Value.absent(),
                Value<double> cm = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MeasurementsCompanion(
                id: id,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                dirty: dirty,
                seq: seq,
                day: day,
                at: at,
                part: part,
                cm: cm,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                Value<int?> seq = const Value.absent(),
                required String day,
                required DateTime at,
                required String part,
                required double cm,
                Value<int> rowid = const Value.absent(),
              }) => MeasurementsCompanion.insert(
                id: id,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                dirty: dirty,
                seq: seq,
                day: day,
                at: at,
                part: part,
                cm: cm,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MeasurementsTableProcessedTableManager =
    ProcessedTableManager<
      _$CalviDb,
      $MeasurementsTable,
      Measurement,
      $$MeasurementsTableFilterComposer,
      $$MeasurementsTableOrderingComposer,
      $$MeasurementsTableAnnotationComposer,
      $$MeasurementsTableCreateCompanionBuilder,
      $$MeasurementsTableUpdateCompanionBuilder,
      (Measurement, BaseReferences<_$CalviDb, $MeasurementsTable, Measurement>),
      Measurement,
      PrefetchHooks Function()
    >;
typedef $$WorkoutsTableCreateCompanionBuilder =
    WorkoutsCompanion Function({
      required String id,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<bool> dirty,
      Value<int?> seq,
      required String day,
      required DateTime at,
      required String kind,
      required int minutes,
      Value<int> kcal,
      Value<int> rowid,
    });
typedef $$WorkoutsTableUpdateCompanionBuilder =
    WorkoutsCompanion Function({
      Value<String> id,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<bool> dirty,
      Value<int?> seq,
      Value<String> day,
      Value<DateTime> at,
      Value<String> kind,
      Value<int> minutes,
      Value<int> kcal,
      Value<int> rowid,
    });

class $$WorkoutsTableFilterComposer extends Composer<_$CalviDb, $WorkoutsTable> {
  $$WorkoutsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get seq =>
      $composableBuilder(column: $table.seq, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get at =>
      $composableBuilder(column: $table.at, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get minutes =>
      $composableBuilder(column: $table.minutes, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get kcal =>
      $composableBuilder(column: $table.kcal, builder: (column) => ColumnFilters(column));
}

class $$WorkoutsTableOrderingComposer extends Composer<_$CalviDb, $WorkoutsTable> {
  $$WorkoutsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get seq =>
      $composableBuilder(column: $table.seq, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get at =>
      $composableBuilder(column: $table.at, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get minutes =>
      $composableBuilder(column: $table.minutes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get kcal =>
      $composableBuilder(column: $table.kcal, builder: (column) => ColumnOrderings(column));
}

class $$WorkoutsTableAnnotationComposer extends Composer<_$CalviDb, $WorkoutsTable> {
  $$WorkoutsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<bool> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => column);

  GeneratedColumn<int> get seq =>
      $composableBuilder(column: $table.seq, builder: (column) => column);

  GeneratedColumn<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<DateTime> get at =>
      $composableBuilder(column: $table.at, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<int> get minutes =>
      $composableBuilder(column: $table.minutes, builder: (column) => column);

  GeneratedColumn<int> get kcal =>
      $composableBuilder(column: $table.kcal, builder: (column) => column);
}

class $$WorkoutsTableTableManager
    extends
        RootTableManager<
          _$CalviDb,
          $WorkoutsTable,
          WorkoutRow,
          $$WorkoutsTableFilterComposer,
          $$WorkoutsTableOrderingComposer,
          $$WorkoutsTableAnnotationComposer,
          $$WorkoutsTableCreateCompanionBuilder,
          $$WorkoutsTableUpdateCompanionBuilder,
          (WorkoutRow, BaseReferences<_$CalviDb, $WorkoutsTable, WorkoutRow>),
          WorkoutRow,
          PrefetchHooks Function()
        > {
  $$WorkoutsTableTableManager(_$CalviDb db, $WorkoutsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$WorkoutsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$WorkoutsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkoutsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                Value<int?> seq = const Value.absent(),
                Value<String> day = const Value.absent(),
                Value<DateTime> at = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<int> minutes = const Value.absent(),
                Value<int> kcal = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkoutsCompanion(
                id: id,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                dirty: dirty,
                seq: seq,
                day: day,
                at: at,
                kind: kind,
                minutes: minutes,
                kcal: kcal,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                Value<int?> seq = const Value.absent(),
                required String day,
                required DateTime at,
                required String kind,
                required int minutes,
                Value<int> kcal = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkoutsCompanion.insert(
                id: id,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                dirty: dirty,
                seq: seq,
                day: day,
                at: at,
                kind: kind,
                minutes: minutes,
                kcal: kcal,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WorkoutsTableProcessedTableManager =
    ProcessedTableManager<
      _$CalviDb,
      $WorkoutsTable,
      WorkoutRow,
      $$WorkoutsTableFilterComposer,
      $$WorkoutsTableOrderingComposer,
      $$WorkoutsTableAnnotationComposer,
      $$WorkoutsTableCreateCompanionBuilder,
      $$WorkoutsTableUpdateCompanionBuilder,
      (WorkoutRow, BaseReferences<_$CalviDb, $WorkoutsTable, WorkoutRow>),
      WorkoutRow,
      PrefetchHooks Function()
    >;
typedef $$MedicationsTableCreateCompanionBuilder =
    MedicationsCompanion Function({
      required String id,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<bool> dirty,
      Value<int?> seq,
      required String name,
      Value<String?> amount,
      Value<String?> note,
      Value<String> times,
      Value<bool> remind,
      Value<String> schedule,
      Value<String> form,
      Value<String> startDay,
      Value<String?> endDay,
      Value<int> rowid,
    });
typedef $$MedicationsTableUpdateCompanionBuilder =
    MedicationsCompanion Function({
      Value<String> id,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<bool> dirty,
      Value<int?> seq,
      Value<String> name,
      Value<String?> amount,
      Value<String?> note,
      Value<String> times,
      Value<bool> remind,
      Value<String> schedule,
      Value<String> form,
      Value<String> startDay,
      Value<String?> endDay,
      Value<int> rowid,
    });

class $$MedicationsTableFilterComposer extends Composer<_$CalviDb, $MedicationsTable> {
  $$MedicationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get seq =>
      $composableBuilder(column: $table.seq, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get times =>
      $composableBuilder(column: $table.times, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get remind =>
      $composableBuilder(column: $table.remind, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get schedule =>
      $composableBuilder(column: $table.schedule, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get form =>
      $composableBuilder(column: $table.form, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get startDay =>
      $composableBuilder(column: $table.startDay, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get endDay =>
      $composableBuilder(column: $table.endDay, builder: (column) => ColumnFilters(column));
}

class $$MedicationsTableOrderingComposer extends Composer<_$CalviDb, $MedicationsTable> {
  $$MedicationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get seq =>
      $composableBuilder(column: $table.seq, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get times =>
      $composableBuilder(column: $table.times, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get remind =>
      $composableBuilder(column: $table.remind, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get schedule =>
      $composableBuilder(column: $table.schedule, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get form =>
      $composableBuilder(column: $table.form, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get startDay =>
      $composableBuilder(column: $table.startDay, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get endDay =>
      $composableBuilder(column: $table.endDay, builder: (column) => ColumnOrderings(column));
}

class $$MedicationsTableAnnotationComposer extends Composer<_$CalviDb, $MedicationsTable> {
  $$MedicationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<bool> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => column);

  GeneratedColumn<int> get seq =>
      $composableBuilder(column: $table.seq, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get times =>
      $composableBuilder(column: $table.times, builder: (column) => column);

  GeneratedColumn<bool> get remind =>
      $composableBuilder(column: $table.remind, builder: (column) => column);

  GeneratedColumn<String> get schedule =>
      $composableBuilder(column: $table.schedule, builder: (column) => column);

  GeneratedColumn<String> get form =>
      $composableBuilder(column: $table.form, builder: (column) => column);

  GeneratedColumn<String> get startDay =>
      $composableBuilder(column: $table.startDay, builder: (column) => column);

  GeneratedColumn<String> get endDay =>
      $composableBuilder(column: $table.endDay, builder: (column) => column);
}

class $$MedicationsTableTableManager
    extends
        RootTableManager<
          _$CalviDb,
          $MedicationsTable,
          Medication,
          $$MedicationsTableFilterComposer,
          $$MedicationsTableOrderingComposer,
          $$MedicationsTableAnnotationComposer,
          $$MedicationsTableCreateCompanionBuilder,
          $$MedicationsTableUpdateCompanionBuilder,
          (Medication, BaseReferences<_$CalviDb, $MedicationsTable, Medication>),
          Medication,
          PrefetchHooks Function()
        > {
  $$MedicationsTableTableManager(_$CalviDb db, $MedicationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$MedicationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$MedicationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MedicationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                Value<int?> seq = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> amount = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String> times = const Value.absent(),
                Value<bool> remind = const Value.absent(),
                Value<String> schedule = const Value.absent(),
                Value<String> form = const Value.absent(),
                Value<String> startDay = const Value.absent(),
                Value<String?> endDay = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MedicationsCompanion(
                id: id,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                dirty: dirty,
                seq: seq,
                name: name,
                amount: amount,
                note: note,
                times: times,
                remind: remind,
                schedule: schedule,
                form: form,
                startDay: startDay,
                endDay: endDay,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                Value<int?> seq = const Value.absent(),
                required String name,
                Value<String?> amount = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String> times = const Value.absent(),
                Value<bool> remind = const Value.absent(),
                Value<String> schedule = const Value.absent(),
                Value<String> form = const Value.absent(),
                Value<String> startDay = const Value.absent(),
                Value<String?> endDay = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MedicationsCompanion.insert(
                id: id,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                dirty: dirty,
                seq: seq,
                name: name,
                amount: amount,
                note: note,
                times: times,
                remind: remind,
                schedule: schedule,
                form: form,
                startDay: startDay,
                endDay: endDay,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MedicationsTableProcessedTableManager =
    ProcessedTableManager<
      _$CalviDb,
      $MedicationsTable,
      Medication,
      $$MedicationsTableFilterComposer,
      $$MedicationsTableOrderingComposer,
      $$MedicationsTableAnnotationComposer,
      $$MedicationsTableCreateCompanionBuilder,
      $$MedicationsTableUpdateCompanionBuilder,
      (Medication, BaseReferences<_$CalviDb, $MedicationsTable, Medication>),
      Medication,
      PrefetchHooks Function()
    >;
typedef $$MedicationTakesTableCreateCompanionBuilder =
    MedicationTakesCompanion Function({
      required String id,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<bool> dirty,
      Value<int?> seq,
      required String medicationId,
      required String day,
      required DateTime at,
      Value<String?> plannedTime,
      Value<int> rowid,
    });
typedef $$MedicationTakesTableUpdateCompanionBuilder =
    MedicationTakesCompanion Function({
      Value<String> id,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<bool> dirty,
      Value<int?> seq,
      Value<String> medicationId,
      Value<String> day,
      Value<DateTime> at,
      Value<String?> plannedTime,
      Value<int> rowid,
    });

class $$MedicationTakesTableFilterComposer extends Composer<_$CalviDb, $MedicationTakesTable> {
  $$MedicationTakesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get seq =>
      $composableBuilder(column: $table.seq, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get medicationId =>
      $composableBuilder(column: $table.medicationId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get at =>
      $composableBuilder(column: $table.at, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get plannedTime =>
      $composableBuilder(column: $table.plannedTime, builder: (column) => ColumnFilters(column));
}

class $$MedicationTakesTableOrderingComposer extends Composer<_$CalviDb, $MedicationTakesTable> {
  $$MedicationTakesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get seq =>
      $composableBuilder(column: $table.seq, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get medicationId =>
      $composableBuilder(column: $table.medicationId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get at =>
      $composableBuilder(column: $table.at, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get plannedTime =>
      $composableBuilder(column: $table.plannedTime, builder: (column) => ColumnOrderings(column));
}

class $$MedicationTakesTableAnnotationComposer extends Composer<_$CalviDb, $MedicationTakesTable> {
  $$MedicationTakesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<bool> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => column);

  GeneratedColumn<int> get seq =>
      $composableBuilder(column: $table.seq, builder: (column) => column);

  GeneratedColumn<String> get medicationId =>
      $composableBuilder(column: $table.medicationId, builder: (column) => column);

  GeneratedColumn<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<DateTime> get at =>
      $composableBuilder(column: $table.at, builder: (column) => column);

  GeneratedColumn<String> get plannedTime =>
      $composableBuilder(column: $table.plannedTime, builder: (column) => column);
}

class $$MedicationTakesTableTableManager
    extends
        RootTableManager<
          _$CalviDb,
          $MedicationTakesTable,
          MedicationTake,
          $$MedicationTakesTableFilterComposer,
          $$MedicationTakesTableOrderingComposer,
          $$MedicationTakesTableAnnotationComposer,
          $$MedicationTakesTableCreateCompanionBuilder,
          $$MedicationTakesTableUpdateCompanionBuilder,
          (MedicationTake, BaseReferences<_$CalviDb, $MedicationTakesTable, MedicationTake>),
          MedicationTake,
          PrefetchHooks Function()
        > {
  $$MedicationTakesTableTableManager(_$CalviDb db, $MedicationTakesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MedicationTakesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MedicationTakesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MedicationTakesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                Value<int?> seq = const Value.absent(),
                Value<String> medicationId = const Value.absent(),
                Value<String> day = const Value.absent(),
                Value<DateTime> at = const Value.absent(),
                Value<String?> plannedTime = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MedicationTakesCompanion(
                id: id,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                dirty: dirty,
                seq: seq,
                medicationId: medicationId,
                day: day,
                at: at,
                plannedTime: plannedTime,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                Value<int?> seq = const Value.absent(),
                required String medicationId,
                required String day,
                required DateTime at,
                Value<String?> plannedTime = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MedicationTakesCompanion.insert(
                id: id,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                dirty: dirty,
                seq: seq,
                medicationId: medicationId,
                day: day,
                at: at,
                plannedTime: plannedTime,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MedicationTakesTableProcessedTableManager =
    ProcessedTableManager<
      _$CalviDb,
      $MedicationTakesTable,
      MedicationTake,
      $$MedicationTakesTableFilterComposer,
      $$MedicationTakesTableOrderingComposer,
      $$MedicationTakesTableAnnotationComposer,
      $$MedicationTakesTableCreateCompanionBuilder,
      $$MedicationTakesTableUpdateCompanionBuilder,
      (MedicationTake, BaseReferences<_$CalviDb, $MedicationTakesTable, MedicationTake>),
      MedicationTake,
      PrefetchHooks Function()
    >;
typedef $$AllergiesTableCreateCompanionBuilder =
    AllergiesCompanion Function({
      required String id,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<bool> dirty,
      Value<int?> seq,
      required String allergenId,
      Value<bool> severe,
      Value<int> rowid,
    });
typedef $$AllergiesTableUpdateCompanionBuilder =
    AllergiesCompanion Function({
      Value<String> id,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<bool> dirty,
      Value<int?> seq,
      Value<String> allergenId,
      Value<bool> severe,
      Value<int> rowid,
    });

class $$AllergiesTableFilterComposer extends Composer<_$CalviDb, $AllergiesTable> {
  $$AllergiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get seq =>
      $composableBuilder(column: $table.seq, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get allergenId =>
      $composableBuilder(column: $table.allergenId, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get severe =>
      $composableBuilder(column: $table.severe, builder: (column) => ColumnFilters(column));
}

class $$AllergiesTableOrderingComposer extends Composer<_$CalviDb, $AllergiesTable> {
  $$AllergiesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get seq =>
      $composableBuilder(column: $table.seq, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get allergenId =>
      $composableBuilder(column: $table.allergenId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get severe =>
      $composableBuilder(column: $table.severe, builder: (column) => ColumnOrderings(column));
}

class $$AllergiesTableAnnotationComposer extends Composer<_$CalviDb, $AllergiesTable> {
  $$AllergiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<bool> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => column);

  GeneratedColumn<int> get seq =>
      $composableBuilder(column: $table.seq, builder: (column) => column);

  GeneratedColumn<String> get allergenId =>
      $composableBuilder(column: $table.allergenId, builder: (column) => column);

  GeneratedColumn<bool> get severe =>
      $composableBuilder(column: $table.severe, builder: (column) => column);
}

class $$AllergiesTableTableManager
    extends
        RootTableManager<
          _$CalviDb,
          $AllergiesTable,
          Allergy,
          $$AllergiesTableFilterComposer,
          $$AllergiesTableOrderingComposer,
          $$AllergiesTableAnnotationComposer,
          $$AllergiesTableCreateCompanionBuilder,
          $$AllergiesTableUpdateCompanionBuilder,
          (Allergy, BaseReferences<_$CalviDb, $AllergiesTable, Allergy>),
          Allergy,
          PrefetchHooks Function()
        > {
  $$AllergiesTableTableManager(_$CalviDb db, $AllergiesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$AllergiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$AllergiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AllergiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                Value<int?> seq = const Value.absent(),
                Value<String> allergenId = const Value.absent(),
                Value<bool> severe = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AllergiesCompanion(
                id: id,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                dirty: dirty,
                seq: seq,
                allergenId: allergenId,
                severe: severe,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                Value<int?> seq = const Value.absent(),
                required String allergenId,
                Value<bool> severe = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AllergiesCompanion.insert(
                id: id,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                dirty: dirty,
                seq: seq,
                allergenId: allergenId,
                severe: severe,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AllergiesTableProcessedTableManager =
    ProcessedTableManager<
      _$CalviDb,
      $AllergiesTable,
      Allergy,
      $$AllergiesTableFilterComposer,
      $$AllergiesTableOrderingComposer,
      $$AllergiesTableAnnotationComposer,
      $$AllergiesTableCreateCompanionBuilder,
      $$AllergiesTableUpdateCompanionBuilder,
      (Allergy, BaseReferences<_$CalviDb, $AllergiesTable, Allergy>),
      Allergy,
      PrefetchHooks Function()
    >;
typedef $$ProfileTableCreateCompanionBuilder =
    ProfileCompanion Function({
      required String id,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<bool> dirty,
      Value<int?> seq,
      Value<String> sex,
      Value<int?> birthYear,
      Value<int?> heightCm,
      Value<double?> goalStartKg,
      Value<double?> targetKg,
      Value<String> direction,
      Value<double> pace,
      Value<double> activity,
      Value<int?> kcalManual,
      Value<int?> proteinG,
      Value<int?> fatG,
      Value<int?> carbsG,
      Value<int> waterMl,
      Value<String> theme,
      Value<String> lang,
      Value<String?> addressAs,
      Value<String> memory,
      Value<String> reminders,
      Value<String> tracked,
      Value<int> rowid,
    });
typedef $$ProfileTableUpdateCompanionBuilder =
    ProfileCompanion Function({
      Value<String> id,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<bool> dirty,
      Value<int?> seq,
      Value<String> sex,
      Value<int?> birthYear,
      Value<int?> heightCm,
      Value<double?> goalStartKg,
      Value<double?> targetKg,
      Value<String> direction,
      Value<double> pace,
      Value<double> activity,
      Value<int?> kcalManual,
      Value<int?> proteinG,
      Value<int?> fatG,
      Value<int?> carbsG,
      Value<int> waterMl,
      Value<String> theme,
      Value<String> lang,
      Value<String?> addressAs,
      Value<String> memory,
      Value<String> reminders,
      Value<String> tracked,
      Value<int> rowid,
    });

class $$ProfileTableFilterComposer extends Composer<_$CalviDb, $ProfileTable> {
  $$ProfileTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get seq =>
      $composableBuilder(column: $table.seq, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sex =>
      $composableBuilder(column: $table.sex, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get birthYear =>
      $composableBuilder(column: $table.birthYear, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get heightCm =>
      $composableBuilder(column: $table.heightCm, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get goalStartKg =>
      $composableBuilder(column: $table.goalStartKg, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get targetKg =>
      $composableBuilder(column: $table.targetKg, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get direction =>
      $composableBuilder(column: $table.direction, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get pace =>
      $composableBuilder(column: $table.pace, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get activity =>
      $composableBuilder(column: $table.activity, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get kcalManual =>
      $composableBuilder(column: $table.kcalManual, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get proteinG =>
      $composableBuilder(column: $table.proteinG, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get fatG =>
      $composableBuilder(column: $table.fatG, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get carbsG =>
      $composableBuilder(column: $table.carbsG, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get waterMl =>
      $composableBuilder(column: $table.waterMl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get theme =>
      $composableBuilder(column: $table.theme, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lang =>
      $composableBuilder(column: $table.lang, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get addressAs =>
      $composableBuilder(column: $table.addressAs, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get memory =>
      $composableBuilder(column: $table.memory, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reminders =>
      $composableBuilder(column: $table.reminders, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tracked =>
      $composableBuilder(column: $table.tracked, builder: (column) => ColumnFilters(column));
}

class $$ProfileTableOrderingComposer extends Composer<_$CalviDb, $ProfileTable> {
  $$ProfileTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get seq =>
      $composableBuilder(column: $table.seq, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sex =>
      $composableBuilder(column: $table.sex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get birthYear =>
      $composableBuilder(column: $table.birthYear, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get heightCm =>
      $composableBuilder(column: $table.heightCm, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get goalStartKg =>
      $composableBuilder(column: $table.goalStartKg, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get targetKg =>
      $composableBuilder(column: $table.targetKg, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get direction =>
      $composableBuilder(column: $table.direction, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get pace =>
      $composableBuilder(column: $table.pace, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get activity =>
      $composableBuilder(column: $table.activity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get kcalManual =>
      $composableBuilder(column: $table.kcalManual, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get proteinG =>
      $composableBuilder(column: $table.proteinG, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get fatG =>
      $composableBuilder(column: $table.fatG, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get carbsG =>
      $composableBuilder(column: $table.carbsG, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get waterMl =>
      $composableBuilder(column: $table.waterMl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get theme =>
      $composableBuilder(column: $table.theme, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lang =>
      $composableBuilder(column: $table.lang, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get addressAs =>
      $composableBuilder(column: $table.addressAs, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get memory =>
      $composableBuilder(column: $table.memory, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reminders =>
      $composableBuilder(column: $table.reminders, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tracked =>
      $composableBuilder(column: $table.tracked, builder: (column) => ColumnOrderings(column));
}

class $$ProfileTableAnnotationComposer extends Composer<_$CalviDb, $ProfileTable> {
  $$ProfileTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<bool> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => column);

  GeneratedColumn<int> get seq =>
      $composableBuilder(column: $table.seq, builder: (column) => column);

  GeneratedColumn<String> get sex =>
      $composableBuilder(column: $table.sex, builder: (column) => column);

  GeneratedColumn<int> get birthYear =>
      $composableBuilder(column: $table.birthYear, builder: (column) => column);

  GeneratedColumn<int> get heightCm =>
      $composableBuilder(column: $table.heightCm, builder: (column) => column);

  GeneratedColumn<double> get goalStartKg =>
      $composableBuilder(column: $table.goalStartKg, builder: (column) => column);

  GeneratedColumn<double> get targetKg =>
      $composableBuilder(column: $table.targetKg, builder: (column) => column);

  GeneratedColumn<String> get direction =>
      $composableBuilder(column: $table.direction, builder: (column) => column);

  GeneratedColumn<double> get pace =>
      $composableBuilder(column: $table.pace, builder: (column) => column);

  GeneratedColumn<double> get activity =>
      $composableBuilder(column: $table.activity, builder: (column) => column);

  GeneratedColumn<int> get kcalManual =>
      $composableBuilder(column: $table.kcalManual, builder: (column) => column);

  GeneratedColumn<int> get proteinG =>
      $composableBuilder(column: $table.proteinG, builder: (column) => column);

  GeneratedColumn<int> get fatG =>
      $composableBuilder(column: $table.fatG, builder: (column) => column);

  GeneratedColumn<int> get carbsG =>
      $composableBuilder(column: $table.carbsG, builder: (column) => column);

  GeneratedColumn<int> get waterMl =>
      $composableBuilder(column: $table.waterMl, builder: (column) => column);

  GeneratedColumn<String> get theme =>
      $composableBuilder(column: $table.theme, builder: (column) => column);

  GeneratedColumn<String> get lang =>
      $composableBuilder(column: $table.lang, builder: (column) => column);

  GeneratedColumn<String> get addressAs =>
      $composableBuilder(column: $table.addressAs, builder: (column) => column);

  GeneratedColumn<String> get memory =>
      $composableBuilder(column: $table.memory, builder: (column) => column);

  GeneratedColumn<String> get reminders =>
      $composableBuilder(column: $table.reminders, builder: (column) => column);

  GeneratedColumn<String> get tracked =>
      $composableBuilder(column: $table.tracked, builder: (column) => column);
}

class $$ProfileTableTableManager
    extends
        RootTableManager<
          _$CalviDb,
          $ProfileTable,
          ProfileData,
          $$ProfileTableFilterComposer,
          $$ProfileTableOrderingComposer,
          $$ProfileTableAnnotationComposer,
          $$ProfileTableCreateCompanionBuilder,
          $$ProfileTableUpdateCompanionBuilder,
          (ProfileData, BaseReferences<_$CalviDb, $ProfileTable, ProfileData>),
          ProfileData,
          PrefetchHooks Function()
        > {
  $$ProfileTableTableManager(_$CalviDb db, $ProfileTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$ProfileTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$ProfileTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProfileTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                Value<int?> seq = const Value.absent(),
                Value<String> sex = const Value.absent(),
                Value<int?> birthYear = const Value.absent(),
                Value<int?> heightCm = const Value.absent(),
                Value<double?> goalStartKg = const Value.absent(),
                Value<double?> targetKg = const Value.absent(),
                Value<String> direction = const Value.absent(),
                Value<double> pace = const Value.absent(),
                Value<double> activity = const Value.absent(),
                Value<int?> kcalManual = const Value.absent(),
                Value<int?> proteinG = const Value.absent(),
                Value<int?> fatG = const Value.absent(),
                Value<int?> carbsG = const Value.absent(),
                Value<int> waterMl = const Value.absent(),
                Value<String> theme = const Value.absent(),
                Value<String> lang = const Value.absent(),
                Value<String?> addressAs = const Value.absent(),
                Value<String> memory = const Value.absent(),
                Value<String> reminders = const Value.absent(),
                Value<String> tracked = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProfileCompanion(
                id: id,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                dirty: dirty,
                seq: seq,
                sex: sex,
                birthYear: birthYear,
                heightCm: heightCm,
                goalStartKg: goalStartKg,
                targetKg: targetKg,
                direction: direction,
                pace: pace,
                activity: activity,
                kcalManual: kcalManual,
                proteinG: proteinG,
                fatG: fatG,
                carbsG: carbsG,
                waterMl: waterMl,
                theme: theme,
                lang: lang,
                addressAs: addressAs,
                memory: memory,
                reminders: reminders,
                tracked: tracked,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                Value<int?> seq = const Value.absent(),
                Value<String> sex = const Value.absent(),
                Value<int?> birthYear = const Value.absent(),
                Value<int?> heightCm = const Value.absent(),
                Value<double?> goalStartKg = const Value.absent(),
                Value<double?> targetKg = const Value.absent(),
                Value<String> direction = const Value.absent(),
                Value<double> pace = const Value.absent(),
                Value<double> activity = const Value.absent(),
                Value<int?> kcalManual = const Value.absent(),
                Value<int?> proteinG = const Value.absent(),
                Value<int?> fatG = const Value.absent(),
                Value<int?> carbsG = const Value.absent(),
                Value<int> waterMl = const Value.absent(),
                Value<String> theme = const Value.absent(),
                Value<String> lang = const Value.absent(),
                Value<String?> addressAs = const Value.absent(),
                Value<String> memory = const Value.absent(),
                Value<String> reminders = const Value.absent(),
                Value<String> tracked = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProfileCompanion.insert(
                id: id,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                dirty: dirty,
                seq: seq,
                sex: sex,
                birthYear: birthYear,
                heightCm: heightCm,
                goalStartKg: goalStartKg,
                targetKg: targetKg,
                direction: direction,
                pace: pace,
                activity: activity,
                kcalManual: kcalManual,
                proteinG: proteinG,
                fatG: fatG,
                carbsG: carbsG,
                waterMl: waterMl,
                theme: theme,
                lang: lang,
                addressAs: addressAs,
                memory: memory,
                reminders: reminders,
                tracked: tracked,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProfileTableProcessedTableManager =
    ProcessedTableManager<
      _$CalviDb,
      $ProfileTable,
      ProfileData,
      $$ProfileTableFilterComposer,
      $$ProfileTableOrderingComposer,
      $$ProfileTableAnnotationComposer,
      $$ProfileTableCreateCompanionBuilder,
      $$ProfileTableUpdateCompanionBuilder,
      (ProfileData, BaseReferences<_$CalviDb, $ProfileTable, ProfileData>),
      ProfileData,
      PrefetchHooks Function()
    >;
typedef $$ChatMessagesTableCreateCompanionBuilder =
    ChatMessagesCompanion Function({
      required String id,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<bool> dirty,
      Value<int?> seq,
      required String role,
      required String body,
      required DateTime at,
      Value<int> spent,
      Value<int> rowid,
    });
typedef $$ChatMessagesTableUpdateCompanionBuilder =
    ChatMessagesCompanion Function({
      Value<String> id,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<bool> dirty,
      Value<int?> seq,
      Value<String> role,
      Value<String> body,
      Value<DateTime> at,
      Value<int> spent,
      Value<int> rowid,
    });

class $$ChatMessagesTableFilterComposer extends Composer<_$CalviDb, $ChatMessagesTable> {
  $$ChatMessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get seq =>
      $composableBuilder(column: $table.seq, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get at =>
      $composableBuilder(column: $table.at, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get spent =>
      $composableBuilder(column: $table.spent, builder: (column) => ColumnFilters(column));
}

class $$ChatMessagesTableOrderingComposer extends Composer<_$CalviDb, $ChatMessagesTable> {
  $$ChatMessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get seq =>
      $composableBuilder(column: $table.seq, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get at =>
      $composableBuilder(column: $table.at, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get spent =>
      $composableBuilder(column: $table.spent, builder: (column) => ColumnOrderings(column));
}

class $$ChatMessagesTableAnnotationComposer extends Composer<_$CalviDb, $ChatMessagesTable> {
  $$ChatMessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<bool> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => column);

  GeneratedColumn<int> get seq =>
      $composableBuilder(column: $table.seq, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<DateTime> get at =>
      $composableBuilder(column: $table.at, builder: (column) => column);

  GeneratedColumn<int> get spent =>
      $composableBuilder(column: $table.spent, builder: (column) => column);
}

class $$ChatMessagesTableTableManager
    extends
        RootTableManager<
          _$CalviDb,
          $ChatMessagesTable,
          ChatMessage,
          $$ChatMessagesTableFilterComposer,
          $$ChatMessagesTableOrderingComposer,
          $$ChatMessagesTableAnnotationComposer,
          $$ChatMessagesTableCreateCompanionBuilder,
          $$ChatMessagesTableUpdateCompanionBuilder,
          (ChatMessage, BaseReferences<_$CalviDb, $ChatMessagesTable, ChatMessage>),
          ChatMessage,
          PrefetchHooks Function()
        > {
  $$ChatMessagesTableTableManager(_$CalviDb db, $ChatMessagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$ChatMessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$ChatMessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChatMessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                Value<int?> seq = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<DateTime> at = const Value.absent(),
                Value<int> spent = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChatMessagesCompanion(
                id: id,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                dirty: dirty,
                seq: seq,
                role: role,
                body: body,
                at: at,
                spent: spent,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                Value<int?> seq = const Value.absent(),
                required String role,
                required String body,
                required DateTime at,
                Value<int> spent = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChatMessagesCompanion.insert(
                id: id,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                dirty: dirty,
                seq: seq,
                role: role,
                body: body,
                at: at,
                spent: spent,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ChatMessagesTableProcessedTableManager =
    ProcessedTableManager<
      _$CalviDb,
      $ChatMessagesTable,
      ChatMessage,
      $$ChatMessagesTableFilterComposer,
      $$ChatMessagesTableOrderingComposer,
      $$ChatMessagesTableAnnotationComposer,
      $$ChatMessagesTableCreateCompanionBuilder,
      $$ChatMessagesTableUpdateCompanionBuilder,
      (ChatMessage, BaseReferences<_$CalviDb, $ChatMessagesTable, ChatMessage>),
      ChatMessage,
      PrefetchHooks Function()
    >;
typedef $$TokenStateTableCreateCompanionBuilder =
    TokenStateCompanion Function({
      Value<int> id,
      Value<int> balance,
      Value<DateTime?> nextGrantAt,
      Value<DateTime?> syncedAt,
    });
typedef $$TokenStateTableUpdateCompanionBuilder =
    TokenStateCompanion Function({
      Value<int> id,
      Value<int> balance,
      Value<DateTime?> nextGrantAt,
      Value<DateTime?> syncedAt,
    });

class $$TokenStateTableFilterComposer extends Composer<_$CalviDb, $TokenStateTable> {
  $$TokenStateTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get balance =>
      $composableBuilder(column: $table.balance, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get nextGrantAt =>
      $composableBuilder(column: $table.nextGrantAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => ColumnFilters(column));
}

class $$TokenStateTableOrderingComposer extends Composer<_$CalviDb, $TokenStateTable> {
  $$TokenStateTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get balance =>
      $composableBuilder(column: $table.balance, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get nextGrantAt =>
      $composableBuilder(column: $table.nextGrantAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => ColumnOrderings(column));
}

class $$TokenStateTableAnnotationComposer extends Composer<_$CalviDb, $TokenStateTable> {
  $$TokenStateTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get balance =>
      $composableBuilder(column: $table.balance, builder: (column) => column);

  GeneratedColumn<DateTime> get nextGrantAt =>
      $composableBuilder(column: $table.nextGrantAt, builder: (column) => column);

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $$TokenStateTableTableManager
    extends
        RootTableManager<
          _$CalviDb,
          $TokenStateTable,
          TokenStateData,
          $$TokenStateTableFilterComposer,
          $$TokenStateTableOrderingComposer,
          $$TokenStateTableAnnotationComposer,
          $$TokenStateTableCreateCompanionBuilder,
          $$TokenStateTableUpdateCompanionBuilder,
          (TokenStateData, BaseReferences<_$CalviDb, $TokenStateTable, TokenStateData>),
          TokenStateData,
          PrefetchHooks Function()
        > {
  $$TokenStateTableTableManager(_$CalviDb db, $TokenStateTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$TokenStateTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$TokenStateTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TokenStateTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> balance = const Value.absent(),
                Value<DateTime?> nextGrantAt = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
              }) => TokenStateCompanion(
                id: id,
                balance: balance,
                nextGrantAt: nextGrantAt,
                syncedAt: syncedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> balance = const Value.absent(),
                Value<DateTime?> nextGrantAt = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
              }) => TokenStateCompanion.insert(
                id: id,
                balance: balance,
                nextGrantAt: nextGrantAt,
                syncedAt: syncedAt,
              ),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TokenStateTableProcessedTableManager =
    ProcessedTableManager<
      _$CalviDb,
      $TokenStateTable,
      TokenStateData,
      $$TokenStateTableFilterComposer,
      $$TokenStateTableOrderingComposer,
      $$TokenStateTableAnnotationComposer,
      $$TokenStateTableCreateCompanionBuilder,
      $$TokenStateTableUpdateCompanionBuilder,
      (TokenStateData, BaseReferences<_$CalviDb, $TokenStateTable, TokenStateData>),
      TokenStateData,
      PrefetchHooks Function()
    >;
typedef $$SyncMetaTableCreateCompanionBuilder =
    SyncMetaCompanion Function({
      Value<int> id,
      Value<int> cursor,
      Value<DateTime?> lastSyncAt,
      Value<String?> userId,
      Value<String?> accessToken,
      Value<String?> refreshToken,
      Value<String?> email,
      Value<DateTime?> joinedAt,
    });
typedef $$SyncMetaTableUpdateCompanionBuilder =
    SyncMetaCompanion Function({
      Value<int> id,
      Value<int> cursor,
      Value<DateTime?> lastSyncAt,
      Value<String?> userId,
      Value<String?> accessToken,
      Value<String?> refreshToken,
      Value<String?> email,
      Value<DateTime?> joinedAt,
    });

class $$SyncMetaTableFilterComposer extends Composer<_$CalviDb, $SyncMetaTable> {
  $$SyncMetaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get cursor =>
      $composableBuilder(column: $table.cursor, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSyncAt =>
      $composableBuilder(column: $table.lastSyncAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get accessToken =>
      $composableBuilder(column: $table.accessToken, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get refreshToken =>
      $composableBuilder(column: $table.refreshToken, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get joinedAt =>
      $composableBuilder(column: $table.joinedAt, builder: (column) => ColumnFilters(column));
}

class $$SyncMetaTableOrderingComposer extends Composer<_$CalviDb, $SyncMetaTable> {
  $$SyncMetaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get cursor =>
      $composableBuilder(column: $table.cursor, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSyncAt =>
      $composableBuilder(column: $table.lastSyncAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get accessToken =>
      $composableBuilder(column: $table.accessToken, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get refreshToken =>
      $composableBuilder(column: $table.refreshToken, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get joinedAt =>
      $composableBuilder(column: $table.joinedAt, builder: (column) => ColumnOrderings(column));
}

class $$SyncMetaTableAnnotationComposer extends Composer<_$CalviDb, $SyncMetaTable> {
  $$SyncMetaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id => $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get cursor =>
      $composableBuilder(column: $table.cursor, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncAt =>
      $composableBuilder(column: $table.lastSyncAt, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get accessToken =>
      $composableBuilder(column: $table.accessToken, builder: (column) => column);

  GeneratedColumn<String> get refreshToken =>
      $composableBuilder(column: $table.refreshToken, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<DateTime> get joinedAt =>
      $composableBuilder(column: $table.joinedAt, builder: (column) => column);
}

class $$SyncMetaTableTableManager
    extends
        RootTableManager<
          _$CalviDb,
          $SyncMetaTable,
          SyncMetaData,
          $$SyncMetaTableFilterComposer,
          $$SyncMetaTableOrderingComposer,
          $$SyncMetaTableAnnotationComposer,
          $$SyncMetaTableCreateCompanionBuilder,
          $$SyncMetaTableUpdateCompanionBuilder,
          (SyncMetaData, BaseReferences<_$CalviDb, $SyncMetaTable, SyncMetaData>),
          SyncMetaData,
          PrefetchHooks Function()
        > {
  $$SyncMetaTableTableManager(_$CalviDb db, $SyncMetaTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$SyncMetaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$SyncMetaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncMetaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> cursor = const Value.absent(),
                Value<DateTime?> lastSyncAt = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<String?> accessToken = const Value.absent(),
                Value<String?> refreshToken = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<DateTime?> joinedAt = const Value.absent(),
              }) => SyncMetaCompanion(
                id: id,
                cursor: cursor,
                lastSyncAt: lastSyncAt,
                userId: userId,
                accessToken: accessToken,
                refreshToken: refreshToken,
                email: email,
                joinedAt: joinedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> cursor = const Value.absent(),
                Value<DateTime?> lastSyncAt = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<String?> accessToken = const Value.absent(),
                Value<String?> refreshToken = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<DateTime?> joinedAt = const Value.absent(),
              }) => SyncMetaCompanion.insert(
                id: id,
                cursor: cursor,
                lastSyncAt: lastSyncAt,
                userId: userId,
                accessToken: accessToken,
                refreshToken: refreshToken,
                email: email,
                joinedAt: joinedAt,
              ),
          withReferenceMapper: (p0) =>
              p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncMetaTableProcessedTableManager =
    ProcessedTableManager<
      _$CalviDb,
      $SyncMetaTable,
      SyncMetaData,
      $$SyncMetaTableFilterComposer,
      $$SyncMetaTableOrderingComposer,
      $$SyncMetaTableAnnotationComposer,
      $$SyncMetaTableCreateCompanionBuilder,
      $$SyncMetaTableUpdateCompanionBuilder,
      (SyncMetaData, BaseReferences<_$CalviDb, $SyncMetaTable, SyncMetaData>),
      SyncMetaData,
      PrefetchHooks Function()
    >;

class $CalviDbManager {
  final _$CalviDb _db;
  $CalviDbManager(this._db);
  $$MealsTableTableManager get meals => $$MealsTableTableManager(_db, _db.meals);
  $$WaterLogsTableTableManager get waterLogs => $$WaterLogsTableTableManager(_db, _db.waterLogs);
  $$WeightsTableTableManager get weights => $$WeightsTableTableManager(_db, _db.weights);
  $$MeasurementsTableTableManager get measurements =>
      $$MeasurementsTableTableManager(_db, _db.measurements);
  $$WorkoutsTableTableManager get workouts => $$WorkoutsTableTableManager(_db, _db.workouts);
  $$MedicationsTableTableManager get medications =>
      $$MedicationsTableTableManager(_db, _db.medications);
  $$MedicationTakesTableTableManager get medicationTakes =>
      $$MedicationTakesTableTableManager(_db, _db.medicationTakes);
  $$AllergiesTableTableManager get allergies => $$AllergiesTableTableManager(_db, _db.allergies);
  $$ProfileTableTableManager get profile => $$ProfileTableTableManager(_db, _db.profile);
  $$ChatMessagesTableTableManager get chatMessages =>
      $$ChatMessagesTableTableManager(_db, _db.chatMessages);
  $$TokenStateTableTableManager get tokenState =>
      $$TokenStateTableTableManager(_db, _db.tokenState);
  $$SyncMetaTableTableManager get syncMeta => $$SyncMetaTableTableManager(_db, _db.syncMeta);
}
