import 'package:receiptlens/core/money.dart';
import 'package:receiptlens/domain/entities/expense_category.dart';
import 'package:receiptlens/domain/entities/line_item.dart';
import 'package:receiptlens/domain/entities/receipt.dart';

/// Shared receipt builders used across the unit and widget test suites so
/// individual test files don't have to hand-roll [Receipt]/[LineItem]
/// boilerplate.
Receipt buildReceipt({
  int? id,
  String vendor = 'Office Depot',
  DateTime? purchasedAt,
  List<LineItem>? lineItems,
  String rawOcrText = 'Office Depot\nCopy paper  12.99',
  String? imagePath,
}) {
  final items =
      lineItems ??
      [
        buildLineItem(
          description: 'Copy paper ream',
          amountCents: 1299,
          category: ExpenseCategory.officeSupplies,
        ),
      ];
  final subtotal = items.fold(Money.zero(), (sum, item) => sum + item.amount);

  return Receipt(
    id: id,
    vendor: vendor,
    purchasedAt: purchasedAt ?? DateTime(2024, 3, 15),
    lineItems: items,
    subtotal: subtotal,
    tax: Money.zero(),
    total: subtotal,
    rawOcrText: rawOcrText,
    imagePath: imagePath,
    createdAt: purchasedAt ?? DateTime(2024, 3, 15),
  );
}

LineItem buildLineItem({
  int? id,
  String description = 'Widget',
  int amountCents = 500,
  ExpenseCategory category = ExpenseCategory.other,
  double confidence = 0.9,
}) {
  return LineItem(
    id: id,
    description: description,
    amount: Money(amountCents),
    category: category,
    confidence: confidence,
  );
}
