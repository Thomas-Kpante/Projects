import 'package:flutter/material.dart';
import 'contacts.dart';
import 'chats.dart';
import 'settings.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 1; // Default to Chats tab

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      ContactsScreen(),
      ChatsScreen(),
      SettingsScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // No need to manually reload chats; ChatsScreen updates in real time.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Color(0xFF0F1828),
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.contacts),
            label: "Contacts",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: "Chats",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Paramètres",
          ),
        ],
      ),
    );
  }
}
