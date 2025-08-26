# Guide d'utilisation des Constantes API

## 📋 Vue d'ensemble

Ce guide explique comment utiliser les constantes API centralisées et le service HTTP dans l'application Zentry.

## 🏗️ Structure

### `ApiConstants` - Constantes centralisées
- **Localisation** : `lib/core/constants/api_constants.dart`
- **Rôle** : Centralise toutes les URLs et configurations API

### `HttpService` - Service HTTP unifié
- **Localisation** : `lib/core/services/http_service.dart`
- **Rôle** : Gère toutes les requêtes HTTP avec une configuration commune

## 🔧 Configuration de base

### URL de base
```dart
// URL de base de l'API
static const String baseUrl = 'http://192.168.0.99:3000/apis/v1';
```

### Endpoints disponibles
```dart
// Authentification
static const String loginEndpoint = '/users/login';
static const String registerEndpoint = '/users/register';
static const String forgotPasswordEndpoint = '/users/forgot-password';

// Projets
static const String projectsEndpoint = '/projects';
static const String createProjectEndpoint = '/projects';

// Tronçons
static const String tronconsEndpoint = '/troncons';
static const String createTronconEndpoint = '/troncons';

// Points d'entrée
static const String pointsEntreeEndpoint = '/points-entree';
static const String createPointEntreeEndpoint = '/points-entree';
```

## 🚀 Utilisation pratique

### 1. URLs complètes pré-construites
```dart
// Utilisation directe des URLs complètes
final loginUrl = ApiConstants.loginUrl;
// Résultat: "http://192.168.0.99:3000/apis/v1/users/login"

final projectsUrl = ApiConstants.projectsUrl;
// Résultat: "http://192.168.0.99:3000/apis/v1/projects"
```

### 2. Construction d'URLs dynamiques
```dart
// Pour des endpoints avec paramètres
final projectId = 123;
final projectDetailUrl = ApiConstants.buildUrl('/projects/$projectId');
// Résultat: "http://192.168.0.99:3000/apis/v1/projects/123"

final tronconId = 456;
final tronconDetailUrl = ApiConstants.buildUrl('/troncons/$tronconId');
// Résultat: "http://192.168.0.99:3000/apis/v1/troncons/456"
```

### 3. Utilisation du service HTTP

#### Requêtes GET
```dart
try {
  // Récupérer tous les projets
  final response = await HttpService.get(ApiConstants.projectsEndpoint);
  final projects = response.data;
  print('Projets récupérés: ${projects.length}');
} catch (e) {
  print('Erreur: $e');
}
```

#### Requêtes POST
```dart
try {
  final projectData = {
    'name': 'Nouveau Projet',
    'description': 'Description du projet',
  };
  
  final response = await HttpService.post(
    ApiConstants.createProjectEndpoint,
    data: projectData,
  );
  
  print('Projet créé avec ID: ${response.data['id']}');
} catch (e) {
  print('Erreur lors de la création: $e');
}
```

#### Authentification avec token
```dart
// Ajouter un token d'authentification
HttpService.setAuthToken('your_jwt_token_here');

// Toutes les requêtes suivantes incluront automatiquement le token
final response = await HttpService.get('/protected-endpoint');

// Supprimer le token lors de la déconnexion
HttpService.removeAuthToken();
```

## 🛠️ Exemple de service complet

```dart
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
```

## ⚙️ Configuration avancée

### Headers personnalisés
```dart
// Headers par défaut (appliqués automatiquement)
static const Map<String, String> defaultHeaders = {
  'Content-Type': 'application/json',
  'Accept': 'application/json',
};

// Pour des headers spécifiques à une requête
final response = await HttpService.post(
  '/endpoint',
  data: data,
  options: Options(
    headers: {'Custom-Header': 'value'},
  ),
);
```

### Timeouts
```dart
// Timeouts configurés globalement
static const Duration connectTimeout = Duration(seconds: 15);
static const Duration receiveTimeout = Duration(seconds: 15);
```

## 🔄 Migration depuis l'ancien système

### Avant (URL en dur)
```dart
final response = await dio.post(
  'http://192.168.0.99:3000/apis/v1/users/login',
  data: data,
  options: Options(
    headers: {'Content-Type': 'application/json'},
  ),
);
```

### Après (avec constantes)
```dart
final response = await HttpService.post(
  ApiConstants.loginEndpoint,
  data: data,
);
```

## ✅ Avantages

1. **🎯 Centralisation** : Toutes les URLs en un seul endroit
2. **🔧 Maintenance facilitée** : Changement d'URL = une seule modification
3. **🛡️ Configuration uniforme** : Headers, timeouts, logs automatiques
4. **📊 Gestion d'erreurs centralisée** : Logs et gestion des erreurs uniformes
5. **🔐 Support d'authentification** : Gestion automatique des tokens
6. **🐛 Debugging amélioré** : Logs détaillés des requêtes HTTP

## 🚨 Bonnes pratiques

1. **Toujours utiliser `ApiConstants`** pour les URLs
2. **Utiliser `HttpService`** au lieu de créer des instances Dio
3. **Gérer les erreurs** avec try/catch appropriés
4. **Utiliser les endpoints** plutôt que les URLs complètes
5. **Nettoyer les tokens** lors de la déconnexion

## 📝 Notes importantes

- Les constantes sont immutables (`const`)
- Le service HTTP utilise un singleton Dio configuré
- Les logs sont automatiquement générés en mode debug
- La gestion d'erreurs est centralisée et uniforme 