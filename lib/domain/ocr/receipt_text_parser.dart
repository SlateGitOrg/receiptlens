import 'package:receiptlens/core/money.dart';
import 'package:receiptlens/domain/ocr/recognized_text.dart';

/// A single candidate expense line pulled off a receipt, before
/// categorization has been applied.
class RawLineItem {
  const RawLineItem({required this.description, required this.amount});
  final String description;
  final Money amount;
}

/// The structured (but not-yet-categorized) result of parsing raw OCR
/// text off a receipt photo.
class ParsedReceiptDraft {
  const ParsedReceiptDraft({
    required this.vendor,
    required this.purchasedAt,
    required this.lineItems,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.rawText,
  });

  final String vendor;
  final DateTime purchasedAt;
  final List<RawLineItem> lineItems;
  final Money subtotal;
  final Money tax;
  final Money total;
  final String rawText;
}

/// Turns raw OCR text lines into a structured [ParsedReceiptDraft].
///
/// This is intentionally pure (no I/O, no platform dependency) so it can
/// be unit tested exhaustively against fixture receipts. It implements
/// the heuristics real receipt-parsing pipelines use in practice:
///
///  - the vendor name is usually one of the first non-numeric lines
///  - dates appear in a handful of common formats
///  - subtotal/tax/tip/total lines are keyword-anchored and should be
///    excluded from the itemized line-item list
///  - a "line item" is any remaining line that ends in a plausible
///    money amount
class ReceiptTextParser {
  const ReceiptTextParser();

  static final RegExp _moneyAtEnd = RegExp(
    r'([\$]?\s?-?\(?\d{1,3}(?:[,.]\d{3})*[.,]\d{2}\)?)\s*$',
  );

  static final RegExp _dateMdY = RegExp(
    r'\b(\d{1,2})[\/\-](\d{1,2})[\/\-](\d{2,4})\b',
  );

  static final RegExp _dateMonthName = RegExp(
    r'\b(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[a-z]*\.?\s+(\d{1,2}),?\s+(\d{4})\b',
    caseSensitive: false,
  );

  static const _monthAbbrev = {
    'jan': 1,
    'feb': 2,
    'mar': 3,
    'apr': 4,
    'may': 5,
    'jun': 6,
    'jul': 7,
    'aug': 8,
    'sep': 9,
    'oct': 10,
    'nov': 11,
    'dec': 12,
  };

  static const _subtotalKeywords = ['subtotal', 'sub total', 'sub-total'];
  static const _taxKeywords = ['tax', 'vat', 'gst', 'hst'];
  static const _totalKeywords = [
    'total',
    'amount due',
    'balance due',
    'grand total',
  ];
  static const _excludeFromLineItems = [
    ...['subtotal', 'sub total', 'sub-total'],
    ...['tax', 'vat', 'gst', 'hst'],
    ...[
      'total',
      'amount due',
      'balance due',
      'grand total',
      'change',
      'cash',
      'card',
      'visa',
      'mastercard',
      'debit',
      'credit',
      'tip',
      'gratuity',
    ],
  ];

  ParsedReceiptDraft parse(RecognizedText text, {DateTime? now}) {
    final lines = text.lines.map((l) => l.text).toList();
    final vendor = _extractVendor(lines);
    final purchasedAt = _extractDate(lines) ?? (now ?? DateTime.now());
    final subtotal = _extractLabeledAmount(lines, _subtotalKeywords);
    final tax = _extractLabeledAmount(lines, _taxKeywords);
    final total = _extractLabeledAmount(
      lines,
      _totalKeywords,
      excludeIfAlsoMatches: _subtotalKeywords,
    );
    final lineItems = _extractLineItems(lines);

    final resolvedSubtotal =
        subtotal ??
        lineItems.fold<Money>(Money.zero(), (sum, i) => sum + i.amount);
    final resolvedTotal = total ?? (resolvedSubtotal + (tax ?? Money.zero()));

    return ParsedReceiptDraft(
      vendor: vendor,
      purchasedAt: purchasedAt,
      lineItems: lineItems,
      subtotal: resolvedSubtotal,
      tax: tax ?? Money.zero(),
      total: resolvedTotal,
      rawText: text.fullText,
    );
  }

