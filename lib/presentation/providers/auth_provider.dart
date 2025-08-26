import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/auth_service.dart';

/// État d'authentification
class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? userEmail;
  final DateTime? lastLoginTime;
  final bool isOfflineMode;

  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.userEmail,
    this.lastLoginTime,
    this.isOfflineMode = false,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? userEmail,
    DateTime? lastLoginTime,
    bool? isOfflineMode,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      userEmail: userEmail ?? this.userEmail,
      lastLoginTime: lastLoginTime ?? this.lastLoginTime,
      isOfflineMode: isOfflineMode ?? this.isOfflineMode,
    );
  }
}

/// Notifier pour gérer l'état d'authentification
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState()) {
    _checkInitialAuthState();
  }

  /// Vérifie l'état d'authentification au démarrage de l'app
  Future<void> _checkInitialAuthState() async {
    state = state.copyWith(isLoading: true);
    
    try {
      final isAuth = await AuthService.isAuthenticated();
      if (isAuth) {
        // Initialiser le token d'authentification
        await AuthService.initializeAuthToken();
        
        final credentials = await AuthService.getStoredCredentials();
        final lastLogin = await AuthService.getLastLoginTime();
        
        state = state.copyWith(
          isAuthenticated: true,
          isLoading: false,
          userEmail: credentials['email'],
          lastLoginTime: lastLogin,
        );
      } else {
        state = state.copyWith(
          isAuthenticated: false,
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isAuthenticated: false,
        isLoading: false,
      );
    }
  }

  /// Connexion avec email et mot de passe
  Future<AuthResult> login(String email, String password) async {
    state = state.copyWith(isLoading: true);
    
    try {
      final result = await AuthService.login(email: email, password: password);
      
      if (result.isSuccess) {
        final lastLogin = await AuthService.getLastLoginTime();
        state = state.copyWith(
          isAuthenticated: true,
          isLoading: false,
          userEmail: email,
          lastLoginTime: lastLogin,
          isOfflineMode: result.isOffline,
        );
      } else {
        state = state.copyWith(
          isAuthenticated: false,
          isLoading: false,
        );
      }
      
      return result;
    } catch (e) {
      state = state.copyWith(
        isAuthenticated: false,
        isLoading: false,
      );
      return AuthResult.failure(message: 'Erreur inattendue');
    }
  }

  /// Déconnexion
  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    
    try {
      await AuthService.logout();
      state = const AuthState();
    } catch (e) {
      // Même en cas d'erreur, on déconnecte l'utilisateur localement
      state = const AuthState();
    }
  }

  /// Rafraîchir l'état d'authentification
  Future<void> refresh() async {
    await _checkInitialAuthState();
  }

  /// Vérifier si les credentials sont expirés
  Future<bool> areCredentialsExpired() async {
    return await AuthService.areCredentialsExpired();
  }
}

/// Provider pour l'état d'authentification
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

/// Provider pour vérifier rapidement si l'utilisateur est connecté
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);
  return authState.isAuthenticated;
});

/// Provider pour obtenir l'email de l'utilisateur connecté
final currentUserEmailProvider = Provider<String?>((ref) {
  final authState = ref.watch(authProvider);
  return authState.userEmail;
});

/// Provider pour vérifier si l'app est en mode hors ligne
final isOfflineModeProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);
  return authState.isOfflineMode;
}); 