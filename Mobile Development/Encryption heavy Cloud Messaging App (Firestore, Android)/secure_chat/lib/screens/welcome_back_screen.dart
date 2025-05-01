// lib/screens/welcome_back_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/local_storage.dart';
import '../utils/crypto_utils.dart';
import '../utils/sercure_store.dart';

class WelcomeBackScreen extends StatefulWidget {
  const WelcomeBackScreen({Key? key}) : super(key: key);

  @override
  _WelcomeBackScreenState createState() => _WelcomeBackScreenState();
}

class _WelcomeBackScreenState extends State<WelcomeBackScreen> {
  TextEditingController _passphraseController = TextEditingController();
  String? username;
  String _errorMessage = "";

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  void _loadUsername() async {
    String? storedUsername = await LocalStorage.getUsername();
    setState(() {
      username = storedUsername;
    });
  }

  // Attempt to unlock the local key using the entered passphrase.
  void _checkPassphrase() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() {
        _errorMessage = "Utilisateur non authentifié.";
      });
      return;
    }
    final encPrivKey = await LocalStorage.getPrivateKeyForUid(uid);
    if (encPrivKey == null) {
      setState(() {
        _errorMessage = "Aucune clé privée trouvée.";
      });
      return;
    }
    try {
      Map<String, dynamic> keyMap = jsonDecode(encPrivKey);
      final pass = _passphraseController.text.trim();
      // Attempt decryption; if it fails, an exception is thrown.
      decryptPrivateKey(keyMap['encrypted'], keyMap['iv'], pass);
      // Save the passphrase for future use if desired.
      await SecureStore.savePassphraseForUid(uid, pass);
      // On successful decryption, navigate to the main screen.
      Navigator.pushReplacementNamed(context, '/main');
    } catch (e) {
      setState(() {
        _errorMessage = "Passphrase incorrecte, veuillez réessayer.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show a loading indicator until username loads.
    if (username == null) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("Bienvenue, $username"),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Entrez votre passphrase pour déverrouiller votre clé privée",
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            TextField(
              controller: _passphraseController,
              decoration: InputDecoration(
                labelText: "Passphrase",
                border: OutlineInputBorder(),
                errorText: _errorMessage.isNotEmpty ? _errorMessage : null,
              ),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _checkPassphrase,
              child: Text("Continuer"),
            ),
          ],
        ),
      ),
    );
  }
}
