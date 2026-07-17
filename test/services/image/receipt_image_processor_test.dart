import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:receiptlens/services/image/receipt_image_processor.dart';

/// Builds a synthetic in-memory JPEG so this suite never needs a real
/// camera photo or device - `package:image` does plain pixel manipulation
/// with no platform dependency.
Uint8List _syntheticJpeg({int width = 200, int height = 300}) {
  final image = img.Image(width: width, height: height);
  img.fill(image, color: img.ColorRgb8(180, 40, 40));
  return Uint8List.fromList(img.encodeJpg(image));
}

void main() {
  const processor = ReceiptImageProcessor();

  group('CropRect', () {
    test('isValid is true for a well-formed rectangle', () {
      const rect = CropRect(left: 0.1, top: 0.1, right: 0.9, bottom: 0.9);
      expect(rect.isValid, isTrue);
    });

    test('isValid is false when right <= left or bottom <= top', () {
      expect(
        const CropRect(left: 0.5, top: 0.1, right: 0.4, bottom: 0.9).isValid,
        isFalse,
      );
      expect(
        const CropRect(left: 0.1, top: 0.5, right: 0.9, bottom: 0.4).isValid,
        isFalse,
      );
    });

    test('isValid is false when outside the [0, 1] range', () {
      expect(
        const CropRect(left: -0.1, top: 0.0, right: 0.9, bottom: 0.9).isValid,
        isFalse,
      );
      expect(
        const CropRect(left: 0.0, top: 0.0, right: 1.1, bottom: 0.9).isValid,
        isFalse,
      );
    });
  });

  group('cropAndNormalize', () {
    test('produces a smaller, still-decodable JPEG for a partial crop', () {
      final source = _syntheticJpeg(width: 400, height: 600);
      const crop = CropRect(left: 0.25, top: 0.25, right: 0.75, bottom: 0.75);

      final result = processor.cropAndNormalize(source, crop);
      final decoded = img.decodeImage(result);

      expect(decoded, isNotNull);
      expect(decoded!.width, 200);
      expect(decoded.height, 300);
    });

    test('throws ArgumentError for an invalid crop rectangle', () {
      final source = _syntheticJpeg();
      const invalidCrop = CropRect(
        left: 0.9,
        top: 0.1,
        right: 0.1,
        bottom: 0.9,
      );

      expect(
        () => processor.cropAndNormalize(source, invalidCrop),
        throwsArgumentError,
      );
    });

    test('throws FormatException for undecodable bytes', () {
      // A longer, clearly-non-image buffer: long enough that no format
      // sniffer over/under-reads its header, and containing no magic
      // byte sequence (PNG/JPEG/GIF/BMP/etc signature) that would cause
      // any decoder to misidentify it.
      const text = 'not an image, just plain text padding for length';
      final garbage = Uint8List.fromList(
        List.generate(256, (i) => text.codeUnitAt(i % text.length)),
      );
      const crop = CropRect(left: 0.0, top: 0.0, right: 1.0, bottom: 1.0);

      expect(
        () => processor.cropAndNormalize(garbage, crop),
        throwsFormatException,
      );
    });

    test('a full-frame crop keeps the original dimensions', () {
      final source = _syntheticJpeg(width: 100, height: 150);
      const fullCrop = CropRect(left: 0.0, top: 0.0, right: 1.0, bottom: 1.0);

      final decoded = img.decodeImage(
        processor.cropAndNormalize(source, fullCrop),
      );

      expect(decoded!.width, 100);
      expect(decoded.height, 150);
    });
  });

  group('resolvedSize', () {
    test('computes the pixel dimensions a crop would produce', () {
      final size = processor.resolvedSize(
        1000,
        2000,
        const CropRect(left: 0.1, top: 0.2, right: 0.9, bottom: 0.8),
      );

      expect(size.$1, 800);
      expect(size.$2, 1200);
    });

    test('clamps to at least 1px and at most the source dimensions', () {
      final size = processor.resolvedSize(
        100,
        100,
        const CropRect(left: 0.499, top: 0.499, right: 0.501, bottom: 0.501),
      );

      expect(size.$1, greaterThanOrEqualTo(1));
      expect(size.$2, greaterThanOrEqualTo(1));
    });
  });
}
