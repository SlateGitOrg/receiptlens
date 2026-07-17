import 'package:flutter_test/flutter_test.dart';
import 'package:receiptlens/core/result.dart';

void main() {
  group('Result', () {
    test('Ok exposes isOk/isErr correctly', () {
      const result = Result<int>.ok(42);
      expect(result.isOk, isTrue);
      expect(result.isErr, isFalse);
      expect(result.valueOrThrow, 42);
    });

    test('Err exposes isOk/isErr correctly and throws on valueOrThrow', () {
      const result = Result<int>.err('boom');
      expect(result.isOk, isFalse);
      expect(result.isErr, isTrue);
      expect(() => result.valueOrThrow, throwsStateError);
    });

    test('when() dispatches to the matching branch', () {
      const ok = Result<int>.ok(1);
      const err = Result<int>.err('bad');

      expect(ok.when(ok: (v) => 'ok:$v', err: (m) => 'err:$m'), 'ok:1');
      expect(err.when(ok: (v) => 'ok:$v', err: (m) => 'err:$m'), 'err:bad');
    });

    test('map() transforms an Ok value and leaves Err untouched', () {
      const ok = Result<int>.ok(2);
      const err = Result<int>.err('bad');

      final mappedOk = ok.map((v) => v * 10);
      final mappedErr = err.map((v) => v * 10);

      expect(mappedOk.valueOrThrow, 20);
      expect(mappedErr.isErr, isTrue);
      expect(() => mappedErr.valueOrThrow, throwsStateError);
    });
  });
}
