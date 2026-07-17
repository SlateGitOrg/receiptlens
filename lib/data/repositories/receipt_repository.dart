import 'package:receiptlens/domain/entities/receipt.dart';

/// Persistence boundary for receipts. All implementations must keep
/// sensitive fields encrypted at rest and must never perform network I/O.
abstract interface class ReceiptRepository {
  Future<int> save(Receipt receipt);

  Future<List<Receipt>> getAll();

  Future<Receipt?> getById(int id);

  Future<List<Receipt>> getForMonth(int year, int month);

  Future<void> delete(int id);
}
