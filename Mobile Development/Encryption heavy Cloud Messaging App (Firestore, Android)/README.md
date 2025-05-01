# Documentation du Frontend Chat Sécurisé

## Vue d'ensemble
Ce projet est une application de chat sécurisé pour Android construite avec Flutter. Il utilise Firebase Authentication (via vérification par téléphone) et Firestore pour le stockage des données, tout en fournissant un chiffrement de bout en bout via une approche hybride RSA + AES. L'interface est structurée en composants modulaires qui gèrent l'authentification, la gestion du profil, la messagerie, les contacts et les paramètres. Cette documentation offre un aperçu de l'architecture, détaille les responsabilités de chaque composant, et explique comment utiliser et étendre le frontend.

## Table des matières
- [Vue d'ensemble de l'architecture](#vue-densemble-de-larchitecture)
- [Composants clés](#composants-clés)
  - [Local Storage](#local-storage)
  - [Secure Store](#secure-store)
  - [Crypto Utilities](#crypto-utilities)
  - [Data Repository](#data-repository)
  - [Authentication & Profile](#authentication--profile)
  - [Chats and Messaging](#chats-and-messaging)
  - [Contacts](#contacts)
  - [Settings](#settings)
- [Nouveautés et améliorations](#nouvaut%C3%A9s-et-am%C3%A9liorations)
- [Utilisation du frontend](#utilisation-du-frontend)
- [Extension du frontend](#extension-du-frontend)
- [Résumé](#r%C3%A9sum%C3%A9)

## Vue d'ensemble de l'architecture

Le frontend est construit autour des domaines clés suivants :

### Gestion de l'authentification et du profil
- **Firebase Phone Authentication :** L'application vérifie les utilisateurs en envoyant un code SMS.
- **Configuration du profil :** Après vérification, l'utilisateur est invité à définir un nom d'utilisateur et une phrase de passe.  
  - **Nouvelle amélioration :**  
    Lorsqu'un utilisateur se connecte depuis un nouvel appareil, l'application tente de récupérer l'**enregistrement chiffré de la clé privée** (backup) depuis Firestore. Ce backup est stocké localement et décrypté à l'aide de la phrase de passe fournie.  
    Si la décryption échoue (passphrase incorrecte), l'accès à l'application est bloqué, garantissant ainsi l'intégrité du chiffrement de bout en bout.

### Stockage des données
- **Stockage distant :** Firestore est utilisé pour stocker les profils utilisateur, les messages de chat et les contacts.
- **Local Storage :** SharedPreferences stocke des données spécifiques à l'utilisateur (clés privées chiffrées, noms d'utilisateur, numéros de téléphone, etc.).
- **Secure Storage :** Flutter Secure Storage protège les données sensibles, notamment la phrase de passe permettant de décrypter la clé privée.

### Chiffrement
- **Chiffrement hybride :** Chaque message est chiffré avec une clé AES générée aléatoirement (en utilisant AES-GCM), et la clé AES est ensuite chiffrée avec les clés publiques RSA de l'expéditeur et du destinataire. Cela permet aux deux parties de déchiffrer le message.
- **Crypto Utilities :** La logique de chiffrement, déchiffrement et de génération de clés est fournie par des fonctions utilitaires reposant sur PointyCastle.
- **Nouvelle fonctionnalité :** Le processus de récupération et de déchiffrement du backup de la clé privée assure que l'utilisateur doit fournir la bonne phrase de passe pour accéder à son historique de messages sur plusieurs appareils.

### Écrans de l'interface
- **Écran de vérification par code :** Gère la vérification par SMS et redirige l'utilisateur en fonction de l'état du profil et des clés.
- **Écran de profil :** Configure les détails de l'utilisateur et gère la génération (ou la récupération) de la paire de clés RSA.  
  - *Nouveauté :* La logique a été améliorée pour vérifier et décrypter la clé privée sauvegardée sur Firestore lorsqu'une clé locale n'est pas présente.
- **Écran des chats :** Affiche une liste de conversations avec des aperçus déchiffrés et des horodatages.
- **Écran de détail du chat :** Affiche la conversation complète, les messages déchiffrés et permet l'envoi de nouveaux messages.
- **Écran des contacts :** Permet la gestion des contacts.
- **Écran des paramètres :** Offre des options pour modifier le profil ou se déconnecter.

### Abstraction du dépôt de données
- **Interface DataRepository :** Abstrait les opérations de données (mise à jour du profil, messagerie, gestion des contacts) afin de découpler l'interface utilisateur de l'implémentation Firebase.

## Composants clés

### Local Storage
- **Fichier :** `lib/utils/local_storage.dart`
- **But :** Utilise SharedPreferences pour stocker et récupérer des données spécifiques à l'utilisateur (par exemple, les clés privées chiffrées, noms d'utilisateur, numéros de téléphone et photos de profil).
- **Fonctions clés :**
  - `savePrivateKeyForUid(uid, encryptedPrivateKeyJson)`
  - `getPrivateKeyForUid(uid)`
  - `saveUsername(username)`
  - `getUsername()`

### Secure Store
- **Fichier :** `lib/utils/sercure_store.dart`
- **But :** Utilise Flutter Secure Storage pour stocker de manière sécurisée les données sensibles (comme la phrase de passe pour déchiffrer la clé privée).
- **Fonctions clés :**
  - `savePassphraseForUid(uid, passphrase)`
  - `getPassphraseForUid(uid)`
  - `clearPassphraseForUid(uid)`

### Crypto Utilities
- **Fichier :** `lib/utils/crypto_utils.dart`
- **But :** Fournit des fonctions cryptographiques pour la génération de paires de clés RSA, le chiffrement/déchiffrement avec AES-GCM, et le chiffrement/déchiffrement RSA.
- **Fonctions clés :**
  - `generateRSAKeyPair()`
  - `encryptPrivateKey(privateKeyPem, passphrase)`
  - `decryptPrivateKey(encryptedBase64, ivBase64, passphrase)`
  - `rsaEncrypt(plaintext, publicKey)`
  - `rsaDecrypt(ciphertextBase64, privateKey)`
  - `aesEncrypt(plaintext, aesKey)`
  - `aesDecrypt(ciphertextBase64, ivBase64, aesKey)`

### Data Repository
- **Fichier :** `lib/repositories/data_repository.dart`
- **But :** Définit l'interface DataRepository et fournit une implémentation Firebase qui gère :
  - Les opérations de profil utilisateur (récupération et mise à jour des données)
  - Les opérations de chat (création de chats, envoi et déchiffrement des messages)
  - La gestion des contacts (ajout, récupération et suppression)
- **Avantage :** Découple la logique des données de l'interface, rendant le frontend plus modulaire et évolutif.

### Authentication & Profile

#### Écran de vérification par code :
- **Fichier :** `lib/screens/verification_code.dart`
- **But :** Gère la vérification par SMS via Firebase et redirige l'utilisateur vers l'écran de chat ou de profil en fonction de l'existence d'une clé locale valide.

#### Écran de profil :
- **Fichier :** `lib/screens/profile.dart`
- **But :** Invite l'utilisateur à saisir un nom d'utilisateur et une phrase de passe.  
  - **Nouveauté :**  
    - Si une clé privée locale existe, l'application tente de la déchiffrer avec la phrase de passe fournie.  
    - Si aucune clé locale n'est présente, l'application tente de récupérer un backup chiffré depuis Firestore, le stocke localement et le décrypte avec la phrase de passe.  
    - En cas d'échec de déchiffrement (passphrase incorrecte), l'utilisateur est bloqué jusqu'à ce que la bonne phrase soit fournie.
  - Met à jour le profil utilisateur dans Firestore en incluant la clé publique et le backup de la clé privée.

### Chats and Messaging

#### Écran des chats :
- **Fichier :** `lib/screens/chats.dart`
- **But :** Affiche la liste des conversations actives, avec :
  - Le nom de l'autre participant
  - Un aperçu déchiffré du dernier message (en utilisant une mise en cache pour fluidifier l'UI)
  - L'horodatage du dernier message

#### Écran de détail du chat :
- **Fichier :** `lib/screens/chat_detail.dart`
- **But :** Affiche la conversation complète avec les messages déchiffrés et leurs horodatages, et permet l'envoi de nouveaux messages chiffrés de bout en bout.

### Contacts
- **Fichier :** `lib/screens/contacts.dart`
- **But :** Permet aux utilisateurs de gérer leurs contacts (ajouter, modifier, supprimer). Les contacts sont stockés par utilisateur dans Firestore.

### Settings
- **Fichier :** `lib/screens/settings.dart`
- **But :** Affiche les informations de l'utilisateur (nom, téléphone, photo) et fournit des options pour modifier le profil ou se déconnecter.
  - La déconnexion efface certaines données sensibles locales (comme la phrase de passe) tout en conservant la clé privée pour la restauration ultérieure.

## Nouveautés et améliorations

- **Récupération du backup de la clé privée :**  
  Lorsqu'un utilisateur se connecte sur un nouvel appareil et qu'aucune clé locale n'est présente, l'application tente de récupérer un backup chiffré de la clé privée depuis Firestore.  
  Ce mécanisme permet de restaurer l'accès aux messages précédemment chiffrés sur plusieurs appareils, à condition que la bonne phrase de passe soit fournie.

- **Vérification renforcée de la passphrase :**  
  La décryption du backup de la clé privée est maintenant une étape obligatoire. Si la passphrase est incorrecte, la décryption échoue et l'utilisateur est invité à réessayer, empêchant ainsi l'accès non autorisé.

- **Optimisation de la gestion des erreurs :**  
  Les messages d'erreur clairs et précis sont affichés en cas d'échec de décryption, aidant l'utilisateur à corriger la phrase de passe.

## Utilisation du frontend

### Installation
1. Clonez le dépôt et installez Flutter.
2. Exécutez `flutter pub get` pour installer toutes les dépendances.
3. Configurez votre projet Firebase (Activez Firebase Authentication, Firestore, etc.) et ajoutez le fichier `google-services.json` (Android) ou `GoogleService-Info.plist` (iOS) approprié.

### Authentification
- Lancez l'application. L'utilisateur est d'abord dirigé vers un écran de vérification par téléphone.
- Après une vérification SMS réussie, l'application vérifie l'existence d'une paire de clés RSA.
- Si aucune clé locale n'est trouvée, l'application tente de récupérer le backup depuis Firestore.  
  L'utilisateur doit fournir la bonne phrase de passe pour déchiffrer la clé privée.

### Messagerie
- L'écran des chats affiche toutes les conversations actives.
- Chaque conversation présente le nom de l'autre participant, un aperçu déchiffré du dernier message et l'horodatage du message.
- En sélectionnant une conversation, l'écran de détail du chat affiche la conversation complète et permet l'envoi de nouveaux messages, qui sont tous chiffrés de bout en bout.

### Gestion des contacts et du profil
- Utilisez l'écran des contacts pour gérer vos contacts.
- L'écran des paramètres permet de modifier le profil ou de se déconnecter, effaçant notamment les données sensibles locales.

## Extension du frontend

### Ajout de nouvelles fonctionnalités
Grâce à l'abstraction du dépôt de données, il est facile d'ajouter de nouvelles fonctionnalités (chats de groupe, messages multimédias, notifications, etc.) en étendant les classes existantes et en modifiant l'interface.

### Amélioration de l'UI/UX
Envisagez d'intégrer des solutions de gestion d'état (Provider, Riverpod, Bloc) pour une architecture d'application plus robuste et évolutive. Personnalisez les composants UI pour améliorer l'apparence et l'ergonomie.

### Renforcement du chiffrement
Les fonctions cryptographiques dans `crypto_utils.dart` peuvent être ajustées ou étendues si vous décidez de supporter des algorithmes de chiffrement supplémentaires ou de modifier la stratégie de gestion des clés.

## Résumé
Cette documentation décrit la structure et les fonctionnalités du frontend de chat sécurisé. En comprenant les rôles de chaque composant — de l'authentification et du chiffrement à la gestion des données et à l'interface utilisateur — le projet devient plus facile à utiliser, à maintenir et à étendre. Les développeurs peuvent s'appuyer sur ce guide pour se familiariser rapidement avec la base de code et commencer à ajouter ou modifier des fonctionnalités selon les besoins.

