import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// A normalized rectangle expressed as fractions (0.0-1.0) of the source
/// image's width/height, exactly what the crop-overlay UI produces when
/// the user drags the four corner handles over the camera preview.
class CropRect {
  const CropRect({
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
  });

  final double left;
  final double top;
  final double right;
  final double bottom;

  bool get isValid =>
      left >= 0 &&
      top >= 0 &&
      right <= 1 &&
      bottom <= 1 &&
      right > left &&
      bottom > top;
}

/// Crops and normalizes a captured receipt photo before it's handed to
/// the OCR pipeline. This is real pixel manipulation (not just a UI
/// affordance): cropping to the user-selected region measurably improves
/// OCR accuracy by removing background clutter, and normalizing to
/// grayscale + boosted contrast helps the text recognizer on low-light
/// photos.
class ReceiptImageProcessor {
  const ReceiptImageProcessor();

  /// Crops [bytes] (any format `package:image` can decode - JPEG/PNG) to
  /// [crop] and applies a grayscale + contrast pass tuned for printed
  /// receipt text. Returns re-encoded JPEG bytes.
  Uint8List cropAndNormalize(Uint8List bytes, CropRect crop) {
    if (!crop.isValid) {
      throw ArgumentError.value(crop, 'crop', 'Crop rectangle is invalid');
    }

    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      throw const FormatException('Unable to decode image bytes');
    }

    final x = (crop.left * decoded.width).round().clamp(0, decoded.width - 1);
    final y = (crop.top * decoded.height).round().clamp(0, decoded.height - 1);
    final width = ((crop.right - crop.left) * decoded.width).round().clamp(
      1,
      decoded.width - x,
    );
    final height = ((crop.bottom - crop.top) * decoded.height).round().clamp(
      1,
      decoded.height - y,
    );

    var cropped = img.copyCrop(
      decoded,
      x: x,
      y: y,
      width: width,
      height: height,
    );
    cropped = img.grayscale(cropped);
    cropped = img.adjustColor(cropped, contrast: 1.25, brightness: 1.05);

    return Uint8List.fromList(img.encodeJpg(cropped, quality: 92));
  }

  /// Dimensions the crop would produce for [imageWidth] x [imageHeight],
  /// useful for the review UI to display an accurate preview size without
  /// re-decoding the full image.
  (int width, int height) resolvedSize(
    int imageWidth,
    int imageHeight,
    CropRect crop,
  ) {
    final width = ((crop.right - crop.left) * imageWidth).round();
    final height = ((crop.bottom - crop.top) * imageHeight).round();
    return (width.clamp(1, imageWidth), height.clamp(1, imageHeight));
  }
}
