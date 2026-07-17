import 'dart:math' as math;

import 'package:flutter/services.dart' show rootBundle;
import 'package:tflite_flutter/tflite_flutter.dart';

import 'package:receiptlens/domain/classification/bow_vectorizer.dart';
import 'package:receiptlens/domain/classification/classifier_weights.dart';
import 'package:receiptlens/domain/classification/line_item_classifier.dart';
import 'package:receiptlens/domain/entities/expense_category.dart';

/// Production, on-device inference path: runs the real trained model
/// (`assets/model/category_classifier.tflite`) through the TensorFlow
/// Lite interpreter. No network call is made - the model, vocabulary, and
/// weights are all bundled app assets.
///
/// See [DartReferenceClassifier] for why a second, pure-Dart
/// implementation of the identical trained weights also exists (used by
/// the test suite and as a runtime fallback).
class TfliteLineItemClassifier implements LineItemClassifier {
  TfliteLineItemClassifier._(
    this._interpreter,
    this._vectorizer,
    this._categories,
  );

  final Interpreter _interpreter;
  final BagOfWordsVectorizer _vectorizer;
  final ClassifierCategories _categories;

  static Future<TfliteLineItemClassifier> load({
    String modelAsset = 'assets/model/category_classifier.tflite',
    String vocabAsset = 'assets/model/vocab.json',
    String categoriesAsset = 'assets/model/categories.json',
  }) async {
    final interpreter = await Interpreter.fromAsset(modelAsset);
    final vocabJson = await rootBundle.loadString(vocabAsset);
    final categoriesJson = await rootBundle.loadString(categoriesAsset);

    final vocab = ClassifierVocab.fromJsonString(vocabJson);
    final categories = ClassifierCategories.fromJsonString(categoriesJson);

    return TfliteLineItemClassifier._(
      interpreter,
      BagOfWordsVectorizer(vocabulary: vocab.tokens),
      categories,
    );
  }

  @override
  Future<CategoryPrediction> classify(String description) async {
    final input = [_vectorizer.vectorize(description)];
    final output = [List<double>.filled(_categories.ids.length, 0.0)];

    _interpreter.run(input, output);

    final probs = output[0];
    var bestIdx = 0;
    var bestProb = probs[0];
    for (var k = 1; k < probs.length; k++) {
      if (probs[k] > bestProb) {
        bestProb = probs[k];
        bestIdx = k;
      }
    }

    return CategoryPrediction(
      category: ExpenseCategory.fromId(_categories.ids[bestIdx]),
      confidence: math.max(0.0, math.min(1.0, bestProb)),
    );
  }

  @override
  Future<void> close() async {
    _interpreter.close();
  }
}
