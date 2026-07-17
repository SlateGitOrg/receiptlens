import 'package:flutter_test/flutter_test.dart';
import 'package:receiptlens/core/money.dart';
import 'package:receiptlens/data/db/app_database.dart';
import 'package:receiptlens/data/encryption/field_cipher.dart';
import 'package:receiptlens/data/encryption/key_manager.dart';
import 'package:receiptlens/data/repositories/drift_receipt_repository.dart';
import 'package:receiptlens/domain/entities/expense_category.dart';

import '../../fixtures/receipt_fixtures.dart';

/// Every test here runs against `AppDatabase.inMemory()` - a private
/// in-memory SQLite database with no file system or platform-channel
/// dependency, so the whole suite runs offline under `flutter test`.
void main() {
  late AppDatabase db;
  late DriftReceiptRepository repo;

  setUp(() {
    db = AppDatabase.inMemory();
    repo = DriftReceiptRepository(
      db: db,
      cipher: AesGcmFieldCipher(keyManager: InMemoryKeyManager()),
    );
  });

  tearDown(() => db.close());

  test(
    'save() then getAll() round-trips a receipt with its line items',
    () async {
      final receipt = buildReceipt(
        vendor: 'Whole Foods',
        purchasedAt: DateTime(2024, 4, 2),
        lineItems: [
          buildLineItem(
            description: 'Organic bananas',
            amountCents: 249,
            category: ExpenseCategory.mealsEntertainment,
            confidence: 0.91,
          ),
        ],
      );

      final id = await repo.save(receipt);
      final all = await repo.getAll();

      expect(all, hasLength(1));
      expect(all.single.id, id);
      expect(all.single.vendor, 'Whole Foods');
      expect(all.single.lineItems.single.description, 'Organic bananas');
      expect(all.single.lineItems.single.amount.cents, 249);
      expect(
        all.single.lineItems.single.category,
        ExpenseCategory.mealsEntertainment,
      );
      expect(all.single.lineItems.single.confidence, closeTo(0.91, 1e-9));
    },
  );

  test('sensitive fields are stored encrypted, not as plaintext', () async {
    final receipt = buildReceipt(
      vendor: 'Sensitive Vendor Name',
      rawOcrText: 'Sensitive Vendor Name\nSecret item  1.00',
    );
    await repo.save(receipt);

    final rawRow = await db.select(db.receipts).getSingle();
    expect(rawRow.vendorEncrypted.contains('Sensitive Vendor Name'), isFalse);
    expect(rawRow.rawOcrTextEncrypted.contains('Secret item'), isFalse);
  });

  test('getById returns null for a non-existent id', () async {
    expect(await repo.getById(9999), isNull);
  });

  test('getById returns the matching receipt', () async {
    final id = await repo.save(buildReceipt(vendor: 'Target'));
    final fetched = await repo.getById(id);
    expect(fetched?.vendor, 'Target');
  });

  test(
    'saving with an existing id updates in place and replaces line items',
    () async {
      final id = await repo.save(
        buildReceipt(
          vendor: 'Store A',
          lineItems: [buildLineItem(description: 'Old item', amountCents: 100)],
        ),
      );

      final updated = (await repo.getById(id))!.copyWith(
        vendor: 'Store A (corrected)',
        lineItems: [buildLineItem(description: 'New item', amountCents: 250)],
      );
      await repo.save(updated);

      final all = await repo.getAll();
      expect(all, hasLength(1));
      expect(all.single.vendor, 'Store A (corrected)');
      expect(all.single.lineItems, hasLength(1));
      expect(all.single.lineItems.single.description, 'New item');
    },
  );

  test('getForMonth filters receipts to the given year/month', () async {
    await repo.save(
      buildReceipt(vendor: 'Jan', purchasedAt: DateTime(2024, 1, 10)),
    );
    await repo.save(
      buildReceipt(vendor: 'Mar1', purchasedAt: DateTime(2024, 3, 1)),
    );
    await repo.save(
      buildReceipt(vendor: 'Mar2', purchasedAt: DateTime(2024, 3, 20)),
    );

    final march = await repo.getForMonth(2024, 3);
    expect(march.map((r) => r.vendor).toSet(), {'Mar1', 'Mar2'});
  });

  test('delete removes the receipt and its line items', () async {
    final id = await repo.save(buildReceipt());
    await repo.delete(id);

    expect(await repo.getAll(), isEmpty);
    final lineItemRows = await db.select(db.lineItems).get();
    expect(lineItemRows, isEmpty);
  });

  test('getAll returns receipts newest-first', () async {
    await repo.save(
      buildReceipt(vendor: 'Older', purchasedAt: DateTime(2024, 1, 1)),
    );
    await repo.save(
      buildReceipt(vendor: 'Newer', purchasedAt: DateTime(2024, 6, 1)),
    );

    final all = await repo.getAll();
    expect(all.map((r) => r.vendor).toList(), ['Newer', 'Older']);
  });

  test('Money round-trips exactly through integer cent columns', () async {
    final id = await repo.save(
      buildReceipt(
        lineItems: [buildLineItem(description: 'Odd amount', amountCents: 1)],
      ),
    );
    final fetched = await repo.getById(id);
    expect(fetched!.lineItems.single.amount, const Money(1));
  });
}
