import 'package:drift/drift.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:drift/native.dart';

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
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
