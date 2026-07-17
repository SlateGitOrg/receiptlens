import 'dart:convert';
import 'dart:math';

/// Supplies the symmetric key used to encrypt receipt data at rest.
///
/// Kept as an interface so tests can inject a deterministic in-memory key
/// without touching the platform keychain/keystore.
abstract interface class KeyManager {
  /// Returns the 32-byte (256-bit) AES key, generating and persisting one
  /// on first use.
  Future<List<int>> getOrCreateKey();
}

/// Test/dev double: holds the key in memory only. Never use in production
/// - the key would be lost (and all encrypted data with it) on restart.
class InMemoryKeyManager implements KeyManager {
  InMemoryKeyManager({List<int>? fixedKey}) : _key = fixedKey;

  List<int>? _key;

  @override
  Future<List<int>> getOrCreateKey() async {
    final existing = _key;
    if (existing != null) return existing;
    final random = Random.secure();
    final generated = List<int>.generate(32, (_) => random.nextInt(256));
    _key = generated;
    return generated;
  }
}

/// Base64 helpers shared by [KeyManager] implementations.
class KeyManagerCodec {
  static String encode(List<int> key) => base64Encode(key);
  static List<int> decode(String encoded) => base64Decode(encoded);
}
