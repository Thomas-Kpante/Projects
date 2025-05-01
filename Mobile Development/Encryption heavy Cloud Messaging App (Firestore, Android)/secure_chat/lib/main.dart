// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/walkthrough.dart';
import 'screens/verification_phone.dart';
import 'screens/verification_code.dart';
import 'screens/profile.dart';
import 'screens/main_screen.dart';
import 'screens/welcome_back_screen.dart';
import 'screens/edit_profile.dart';
import 'screens/chat_detail.dart';
import 'screens/chats.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'utils/local_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Here we always launch at the Walkthrough (or sign-in) screen.
  runApp(SecureChatApp());
}

class SecureChatApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SecureChat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/', // Start with the Walkthrough screen.
      routes: {
        '/': (context) => WalkthroughScreen(),
        '/phone_verification': (context) => PhoneVerificationScreen(),
        '/verification_code': (context) => VerificationCodeScreen(),
        '/profile': (context) => ProfileScreen(),
        '/welcome_back': (context) => WelcomeBackScreen(),
        '/main': (context) => MainScreen(),
        '/edit_profile': (context) => EditProfileScreen(),
        '/chats': (context) => ChatsScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/chat_detail') {
          final args = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => ChatDetailScreen(chatId: args),
          );
        }
        return null;
      },
    );
  }
}
