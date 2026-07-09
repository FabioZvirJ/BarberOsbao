// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drift_db.dart';

// ignore_for_file: type=lint
class $CachedAppointmentsTable extends CachedAppointments
    with TableInfo<$CachedAppointmentsTable, CachedAppointment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedAppointmentsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _barberIdMeta = const VerificationMeta(
    'barberId',
  );
  @override
  late final GeneratedColumn<String> barberId = GeneratedColumn<String>(
    'barber_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _barberNameMeta = const VerificationMeta(
    'barberName',
  );
  @override
  late final GeneratedColumn<String> barberName = GeneratedColumn<String>(
    'barber_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _barberAvatarMeta = const VerificationMeta(
    'barberAvatar',
  );
  @override
  late final GeneratedColumn<String> barberAvatar = GeneratedColumn<String>(
    'barber_avatar',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timeMeta = const VerificationMeta('time');
  @override
  late final GeneratedColumn<String> time = GeneratedColumn<String>(
    'time',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalValueMeta = const VerificationMeta(
    'totalValue',
  );
  @override
  late final GeneratedColumn<double> totalValue = GeneratedColumn<double>(
    'total_value',
    aliasedName,
    false,
    type: DriftSqlType.double,
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
  static const VerificationMeta _servicesJsonMeta = const VerificationMeta(
    'servicesJson',
  );
  @override
  late final GeneratedColumn<String> servicesJson = GeneratedColumn<String>(
    'services_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    barberId,
    barberName,
    barberAvatar,
    date,
    time,
    totalValue,
    status,
    servicesJson,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_appointments';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedAppointment> instance, {
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
    if (data.containsKey('barber_id')) {
      context.handle(
        _barberIdMeta,
        barberId.isAcceptableOrUnknown(data['barber_id']!, _barberIdMeta),
      );
    } else if (isInserting) {
      context.missing(_barberIdMeta);
    }
    if (data.containsKey('barber_name')) {
      context.handle(
        _barberNameMeta,
        barberName.isAcceptableOrUnknown(data['barber_name']!, _barberNameMeta),
      );
    } else if (isInserting) {
      context.missing(_barberNameMeta);
    }
    if (data.containsKey('barber_avatar')) {
      context.handle(
        _barberAvatarMeta,
        barberAvatar.isAcceptableOrUnknown(
          data['barber_avatar']!,
          _barberAvatarMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_barberAvatarMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('time')) {
      context.handle(
        _timeMeta,
        time.isAcceptableOrUnknown(data['time']!, _timeMeta),
      );
    } else if (isInserting) {
      context.missing(_timeMeta);
    }
    if (data.containsKey('total_value')) {
      context.handle(
        _totalValueMeta,
        totalValue.isAcceptableOrUnknown(data['total_value']!, _totalValueMeta),
      );
    } else if (isInserting) {
      context.missing(_totalValueMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('services_json')) {
      context.handle(
        _servicesJsonMeta,
        servicesJson.isAcceptableOrUnknown(
          data['services_json']!,
          _servicesJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_servicesJsonMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedAppointment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedAppointment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      barberId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}barber_id'],
      )!,
      barberName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}barber_name'],
      )!,
      barberAvatar: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}barber_avatar'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      time: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}time'],
      )!,
      totalValue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_value'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      servicesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}services_json'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $CachedAppointmentsTable createAlias(String alias) {
    return $CachedAppointmentsTable(attachedDatabase, alias);
  }
}

class CachedAppointment extends DataClass
    implements Insertable<CachedAppointment> {
  final String id;
  final String userId;
  final String barberId;
  final String barberName;
  final String barberAvatar;
  final String date;
  final String time;
  final double totalValue;
  final String status;
  final String servicesJson;
  final String? notes;
  const CachedAppointment({
    required this.id,
    required this.userId,
    required this.barberId,
    required this.barberName,
    required this.barberAvatar,
    required this.date,
    required this.time,
    required this.totalValue,
    required this.status,
    required this.servicesJson,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['barber_id'] = Variable<String>(barberId);
    map['barber_name'] = Variable<String>(barberName);
    map['barber_avatar'] = Variable<String>(barberAvatar);
    map['date'] = Variable<String>(date);
    map['time'] = Variable<String>(time);
    map['total_value'] = Variable<double>(totalValue);
    map['status'] = Variable<String>(status);
    map['services_json'] = Variable<String>(servicesJson);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  CachedAppointmentsCompanion toCompanion(bool nullToAbsent) {
    return CachedAppointmentsCompanion(
      id: Value(id),
      userId: Value(userId),
      barberId: Value(barberId),
      barberName: Value(barberName),
      barberAvatar: Value(barberAvatar),
      date: Value(date),
      time: Value(time),
      totalValue: Value(totalValue),
      status: Value(status),
      servicesJson: Value(servicesJson),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory CachedAppointment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedAppointment(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      barberId: serializer.fromJson<String>(json['barberId']),
      barberName: serializer.fromJson<String>(json['barberName']),
      barberAvatar: serializer.fromJson<String>(json['barberAvatar']),
      date: serializer.fromJson<String>(json['date']),
      time: serializer.fromJson<String>(json['time']),
      totalValue: serializer.fromJson<double>(json['totalValue']),
      status: serializer.fromJson<String>(json['status']),
      servicesJson: serializer.fromJson<String>(json['servicesJson']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'barberId': serializer.toJson<String>(barberId),
      'barberName': serializer.toJson<String>(barberName),
      'barberAvatar': serializer.toJson<String>(barberAvatar),
      'date': serializer.toJson<String>(date),
      'time': serializer.toJson<String>(time),
      'totalValue': serializer.toJson<double>(totalValue),
      'status': serializer.toJson<String>(status),
      'servicesJson': serializer.toJson<String>(servicesJson),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  CachedAppointment copyWith({
    String? id,
    String? userId,
    String? barberId,
    String? barberName,
    String? barberAvatar,
    String? date,
    String? time,
    double? totalValue,
    String? status,
    String? servicesJson,
    Value<String?> notes = const Value.absent(),
  }) => CachedAppointment(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    barberId: barberId ?? this.barberId,
    barberName: barberName ?? this.barberName,
    barberAvatar: barberAvatar ?? this.barberAvatar,
    date: date ?? this.date,
    time: time ?? this.time,
    totalValue: totalValue ?? this.totalValue,
    status: status ?? this.status,
    servicesJson: servicesJson ?? this.servicesJson,
    notes: notes.present ? notes.value : this.notes,
  );
  CachedAppointment copyWithCompanion(CachedAppointmentsCompanion data) {
    return CachedAppointment(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      barberId: data.barberId.present ? data.barberId.value : this.barberId,
      barberName: data.barberName.present
          ? data.barberName.value
          : this.barberName,
      barberAvatar: data.barberAvatar.present
          ? data.barberAvatar.value
          : this.barberAvatar,
      date: data.date.present ? data.date.value : this.date,
      time: data.time.present ? data.time.value : this.time,
      totalValue: data.totalValue.present
          ? data.totalValue.value
          : this.totalValue,
      status: data.status.present ? data.status.value : this.status,
      servicesJson: data.servicesJson.present
          ? data.servicesJson.value
          : this.servicesJson,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedAppointment(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('barberId: $barberId, ')
          ..write('barberName: $barberName, ')
          ..write('barberAvatar: $barberAvatar, ')
          ..write('date: $date, ')
          ..write('time: $time, ')
          ..write('totalValue: $totalValue, ')
          ..write('status: $status, ')
          ..write('servicesJson: $servicesJson, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    barberId,
    barberName,
    barberAvatar,
    date,
    time,
    totalValue,
    status,
    servicesJson,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedAppointment &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.barberId == this.barberId &&
          other.barberName == this.barberName &&
          other.barberAvatar == this.barberAvatar &&
          other.date == this.date &&
          other.time == this.time &&
          other.totalValue == this.totalValue &&
          other.status == this.status &&
          other.servicesJson == this.servicesJson &&
          other.notes == this.notes);
}

class CachedAppointmentsCompanion extends UpdateCompanion<CachedAppointment> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> barberId;
  final Value<String> barberName;
  final Value<String> barberAvatar;
  final Value<String> date;
  final Value<String> time;
  final Value<double> totalValue;
  final Value<String> status;
  final Value<String> servicesJson;
  final Value<String?> notes;
  final Value<int> rowid;
  const CachedAppointmentsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.barberId = const Value.absent(),
    this.barberName = const Value.absent(),
    this.barberAvatar = const Value.absent(),
    this.date = const Value.absent(),
    this.time = const Value.absent(),
    this.totalValue = const Value.absent(),
    this.status = const Value.absent(),
    this.servicesJson = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedAppointmentsCompanion.insert({
    required String id,
    required String userId,
    required String barberId,
    required String barberName,
    required String barberAvatar,
    required String date,
    required String time,
    required double totalValue,
    required String status,
    required String servicesJson,
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       barberId = Value(barberId),
       barberName = Value(barberName),
       barberAvatar = Value(barberAvatar),
       date = Value(date),
       time = Value(time),
       totalValue = Value(totalValue),
       status = Value(status),
       servicesJson = Value(servicesJson);
  static Insertable<CachedAppointment> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? barberId,
    Expression<String>? barberName,
    Expression<String>? barberAvatar,
    Expression<String>? date,
    Expression<String>? time,
    Expression<double>? totalValue,
    Expression<String>? status,
    Expression<String>? servicesJson,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (barberId != null) 'barber_id': barberId,
      if (barberName != null) 'barber_name': barberName,
      if (barberAvatar != null) 'barber_avatar': barberAvatar,
      if (date != null) 'date': date,
      if (time != null) 'time': time,
      if (totalValue != null) 'total_value': totalValue,
      if (status != null) 'status': status,
      if (servicesJson != null) 'services_json': servicesJson,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedAppointmentsCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? barberId,
    Value<String>? barberName,
    Value<String>? barberAvatar,
    Value<String>? date,
    Value<String>? time,
    Value<double>? totalValue,
    Value<String>? status,
    Value<String>? servicesJson,
    Value<String?>? notes,
    Value<int>? rowid,
  }) {
    return CachedAppointmentsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      barberId: barberId ?? this.barberId,
      barberName: barberName ?? this.barberName,
      barberAvatar: barberAvatar ?? this.barberAvatar,
      date: date ?? this.date,
      time: time ?? this.time,
      totalValue: totalValue ?? this.totalValue,
      status: status ?? this.status,
      servicesJson: servicesJson ?? this.servicesJson,
      notes: notes ?? this.notes,
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
    if (barberId.present) {
      map['barber_id'] = Variable<String>(barberId.value);
    }
    if (barberName.present) {
      map['barber_name'] = Variable<String>(barberName.value);
    }
    if (barberAvatar.present) {
      map['barber_avatar'] = Variable<String>(barberAvatar.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (time.present) {
      map['time'] = Variable<String>(time.value);
    }
    if (totalValue.present) {
      map['total_value'] = Variable<double>(totalValue.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (servicesJson.present) {
      map['services_json'] = Variable<String>(servicesJson.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedAppointmentsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('barberId: $barberId, ')
          ..write('barberName: $barberName, ')
          ..write('barberAvatar: $barberAvatar, ')
          ..write('date: $date, ')
          ..write('time: $time, ')
          ..write('totalValue: $totalValue, ')
          ..write('status: $status, ')
          ..write('servicesJson: $servicesJson, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedNotificationsTable extends CachedNotifications
    with TableInfo<$CachedNotificationsTable, CachedNotification> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedNotificationsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _messageMeta = const VerificationMeta(
    'message',
  );
  @override
  late final GeneratedColumn<String> message = GeneratedColumn<String>(
    'message',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _readMeta = const VerificationMeta('read');
  @override
  late final GeneratedColumn<bool> read = GeneratedColumn<bool>(
    'read',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("read" IN (0, 1))',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    title,
    message,
    type,
    read,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_notifications';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedNotification> instance, {
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
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('message')) {
      context.handle(
        _messageMeta,
        message.isAcceptableOrUnknown(data['message']!, _messageMeta),
      );
    } else if (isInserting) {
      context.missing(_messageMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('read')) {
      context.handle(
        _readMeta,
        read.isAcceptableOrUnknown(data['read']!, _readMeta),
      );
    } else if (isInserting) {
      context.missing(_readMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedNotification map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedNotification(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      message: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      read: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}read'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CachedNotificationsTable createAlias(String alias) {
    return $CachedNotificationsTable(attachedDatabase, alias);
  }
}

class CachedNotification extends DataClass
    implements Insertable<CachedNotification> {
  final String id;
  final String userId;
  final String title;
  final String message;
  final String type;
  final bool read;
  final String createdAt;
  const CachedNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    required this.read,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['title'] = Variable<String>(title);
    map['message'] = Variable<String>(message);
    map['type'] = Variable<String>(type);
    map['read'] = Variable<bool>(read);
    map['created_at'] = Variable<String>(createdAt);
    return map;
  }

  CachedNotificationsCompanion toCompanion(bool nullToAbsent) {
    return CachedNotificationsCompanion(
      id: Value(id),
      userId: Value(userId),
      title: Value(title),
      message: Value(message),
      type: Value(type),
      read: Value(read),
      createdAt: Value(createdAt),
    );
  }

  factory CachedNotification.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedNotification(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      title: serializer.fromJson<String>(json['title']),
      message: serializer.fromJson<String>(json['message']),
      type: serializer.fromJson<String>(json['type']),
      read: serializer.fromJson<bool>(json['read']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'title': serializer.toJson<String>(title),
      'message': serializer.toJson<String>(message),
      'type': serializer.toJson<String>(type),
      'read': serializer.toJson<bool>(read),
      'createdAt': serializer.toJson<String>(createdAt),
    };
  }

  CachedNotification copyWith({
    String? id,
    String? userId,
    String? title,
    String? message,
    String? type,
    bool? read,
    String? createdAt,
  }) => CachedNotification(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    title: title ?? this.title,
    message: message ?? this.message,
    type: type ?? this.type,
    read: read ?? this.read,
    createdAt: createdAt ?? this.createdAt,
  );
  CachedNotification copyWithCompanion(CachedNotificationsCompanion data) {
    return CachedNotification(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      title: data.title.present ? data.title.value : this.title,
      message: data.message.present ? data.message.value : this.message,
      type: data.type.present ? data.type.value : this.type,
      read: data.read.present ? data.read.value : this.read,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedNotification(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('title: $title, ')
          ..write('message: $message, ')
          ..write('type: $type, ')
          ..write('read: $read, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, userId, title, message, type, read, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedNotification &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.title == this.title &&
          other.message == this.message &&
          other.type == this.type &&
          other.read == this.read &&
          other.createdAt == this.createdAt);
}

class CachedNotificationsCompanion extends UpdateCompanion<CachedNotification> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> title;
  final Value<String> message;
  final Value<String> type;
  final Value<bool> read;
  final Value<String> createdAt;
  final Value<int> rowid;
  const CachedNotificationsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.title = const Value.absent(),
    this.message = const Value.absent(),
    this.type = const Value.absent(),
    this.read = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedNotificationsCompanion.insert({
    required String id,
    required String userId,
    required String title,
    required String message,
    required String type,
    required bool read,
    required String createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       title = Value(title),
       message = Value(message),
       type = Value(type),
       read = Value(read),
       createdAt = Value(createdAt);
  static Insertable<CachedNotification> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? title,
    Expression<String>? message,
    Expression<String>? type,
    Expression<bool>? read,
    Expression<String>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (title != null) 'title': title,
      if (message != null) 'message': message,
      if (type != null) 'type': type,
      if (read != null) 'read': read,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedNotificationsCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? title,
    Value<String>? message,
    Value<String>? type,
    Value<bool>? read,
    Value<String>? createdAt,
    Value<int>? rowid,
  }) {
    return CachedNotificationsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      read: read ?? this.read,
      createdAt: createdAt ?? this.createdAt,
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
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (message.present) {
      map['message'] = Variable<String>(message.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (read.present) {
      map['read'] = Variable<bool>(read.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedNotificationsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('title: $title, ')
          ..write('message: $message, ')
          ..write('type: $type, ')
          ..write('read: $read, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CachedAppointmentsTable cachedAppointments =
      $CachedAppointmentsTable(this);
  late final $CachedNotificationsTable cachedNotifications =
      $CachedNotificationsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    cachedAppointments,
    cachedNotifications,
  ];
}

typedef $$CachedAppointmentsTableCreateCompanionBuilder =
    CachedAppointmentsCompanion Function({
      required String id,
      required String userId,
      required String barberId,
      required String barberName,
      required String barberAvatar,
      required String date,
      required String time,
      required double totalValue,
      required String status,
      required String servicesJson,
      Value<String?> notes,
      Value<int> rowid,
    });
typedef $$CachedAppointmentsTableUpdateCompanionBuilder =
    CachedAppointmentsCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> barberId,
      Value<String> barberName,
      Value<String> barberAvatar,
      Value<String> date,
      Value<String> time,
      Value<double> totalValue,
      Value<String> status,
      Value<String> servicesJson,
      Value<String?> notes,
      Value<int> rowid,
    });

class $$CachedAppointmentsTableFilterComposer
    extends Composer<_$AppDatabase, $CachedAppointmentsTable> {
  $$CachedAppointmentsTableFilterComposer({
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

  ColumnFilters<String> get barberId => $composableBuilder(
    column: $table.barberId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get barberName => $composableBuilder(
    column: $table.barberName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get barberAvatar => $composableBuilder(
    column: $table.barberAvatar,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get time => $composableBuilder(
    column: $table.time,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalValue => $composableBuilder(
    column: $table.totalValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get servicesJson => $composableBuilder(
    column: $table.servicesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedAppointmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedAppointmentsTable> {
  $$CachedAppointmentsTableOrderingComposer({
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

  ColumnOrderings<String> get barberId => $composableBuilder(
    column: $table.barberId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get barberName => $composableBuilder(
    column: $table.barberName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get barberAvatar => $composableBuilder(
    column: $table.barberAvatar,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get time => $composableBuilder(
    column: $table.time,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalValue => $composableBuilder(
    column: $table.totalValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get servicesJson => $composableBuilder(
    column: $table.servicesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedAppointmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedAppointmentsTable> {
  $$CachedAppointmentsTableAnnotationComposer({
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

  GeneratedColumn<String> get barberId =>
      $composableBuilder(column: $table.barberId, builder: (column) => column);

  GeneratedColumn<String> get barberName => $composableBuilder(
    column: $table.barberName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get barberAvatar => $composableBuilder(
    column: $table.barberAvatar,
    builder: (column) => column,
  );

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get time =>
      $composableBuilder(column: $table.time, builder: (column) => column);

  GeneratedColumn<double> get totalValue => $composableBuilder(
    column: $table.totalValue,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get servicesJson => $composableBuilder(
    column: $table.servicesJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);
}

class $$CachedAppointmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedAppointmentsTable,
          CachedAppointment,
          $$CachedAppointmentsTableFilterComposer,
          $$CachedAppointmentsTableOrderingComposer,
          $$CachedAppointmentsTableAnnotationComposer,
          $$CachedAppointmentsTableCreateCompanionBuilder,
          $$CachedAppointmentsTableUpdateCompanionBuilder,
          (
            CachedAppointment,
            BaseReferences<
              _$AppDatabase,
              $CachedAppointmentsTable,
              CachedAppointment
            >,
          ),
          CachedAppointment,
          PrefetchHooks Function()
        > {
  $$CachedAppointmentsTableTableManager(
    _$AppDatabase db,
    $CachedAppointmentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedAppointmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedAppointmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedAppointmentsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> barberId = const Value.absent(),
                Value<String> barberName = const Value.absent(),
                Value<String> barberAvatar = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<String> time = const Value.absent(),
                Value<double> totalValue = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> servicesJson = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedAppointmentsCompanion(
                id: id,
                userId: userId,
                barberId: barberId,
                barberName: barberName,
                barberAvatar: barberAvatar,
                date: date,
                time: time,
                totalValue: totalValue,
                status: status,
                servicesJson: servicesJson,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String barberId,
                required String barberName,
                required String barberAvatar,
                required String date,
                required String time,
                required double totalValue,
                required String status,
                required String servicesJson,
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedAppointmentsCompanion.insert(
                id: id,
                userId: userId,
                barberId: barberId,
                barberName: barberName,
                barberAvatar: barberAvatar,
                date: date,
                time: time,
                totalValue: totalValue,
                status: status,
                servicesJson: servicesJson,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedAppointmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedAppointmentsTable,
      CachedAppointment,
      $$CachedAppointmentsTableFilterComposer,
      $$CachedAppointmentsTableOrderingComposer,
      $$CachedAppointmentsTableAnnotationComposer,
      $$CachedAppointmentsTableCreateCompanionBuilder,
      $$CachedAppointmentsTableUpdateCompanionBuilder,
      (
        CachedAppointment,
        BaseReferences<
          _$AppDatabase,
          $CachedAppointmentsTable,
          CachedAppointment
        >,
      ),
      CachedAppointment,
      PrefetchHooks Function()
    >;
typedef $$CachedNotificationsTableCreateCompanionBuilder =
    CachedNotificationsCompanion Function({
      required String id,
      required String userId,
      required String title,
      required String message,
      required String type,
      required bool read,
      required String createdAt,
      Value<int> rowid,
    });
typedef $$CachedNotificationsTableUpdateCompanionBuilder =
    CachedNotificationsCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> title,
      Value<String> message,
      Value<String> type,
      Value<bool> read,
      Value<String> createdAt,
      Value<int> rowid,
    });

class $$CachedNotificationsTableFilterComposer
    extends Composer<_$AppDatabase, $CachedNotificationsTable> {
  $$CachedNotificationsTableFilterComposer({
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

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get read => $composableBuilder(
    column: $table.read,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedNotificationsTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedNotificationsTable> {
  $$CachedNotificationsTableOrderingComposer({
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

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get read => $composableBuilder(
    column: $table.read,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedNotificationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedNotificationsTable> {
  $$CachedNotificationsTableAnnotationComposer({
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

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get message =>
      $composableBuilder(column: $table.message, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<bool> get read =>
      $composableBuilder(column: $table.read, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$CachedNotificationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedNotificationsTable,
          CachedNotification,
          $$CachedNotificationsTableFilterComposer,
          $$CachedNotificationsTableOrderingComposer,
          $$CachedNotificationsTableAnnotationComposer,
          $$CachedNotificationsTableCreateCompanionBuilder,
          $$CachedNotificationsTableUpdateCompanionBuilder,
          (
            CachedNotification,
            BaseReferences<
              _$AppDatabase,
              $CachedNotificationsTable,
              CachedNotification
            >,
          ),
          CachedNotification,
          PrefetchHooks Function()
        > {
  $$CachedNotificationsTableTableManager(
    _$AppDatabase db,
    $CachedNotificationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedNotificationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedNotificationsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CachedNotificationsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> message = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<bool> read = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedNotificationsCompanion(
                id: id,
                userId: userId,
                title: title,
                message: message,
                type: type,
                read: read,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String title,
                required String message,
                required String type,
                required bool read,
                required String createdAt,
                Value<int> rowid = const Value.absent(),
              }) => CachedNotificationsCompanion.insert(
                id: id,
                userId: userId,
                title: title,
                message: message,
                type: type,
                read: read,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedNotificationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedNotificationsTable,
      CachedNotification,
      $$CachedNotificationsTableFilterComposer,
      $$CachedNotificationsTableOrderingComposer,
      $$CachedNotificationsTableAnnotationComposer,
      $$CachedNotificationsTableCreateCompanionBuilder,
      $$CachedNotificationsTableUpdateCompanionBuilder,
      (
        CachedNotification,
        BaseReferences<
          _$AppDatabase,
          $CachedNotificationsTable,
          CachedNotification
        >,
      ),
      CachedNotification,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CachedAppointmentsTableTableManager get cachedAppointments =>
      $$CachedAppointmentsTableTableManager(_db, _db.cachedAppointments);
  $$CachedNotificationsTableTableManager get cachedNotifications =>
      $$CachedNotificationsTableTableManager(_db, _db.cachedNotifications);
}
