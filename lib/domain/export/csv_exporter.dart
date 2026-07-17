import 'package:intl/intl.dart';

import 'package:receiptlens/domain/entities/receipt.dart';

/// Exports receipts as a general-purpose, spreadsheet-friendly CSV: one
/// row per line item, with the parent receipt's vendor/date repeated.
class CsvExporter {
  const CsvExporter();

  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  String export(List<Receipt> receipts) {
    final buffer = StringBuffer();
    buffer.writeln(
      [
        'Date',
        'Vendor',
        'Description',
        'Category',
        'Amount',
        'Receipt Total',
      ].map(_csvField).join(','),
    );

    for (final receipt in receipts) {
      for (final item in receipt.lineItems) {
        buffer.writeln(
          [
            _dateFormat.format(receipt.purchasedAt),
            receipt.vendor,
            item.description,
            item.category.displayName,
            item.amount.dollars.toStringAsFixed(2),
            receipt.total.dollars.toStringAsFixed(2),
          ].map(_csvField).join(','),
        );
      }
    }
    return buffer.toString();
  }

  String _csvField(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }
}
