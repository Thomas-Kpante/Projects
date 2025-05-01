// lib/utils/local_storage.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LocalStorage {
  // ============== PER-USER ENCRYPTED PRIVATE KEY =============
  static Future<void> savePrivateKeyForUid(String uid, String encryptedPrivateKeyJson) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('private_key_$uid', encryptedPrivateKeyJson);
  }

  static Future<String?> getPrivateKeyForUid(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('private_key_$uid');
  }

  static Future<void> clearUserData(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('private_key_$uid');
  }

  // ============== USERNAME, PHONE, PICTURE =============
  // Save username using the current user's UID.
  static Future<void> saveUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await prefs.setString('username_$uid', username);
    } else {
      // Optionally handle this case if needed.
      await prefs.setString('username', username);
    }
  }

  // Retrieve the username using the current user's UID.
  static Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      return prefs.getString('username_$uid');
    } else {
      return prefs.getString('username');
    }
  }

  static Future<void> savePhoneNumber(String phoneNumber) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('phone_number', phoneNumber);
  }

  static Future<String?> getPhoneNumber() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('phone_number');
  }

  static Future<void> saveProfilePicture(String profileUrl) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_picture', profileUrl);
  }

  static Future<String?> getProfilePicture() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('profile_picture');
  }
}
