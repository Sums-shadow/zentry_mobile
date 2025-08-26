import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_routes.dart';

class PointEntreeDetailPage extends ConsumerWidget {
  final String pointEntreeId;

  const PointEntreeDetailPage({
    super.key,
    required this.pointEntreeId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pointEntree = _getMockPointEntree(pointEntreeId);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(pointEntree['nom']),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              // TODO: Naviguer vers la page de modification
            },
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              // TODO: Partager les informations du point d'entrée
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'duplicate':
                  // TODO: Dupliquer le point d'entrée
                  break;
                case 'archive':
                  // TODO: Archiver le point d'entrée
                  break;
                case 'delete':
                  _showDeleteConfirmation(context);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'duplicate',
                child: Row(
                  children: [
                    Icon(Icons.copy_outlined),
                    SizedBox(width: 8),
                    Text('Dupliquer'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'archive',
                child: Row(
                  children: [
                    Icon(Icons.archive_outlined),
                    SizedBox(width: 8),
                    Text('Archiver'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outlined, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Supprimer', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Carte de statut
            Card(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [
                      _getStatusColor(pointEntree['statut']),
                      _getStatusColor(pointEntree['statut']).withOpacity(0.8),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            pointEntree['nom'],
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            pointEntree['statut'].toString().replaceAll('_', ' ').toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      pointEntree['type'].toString().toUpperCase(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (pointEntree['description'] != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        pointEntree['description'],
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Localisation
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Localisation',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            // TODO: Ouvrir dans une app de navigation
                          },
                          icon: const Icon(Icons.navigation_outlined),
                          style: IconButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                            foregroundColor: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    _buildInfoRow(
                      context,
                      Icons.home_outlined,
                      'Adresse',
                      pointEntree['adresse'],
                    ),
                    const SizedBox(height: 12),
                    
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoRow(
                            context,
                            Icons.location_city_outlined,
                            'Ville',
                            pointEntree['ville'],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildInfoRow(
                            context,
                            Icons.markunread_mailbox_outlined,
                            'Code postal',
                            pointEntree['codePostal'],
                          ),
                        ),
                      ],
                    ),
                    
                    if (pointEntree['coordonnees'] != null) ...[
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        context,
                        Icons.my_location_outlined,
                        'Coordonnées GPS',
                        '${pointEntree['coordonnees']['lat']}, ${pointEntree['coordonnees']['lng']}',
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Configuration d'accès
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Configuration d\'accès',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    _buildInfoRow(
                      context,
                      Icons.security_outlined,
                      'Niveau de sécurité',
                      pointEntree['securite'].toString().replaceAll('_', ' ').toUpperCase(),
                    ),
                    const SizedBox(height: 12),
                    
                    if (pointEntree['horaires'] != null) ...[
                      _buildInfoRow(
                        context,
                        Icons.access_time_outlined,
                        'Horaires d\'accès',
                        pointEntree['horaires'],
                      ),
                      const SizedBox(height: 12),
                    ],
                    
                    _buildInfoRow(
                      context,
                      Icons.calendar_today_outlined,
                      'Date de création',
                      pointEntree['dateCreation'],
                    ),
                    
                    if (pointEntree['instructions'] != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Instructions d\'accès',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.withOpacity(0.2)),
                        ),
                        child: Text(
                          pointEntree['instructions'],
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.blue[800],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Statistiques d'utilisation
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Statistiques d\'utilisation',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            context,
                            'Accès aujourd\'hui',
                            pointEntree['accesAujourdhui'].toString(),
                            Icons.login_outlined,
                            Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            context,
                            'Accès cette semaine',
                            pointEntree['accesSemaine'].toString(),
                            Icons.bar_chart_outlined,
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
                            context,
                            'Dernier accès',
                            pointEntree['dernierAcces'],
                            Icons.history_outlined,
                            Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            context,
                            'Alertes',
                            pointEntree['alertes'].toString(),
                            Icons.warning_outlined,
                            pointEntree['alertes'] > 0 ? Colors.red : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Actions rapides
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Actions rapides',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // TODO: Ouvrir navigation
                            },
                            icon: const Icon(Icons.navigation_outlined),
                            label: const Text('Navigation'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              // TODO: Partager
                            },
                            icon: const Icon(Icons.share_outlined),
                            label: const Text('Partager'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // TODO: Signaler un problème
                        },
                        icon: const Icon(Icons.report_outlined),
                        label: const Text('Signaler un problème'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                      ),
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

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 20),
              Text(
                value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String statut) {
    switch (statut.toLowerCase()) {
      case 'actif':
        return Colors.green;
      case 'inactif':
        return Colors.grey;
      case 'maintenance':
        return Colors.orange;
      case 'temporaire':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Map<String, dynamic> _getMockPointEntree(String id) {
    return {
      'id': id,
      'nom': 'Entrée Principale Bureau',
      'type': 'principal',
      'description': 'Point d\'entrée principal du bâtiment avec accès sécurisé',
      'statut': 'actif',
      'adresse': '123 Rue de la République',
      'ville': 'Paris',
      'codePostal': '75001',
      'coordonnees': {
        'lat': 48.8566,
        'lng': 2.3522,
      },
      'securite': 'securise',
      'horaires': '08h00 - 18h00',
      'instructions': 'Présenter votre badge d\'accès au lecteur. En cas de problème, contactez la sécurité au 01.23.45.67.89',
      'dateCreation': '15/01/2024',
      'accesAujourdhui': 24,
      'accesSemaine': 156,
      'dernierAcces': '14h30',
      'alertes': 0,
    };
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le point d\'entrée'),
        content: const Text(
          'Êtes-vous sûr de vouloir supprimer ce point d\'entrée ? Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Supprimer le point d'entrée
              context.go(AppRoutes.dashboard);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
} 