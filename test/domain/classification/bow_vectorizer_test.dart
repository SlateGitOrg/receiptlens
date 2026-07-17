import 'package:flutter_test/flutter_test.dart';
import 'package:receiptlens/domain/classification/bow_vectorizer.dart';

void main() {
  const vocab = ['coffee', 'latte', 'flight', 'hotel'];
  const vectorizer = BagOfWordsVectorizer(vocabulary: vocab);

  group('tokenize', () {
    test('lowercases and splits on non-alphanumeric characters', () {
      expect(vectorizer.tokenize('Starbucks Coffee, Grande Latte!'), [
        'starbucks',
        'coffee',
        'grande',
        'latte',
      ]);
    });

    test('keeps digits as part of tokens', () {
      expect(vectorizer.tokenize('Room 204 - Hotel stay'), [
        'room',
        '204',
        'hotel',
        'stay',
      ]);
    });

    test('returns an empty list for text with no tokens', () {
      expect(vectorizer.tokenize('---***'), isEmpty);
    });
  });

  group('vectorize', () {
    test('produces a vector the same length as the vocabulary', () {
      final vec = vectorizer.vectorize('coffee latte');
      expect(vec, hasLength(vocab.length));
    });

    test('ignores out-of-vocabulary tokens', () {
      final vec = vectorizer.vectorize('mystery unknown words only');
      expect(vec.every((v) => v == 0), isTrue);
    });

    test('L1-normalizes term frequencies so they sum to 1.0', () {
      final vec = vectorizer.vectorize('coffee coffee latte flight');
      final sum = vec.fold(0.0, (a, b) => a + b);
      expect(sum, closeTo(1.0, 1e-9));
      // coffee appears twice out of 4 recognized tokens -> weight 0.5
      expect(vec[vocab.indexOf('coffee')], closeTo(0.5, 1e-9));
      expect(vec[vocab.indexOf('latte')], closeTo(0.25, 1e-9));
      expect(vec[vocab.indexOf('flight')], closeTo(0.25, 1e-9));
      expect(vec[vocab.indexOf('hotel')], 0.0);
    });

    test('returns an all-zero vector for empty input', () {
      final vec = vectorizer.vectorize('');
      expect(vec.every((v) => v == 0), isTrue);
    });
  });
}
