import 'package:intl/intl.dart';

import 'package:receiptlens/domain/entities/receipt.dart';

/// Exports receipts using the 3-column CSV layout QuickBooks Online's
/// "Upload from file" bank-transaction importer expects: `Date,
/// Description, Amount`, with `MM/dd/yyyy` dates and expenses represented
/// as negative amounts (money leaving the account). One row is emitted
/// per line item so each expense lands in its own QuickBooks
/// category/account after import-mapping, with the mapped account name
/// appended to the description for easy manual reconciliation.
class QuickBooksExporter {
  const QuickBooksExporter();

  static final DateFormat _dateFormat = DateFormat('MM/dd/yyyy');

  String export(List<Receipt> receipts) {
    final buffer = StringBuffer();
    buffer.writeln(['Date', 'Description', 'Amount'].join(','));

    for (final receipt in receipts) {
      for (final item in receipt.lineItems) {
        final description =
            '${receipt.vendor} - ${item.description} (${item.category.quickBooksAccount})';
        final amount = -item.amount.dollars;
        buffer.writeln(
          [
            _dateFormat.format(receipt.purchasedAt),
            _csvField(description),
            amount.toStringAsFixed(2),
          ].join(','),
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
