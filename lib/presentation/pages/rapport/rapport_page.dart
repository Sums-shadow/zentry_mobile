import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RapportPage extends ConsumerStatefulWidget {
  const RapportPage({super.key});

  @override
  ConsumerState<RapportPage> createState() => _RapportPageState();
}

class _RapportPageState extends ConsumerState<RapportPage> {
  String _selectedPeriod = 'mois';
  String _selectedType = 'tous';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rapports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_outlined),
            onPressed: () {
              _showExportDialog();
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list_outlined),
            onPressed: () {
              _showFilterDialog();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filtres rapides
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Filtres',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Période',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 4),
                              DropdownButtonFormField<String>(
                                value: _selectedPeriod,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                                items: const [
                                  DropdownMenuItem(value: 'jour', child: Text('Aujourd\'hui')),
                                  DropdownMenuItem(value: 'semaine', child: Text('Cette semaine')),
                                  DropdownMenuItem(value: 'mois', child: Text('Ce mois')),
                                  DropdownMenuItem(value: 'trimestre', child: Text('Ce trimestre')),
                                  DropdownMenuItem(value: 'annee', child: Text('Cette année')),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _selectedPeriod = value!;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Type de rapport',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 4),
                              DropdownButtonFormField<String>(
                                value: _selectedType,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                                items: const [
                                  DropdownMenuItem(value: 'tous', child: Text('Tous')),
                                  DropdownMenuItem(value: 'projets', child: Text('Projets')),
                                  DropdownMenuItem(value: 'points_entree', child: Text('Points d\'entrée')),
                                  DropdownMenuItem(value: 'activite', child: Text('Activité')),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _selectedType = value!;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Métriques principales
            Text(
              'Vue d\'ensemble',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    context,
                    'Projets Actifs',
                    '12',
                    '+2 ce mois',
                    Icons.folder_outlined,
                    Colors.blue,
                    true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    context,
                    'Points d\'Entrée',
                    '45',
                    '+5 ce mois',
                    Icons.location_on_outlined,
                    Colors.green,
                    true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    context,
                    'Accès Total',
                    '1,234',
                    '+15% ce mois',
                    Icons.login_outlined,
                    Colors.orange,
                    true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    context,
                    'Alertes',
                    '3',
                    '-2 ce mois',
                    Icons.warning_outlined,
                    Colors.red,
                    false,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Graphique d'activité
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
                          'Activité des accès',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            // TODO: Changer le type de graphique
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(value: 'line', child: Text('Graphique linéaire')),
                            const PopupMenuItem(value: 'bar', child: Text('Graphique en barres')),
                            const PopupMenuItem(value: 'pie', child: Text('Graphique circulaire')),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Simulation d'un graphique
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.bar_chart_outlined,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Graphique d\'activité',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              'Données pour $_selectedPeriod',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Répartition par type
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Répartition par type de point d\'entrée',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    _buildProgressItem('Principal', 35, 60, Colors.blue),
                    const SizedBox(height: 12),
                    _buildProgressItem('Secondaire', 25, 40, Colors.green),
                    const SizedBox(height: 12),
                    _buildProgressItem('Urgence', 8, 15, Colors.red),
                    const SizedBox(height: 12),
                    _buildProgressItem('Service', 15, 25, Colors.orange),
                    const SizedBox(height: 12),
                    _buildProgressItem('Livraison', 12, 20, Colors.purple),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Top des projets les plus actifs
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Projets les plus actifs',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    ...List.generate(5, (index) {
                      final projets = [
                        {'nom': 'Projet Alpha', 'acces': 456, 'evolution': '+12%'},
                        {'nom': 'Projet Beta', 'acces': 342, 'evolution': '+8%'},
                        {'nom': 'Projet Gamma', 'acces': 298, 'evolution': '+5%'},
                        {'nom': 'Projet Delta', 'acces': 187, 'evolution': '-2%'},
                        {'nom': 'Projet Epsilon', 'acces': 123, 'evolution': '+15%'},
                      ];
                      
                      final projet = projets[index];
                      final isPositive = projet['evolution'].toString().contains('+');
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    projet['nom'].toString(),
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    '${projet['acces']} accès',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isPositive 
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                projet['evolution'].toString(),
                                style: TextStyle(
                                  color: isPositive ? Colors.green : Colors.red,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
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
                          child: OutlinedButton.icon(
                            onPressed: () => _showExportDialog(),
                            icon: const Icon(Icons.download_outlined),
                            label: const Text('Exporter'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              // TODO: Programmer un rapport
                            },
                            icon: const Icon(Icons.schedule_outlined),
                            label: const Text('Programmer'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Créer un rapport personnalisé
                        },
                        icon: const Icon(Icons.add_chart_outlined),
                        label: const Text('Rapport personnalisé'),
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

  Widget _buildMetricCard(
    BuildContext context,
    String title,
    String value,
    String evolution,
    IconData icon,
    Color color,
    bool isPositive,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 24),
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  isPositive ? Icons.trending_up : Icons.trending_down,
                  size: 16,
                  color: isPositive ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 4),
                Text(
                  evolution,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isPositive ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressItem(String label, int value, int max, Color color) {
    final percentage = (value / max) * 100;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '$value/$max',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: percentage / 100,
          backgroundColor: color.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtres avancés'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Options de filtrage disponibles :'),
            const SizedBox(height: 16),
            // TODO: Ajouter plus de filtres
            const Text('• Période personnalisée'),
            const Text('• Projets spécifiques'),
            const Text('• Types de points d\'entrée'),
            const Text('• Niveau de sécurité'),
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
        title: const Text('Exporter le rapport'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Choisissez le format d\'export :'),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf_outlined),
              title: const Text('PDF'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Exporter en PDF
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Export PDF en cours...')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.table_chart_outlined),
              title: const Text('Excel'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Exporter en Excel
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Export Excel en cours...')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.code_outlined),
              title: const Text('CSV'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Exporter en CSV
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Export CSV en cours...')),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );
  }
} 