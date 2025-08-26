import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_routes.dart';

class ProfilPage extends ConsumerStatefulWidget {
  const ProfilPage({super.key});

  @override
  ConsumerState<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends ConsumerState<ProfilPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isEditing = false;
  bool _isLoading = false;

  Future<void> _handleSave() async {
    if (_formKey.currentState?.saveAndValidate() == true) {
      setState(() {
        _isLoading = true;
      });

      // Simulation de sauvegarde
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        setState(() {
          _isLoading = false;
          _isEditing = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil mis à jour avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userData = _getMockUserData();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Profil'),
        actions: [
          if (_isEditing)
            TextButton(
              onPressed: _isLoading ? null : _handleSave,
              child: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Sauvegarder'),
            )
          else
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Photo de profil
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                          child: Icon(
                            Icons.person,
                            size: 50,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        if (_isEditing)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.camera_alt, color: Colors.white),
                                iconSize: 20,
                                onPressed: () {
                                  // TODO: Changer la photo de profil
                                },
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${userData['prenom']} ${userData['nom']}',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      userData['fonction'],
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Formulaire d'informations
            FormBuilder(
              key: _formKey,
              child: Column(
                children: [
                  // Informations personnelles
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Informations personnelles',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Prénom
                          FormBuilderTextField(
                            name: 'prenom',
                            initialValue: userData['prenom'],
                            enabled: _isEditing,
                            decoration: InputDecoration(
                              labelText: 'Prénom',
                              prefixIcon: const Icon(Icons.person_outline),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: _isEditing ? Colors.grey[50] : Colors.grey[100],
                            ),
                            validator: FormBuilderValidators.required(
                              errorText: 'Le prénom est requis',
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Nom
                          FormBuilderTextField(
                            name: 'nom',
                            initialValue: userData['nom'],
                            enabled: _isEditing,
                            decoration: InputDecoration(
                              labelText: 'Nom',
                              prefixIcon: const Icon(Icons.person_outline),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: _isEditing ? Colors.grey[50] : Colors.grey[100],
                            ),
                            validator: FormBuilderValidators.required(
                              errorText: 'Le nom est requis',
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Email
                          FormBuilderTextField(
                            name: 'email',
                            initialValue: userData['email'],
                            enabled: _isEditing,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              prefixIcon: const Icon(Icons.email_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: _isEditing ? Colors.grey[50] : Colors.grey[100],
                            ),
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(
                                errorText: 'L\'email est requis',
                              ),
                              FormBuilderValidators.email(
                                errorText: 'Email invalide',
                              ),
                            ]),
                          ),
                          const SizedBox(height: 16),

                          // Téléphone
                          FormBuilderTextField(
                            name: 'telephone',
                            initialValue: userData['telephone'],
                            enabled: _isEditing,
                            decoration: InputDecoration(
                              labelText: 'Téléphone',
                              prefixIcon: const Icon(Icons.phone_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: _isEditing ? Colors.grey[50] : Colors.grey[100],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Informations professionnelles
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Informations professionnelles',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Fonction
                          FormBuilderTextField(
                            name: 'fonction',
                            initialValue: userData['fonction'],
                            enabled: _isEditing,
                            decoration: InputDecoration(
                              labelText: 'Fonction',
                              prefixIcon: const Icon(Icons.work_outline),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: _isEditing ? Colors.grey[50] : Colors.grey[100],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Service
                          FormBuilderTextField(
                            name: 'service',
                            initialValue: userData['service'],
                            enabled: _isEditing,
                            decoration: InputDecoration(
                              labelText: 'Service',
                              prefixIcon: const Icon(Icons.business_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: _isEditing ? Colors.grey[50] : Colors.grey[100],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Matricule
                          FormBuilderTextField(
                            name: 'matricule',
                            initialValue: userData['matricule'],
                            enabled: false, // Toujours en lecture seule
                            decoration: InputDecoration(
                              labelText: 'Matricule',
                              prefixIcon: const Icon(Icons.badge_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey[100],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Statistiques
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Mes statistiques',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  'Projets gérés',
                                  userData['projetsGeres'].toString(),
                                  Icons.folder_outlined,
                                  Colors.blue,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatCard(
                                  'Points d\'entrée',
                                  userData['pointsEntree'].toString(),
                                  Icons.location_on_outlined,
                                  Colors.green,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  'Connexions',
                                  userData['connexions'].toString(),
                                  Icons.login_outlined,
                                  Colors.orange,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatCard(
                                  'Dernière activité',
                                  userData['derniereActivite'],
                                  Icons.schedule_outlined,
                                  Colors.purple,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Actions
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Actions',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    ListTile(
                      leading: const Icon(Icons.security_outlined),
                      title: const Text('Changer le mot de passe'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        _showChangePasswordDialog();
                      },
                    ),
                    const Divider(),
                    
                    ListTile(
                      leading: const Icon(Icons.notifications_outlined),
                      title: const Text('Paramètres de notification'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        context.go(AppRoutes.parametre);
                      },
                    ),
                    const Divider(),
                    
                    ListTile(
                      leading: const Icon(Icons.download_outlined),
                      title: const Text('Exporter mes données'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        _showExportDialog();
                      },
                    ),
                    const Divider(),
                    
                    ListTile(
                      leading: const Icon(Icons.logout, color: Colors.red),
                      title: const Text('Déconnexion', style: TextStyle(color: Colors.red)),
                      onTap: () {
                        _showLogoutDialog();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getMockUserData() {
    return {
      'prenom': 'Jean',
      'nom': 'Dupont',
      'email': 'jean.dupont@exemple.fr',
      'telephone': '+33 1 23 45 67 89',
      'fonction': 'Chef de Projet',
      'service': 'Développement',
      'matricule': 'EMP001',
      'projetsGeres': 12,
      'pointsEntree': 45,
      'connexions': 234,
      'derniereActivite': '14h30',
    };
  }

  void _showChangePasswordDialog() {
    final formKey = GlobalKey<FormBuilderState>();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Changer le mot de passe'),
        content: FormBuilder(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FormBuilderTextField(
                name: 'currentPassword',
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Mot de passe actuel',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                validator: FormBuilderValidators.required(
                  errorText: 'Mot de passe actuel requis',
                ),
              ),
              const SizedBox(height: 16),
              FormBuilderTextField(
                name: 'newPassword',
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Nouveau mot de passe',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(
                    errorText: 'Nouveau mot de passe requis',
                  ),
                  FormBuilderValidators.minLength(
                    6,
                    errorText: 'Au moins 6 caractères',
                  ),
                ]),
              ),
              const SizedBox(height: 16),
              FormBuilderTextField(
                name: 'confirmPassword',
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirmer le mot de passe',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                validator: (value) {
                  if (value != formKey.currentState?.fields['newPassword']?.value) {
                    return 'Les mots de passe ne correspondent pas';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.saveAndValidate() == true) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Mot de passe changé avec succès !'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Changer'),
          ),
        ],
      ),
    );
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exporter mes données'),
        content: const Text(
          'Un fichier contenant toutes vos données personnelles et votre activité vous sera envoyé par email.',
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
                const SnackBar(
                  content: Text('Export en cours... Vous recevrez un email.'),
                ),
              );
            },
            child: const Text('Exporter'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.go(AppRoutes.login);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );
  }
} 