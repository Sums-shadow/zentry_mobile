# Configuration Google Maps API

## 🔑 Obtenir une clé API Google Maps

### 1. Accéder à Google Cloud Console
1. Aller sur [Google Cloud Console](https://console.cloud.google.com/)
2. Se connecter avec votre compte Google
3. Créer un nouveau projet ou sélectionner un projet existant

### 2. Activer l'API Google Maps
1. Dans le menu de navigation, aller à **APIs & Services > Library**
2. Rechercher et activer les APIs suivantes :
   - **Maps SDK for Android**
   - **Maps SDK for iOS** 
   - **Maps JavaScript API** (optionnel pour le web)

### 3. Créer une clé API
1. Aller à **APIs & Services > Credentials**
2. Cliquer sur **+ CREATE CREDENTIALS > API key**
3. Une clé API sera générée automatiquement
4. **Important** : Copier cette clé immédiatement

### 4. Sécuriser la clé API (Recommandé)
1. Cliquer sur l'icône de modification de la clé API
2. Dans **Application restrictions**, choisir :
   - **Android apps** pour Android
   - **iOS apps** pour iOS
3. Ajouter les restrictions de package :
   - **Android** : `com.example.zentry` (ou votre package name)
   - **iOS** : `com.example.zentry` (ou votre bundle identifier)

## 📱 Configuration dans l'application

### Android
Remplacer `VOTRE_CLE_API_GOOGLE_MAPS_ICI` dans le fichier :
```
android/app/src/main/AndroidManifest.xml
```

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="AIzaSyC4YrIWGcJ8..." />
```

### iOS
Remplacer `VOTRE_CLE_API_GOOGLE_MAPS_ICI` dans le fichier :
```
ios/Runner/AppDelegate.swift
```

```swift
GMSServices.provideAPIKey("AIzaSyC4YrIWGcJ8...")
```

## 🔒 Sécurité et bonnes pratiques

### Variables d'environnement (Recommandé)
Pour éviter d'exposer votre clé API dans le code source :

1. Créer un fichier `.env` à la racine du projet :
```env
GOOGLE_MAPS_API_KEY=AIzaSyC4YrIWGcJ8...
```

2. Ajouter `.env` au fichier `.gitignore`

3. Utiliser un plugin comme `flutter_dotenv` pour charger les variables

### Restrictions IP (Production)
Pour la production, ajouter des restrictions IP dans Google Cloud Console :
1. **APIs & Services > Credentials**
2. Modifier la clé API
3. **Application restrictions > IP addresses**
4. Ajouter les IPs de vos serveurs

## 🚨 Erreurs courantes

### "API key not found"
- Vérifier que la clé est correctement ajoutée dans AndroidManifest.xml et AppDelegate.swift
- S'assurer que les APIs sont activées dans Google Cloud Console

### "This API project is not authorized"
- Vérifier les restrictions de package/bundle dans Google Cloud Console
- S'assurer que le package name correspond exactement

### "Quota exceeded"
- Vérifier les quotas dans Google Cloud Console
- Configurer la facturation si nécessaire

## 💰 Facturation

### Tarification Google Maps
- **Gratuit** : 28 000 chargements de carte par mois
- **Payant** : 7$ pour 1000 chargements supplémentaires

### Optimisation des coûts
- Utiliser le cache de cartes
- Limiter le nombre de marqueurs
- Optimiser les appels API

## 🔧 Test de la configuration

### Vérifier que tout fonctionne
1. Compiler l'application : `flutter build apk --debug`
2. Installer sur un appareil physique
3. Naviguer vers un projet avec des images géolocalisées
4. Cliquer sur l'icône carte 🗺️
5. Vérifier que la carte s'affiche correctement

### Debug des problèmes
- Activer les logs dans Google Cloud Console
- Vérifier les logs de l'application avec `flutter logs`
- Tester d'abord avec une clé sans restrictions

## 📖 Ressources utiles
- [Documentation Google Maps Flutter](https://pub.dev/packages/google_maps_flutter)
- [Google Cloud Console](https://console.cloud.google.com/)
- [Tarification Google Maps](https://cloud.google.com/maps-platform/pricing)
- [Bonnes pratiques sécurité](https://developers.google.com/maps/api-security-best-practices) 