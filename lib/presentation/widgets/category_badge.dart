import 'package:flutter/material.dart';

import 'package:receiptlens/domain/entities/expense_category.dart';

Color colorForCategory(ExpenseCategory category) {
  switch (category) {
    case ExpenseCategory.officeSupplies:
      return const Color(0xFF3B82F6);
    case ExpenseCategory.mealsEntertainment:
      return const Color(0xFFF59E0B);
    case ExpenseCategory.travel:
      return const Color(0xFF10B981);
    case ExpenseCategory.softwareSubscriptions:
      return const Color(0xFF8B5CF6);
    case ExpenseCategory.utilities:
      return const Color(0xFF06B6D4);
    case ExpenseCategory.equipmentHardware:
      return const Color(0xFFEF4444);
    case ExpenseCategory.marketingAdvertising:
      return const Color(0xFFEC4899);
    case ExpenseCategory.professionalServices:
      return const Color(0xFF6366F1);
    case ExpenseCategory.other:
      return const Color(0xFF6B7280);
  }
}

class CategoryBadge extends StatelessWidget {
  const CategoryBadge({super.key, required this.category, this.confidence});

  final ExpenseCategory category;
  final double? confidence;

  @override
  Widget build(BuildContext context) {
    final color = colorForCategory(category);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            category.displayName,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (confidence != null) ...[
            const SizedBox(width: 4),
            Text(
              '${(confidence! * 100).round()}%',
              style: TextStyle(
                color: color.withValues(alpha: 0.7),
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
