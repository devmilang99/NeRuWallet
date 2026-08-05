import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_database.g.dart';

@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  final db = ref.watch(_appDatabaseInstanceProvider);
  return db;
}

final _appDatabaseInstanceProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

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

  TextColumn get transactionType => text().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  TextColumn get metadata =>
      text().nullable()(); // JSON string for additional data

  TextColumn get groupId => text().nullable()(); // Multi-Sig Group ID

  TextColumn get status => text().withDefault(
    const Constant('completed'),
  )(); // pending, signed, failed, completed

  @override
  Set<Column> get primaryKey => {id};
}

/// Multi-Sig Groups table
class MultiSigGroups extends Table {
  TextColumn get id => text()();

  TextColumn get name => text()();

  TextColumn get creatorId => text()();

  IntColumn get threshold => integer()(); // M in M-of-N
  IntColumn get totalMembers => integer()(); // N in M-of-N
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Members of a Multi-Sig Group
class MultiSigMembers extends Table {
  TextColumn get groupId => text().references(MultiSigGroups, #id)();

  TextColumn get userId => text()();

  TextColumn get publicKey => text()(); // Device public key for verification

  @override
  Set<Column> get primaryKey => {groupId, userId};
}

/// Pending signatures for Multi-Sig transactions
class PendingSignatures extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get transactionId => text().references(Transactions, #id)();

  TextColumn get signerId => text()();

  TextColumn get signature => text()();

  DateTimeColumn get signedAt => dateTime().withDefault(currentDateAndTime)();
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

/// AI Memory and Chat history
class AiMemories extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get role => text()(); // 'user' or 'model'
  TextColumn get content => text()(); // Message or JSON string
  TextColumn get type =>
      text().withDefault(const Constant('text'))(); // 'text' or 'json'
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(
  tables: [
    Transactions,
    AppPreferences,
    DbNotifications,
    AiMemories,
    MultiSigGroups,
    MultiSigMembers,
    PendingSignatures,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(aiMemories);
      }
      if (from < 3) {
        await m.issueCustomQuery(
          'ALTER TABLE transactions ADD COLUMN transaction_type TEXT',
        );
      }
      if (from < 4) {
        await m.createTable(multiSigGroups);
        await m.createTable(multiSigMembers);
        await m.createTable(pendingSignatures);
        await m.issueCustomQuery(
          'ALTER TABLE transactions ADD COLUMN group_id TEXT',
        );
        await m.issueCustomQuery(
          "ALTER TABLE transactions ADD COLUMN status TEXT DEFAULT 'completed'",
        );
      }
    },
    beforeOpen: (details) async {
      // Enable foreign keys
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  // --- CRUD Operations for Transactions ---

  /// Records a transaction atomically
  Future<Transaction> recordTransaction(TransactionsCompanion entry) async {
    return transaction(() async {
      return into(transactions).insertReturning(entry);
    });
  }

  Future<List<Transaction>> getAllTransactions() =>
      (select(transactions)..orderBy([
            (t) =>
                OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
          ]))
          .get();

  Future<List<Transaction>> getTransactionsByType(String type) =>
      (select(transactions)
            ..where((t) => t.transactionType.equals(type))
            ..orderBy([
              (t) => OrderingTerm(
                expression: t.createdAt,
                mode: OrderingMode.desc,
              ),
            ]))
          .get();

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

  Stream<String?> watchPreference(String key) {
    return (select(appPreferences)..where((t) => t.key.equals(key)))
        .watchSingleOrNull()
        .map((row) => row?.value);
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

  // --- CRUD Operations for AI Memories ---

  Future<int> saveAiMemory(AiMemoriesCompanion entry) =>
      into(aiMemories).insert(entry);

  Future<List<AiMemory>> getAiMemories({int limit = 50}) =>
      (select(aiMemories)
            ..orderBy([
              (t) => OrderingTerm(
                expression: t.createdAt,
                mode: OrderingMode.desc,
              ),
            ])
            ..limit(limit))
          .get();

  Future<void> clearAiMemories() => delete(aiMemories).go();
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'neru_wallet.sqlite'));
    return NativeDatabase(file);
  });
}
