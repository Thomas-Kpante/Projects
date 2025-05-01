# Processus de chiffrement de bout en bout pour SecureChat

Ce document décrit le processus mis en place pour assurer une communication sécurisée dans l’application SecureChat en utilisant le chiffrement asymétrique et symétrique. Le but est de garantir que seuls les destinataires prévus puissent déchiffrer les messages.

---

## 1. Génération de la paire de clés RSA

Lors de la création (ou de la mise à jour) du profil utilisateur, l’application génère une paire de clés RSA :

- **Clé publique :**  
  - Utilisée pour chiffrer les messages destinés à l’utilisateur.
  - Est stockée dans Firebase dans le document de profil utilisateur (dans la collection "usernames").  
- **Clé privée :**  
  - Doit rester secrète et n’est jamais envoyée au serveur.
  - Pour garantir sa sécurité, elle est chiffrée à l’aide d’un **passphrase** fourni par l’utilisateur.

La fonction `generateRSAKeyPair()` dans **crypto_utils.dart** utilise PointyCastle pour générer la paire de clés. Les clés générées sont ensuite converties (pour ce test, on utilise la méthode `.toString()`, mais en production, il faut les encoder au format PEM).

---

## 2. Dérivation d’une clé symétrique via PBKDF2

Pour chiffrer la clé privée, nous devons d’abord dériver une clé symétrique à partir du passphrase de l’utilisateur :

- La fonction `deriveKey()` utilise l’algorithme PBKDF2 avec HMAC-SHA256 pour transformer le passphrase en une clé symétrique.
- Un sel (salt) est utilisé dans ce processus (pour le test, une valeur par défaut est utilisée, mais en production il faudra un sel aléatoire pour chaque dérivation).

---

## 3. Chiffrement de la clé privée avec AES-GCM

Une fois la clé symétrique dérivée, la clé privée (au format PEM) est chiffrée avec AES-GCM :

- **AES-GCM :**  
  - Offre à la fois confidentialité et intégrité des données.
  - La fonction `encryptPrivateKey()` utilise AES-GCM pour chiffrer la clé privée.
  - Un vecteur d’initialisation (IV) aléatoire de 12 octets est généré pour chaque opération de chiffrement.
  - Le résultat est un objet contenant l’IV et le texte chiffré, tous deux encodés en base64.

- **Stockage local :**  
  - Le résultat (IV et texte chiffré) est converti en JSON et sauvegardé localement via notre helper **LocalStorage** dans SharedPreferences (pour un usage en développement ; pour la production, il est recommandé d’utiliser un stockage sécurisé).

---

## 4. Stockage de la clé publique

La clé publique, qui est utilisée pour chiffrer les messages destinés à l’utilisateur, est ajoutée au document de profil utilisateur dans Firebase. Cela permet aux autres utilisateurs ou dispositifs de récupérer cette clé et de chiffrer les messages de manière à ce que seul le détenteur de la clé privée puisse les déchiffrer.

---

## 5. Récupération et utilisation des clés

- **Clé privée :**  
  - Lorsqu’un utilisateur souhaite déchiffrer un message, l’application récupère la clé privée chiffrée depuis le stockage local.
  - L’utilisateur doit fournir le passphrase pour déchiffrer cette clé via la fonction `decryptPrivateKey()`.
  
- **Clé publique :**  
  - Lorsqu’un utilisateur envoie un message, le destinataire est identifié et son profil est récupéré depuis Firebase pour obtenir sa clé publique.
  - Le message est alors chiffré avec un schéma hybride (généralement, on chiffre le message avec une clé symétrique, et on chiffre cette clé symétrique avec la clé publique du destinataire).

---

## Conclusion

Ce processus garantit que :
- **La clé privée reste sur l’appareil de l’utilisateur,** protégée par un passphrase.
- **La clé publique est disponible sur Firebase,** permettant aux autres d’envoyer des messages chiffrés.
- **Les messages échangés sont protégés,** car même si quelqu’un intercepte les données, il ne pourra pas déchiffrer les messages sans posséder la clé privée déchiffrée.

Ce système pose les bases d’un chiffrement de bout en bout dans SecureChat et peut être étendu pour intégrer le chiffrement hybride des messages.

---

*Note : Pour une sécurité accrue, assurez-vous d’utiliser un sel unique et aléatoire pour chaque dérivation de clé et envisagez d’utiliser un stockage sécurisé (comme `flutter_secure_storage`) pour les données sensibles en production.*
