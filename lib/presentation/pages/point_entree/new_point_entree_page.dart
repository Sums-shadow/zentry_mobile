import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_routes.dart';

class NewPointEntreePage extends ConsumerStatefulWidget {
  final String projetId;

  const NewPointEntreePage({
    super.key,
    required this.projetId,
  });

  @override
  ConsumerState<NewPointEntreePage> createState() => _NewPointEntreePageState();
}

class _NewPointEntreePageState extends ConsumerState<NewPointEntreePage> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isLoading = false;

  Future<void> _handleSubmit() async {
    if (_formKey.currentState?.saveAndValidate() == true) {
      setState(() {
        _isLoading = true;
      });

      // Simulation de création du point d'entrée
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        // Afficher un message de succès
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Point d\'entrée créé avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Retourner au détail du projet
        context.go('${AppRoutes.projetDetail}/${widget.projetId}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouveau Point d\'entrée'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('${AppRoutes.projetDetail}/${widget.projetId}'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: FormBuilder(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Icon(
                          Icons.add_location_alt_outlined,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ajouter un point d\'entrée',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Définissez un nouveau point d\'accès',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Informations générales
              Text(
                'Informations générales',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Nom du point d'entrée
              FormBuilderTextField(
                name: 'nom',
                decoration: InputDecoration(
                  labelText: 'Nom du point d\'entrée *',
                  prefixIcon: const Icon(Icons.location_on_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(
                    errorText: 'Le nom est requis',
                  ),
                  FormBuilderValidators.minLength(
                    3,
                    errorText: 'Le nom doit contenir au moins 3 caractères',
                  ),
                ]),
              ),
              const SizedBox(height: 16),

              // Type de point d'entrée
              FormBuilderDropdown<String>(
                name: 'type',
                initialValue: 'principal',
                decoration: InputDecoration(
                  labelText: 'Type de point d\'entrée *',
                  prefixIcon: const Icon(Icons.category_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                items: const [
                  DropdownMenuItem(value: 'principal', child: Text('Principal')),
                  DropdownMenuItem(value: 'secondaire', child: Text('Secondaire')),
                  DropdownMenuItem(value: 'urgence', child: Text('Urgence')),
                  DropdownMenuItem(value: 'service', child: Text('Service')),
                  DropdownMenuItem(value: 'livraison', child: Text('Livraison')),
                ],
                validator: FormBuilderValidators.required(
                  errorText: 'Le type est requis',
                ),
              ),
              const SizedBox(height: 16),

              // Description
              FormBuilderTextField(
                name: 'description',
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Description',
                  prefixIcon: const Icon(Icons.description_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 24),

              // Localisation
              Text(
                'Localisation',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Adresse
              FormBuilderTextField(
                name: 'adresse',
                decoration: InputDecoration(
                  labelText: 'Adresse *',
                  prefixIcon: const Icon(Icons.home_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                validator: FormBuilderValidators.required(
                  errorText: 'L\'adresse est requise',
                ),
              ),
              const SizedBox(height: 16),

              // Ville
              FormBuilderTextField(
                name: 'ville',
                decoration: InputDecoration(
                  labelText: 'Ville *',
                  prefixIcon: const Icon(Icons.location_city_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                validator: FormBuilderValidators.required(
                  errorText: 'La ville est requise',
                ),
              ),
              const SizedBox(height: 16),

              // Code postal
              FormBuilderTextField(
                name: 'codePostal',
                decoration: InputDecoration(
                  labelText: 'Code postal *',
                  prefixIcon: const Icon(Icons.markunread_mailbox_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(
                    errorText: 'Le code postal est requis',
                  ),
                  FormBuilderValidators.numeric(
                    errorText: 'Le code postal doit être numérique',
                  ),
                  FormBuilderValidators.minLength(
                    5,
                    errorText: 'Le code postal doit contenir 5 chiffres',
                  ),
                  FormBuilderValidators.maxLength(
                    5,
                    errorText: 'Le code postal doit contenir 5 chiffres',
                  ),
                ]),
              ),
              const SizedBox(height: 24),

              // Coordonnées GPS (optionnel)
              Text(
                'Coordonnées GPS (optionnel)',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: FormBuilderTextField(
                      name: 'latitude',
                      decoration: InputDecoration(
                        labelText: 'Latitude',
                        prefixIcon: const Icon(Icons.my_location_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      validator: FormBuilderValidators.numeric(
                        errorText: 'Doit être un nombre',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FormBuilderTextField(
                      name: 'longitude',
                      decoration: InputDecoration(
                        labelText: 'Longitude',
                        prefixIcon: const Icon(Icons.my_location_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      validator: FormBuilderValidators.numeric(
                        errorText: 'Doit être un nombre',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Bouton pour localiser
              OutlinedButton.icon(
                onPressed: () {
                  // TODO: Implémenter la géolocalisation
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Géolocalisation non implémentée'),
                    ),
                  );
                },
                icon: const Icon(Icons.gps_fixed),
                label: const Text('Utiliser ma position actuelle'),
              ),
              const SizedBox(height: 24),

              // Configuration d'accès
              Text(
                'Configuration d\'accès',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Statut
              FormBuilderDropdown<String>(
                name: 'statut',
                initialValue: 'actif',
                decoration: InputDecoration(
                  labelText: 'Statut *',
                  prefixIcon: const Icon(Icons.flag_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                items: const [
                  DropdownMenuItem(value: 'actif', child: Text('Actif')),
                  DropdownMenuItem(value: 'inactif', child: Text('Inactif')),
                  DropdownMenuItem(value: 'maintenance', child: Text('En maintenance')),
                  DropdownMenuItem(value: 'temporaire', child: Text('Temporaire')),
                ],
                validator: FormBuilderValidators.required(
                  errorText: 'Le statut est requis',
                ),
              ),
              const SizedBox(height: 16),

              // Niveau de sécurité
              FormBuilderDropdown<String>(
                name: 'securite',
                initialValue: 'standard',
                decoration: InputDecoration(
                  labelText: 'Niveau de sécurité *',
                  prefixIcon: const Icon(Icons.security_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                items: const [
                  DropdownMenuItem(value: 'public', child: Text('Public')),
                  DropdownMenuItem(value: 'standard', child: Text('Standard')),
                  DropdownMenuItem(value: 'securise', child: Text('Sécurisé')),
                  DropdownMenuItem(value: 'haute_securite', child: Text('Haute sécurité')),
                ],
                validator: FormBuilderValidators.required(
                  errorText: 'Le niveau de sécurité est requis',
                ),
              ),
              const SizedBox(height: 16),

              // Horaires d'accès
              FormBuilderTextField(
                name: 'horaires',
                decoration: InputDecoration(
                  labelText: 'Horaires d\'accès',
                  prefixIcon: const Icon(Icons.access_time_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                  hintText: 'Ex: 08h00 - 18h00',
                ),
              ),
              const SizedBox(height: 16),

              // Instructions d'accès
              FormBuilderTextField(
                name: 'instructions',
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Instructions d\'accès',
                  prefixIcon: const Icon(Icons.info_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                  alignLabelWithHint: true,
                  hintText: 'Consignes particulières pour accéder à ce point...',
                ),
              ),
              const SizedBox(height: 32),

              // Boutons d'action
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => context.go('${AppRoutes.projetDetail}/${widget.projetId}'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Annuler'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Créer le point d\'entrée'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
} 