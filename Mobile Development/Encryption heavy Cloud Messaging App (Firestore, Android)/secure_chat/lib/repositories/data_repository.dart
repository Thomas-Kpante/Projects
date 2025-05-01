// lib/repositories/data_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'dart:typed_data';

import '../utils/local_storage.dart';
import '../utils/crypto_utils.dart';
import 'package:pointycastle/asymmetric/rsa.dart';
import 'package:basic_utils/basic_utils.dart';

import '../utils/sercure_store.dart';

/// --- Models ---
class UserProfile {
  final String username;
  final String profilePicture;
  final String phoneNumber;
  final String publicKey; //
  final String privateKeyBackup;

  UserProfile({
    required this.username,
    required this.profilePicture,
    required this.phoneNumber,
    required this.publicKey,
    this.privateKeyBackup = "",
  });

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'profilePicture': profilePicture,
      'phoneNumber': phoneNumber,
      'publicKey': publicKey,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      username: map['username'] as String,
      profilePicture: map['profilePicture'] as String,
      phoneNumber: map['phoneNumber'] as String,
      publicKey: map['publicKey'] as String? ?? "",
      privateKeyBackup: map['privateKeyBackup'] as String? ?? "",
    );
  }
}

class ChatMessage {
  final String sender; // Nom d'utilisateur de l'expéditeur
  final String text;   // Texte ou charge utile JSON cryptée
  final DateTime timestamp;

