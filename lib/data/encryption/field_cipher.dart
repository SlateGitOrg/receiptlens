import 'dart:convert';

import 'package:cryptography/cryptography.dart';

import 'package:receiptlens/data/encryption/key_manager.dart';

/// Encrypts/decrypts individual sensitive string fields (raw OCR text,
/// vendor names, etc.) before they touch SQLite, using AES-256-GCM.
///
/// This is what makes "fully local encrypted storage" true even though
/// the underlying Drift/SQLite file itself is not full-disk-encrypted:
/// every sensitive value is ciphertext at the byte level inside the
/// database file, and the key never leaves the device or crosses a
/// network boundary.
abstract interface class FieldCipher {
  Future<String> encrypt(String plaintext);
  Future<String> decrypt(String ciphertext);
}

class AesGcmFieldCipher implements FieldCipher {
  AesGcmFieldCipher({required KeyManager keyManager})
    : _keyManager = keyManager,
      _algorithm = AesGcm.with256bits();

  final KeyManager _keyManager;
  final AesGcm _algorithm;

  @override
  Future<String> encrypt(String plaintext) async {
    final keyBytes = await _keyManager.getOrCreateKey();
    final secretKey = SecretKey(keyBytes);

    final secretBox = await _algorithm.encrypt(
      utf8.encode(plaintext),
      secretKey: secretKey,
    );

    // Pack nonce + ciphertext + mac into one base64 string for storage.
    final packed = <int>[
      ...secretBox.nonce,
      ...secretBox.cipherText,
      ...secretBox.mac.bytes,
    ];
    return base64Encode(packed);
  }

  @override
  Future<String> decrypt(String ciphertext) async {
    if (ciphertext.isEmpty) return '';

    final keyBytes = await _keyManager.getOrCreateKey();
    final secretKey = SecretKey(keyBytes);

    final packed = base64Decode(ciphertext);
    const nonceLength = 12; // AES-GCM standard nonce size
    const macLength = 16; // AES-GCM tag size

    if (packed.length < nonceLength + macLength) {
      throw const FormatException('Ciphertext too short to be valid');
    }

    final nonce = packed.sublist(0, nonceLength);
    final mac = packed.sublist(packed.length - macLength);
    final cipherBytes = packed.sublist(nonceLength, packed.length - macLength);

    final secretBox = SecretBox(cipherBytes, nonce: nonce, mac: Mac(mac));
    final clearBytes = await _algorithm.decrypt(
      secretBox,
      secretKey: secretKey,
    );
    return utf8.decode(clearBytes);
  }
}
