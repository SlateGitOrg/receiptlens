import 'package:drift/drift.dart';

import 'package:receiptlens/core/money.dart';
import 'package:receiptlens/data/db/app_database.dart';
import 'package:receiptlens/data/encryption/field_cipher.dart';
import 'package:receiptlens/data/repositories/receipt_repository.dart';
import 'package:receiptlens/domain/entities/expense_category.dart';
import 'package:receiptlens/domain/entities/line_item.dart';
import 'package:receiptlens/domain/entities/receipt.dart';

/// Drift/SQLite-backed [ReceiptRepository]. Every write encrypts sensitive
/// text fields via [FieldCipher] before they reach the database; every
/// read decrypts them back. No column here is ever populated from, or
/// sent to, a network call.
class DriftReceiptRepository implements ReceiptRepository {
  DriftReceiptRepository({required AppDatabase db, required FieldCipher cipher})
    : _db = db,
      _cipher = cipher;

  final AppDatabase _db;
  final FieldCipher _cipher;

  @override
  Future<int> save(Receipt receipt) async {
    return _db.transaction(() async {
      final vendorEncrypted = await _cipher.encrypt(receipt.vendor);
      final rawTextEncrypted = await _cipher.encrypt(receipt.rawOcrText);

      final int receiptId;
      if (receipt.id == null) {
        receiptId = await _db
            .into(_db.receipts)
            .insert(
              ReceiptsCompanion.insert(
                vendorEncrypted: vendorEncrypted,
                purchasedAt: receipt.purchasedAt,
                subtotalCents: receipt.subtotal.cents,
                taxCents: receipt.tax.cents,
                totalCents: receipt.total.cents,
                rawOcrTextEncrypted: rawTextEncrypted,
                imagePath: Value(receipt.imagePath),
                createdAt: receipt.createdAt,
              ),
            );
      } else {
        receiptId = receipt.id!;
        await (_db.update(
          _db.receipts,
        )..where((r) => r.id.equals(receiptId))).write(
          ReceiptsCompanion(
            vendorEncrypted: Value(vendorEncrypted),
            purchasedAt: Value(receipt.purchasedAt),
            subtotalCents: Value(receipt.subtotal.cents),
            taxCents: Value(receipt.tax.cents),
            totalCents: Value(receipt.total.cents),
            rawOcrTextEncrypted: Value(rawTextEncrypted),
            imagePath: Value(receipt.imagePath),
          ),
        );
        await (_db.delete(
          _db.lineItems,
        )..where((li) => li.receiptId.equals(receiptId))).go();
      }

      for (final item in receipt.lineItems) {
        final descriptionEncrypted = await _cipher.encrypt(item.description);
        await _db
            .into(_db.lineItems)
            .insert(
              LineItemsCompanion.insert(
                receiptId: receiptId,
                descriptionEncrypted: descriptionEncrypted,
                amountCents: item.amount.cents,
                categoryId: item.category.id,
                confidence: Value(item.confidence),
              ),
            );
      }

      return receiptId;
    });
  }

  @override
  Future<List<Receipt>> getAll() async {
    final rows = await _db.select(_db.receipts).get();
    final receipts = <Receipt>[];
    for (final row in rows) {
      receipts.add(await _hydrate(row));
    }
    receipts.sort((a, b) => b.purchasedAt.compareTo(a.purchasedAt));
    return receipts;
  }

  @override
  Future<Receipt?> getById(int id) async {
    final row = await (_db.select(
      _db.receipts,
    )..where((r) => r.id.equals(id))).getSingleOrNull();
    if (row == null) return null;
    return _hydrate(row);
  }

  @override
  Future<List<Receipt>> getForMonth(int year, int month) async {
    final all = await getAll();
    return all
        .where(
          (r) => r.purchasedAt.year == year && r.purchasedAt.month == month,
        )
        .toList();
  }

  @override
  Future<void> delete(int id) async {
    await (_db.delete(_db.receipts)..where((r) => r.id.equals(id))).go();
  }

  Future<Receipt> _hydrate(ReceiptRow row) async {
    final lineItemRows = await (_db.select(
      _db.lineItems,
    )..where((li) => li.receiptId.equals(row.id))).get();

    final lineItems = <LineItem>[];
    for (final li in lineItemRows) {
      final description = await _cipher.decrypt(li.descriptionEncrypted);
      lineItems.add(
        LineItem(
          id: li.id,
          description: description,
          amount: Money(li.amountCents),
          category: ExpenseCategory.fromId(li.categoryId),
          confidence: li.confidence,
        ),
      );
    }

    final vendor = await _cipher.decrypt(row.vendorEncrypted);
    final rawText = await _cipher.decrypt(row.rawOcrTextEncrypted);

    return Receipt(
      id: row.id,
      vendor: vendor,
      purchasedAt: row.purchasedAt,
      lineItems: lineItems,
      subtotal: Money(row.subtotalCents),
      tax: Money(row.taxCents),
      total: Money(row.totalCents),
      rawOcrText: rawText,
      imagePath: row.imagePath,
      createdAt: row.createdAt,
    );
  }
}
