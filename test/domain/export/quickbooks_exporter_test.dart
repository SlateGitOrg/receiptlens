import 'package:flutter_test/flutter_test.dart';
import 'package:receiptlens/domain/entities/expense_category.dart';
import 'package:receiptlens/domain/export/quickbooks_exporter.dart';

import '../../fixtures/receipt_fixtures.dart';

void main() {
  const exporter = QuickBooksExporter();

  test('writes the Date,Description,Amount header QuickBooks expects', () {
    final csv = exporter.export(const []);
    expect(csv.trim(), 'Date,Description,Amount');
  });

  test('formats dates as MM/dd/yyyy and amounts as negative expenses', () {
    final receipts = [
      buildReceipt(
        vendor: 'Delta Airlines',
        purchasedAt: DateTime(2024, 3, 15),
        lineItems: [
          buildLineItem(
            description: 'Flight ticket',
            amountCents: 45000,
            category: ExpenseCategory.travel,
          ),
        ],
      ),
    ];

    final csv = exporter.export(receipts);
    final row = csv.trim().split('\n')[1];

    expect(row, startsWith('03/15/2024,'));
    expect(row, endsWith(',-450.00'));
    expect(row, contains('Delta Airlines - Flight ticket'));
    expect(row, contains('Travel Expense'));
  });

  test('emits one row per line item with the mapped QuickBooks account', () {
    final receipts = [
      buildReceipt(
        lineItems: [
          buildLineItem(
            description: 'Laptop',
            amountCents: 120000,
            category: ExpenseCategory.equipmentHardware,
          ),
          buildLineItem(
            description: 'Consulting fee',
            amountCents: 50000,
            category: ExpenseCategory.professionalServices,
          ),
        ],
      ),
    ];

    final rows = exporter.export(receipts).trim().split('\n');

    expect(rows, hasLength(3));
    expect(rows[1], contains('Equipment'));
    expect(rows[2], contains('Legal & Professional Fees'));
  });
}
