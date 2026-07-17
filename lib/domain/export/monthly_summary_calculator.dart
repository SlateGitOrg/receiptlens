import 'package:receiptlens/core/money.dart';
import 'package:receiptlens/domain/entities/expense_category.dart';
import 'package:receiptlens/domain/entities/monthly_summary.dart';
import 'package:receiptlens/domain/entities/receipt.dart';

/// Aggregates a flat list of receipts into per-month, per-category totals.
class MonthlySummaryCalculator {
  const MonthlySummaryCalculator();

  List<MonthlySummary> calculate(List<Receipt> receipts) {
    final grouped = <String, List<Receipt>>{};
    for (final receipt in receipts) {
      final key = _monthKey(receipt.purchasedAt);
      grouped.putIfAbsent(key, () => []).add(receipt);
    }

    final summaries = grouped.entries.map((entry) {
      final parts = entry.key.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);

      final totals = <ExpenseCategory, Money>{};
      for (final receipt in entry.value) {
        for (final item in receipt.lineItems) {
          totals.update(
            item.category,
            (existing) => existing + item.amount,
            ifAbsent: () => item.amount,
          );
        }
      }

      return MonthlySummary(
        year: year,
        month: month,
        totalsByCategory: totals,
        receiptCount: entry.value.length,
      );
    }).toList();

    summaries.sort((a, b) {
      final byYear = b.year.compareTo(a.year);
      if (byYear != 0) return byYear;
      return b.month.compareTo(a.month);
    });

    return summaries;
  }

  /// Convenience accessor for a single (year, month) pair.
  MonthlySummary forMonth(List<Receipt> receipts, int year, int month) {
    final filtered = receipts
        .where(
          (r) => r.purchasedAt.year == year && r.purchasedAt.month == month,
        )
        .toList();

    final totals = <ExpenseCategory, Money>{};
    for (final receipt in filtered) {
      for (final item in receipt.lineItems) {
        totals.update(
          item.category,
          (existing) => existing + item.amount,
          ifAbsent: () => item.amount,
        );
      }
    }

    return MonthlySummary(
      year: year,
      month: month,
      totalsByCategory: totals,
      receiptCount: filtered.length,
    );
  }

  String _monthKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}';
}
