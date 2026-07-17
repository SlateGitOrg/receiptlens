import 'package:receiptlens/domain/classification/line_item_classifier.dart';
import 'package:receiptlens/domain/entities/expense_category.dart';
import 'package:receiptlens/domain/ocr/recognized_text.dart';
import 'package:receiptlens/domain/ocr/text_recognizer.dart';

/// A deterministic, in-memory [TextRecognizer] double for tests: returns
/// pre-canned OCR output (or throws) instead of touching ML Kit or a
/// camera/device.
class FakeTextRecognizer implements TextRecognizer {
  FakeTextRecognizer({List<String>? lines, this.throwOnRecognize})
    : lines = lines ?? const [];

  final List<String> lines;
  final Object? throwOnRecognize;

  int closeCallCount = 0;
  final List<String> recognizedPaths = [];

  @override
  Future<RecognizedText> recognizeImage(String imagePath) async {
    recognizedPaths.add(imagePath);
    if (throwOnRecognize != null) throw throwOnRecognize!;
    return RecognizedText.fromRawLines(lines);
  }

  @override
  Future<void> close() async {
    closeCallCount++;
  }
}

/// A deterministic [LineItemClassifier] double: classifies every line item
/// as [category] with [confidence], unless [categoryFor] is supplied for
/// per-description control.
class FakeLineItemClassifier implements LineItemClassifier {
  FakeLineItemClassifier({
    this.category = ExpenseCategory.other,
    this.confidence = 0.99,
    this.categoryFor,
  });

  final ExpenseCategory category;
  final double confidence;
  final ExpenseCategory Function(String description)? categoryFor;

  final List<String> classifiedDescriptions = [];
  int closeCallCount = 0;

  @override
  Future<CategoryPrediction> classify(String description) async {
    classifiedDescriptions.add(description);
    final resolved = categoryFor?.call(description) ?? category;
    return CategoryPrediction(category: resolved, confidence: confidence);
  }

  @override
  Future<void> close() async {
    closeCallCount++;
  }
}
