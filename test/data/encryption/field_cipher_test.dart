import 'package:flutter_test/flutter_test.dart';
import 'package:receiptlens/data/encryption/field_cipher.dart';
import 'package:receiptlens/data/encryption/key_manager.dart';

void main() {
  late AesGcmFieldCipher cipher;

  setUp(() {
    cipher = AesGcmFieldCipher(keyManager: InMemoryKeyManager());
  });

  test('round-trips plaintext through encrypt/decrypt', () async {
    const plaintext = 'Trader Joe\'s - 42 Main St';
    final ciphertext = await cipher.encrypt(plaintext);

    expect(ciphertext, isNot(equals(plaintext)));
    expect(await cipher.decrypt(ciphertext), plaintext);
  });

  test('ciphertext does not contain the plaintext substring', () async {
    const plaintext = 'CONFIDENTIAL vendor name 12345';
    final ciphertext = await cipher.encrypt(plaintext);
    expect(ciphertext.contains('CONFIDENTIAL'), isFalse);
  });

  test(
    'produces different ciphertext for the same plaintext (random nonce)',
    () async {
      const plaintext = 'Repeated vendor';
      final a = await cipher.encrypt(plaintext);
      final b = await cipher.encrypt(plaintext);

      expect(a, isNot(equals(b)));
      expect(await cipher.decrypt(a), plaintext);
      expect(await cipher.decrypt(b), plaintext);
    },
  );

  test('decrypting an empty ciphertext returns an empty string', () async {
    expect(await cipher.decrypt(''), '');
  });

  test('throws on malformed (too-short) ciphertext', () async {
    expect(() => cipher.decrypt('AA=='), throwsFormatException);
  });

  test(
    'a cipher built with a different key cannot decrypt another\'s data',
    () async {
      final other = AesGcmFieldCipher(keyManager: InMemoryKeyManager());
      final ciphertext = await cipher.encrypt('secret value');

      expect(() => other.decrypt(ciphertext), throwsA(anything));
    },
  );

  test('handles unicode content correctly', () async {
    const plaintext = 'Café Münster — €12,50 total';
    final ciphertext = await cipher.encrypt(plaintext);
    expect(await cipher.decrypt(ciphertext), plaintext);
  });
}
