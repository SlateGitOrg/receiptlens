import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:receiptlens/data/encryption/key_manager.dart';

/// Production [KeyManager]: the AES key lives in the platform keychain
/// (iOS Keychain / Android Keystore-backed EncryptedSharedPreferences) via
/// `flutter_secure_storage`, never in application-readable plaintext
/// storage and never transmitted anywhere.
class SecureStorageKeyManager implements KeyManager {
  SecureStorageKeyManager({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _keyName = 'receiptlens.db_encryption_key_v1';

  final FlutterSecureStorage _storage;

  @override
  Future<List<int>> getOrCreateKey() async {
    final existing = await _storage.read(key: _keyName);
    if (existing != null) {
      return KeyManagerCodec.decode(existing);
    }

    final random = Random.secure();
    final generated = List<int>.generate(32, (_) => random.nextInt(256));
    await _storage.write(
      key: _keyName,
      value: KeyManagerCodec.encode(generated),
    );
    return generated;
  }
}
