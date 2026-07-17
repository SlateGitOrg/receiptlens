import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:receiptlens/core/money.dart';
import 'package:receiptlens/data/db/app_database.dart';
import 'package:receiptlens/data/encryption/field_cipher.dart';
import 'package:receiptlens/data/encryption/key_manager.dart';
import 'package:receiptlens/data/repositories/drift_receipt_repository.dart';
import 'package:receiptlens/domain/entities/expense_category.dart';
import 'package:receiptlens/domain/entities/line_item.dart';
import 'package:receiptlens/domain/entities/receipt.dart';
import 'package:receiptlens/presentation/providers/app_providers.dart';
import 'package:receiptlens/presentation/screens/review/review_receipt_screen.dart';

import '../domain/fakes.dart';

/// End-to-end widget coverage of the "capture -> save" tail of the
/// pipeline, with OCR mocked out entirely.
///
/// [ReviewReceiptScreen] is deliberately built with a `debugDraft`
/// injection point (see the widget itself) so this test can start from an
/// already-recognized-and-parsed receipt - exactly what would exist after
/// a real camera capture + on-device OCR + classification run - without
/// needing a camera, an image file, ML Kit, or a TFLite interpreter. What
/// *is* exercised for real: Riverpod wiring, the review/edit UI, and a
/// genuine encrypted round trip through an in-memory Drift database.
void main() {
  late AppDatabase db;
  late DriftReceiptRepository repository;

  setUp(() {
    db = AppDatabase.inMemory();
    repository = DriftReceiptRepository(
      db: db,
      cipher: AesGcmFieldCipher(keyManager: InMemoryKeyManager()),
    );
  });

  tearDown(() => db.close());

  Receipt draftReceipt() {
    final items = [
      const LineItem(
        description: 'Copy paper ream',
        amount: Money(1299),
        category: ExpenseCategory.other,
        confidence: 0.4,
      ),
    ];
    return Receipt(
      vendor: 'Office Depot',
      purchasedAt: DateTime(2024, 3, 15),
      lineItems: items,
      subtotal: const Money(1299),
      tax: Money.zero(),
      total: const Money(1299),
      rawOcrText: 'Office Depot\nCopy paper ream  12.99',
      createdAt: DateTime(2024, 3, 15),
    );
  }

  Widget wrap(Widget child) {
    return ProviderScope(
      overrides: [receiptRepositoryProvider.overrideWithValue(repository)],
      child: MaterialApp(home: child),
    );
  }

  testWidgets('shows the OCR-parsed draft, ready for review', (tester) async {
    await tester.pumpWidget(
      wrap(
        ReviewReceiptScreen(
          imagePath: '/tmp/receipt.jpg',
          debugDraft: draftReceipt(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Office Depot'), findsOneWidget);
    expect(find.text('Copy paper ream'), findsOneWidget);
    expect(find.text(r'$12.99'), findsWidgets);
    expect(find.text('Save Receipt'), findsOneWidget);
  });

  testWidgets('user can correct the predicted category before saving', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        ReviewReceiptScreen(
          imagePath: '/tmp/receipt.jpg',
          debugDraft: draftReceipt(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Other'), findsOneWidget);

    await tester.tap(find.text('Other'));
    await tester.pumpAndSettle();

    expect(find.text('Office Supplies'), findsWidgets);
    await tester.tap(find.text('Office Supplies').last);
    await tester.pumpAndSettle();

    expect(find.text('Office Supplies'), findsOneWidget);
  });

  testWidgets('tapping Save Receipt persists the receipt to the repository', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        Navigator(
          onGenerateRoute: (settings) => MaterialPageRoute(
            builder: (_) => ReviewReceiptScreen(
              imagePath: '/tmp/receipt.jpg',
              debugDraft: draftReceipt(),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(await repository.getAll(), isEmpty);

    await tester.tap(find.text('Save Receipt'));
    await tester.pumpAndSettle();

    final saved = await repository.getAll();
    expect(saved, hasLength(1));
    expect(saved.single.vendor, 'Office Depot');
    expect(saved.single.lineItems.single.amount.cents, 1299);
  });

  testWidgets('shows a retry affordance when the OCR pipeline finds no text', (
    tester,
  ) async {
    // No `debugDraft` here, so this drives the *real* pipeline
    // (ReceiptProcessingPipeline) end to end - but with the
    // text-recognizer/classifier providers swapped for deterministic
    // fakes, so nothing touches ML Kit, TFLite, or a device.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          receiptRepositoryProvider.overrideWithValue(repository),
          textRecognizerProvider.overrideWithValue(
            FakeTextRecognizer(lines: const []),
          ),
          classifierProvider.overrideWith(
            (ref) async => FakeLineItemClassifier(),
          ),
        ],
        child: const MaterialApp(
          home: ReviewReceiptScreen(imagePath: '/tmp/blank.jpg'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Retry'), findsOneWidget);
    expect(find.textContaining('No text detected'), findsOneWidget);
  });
}
