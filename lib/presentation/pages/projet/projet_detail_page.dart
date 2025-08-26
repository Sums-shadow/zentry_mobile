import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/projet.dart';
import '../../providers/projet_provider.dart';
import '../../providers/troncon_provider.dart'; // Ajout de l'import du provider troncon
import '../../widgets/projet/projet_header_card.dart';
import '../../widgets/troncon/troncon_list_widget.dart';
import '../../widgets/common/info_row.dart';
import 'package:intl/intl.dart';

class ProjetDetailPage extends ConsumerWidget {
  final String projetId;

  const ProjetDetailPage({
    super.key,
    required this.projetId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projetAsyncValue = ref.watch(projetByIdProvider(int.parse(projetId)));

    return Scaffold(
      body: projetAsyncValue.when(
        loading: () => const _LoadingScaffold(),
        error: (error, stackTrace) => _ErrorScaffold(
          error: error,
          onRetry: () => ref.refresh(projetByIdProvider(int.parse(projetId))),
        ),
        data: (projet) {
          if (projet == null) {
            return _NotFoundScaffold(
              onGoBack: () => context.go(AppRoutes.projets),
            );
          }
          return _ProjetDetailContent(projet: projet);
        },
      ),
    );
  }
}

class _ProjetDetailContent extends ConsumerStatefulWidget {
  final Projet projet;

  const _ProjetDetailContent({required this.projet});

  @override
  ConsumerState<_ProjetDetailContent> createState() => _ProjetDetailContentState();
}

class _ProjetDetailContentState extends ConsumerState<_ProjetDetailContent>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final DateFormat dateFormatter = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    // Rafraîchir les données du projet
    await ref.refresh(projetByIdProvider(widget.projet.id!).future);
    
    // Redémarrer l'animation de fade-in
    _animationController.reset();
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: CustomScrollView(
          slivers: [
            _buildSliverAppBar(theme),
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Carte principale du projet
                      _buildMainProjectCard(theme),
                      // const SizedBox(height: 24),

                      // Section des informations détaillées
                      // _buildDetailedInfoCard(theme),
                      // const SizedBox(height: 24),

                      // Section des tronçons
                      _buildTronconSection(theme),
                      const SizedBox(height: 100), // Espace pour le FAB
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(theme),
    );
  }

