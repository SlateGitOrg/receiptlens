import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:receiptlens/domain/classification/classifier_weights.dart';
import 'package:receiptlens/domain/classification/dart_reference_classifier.dart';
import 'package:receiptlens/domain/entities/expense_category.dart';

/// Exercises [DartReferenceClassifier] against the *real* trained model
/// assets shipped with the app (assets/model/*.json), not a hand-rolled
/// fixture. This is the same forward pass the production TFLite path
/// runs, re-implemented in pure Dart specifically so it's exercisable
/// here: no native TFLite interpreter, no device, no network - just the
/// bundled JSON weight export loaded through Flutter's test asset
/// bundle.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DartReferenceClassifier classifier;

  setUpAll(() async {
    final weightsJson = await rootBundle.loadString(
      'assets/model/weights.json',
    );
    final vocabJson = await rootBundle.loadString('assets/model/vocab.json');
    final categoriesJson = await rootBundle.loadString(
      'assets/model/categories.json',
    );

    classifier = DartReferenceClassifier(
      weights: ClassifierWeights.fromJsonString(weightsJson),
      vocab: ClassifierVocab.fromJsonString(vocabJson),
      categories: ClassifierCategories.fromJsonString(categoriesJson),
    );
  });

  tearDownAll(() => classifier.close());

  test('classifies an office-supplies line item correctly', () async {
    final prediction = await classifier.classify('staples copy paper ream');
    expect(prediction.category, ExpenseCategory.officeSupplies);
    expect(prediction.confidence, greaterThan(0.5));
  });

  test('classifies a meals & entertainment line item correctly', () async {
    final prediction = await classifier.classify(
      'starbucks coffee grande latte',
    );
    expect(prediction.category, ExpenseCategory.mealsEntertainment);
  });

  test('classifies a software subscription line item correctly', () async {
    final prediction = await classifier.classify(
      'adobe creative cloud subscription',
    );
    expect(prediction.category, ExpenseCategory.softwareSubscriptions);
  });

  test('classifies a travel line item correctly', () async {
    final prediction = await classifier.classify(
      'delta airlines flight ticket',
    );
    expect(prediction.category, ExpenseCategory.travel);
  });

  test('classifies an equipment & hardware line item correctly', () async {
    final prediction = await classifier.classify(
      'dell laptop computer purchase',
    );
    expect(prediction.category, ExpenseCategory.equipmentHardware);
  });

  test('confidence is always a valid probability', () async {
    final prediction = await classifier.classify(
      'completely unrelated gibberish text',
    );
    expect(prediction.confidence, inInclusiveRange(0.0, 1.0));
  });

  test('is deterministic for the same input', () async {
    final a = await classifier.classify('microsoft 365 monthly plan');
    final b = await classifier.classify('microsoft 365 monthly plan');
    expect(a.category, b.category);
    expect(a.confidence, closeTo(b.confidence, 1e-12));
  });
}
