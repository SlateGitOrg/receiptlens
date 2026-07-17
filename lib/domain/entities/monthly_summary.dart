import 'package:receiptlens/core/money.dart';
import 'package:receiptlens/domain/entities/expense_category.dart';

/// Aggregated totals for a single calendar month, broken down by category.
class MonthlySummary {
  const MonthlySummary({
    required this.year,
    required this.month,
    required this.totalsByCategory,
    required this.receiptCount,
  });

  final int year;
  final int month;
  final Map<ExpenseCategory, Money> totalsByCategory;
  final int receiptCount;

  Money get grandTotal =>
      totalsByCategory.values.fold(Money.zero(), (sum, m) => sum + m);

  String get label => '${_monthName(month)} $year';

  static String _monthName(int month) {
    const names = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return names[month - 1];
  }
}