  Widget _buildSliverAppBar(ThemeData theme) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: theme.colorScheme.onPrimary,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          widget.projet.nom,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.primary.withOpacity(0.8),
              ],
            ),
          ),
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.go(AppRoutes.projets),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.map_outlined),
          onPressed: () {
            context.pushNamed(
              'projet-map',
              pathParameters: {'id': widget.projet.id.toString()},
              extra: widget.projet,
            );
          },
          tooltip: 'Voir sur la carte',
        ),
        IconButton(
          icon: const Icon(Icons.edit_outlined),
          onPressed: () {
            _showFeatureNotImplemented(context);
          },
          tooltip: 'Modifier le projet',
        ),
        PopupMenuButton<String>(
          onSelected: (value) => _handleMenuAction(context, value),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'duplicate',
              child: Row(
                children: [
                  Icon(Icons.copy_outlined, size: 20),
                  SizedBox(width: 12),
                  Text('Dupliquer'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'archive',
              child: Row(
                children: [
                  Icon(Icons.archive_outlined, size: 20),
                  SizedBox(width: 12),
                  Text('Archiver'),
                ],
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete_outlined, color: Colors.red, size: 20),
                  SizedBox(width: 12),
                  Text('Supprimer', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildMainProjectCard(ThemeData theme) {
    return Consumer(
      builder: (context, ref, child) {
        final tronconsAsyncValue = ref.watch(tronconsByProjetProvider(widget.projet.id!));
        
        return Material(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          elevation: 2,
          shadowColor: theme.shadowColor.withOpacity(0.1),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête avec nom et statut
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.projet.nom,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'ID: ${widget.projet.id}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    tronconsAsyncValue.when(
                      data: (troncons) {
                        // Vérifier si tous les tronçons sont synchronisés
                        final allSynced = troncons.isEmpty || troncons.every((troncon) => troncon.sync);
                        return _buildModernStatusChip(allSynced, theme);
                      },
                      loading: () => _buildModernStatusChip(false, theme),
                      error: (_, __) => _buildModernStatusChip(false, theme),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Description si disponible
                if (widget.projet.description != null && widget.projet.description!.isNotEmpty) ...[
                  Text(
                    widget.projet.description!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                
                // Informations de base
                InfoRow(
                  icon: Icons.route_rounded,
                  label: 'Tronçon',
                  value: widget.projet.troncon ?? 'Non spécifié',
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.location_on_outlined,
                  'Province',
                  widget.projet.province,
                  theme,
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.calendar_today_outlined,
                  'Date de création',
                  dateFormatter.format(widget.projet.date),
                  theme,
                ),
                
                // PK si disponible
                if (widget.projet.pkdebut != null || widget.projet.pkfin != null) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    Icons.straighten_rounded,
                    'Points kilométriques',
                    'PK ${widget.projet.pkdebut ?? "?"} → PK ${widget.projet.pkfin ?? "?"}',
                    theme,
                  ),
                ],
                
                // Agent si disponible
                if (widget.projet.agent != null && widget.projet.agent!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    Icons.person_outline_rounded,
                    'Agent responsable',
                    widget.projet.agent!,
                    theme,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailedInfoCard(ThemeData theme) {
    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
      elevation: 2,
      shadowColor: theme.shadowColor.withOpacity(0.1),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Informations détaillées',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Statistiques en grid
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.2),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    '12',
                    'Tronçons',
                    Icons.route_outlined,
                    theme.colorScheme.primary,
                  ),
                  _buildStatItem(
                    '75%',
                    'Progression',
                    Icons.trending_up_rounded,
                    Colors.green,
                  ),
                  _buildStatItem(
                    '8 mois',
                    'Durée',
                    Icons.schedule_outlined,
                    theme.colorScheme.secondary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTronconSection(ThemeData theme) {
    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
      elevation: 2,
      shadowColor: theme.shadowColor.withOpacity(0.1),
      child: Container(
        padding: const EdgeInsets.all(0),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            // const SizedBox(height: 20),
            TronconListWidget(
              projetId: widget.projet.id!,
              projetNom: widget.projet.nom,
              maxItems: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, ThemeData theme) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: theme.colorScheme.primary.withOpacity(0.7),
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.8),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildModernStatusChip(bool isSynced, ThemeData theme) {
    Color color;
    String label;
    
    if (isSynced) {
      color = Colors.green;
      label = 'Synchronisé';
    } else {
      color = Colors.red;
      label = 'Non synchronisé';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color.withOpacity(0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingActionButton(ThemeData theme) {
    return FloatingActionButton.extended(
      onPressed: () => context.go('${AppRoutes.newTroncon}/${widget.projet.id}'),
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: theme.colorScheme.onPrimary,
      icon: const Icon(Icons.add_road),
      label: const Text('Ajouter tronçon'),
    );
  }

  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'duplicate':
        _showFeatureNotImplemented(context);
        break;
      case 'archive':
        _showFeatureNotImplemented(context);
        break;
      case 'delete':
        _showDeleteConfirmation(context);
        break;
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le projet'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer le projet "${widget.projet.nom}" ? Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.go(AppRoutes.projets);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _showFeatureNotImplemented(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fonctionnalité en cours de développement'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

// Widgets d'état de chargement et d'erreur avec le même style
class _LoadingScaffold extends StatelessWidget {
  const _LoadingScaffold();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Chargement des détails du projet...',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorScaffold extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;

  const _ErrorScaffold({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Erreur lors du chargement',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Réessayer'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotFoundScaffold extends StatelessWidget {
  final VoidCallback onGoBack;

  const _NotFoundScaffold({required this.onGoBack});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.search_off,
                  size: 64,
                  color: theme.colorScheme.primary.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Projet introuvable',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Le projet demandé n\'existe pas ou a été supprimé.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onGoBack,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Retour aux projets'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 