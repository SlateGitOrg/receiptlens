/// A bag-of-words tokenizer + vectorizer that exactly mirrors the
/// preprocessing done in `tool/ml/train_classifier.py` at training time
/// (see `tokenize` / `vectorize` in that script). Keeping the two in
/// lockstep is what lets [DartReferenceClassifier] reproduce the trained
/// TFLite model's predictions bit-for-bit.
class BagOfWordsVectorizer {
  const BagOfWordsVectorizer({required this.vocabulary});

  /// Ordered vocabulary tokens; index in this list == feature index.
  final List<String> vocabulary;

  static final RegExp _tokenPattern = RegExp(r'[a-z0-9]+');

  List<String> tokenize(String text) {
    return _tokenPattern
        .allMatches(text.toLowerCase())
        .map((m) => m[0]!)
        .toList();
  }

  /// Produces an L1-normalized term-frequency vector over [vocabulary].
  /// Tokens not present in the vocabulary are ignored (out-of-vocabulary),
  /// matching the training-time behavior exactly.
  List<double> vectorize(String text) {
    final vec = List<double>.filled(vocabulary.length, 0.0);
    final tokens = tokenize(text);
    if (tokens.isEmpty) return vec;

    final indexOf = <String, int>{
      for (var i = 0; i < vocabulary.length; i++) vocabulary[i]: i,
    };

    for (final tok in tokens) {
      final idx = indexOf[tok];
      if (idx != null) vec[idx] += 1.0;
    }

    final total = vec.fold(0.0, (a, b) => a + b);
    if (total > 0) {
      for (var i = 0; i < vec.length; i++) {
        vec[i] /= total;
      }
    }
    return vec;
  }
}
