/// A platform-agnostic representation of OCR output.
///
/// Concrete recognizers (ML Kit on-device, or a fake for tests) produce
/// this type so the rest of the domain layer never depends on any
/// ML-Kit-specific classes - which keeps the parsing/classification logic
/// trivially unit-testable without a device or platform channel.
class RecognizedText {
  const RecognizedText({required this.lines});

  factory RecognizedText.fromRawLines(List<String> rawLines) {
    return RecognizedText(
      lines: rawLines
          .map((l) => l.trim())
          .where((l) => l.isNotEmpty)
          .map((l) => RecognizedTextLine(text: l))
          .toList(growable: false),
    );
  }

  final List<RecognizedTextLine> lines;

  String get fullText => lines.map((l) => l.text).join('\n');

  bool get isEmpty => lines.isEmpty;
}

class RecognizedTextLine {
  const RecognizedTextLine({required this.text, this.confidence = 1.0});

  final String text;
  final double confidence;
}
