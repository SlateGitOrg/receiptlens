import 'package:flutter_test/flutter_test.dart';
import 'package:receiptlens/domain/entities/expense_category.dart';
import 'package:receiptlens/domain/export/csv_exporter.dart';

import '../../fixtures/receipt_fixtures.dart';

void main() {
  const exporter = CsvExporter();

  test('writes a header row followed by one row per line item', () {
    final receipts = [
      buildReceipt(
        vendor: 'Office Depot',
        purchasedAt: DateTime(2024, 3, 15),
        lineItems: [
          buildLineItem(
            description: 'Copy paper',
            amountCents: 1299,
            category: ExpenseCategory.officeSupplies,
          ),
          buildLineItem(
            description: 'Stapler',
            amountCents: 899,
            category: ExpenseCategory.officeSupplies,
          ),
        ],
      ),
    ];

    final csv = exporter.export(receipts);
    final rows = csv.trim().split('\n');

    expect(rows, hasLength(3));
    expect(rows[0], 'Date,Vendor,Description,Category,Amount,Receipt Total');
    expect(
      rows[1],
      '2024-03-15,Office Depot,Copy paper,Office Supplies,12.99,21.98',
    );
    expect(
      rows[2],
      '2024-03-15,Office Depot,Stapler,Office Supplies,8.99,21.98',
    );
  });

  test('escapes fields containing commas or quotes', () {
    final receipts = [
      buildReceipt(
        vendor: 'Joe\'s "Downtown" Diner, LLC',
        lineItems: [
          buildLineItem(description: 'Lunch, with tax', amountCents: 1500),
        ],
      ),
    ];

    final csv = exporter.export(receipts);

    expect(csv, contains('"Joe\'s ""Downtown"" Diner, LLC"'));
    expect(csv, contains('"Lunch, with tax"'));
  });

  test('emits only the header row for an empty receipt list', () {
    final csv = exporter.export(const []);
    expect(csv.trim(), 'Date,Vendor,Description,Category,Amount,Receipt Total');
  });

  test('emits multiple receipts in the order given', () {
    final receipts = [
      buildReceipt(vendor: 'Store A', purchasedAt: DateTime(2024, 1, 1)),
      buildReceipt(vendor: 'Store B', purchasedAt: DateTime(2024, 1, 2)),
    ];

    final csv = exporter.export(receipts);
    final rows = csv.trim().split('\n');

    expect(rows, hasLength(3));
    expect(rows[1], startsWith('2024-01-01,Store A'));
    expect(rows[2], startsWith('2024-01-02,Store B'));
  });
}
