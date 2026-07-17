import 'package:receiptlens/core/money.dart';
import 'package:receiptlens/domain/entities/line_item.dart';

/// A fully parsed, user-confirmed receipt ready for local storage.
class Receipt {
  const Receipt({
    this.id,
    required this.vendor,
    required this.purchasedAt,
    required this.lineItems,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.rawOcrText,
    this.imagePath,
    required this.createdAt,
  });

  final int? id;
  final String vendor;
  final DateTime purchasedAt;
  final List<LineItem> lineItems;
  final Money subtotal;
  final Money tax;
  final Money total;

  /// The full raw OCR text is retained (encrypted at rest) so a user can
  /// re-run categorization or manually correct parsing later.
  final String rawOcrText;

  /// Path to the locally-stored (cropped) receipt image, if kept.
  final String? imagePath;

  final DateTime createdAt;

  /// Sum of the line items, independent of whatever `total` the OCR/user
  /// recorded - used to sanity-check parsing.
  Money get computedLineItemTotal =>
      lineItems.fold(Money.zero(), (sum, item) => sum + item.amount);

  Receipt copyWith({
    int? id,
    String? vendor,
    DateTime? purchasedAt,
    List<LineItem>? lineItems,
    Money? subtotal,
    Money? tax,
    Money? total,
    String? rawOcrText,
    String? imagePath,
    DateTime? createdAt,
  }) {
    return Receipt(
      id: id ?? this.id,
      vendor: vendor ?? this.vendor,
      purchasedAt: purchasedAt ?? this.purchasedAt,
      lineItems: lineItems ?? this.lineItems,
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      total: total ?? this.total,
      rawOcrText: rawOcrText ?? this.rawOcrText,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
