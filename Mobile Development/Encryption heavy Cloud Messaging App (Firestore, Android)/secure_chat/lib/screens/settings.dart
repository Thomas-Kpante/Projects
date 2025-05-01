// lib/screens/settings.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/local_storage.dart';
import '../utils/sercure_store.dart';
import 'edit_profile.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String? _username;
  String? _phoneNumber;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    String? savedName = await LocalStorage.getUsername();
    String? savedPhone = await LocalStorage.getPhoneNumber();
    setState(() {
      _username = savedName ?? "Unknown User";
      _phoneNumber = savedPhone ?? "Not Set";
    });
  }

  /// Logs out the current Firebase user. Note: The private key is preserved so that the user can re-use it on subsequent logins.
  void _logout(BuildContext context) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final uid = currentUser?.uid;

    if (uid != null) {
      // Remove the user's passphrase from Secure Storage
      await SecureStore.clearPassphraseForUid(uid);

      // Do not clear the user's private key so that it persists across logins.
      // await LocalStorage.clearUserData(uid);
    }

    await FirebaseAuth.instance.signOut();
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  void _openEditProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditProfileScreen()),
    ).then((_) {
      _loadUserData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text("Paramètres"),
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: Icon(Icons.person, color: Colors.blue),
                  title: Text(
                    _username ?? "Loading...",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text("Phone: $_phoneNumber"),
                  trailing: IconButton(
                    icon: Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _openEditProfile(context),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Divider(),
              ListTile(
                leading: Icon(Icons.logout, color: Colors.red),
                title: Text("Déconnexion", style: TextStyle(color: Colors.red)),
                onTap: () => _logout(context),
                trailing: Icon(Icons.exit_to_app, color: Colors.red),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
