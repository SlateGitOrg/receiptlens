import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart'
    as mlkit;

import 'package:receiptlens/domain/ocr/recognized_text.dart';
import 'package:receiptlens/domain/ocr/text_recognizer.dart';

/// Production [TextRecognizer]: Google ML Kit's on-device text recognizer.
/// This runs entirely on-device via the bundled ML Kit model - the image
/// bytes never leave the phone and no HTTP request is made, which is the
/// core privacy guarantee of the app.
class MlKitTextRecognizer implements TextRecognizer {
  MlKitTextRecognizer() : _recognizer = mlkit.TextRecognizer();

  final mlkit.TextRecognizer _recognizer;

  @override
  Future<RecognizedText> recognizeImage(String imagePath) async {
    final input = mlkit.InputImage.fromFilePath(imagePath);
    final result = await _recognizer.processImage(input);

    final lines = <RecognizedTextLine>[];
    for (final block in result.blocks) {
      for (final line in block.lines) {
        lines.add(RecognizedTextLine(text: line.text, confidence: 1.0));
      }
    }
    return RecognizedText(lines: lines);
  }

  @override
  Future<void> close() => _recognizer.close();
}
