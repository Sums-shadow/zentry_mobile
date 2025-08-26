import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import 'password_hash_service.dart';
import '../constants/api_constants.dart';
import 'http_service.dart';

class AuthService {
  static const _storage = FlutterSecureStorage();
  
  // Clés pour le stockage sécurisé
  static const _keyEmail = 'user_email';
  static const _keyPassword = 'user_password';
  static const _keyIsAuthenticated = 'is_authenticated';
  static const _keyLastLoginTime = 'last_login_time';
  static const _keyUserData = 'user_data';
  static const _keyAuthToken = 'auth_token';

  /// Sauvegarde les credentials après une connexion réussie
  static Future<void> saveCredentials({
    required String email,
    required String password,
    Map<String, dynamic>? userData,
    String? authToken,
  }) async {
    try {
      // Hacher le mot de passe avant de le sauvegarder
      final hashedPassword = PasswordHashService.hashPassword(password);
      
      await _storage.write(key: _keyEmail, value: email);
      await _storage.write(key: _keyPassword, value: hashedPassword);
      await _storage.write(key: _keyIsAuthenticated, value: 'true');
      await _storage.write(key: _keyLastLoginTime, value: DateTime.now().toIso8601String());
      
      if (userData != null) {
        await _storage.write(key: _keyUserData, value: userData.toString());
      }
      
      if (authToken != null) {
        await _storage.write(key: _keyAuthToken, value: authToken);
        // Configurer le token dans HttpService
        HttpService.setAuthToken(authToken);
      }
      
      print('Credentials sauvegardés avec mot de passe haché');
    } catch (e) {
      print('Erreur lors de la sauvegarde des credentials: $e');
    }
  }

  /// Vérifie si l'utilisateur est authentifié localement
  static Future<bool> isAuthenticated() async {
    try {
      final isAuth = await _storage.read(key: _keyIsAuthenticated);
      return isAuth == 'true';
    } catch (e) {
      print('Erreur lors de la vérification de l\'authentification: $e');
      return false;
    }
  }

  /// Récupère le token d'authentification stocké
  static Future<String?> getAuthToken() async {
    try {
      return await _storage.read(key: _keyAuthToken);
    } catch (e) {
      print('Erreur lors de la récupération du token: $e');
      return null;
    }
  }

  /// Récupère les credentials sauvegardés (mot de passe haché)
  static Future<Map<String, String?>> getStoredCredentials() async {
    try {
      final email = await _storage.read(key: _keyEmail);
      final hashedPassword = await _storage.read(key: _keyPassword);
      return {
        'email': email,
        'hashedPassword': hashedPassword,
      };
    } catch (e) {
      print('Erreur lors de la récupération des credentials: $e');
      return {'email': null, 'hashedPassword': null};
    }
  }

  /// Migre un ancien mot de passe en clair vers un mot de passe haché
  /// (pour la rétrocompatibilité)
  static Future<void> _migrateOldPassword(String email, String plainPassword) async {
    try {
      print('Migration d\'un ancien mot de passe vers un hash sécurisé');
      await saveCredentials(email: email, password: plainPassword);
    } catch (e) {
      print('Erreur lors de la migration du mot de passe: $e');
    }
  }

  /// Tentative de connexion avec l'API
  static Future<AuthResult> loginWithAPI({
    required String email,
    required String password,
  }) async {
    try {
      final data = {
        'email': email,
        'password': password,
      };

      final response = await HttpService.post(
        ApiConstants.loginEndpoint,
        data: data,
      );

      if (response.data != null && response.data['status'] == 'success') {
        // Extraire le token de la réponse
        final authToken = response.data['token'] ?? response.data['access_token'];
        
        // Sauvegarder les credentials en cas de succès
        await saveCredentials(
          email: email,
          password: password,
          userData: response.data,
          authToken: authToken,
        );
        
        return AuthResult.success(
          message: 'Connexion réussie !',
          userData: response.data,
        );
      } else {
        return AuthResult.failure(message: 'Identifiants incorrects');
      }
    } catch (e) {
      // Gestion des erreurs réseau
      String errorMessage = 'Erreur de connexion';
      
      if (e is DioException) {
        if (e.response?.statusCode == 401) {
          errorMessage = 'Identifiants incorrects';
        } else if (e.response?.statusCode == 500) {
          errorMessage = 'Erreur serveur';
        } else if (e.type == DioExceptionType.connectionTimeout || 
                   e.type == DioExceptionType.receiveTimeout) {
          errorMessage = 'Délai d\'attente dépassé';
        } else if (e.type == DioExceptionType.connectionError) {
          errorMessage = 'Impossible de se connecter au serveur';
        }
      }
      
      return AuthResult.failure(message: errorMessage);
    }
  }

