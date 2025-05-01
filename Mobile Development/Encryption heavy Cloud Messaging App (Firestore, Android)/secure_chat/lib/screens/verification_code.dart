import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/crypto_utils.dart';
import '../utils/local_storage.dart';
import '../utils/sercure_store.dart';

class VerificationCodeScreen extends StatefulWidget {
  @override
  _VerificationCodeScreenState createState() => _VerificationCodeScreenState();
}

class _VerificationCodeScreenState extends State<VerificationCodeScreen> {
  TextEditingController _otpController = TextEditingController();
  String _errorMessage = "";
  String? _verificationId;
  String? _phoneNumber;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map?;
    if (args != null) {
      _phoneNumber = args['phone'] as String?;
      _verificationId = args['verificationId'] as String?;
    }
  }

  Future<bool> canDecryptLocalKey() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return false;

    final encPrivKey = await LocalStorage.getPrivateKeyForUid(uid);
    if (encPrivKey != null) {
      final pass = await SecureStore.getPassphraseForUid(uid);
      if (pass == null) return false;
      try {
        final privObj = jsonDecode(encPrivKey);
        decryptPrivateKey(privObj['encrypted'], privObj['iv'], pass);
        return true;
      } catch (e) {
        // Decryption failed, likely due to wrong passphrase.
        return false;
      }
    } else {
      // No local key: check Firestore backup.
      final username = await LocalStorage.getUsername();
      if (username == null || username.isEmpty) return false;
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('usernames').doc(username).get();
      if (userDoc.exists) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
        String? backup = data['privateKeyBackup'];
        if (backup != null && backup.isNotEmpty) {
          // Save the backup locally.
          await LocalStorage.savePrivateKeyForUid(uid, backup);
          final pass = await SecureStore.getPassphraseForUid(uid);
          if (pass == null) return false;
          try {
            final privObj = jsonDecode(backup);
            decryptPrivateKey(privObj['encrypted'], privObj['iv'], pass);
            return true;
          } catch (e) {
            return false;
          }
        }
      }
      return false;
    }
  }

  void _verifyCode() async {
    String enteredCode = _otpController.text.trim();

    if (enteredCode.length < 6) {
      setState(() => _errorMessage = "Veuillez entrer un code de 6 chiffres");
      return;
    }
    if (_verificationId == null) {
      setState(() => _errorMessage = "Le processus de vérification a échoué, réessayez.");
      return;
    }

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: enteredCode,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);

      // Check if this user already has a username stored locally
      String? storedUsername = await LocalStorage.getUsername();
      if (storedUsername != null && storedUsername.isNotEmpty) {
        // Existing account: ask for passphrase to unlock private key.
        Navigator.pushReplacementNamed(context, '/welcome_back');
      } else {
        // No account: proceed to account/profile setup.
        Navigator.pushReplacementNamed(context, '/profile');
      }
    } catch (e) {
      setState(() => _errorMessage = "Code invalide, veuillez réessayer.");
    }
  }




  @override
  Widget build(BuildContext context) {
    final String phoneNumber = _phoneNumber ?? "Numéro inconnu";
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.07),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Spacer(flex: 2),
              Text(
                "Un code de vérification a été envoyé à",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF0F1828),
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 5),
              Text(
                phoneNumber,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              SizedBox(height: screenHeight * 0.05),
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, letterSpacing: 10),
                decoration: InputDecoration(
                  hintText: "000000",
                  counterText: "",
                  filled: true,
                  fillColor: Color(0xFFF7F7FC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                ),
                onChanged: (value) {
                  if (value.length == 6) {
                    _verifyCode();
                  }
                },
              ),
              SizedBox(height: 10),
              if (_errorMessage.isNotEmpty)
                Text(
                  _errorMessage,
                  style: TextStyle(color: Colors.red),
                ),
              Spacer(flex: 1),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF4B00FA),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _verifyCode,
                  child: Text(
                    "Confirmer",
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Code renvoyé à $phoneNumber")),
                  );
                },
                child: Text(
                  "Renvoyer le code",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
              Spacer(flex: 3),
              Container(
                width: screenWidth * 0.4,
                height: 5,
                decoration: BoxDecoration(
                  color: Color(0xFF0F1828),
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
