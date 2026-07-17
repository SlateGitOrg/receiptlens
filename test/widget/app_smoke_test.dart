import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:receiptlens/data/db/app_database.dart';
import 'package:receiptlens/data/encryption/key_manager.dart';
import 'package:receiptlens/main.dart';
import 'package:receiptlens/presentation/providers/app_providers.dart';

import '../domain/fakes.dart';

/// Boots the real [ReceiptLensApp] widget tree end to end. Every provider
/// that would otherwise touch a platform channel (SQLite file I/O,
/// secure-storage keychain, ML Kit, TFLite) is overridden with an
/// in-memory / fake implementation so the app can mount and be driven by
/// `WidgetTester` with no device, model, or network involved.
void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.inMemory());
  tearDown(() => db.close());

  List<Override> overrides() => [
    appDatabaseProvider.overrideWithValue(db),
    keyManagerProvider.overrideWithValue(InMemoryKeyManager()),
    textRecognizerProvider.overrideWithValue(FakeTextRecognizer()),
    classifierProvider.overrideWith((ref) async => FakeLineItemClassifier()),
  ];

  testWidgets('boots to the receipts tab with an empty state', (tester) async {
    await tester.pumpWidget(
      ProviderScope(overrides: overrides(), child: const ReceiptLensApp()),
    );
    await tester.pumpAndSettle();

    expect(find.text('No receipts yet. Tap Scan to add one.'), findsOneWidget);
    expect(find.text('Receipts'), findsWidgets);
    expect(find.text('Summary'), findsOneWidget);
    expect(find.text('Scan'), findsOneWidget);
  });

  testWidgets('switching to the Summary tab shows the empty-summary state', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(overrides: overrides(), child: const ReceiptLensApp()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Summary'));
    await tester.pumpAndSettle();

    expect(find.text('No receipts yet.'), findsOneWidget);
  });

  testWidgets('tapping Scan opens the capture screen', (tester) async {
    await tester.pumpWidget(
      ProviderScope(overrides: overrides(), child: const ReceiptLensApp()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Scan'));
    // Deliberately bounded pumps (not pumpAndSettle): CaptureScreen kicks
    // off a real `package:camera` platform-channel call in its initState,
    // which never resolves under the host `flutter test` binding (there is
    // no camera plugin implementation registered - by design, this app
    // only mocks the OCR/classifier abstractions, not the camera hardware
    // itself). pumpAndSettle would wait forever on that never-completing
    // future; a few bounded pumps are enough to let the push-route
    // transition finish and assert navigation happened.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Scan Receipt'), findsOneWidget);
  });
}
