// lib/screens/chats.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../repositories/data_repository.dart';
import 'chat_detail.dart';
import '../utils/local_storage.dart'; // pour obtenir le nom d'utilisateur

class ChatsScreen extends StatefulWidget {
  @override
  ChatsScreenState createState() => ChatsScreenState();
}

class ChatsScreenState extends State<ChatsScreen> {
  final DataRepository repository = FirebaseDataRepository();
  Stream<QuerySnapshot>? _chatsStream;
  String? _currentUsername;
  Map<String, String> previewCache = {}; // Cache des aperçus décryptés par document de chat

  @override
  void initState() {
    super.initState();
    _loadCurrentUsernameAndChats();
  }

  /// Charge le nom d'utilisateur actuel et initialise le flux des chats.
  void _loadCurrentUsernameAndChats() async {
    String? currentUsername = await LocalStorage.getUsername();
    if (currentUsername == null || currentUsername.isEmpty) {
      return;
    }
    setState(() {
      _currentUsername = currentUsername;
      _chatsStream = FirebaseFirestore.instance
          .collection('chats')
          .where('participants', arrayContains: currentUsername)
          .snapshots();
    });
  }

  void _openChat(String chatId) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChatDetailScreen(chatId: chatId)),
    );
  }

  /// Crée un nouveau chat avec le nom d'utilisateur du destinataire.
  void _startNewChat(String receiverUsername) async {
    // Vérifie que l'utilisateur existe
    bool exists = await repository.doesUsernameExist(receiverUsername);
    if (!exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("L'utilisateur n'existe pas")),
      );
      return;
    }
    try {
      String chatId = await repository.createChat(receiverUsername);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ChatDetailScreen(chatId: chatId)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de la création du chat : $e")),
      );
    }
  }

  /// Affiche une boîte de dialogue pour démarrer une nouvelle conversation.
  void _showAddConversationDialog() {
    TextEditingController usernameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Nouvelle conversation"),
          content: TextField(
            controller: usernameController,
            decoration: InputDecoration(labelText: "Nom d'utilisateur"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Annuler"),
            ),
            TextButton(
              onPressed: () {
                String enteredUsername = usernameController.text.trim();
                if (enteredUsername.isNotEmpty) {
                  Navigator.pop(context);
                  _startNewChat(enteredUsername);
                }
              },
              child: Text("Démarrer"),
            ),
          ],
        );
      },
    );
  }

  /// Supprime la conversation (chat) du Firestore.
  Future<void> _deleteConversation(String chatId) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Supprimer la conversation"),
          content: Text("Êtes-vous sûr de vouloir supprimer cette conversation ?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text("Annuler"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text("Supprimer", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
    if (confirm) {
      try {
        await FirebaseFirestore.instance.collection('chats').doc(chatId).delete();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Conversation supprimée")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur lors de la suppression : $e")),
        );
      }
    }
  }

  /// Décrypte de manière asynchrone le dernier message d'un chat et le met en cache.
  Future<void> _loadPreview(String chatId, ChatMessage lastMessage) async {
    try {
      final decrypted = await repository.decryptReceivedMessage(lastMessage, "");
      if (mounted) {
        setState(() {
          previewCache[chatId] = decrypted;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          previewCache[chatId] = "Erreur";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chats (Cryptés)"),
        actions: [
          IconButton(
            onPressed: _showAddConversationDialog,
            icon: Icon(Icons.add),
            tooltip: "Nouvelle conversation",
          )
        ],
      ),
      body: _chatsStream == null
          ? Center(child: CircularProgressIndicator())
          : StreamBuilder<QuerySnapshot>(
        stream: _chatsStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          return ListView.separated(
            itemCount: snapshot.data!.docs.length,
            separatorBuilder: (_, __) => Divider(height: 1),
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final List<dynamic> participants = data['participants'] ?? [];
              final List<dynamic> messagesData = data['messages'] ?? [];
              final messages = messagesData
                  .map((m) => ChatMessage.fromMap(m as Map<String, dynamic>))
                  .toList();

              // Détermine le nom de la conversation (l'autre participant).
              String conversationName = doc.id;
              if (_currentUsername != null && participants.isNotEmpty) {
                conversationName = participants.firstWhere(
                      (p) => p != _currentUsername,
                  orElse: () => doc.id,
                );
              }

              // Aperçu décrypté du dernier message.
              String preview = "Décryptage...";
              if (messages.isNotEmpty) {
                if (previewCache.containsKey(doc.id)) {
                  preview = previewCache[doc.id]!;
                } else {
                  _loadPreview(doc.id, messages.last);
                }
              }

              // Formate la date du dernier message.
              String dateString = "";
              if (messages.isNotEmpty) {
                dateString = DateFormat('dd/MM/yyyy hh:mm a')
                    .format(messages.last.timestamp);
              }

              return ListTile(
                leading: CircleAvatar(
                  child: Text(
                    conversationName.isNotEmpty
                        ? conversationName.substring(0, 1).toUpperCase()
                        : "?",
                  ),
                ),
                title: Text(conversationName),
                subtitle: messages.isNotEmpty
                    ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      preview,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      dateString,
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                )
                    : Text("Nouvelle conversation",
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                onTap: () => _openChat(doc.id),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteConversation(doc.id),
                  tooltip: "Supprimer la conversation",
                ),
              );
            },
          );
        },
      ),
    );
  }
}
