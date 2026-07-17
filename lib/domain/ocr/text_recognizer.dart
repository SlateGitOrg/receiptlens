import 'package:receiptlens/domain/ocr/recognized_text.dart';

/// Abstraction over an on-device OCR engine.
///
/// The production implementation (`MlKitTextRecognizer` in
/// lib/services/ocr) wraps `google_mlkit_text_recognition` - which never
/// makes a network call, satisfying the "no third-party cloud OCR" goal.
/// Tests use a fake implementation so the parsing/classification pipeline
/// can be exercised deterministically without a camera or device.
abstract interface class TextRecognizer {
  Future<RecognizedText> recognizeImage(String imagePath);

  /// Releases any native resources held by the recognizer.
  Future<void> close();
}
