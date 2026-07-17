import 'package:flutter/services.dart' show rootBundle;

import 'package:receiptlens/domain/classification/classifier_weights.dart';
import 'package:receiptlens/domain/classification/dart_reference_classifier.dart';
import 'package:receiptlens/domain/classification/line_item_classifier.dart';
import 'package:receiptlens/services/classification/tflite_line_item_classifier.dart';

/// Builds the app's [LineItemClassifier], preferring the real on-device
/// TFLite interpreter and transparently falling back to the pure-Dart
/// reference implementation of the identical trained weights if the
/// native TFLite runtime can't be initialized on the current platform
/// (e.g. certain simulators/CI hosts without the native library staged).
///
/// Both paths score identically because they share one weights export -
/// this is a resilience fallback, not a quality downgrade.
class ClassifierAssetLoader {
  const ClassifierAssetLoader();

  Future<LineItemClassifier> load() async {
    try {
      return await TfliteLineItemClassifier.load();
    } catch (_) {
      return _loadDartReference();
    }
  }

  Future<DartReferenceClassifier> _loadDartReference() async {
    final weightsJson = await rootBundle.loadString(
      'assets/model/weights.json',
    );
    final vocabJson = await rootBundle.loadString('assets/model/vocab.json');
    final categoriesJson = await rootBundle.loadString(
      'assets/model/categories.json',
    );

    return DartReferenceClassifier(
      weights: ClassifierWeights.fromJsonString(weightsJson),
      vocab: ClassifierVocab.fromJsonString(vocabJson),
      categories: ClassifierCategories.fromJsonString(categoriesJson),
    );
  }
}
