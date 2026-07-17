import 'package:receiptlens/core/result.dart';
import 'package:receiptlens/domain/classification/line_item_classifier.dart';
import 'package:receiptlens/domain/entities/line_item.dart';
import 'package:receiptlens/domain/entities/receipt.dart';
import 'package:receiptlens/domain/ocr/receipt_text_parser.dart';
import 'package:receiptlens/domain/ocr/recognized_text.dart';
import 'package:receiptlens/domain/ocr/text_recognizer.dart';

/// Orchestrates the full "capture -> structured receipt" pipeline:
///
///   image path -> [TextRecognizer] (on-device OCR)
///              -> [ReceiptTextParser] (structure the raw text)
///              -> [LineItemClassifier] (categorize each line item)
///              -> [Receipt] draft, ready for user review and save
///
/// Every step here is either a pure function or an on-device call - there
/// is no network boundary crossed anywhere in this class.
class ReceiptProcessingPipeline {
  const ReceiptProcessingPipeline({
    required TextRecognizer textRecognizer,
    required LineItemClassifier classifier,
    ReceiptTextParser parser = const ReceiptTextParser(),
  }) : _textRecognizer = textRecognizer,
       _classifier = classifier,
       _parser = parser;

  final TextRecognizer _textRecognizer;
  final LineItemClassifier _classifier;
  final ReceiptTextParser _parser;

  /// Runs OCR + parsing + categorization for a captured (and already
  /// cropped) receipt image, returning a draft [Receipt] with `id: null`
  /// and no `imagePath` set (the caller fills that in once the cropped
  /// image is persisted to app-local storage).
  Future<Result<Receipt>> process(String imagePath) async {
    final RecognizedText recognized;
    try {
      recognized = await _textRecognizer.recognizeImage(imagePath);
    } catch (e) {
      return Result.err('OCR failed: $e');
    }

    if (recognized.isEmpty) {
      return const Result.err(
        'No text detected. Retake the photo with better lighting or framing.',
      );
    }

    final draft = _parser.parse(recognized);

    if (draft.lineItems.isEmpty) {
      return const Result.err(
        'No line items could be parsed from this receipt. '
        'Try a clearer, well-lit photo showing the full itemized list.',
      );
    }

    final lineItems = <LineItem>[];
    for (final raw in draft.lineItems) {
      final prediction = await _classifier.classify(raw.description);
      lineItems.add(
        LineItem(
          description: raw.description,
          amount: raw.amount,
          category: prediction.category,
          confidence: prediction.confidence,
        ),
      );
    }

    final now = DateTime.now();
    final receipt = Receipt(
      vendor: draft.vendor,
      purchasedAt: draft.purchasedAt,
      lineItems: lineItems,
      subtotal: draft.subtotal,
      tax: draft.tax,
      total: draft.total,
      rawOcrText: draft.rawText,
      createdAt: now,
    );

    return Result.ok(receipt);
  }
}
