// lib/utils/crypto_utils.dart

import 'dart:convert';
import 'dart:typed_data';

import 'package:pointycastle/api.dart';
import 'package:pointycastle/asymmetric/pkcs1.dart';
import 'package:pointycastle/asymmetric/rsa.dart';
import 'package:pointycastle/block/aes.dart';
import 'package:pointycastle/block/modes/gcm.dart';
import 'package:pointycastle/digests/sha256.dart';
import 'package:pointycastle/key_derivators/pbkdf2.dart';
import 'package:pointycastle/key_generators/rsa_key_generator.dart';
import 'package:pointycastle/macs/hmac.dart';
import 'package:pointycastle/pointycastle.dart';
import 'package:pointycastle/random/fortuna_random.dart';

/// Generate RSA Key Pair (public + private).
AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> generateRSAKeyPair({int bitLength = 2048}) {
  final secureRandom = FortunaRandom();
  secureRandom.seed(KeyParameter(
    Uint8List.fromList(
      List.generate(32, (_) => DateTime.now().millisecondsSinceEpoch % 256),
    ),
  ));

  final keyGen = RSAKeyGenerator()
    ..init(ParametersWithRandom(
      RSAKeyGeneratorParameters(BigInt.parse("65537"), bitLength, 64),
      secureRandom,
    ));

  final pair = keyGen.generateKeyPair();
  return AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey>(
    pair.publicKey as RSAPublicKey,
    pair.privateKey as RSAPrivateKey,
  );
}

/// Derive a symmetric key from a passphrase using PBKDF2(HMAC-SHA256).
Uint8List deriveKey(String passphrase,
    {int iterations = 10000, int keyLength = 32, Uint8List? salt}) {
  salt ??= Uint8List.fromList(utf8.encode("default_salt"));
  final derivator = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64));
  derivator.init(Pbkdf2Parameters(salt, iterations, keyLength));
  return derivator.process(Uint8List.fromList(utf8.encode(passphrase)));
}

/// Encrypt a private key (PEM or string) with passphrase using AES-GCM.
Map<String, dynamic> encryptPrivateKey(String privateKeyPem, String passphrase) {
  final key = deriveKey(passphrase);
  final secureRandom = FortunaRandom();
  secureRandom.seed(KeyParameter(Uint8List.fromList(
    List.generate(32, (_) => DateTime.now().millisecondsSinceEpoch % 256),
  )));
  final iv = secureRandom.nextBytes(12);

  final cipher = GCMBlockCipher(AESEngine());
  cipher.init(true, ParametersWithIV(KeyParameter(key), iv));

  final plainBytes = utf8.encode(privateKeyPem);
  final encrypted = cipher.process(Uint8List.fromList(plainBytes));

  return {
    'iv': base64.encode(iv),
    'encrypted': base64.encode(encrypted),
  };
}

/// Decrypt a private key with passphrase (AES-GCM).
String decryptPrivateKey(String encryptedBase64, String ivBase64, String passphrase) {
  final key = deriveKey(passphrase);
  final iv = base64.decode(ivBase64);
  final encrypted = base64.decode(encryptedBase64);

  final cipher = GCMBlockCipher(AESEngine());
  cipher.init(false, ParametersWithIV(KeyParameter(key), iv));

  final decrypted = cipher.process(encrypted);
  return utf8.decode(decrypted);
}

/// RSA public-key encryption (PKCS1).
String rsaEncrypt(String plaintext, RSAPublicKey publicKey) {
  final cipher = PKCS1Encoding(RSAEngine());
  cipher.init(true, PublicKeyParameter<RSAPublicKey>(publicKey));
  final input = Uint8List.fromList(utf8.encode(plaintext));
  final output = cipher.process(input);
  return base64.encode(output);
}

/// RSA private-key decryption (PKCS1).
String rsaDecrypt(String ciphertextBase64, RSAPrivateKey privateKey) {
  final cipher = PKCS1Encoding(RSAEngine());
  cipher.init(false, PrivateKeyParameter<RSAPrivateKey>(privateKey));
  final input = base64.decode(ciphertextBase64);
  final output = cipher.process(input);
  return utf8.decode(output);
}

/// Generate a random AES key (bits: 128, 192, 256).
Uint8List generateRandomAESKey(int bits) {
  final secureRandom = FortunaRandom();
  secureRandom.seed(KeyParameter(Uint8List.fromList(
    List.generate(32, (_) => DateTime.now().millisecondsSinceEpoch % 256),
  )));
  final keyBytes = bits ~/ 8;
  return secureRandom.nextBytes(keyBytes);
}

/// Encrypt a message with AES-GCM. Returns iv + ciphertext in base64.
Map<String, String> aesEncrypt(String plaintext, Uint8List aesKey) {
  final secureRandom = FortunaRandom();
  secureRandom.seed(KeyParameter(Uint8List.fromList(
    List.generate(32, (_) => DateTime.now().millisecondsSinceEpoch % 256),
  )));
  final iv = secureRandom.nextBytes(12);

  final cipher = GCMBlockCipher(AESEngine());
  cipher.init(
    true,
    AEADParameters(KeyParameter(aesKey), 128, iv, Uint8List(0)),
  );

  final input = utf8.encode(plaintext);
  final encrypted = cipher.process(Uint8List.fromList(input));

  return {
    'iv': base64.encode(iv),
    'ciphertext': base64.encode(encrypted),
  };
}

/// Decrypt AES-GCM.
String aesDecrypt(String ciphertextBase64, String ivBase64, Uint8List aesKey) {
  final iv = base64.decode(ivBase64);
  final ciphertext = base64.decode(ciphertextBase64);

  final cipher = GCMBlockCipher(AESEngine());
  cipher.init(
    false,
    AEADParameters(KeyParameter(aesKey), 128, iv, Uint8List(0)),
  );

  final decrypted = cipher.process(ciphertext);
  return utf8.decode(decrypted);
}
