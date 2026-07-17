import 'package:flutter_test/flutter_test.dart';
import 'package:receiptlens/core/money.dart';

void main() {
  group('Money.parse', () {
    test('parses a plain decimal amount', () {
      expect(Money.parse('12.99').cents, 1299);
    });

    test('parses a dollar-sign-prefixed amount', () {
      expect(Money.parse(r'$4.50').cents, 450);
    });

    test('parses amounts with thousands separators', () {
      expect(Money.parse('1,234.56').cents, 123456);
    });

    test('parses European-style thousands/decimal separators', () {
      expect(Money.parse('1.234,56').cents, 123456);
    });

    test('parses comma-decimal amounts with no thousands group', () {
      expect(Money.parse('12,34').cents, 1234);
    });

    test('parses parenthesized amounts as negative (refunds)', () {
      expect(Money.parse('(4.50)').cents, -450);
    });

    test('parses explicit negative amounts', () {
      expect(Money.parse('-9.99').cents, -999);
    });

    test('parses a bare integer with no decimal part', () {
      expect(Money.parse('12').cents, 1200);
    });

    test('returns zero for unparsable input', () {
      expect(Money.parse('n/a').cents, 0);
      expect(Money.parse('').cents, 0);
    });
  });

  group('Money arithmetic and comparisons', () {
    test('addition and subtraction operate in integer cents', () {
      final a = Money.parse('10.10');
      final b = Money.parse('0.05');
      expect((a + b).cents, 1015);
      expect((a - b).cents, 1005);
    });

    test('comparison operators compare by cents', () {
      expect(Money.parse('5.00') > Money.parse('4.99'), isTrue);
      expect(Money.parse('4.99') < Money.parse('5.00'), isTrue);
      expect(Money.parse('5.00').compareTo(Money.parse('5.00')), 0);
    });

    test('equality and hashCode are value-based', () {
      expect(Money.parse('5.00'), Money.parse('5.00'));
      expect(Money.parse('5.00').hashCode, Money.parse('5.00').hashCode);
      expect(Money.parse('5.00') == Money.parse('5.01'), isFalse);
    });
  });

  group('Money.format', () {
    test('formats whole dollars with two decimal places', () {
      expect(const Money(500).format(), r'$5.00');
    });

    test('adds thousands separators for large amounts', () {
      expect(const Money(123456789).format(), r'$1,234,567.89');
    });

    test('formats negative amounts with a leading minus sign', () {
      expect(const Money(-450).format(), r'-$4.50');
    });

    test('supports a custom currency symbol', () {
      expect(const Money(1000).format(symbol: '€'), '€10.00');
    });

    test('round-trips through toString', () {
      expect(const Money(999).toString(), r'$9.99');
    });
  });
}