  /// Tentative de connexion locale (hors ligne)
  static Future<AuthResult> loginOffline({
    required String email,
    required String password,
  }) async {
    try {
      final storedCredentials = await getStoredCredentials();
      final storedEmail = storedCredentials['email'];
      final storedPassword = storedCredentials['hashedPassword'];
      
      // Vérifier l'email
      if (storedEmail != email || storedPassword == null) {
        return AuthResult.failure(
          message: 'Identifiants incorrects (mode hors ligne)',
        );
      }

      // Vérifier si c'est un ancien mot de passe en clair (rétrocompatibilité)
      if (!PasswordHashService.isHashedPassword(storedPassword)) {
        print('Détection d\'un ancien mot de passe en clair, migration en cours...');
        
        // Vérifier le mot de passe en clair
        if (storedPassword == password) {
          // Migrer vers un mot de passe haché
          await _migrateOldPassword(email, password);
          
          return AuthResult.success(
            message: 'Connexion locale réussie ! (Sécurité mise à jour)',
            isOffline: true,
          );
        }
      } else {
        // Vérifier le mot de passe avec le hash stocké
        final isPasswordValid = PasswordHashService.verifyPassword(password, storedPassword);
        
        if (isPasswordValid) {
          print('Connexion locale réussie avec vérification du hash');
          return AuthResult.success(
            message: 'Connexion locale réussie !',
            isOffline: true,
          );
        }
      }
      
      return AuthResult.failure(
        message: 'Identifiants incorrects (mode hors ligne)',
      );
    } catch (e) {
      print('Erreur lors de la vérification locale: $e');
      return AuthResult.failure(
        message: 'Erreur lors de la vérification locale',
      );
    }
  }

  /// Tentative de connexion hybride (API puis local si échec réseau)
  static Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    // D'abord essayer avec l'API
    final apiResult = await loginWithAPI(email: email, password: password);
    
    if (apiResult.isSuccess) {
      return apiResult;
    }
    
    // Si l'API échoue à cause d'un problème réseau, essayer en local
    if (apiResult.message.contains('connexion') || 
        apiResult.message.contains('serveur') ||
        apiResult.message.contains('délai')) {
      
      print('Tentative de connexion locale après échec réseau...');
      return await loginOffline(email: email, password: password);
    }
    
    // Si c'est un problème d'identifiants, ne pas essayer en local
    return apiResult;
  }

  /// Déconnexion (supprime les credentials)
  static Future<void> logout() async {
    try {
      await _storage.delete(key: _keyEmail);
      await _storage.delete(key: _keyPassword);
      await _storage.delete(key: _keyIsAuthenticated);
      await _storage.delete(key: _keyLastLoginTime);
      await _storage.delete(key: _keyUserData);
      await _storage.delete(key: _keyAuthToken);
      
      // Supprimer le token d'HttpService
      HttpService.removeAuthToken();
    } catch (e) {
      print('Erreur lors de la déconnexion: $e');
    }
  }

  /// Récupère la date de dernière connexion
  static Future<DateTime?> getLastLoginTime() async {
    try {
      final timeString = await _storage.read(key: _keyLastLoginTime);
      if (timeString != null) {
        return DateTime.parse(timeString);
      }
    } catch (e) {
      print('Erreur lors de la récupération de la dernière connexion: $e');
    }
    return null;
  }

  /// Vérifie si les credentials sont expirés (optionnel)
  static Future<bool> areCredentialsExpired({int maxDaysOffline = 30}) async {
    final lastLogin = await getLastLoginTime();
    if (lastLogin == null) return true;
    
    final daysSinceLogin = DateTime.now().difference(lastLogin).inDays;
    return daysSinceLogin > maxDaysOffline;
  }

  /// Initialise le token d'authentification au démarrage de l'app
  static Future<void> initializeAuthToken() async {
    try {
      final token = await getAuthToken();
      if (token != null) {
        HttpService.setAuthToken(token);
      }
    } catch (e) {
      print('Erreur lors de l\'initialisation du token: $e');
    }
  }
}

/// Classe pour encapsuler le résultat d'une tentative d'authentification
class AuthResult {
  final bool isSuccess;
  final String message;
  final Map<String, dynamic>? userData;
  final bool isOffline;

  AuthResult._({
    required this.isSuccess,
    required this.message,
    this.userData,
    this.isOffline = false,
  });

  factory AuthResult.success({
    required String message,
    Map<String, dynamic>? userData,
    bool isOffline = false,
  }) {
    return AuthResult._(
      isSuccess: true,
      message: message,
      userData: userData,
      isOffline: isOffline,
    );
  }

  factory AuthResult.failure({required String message}) {
    return AuthResult._(
      isSuccess: false,
      message: message,
    );
  }
} 