import 'package:flutter_test/flutter_test.dart';
import 'package:receiptlens/domain/entities/expense_category.dart';
import 'package:receiptlens/domain/export/monthly_summary_calculator.dart';

import '../../fixtures/receipt_fixtures.dart';

void main() {
  const calculator = MonthlySummaryCalculator();

  test('groups receipts by calendar month, newest first', () {
    final receipts = [
      buildReceipt(purchasedAt: DateTime(2024, 1, 5)),
      buildReceipt(purchasedAt: DateTime(2024, 3, 2)),
      buildReceipt(purchasedAt: DateTime(2024, 3, 20)),
    ];

    final summaries = calculator.calculate(receipts);

    expect(summaries, hasLength(2));
    expect(summaries[0].year, 2024);
    expect(summaries[0].month, 3);
    expect(summaries[0].receiptCount, 2);
    expect(summaries[1].month, 1);
    expect(summaries[1].receiptCount, 1);
  });

  test('sums line item amounts per category within a month', () {
    final receipts = [
      buildReceipt(
        purchasedAt: DateTime(2024, 5, 1),
        lineItems: [
          buildLineItem(amountCents: 1000, category: ExpenseCategory.travel),
          buildLineItem(amountCents: 500, category: ExpenseCategory.travel),
        ],
      ),
      buildReceipt(
        purchasedAt: DateTime(2024, 5, 10),
        lineItems: [
          buildLineItem(
            amountCents: 2000,
            category: ExpenseCategory.mealsEntertainment,
          ),
        ],
      ),
    ];

    final summaries = calculator.calculate(receipts);
    final may = summaries.single;

    expect(may.totalsByCategory[ExpenseCategory.travel]?.cents, 1500);
    expect(
      may.totalsByCategory[ExpenseCategory.mealsEntertainment]?.cents,
      2000,
    );
    expect(may.grandTotal.cents, 3500);
    expect(may.label, 'May 2024');
  });

  test('forMonth filters and aggregates a single (year, month) pair', () {
    final receipts = [
      buildReceipt(
        purchasedAt: DateTime(2024, 6, 1),
        lineItems: [
          buildLineItem(amountCents: 400, category: ExpenseCategory.utilities),
        ],
      ),
      buildReceipt(
        purchasedAt: DateTime(2024, 7, 1),
        lineItems: [
          buildLineItem(amountCents: 999, category: ExpenseCategory.utilities),
        ],
      ),
    ];

    final june = calculator.forMonth(receipts, 2024, 6);

    expect(june.receiptCount, 1);
    expect(june.totalsByCategory[ExpenseCategory.utilities]?.cents, 400);
  });

  test('returns an empty summary for a month with no receipts', () {
    final summary = calculator.forMonth(const [], 2024, 1);
    expect(summary.receiptCount, 0);
    expect(summary.grandTotal.cents, 0);
    expect(summary.totalsByCategory, isEmpty);
  });
}
