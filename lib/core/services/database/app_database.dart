import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_database.g.dart';

@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  final db = AppDatabase();
  return db;
}

/// Transactions table for offline storage and atomicity
class Transactions extends Table {
  TextColumn get id => text()(); // Primary Key (Unique ID)
  TextColumn get title => text()();
  TextColumn get subtitle => text()();
  RealColumn get amount => real()();
  RealColumn get fee => real().withDefault(const Constant(0.0))();
  RealColumn get tax => real().withDefault(const Constant(0.0))();
  IntColumn get iconCode => integer()();
  IntColumn get colorValue => integer()();
  TextColumn get category => text().withDefault(const Constant('Other'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get metadata =>
      text().nullable()(); // JSON string for additional data

  @override
  Set<Column> get primaryKey => {id};
}

/// Key-Value store to replace SharedPreferences
class AppPreferences extends Table {
  TextColumn get key => text()();
  TextColumn get value => text().nullable()();

  @override
  Set<Column> get primaryKey => {key};
}

/// Notification history table
class DbNotifications extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get body => text()();
  DateTimeColumn get receivedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isRead => boolean().withDefault(const Constant(false))();
}

@DriftDatabase(tables: [Transactions, AppPreferences, DbNotifications])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      // Logic for migration between versions will go here
      if (from < 2) {
        // Example: await m.addColumn(notifications, notifications.isRead);
      }
    },
    beforeOpen: (details) async {
      // Enable foreign keys
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  // --- CRUD Operations for Transactions ---

  /// Records a transaction atomically
  Future<void> recordTransaction(TransactionsCompanion entry) async {
    await transaction(() async {
      await into(transactions).insert(entry);
    });
  }

  Future<List<Transaction>> getAllTransactions() => select(transactions).get();

  Stream<List<Transaction>> watchAllTransactions() =>
      (select(transactions)..orderBy([
            (t) =>
                OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
          ]))
          .watch();

  // --- CRUD Operations for Preferences ---

  Future<void> setPreference(String key, String? value) async {
    await into(appPreferences).insertOnConflictUpdate(
      AppPreferencesCompanion(key: Value(key), value: Value(value)),
    );
  }

  Future<String?> getPreference(String key) async {
    final query = select(appPreferences)..where((t) => t.key.equals(key));
    final result = await query.getSingleOrNull();
    return result?.value;
  }

  // --- CRUD Operations for Notifications ---

  Future<void> insertNotification(DbNotificationsCompanion entry) =>
      into(dbNotifications).insert(entry);

  Stream<List<DbNotification>> watchNotifications() =>
      (select(dbNotifications)..orderBy([
            (t) =>
                OrderingTerm(expression: t.receivedAt, mode: OrderingMode.desc),
          ]))
          .watch();

  Future<void> markNotificationAsRead(int id) {
    return (update(dbNotifications)..where((t) => t.id.equals(id))).write(
      const DbNotificationsCompanion(isRead: Value(true)),
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'neru_wallet.sqlite'));
    return NativeDatabase(file);
  });
}
