// test/hybrid_encryption_test.dart
import 'dart:convert';
import 'dart:typed_data';


import 'package:flutter_test/flutter_test.dart';
import 'package:secure_chat/utils/crypto_utils.dart'; // Adjust your import path if needed

void main() {
  test('Hybrid encryption test (AES + RSA)', () {
    // Step 1: Generate RSA key pair (recipient's keys).
    final keyPair = generateRSAKeyPair();

    // Step 2: Generate a random AES-256 key.
    Uint8List aesKey = generateRandomAESKey(256);

    // Original message we want to send securely.
    String originalMessage = "Hello from hybrid encryption!";

    // Step 3: Encrypt the message with AES.
    Map<String, String> aesResult = aesEncrypt(originalMessage, aesKey);
    String aesIv = aesResult['iv']!;
    String aesCiphertext = aesResult['ciphertext']!;

    // Step 4: Encrypt the AES key with the recipient’s RSA public key.
    // Convert aesKey to a base64 string, then encrypt that string with RSA.
    String aesKeyBase64 = base64.encode(aesKey);
    String encryptedAesKey = rsaEncrypt(aesKeyBase64, keyPair.publicKey);

    // ========== Now, pretend the encrypted message + encrypted key
    // ========== are sent to the recipient. ==========

    // Step 5: Decrypt the AES key using the recipient’s RSA private key.
    String decryptedAesKeyBase64 = rsaDecrypt(encryptedAesKey, keyPair.privateKey);
    // Convert from base64 string back to bytes.
    Uint8List recoveredAesKey = base64.decode(decryptedAesKeyBase64);

    // Step 6: Decrypt the message using the recovered AES key.
    String decryptedMessage = aesDecrypt(aesCiphertext, aesIv, recoveredAesKey);

    // Finally, verify that the decrypted message matches the original.
    expect(decryptedMessage, equals(originalMessage));
  });
}
