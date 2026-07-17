/// Money is always represented in integer minor units (cents) to avoid
/// floating point drift when summing dozens of line items across months
/// of receipts.
class Money implements Comparable<Money> {
  const Money(this.cents);

  factory Money.zero() => const Money(0);

  /// Parses common receipt-printed money strings such as "$12.34", "12,34",
  /// "1,234.56", "(4.50)" (negative/refund), or bare "12".
  factory Money.parse(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return Money.zero();

    final isNegative =
        trimmed.startsWith('-') ||
        (trimmed.startsWith('(') && trimmed.endsWith(')'));

    var cleaned = trimmed.replaceAll(RegExp(r'[^0-9.,]'), '');
    if (cleaned.isEmpty) return Money.zero();

    // Normalize thousands separators. If both '.' and ',' are present,
    // assume the last one is the decimal separator.
    final lastDot = cleaned.lastIndexOf('.');
    final lastComma = cleaned.lastIndexOf(',');
    if (lastDot != -1 && lastComma != -1) {
      if (lastComma > lastDot) {
        cleaned = cleaned.replaceAll('.', '').replaceAll(',', '.');
      } else {
        cleaned = cleaned.replaceAll(',', '');
      }
    } else if (lastComma != -1 && lastDot == -1) {
      // Only commas: treat as decimal separator if exactly 2 digits follow.
      final parts = cleaned.split(',');
      if (parts.last.length == 2) {
        cleaned =
            '${parts.sublist(0, parts.length - 1).join('')}.${parts.last}';
      } else {
        cleaned = cleaned.replaceAll(',', '');
      }
    }

    final value = double.tryParse(cleaned) ?? 0;
    final cents = (value * 100).round();
    return Money(isNegative ? -cents.abs() : cents);
  }

  final int cents;

  double get dollars => cents / 100.0;

  Money operator +(Money other) => Money(cents + other.cents);
  Money operator -(Money other) => Money(cents - other.cents);
  bool operator >(Money other) => cents > other.cents;
  bool operator <(Money other) => cents < other.cents;

  String format({String symbol = '\$'}) {
    final negative = cents < 0;
    final absCents = cents.abs();
    final dollarsPart = absCents ~/ 100;
    final centsPart = (absCents % 100).toString().padLeft(2, '0');
    final withCommas = _addThousandsSeparators(dollarsPart.toString());
    return '${negative ? '-' : ''}$symbol$withCommas.$centsPart';
  }

  static String _addThousandsSeparators(String digits) {
    final buffer = StringBuffer();
    final reversed = digits.split('').reversed.toList();
    for (var i = 0; i < reversed.length; i++) {
      if (i != 0 && i % 3 == 0) buffer.write(',');
      buffer.write(reversed[i]);
    }
    return buffer.toString().split('').reversed.join();
  }

  @override
  int compareTo(Money other) => cents.compareTo(other.cents);

  @override
  bool operator ==(Object other) => other is Money && other.cents == cents;

  @override
  int get hashCode => cents.hashCode;

  @override
  String toString() => format();
}
