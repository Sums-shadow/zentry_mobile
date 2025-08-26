# Guide d'Utilisation des Widgets Réutilisables

## 🎨 StatusBadge - Badges de Statut

### Utilisation Basique
```dart
import 'package:zentry/presentation/widgets/common/status_badge.dart';

// Badge de statut simple
StatusBadge(status: 'actif')

// Badge de statut large
StatusBadge(
  status: 'bon_etat',
  isLarge: true,
)

// Badge blanc pour les fonds colorés
StatusBadgeWhite(status: 'en_cours')
```

### Statuts Supportés
- `'actif'` → Vert (succès)
- `'en_cours'` / `'etat_moyen'` → Orange (avertissement)
- `'termine'` → Bleu (info)
- `'suspendu'` / `'mauvais_etat'` → Rouge (erreur)
- Autres → Gris par défaut

## 📋 InfoRow - Lignes d'Information

### Utilisation Horizontale
```dart
import 'package:zentry/presentation/widgets/common/info_row.dart';

InfoRow(
  icon: Icons.location_on_outlined,
  label: 'Localisation',
  value: 'Paris, France',
)
```

### Utilisation Verticale
```dart
InfoRow(
  icon: Icons.description_outlined,
  label: 'Description',
  value: 'Une description très longue qui nécessite plusieurs lignes...',
  isVertical: true,
  crossAxisAlignment: CrossAxisAlignment.start,
)
```

### Personnalisation
```dart
InfoRow(
  icon: Icons.priority_high,
  label: 'Priorité',
  value: 'Haute',
  iconColor: Colors.red,
  labelStyle: TextStyle(fontWeight: FontWeight.bold),
  valueStyle: TextStyle(color: Colors.red),
)
```

## 🗃 InfoCard - Cartes d'Information

### Utilisation Simple
```dart
InfoCard(
  title: 'Informations générales',
  children: [
    InfoRow(
      icon: Icons.calendar_today,
      label: 'Date',
      value: '15 janvier 2024',
    ),
    InfoRow(
      icon: Icons.person,
      label: 'Agent',
      value: 'Jean Dupont',
    ),
  ],
)
```

### Avec Actions
```dart
InfoCard(
  title: 'Tronçons',
  trailing: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      TextButton(
        onPressed: () => {},
        child: Text('Voir tout'),
      ),
      IconButton(
        onPressed: () => {},
        icon: Icon(Icons.add),
      ),
    ],
  ),
  children: [
    // Contenu de la carte
  ],
)
```

## 🎯 ProjetHeaderCard - En-tête de Projet

### Utilisation
```dart
import 'package:zentry/presentation/widgets/projet/projet_header_card.dart';

ProjetHeaderCard(
  projet: monProjet, // Instance de la classe Projet
)
```

**Fonctionnalités automatiques :**
- Gradient de couleur basé sur le statut
- Badge de statut blanc
- Chips d'information (localisation, date, agent, tronçon)
- Gestion de la description longue avec ellipsis

## 🛣 TronconListWidget - Liste des Tronçons

### Utilisation Complète
```dart
import 'package:zentry/presentation/widgets/troncon/troncon_list_widget.dart';

TronconListWidget(
  projetId: 123,
  projetNom: 'Mon Projet',
  maxItems: 3, // Limite d'affichage
  showViewAllButton: true, // Boutons d'action
)
```

### Utilisation Simple (Liste complète)
```dart
TronconListWidget(
  projetId: 123,
  projetNom: 'Mon Projet',
  showViewAllButton: false, // Pas de boutons d'action
)
```

**Fonctionnalités automatiques :**
- Gestion des états (chargement, erreur, vide)
- Calcul automatique du statut des tronçons
- Navigation vers les détails
- État vide avec bouton d'ajout

## 🎨 Utilisation du Design System

### Couleurs
```dart
import 'package:zentry/core/theme/app_theme.dart';

// Couleurs principales
Container(
  color: AppTheme.primaryColor,
  child: Text(
    'Texte',
    style: TextStyle(color: AppTheme.textPrimary),
  ),
)

// Couleurs de statut
Container(
  color: StatusColors.forStatus('actif'),
  child: Text('Statut actif'),
)
```

### Espacement
```dart
// Marges et padding cohérents
Padding(
  padding: EdgeInsets.all(AppTheme.spacingM), // 16px
  child: Column(
    children: [
      Text('Premier élément'),
      SizedBox(height: AppTheme.spacingS), // 8px
      Text('Deuxième élément'),
    ],
  ),
)
```

### Typographie
```dart
// Styles de texte prédéfinis
Text(
  'Titre principal',
  style: AppTheme.headlineLarge,
)

Text(
  'Titre de section',
  style: AppTheme.titleMedium,
)

Text(
  'Texte de corps',
  style: AppTheme.bodyMedium,
)

Text(
  'Label ou métadonnée',
  style: AppTheme.bodySmall,
)
```

### Rayons et Élévations
```dart
// Card avec style cohérent
Card(
  elevation: AppTheme.elevationLow, // 2.0
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(AppTheme.radiusM), // 12px
  ),
  child: Padding(
    padding: EdgeInsets.all(AppTheme.spacingM),
    child: Text('Contenu de la carte'),
  ),
)
```

## 🧪 Tests

### Test d'un Widget Personnalisé
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:zentry/core/theme/app_theme.dart';

testWidgets('StatusBadge displays correct text', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(
        body: StatusBadge(status: 'actif'),
      ),
    ),
  );

  expect(find.text('Actif'), findsOneWidget);
});
```

## 📱 Exemple d'Intégration Complète

```dart
class MaPagePersonnalisee extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text('Ma Page')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppTheme.spacingM),
        child: Column(
          children: [
            // En-tête avec gradient
            ProjetHeaderCard(projet: monProjet),
            
            SizedBox(height: AppTheme.spacingL),
            
            // Informations détaillées
            InfoCard(
              title: 'Détails',
              children: [
                InfoRow(
                  icon: Icons.location_on,
                  label: 'Lieu',
                  value: 'Paris',
                ),
                InfoRow(
                  icon: Icons.calendar_today,
                  label: 'Date',
                  value: '15/01/2024',
                ),
              ],
            ),
            
            SizedBox(height: AppTheme.spacingL),
            
            // Liste des tronçons
            TronconListWidget(
              projetId: monProjet.id!,
              projetNom: monProjet.nom,
              maxItems: 3,
            ),
          ],
        ),
      ),
    );
  }
}
```

Ce système de widgets réutilisables garantit une cohérence visuelle et fonctionnelle dans toute l'application, tout en réduisant la duplication de code et en facilitant la maintenance. 