  ChatMessage({
    required this.sender,
    required this.text,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'sender': sender,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      sender: map['sender'] as String,
      text: map['text'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }
}

class Chat {
  final String chatId;
  final List<ChatMessage> messages;
  Chat({required this.chatId, required this.messages});
}

class Contact {
  final String id; // ID du document Firestore
  final String name;
  final String image;
  final String uid; // UID du destinataire

  Contact({
    this.id = '',
    required this.name,
    required this.image,
    required this.uid,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'image': image,
      'uid': uid,
    };
  }

  factory Contact.fromMap(Map<String, dynamic> map, {String id = ''}) {
    return Contact(
      id: id,
      name: map['name'] as String,
      image: map['image'] as String,
      uid: map['uid'] as String? ?? '',
    );
  }
}

/// --- Repository Interface ---
abstract class DataRepository {
  // Opérations de profil
  Future<UserProfile?> getUserProfile();
  Future<void> updateUserProfile(UserProfile profile);
  Future<UserProfile?> getUserByPhone(String phoneNumber);

  // Opérations de chat
  Future<List<Chat>> fetchChats();
  Future<String> createChat(String receiverUsername);
  Future<void> sendMessage(String chatId, ChatMessage message);

  // Méthodes d'encryption hybride
  Future<void> sendEncryptedMessage(String chatId, String plaintext);
  Future<String> decryptReceivedMessage(ChatMessage encryptedMsg, String passphrase);

  // Opérations de contacts
  Future<List<Contact>> fetchContacts();
  Future<void> addContact(Contact contact);
  Future<void> deleteContact(String contactId);

  // Méthode additionnelle pour vérifier l'existence d'un utilisateur
  Future<bool> doesUsernameExist(String username);
}

/// --- Implémentation Firebase et stockage local ---
class FirebaseDataRepository implements DataRepository {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // OPÉRATIONS DE PROFIL

  @override
  Future<UserProfile?> getUserProfile() async {
    String? username = await LocalStorage.getUsername();
    String? profilePicture = await LocalStorage.getProfilePicture();
    String? phoneNumber = await LocalStorage.getPhoneNumber();
    if (username != null && profilePicture != null && phoneNumber != null) {
      // On suppose que le document utilisateur est stocké avec le nom d'utilisateur comme ID.
      return UserProfile(
        username: username,
        profilePicture: profilePicture,
        phoneNumber: phoneNumber,
        publicKey: "", // Valeur par défaut ; updateUserProfile() mettra à jour cette valeur.
      );
    }
    return null;
  }

  @override
  Future<void> updateUserProfile(UserProfile profile) async {
    // Enregistre le document utilisateur avec le nom d'utilisateur comme ID.
    await firestore.collection('usernames').doc(profile.username).set({
      'uid': FirebaseAuth.instance.currentUser!.uid,
      'username': profile.username,
      'phoneNumber': profile.phoneNumber,
      'profilePicture': profile.profilePicture,
      'publicKey': profile.publicKey,
      'privateKeyBackup': profile.privateKeyBackup ?? "", // NEW backup field
      'updatedAt': DateTime.now().toIso8601String(),
    });
    await LocalStorage.saveUsername(profile.username);
    await LocalStorage.saveProfilePicture(profile.profilePicture);
    await LocalStorage.savePhoneNumber(profile.phoneNumber);
  }

  @override
  Future<UserProfile?> getUserByPhone(String phoneNumber) async {
    QuerySnapshot snapshot = await firestore
        .collection('usernames')
        .where('phoneNumber', isEqualTo: phoneNumber)
        .limit(1)
        .get();
    if (snapshot.docs.isNotEmpty) {
      Map<String, dynamic> data =
      snapshot.docs.first.data() as Map<String, dynamic>;
      return UserProfile(
        username: data['username'] ?? snapshot.docs.first.id,
        profilePicture: data['profilePicture'] ?? "",
        phoneNumber: data['phoneNumber'] as String,
        publicKey: data['publicKey'] as String? ?? "",
      );
    }
    return null;
  }

  // OPÉRATIONS DE CHAT

  @override
  Future<List<Chat>> fetchChats() async {
    // On suppose que les documents de chat stockent les participants sous forme de noms d'utilisateur.
    String? currentUsername = await LocalStorage.getUsername();
    if (currentUsername == null) return [];
    QuerySnapshot snapshot = await firestore
        .collection('chats')
        .where('participants', arrayContains: currentUsername)
        .get();
    List<Chat> chats = [];
    for (var doc in snapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      List<dynamic> messagesData = data['messages'] ?? [];
      List<ChatMessage> messages = messagesData
          .map((m) => ChatMessage.fromMap(m as Map<String, dynamic>))
          .toList();
      chats.add(Chat(chatId: doc.id, messages: messages));
    }
    return chats;
  }

  @override
  Future<String> createChat(String receiverUsername) async {
    // Utilise les noms d'utilisateur (et non les UIDs) pour créer le document de chat.
    String? currentUsername = await LocalStorage.getUsername();
    if (currentUsername == null || receiverUsername.isEmpty) {
      throw Exception("Les noms d'utilisateur ne sont pas disponibles");
    }
    List<String> participants = [currentUsername, receiverUsername]..sort();
    String chatId = participants.join('_');
    DocumentReference chatDoc = firestore.collection('chats').doc(chatId);
    DocumentSnapshot docSnapshot = await chatDoc.get();
    if (!docSnapshot.exists) {
      await chatDoc.set({
        'participants': participants,
        'messages': [],
      });
    }
    return chatId;
  }

  @override
  Future<void> sendMessage(String chatId, ChatMessage message) async {
    DocumentReference chatDoc = firestore.collection('chats').doc(chatId);
    await chatDoc.set({
      'messages': FieldValue.arrayUnion([message.toMap()]),
    }, SetOptions(merge: true));
  }

  // MÉTHODES D'ENCRYPTION HYBRIDE

  @override
  Future<void> sendEncryptedMessage(String chatId, String plaintext) async {
    print("DEBUG: sendEncryptedMessage -> chatId=$chatId, plaintext=$plaintext");

    // 1) Charge le document de chat
    DocumentSnapshot docSnapshot =
    await firestore.collection('chats').doc(chatId).get();
    if (!docSnapshot.exists) {
      print("DEBUG: Le document de chat $chatId n'existe PAS. Lancement d'une exception.");
      throw Exception("Le chat $chatId n'existe pas");
    }
    Map<String, dynamic> chatData = docSnapshot.data() as Map<String, dynamic>;
    List<dynamic> participants = chatData['participants'] ?? [];
    print("DEBUG: Participants du chat => $participants");
    if (participants.length < 2) {
      print("DEBUG: Pas assez de participants dans le chat. Lancement d'une exception.");
      throw Exception("Pas assez de participants dans le chat pour l'encryption.");
    }

    // 2) Nom d'utilisateur actuel et l'autre participant
    String? currentUsername = await LocalStorage.getUsername();
    if (currentUsername == null) {
      print("DEBUG: Le nom d'utilisateur actuel est nul, impossible de continuer.");
      throw Exception("Nom d'utilisateur actuel introuvable");
    }
    String otherUsername =
    (participants[0] == currentUsername) ? participants[1] : participants[0];

    print("DEBUG: currentUsername=$currentUsername, otherUsername=$otherUsername");

    // 3) Récupère le document pour l'expéditeur (currentUsername)
    DocumentSnapshot senderDoc =
    await firestore.collection('usernames').doc(currentUsername).get();
    if (!senderDoc.exists) {
      print("DEBUG: Le document Firestore pour l'expéditeur $currentUsername n'existe PAS !");
      throw Exception("Document de l'expéditeur introuvable dans Firestore");
    }
    Map<String, dynamic> senderData = senderDoc.data() as Map<String, dynamic>;
    String senderPublicKeyPem = senderData['publicKey'] ?? "";
    String senderDocUid = senderData['uid'] ?? "NO_UID_FIELD";
    print("DEBUG: Champ 'uid' du document de l'expéditeur = $senderDocUid, Clé publique Firestore:\n$senderPublicKeyPem");

    // 4) Récupère le document pour le destinataire (otherUsername)
    DocumentSnapshot recipientDoc =
    await firestore.collection('usernames').doc(otherUsername).get();
    if (!recipientDoc.exists) {
      print("DEBUG: Le document Firestore pour le destinataire $otherUsername n'existe PAS !");
      throw Exception("Document du destinataire introuvable dans Firestore");
    }
    Map<String, dynamic> recipientData =
    recipientDoc.data() as Map<String, dynamic>;
    String recipientPublicKeyPem = recipientData['publicKey'] ?? "";
    String recipientDocUid = recipientData['uid'] ?? "NO_UID_FIELD";
    print("DEBUG: Champ 'uid' du document du destinataire = $recipientDocUid, Clé publique Firestore:\n$recipientPublicKeyPem");

    if (senderPublicKeyPem.isEmpty || recipientPublicKeyPem.isEmpty) {
      print("DEBUG: L'un ou l'autre des utilisateurs n'a pas de clé publique dans Firestore. Lancement d'une erreur.");
      throw Exception("Clé publique de l'expéditeur ou du destinataire manquante");
    }

    // 4.5) Vérifie l'UID local pour le debug
    final localUid = FirebaseAuth.instance.currentUser?.uid;
    print("DEBUG: UID local via FirebaseAuth.currentUser => $localUid");

    // 5) Convertit les chaînes PEM en objets RSAPublicKey
    RSAPublicKey senderPubKey = CryptoUtils.rsaPublicKeyFromPem(senderPublicKeyPem);
    RSAPublicKey recipientPubKey = CryptoUtils.rsaPublicKeyFromPem(recipientPublicKeyPem);

    // 6) Génère une clé AES aléatoire et chiffre le texte en clair
    Uint8List aesKey = generateRandomAESKey(256);
    Map<String, String> aesResult = aesEncrypt(plaintext, aesKey);
    String aesCiphertext = aesResult['ciphertext']!;
    String aesIv = aesResult['iv']!;
    print("DEBUG: AES ciphertext=$aesCiphertext, AES iv=$aesIv");

    // 7) Chiffre la clé AES avec RSA pour l'expéditeur et le destinataire
    String aesKeyBase64 = base64.encode(aesKey);
    String encryptedAesKeyForSender = rsaEncrypt(aesKeyBase64, senderPubKey);
    String encryptedAesKeyForRecipient = rsaEncrypt(aesKeyBase64, recipientPubKey);
    print("DEBUG: Longueur encryptedAesKeyForSender=${encryptedAesKeyForSender.length}");
    print("DEBUG: Longueur encryptedAesKeyForRecipient=${encryptedAesKeyForRecipient.length}");

    // 8) Construit le JSON final
    String payloadJson = jsonEncode({
      'aesCiphertext': aesCiphertext,
      'aesIv': aesIv,
      'encryptedAesKeyForSender': encryptedAesKeyForSender,
      'encryptedAesKeyForRecipient': encryptedAesKeyForRecipient,
    });
    print("DEBUG: JSON final => $payloadJson");

    // 9) Construit un ChatMessage
    ChatMessage newMessage = ChatMessage(
      sender: currentUsername,
      text: payloadJson,
      timestamp: DateTime.now(),
    );

    // 10) Sauvegarde le nouveau message crypté
    print("DEBUG: Enregistrement du nouveau message dans le document de chat. Terminé.\n-------------------");
    await sendMessage(chatId, newMessage);
  }

  // MÉTHODES D'ENCRYPTION HYBRIDE

  @override
  Future<String> decryptReceivedMessage(ChatMessage encryptedMsg, String ignoredParam) async {
    String rawText = encryptedMsg.text;
    print("[decryptReceivedMessage] Début. sender=${encryptedMsg.sender}\nTexte brut:\n$rawText\n----------");

    // 1) Analyse le JSON
    late Map<String, dynamic> payload;
    try {
      payload = jsonDecode(rawText);
      print("[decryptReceivedMessage] JSON analysé => $payload");
    } catch (e) {
      print("[decryptReceivedMessage] JSON invalide, retourne le texte brut. Erreur: $e");
      return rawText;
    }

    // 2) Vérifie les champs requis
    if (!payload.containsKey('aesCiphertext') ||
        !payload.containsKey('aesIv') ||
        (!payload.containsKey('encryptedAesKeyForSender') &&
            !payload.containsKey('encryptedAesKeyForRecipient'))) {
      print("[decryptReceivedMessage] Champs requis manquants => retourne le texte brut");
      return rawText;
    }

    // 3) Récupère l'UID de l'utilisateur actuel
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      print("[decryptReceivedMessage] Aucun utilisateur connecté => impossible de décrypter.");
      throw Exception("Aucun utilisateur authentifié, impossible de décrypter");
    }
    print("[decryptReceivedMessage] UID local => $uid");

    // 4) Récupère la clé privée cryptée stockée localement pour cet UID
    String? encPrivKeyJson = await LocalStorage.getPrivateKeyForUid(uid);
    if (encPrivKeyJson == null) {
      print("[decryptReceivedMessage] Aucune clé privée stockée pour UID=$uid !");
      throw Exception("Aucune clé privée stockée pour l'utilisateur $uid");
    }
    print("[decryptReceivedMessage] Clé privée cryptée trouvée => $encPrivKeyJson");

    // 5) Récupère la passphrase depuis le SecureStore
    String? storedPassphrase = await SecureStore.getPassphraseForUid(uid);
    if (storedPassphrase == null) {
      print("[decryptReceivedMessage] Aucune passphrase trouvée dans SecureStore pour UID=$uid");
      throw Exception("Aucune passphrase trouvée pour l'utilisateur $uid");
    }

    // 6) Décrypte la clé privée
    String privateKeyPem;
    try {
      Map<String, dynamic> privObj = jsonDecode(encPrivKeyJson);
      privateKeyPem = decryptPrivateKey(privObj['encrypted'], privObj['iv'], storedPassphrase);
      print("[decryptReceivedMessage] Clé privée décrytpée avec succès. (Omit for security)");
    } catch (e) {
      print("[decryptReceivedMessage] Erreur lors du décryptage de la clé privée => $e");
      rethrow;
    }

    // 7) Parse la clé privée en objet RSAPrivateKey
    RSAPrivateKey userPrivateKey;
    try {
      userPrivateKey = CryptoUtils.rsaPrivateKeyFromPem(privateKeyPem);
      print("[decryptReceivedMessage] Analyse de la clé privée RSA réussie");
    } catch (e) {
      print("[decryptReceivedMessage] Erreur lors de l'analyse de la clé RSA => $e");
      rethrow;
    }

    // 8) Détermine si l'utilisateur est l'expéditeur ou le destinataire
    String? currentUsername = await LocalStorage.getUsername();
    bool isSender = (encryptedMsg.sender == currentUsername);
    print("[decryptReceivedMessage] currentUsername=$currentUsername, isSender=$isSender");

    // 9) Sélectionne la clé AES RSA appropriée
    String encryptedAesKey = isSender
        ? payload['encryptedAesKeyForSender']
        : payload['encryptedAesKeyForRecipient'];
    print("[decryptReceivedMessage] Utilisation de la clé AES RSA suivante => $encryptedAesKey");

    // 10) Décrypte la clé AES avec RSA
    String aesKeyBase64;
    try {
      aesKeyBase64 = rsaDecrypt(encryptedAesKey, userPrivateKey);
      print("[decryptReceivedMessage] RSA décryptage réussi, longueur base64=${aesKeyBase64.length}");
    } catch (e) {
      print("[decryptReceivedMessage] Erreur RSA lors du décryptage => $e");
      rethrow;
    }

    // 11) Décrypte le message avec AES-GCM
    String aesCiphertext = payload['aesCiphertext'];
    String aesIv = payload['aesIv'];
    print("[decryptReceivedMessage] aesCiphertext=$aesCiphertext, aesIv=$aesIv => décryptage en cours...");
    String decryptedMessage;
    try {
      Uint8List aesKey = base64.decode(aesKeyBase64);
      decryptedMessage = aesDecrypt(aesCiphertext, aesIv, aesKey);
      print("[decryptReceivedMessage] AES décryptage => $decryptedMessage");
    } catch (e) {
      print("[decryptReceivedMessage] Exception lors du décryptage AES => $e");
      rethrow;
    }

    print("[decryptReceivedMessage] Terminé => $decryptedMessage\n----------------");
    return decryptedMessage;
  }

  // OPÉRATIONS SUR LES CONTACTS

  @override
  Future<List<Contact>> fetchContacts() async {
    String? username = await LocalStorage.getUsername();
    if (username == null) return [];
    QuerySnapshot snapshot = await firestore
        .collection('usernames')
        .doc(username)
        .collection('contacts')
        .get();
    return snapshot.docs.map((doc) {
      return Contact.fromMap(doc.data() as Map<String, dynamic>, id: doc.id);
    }).toList();
  }

  @override
  Future<void> addContact(Contact contact) async {
    bool exists = await doesUsernameExist(contact.name);
    if (!exists) {
      throw Exception("L'utilisateur n'existe pas");
    }
    String receiverUID = contact.uid;
    if (receiverUID.isEmpty) {
      DocumentSnapshot doc = await firestore.collection('usernames').doc(contact.name).get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        receiverUID = data['uid'] ?? "";
      }
    }
    if (receiverUID.isEmpty) {
      throw Exception("UID de l'utilisateur introuvable");
    }
    Contact newContact = Contact(name: contact.name, image: contact.image, uid: receiverUID);
    String? currentUsername = await LocalStorage.getUsername();
    if (currentUsername == null) {
      throw Exception("Utilisateur non connecté");
    }
    var contactData = newContact.toMap();
    contactData['ownerUid'] = FirebaseAuth.instance.currentUser!.uid;
    await firestore.collection('usernames').doc(currentUsername).collection('contacts').add(contactData);
  }

  @override
  Future<void> deleteContact(String contactId) async {
    String? currentUsername = await LocalStorage.getUsername();
    if (currentUsername == null) {
      throw Exception("Utilisateur non connecté");
    }
    await firestore
        .collection('usernames')
        .doc(currentUsername)
        .collection('contacts')
        .doc(contactId)
        .delete();
  }

  Future<bool> isUsernameAvailable(String username) async {
    DocumentSnapshot snapshot = await firestore.collection('usernames').doc(username).get();
    return !snapshot.exists;
  }

  @override
  Future<bool> doesUsernameExist(String username) async {
    DocumentSnapshot snapshot = await firestore.collection('usernames').doc(username).get();
    return snapshot.exists;
  }
}
