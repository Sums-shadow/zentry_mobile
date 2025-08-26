# Fonctionnalité Carte des Images

## Description
Cette fonctionnalité permet d'afficher une carte interactive pour chaque image dans la page de détail du tronçon, montrant la localisation exacte où la photo a été prise.

## Fonctionnalités

### 📸 Visualisation des images avec carte
- **Galerie d'images** : Affichage en grille des images du tronçon
- **Clic sur image** : Ouvre un visualiseur plein écran avec les détails
- **Mini carte intégrée** : Carte Google Maps sous chaque image avec coordonnées GPS
- **Marqueur précis** : Indication de la position exacte de prise de vue

### 🗺️ Mini carte dans le visualiseur d'images
- **Taille optimisée** : Carte de 200px de hauteur sous l'image
- **Zoom adapté** : Niveau de zoom 16 pour voir les détails environnants
- **Type hybride** : Vue satellite avec noms des rues
- **Marqueur rouge** : Position exacte de la photo
- **Info-bulle** : Affiche le numéro de photo et date de prise

### 🔍 Mode plein écran
- **Bouton fullscreen** : Icône en haut à droite de la mini carte
- **Carte étendue** : Vue plein écran avec tous les contrôles activés
- **Zoom élevé** : Niveau 18 pour maximum de détails
- **Contrôles complets** : Zoom, rotation, inclinaison activés
- **Bouton info** : Affiche les coordonnées exactes dans une popup

### 📍 Informations de localisation
- **Coordonnées GPS** : Latitude et longitude avec 6 décimales
- **Altitude** : Si disponible, affichée en mètres
- **Date et heure** : Timestamp précis de la prise de vue
- **Formatage** : Affichage en français (dd/MM/yyyy HH:mm)

## Interface utilisateur

### Dans la galerie d'images
```
┌─────────────────────────────────────┐
│ 📸 Galerie photos (3)               │
├─────────────────────────────────────┤
│ [Image 1] [Image 2]                 │
│ [Image 3] [Image 4]                 │
└─────────────────────────────────────┘
```

### Dans le visualiseur d'image
```
┌─────────────────────────────────────┐
│ ← Photo 1 sur 3                     │
├─────────────────────────────────────┤
│                                     │
│        [IMAGE PRINCIPALE]           │
│                                     │
├─────────────────────────────────────┤
│ 📍 Coordonnées GPS                  │
│ Lat: -4.123456°                     │
│ Lng: 15.789012°                     │
│ Alt: 345.2m                         │
│                                     │
│ ┌─────────────────────────┐ [🔍]    │
│ │                         │         │
│ │     [MINI CARTE]        │         │
│ │         📍              │         │
│ │                         │         │
│ └─────────────────────────┘         │
│                                     │
│ Prise le 15/12/2024 à 14:30        │
└─────────────────────────────────────┘
```

### En mode plein écran
```
┌─────────────────────────────────────┐
│ ← Localisation - Photo 1        ℹ️  │
├─────────────────────────────────────┤
│                                     │
│                                     │
│         [CARTE PLEIN ÉCRAN]         │
│               📍                    │
│                                     │
│                                     │
└─────────────────────────────────────┘
```

## Utilisation

### Accès aux cartes d'images
1. Ouvrir un tronçon avec des images géolocalisées
2. Dans la section "📸 Galerie photos", cliquer sur une image
3. La carte s'affiche automatiquement sous l'image si elle a des coordonnées GPS
4. Naviguer entre les images avec les gestes de swipe

### Navigation dans la carte
- **Mini carte** : Zoom et déplacement limités pour préservation de l'UX
- **Bouton plein écran** : Cliquer sur l'icône 🔍 en haut à droite
- **Mode plein écran** : Tous les gestes et contrôles activés
- **Bouton info** : Affiche les détails de localisation

### Informations détaillées
- **Popup info** : Cliquer sur le bouton ℹ️ en mode plein écran
- **Coordonnées précises** : Latitude/longitude avec 6 décimales
- **Altitude** : Si captée par le GPS de l'appareil
- **Horodatage** : Date et heure exactes de la prise de vue

## Gestion des cas spéciaux

### Images sans coordonnées GPS
- La carte n'est pas affichée
- Seules les informations de date sont visibles
- Message informatif possible (à implémenter)

### Erreur de chargement de carte
- Fallback gracieux vers les informations textuelles
- Gestion des erreurs de réseau
- Retry automatique possible

### Permissions de localisation
- Aucune permission supplémentaire requise
- Utilise uniquement les coordonnées stockées avec l'image
- Pas d'accès à la localisation en temps réel

## Configuration technique

### Dépendances utilisées
```yaml
dependencies:
  google_maps_flutter: ^2.9.0
  intl: ^0.20.2
```

### Widgets créés
- `_ImageLocationMap` : Mini carte intégrée
- `_FullScreenImageMap` : Vue plein écran
- Modification de `_ImageViewerPage` : Intégration des cartes

### Paramètres de carte
```dart
// Mini carte
zoom: 16.0
mapType: MapType.hybrid
scrollGesturesEnabled: true
zoomGesturesEnabled: true
rotateGesturesEnabled: false
tiltGesturesEnabled: false

// Plein écran
zoom: 18.0
mapType: MapType.hybrid
// Tous les gestes activés
```

## Performance et optimisation

### Optimisations implémentées
- **Chargement différé** : Cartes créées uniquement lors de l'affichage
- **Contrôles limités** : Mini carte avec interactions réduites
- **Marqueurs simples** : Un seul marqueur par carte
- **Zoom adaptatif** : Niveaux optimisés pour chaque contexte

### Considérations réseau
- **Cache automatique** : Google Maps gère le cache des tuiles
- **Mode hors ligne** : Cartes précédemment vues disponibles
- **Fallback** : Informations textuelles si carte indisponible

## Améliorations futures

### Fonctionnalités possibles
- 🎯 **Navigation GPS** : Bouton "Y aller" vers la position
- 📊 **Métadonnées EXIF** : Extraction automatique des coordonnées
- 🌐 **Partage de position** : Lien vers Google Maps/Apple Maps
- 📷 **Miniature sur carte** : Aperçu de l'image sur le marqueur
- 🔄 **Synchronisation** : Mise à jour des coordonnées en temps réel
- 📍 **Géofencing** : Alertes si image prise hors zone projet
- 🗂️ **Regroupement** : Clustering des images proches
- 📐 **Mesures** : Distance entre images, surface couverte

### Améliorations UX
- **Animations** : Transitions fluides entre images
- **Préchargement** : Cartes des images suivantes
- **Gestures** : Pinch-to-zoom dans la mini carte
- **Thème sombre** : Style de carte adapté au mode nuit
- **Indicateurs** : Boussole, échelle, coordonnées en temps réel

## Intégration avec l'existant

### Compatibilité
- ✅ Fonctionne avec toutes les images existantes
- ✅ Rétrocompatible avec images sans GPS
- ✅ Respect du thème de l'application
- ✅ Navigation cohérente avec le reste de l'app

### Tests recommandés
1. **Images avec GPS** : Vérifier affichage correct de la carte
2. **Images sans GPS** : Confirmer masquage gracieux
3. **Navigation** : Swipe entre images avec cartes
4. **Performance** : Temps de chargement des cartes
5. **Réseau** : Comportement en mode hors ligne 