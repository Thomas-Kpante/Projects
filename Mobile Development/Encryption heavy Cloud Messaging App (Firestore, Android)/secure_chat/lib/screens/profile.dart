// lib/screens/profile.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:basic_utils/basic_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../repositories/data_repository.dart';
import '../utils/local_storage.dart';
import '../utils/crypto_utils.dart';
import '../utils/sercure_store.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final DataRepository repository = FirebaseDataRepository();

  TextEditingController _nameController = TextEditingController();
  TextEditingController _passphraseController = TextEditingController();
  String? _profilePicture;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    final profile = await repository.getUserProfile();
    if (profile != null) {
      setState(() {
        _nameController.text = profile.username;
        _profilePicture = profile.profilePicture;
      });
    }
  }

  Future<void> _saveUserData() async {
    final name = _nameController.text.trim();
    final passphrase = _passphraseController.text.trim();
    if (name.isEmpty) {
      setState(() => _errorMessage = "Le nom ne peut pas être vide");
      return;
    }
    if (passphrase.isEmpty) {
      setState(() => _errorMessage = "La passphrase ne peut pas être vide");
      return;
    }
    // Enforce passphrase length between 15 and 30 characters.
    if (passphrase.length < 15 || passphrase.length > 30) {
      setState(() => _errorMessage = "La passphrase doit contenir entre 15 et 30 caractères");
      return;
    }

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() => _errorMessage = "Aucun utilisateur authentifié trouvé.");
      return;
    }

    // First, check if a user document exists in Firestore.
    final userDoc = await FirebaseFirestore.instance.collection('usernames').doc(name).get();
    final bool userExists = userDoc.exists;

    if (userExists) {
      // Flow for existing users.
      final existingKey = await LocalStorage.getPrivateKeyForUid(uid);
      if (existingKey != null) {
        try {
          final privObj = jsonDecode(existingKey);
          // Try decrypting using the entered passphrase.
          decryptPrivateKey(privObj['encrypted'], privObj['iv'], passphrase);
        } catch (e) {
          setState(() => _errorMessage = "Passphrase incorrecte, veuillez réessayer.");
          return;
        }
        await SecureStore.savePassphraseForUid(uid, passphrase);
        // Retrieve the existing public key from Firestore.
        String existingPublicKey = "";
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
        existingPublicKey = data['publicKey'] ?? "";
        await _updateFirestoreProfile(
          name,
          passphrase,
          isKeyAlreadyPresent: true,
          publicKeyPem: existingPublicKey,
          privateKeyBackup: existingKey,
        );
        return;
      } else {
        // No local key, but a Firestore document exists.
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
        String? backup = data['privateKeyBackup'];
        if (backup != null && backup.isNotEmpty) {
          await LocalStorage.savePrivateKeyForUid(uid, backup);
          try {
            final privObj = jsonDecode(backup);
            decryptPrivateKey(privObj['encrypted'], privObj['iv'], passphrase);
          } catch (e) {
            setState(() => _errorMessage = "Passphrase incorrecte, veuillez réessayer.");
            return;
          }
          await SecureStore.savePassphraseForUid(uid, passphrase);
          String existingPublicKey = data['publicKey'] ?? "";
          await _updateFirestoreProfile(
            name,
            passphrase,
            isKeyAlreadyPresent: true,
            publicKeyPem: existingPublicKey,
            privateKeyBackup: backup,
          );
          return;
        }
      }
    } else {
      // Brand-new account: no Firestore user document exists.
      // Clear any stale local private key.
      await LocalStorage.clearUserData(uid);

      // Generate new RSA key pair.
      final keyPair = generateRSAKeyPair();
      final publicKeyPem = CryptoUtils.encodeRSAPublicKeyToPem(keyPair.publicKey);
      final privateKeyPem = CryptoUtils.encodeRSAPrivateKeyToPem(keyPair.privateKey);

      // Encrypt the new private key using the provided passphrase.
      final encResult = encryptPrivateKey(privateKeyPem, passphrase);
      final encPrivateKeyJson = jsonEncode(encResult);

      await SecureStore.savePassphraseForUid(uid, passphrase);
      await LocalStorage.savePrivateKeyForUid(uid, encPrivateKeyJson);

      // Update Firestore with the new profile and key data.
      await _updateFirestoreProfile(
        name,
        passphrase,
        publicKeyPem: publicKeyPem,
        privateKeyBackup: encPrivateKeyJson,
      );
      return;
    }
  }

  // Update the profile in Firestore (and locally) with the provided data.
  Future<void> _updateFirestoreProfile(String name, String passphrase,
      {bool isKeyAlreadyPresent = false, String publicKeyPem = "", String privateKeyBackup = ""}) async {
    final phone = await LocalStorage.getPhoneNumber() ?? "";
    final profile = UserProfile(
      username: name,
      profilePicture: _profilePicture ?? "",
      phoneNumber: phone,
      publicKey: publicKeyPem,
      privateKeyBackup: privateKeyBackup,
    );

    try {
      await repository.updateUserProfile(profile);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isKeyAlreadyPresent
              ? "Profil mis à jour sans générer une nouvelle clé."
              : "Profil et clé sauvegardés !"),
        ),
      );
      Future.delayed(Duration(seconds: 1), () {
        Navigator.pushReplacementNamed(context, '/main');
      });
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Votre Profil"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "Entrez votre nom",
                errorText: _errorMessage,
              ),
            ),
            TextField(
              controller: _passphraseController,
              decoration: InputDecoration(
                labelText: "Passphrase pour clé privée",
              ),
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: _saveUserData,
              child: Text("Enregistrer"),
            ),
          ],
        ),
      ),
    );
  }
}
