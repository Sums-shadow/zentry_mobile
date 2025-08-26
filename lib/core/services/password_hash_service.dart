import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

/// Service pour hacher et vérifier les mots de passe de manière sécurisée
class PasswordHashService {
  /// Génère un salt aléatoire pour le hachage
  static String _generateSalt([int length = 32]) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*';
    final random = Random.secure();
    return List.generate(length, (index) => chars[random.nextInt(chars.length)]).join();
  }

  /// Hache un mot de passe avec un salt
  static String hashPassword(String password) {
    // Générer un salt unique pour ce mot de passe
    final salt = _generateSalt();
    
    // Combiner le mot de passe avec le salt
    final saltedPassword = password + salt;
    
    // Hacher avec SHA-256
    final bytes = utf8.encode(saltedPassword);
    final digest = sha256.convert(bytes);
    
    // Retourner le hash avec le salt (séparés par :)
    return '$salt:${digest.toString()}';
  }

  /// Vérifie si un mot de passe correspond au hash stocké
  static bool verifyPassword(String password, String storedHash) {
    try {
      // Séparer le salt du hash
      final parts = storedHash.split(':');
      if (parts.length != 2) {
        return false; // Format invalide
      }
      
      final salt = parts[0];
      final hash = parts[1];
      
      // Recréer le hash avec le mot de passe fourni et le salt stocké
      final saltedPassword = password + salt;
      final bytes = utf8.encode(saltedPassword);
      final digest = sha256.convert(bytes);
      
      // Comparer les hash
      return digest.toString() == hash;
    } catch (e) {
      print('Erreur lors de la vérification du mot de passe: $e');
      return false;
    }
  }

  /// Vérifie si une chaîne semble être un hash (contient un salt et un hash)
  static bool isHashedPassword(String value) {
    final parts = value.split(':');
    return parts.length == 2 && parts[0].length >= 16 && parts[1].length == 64;
  }

  /// Génère un hash de test pour les tests unitaires
  static String generateTestHash(String password) {
    return hashPassword(password);
  }
} 