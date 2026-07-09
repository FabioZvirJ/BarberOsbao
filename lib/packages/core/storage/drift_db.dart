import 'package:drift/drift.dart';
import 'package:barber_osbao/packages/core/storage/connection.dart' as impl;

part 'drift_db.g.dart';

class CachedAppointments extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get barberId => text()();
  TextColumn get barberName => text()();
  TextColumn get barberAvatar => text()();
  TextColumn get date => text()();
  TextColumn get time => text()();
  RealColumn get totalValue => real()();
  TextColumn get status => text()();
  TextColumn get servicesJson => text()(); // Stringified JSON array
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class CachedNotifications extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get title => text()();
  TextColumn get message => text()();
  TextColumn get type => text()();
  BoolColumn get read => boolean()();
  TextColumn get createdAt => text()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [CachedAppointments, CachedNotifications])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(impl.connect());

  @override
  int get schemaVersion => 1;
}

