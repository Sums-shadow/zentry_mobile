# Fonctionnalité Carte du Projet

## Description
Cette fonctionnalité permet d'afficher une carte interactive montrant le parcours d'un projet basé sur les coordonnées GPS des images prises lors des inspections de tronçons.

## Fonctionnalités

### 🗺️ Affichage de la carte
- **Carte interactive** : Utilise Google Maps pour afficher le parcours
- **Polyligne** : Trace une ligne reliant tous les points GPS des images
- **Marqueurs** : Affiche des marqueurs pour chaque point avec des couleurs distinctes :
  - 🟢 **Vert** : Point de départ
  - 🔴 **Rouge** : Point d'arrivée  
  - 🔵 **Bleu** : Points intermédiaires

### 📍 Regroupement des points proches
- **Algorithme intelligent** : Regroupe automatiquement les images prises dans un rayon de 50 mètres
- **Point moyen** : Calcule la position moyenne des images regroupées
- **Optimisation** : Évite l'encombrement de la carte avec trop de marqueurs

### 🎯 Ajustement automatique de la vue
- **Zoom adaptatif** : La carte s'ajuste automatiquement pour inclure tous les points
- **Centrage intelligent** : Centre la vue sur l'ensemble du parcours

## Utilisation

### Accès à la carte
1. Ouvrir la page de détail d'un projet
2. Cliquer sur l'icône 🗺️ **"Voir sur la carte"** dans la barre d'actions
3. La carte s'ouvre avec le parcours du projet

### Navigation
- **Zoom** : Pincer pour zoomer/dézoomer
- **Déplacement** : Glisser pour naviguer
- **Informations** : Cliquer sur un marqueur pour voir les coordonnées

## Gestion des cas spéciaux

### Aucune coordonnée disponible
- Affiche un message informatif
- Propose de retourner au projet

### Erreur de chargement
- Affiche un message d'erreur détaillé
- Bouton pour réessayer

### Chargement
- Indicateur de progression
- Message de statut

## Configuration technique

### Dépendances ajoutées
```yaml
dependencies:
  google_maps_flutter: ^2.9.0
  intl: ^0.20.2
```

### Fichiers créés
- `lib/presentation/pages/maps/projet_map_page.dart` : Page principale de la carte
- Route ajoutée dans `lib/core/routing/app_router.dart`
- Constante ajoutée dans `lib/core/constants/app_routes.dart`

### Permissions requises
Pour Android, ajouter dans `android/app/src/main/AndroidManifest.xml` :
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.INTERNET" />
```

### Clé API Google Maps
Ajouter votre clé API Google Maps dans :
- Android : `android/app/src/main/AndroidManifest.xml`
- iOS : `ios/Runner/AppDelegate.swift`

## Algorithme de regroupement

```dart
// Regroupement des points dans un rayon de 50 mètres
List<LatLng> _groupNearbyCoordinates(List<LatLng> coordinates, double radiusInMeters) {
  // 1. Parcourt tous les points
  // 2. Trouve les points proches (< 50m)
  // 3. Calcule la moyenne des coordonnées du groupe
  // 4. Retourne la liste des points moyens
}
```

## Formule de distance
Utilise la formule de Haversine pour calculer la distance entre deux points GPS :

```dart
double _calculateDistance(LatLng point1, LatLng point2) {
  // Formule de Haversine pour la distance sur une sphère
  // Retourne la distance en mètres
}
```

## Améliorations futures possibles
- 🎨 Personnalisation des couleurs de la polyligne
- 📊 Affichage de statistiques (distance totale, nombre d'images)
- 🖼️ Aperçu des images au clic sur un marqueur
- 🌐 Support d'autres fournisseurs de cartes (OpenStreetMap, Mapbox)
- 📱 Mode hors ligne avec cartes mises en cache 