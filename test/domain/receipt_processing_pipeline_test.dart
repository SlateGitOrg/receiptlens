import 'package:flutter_test/flutter_test.dart';
import 'package:receiptlens/domain/entities/expense_category.dart';
import 'package:receiptlens/domain/receipt_processing_pipeline.dart';

import 'fakes.dart';

void main() {
  group('ReceiptProcessingPipeline', () {
    test('produces a categorized Receipt draft from OCR text', () async {
      final recognizer = FakeTextRecognizer(
        lines: [
          'Corner Cafe',
          '01/15/2024',
          'Latte                      4.50',
          'Bagel                      3.25',
          'SUBTOTAL                   7.75',
          'TAX                        0.62',
          'TOTAL                      8.37',
        ],
      );
      final classifier = FakeLineItemClassifier(
        category: ExpenseCategory.mealsEntertainment,
        confidence: 0.87,
      );
      final pipeline = ReceiptProcessingPipeline(
        textRecognizer: recognizer,
        classifier: classifier,
      );

      final result = await pipeline.process('/tmp/receipt.jpg');

      expect(result.isOk, isTrue);
      final receipt = result.valueOrThrow;
      expect(receipt.vendor, 'Corner Cafe');
      expect(receipt.purchasedAt, DateTime(2024, 1, 15));
      expect(receipt.lineItems, hasLength(2));
      expect(
        receipt.lineItems.every(
          (i) => i.category == ExpenseCategory.mealsEntertainment,
        ),
        isTrue,
      );
      expect(receipt.lineItems.every((i) => i.confidence == 0.87), isTrue);
      expect(receipt.total.cents, 837);
      expect(recognizer.recognizedPaths, ['/tmp/receipt.jpg']);
      expect(classifier.classifiedDescriptions, ['Latte', 'Bagel']);
    });

    test('classifies each line item independently', () async {
      final recognizer = FakeTextRecognizer(
        lines: [
          'Mixed Store',
          'Copy paper                 5.00',
          'Client lunch               20.00',
        ],
      );
      final classifier = FakeLineItemClassifier(
        categoryFor: (description) => description.contains('paper')
            ? ExpenseCategory.officeSupplies
            : ExpenseCategory.mealsEntertainment,
      );
      final pipeline = ReceiptProcessingPipeline(
        textRecognizer: recognizer,
        classifier: classifier,
      );

      final receipt = (await pipeline.process('/tmp/x.jpg')).valueOrThrow;

      expect(receipt.lineItems[0].category, ExpenseCategory.officeSupplies);
      expect(receipt.lineItems[1].category, ExpenseCategory.mealsEntertainment);
    });

    test('returns Err when OCR throws', () async {
      final recognizer = FakeTextRecognizer(
        throwOnRecognize: Exception('camera blur'),
      );
      final pipeline = ReceiptProcessingPipeline(
        textRecognizer: recognizer,
        classifier: FakeLineItemClassifier(),
      );

      final result = await pipeline.process('/tmp/bad.jpg');

      expect(result.isErr, isTrue);
      result.when(
        ok: (_) => fail('expected an error'),
        err: (message) => expect(message, contains('OCR failed')),
      );
    });

    test('returns Err when OCR finds no text at all', () async {
      final pipeline = ReceiptProcessingPipeline(
        textRecognizer: FakeTextRecognizer(lines: const []),
        classifier: FakeLineItemClassifier(),
      );

      final result = await pipeline.process('/tmp/blank.jpg');

      expect(result.isErr, isTrue);
      result.when(
        ok: (_) => fail('expected an error'),
        err: (message) => expect(message, contains('No text detected')),
      );
    });

    test('returns Err when no line items can be parsed', () async {
      final pipeline = ReceiptProcessingPipeline(
        textRecognizer: FakeTextRecognizer(
          lines: ['Just a vendor name, no prices'],
        ),
        classifier: FakeLineItemClassifier(),
      );

      final result = await pipeline.process('/tmp/noitems.jpg');

      expect(result.isErr, isTrue);
      result.when(
        ok: (_) => fail('expected an error'),
        err: (message) => expect(message, contains('No line items')),
      );
    });

    test('never invokes the classifier when parsing fails early', () async {
      final classifier = FakeLineItemClassifier();
      final pipeline = ReceiptProcessingPipeline(
        textRecognizer: FakeTextRecognizer(lines: const []),
        classifier: classifier,
      );

      await pipeline.process('/tmp/blank.jpg');

      expect(classifier.classifiedDescriptions, isEmpty);
    });
  });
}
