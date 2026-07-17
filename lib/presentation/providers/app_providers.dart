import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:receiptlens/data/db/app_database.dart';
import 'package:receiptlens/data/encryption/field_cipher.dart';
import 'package:receiptlens/data/encryption/key_manager.dart';
import 'package:receiptlens/data/encryption/secure_storage_key_manager.dart';
import 'package:receiptlens/data/repositories/drift_receipt_repository.dart';
import 'package:receiptlens/data/repositories/receipt_repository.dart';
import 'package:receiptlens/domain/classification/line_item_classifier.dart';
import 'package:receiptlens/domain/entities/receipt.dart';
import 'package:receiptlens/domain/export/monthly_summary_calculator.dart';
import 'package:receiptlens/domain/ocr/text_recognizer.dart';
import 'package:receiptlens/domain/receipt_processing_pipeline.dart';
import 'package:receiptlens/services/classification/classifier_asset_loader.dart';
import 'package:receiptlens/services/image/receipt_image_processor.dart';
import 'package:receiptlens/services/ocr/mlkit_text_recognizer.dart';

/// The Drift database instance. Overridden in tests with
/// `AppDatabase.inMemory()`.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase.open();
  ref.onDispose(db.close);
  return db;
});

final keyManagerProvider = Provider<KeyManager>((ref) {
  return SecureStorageKeyManager();
});

final fieldCipherProvider = Provider<FieldCipher>((ref) {
  return AesGcmFieldCipher(keyManager: ref.watch(keyManagerProvider));
});

final receiptRepositoryProvider = Provider<ReceiptRepository>((ref) {
  return DriftReceiptRepository(
    db: ref.watch(appDatabaseProvider),
    cipher: ref.watch(fieldCipherProvider),
  );
});

final textRecognizerProvider = Provider<TextRecognizer>((ref) {
  final recognizer = MlKitTextRecognizer();
  ref.onDispose(recognizer.close);
  return recognizer;
});

/// Async because loading the TFLite model / JSON assets requires
/// awaiting `rootBundle`.
final classifierProvider = FutureProvider<LineItemClassifier>((ref) async {
  final classifier = await const ClassifierAssetLoader().load();
  ref.onDispose(() {
    // ignore: discarded_futures
    classifier.close();
  });
  return classifier;
});

final imageProcessorProvider = Provider<ReceiptImageProcessor>((ref) {
  return const ReceiptImageProcessor();
});

final monthlySummaryCalculatorProvider = Provider<MonthlySummaryCalculator>((
  ref,
) {
  return const MonthlySummaryCalculator();
});

final receiptProcessingPipelineProvider =
    FutureProvider<ReceiptProcessingPipeline>((ref) async {
      final classifier = await ref.watch(classifierProvider.future);
      return ReceiptProcessingPipeline(
        textRecognizer: ref.watch(textRecognizerProvider),
        classifier: classifier,
      );
    });

/// All saved receipts, refreshed whenever [receiptsRefreshProvider] is
/// invalidated (e.g. after a save/delete).
final allReceiptsProvider = FutureProvider<List<Receipt>>((ref) async {
  ref.watch(receiptsRefreshProvider);
  final repo = ref.watch(receiptRepositoryProvider);
  return repo.getAll();
});

/// A simple ticking counter used purely to invalidate [allReceiptsProvider]
/// after mutations, since Drift's reactive streams are overkill for this
/// app's scale.
final receiptsRefreshProvider = StateProvider<int>((ref) => 0);
