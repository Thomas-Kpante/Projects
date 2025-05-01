// lib/screens/chat_detail.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../repositories/data_repository.dart';
import '../utils/local_storage.dart'; // pour comparer les noms d'utilisateur

class ChatDetailScreen extends StatefulWidget {
  final String chatId;
  ChatDetailScreen({required this.chatId});

  @override
  _ChatDetailScreenState createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final DataRepository repository = FirebaseDataRepository();
  final TextEditingController _messageController = TextEditingController();

  // Nom d'utilisateur actuel
  String? _myUsername;
  // Cache pour les messages décryptés (clé = timestamp en ISO)
  Map<String, String> _decryptedCache = {};

  @override
  void initState() {
    super.initState();
    _loadMyUsername();
  }

  void _loadMyUsername() async {
    final username = await LocalStorage.getUsername();
    setState(() => _myUsername = username);
  }

  Stream<DocumentSnapshot> get chatStream {
    return FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .snapshots();
  }

  // Envoie le message en mode crypté.
  void _sendEncrypted() async {
    final plaintext = _messageController.text.trim();
    if (plaintext.isEmpty) return;
    _messageController.clear();

    try {
      await repository.sendEncryptedMessage(widget.chatId, plaintext);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de l'envoi du message crypté : $e")),
      );
    }
  }

  // Décrypte un message s'il n'est pas déjà en cache.
  Future<void> _decryptMessageIfNeeded(ChatMessage msg) async {
    String key = msg.timestamp.toIso8601String();
    if (_decryptedCache.containsKey(key)) return;
    try {
      String decrypted = await repository.decryptReceivedMessage(msg, "");
      if (mounted) {
        setState(() {
          _decryptedCache[key] = decrypted;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _decryptedCache[key] = "Erreur";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_myUsername == null) {
      return Scaffold(
        appBar: AppBar(title: Text("Chat Crypté")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text("Chat Crypté")),
      body: StreamBuilder<DocumentSnapshot>(
        stream: chatStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
          final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
          final List<dynamic> messagesData = data['messages'] ?? [];
          final messages = messagesData
              .map((m) => ChatMessage.fromMap(m as Map<String, dynamic>))
              .toList();

          // Déclenche le décryptage pour chaque message non encore en cache.
          for (var msg in messages) {
            String key = msg.timestamp.toIso8601String();
            if (!_decryptedCache.containsKey(key)) {
              _decryptMessageIfNeeded(msg);
            }
          }

          // Vérifie si tous les messages sont décryptés.
          bool allDecrypted = messages.every(
                  (msg) => _decryptedCache.containsKey(msg.timestamp.toIso8601String()));

          Widget listView = ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final msg = messages[index];
              String key = msg.timestamp.toIso8601String();
              String decryptedText = _decryptedCache[key] ?? "";
              bool isCurrentUser = (msg.sender == _myUsername);

              return Align(
                alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isCurrentUser ? Colors.blueAccent : Colors.grey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!isCurrentUser)
                        Text(
                          msg.sender,
                          style: TextStyle(color: Colors.white70, fontSize: 10),
                        ),
                      Text(decryptedText, style: TextStyle(color: Colors.white)),
                      SizedBox(height: 4),
                      Text(
                        DateFormat('dd/MM/yyyy hh:mm a').format(msg.timestamp),
                        style: TextStyle(color: Colors.white70, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              );
            },
          );

          return Stack(
            children: [
              listView,
              if (!allDecrypted)
                Positioned.fill(
                  child: Container(
                    color: Colors.black45,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 10),
                          Text("Décryptage en cours...", style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      // Barre d'entrée
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(10),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: "Écrire un message crypté...",
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            SizedBox(width: 10),
            IconButton(
              icon: Icon(Icons.send, color: Colors.blue),
              onPressed: _sendEncrypted,
            ),
          ],
        ),
      ),
    );
  }
}
