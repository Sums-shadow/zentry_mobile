import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class ParametrePage extends ConsumerStatefulWidget {
  const ParametrePage({super.key});

  @override
  ConsumerState<ParametrePage> createState() => _ParametrePageState();
}

class _ParametrePageState extends ConsumerState<ParametrePage> {
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _darkMode = false;
  bool _autoBackup = true;
  String _language = 'fr';
  String _theme = 'system';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Notifications
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notifications',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  SwitchListTile(
                    title: const Text('Activer les notifications'),
                    subtitle: const Text('Recevoir des notifications push'),
                    value: _notificationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                    },
                    secondary: const Icon(Icons.notifications_outlined),
                  ),
                  
                  SwitchListTile(
                    title: const Text('Sons'),
                    subtitle: const Text('Sons de notification'),
                    value: _soundEnabled,
                    onChanged: _notificationsEnabled ? (value) {
                      setState(() {
                        _soundEnabled = value;
                      });
                    } : null,
                    secondary: const Icon(Icons.volume_up_outlined),
                  ),
                  
                  SwitchListTile(
                    title: const Text('Vibration'),
                    subtitle: const Text('Vibration pour les notifications'),
                    value: _vibrationEnabled,
                    onChanged: _notificationsEnabled ? (value) {
                      setState(() {
                        _vibrationEnabled = value;
                      });
                    } : null,
                    secondary: const Icon(Icons.vibration_outlined),
                  ),
                  
                  ListTile(
                    title: const Text('Types de notifications'),
                    subtitle: const Text('Configurer les types de notifications'),
                    trailing: const Icon(Icons.chevron_right),
                    leading: const Icon(Icons.tune_outlined),
                    onTap: () => _showNotificationTypesDialog(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Apparence
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Apparence',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  ListTile(
                    title: const Text('Thème'),
                    subtitle: Text(_getThemeLabel(_theme)),
                    leading: const Icon(Icons.palette_outlined),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showThemeDialog(),
                  ),
                  
                  ListTile(
                    title: const Text('Langue'),
                    subtitle: Text(_getLanguageLabel(_language)),
                    leading: const Icon(Icons.language_outlined),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showLanguageDialog(),
                  ),
                  
                  ListTile(
                    title: const Text('Taille du texte'),
                    subtitle: const Text('Ajuster la taille du texte'),
                    leading: const Icon(Icons.text_fields_outlined),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showTextSizeDialog(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Sécurité et confidentialité
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sécurité et confidentialité',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  ListTile(
                    title: const Text('Changer le mot de passe'),
                    subtitle: const Text('Modifier votre mot de passe'),
                    leading: const Icon(Icons.lock_outline),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showChangePasswordDialog(),
                  ),
                  
                  ListTile(
                    title: const Text('Authentification biométrique'),
                    subtitle: const Text('Utiliser votre empreinte ou Face ID'),
                    leading: const Icon(Icons.fingerprint_outlined),
                    trailing: Switch(
                      value: false, // TODO: Gérer l'état de la biométrie
                      onChanged: (value) {
                        // TODO: Implémenter l'authentification biométrique
                      },
                    ),
                  ),
                  
                  ListTile(
                    title: const Text('Sessions actives'),
                    subtitle: const Text('Gérer les sessions connectées'),
                    leading: const Icon(Icons.devices_outlined),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showActiveSessionsDialog(),
                  ),
                  
                  ListTile(
                    title: const Text('Confidentialité des données'),
                    subtitle: const Text('Paramètres de confidentialité'),
                    leading: const Icon(Icons.privacy_tip_outlined),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showPrivacyDialog(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Données et stockage
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Données et stockage',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  SwitchListTile(
                    title: const Text('Sauvegarde automatique'),
                    subtitle: const Text('Sauvegarder automatiquement les données'),
                    value: _autoBackup,
                    onChanged: (value) {
                      setState(() {
                        _autoBackup = value;
                      });
                    },
                    secondary: const Icon(Icons.backup_outlined),
                  ),
                  
                  ListTile(
                    title: const Text('Gérer le stockage'),
                    subtitle: const Text('Voir l\'utilisation du stockage'),
                    leading: const Icon(Icons.storage_outlined),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showStorageDialog(),
                  ),
                  
                  ListTile(
                    title: const Text('Exporter les données'),
                    subtitle: const Text('Télécharger une copie de vos données'),
                    leading: const Icon(Icons.download_outlined),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showExportDialog(),
                  ),
                  
                  ListTile(
                    title: const Text('Vider le cache'),
                    subtitle: const Text('Libérer de l\'espace de stockage'),
                    leading: const Icon(Icons.clear_all_outlined),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showClearCacheDialog(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Support et aide
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Support et aide',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  ListTile(
                    title: const Text('Centre d\'aide'),
                    subtitle: const Text('FAQ et documentation'),
                    leading: const Icon(Icons.help_outline),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showHelpDialog(),
                  ),
                  
                  ListTile(
                    title: const Text('Signaler un problème'),
                    subtitle: const Text('Signaler un bug ou un problème'),
                    leading: const Icon(Icons.bug_report_outlined),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showReportDialog(),
                  ),
                  
                  ListTile(
                    title: const Text('Contacter le support'),
                    subtitle: const Text('Assistance technique'),
                    leading: const Icon(Icons.support_agent_outlined),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showContactDialog(),
                  ),
                  
                  ListTile(
                    title: const Text('À propos'),
                    subtitle: const Text('Version et informations de l\'app'),
                    leading: const Icon(Icons.info_outline),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showAboutDialog(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  String _getThemeLabel(String theme) {
    switch (theme) {
      case 'light':
        return 'Clair';
      case 'dark':
        return 'Sombre';
      case 'system':
        return 'Automatique (système)';
      default:
        return 'Automatique (système)';
    }
  }

  String _getLanguageLabel(String language) {
    switch (language) {
      case 'fr':
        return 'Français';
      case 'en':
        return 'English';
      case 'es':
        return 'Español';
      default:
        return 'Français';
    }
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choisir le thème'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Clair'),
              value: 'light',
              groupValue: _theme,
              onChanged: (value) {
                setState(() {
                  _theme = value!;
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Sombre'),
              value: 'dark',
              groupValue: _theme,
              onChanged: (value) {
                setState(() {
                  _theme = value!;
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Automatique (système)'),
              value: 'system',
              groupValue: _theme,
              onChanged: (value) {
                setState(() {
                  _theme = value!;
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choisir la langue'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Français'),
              value: 'fr',
              groupValue: _language,
              onChanged: (value) {
                setState(() {
                  _language = value!;
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('English'),
              value: 'en',
              groupValue: _language,
              onChanged: (value) {
                setState(() {
                  _language = value!;
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Español'),
              value: 'es',
              groupValue: _language,
              onChanged: (value) {
                setState(() {
                  _language = value!;
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showNotificationTypesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Types de notifications'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CheckboxListTile(
              title: const Text('Nouveaux projets'),
              value: true,
              onChanged: (value) {},
            ),
            CheckboxListTile(
              title: const Text('Mises à jour de projets'),
              value: true,
              onChanged: (value) {},
            ),
            CheckboxListTile(
              title: const Text('Alertes de sécurité'),
              value: true,
              onChanged: (value) {},
            ),
            CheckboxListTile(
              title: const Text('Rapports hebdomadaires'),
              value: false,
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    // Réutiliser le dialog du profil
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Redirection vers le changement de mot de passe...')),
    );
  }

  void _showActiveSessionsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sessions actives'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Sessions actuellement connectées :'),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.phone_android),
              title: const Text('Android (actuel)'),
              subtitle: const Text('Dernière activité : maintenant'),
              trailing: const Chip(label: Text('Actuel')),
            ),
            ListTile(
              leading: const Icon(Icons.laptop),
              title: const Text('Chrome - Windows'),
              subtitle: const Text('Dernière activité : il y a 2h'),
              trailing: TextButton(
                onPressed: () {},
                child: const Text('Déconnecter'),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confidentialité des données'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Paramètres de confidentialité :'),
            SizedBox(height: 16),
            Text('• Collecte de données anonymes'),
            Text('• Partage avec des tiers'),
            Text('• Analytics et amélioration'),
            Text('• Cookies et tracking'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showStorageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Utilisation du stockage'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Espace utilisé :', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            const LinearProgressIndicator(value: 0.3),
            const SizedBox(height: 8),
            const Text('245 MB / 1 GB utilisés'),
            const SizedBox(height: 16),
            const Text('Répartition :'),
            const SizedBox(height: 8),
            const Text('• Documents : 120 MB'),
            const Text('• Images : 85 MB'),
            const Text('• Cache : 40 MB'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exporter les données'),
        content: const Text('Vos données seront exportées au format ZIP et envoyées à votre adresse email.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Export en cours...')),
              );
            },
            child: const Text('Exporter'),
          ),
        ],
      ),
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Vider le cache'),
        content: const Text('Cette action libérera de l\'espace mais peut ralentir temporairement l\'application.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache vidé avec succès !')),
              );
            },
            child: const Text('Vider'),
          ),
        ],
      ),
    );
  }

  void _showTextSizeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Taille du texte'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Ajustez la taille du texte selon vos préférences :'),
            const SizedBox(height: 16),
            Slider(
              value: 1.0,
              min: 0.8,
              max: 1.4,
              divisions: 6,
              label: 'Normal',
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Centre d\'aide'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Questions fréquentes :'),
            SizedBox(height: 8),
            Text('• Comment créer un projet ?'),
            Text('• Comment ajouter un point d\'entrée ?'),
            Text('• Comment consulter les rapports ?'),
            Text('• Comment modifier mon profil ?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Signaler un problème'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Décrivez le problème',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Rapport envoyé. Merci !')),
              );
            },
            child: const Text('Envoyer'),
          ),
        ],
      ),
    );
  }

  void _showContactDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contacter le support'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Moyens de contact :'),
            SizedBox(height: 16),
            Text('📧 Email : support@zentry.fr'),
            Text('📞 Téléphone : +33 1 23 45 67 89'),
            Text('💬 Chat : Disponible 9h-18h'),
            Text('🕐 Heures d\'ouverture : Lun-Ven 9h-18h'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('À propos de ZENTRY'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version : 1.0.0'),
            Text('Build : 2024.03.15'),
            SizedBox(height: 16),
            Text('ZENTRY - Portail Agent'),
            Text('Gestion de projets et points d\'entrée'),
            SizedBox(height: 16),
            Text('© 2024 ZENTRY. Tous droits réservés.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
} 