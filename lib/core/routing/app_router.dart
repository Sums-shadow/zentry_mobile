import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../presentation/pages/splash/splash_screen.dart';
import '../../presentation/providers/auth_provider.dart';
import '../../presentation/pages/auth/login_page.dart';
import '../../presentation/pages/auth/forgot_password_page.dart';
import '../../presentation/pages/dashboard/dashboard_page.dart';
import '../../presentation/pages/projet/projet_list_page.dart';
import '../../presentation/pages/projet/new_projet_form_page.dart';
import '../../presentation/pages/projet/projet_detail_page.dart';
import '../../presentation/pages/point_entree/new_point_entree_page.dart';
import '../../presentation/pages/point_entree/point_entree_detail_page.dart';
import '../../presentation/pages/rapport/rapport_page.dart';
import '../../presentation/pages/profil/profil_page.dart';
import '../../presentation/pages/parametre/parametre_page.dart';
import '../../presentation/pages/troncons/troncons_list_page.dart';
import '../constants/app_routes.dart';
import '../../presentation/pages/troncons/new_troncons.dart';
import '../../presentation/pages/troncons/troncons_detail_redesigned.dart';
import '../../presentation/pages/maps/projet_map_page.dart';
import '../../domain/entities/projet.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    redirect: (context, state) {
      final isAuthenticated = ref.read(isAuthenticatedProvider);
      final isLoading = ref.read(authProvider).isLoading;
      
      // Si on est en train de charger l'état d'auth, rester sur splash
      if (isLoading && state.fullPath == AppRoutes.splash) {
        return null;
      }
      
      // Pages publiques (pas besoin d'être connecté)
      final publicRoutes = [
        AppRoutes.splash,
        AppRoutes.login,
        AppRoutes.forgotPassword,
      ];
      
      // Si on est sur une page publique
      if (publicRoutes.contains(state.fullPath)) {
        // Si on est connecté et sur login, rediriger vers dashboard
        if (isAuthenticated && state.fullPath == AppRoutes.login) {
          return AppRoutes.dashboard;
        }
        return null; // Laisser accéder aux pages publiques
      }
      
      // Pour toutes les autres pages, vérifier l'authentification
      if (!isAuthenticated) {
        return AppRoutes.login;
      }
      
      return null; // Laisser continuer si authentifié
    },
    routes: [
      // Splash Screen
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      
      // Auth Routes
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      
      // Dashboard
      GoRoute(
        path: AppRoutes.dashboard,
        name: 'dashboard',
        builder: (context, state) => const DashboardPage(),
      ),
      
      // Projet Routes
      GoRoute(
        path: AppRoutes.projets,
        name: 'projets',
        builder: (context, state) => const ProjetListPage(),
      ),
      GoRoute(
        path: AppRoutes.newProjet,
        name: 'new-projet',
        builder: (context, state) => const NewProjetFormPage(),
      ),
      GoRoute(
        path: '${AppRoutes.projetDetail}/:id',
        name: 'projet-detail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ProjetDetailPage(projetId: id);
        },
      ),
      
      // Point d'entrée Routes
      GoRoute(
        path: '${AppRoutes.newPointEntree}/:projetId',
        name: 'new-point-entree',
        builder: (context, state) {
          final projetId = state.pathParameters['projetId']!;
          return NewPointEntreePage(projetId: projetId);
        },
      ),
      GoRoute(
        path: '${AppRoutes.pointEntreeDetail}/:id',
        name: 'point-entree-detail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return PointEntreeDetailPage(pointEntreeId: id);
        },
      ),

      // Tronçon Routes
      GoRoute(
        path: '${AppRoutes.newTroncon}/:projetId',
        name: 'new-troncon',
        builder: (context, state) {
          final projetId = int.parse(state.pathParameters['projetId']!);
          return NewTronconFormPage(projetId: projetId);
        },
      ),
      GoRoute(
        path: '/projets/:projetId/troncons',
        name: 'troncons-list',
        builder: (context, state) {
          final projetId = state.pathParameters['projetId']!;
          final extra = state.extra as Map<String, dynamic>?;
          final projetNom = extra?['projetNom'] ?? 'Projet';
          return TronconsListPage(
            projetId: projetId,
            projetNom: projetNom,
          );
        },
      ),
      GoRoute(
        path: '/troncons/:id/detail',
        name: 'troncon-detail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return TronconDetailRedesignedPage(tronconId: id);
        },
      ),
      GoRoute(
        path: '/projets/:projetId/troncons/:tronconId',
        name: 'troncon-detail-alt',
        builder: (context, state) {
          final tronconId = state.pathParameters['tronconId']!;
          return TronconDetailRedesignedPage(tronconId: tronconId);
        },
      ),
      
      // Rapport
      GoRoute(
        path: AppRoutes.rapport,
        name: 'rapport',
        builder: (context, state) => const RapportPage(),
      ),
      
      // Profil
      GoRoute(
        path: AppRoutes.profil,
        name: 'profil',
        builder: (context, state) => const ProfilPage(),
      ),
      
      // Paramètres
      GoRoute(
        path: AppRoutes.parametre,
        name: 'parametre',
        builder: (context, state) => const ParametrePage(),
      ),
      
      // Carte du projet
      GoRoute(
        path: '${AppRoutes.projetMap}/:id',
        name: 'projet-map',
        builder: (context, state) {
          final extra = state.extra as Projet?;
          if (extra != null) {
            return ProjetMapPage(projet: extra);
          }
          // Fallback si le projet n'est pas passé en extra
          throw Exception('Projet requis pour afficher la carte');
        },
      ),
    ],
  );
}); 