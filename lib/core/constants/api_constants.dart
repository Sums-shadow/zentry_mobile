/// Constantes pour les API et endpoints
class ApiConstants {
  // URL de base de l'API
  static const String baseUrl = 'http://192.168.2.12:3000/apis/v1';
  
  // Endpoints d'authentification
  static const String loginEndpoint = '/users/login';
  static const String registerEndpoint = '/users/register';
  static const String forgotPasswordEndpoint = '/users/forgot-password';
  static const String resetPasswordEndpoint = '/users/reset-password';
  
  // Endpoints des projets
  static const String projectsEndpoint = '/projects';
  static const String createProjectEndpoint = '/projects';
  static const String syncProjectEndpoint = '/projects/sync';
  
  // Endpoints des tronçons
  static const String tronconsEndpoint = '/troncons';
  static const String createTronconEndpoint = '/troncons';
  
  // Endpoints des points d'entrée
  static const String pointsEntreeEndpoint = '/points-entree';
  static const String createPointEntreeEndpoint = '/points-entree';
  
  // Headers communs
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
  
  /// Construit l'URL complète pour un endpoint
  static String buildUrl(String endpoint) {
    return '$baseUrl$endpoint';
  }
  
  /// URL complète pour la connexion
  static String get loginUrl => buildUrl(loginEndpoint);
  
  /// URL complète pour l'inscription
  static String get registerUrl => buildUrl(registerEndpoint);
  
  /// URL complète pour mot de passe oublié
  static String get forgotPasswordUrl => buildUrl(forgotPasswordEndpoint);
  
  /// URL complète pour les projets
  static String get projectsUrl => buildUrl(projectsEndpoint);
  
  /// URL complète pour les tronçons
  static String get tronconsUrl => buildUrl(tronconsEndpoint);
  
  /// URL complète pour les points d'entrée
  static String get pointsEntreeUrl => buildUrl(pointsEntreeEndpoint);
} 