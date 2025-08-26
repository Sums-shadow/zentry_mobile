# ZENTRY - Portail Agent

Application Flutter pour la gestion de projets et points d'entrée avec routing et gestion d'état Riverpod.

## ✨ Fonctionnalités

### Pages principales
- **SplashScreen** - Écran de chargement de l'application
- **LoginPage** - Page de connexion avec validation de formulaire
- **ForgotPasswordPage** - Page de récupération de mot de passe
- **DashboardPage** - Tableau de bord principal avec statistiques
- **ProjetListPage** - Liste des projets avec recherche et filtres
- **NewProjetFormPage** - Formulaire de création de projet
- **ProjetDetailPage** - Détails d'un projet avec gestion des points d'entrée
- **NewPointEntreePage** - Formulaire de création de point d'entrée
- **PointEntreeDetailPage** - Détails d'un point d'entrée
- **RapportPage** - Page des rapports avec graphiques et statistiques
- **ProfilPage** - Profil utilisateur avec modification des informations
- **ParametrePage** - Paramètres de l'application

### Technologies utilisées
- **Flutter** - Framework principal
- **Riverpod** - Gestion d'état
- **GoRouter** - Navigation et routing
- **FormBuilder** - Gestion des formulaires avec validation
- **Material Design 3** - Interface utilisateur moderne

## 🏗️ Structure du projet

```
lib/
├── core/
│   ├── constants/
│   │   └── app_routes.dart          # Constantes des routes
│   └── routing/
│       └── app_router.dart          # Configuration du router
├── presentation/
│   └── pages/
│       ├── splash/
│       │   └── splash_screen.dart
│       ├── auth/
│       │   ├── login_page.dart
│       │   └── forgot_password_page.dart
│       ├── dashboard/
│       │   └── dashboard_page.dart
│       ├── projet/
│       │   ├── projet_list_page.dart
│       │   ├── new_projet_form_page.dart
│       │   └── projet_detail_page.dart
│       ├── point_entree/
│       │   ├── new_point_entree_page.dart
│       │   └── point_entree_detail_page.dart
│       ├── rapport/
│       │   └── rapport_page.dart
│       ├── profil/
│       │   └── profil_page.dart
│       └── parametre/
│           └── parametre_page.dart
└── main.dart                        # Point d'entrée de l'application
```

## 🚀 Installation et lancement

### Prérequis
- Flutter SDK (>=3.8.1)
- Dart SDK
- Un émulateur Android/iOS ou un appareil physique

### Installation
1. Clonez le repository
```bash
git clone <repository-url>
cd zentry
```

2. Installez les dépendances
```bash
flutter pub get
```

3. Lancez l'application
```bash
flutter run
```

## 🧭 Navigation

L'application utilise **GoRouter** pour la navigation avec les routes suivantes :

- `/` - SplashScreen (page d'accueil)
- `/login` - Page de connexion
- `/forgot-password` - Récupération de mot de passe
- `/dashboard` - Tableau de bord
- `/projets` - Liste des projets
- `/new-projet` - Nouveau projet
- `/projet-detail/:id` - Détails d'un projet
- `/new-point-entree/:projetId` - Nouveau point d'entrée
- `/point-entree-detail/:id` - Détails d'un point d'entrée
- `/rapport` - Rapports
- `/profil` - Profil utilisateur
- `/parametre` - Paramètres

## 🎨 Thème et design

L'application utilise **Material Design 3** avec :
- Couleur principale : Bleu (#2196F3)
- Support du mode sombre/clair
- Composants arrondis (border radius 12px)
- Animations et transitions fluides

## 📱 Fonctionnalités par page

### SplashScreen
- Animation de chargement
- Redirection automatique vers la page de connexion

### LoginPage
- Formulaire de connexion avec validation
- Champs email et mot de passe
- Lien vers la récupération de mot de passe
- Simulation d'authentification

### DashboardPage
- Vue d'ensemble avec statistiques
- Cartes d'actions rapides
- Menu de navigation
- Notifications

### ProjetListPage
- Liste des projets avec recherche
- Filtres par statut
- Actions rapides sur chaque projet
- Bouton de création de nouveau projet

### NewProjetFormPage
- Formulaire complet de création de projet
- Validation des champs
- Sélection de dates
- Configuration des paramètres

### ProjetDetailPage
- Informations détaillées du projet
- Liste des points d'entrée
- Statistiques du projet
- Actions de gestion

### NewPointEntreePage
- Formulaire de création de point d'entrée
- Localisation avec coordonnées GPS
- Configuration de sécurité
- Instructions d'accès

### PointEntreeDetailPage
- Détails complets du point d'entrée
- Carte de localisation
- Statistiques d'utilisation
- Actions rapides

### RapportPage
- Graphiques et statistiques
- Filtres par période
- Export des données
- Rapports personnalisés

### ProfilPage
- Informations personnelles
- Statistiques utilisateur
- Changement de mot de passe
- Actions de compte

### ParametrePage
- Configuration des notifications
- Paramètres d'apparence
- Sécurité et confidentialité
- Support et aide

## 🔧 Personnalisation

### Ajouter une nouvelle page
1. Créez le fichier dans le dossier approprié sous `lib/presentation/pages/`
2. Ajoutez la route dans `lib/core/constants/app_routes.dart`
3. Configurez la route dans `lib/core/routing/app_router.dart`

### Modifier le thème
Les couleurs et styles sont configurés dans `lib/main.dart` dans la propriété `theme` de `MaterialApp.router`.

## 📦 Dépendances principales

```yaml
dependencies:
  flutter_riverpod: ^2.6.1      # Gestion d'état
  go_router: ^16.1.0            # Navigation
  flutter_form_builder: ^10.1.0 # Formulaires
  form_builder_validators: ^11.2.0 # Validation
  dio: ^5.8.0+1                 # HTTP client
  flutter_secure_storage: ^9.2.4 # Stockage sécurisé
  lottie: ^3.3.1               # Animations
```

## 🔐 Authentification

L'application simule actuellement l'authentification. Pour intégrer une vraie authentification :
1. Configurez votre service d'authentification
2. Implémentez les providers Riverpod pour l'état d'authentification
3. Ajoutez des guards de route dans le router

## 🌟 Fonctionnalités avancées

- **Thème adaptatif** (clair/sombre selon le système)
- **Formulaires avec validation** en temps réel
- **Navigation contextuelle** avec paramètres
- **Interface responsive** qui s'adapte aux écrans
- **Gestion d'état réactive** avec Riverpod
- **Animations fluides** entre les pages

## 🤝 Contribution

1. Forkez le projet
2. Créez une branche pour votre fonctionnalité (`git checkout -b feature/nouvelle-fonctionnalite`)
3. Committez vos changements (`git commit -am 'Ajoute nouvelle fonctionnalité'`)
4. Pushez vers la branche (`git push origin feature/nouvelle-fonctionnalite`)
5. Créez une Pull Request

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier `LICENSE` pour plus de détails.

---

**ZENTRY** - Portail Agent pour la gestion efficace de projets et points d'entrée.
