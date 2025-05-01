// lib/screens/edit_profile.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../repositories/data_repository.dart';
import '../utils/local_storage.dart';
import '../utils/crypto_utils.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final DataRepository repository = FirebaseDataRepository();

  TextEditingController _nameController = TextEditingController();
  TextEditingController _passphraseController = TextEditingController();
  String? _profilePicture;
  String _errorMessage = "";
  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Load user profile data from Firebase.
  void _loadUserData() async {
    var profile = await repository.getUserProfile();
    setState(() {
      if (profile != null) {
        _nameController.text = profile.username;
        _profilePicture = profile.profilePicture;
      }
      _validateInput(_nameController.text);
    });
  }

  // Validate that the username is not empty.
  void _validateInput(String value) {
    setState(() {
      if (value.trim().isEmpty) {
        _errorMessage = "Le nom ne peut pas être vide";
        _isButtonEnabled = false;
      } else {
        _errorMessage = "";
        _isButtonEnabled = true;
      }
    });
  }

  // Save updated profile and generate RSA keys.
  void _saveUserData() async {
    String name = _nameController.text.trim();
    String passphrase = _passphraseController.text.trim();

    if (name.isEmpty) {
      setState(() {
        _errorMessage = "Le nom ne peut pas être vide";
      });
      return;
    }
    if (passphrase.isEmpty) {
      setState(() {
        _errorMessage = "Un passphrase est requis pour sécuriser votre clé privée";
      });
      return;
    }
    // Validate passphrase length (15 to 30 characters).
    if (passphrase.length < 15 || passphrase.length > 30) {
      setState(() {
        _errorMessage = "La passphrase doit contenir entre 15 et 30 caractères";
      });
      return;
    }

    String? phone = await LocalStorage.getPhoneNumber();

    // Generate RSA key pair.
    final keyPair = generateRSAKeyPair();
    String publicKeyStr = keyPair.publicKey.toString();
    String privateKeyStr = keyPair.privateKey.toString();

    // Encrypt the private key.
    final encryptionResult = encryptPrivateKey(privateKeyStr, passphrase);
    String encryptedPrivateKeyJson = jsonEncode(encryptionResult);

    // Save encrypted private key locally using the per-UID method.
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await LocalStorage.savePrivateKeyForUid(uid, encryptedPrivateKeyJson);
    }

    // Create a user profile to update in Firestore.
    var profile = UserProfile(
      username: name,
      profilePicture: _profilePicture ?? "",
      phoneNumber: phone ?? "",
      publicKey: publicKeyStr,
    );

    try {
      await repository.updateUserProfile(profile);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Profil sauvegardé!")),
      );
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Modifier le profil"),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Simulated profile picture selection.
            GestureDetector(
              onTap: () {
                setState(() {
                  _profilePicture = "https://placehold.co/100";
                });
              },
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _profilePicture != null ? NetworkImage(_profilePicture!) : null,
                child: _profilePicture == null
                    ? Icon(Icons.person, size: 50, color: Colors.grey)
                    : null,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _nameController,
              onChanged: _validateInput,
              decoration: InputDecoration(
                labelText: "Modifier votre nom",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                errorText: _errorMessage.isNotEmpty ? _errorMessage : null,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _passphraseController,
              decoration: InputDecoration(
                labelText: "Entrez un passphrase pour votre clé privée",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                errorText: _errorMessage.isNotEmpty ? _errorMessage : null,
              ),
              obscureText: true,
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isButtonEnabled ? _saveUserData : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isButtonEnabled ? Color(0xFF4B00FA) : Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  "Enregistrer",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
