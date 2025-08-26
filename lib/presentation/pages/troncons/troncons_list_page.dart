import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_routes.dart';
import '../../../domain/entities/troncon.dart';
import '../../providers/troncon_provider.dart';
import '../../widgets/troncon/troncon_list_widget.dart';


class TronconsListPage extends ConsumerStatefulWidget {
  final String projetId;
  final String projetNom;

  const TronconsListPage({
    super.key,
    required this.projetId,
    required this.projetNom,
  });

  @override
  ConsumerState<TronconsListPage> createState() => _TronconsListPageState();
}

class _TronconsListPageState extends ConsumerState<TronconsListPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  String _searchQuery = '';
  String _selectedFilter = 'all';
  bool _isSearchVisible = false;
  
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tronconsAsyncValue = ref.watch(tronconsByProjetProvider(int.parse(widget.projetId)));
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(theme),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  // Barre de recherche et filtres
                  _buildSearchAndFilters(theme),
                  
                  // Contenu principal
                  tronconsAsyncValue.when(
                    loading: () => _buildLoadingState(),
                    error: (error, stackTrace) => _buildErrorState(error),
                    data: (troncons) => _buildTronconsList(troncons, theme),
                  ),
                ],
              ),
            ),
          ),
        ],
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
          'Tronçons',
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
                theme.colorScheme.primary.withValues(alpha: 0.8),
              ],
            ),
          ),
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      actions: [
        IconButton(
          icon: AnimatedRotation(
            turns: _isSearchVisible ? 0.5 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: Icon(_isSearchVisible ? Icons.close : Icons.search),
          ),
          onPressed: _toggleSearch,
          tooltip: _isSearchVisible ? 'Fermer la recherche' : 'Rechercher',
        ),
        PopupMenuButton<String>(
          onSelected: _handleMenuAction,
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'export',
              child: Row(
                children: [
                  Icon(Icons.download_outlined, size: 20),
                  SizedBox(width: 12),
                  Text('Exporter'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'stats',
              child: Row(
                children: [
                  Icon(Icons.analytics_outlined, size: 20),
                  SizedBox(width: 12),
                  Text('Statistiques'),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildSearchAndFilters(ThemeData theme) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _isSearchVisible ? 120 : 80,
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Barre de recherche
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _isSearchVisible ? 48 : 0,
            child: _isSearchVisible
                ? TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    decoration: InputDecoration(
                      hintText: 'Rechercher par PK, type de chaussée...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: _clearSearch,
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusM),
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  )
                : const SizedBox.shrink(),
          ),
          
          if (_isSearchVisible) const SizedBox(height: AppTheme.spacingM),
          
          // Filtres
          SizedBox(
            height: 32,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildFilterChip('all', 'Tous', theme),
                const SizedBox(width: AppTheme.spacingS),
                _buildFilterChip('bon_etat', 'Bon état', theme),
                const SizedBox(width: AppTheme.spacingS),
                _buildFilterChip('etat_moyen', 'État moyen', theme),
                const SizedBox(width: AppTheme.spacingS),
                _buildFilterChip('mauvais_etat', 'Mauvais état', theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label, ThemeData theme) {
    final isSelected = _selectedFilter == value;
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
      },
      backgroundColor: theme.colorScheme.surface,
      selectedColor: theme.colorScheme.primary.withValues(alpha: 0.1),
      checkmarkColor: theme.colorScheme.primary,
      labelStyle: TextStyle(
        color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected 
            ? theme.colorScheme.primary 
            : theme.colorScheme.outline.withValues(alpha: 0.2),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const SizedBox(
      height: 400,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: AppTheme.spacingL),
            Text('Chargement des tronçons...'),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Container(
      height: 400,
      padding: const EdgeInsets.all(AppTheme.spacingL),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppTheme.errorColor,
            ),
            const SizedBox(height: AppTheme.spacingL),
            Text(
              'Erreur lors du chargement',
              style: AppTheme.titleLarge.copyWith(
                color: AppTheme.errorColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTheme.spacingS),
            Text(
              error.toString(),
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingL),
            ElevatedButton.icon(
              onPressed: () => ref.refresh(tronconsByProjetProvider(int.parse(widget.projetId))),
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTronconsList(List<Troncon> allTroncons, ThemeData theme) {
    // Filtrer les tronçons selon la recherche et le filtre
    final filteredTroncons = _filterTroncons(allTroncons);
    
    if (filteredTroncons.isEmpty) {
      return _buildEmptyState(theme);
    }

    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête avec statistiques
          _buildStatsHeader(filteredTroncons, theme),
          const SizedBox(height: AppTheme.spacingL),
          
          // Liste des tronçons
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredTroncons.length,
            separatorBuilder: (context, index) => const SizedBox(height: AppTheme.spacingM),
            itemBuilder: (context, index) {
              final troncon = filteredTroncons[index];
              return TronconCard(
                troncon: troncon,
                onTap: () => _navigateToTronconDetail(troncon),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatsHeader(List<Troncon> troncons, ThemeData theme) {
    final stats = _calculateStats(troncons);
    
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics_outlined,
                color: theme.colorScheme.primary,
                size: AppTheme.iconM,
              ),
              const SizedBox(width: AppTheme.spacingS),
              Text(
                'Résumé des tronçons',
                style: AppTheme.titleMedium.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingL),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Total',
                  '${stats['total']}',
                  Icons.straighten_rounded,
                  theme.colorScheme.primary,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Bon état',
                  '${stats['good']}',
                  Icons.check_circle_outline,
                  AppTheme.successColor,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'À surveiller',
                  '${stats['warning']}',
                  Icons.warning_amber_outlined,
                  AppTheme.warningColor,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Mauvais état',
                  '${stats['bad']}',
                  Icons.error_outline,
                  AppTheme.errorColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: AppTheme.iconM),
        const SizedBox(height: AppTheme.spacingXS),
        Text(
          value,
          style: AppTheme.titleLarge.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTheme.bodySmall.copyWith(
            color: AppTheme.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    final hasFilters = _searchQuery.isNotEmpty || _selectedFilter != 'all';
    
    return Container(
      height: 400,
      padding: const EdgeInsets.all(AppTheme.spacingL),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasFilters ? Icons.search_off : Icons.alt_route,
              size: 64,
              color: theme.colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppTheme.spacingL),
            Text(
              hasFilters ? 'Aucun résultat' : 'Aucun tronçon',
              style: AppTheme.titleLarge.copyWith(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTheme.spacingS),
            Text(
              hasFilters 
                  ? 'Essayez de modifier vos critères de recherche'
                  : 'Commencez par ajouter votre premier tronçon',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingL),
            if (hasFilters)
              OutlinedButton.icon(
                onPressed: _clearFilters,
                icon: const Icon(Icons.clear_all),
                label: const Text('Effacer les filtres'),
              )
            else
              ElevatedButton.icon(
                onPressed: _navigateToNewTroncon,
                icon: const Icon(Icons.add_road),
                label: const Text('Ajouter un tronçon'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton(ThemeData theme) {
    return FloatingActionButton.extended(
      onPressed: _navigateToNewTroncon,
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: theme.colorScheme.onPrimary,
      icon: const Icon(Icons.add_road),
      label: const Text('Ajouter'),
    );
  }

  // Méthodes utilitaires
  List<Troncon> _filterTroncons(List<Troncon> troncons) {
    var filtered = troncons.where((troncon) {
      // Filtre de recherche
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final pkDebut = troncon.pkDebut?.toLowerCase() ?? '';
        final pkFin = troncon.pkFin?.toLowerCase() ?? '';
        final typeChaussee = troncon.typeChaussee?.toLowerCase() ?? '';
        
        if (!pkDebut.contains(query) && 
            !pkFin.contains(query) && 
            !typeChaussee.contains(query)) {
          return false;
        }
      }
      
      // Filtre de statut
      if (_selectedFilter != 'all') {
        final status = TronconStatusCalculator.calculate(troncon);
        if (status.status != _selectedFilter) {
          return false;
        }
      }
      
      return true;
    }).toList();
    
    // Tri par PK début
    filtered.sort((a, b) {
      final pkA = double.tryParse(a.pkDebut ?? '0') ?? 0;
      final pkB = double.tryParse(b.pkDebut ?? '0') ?? 0;
      return pkA.compareTo(pkB);
    });
    
    return filtered;
  }

  Map<String, int> _calculateStats(List<Troncon> troncons) {
    int good = 0, warning = 0, bad = 0;
    
    for (final troncon in troncons) {
      final status = TronconStatusCalculator.calculate(troncon);
      switch (status.status) {
        case 'bon_etat':
          good++;
          break;
        case 'etat_moyen':
          warning++;
          break;
        case 'mauvais_etat':
          bad++;
          break;
      }
    }
    
    return {
      'total': troncons.length,
      'good': good,
      'warning': warning,
      'bad': bad,
    };
  }

  // Actions
  void _toggleSearch() {
    setState(() {
      _isSearchVisible = !_isSearchVisible;
      if (_isSearchVisible) {
        _searchFocusNode.requestFocus();
      } else {
        _clearSearch();
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
    });
  }

  void _clearFilters() {
    _clearSearch();
    setState(() {
      _selectedFilter = 'all';
    });
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'export':
        _showFeatureNotImplemented('Fonctionnalité d\'export en cours de développement');
        break;
      case 'stats':
        _showFeatureNotImplemented('Statistiques détaillées en cours de développement');
        break;
    }
  }

  void _navigateToTronconDetail(Troncon troncon) {
    // TODO: Implémenter la navigation vers le détail du tronçon
    _showFeatureNotImplemented('Page de détail du tronçon en cours de développement');
  }

  void _navigateToNewTroncon() {
    context.go('${AppRoutes.newTroncon}/${widget.projetId}');
  }

  void _showFeatureNotImplemented(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
} 