import 'package:flutter_test/flutter_test.dart';
import 'package:receiptlens/domain/ocr/receipt_text_parser.dart';
import 'package:receiptlens/domain/ocr/recognized_text.dart';

void main() {
  const parser = ReceiptTextParser();

  RecognizedText fromLines(List<String> lines) =>
      RecognizedText.fromRawLines(lines);

  group('vendor extraction', () {
    test('picks the first plausible non-numeric, non-date line', () {
      final draft = parser.parse(
        fromLines([
          'OFFICE DEPOT #4821',
          '123 Main St, Springfield',
          '04/12/2024',
          'Copy paper ream          12.99',
          'SUBTOTAL                 12.99',
          'TAX                       1.04',
          'TOTAL                    14.03',
        ]),
      );

      expect(draft.vendor, 'Office Depot #4821');
    });

    test('falls back to Unknown Vendor when nothing plausible is found', () {
      final draft = parser.parse(fromLines(['04/12/2024', r'12.99']));

      expect(draft.vendor, 'Unknown Vendor');
    });

    test('leaves already mixed-case vendor names untouched', () {
      final draft = parser.parse(
        fromLines(['Trader Joe\'s', 'Bananas                   1.49']),
      );

      expect(draft.vendor, "Trader Joe's");
    });
  });

  group('date extraction', () {
    test('parses numeric MM/DD/YYYY dates', () {
      final draft = parser.parse(
        fromLines([
          'Some Store',
          '03/07/2024',
          'Widget                    5.00',
        ]),
      );

      expect(draft.purchasedAt, DateTime(2024, 3, 7));
    });

    test('parses two-digit years as 20xx', () {
      final draft = parser.parse(
        fromLines(['Some Store', '03/07/24', 'Widget                    5.00']),
      );

      expect(draft.purchasedAt, DateTime(2024, 3, 7));
    });

    test('parses month-name dates', () {
      final draft = parser.parse(
        fromLines([
          'Some Store',
          'Mar 7, 2024',
          'Widget                    5.00',
        ]),
      );

      expect(draft.purchasedAt, DateTime(2024, 3, 7));
    });

    test('falls back to the provided `now` when no date is found', () {
      final now = DateTime(2023, 11, 1);
      final draft = parser.parse(
        fromLines(['Some Store', 'Widget                    5.00']),
        now: now,
      );

      expect(draft.purchasedAt, now);
    });
  });

  group('line item extraction', () {
    test('extracts itemized lines and excludes totals/payment lines', () {
      final draft = parser.parse(
        fromLines([
          'Corner Cafe',
          '01/15/2024',
          'Latte                      4.50',
          'Bagel with cream cheese    3.25',
          '2 x Cookie                 5.00',
          'SUBTOTAL                  12.75',
          'TAX                        1.02',
          'TOTAL                     13.77',
          'VISA ****1234             13.77',
        ]),
      );

      expect(draft.lineItems, hasLength(3));
      expect(draft.lineItems[0].description, 'Latte');
      expect(draft.lineItems[0].amount.cents, 450);
      expect(draft.lineItems[1].description, 'Bagel with cream cheese');
      expect(draft.lineItems[2].description, 'Cookie');
      expect(draft.lineItems[2].amount.cents, 500);
    });

    test('strips leading quantity markers like "2x" and "2 X"', () {
      final draft = parser.parse(
        fromLines([
          'Store',
          '3x Widget                  9.00',
          '4X Gadget                 12.00',
        ]),
      );

      expect(draft.lineItems[0].description, 'Widget');
      expect(draft.lineItems[1].description, 'Gadget');
    });

    test('ignores zero-amount lines', () {
      final draft = parser.parse(
        fromLines([
          'Store',
          'Free sample                0.00',
          'Real item                  2.50',
        ]),
      );

      expect(draft.lineItems, hasLength(1));
      expect(draft.lineItems.single.description, 'Real item');
    });
  });

  group('subtotal/tax/total resolution', () {
    test('uses explicit subtotal/tax/total lines when present', () {
      final draft = parser.parse(
        fromLines([
          'Store',
          'Widget                     9.99',
          'Sub Total                  9.99',
          'Tax                        0.80',
          'Total                     10.79',
        ]),
      );

      expect(draft.subtotal.cents, 999);
      expect(draft.tax.cents, 80);
      expect(draft.total.cents, 1079);
    });

    test('derives subtotal from line items and total from subtotal+tax '
        'when explicit totals are missing', () {
      final draft = parser.parse(
        fromLines([
          'Store',
          'Widget                     9.99',
          'Gadget                     5.00',
        ]),
      );

      expect(draft.subtotal.cents, 1499);
      expect(draft.tax.cents, 0);
      expect(draft.total.cents, 1499);
    });
  });

  test('retains the full OCR text verbatim on the draft', () {
    final draft = parser.parse(fromLines(['Store', 'Widget    1.00']));
    expect(draft.rawText, 'Store\nWidget    1.00');
  });
}
