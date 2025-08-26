import '../lib/core/constants/api_constants.dart';
import '../lib/core/services/http_service.dart';

/// Exemple d'utilisation des constantes API et du service HTTP
void main() async {
  print('=== EXEMPLE D\'UTILISATION DES API CONSTANTS ===\n');

  // 1. Utilisation des constantes
  print('🌐 URL de base: ${ApiConstants.baseUrl}');
  print('🔐 URL de connexion: ${ApiConstants.loginUrl}');
  print('📋 URL des projets: ${ApiConstants.projectsUrl}');
  print('🛣️  URL des tronçons: ${ApiConstants.tronconsUrl}');
  
  print('\n--- CONSTRUCTION D\'URLS DYNAMIQUES ---');
  
  // 2. Construction d'URLs dynamiques
  final projectId = 123;
  final projectDetailUrl = ApiConstants.buildUrl('/projects/$projectId');
  print('📄 URL détail projet: $projectDetailUrl');
  
  final tronconId = 456;
  final tronconDetailUrl = ApiConstants.buildUrl('/troncons/$tronconId');
  print('🛤️  URL détail tronçon: $tronconDetailUrl');
  
  print('\n--- HEADERS ET CONFIGURATION ---');
  
  // 3. Headers par défaut
  print('📋 Headers par défaut:');
  ApiConstants.defaultHeaders.forEach((key, value) {
    print('   $key: $value');
  });
  
  print('⏱️  Timeout de connexion: ${ApiConstants.connectTimeout}');
  print('⏱️  Timeout de réception: ${ApiConstants.receiveTimeout}');
  
  print('\n--- EXEMPLES D\'UTILISATION DU SERVICE HTTP ---');
  
  // 4. Exemples de requêtes (simulées)
  print('''
// Exemple 1: Récupérer la liste des projets
try {
  final response = await HttpService.get(ApiConstants.projectsEndpoint);
  final projects = response.data;
  print('Projets récupérés: \${projects.length}');
} catch (e) {
  print('Erreur: \$e');
}

// Exemple 2: Créer un nouveau projet
try {
  final projectData = {
    'name': 'Nouveau Projet',
    'description': 'Description du projet',
  };
  
  final response = await HttpService.post(
    ApiConstants.createProjectEndpoint,
    data: projectData,
  );
  
  print('Projet créé avec ID: \${response.data['id']}');
} catch (e) {
  print('Erreur lors de la création: \$e');
}

// Exemple 3: Authentification avec token
HttpService.setAuthToken('your_jwt_token_here');

// Maintenant toutes les requêtes incluront automatiquement le token
final response = await HttpService.get('/protected-endpoint');

// Exemple 4: Suppression du token lors de la déconnexion
HttpService.removeAuthToken();
  ''');
  
  print('\n--- AVANTAGES DE CETTE APPROCHE ---');
  print('''
✅ Centralisation des URLs
✅ Facilité de maintenance
✅ Configuration uniforme
✅ Gestion d'erreurs centralisée
✅ Logs automatiques
✅ Support des tokens d'authentification
✅ Timeouts configurables
  ''');
  
  print('\n=== EXEMPLE TERMINÉ ===');
}

/// Exemple de service utilisant les constantes API
class ProjectService {
  /// Récupérer tous les projets
  static Future<List<dynamic>> getAllProjects() async {
    try {
      final response = await HttpService.get(ApiConstants.projectsEndpoint);
      return response.data['projects'] ?? [];
    } catch (e) {
      print('Erreur lors de la récupération des projets: $e');
      rethrow;
    }
  }
  
  /// Créer un nouveau projet
  static Future<Map<String, dynamic>> createProject({
    required String name,
    required String description,
  }) async {
    try {
      final data = {
        'name': name,
        'description': description,
      };
      
      final response = await HttpService.post(
        ApiConstants.createProjectEndpoint,
        data: data,
      );
      
      return response.data;
    } catch (e) {
      print('Erreur lors de la création du projet: $e');
      rethrow;
    }
  }
  
  /// Récupérer un projet par ID
  static Future<Map<String, dynamic>> getProjectById(int id) async {
    try {
      final endpoint = '/projects/$id';
      final response = await HttpService.get(endpoint);
      return response.data;
    } catch (e) {
      print('Erreur lors de la récupération du projet $id: $e');
      rethrow;
    }
  }
} 