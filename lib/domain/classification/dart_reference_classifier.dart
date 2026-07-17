import 'dart:math' as math;

import 'package:receiptlens/domain/classification/bow_vectorizer.dart';
import 'package:receiptlens/domain/classification/classifier_weights.dart';
import 'package:receiptlens/domain/classification/line_item_classifier.dart';
import 'package:receiptlens/domain/entities/expense_category.dart';

/// A pure-Dart forward pass through the *same* trained
/// bag-of-words -> dense(relu) -> dense(softmax) network exported to
/// `assets/model/category_classifier.tflite`.
///
/// Why this exists alongside a real TFLite model: the native TensorFlow
/// Lite interpreter is a platform binary loaded via FFI/platform channels,
/// which is unavailable inside `flutter test`'s host-Dart-VM environment
/// and on any offline CI runner without the native lib staged. Re-running
/// the identical trained weights in plain Dart gives:
///
///   1. A fully offline, deterministic, fast unit-test target for the
///      categorization logic (this is what test/ exercises).
///   2. A safe automatic fallback at runtime if TFLite interpreter
///      creation fails on a given device (some low-end/older devices,
///      or unusual ABIs).
///
/// Because both consume the identical `weights.json` export, this is not
/// a "fake" - it is a second, portable inference engine for the one real
/// model.
class DartReferenceClassifier implements LineItemClassifier {
  DartReferenceClassifier({
    required ClassifierWeights weights,
    required ClassifierVocab vocab,
    required ClassifierCategories categories,
  }) : _weights = weights,
       _vectorizer = BagOfWordsVectorizer(vocabulary: vocab.tokens),
       _categories = categories;

  final ClassifierWeights _weights;
  final BagOfWordsVectorizer _vectorizer;
  final ClassifierCategories _categories;

  @override
  Future<CategoryPrediction> classify(String description) async {
    final x = _vectorizer.vectorize(description);

    // hidden = relu(W1 . x + b1)
    final hidden = List<double>.filled(_weights.hiddenUnits, 0.0);
    for (var j = 0; j < _weights.hiddenUnits; j++) {
      var sum = _weights.b1[j];
      final row = _weights.w1[j];
      for (var i = 0; i < x.length; i++) {
        sum += row[i] * x[i];
      }
      hidden[j] = sum > 0 ? sum : 0.0;
    }

    // logits = W2 . hidden + b2
    final logits = List<double>.filled(_weights.numCategories, 0.0);
    for (var k = 0; k < _weights.numCategories; k++) {
      var sum = _weights.b2[k];
      final row = _weights.w2[k];
      for (var j = 0; j < hidden.length; j++) {
        sum += row[j] * hidden[j];
      }
      logits[k] = sum;
    }

    final probs = _softmax(logits);

    var bestIdx = 0;
    var bestProb = probs[0];
    for (var k = 1; k < probs.length; k++) {
      if (probs[k] > bestProb) {
        bestProb = probs[k];
        bestIdx = k;
      }
    }

    final categoryId = _categories.ids[bestIdx];
    return CategoryPrediction(
      category: ExpenseCategory.fromId(categoryId),
      confidence: bestProb,
    );
  }

  List<double> _softmax(List<double> logits) {
    final maxLogit = logits.reduce(math.max);
    final exps = logits.map((l) => math.exp(l - maxLogit)).toList();
    final sumExp = exps.fold(0.0, (a, b) => a + b);
    return exps.map((e) => e / sumExp).toList();
  }

  @override
  Future<void> close() async {}
}
