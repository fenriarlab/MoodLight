import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as enc;

class EncryptionHelper {
  static const int _iterations = 10000;
  static const int _keyLength = 32; // 256 bits

  /// Derive a 256-bit AES Key from password and salt using PBKDF2-HMAC-SHA256
  static Uint8List _deriveKey(String password, Uint8List salt) {
    final passwordBytes = utf8.encode(password);

    // Initial HMAC-SHA256 block U_1
    final hmac = Hmac(sha256, passwordBytes);
    Uint8List derivedKey = Uint8List(_keyLength);

    // Single 32-byte block for 256-bit key
    Uint8List blockInput = Uint8List(salt.length + 4);
    blockInput.setRange(0, salt.length, salt);
    blockInput[salt.length] = 0;
    blockInput[salt.length + 1] = 0;
    blockInput[salt.length + 2] = 0;
    blockInput[salt.length + 3] = 1;

    Uint8List u = Uint8List.fromList(hmac.convert(blockInput).bytes);
    Uint8List result = Uint8List.fromList(u);

    for (int i = 1; i < _iterations; i++) {
      u = Uint8List.fromList(hmac.convert(u).bytes);
      for (int j = 0; j < result.length; j++) {
        result[j] ^= u[j];
      }
    }

    derivedKey.setRange(0, _keyLength, result);
    return derivedKey;
  }

  /// Encrypt plain JSON payload using AES-256-CBC with user password
  static String encryptPayload(
    String plainJson,
    String password, {
    required int totalCount,
    String appVersion = '1.0.0+1',
  }) {
    final random = Random.secure();

    // 16-byte Salt & 16-byte IV
    final salt = Uint8List.fromList(List<int>.generate(16, (_) => random.nextInt(256)));
    final ivBytes = Uint8List.fromList(List<int>.generate(16, (_) => random.nextInt(256)));

    final derivedKeyBytes = _deriveKey(password, salt);
    final key = enc.Key(derivedKeyBytes);
    final iv = enc.IV(ivBytes);

    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
    final encrypted = encrypter.encrypt(plainJson, iv: iv);

    final envelope = {
      'schema_version': 2,
      'app_name': 'MoodLight',
      'app_version': appVersion,
      'is_encrypted': true,
      'exported_at': DateTime.now().toIso8601String(),
      'total_count': totalCount,
      'crypto_meta': {
        'algorithm': 'AES-256-CBC',
        'kdf': 'PBKDF2WithHmacSHA256',
        'iterations': _iterations,
        'salt_hex': salt.map((b) => b.toRadixString(16).padLeft(2, '0')).join(),
        'iv_hex': ivBytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join(),
      },
      'ciphertext_base64': encrypted.base64,
    };

    return const JsonEncoder.withIndent('  ').convert(envelope);
  }

  /// Decrypt ciphertext envelope using user password
  static String decryptPayload(String envelopeJsonString, String password) {
    final Map<String, dynamic> envelope = jsonDecode(envelopeJsonString);

    if (envelope['is_encrypted'] != true) {
      throw FormatException('This backup file is not encrypted.');
    }

    final cryptoMeta = envelope['crypto_meta'] as Map<String, dynamic>;
    final saltHex = cryptoMeta['salt_hex'] as String;
    final ivHex = cryptoMeta['iv_hex'] as String;
    final ciphertextBase64 = envelope['ciphertext_base64'] as String;

    final salt = Uint8List.fromList(
      List.generate(saltHex.length ~/ 2, (i) => int.parse(saltHex.substring(i * 2, i * 2 + 2), radix: 16)),
    );
    final ivBytes = Uint8List.fromList(
      List.generate(ivHex.length ~/ 2, (i) => int.parse(ivHex.substring(i * 2, i * 2 + 2), radix: 16)),
    );

    final derivedKeyBytes = _deriveKey(password, salt);
    final key = enc.Key(derivedKeyBytes);
    final iv = enc.IV(ivBytes);

    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
    final decrypted = encrypter.decrypt64(ciphertextBase64, iv: iv);

    return decrypted;
  }
}
