import 'package:dio/dio.dart';
import '../constants/api_constants.dart';

/// Service HTTP centralisé pour toutes les requêtes API
class HttpService {
  static Dio? _dio;
  
  /// Instance singleton de Dio configurée
  static Dio get instance {
    _dio ??= _createDio();
    return _dio!;
  }
  
  /// Crée et configure l'instance Dio
  static Dio _createDio() {
    final dio = Dio();
    
    // Configuration de base
    dio.options.baseUrl = ApiConstants.baseUrl;
    dio.options.headers.addAll(ApiConstants.defaultHeaders);
    dio.options.connectTimeout = ApiConstants.connectTimeout;
    dio.options.receiveTimeout = ApiConstants.receiveTimeout;
    
    // Intercepteur pour les logs (en mode debug)
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: false,
        responseHeader: false,
        error: true,
        logPrint: (obj) {
          // En production, on pourrait utiliser un logger plus sophistiqué
          print('[HTTP] $obj');
        },
      ),
    );
    
    // Intercepteur pour la gestion des erreurs
    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          _handleError(error);
          handler.next(error);
        },
      ),
    );
    
    return dio;
  }
  
  /// Gestion centralisée des erreurs HTTP
  static void _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        print('[HTTP ERROR] Délai de connexion dépassé');
        break;
      case DioExceptionType.sendTimeout:
        print('[HTTP ERROR] Délai d\'envoi dépassé');
        break;
      case DioExceptionType.receiveTimeout:
        print('[HTTP ERROR] Délai de réception dépassé');
        break;
      case DioExceptionType.badResponse:
        print('[HTTP ERROR] Réponse invalide: ${error.response?.statusCode}');
        break;
      case DioExceptionType.cancel:
        print('[HTTP ERROR] Requête annulée');
        break;
      case DioExceptionType.connectionError:
        print('[HTTP ERROR] Erreur de connexion');
        break;
      case DioExceptionType.badCertificate:
        print('[HTTP ERROR] Certificat SSL invalide');
        break;
      case DioExceptionType.unknown:
        print('[HTTP ERROR] Erreur inconnue: ${error.message}');
        break;
    }
  }
  
  /// Requête GET
  static Future<Response<T>> get<T>(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await instance.get<T>(
      endpoint,
      queryParameters: queryParameters,
      options: options,
    );
  }
  
  /// Requête POST
  static Future<Response<T>> post<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    print('[HTTP POST] Request body: $data');
    return await instance.post<T>(
      endpoint,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
  
  /// Requête PUT
  static Future<Response<T>> put<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await instance.put<T>(
      endpoint,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
  
  /// Requête DELETE
  static Future<Response<T>> delete<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await instance.delete<T>(
      endpoint,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
  
  /// Ajouter un token d'authentification aux headers
  static void setAuthToken(String token) {
    instance.options.headers['Authorization'] = 'Bearer $token';
  }
  
  /// Supprimer le token d'authentification
  static void removeAuthToken() {
    instance.options.headers.remove('Authorization');
  }
  
  /// Réinitialiser l'instance (utile pour les tests)
  static void reset() {
    _dio?.close();
    _dio = null;
  }
} 