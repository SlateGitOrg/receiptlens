import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import 'package:receiptlens/presentation/providers/app_providers.dart';
import 'package:receiptlens/presentation/screens/review/review_receipt_screen.dart';
import 'package:receiptlens/services/image/receipt_image_processor.dart';

/// Lets the user drag a rectangle over the captured photo to crop out
/// everything but the receipt itself before OCR runs. Cropping first
/// measurably improves recognition accuracy and keeps unrelated
/// background content out of the stored image.
class CropScreen extends ConsumerStatefulWidget {
  const CropScreen({super.key, required this.imagePath});

  final String imagePath;

  @override
  ConsumerState<CropScreen> createState() => _CropScreenState();
}

class _CropScreenState extends ConsumerState<CropScreen> {
  // Normalized (0-1) corner offsets, initialized to a generous inset so
  // there's already a sane default crop before the user touches anything.
  Offset _topLeft = const Offset(0.06, 0.06);
  Offset _bottomRight = const Offset(0.94, 0.94);
  bool _processing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crop Receipt')),
      body: Column(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final size = Size(constraints.maxWidth, constraints.maxHeight);
                return Stack(
                  children: [
                    Positioned.fill(
                      child: Image.file(
                        File(widget.imagePath),
                        fit: BoxFit.contain,
                      ),
                    ),
                    Positioned.fill(
                      child: GestureDetector(
                        onPanUpdate: (details) =>
                            _dragNearestCorner(details, size),
                        child: CustomPaint(
                          painter: _CropOverlayPainter(
                            topLeft: _topLeft,
                            bottomRight: _bottomRight,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton.icon(
                onPressed: _processing ? null : _usePhoto,
                icon: _processing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check),
                label: const Text('Use Photo'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _dragNearestCorner(DragUpdateDetails details, Size size) {
    final local = details.localPosition;
    final normalized = Offset(
      (local.dx / size.width).clamp(0.0, 1.0),
      (local.dy / size.height).clamp(0.0, 1.0),
    );

    final distToTopLeft = (normalized - _topLeft).distanceSquared;
    final distToBottomRight = (normalized - _bottomRight).distanceSquared;

    setState(() {
      if (distToTopLeft <= distToBottomRight) {
        _topLeft = Offset(
          normalized.dx.clamp(0.0, _bottomRight.dx - 0.05),
          normalized.dy.clamp(0.0, _bottomRight.dy - 0.05),
        );
      } else {
        _bottomRight = Offset(
          normalized.dx.clamp(_topLeft.dx + 0.05, 1.0),
          normalized.dy.clamp(_topLeft.dy + 0.05, 1.0),
        );
      }
    });
  }

  Future<void> _usePhoto() async {
    setState(() => _processing = true);
    try {
      final bytes = await File(widget.imagePath).readAsBytes();
      final processor = ref.read(imageProcessorProvider);
      final cropped = processor.cropAndNormalize(
        bytes,
        CropRect(
          left: _topLeft.dx,
          top: _topLeft.dy,
          right: _bottomRight.dx,
          bottom: _bottomRight.dy,
        ),
      );

      final dir = await getApplicationDocumentsDirectory();
      final fileName = 'receipt_${DateTime.now().microsecondsSinceEpoch}.jpg';
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(cropped);

      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ReviewReceiptScreen(imagePath: file.path),
        ),
      );
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }
}

class _CropOverlayPainter extends CustomPainter {
  _CropOverlayPainter({required this.topLeft, required this.bottomRight});

  final Offset topLeft;
  final Offset bottomRight;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTRB(
      topLeft.dx * size.width,
      topLeft.dy * size.height,
      bottomRight.dx * size.width,
      bottomRight.dy * size.height,
    );

    final scrim = Paint()..color = Colors.black.withValues(alpha: 0.5);
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRect(rect)
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, scrim);

    final border = Paint()
      ..color = Colors.amberAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRect(rect, border);

    final handlePaint = Paint()..color = Colors.amberAccent;
    for (final corner in [rect.topLeft, rect.bottomRight]) {
      canvas.drawCircle(corner, 8, handlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CropOverlayPainter oldDelegate) {
    return oldDelegate.topLeft != topLeft ||
        oldDelegate.bottomRight != bottomRight;
  }
}
