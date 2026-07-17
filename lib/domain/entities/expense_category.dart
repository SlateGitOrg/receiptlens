/// The fixed set of expense categories the classifier predicts into.
///
/// `id` must match the label strings baked into the trained model
/// (see tool/ml/train_classifier.py and assets/model/categories.json) -
/// they are kept in lockstep intentionally so the Dart enum, the TFLite
/// model output ordering, and the QuickBooks export mapping never drift
/// apart silently.
enum ExpenseCategory {
  officeSupplies('office_supplies', 'Office Supplies'),
  mealsEntertainment('meals_entertainment', 'Meals & Entertainment'),
  travel('travel', 'Travel'),
  softwareSubscriptions('software_subscriptions', 'Software & Subscriptions'),
  utilities('utilities', 'Utilities'),
  equipmentHardware('equipment_hardware', 'Equipment & Hardware'),
  marketingAdvertising('marketing_advertising', 'Marketing & Advertising'),
  professionalServices('professional_services', 'Professional Services'),
  other('other', 'Other');

  const ExpenseCategory(this.id, this.displayName);

  final String id;
  final String displayName;

  static ExpenseCategory fromId(String id) {
    return ExpenseCategory.values.firstWhere(
      (c) => c.id == id,
      orElse: () => ExpenseCategory.other,
    );
  }

  /// A reasonable default QuickBooks account name per category, editable
  /// by the user later - this just seeds the exported ledger.
  String get quickBooksAccount {
    switch (this) {
      case ExpenseCategory.officeSupplies:
        return 'Office Supplies';
      case ExpenseCategory.mealsEntertainment:
        return 'Meals and Entertainment';
      case ExpenseCategory.travel:
        return 'Travel Expense';
      case ExpenseCategory.softwareSubscriptions:
        return 'Dues & Subscriptions';
      case ExpenseCategory.utilities:
        return 'Utilities';
      case ExpenseCategory.equipmentHardware:
        return 'Equipment';
      case ExpenseCategory.marketingAdvertising:
        return 'Advertising & Marketing';
      case ExpenseCategory.professionalServices:
        return 'Legal & Professional Fees';
      case ExpenseCategory.other:
        return 'Uncategorized Expense';
    }
  }
}