  String _extractVendor(List<String> lines) {
    for (final line in lines.take(5)) {
      final letters = line.replaceAll(RegExp(r'[^A-Za-z]'), '');
      if (letters.length < 2) continue;
      if (_moneyAtEnd.hasMatch(line)) continue;
      if (_dateMdY.hasMatch(line)) continue;
      return _titleCase(line.trim());
    }
    return 'Unknown Vendor';
  }

  String _titleCase(String input) {
    // Receipts are frequently ALL CAPS; make them presentable while
    // leaving already-mixed-case strings untouched.
    final isShouting =
        input == input.toUpperCase() && input != input.toLowerCase();
    if (!isShouting) return input;
    return input
        .toLowerCase()
        .split(' ')
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  DateTime? _extractDate(List<String> lines) {
    for (final line in lines) {
      final numeric = _dateMdY.firstMatch(line);
      if (numeric != null) {
        final month = int.parse(numeric.group(1)!);
        final day = int.parse(numeric.group(2)!);
        var year = int.parse(numeric.group(3)!);
        if (year < 100) year += 2000;
        if (month.in1to12 && day.in1to31) {
          try {
            return DateTime(year, month, day);
          } catch (_) {
            /* fall through */
          }
        }
      }
      final named = _dateMonthName.firstMatch(line);
      if (named != null) {
        final month = _monthAbbrev[named.group(1)!.toLowerCase()];
        final day = int.tryParse(named.group(2)!);
        final year = int.tryParse(named.group(3)!);
        if (month != null && day != null && year != null) {
          try {
            return DateTime(year, month, day);
          } catch (_) {
            /* fall through */
          }
        }
      }
    }
    return null;
  }

  /// Finds the money amount on the first line matching any of [keywords].
  ///
  /// [excludeIfAlsoMatches] lets callers rule out lines that would
  /// otherwise be ambiguous - e.g. "Sub Total" contains "total" as a
  /// literal substring, so a naive search for the *total* keyword would
  /// match the *subtotal* line first. Passing the subtotal keywords here
  /// when searching for the total keeps the two from colliding.
  Money? _extractLabeledAmount(
    List<String> lines,
    List<String> keywords, {
    List<String> excludeIfAlsoMatches = const [],
  }) {
    for (final line in lines) {
      final lower = line.toLowerCase();
      final matchesKeyword = keywords.any((k) => lower.contains(k));
      if (!matchesKeyword) continue;
      if (excludeIfAlsoMatches.any((k) => lower.contains(k))) continue;
      final match = _moneyAtEnd.firstMatch(line);
      if (match != null) {
        return Money.parse(match.group(1)!);
      }
    }
    return null;
  }

  List<RawLineItem> _extractLineItems(List<String> lines) {
    final items = <RawLineItem>[];
    for (final line in lines) {
      final lower = line.toLowerCase();
      if (_excludeFromLineItems.any((k) => lower.contains(k))) continue;

      final match = _moneyAtEnd.firstMatch(line);
      if (match == null) continue;

      final amount = Money.parse(match.group(1)!);
      if (amount.cents <= 0) continue;

      var description = line.substring(0, match.start).trim();
      // Strip a leading quantity marker like "2 x" or "2x".
      description = description.replaceFirst(RegExp(r'^\d+\s*[xX]\s*'), '');
      description = description.replaceAll(RegExp(r'\s{2,}'), ' ').trim();
      if (description.isEmpty) continue;

      items.add(RawLineItem(description: description, amount: amount));
    }
    return items;
  }
}

extension on int {
  bool get in1to12 => this >= 1 && this <= 12;
  bool get in1to31 => this >= 1 && this <= 31;
}
