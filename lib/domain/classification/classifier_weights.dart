import 'dart:convert';

/// Parsed representation of the trained model's weights, exactly as
/// exported by `tool/ml/train_classifier.py` into
/// `assets/model/weights.json`. Kept free of any Flutter/asset-bundle
/// dependency so it's trivial to construct in unit tests from a fixture
/// string.
class ClassifierWeights {
  const ClassifierWeights({
    required this.vocabSize,
    required this.hiddenUnits,
    required this.numCategories,
    required this.w1,
    required this.b1,
    required this.w2,
    required this.b2,
  });

  factory ClassifierWeights.fromJsonString(String jsonStr) {
    final map = jsonDecode(jsonStr) as Map<String, dynamic>;
    return ClassifierWeights(
      vocabSize: map['vocabSize'] as int,
      hiddenUnits: map['hiddenUnits'] as int,
      numCategories: map['numCategories'] as int,
      w1: _matrix(map['w1']),
      b1: _vector(map['b1']),
      w2: _matrix(map['w2']),
      b2: _vector(map['b2']),
    );
  }

  /// [hiddenUnits][vocabSize]
  final int vocabSize;
  final int hiddenUnits;
  final int numCategories;
  final List<List<double>> w1;
  final List<double> b1;

  /// [numCategories][hiddenUnits]
  final List<List<double>> w2;
  final List<double> b2;

  static List<List<double>> _matrix(dynamic raw) {
    return (raw as List)
        .map((row) => (row as List).map((v) => (v as num).toDouble()).toList())
        .toList();
  }

  static List<double> _vector(dynamic raw) {
    return (raw as List).map((v) => (v as num).toDouble()).toList();
  }
}

class ClassifierVocab {
  const ClassifierVocab({required this.tokens});

  factory ClassifierVocab.fromJsonString(String jsonStr) {
    final map = jsonDecode(jsonStr) as Map<String, dynamic>;
    return ClassifierVocab(tokens: (map['tokens'] as List).cast<String>());
  }

  final List<String> tokens;
}

class ClassifierCategories {
  const ClassifierCategories({required this.ids});

  factory ClassifierCategories.fromJsonString(String jsonStr) {
    final map = jsonDecode(jsonStr) as Map<String, dynamic>;
    return ClassifierCategories(
      ids: (map['categories'] as List).cast<String>(),
    );
  }

  final List<String> ids;
}
