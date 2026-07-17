import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart'
    as sqlite3_flutter_libs;

part 'app_database.g.dart';

/// Receipts table. Any column holding user-sensitive free text
/// (`vendorEncrypted`, `rawOcrTextEncrypted`) stores AES-256-GCM
/// ciphertext produced by [FieldCipher] - never plaintext - so the values
/// in the underlying `.sqlite` file are opaque even if the file itself is
/// extracted from the device.
///
/// Named `ReceiptRow` (via `@DataClassName`) so drift's generated row
/// class doesn't collide with the domain-layer `Receipt` entity - they
/// intentionally live in separate layers (see [DriftReceiptRepository],
/// which maps between the two).
@DataClassName('ReceiptRow')
class Receipts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get vendorEncrypted => text()();
  DateTimeColumn get purchasedAt => dateTime()();
  IntColumn get subtotalCents => integer()();
  IntColumn get taxCents => integer()();
  IntColumn get totalCents => integer()();
  TextColumn get rawOcrTextEncrypted => text()();
  TextColumn get imagePath => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}

@DataClassName('LineItemRow')
class LineItems extends Table {
  IntColumn get id => integer().autoIncrement()();

  // Expressed as an explicit `customConstraint` (rather than
  // `.references()`) so the exact `REFERENCES ... ON DELETE CASCADE` SQL
  // is guaranteed to land in the generated `CREATE TABLE` statement -
  // verified against the real generated schema in
  // test/data/repositories/drift_receipt_repository_test.dart, which
  // asserts that deleting a receipt cascades to its line items.
  IntColumn get receiptId => integer().customConstraint(
    'NOT NULL REFERENCES receipts(id) ON DELETE CASCADE',
  )();

  TextColumn get descriptionEncrypted => text()();
  IntColumn get amountCents => integer()();
  TextColumn get categoryId => text()();
  RealColumn get confidence => real().withDefault(const Constant(1.0))();
}

@DriftDatabase(tables: [Receipts, LineItems])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  /// Production constructor: a real on-disk SQLite file in the app's
  /// documents directory. No network path exists anywhere in this class.
  factory AppDatabase.open() {
    return AppDatabase(_openConnection());
  }

  /// Test/dev constructor: a private in-memory SQLite database. No file
  /// system or platform channel access required, so it runs anywhere
  /// `flutter test` runs.
  factory AppDatabase.inMemory() {
    return AppDatabase(NativeDatabase.memory());
  }

  @override
  int get schemaVersion => 1;

  // SQLite has foreign-key enforcement OFF by default on every new
  // connection (including in-memory ones) unless explicitly turned on -
  // without this, `onDelete: KeyAction.cascade` on `LineItems.receiptId`
  // is silently a no-op and deleting a receipt orphans its line items.
  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  static QueryExecutor _openConnection() {
    return LazyDatabase(() async {
      // Ensures the native sqlite3 dynamic library is available before
      // opening the file-backed database on Android/iOS.
      sqlite3_flutter_libs.applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'receiptlens.sqlite'));
      return NativeDatabase.createInBackground(file);
    });
  }
}
