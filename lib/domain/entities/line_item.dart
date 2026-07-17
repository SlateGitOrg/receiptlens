import 'package:receiptlens/core/money.dart';
import 'package:receiptlens/domain/entities/expense_category.dart';

/// A single expense line on a receipt, e.g. "Copy paper ream  $12.99".
class LineItem {
  const LineItem({
    required this.description,
    required this.amount,
    required this.category,
    this.confidence = 1.0,
    this.id,
  });

  /// Null until persisted; the repository assigns one on save.
  final int? id;
  final String description;
  final Money amount;
  final ExpenseCategory category;

  /// Classifier confidence in [0, 1] for the assigned category.
  final double confidence;

  LineItem copyWith({
    int? id,
    String? description,
    Money? amount,
    ExpenseCategory? category,
    double? confidence,
  }) {
    return LineItem(
      id: id ?? this.id,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      confidence: confidence ?? this.confidence,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is LineItem &&
      other.description == description &&
      other.amount == amount &&
      other.category == category;

  @override
  int get hashCode => Object.hash(description, amount, category);

  @override
  String toString() =>
      'LineItem($description, ${amount.format()}, ${category.id})';
}
