import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

/// Service pour gérer les données utilisateur
class UserService {
  static const _storage = FlutterSecureStorage();
  static const _keyUserData = 'user_data';

  /// Récupère les données utilisateur stockées
  static Future<Map<String, dynamic>?> getUserData() async {
    try {
      final userDataString = await _storage.read(key: _keyUserData);
      if (userDataString != null) {
        return json.decode(userDataString);
      }
    } catch (e) {
      print('Erreur lors de la récupération des données utilisateur: $e');
    }
    return null;
  }

  /// Récupère le nom complet de l'utilisateur (prénom + nom)
  static Future<String> getUserFullName() async {
    try {
      final userData = await getUserData();
      if (userData != null) {
        final prenom = userData['prenom'] ?? userData['firstName'] ?? '';
        final nom = userData['nom'] ?? userData['lastName'] ?? '';
        return '$prenom $nom'.trim();
      }
    } catch (e) {
      print('Erreur lors de la récupération du nom utilisateur: $e');
    }
    
    // Données par défaut si pas de données stockées
    return _getMockUserData();
  }

  /// Récupère l'email de l'utilisateur
  static Future<String> getUserEmail() async {
    try {
      final userData = await getUserData();
      if (userData != null && userData['email'] != null) {
        return userData['email'];
      }
    } catch (e) {
      print('Erreur lors de la récupération de l\'email utilisateur: $e');
    }
    return 'jean.dupont@exemple.fr';
  }

  /// Sauvegarde les données utilisateur
  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    try {
      await _storage.write(key: _keyUserData, value: json.encode(userData));
    } catch (e) {
      print('Erreur lors de la sauvegarde des données utilisateur: $e');
    }
  }

  /// Données utilisateur mockées pour le développement
  static String _getMockUserData() {
    return 'Jean Dupont'; // Nom par défaut
  }

  /// Récupère les informations complètes de l'utilisateur
  static Future<Map<String, dynamic>> getCompleteUserInfo() async {
    try {
      final userData = await getUserData();
      if (userData != null) {
        return userData;
      }
    } catch (e) {
      print('Erreur lors de la récupération des informations utilisateur: $e');
    }
    
    // Retourner les données mockées par défaut
    return {
      'prenom': 'Jean',
      'nom': 'Dupont',
      'email': 'jean.dupont@exemple.fr',
      'telephone': '+33 1 23 45 67 89',
      'fonction': 'Chef de Projet',
      'service': 'Développement',
      'matricule': 'EMP001',
    };
  }
} 