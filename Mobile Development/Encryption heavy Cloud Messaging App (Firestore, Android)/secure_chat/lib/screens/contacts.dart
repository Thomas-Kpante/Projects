// lib/screens/contacts.dart
import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../repositories/data_repository.dart';
import 'chat_detail.dart';

class ContactsScreen extends StatefulWidget {
  @override
  _ContactsScreenState createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final DataRepository repository = FirebaseDataRepository();
  List<Contact> contacts = [];

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    List<Contact> fetched = await repository.fetchContacts();
    setState(() => contacts = fetched);
  }

  void _startChat(Contact c) async {
    String receiverUsername = c.name;
    String chatId = await repository.createChat(receiverUsername);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChatDetailScreen(chatId: chatId)),
    );
  }

  void _changeProfilePicture(int index) async {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text("Choisir depuis la galerie"),
              onTap: () async {
                Navigator.pop(context);
                final picker = ImagePicker();
                final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                if (pickedFile != null) {
                  setState(() {
                    contacts[index] = Contact(
                      id: contacts[index].id,
                      name: contacts[index].name,
                      image: pickedFile.path,
                      uid: contacts[index].uid,
                    );
                  });
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.photo),
              title: Text("Choisir une photo par défaut"),
              onTap: () {
                Navigator.pop(context);
                // Approche similaire pour sélectionner une image stockée.
              },
            ),
          ],
        ),
      ),
    );
  }

  void _addContact() {
    TextEditingController nameCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Ajouter un contact"),
        content: TextField(
          controller: nameCtrl,
          decoration: InputDecoration(labelText: "Nom"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Annuler"),
          ),
          TextButton(
            onPressed: () async {
              final name = nameCtrl.text.trim();
              if (name.isEmpty) {
                Navigator.pop(context);
                return;
              }
              final newC = Contact(name: name, image: "", uid: "");
              try {
                await repository.addContact(newC);
                Navigator.pop(context);
                _loadContacts();
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("$e")),
                );
              }
            },
            child: Text("Ajouter"),
          ),
        ],
      ),
    );
  }

  void _deleteContact(int index) async {
    Contact c = contacts[index];
    try {
      await repository.deleteContact(c.id);
      setState(() {
        contacts.removeAt(index);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : $e")),
      );
    }
  }

  void _showOptions(int index) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Wrap(
        children: [
          ListTile(
            leading: Icon(Icons.chat),
            title: Text("Démarrer le chat"),
            onTap: () {
              Navigator.pop(context);
              _startChat(contacts[index]);
            },
          ),
          ListTile(
            leading: Icon(Icons.image),
            title: Text("Changer la photo"),
            onTap: () {
              Navigator.pop(context);
              _changeProfilePicture(index);
            },
          ),
          ListTile(
            leading: Icon(Icons.delete, color: Colors.red),
            title: Text("Supprimer", style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              _deleteContact(index);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Contacts"),
        actions: [
          IconButton(
            onPressed: _addContact,
            icon: Icon(Icons.add),
          )
        ],
      ),
      body: contacts.isEmpty
          ? Center(child: Text("Aucun contact"))
          : ListView.builder(
        itemCount: contacts.length,
        itemBuilder: (ctx, i) {
          final c = contacts[i];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: c.image.isNotEmpty
                  ? (c.image.startsWith("assets/")
                  ? AssetImage(c.image)
                  : FileImage(File(c.image)) as ImageProvider)
                  : null,
              child: c.image.isEmpty ? Icon(Icons.person) : null,
            ),
            title: Text(c.name),
            onTap: () => _showOptions(i),
          );
        },
      ),
    );
  }
}
