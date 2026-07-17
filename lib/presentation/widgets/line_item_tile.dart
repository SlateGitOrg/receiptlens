import 'package:flutter/material.dart';

import 'package:receiptlens/domain/entities/expense_category.dart';
import 'package:receiptlens/domain/entities/line_item.dart';
import 'package:receiptlens/presentation/widgets/category_badge.dart';

/// An editable row for a single parsed line item: description, amount,
/// and a category dropdown the user can override if the classifier
/// guessed wrong.
class LineItemTile extends StatelessWidget {
  const LineItemTile({
    super.key,
    required this.item,
    required this.onCategoryChanged,
  });

  final LineItem item;
  final ValueChanged<ExpenseCategory> onCategoryChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.description, style: const TextStyle(fontSize: 15)),
                const SizedBox(height: 4),
                InkWell(
                  onTap: () => _showCategoryPicker(context),
                  child: CategoryBadge(
                    category: item.category,
                    confidence: item.confidence,
                  ),
                ),
              ],
            ),
          ),
          Text(
            item.amount.format(),
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  void _showCategoryPicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: ExpenseCategory.values.map((category) {
              return ListTile(
                leading: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: colorForCategory(category),
                    shape: BoxShape.circle,
                  ),
                ),
                title: Text(category.displayName),
                trailing: category == item.category
                    ? const Icon(Icons.check, size: 18)
                    : null,
                onTap: () {
                  onCategoryChanged(category);
                  Navigator.of(context).pop();
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
