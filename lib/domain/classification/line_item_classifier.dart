import 'package:receiptlens/domain/entities/expense_category.dart';

class CategoryPrediction {
  const CategoryPrediction({required this.category, required this.confidence});
  final ExpenseCategory category;
  final double confidence;
}

/// Abstraction over "given a line-item description, which expense category
/// does it belong to". Two implementations exist behind this interface
/// (see lib/domain/classification/*):
///
///  - [TfliteLineItemClassifier]: runs the real trained TFLite model
///    on-device via `tflite_flutter`. This is the production path used
///    at runtime on a real phone/simulator.
///  - [DartReferenceClassifier]: a pure-Dart re-implementation of the
///    *exact same* trained weights (see tool/ml/train_classifier.py),
///    used in unit tests and as an automatic fallback if the native
///    TFLite runtime/model asset is unavailable on a given platform.
///
/// Both share the same [BagOfWordsVectorizer] and weights export, so
/// their predictions agree.
abstract interface class LineItemClassifier {
  Future<CategoryPrediction> classify(String description);

  Future<void> close();
}
