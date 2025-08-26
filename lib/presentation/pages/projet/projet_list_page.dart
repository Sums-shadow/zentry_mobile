import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_routes.dart';
import '../../../domain/entities/projet.dart';
import '../../../domain/entities/troncon.dart';
import '../../providers/projet_provider.dart';
import '../../providers/troncon_provider.dart'; // Ajout de l'import
import 'package:intl/intl.dart';

class ProjetListPage extends ConsumerStatefulWidget {
  const ProjetListPage({super.key});

  @override
  ConsumerState<ProjetListPage> createState() => _ProjetListPageState();
}

class _ProjetListPageState extends ConsumerState<ProjetListPage>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearchActive = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Filtres
  String _selectedFilter = 'tous';
  bool _isGridView = false;

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
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final projetsAsyncValue = ref.watch(projetsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(theme),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: _buildSearchAndFilters(theme),
            ),
          ),
          // SliverToBoxAdapter(
          //   child: _buildStatsSection(projetsAsyncValue, theme),
          // ),
          _buildProjectsList(projetsAsyncValue, theme),
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
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _isSearchActive
              ? null
              : const Text(
                  'Mes Projets',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
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
      actions: [
        // Bouton retour au dashboard
        IconButton(
          icon: const Icon(Icons.home_rounded),
          onPressed: () {
            context.go(AppRoutes.dashboard);
          },
          tooltip: 'Retour au dashboard',
        ),
        IconButton(
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Icon(
              _isGridView ? Icons.view_list : Icons.grid_view,
              key: ValueKey(_isGridView),
            ),
          ),
          onPressed: () {
            setState(() {
              _isGridView = !_isGridView;
            });
          },
          tooltip: _isGridView ? 'Vue liste' : 'Vue grille',
        ),
        IconButton(
          icon: const Icon(Icons.refresh_rounded),
          onPressed: () {
            ref.read(projetsProvider.notifier).loadProjets();
            _showSnackBar('Actualisation en cours...', Colors.blue);
          },
          tooltip: 'Actualiser',
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Barre de recherche moderne
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _isSearchActive ? 60 : 50,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un projet...',
                prefixIcon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    _isSearchActive ? Icons.search_rounded : Icons.search_outlined,
                    color: theme.colorScheme.primary,
                    key: ValueKey(_isSearchActive),
                  ),
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                            _isSearchActive = false;
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: theme.colorScheme.surface,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: theme.colorScheme.outline.withOpacity(0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 2,
                  ),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _isSearchActive = value.isNotEmpty;
                });
              },
              onTap: () {
                setState(() {
                  _isSearchActive = true;
                });
              },
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Filtres modernes
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('tous', 'Tous', Icons.apps_rounded),
                _buildFilterChip('actif', 'Actifs', Icons.play_circle_outline),
                _buildFilterChip('en_cours', 'En cours', Icons.pending_outlined),
                _buildFilterChip('termine', 'Terminés', Icons.check_circle_outline),
                _buildFilterChip('suspendu', 'Suspendus', Icons.pause_circle_outline),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label, IconData icon) {
    final theme = Theme.of(context);
    final isSelected = _selectedFilter == value;
    
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: FilterChip(
          selected: isSelected,
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected 
                    ? theme.colorScheme.onPrimary 
                    : theme.colorScheme.onSurface,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected 
                      ? theme.colorScheme.onPrimary 
                      : theme.colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
          onSelected: (selected) {
            setState(() {
              _selectedFilter = value;
            });
          },
          backgroundColor: theme.colorScheme.surface,
          selectedColor: theme.colorScheme.primary,
          checkmarkColor: theme.colorScheme.onPrimary,
          side: BorderSide(
            color: isSelected 
                ? theme.colorScheme.primary 
                : theme.colorScheme.outline.withOpacity(0.3),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection(AsyncValue<List<Projet>> projetsAsyncValue, ThemeData theme) {
    return projetsAsyncValue.when(
      data: (projets) {
        final filteredProjets = _getFilteredProjects(projets);
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                '${filteredProjets.length}',
                'Projets',
                Icons.folder_outlined,
                theme.colorScheme.primary,
              ),
              _buildStatItem(
                '${projets.where((p) => true).length}', // Tous actifs par défaut
                'Actifs',
                Icons.trending_up_rounded,
                Colors.green,
              ),
              _buildStatItem(
                '${projets.length}',
                'Total',
                Icons.analytics_outlined,
                theme.colorScheme.secondary,
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
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
            fontSize: 20,
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

  Widget _buildProjectsList(AsyncValue<List<Projet>> projetsAsyncValue, ThemeData theme) {
    return projetsAsyncValue.when(
      data: (projets) {
        final filteredProjets = _getFilteredProjects(projets);
        
        if (filteredProjets.isEmpty) {
          return SliverToBoxAdapter(
            child: _buildEmptyState(theme),
          );
        }
        
        return _isGridView 
            ? _buildGridView(filteredProjets, theme)
            : _buildListView(filteredProjets, theme);
      },
      loading: () => SliverToBoxAdapter(
        child: _buildLoadingState(theme),
      ),
      error: (error, stack) => SliverToBoxAdapter(
        child: _buildErrorState(error, theme),
      ),
    );
  }

  Widget _buildListView(List<Projet> projets, ThemeData theme) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return TweenAnimationBuilder<double>(
              duration: Duration(milliseconds: 300 + (index * 100)),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset((1 - value) * 100, 0),
                  child: Opacity(
                    opacity: value,
                    child: _buildModernProjetCard(projets[index], theme),
                  ),
                );
              },
            );
          },
          childCount: projets.length,
        ),
      ),
    );
  }

  Widget _buildGridView(List<Projet> projets, ThemeData theme) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => _buildGridProjetCard(projets[index], theme),
          childCount: projets.length,
        ),
      ),
    );
  }

  Widget _buildModernProjetCard(Projet projet, ThemeData theme) {
    final dateFormatter = DateFormat('dd/MM/yyyy');
    final nbTroncons = ref.watch(tronconsByProjetProvider(projet.id!));
    final troncons = nbTroncons.when(
      data: (troncons) => troncons,
      loading: () => [],
      error: (_, __) => [],
    );
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        elevation: 2,
        shadowColor: theme.shadowColor.withOpacity(0.1),
        child: InkWell(
          onTap: () => context.go('${AppRoutes.projetDetail}/${projet.id}'),
          borderRadius: BorderRadius.circular(20),
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
                            projet.nom,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'ID: ${projet.id}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildModernStatusChip(projet.id!, theme),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Description si disponible
                if (projet.description != null && projet.description!.isNotEmpty) ...[
                  Text(
                    projet.description!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                ],
                
                // Informations détaillées
                _buildInfoRow(
                  Icons.route_rounded,
                  'Tronçon',
                  '${troncons.length}',
                  theme,
                ),
                const SizedBox(height: 8),
                 
                _buildInfoRow(
                  Icons.calendar_today_outlined,
                  'Date',
                  dateFormatter.format(projet.date),
                  theme,
                ),
                
              
                const SizedBox(height: 20),
                
                // Actions
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => context.go('${AppRoutes.newTroncon}/${projet.id}'),
                        icon: const Icon(Icons.add_road, size: 18),
                        label: const Text('Tronçons'),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton.outlined(
                      onPressed: () => _showProjectOptions(projet),
                      icon: const Icon(Icons.more_vert_rounded),
                      style: IconButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGridProjetCard(Projet projet, ThemeData theme) {
    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      shadowColor: theme.shadowColor.withOpacity(0.1),
      child: InkWell(
        onTap: () => context.go('${AppRoutes.projetDetail}/${projet.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      projet.nom,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _showProjectOptions(projet),
                    icon: const Icon(Icons.more_vert_rounded, size: 20),
                    style: IconButton.styleFrom(
                      minimumSize: const Size(32, 32),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
              
              const Spacer(),
              
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    projet.troncon ?? 'Non spécifié',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    projet.province,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => context.go('${AppRoutes.newPointEntree}/${projet.id}'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Ajouter point',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
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

  Widget _buildModernStatusChip(int id, ThemeData theme) {
    final troncons = ref.watch(tronconsByProjetProvider(id));
    
    return troncons.when(
      data: (tronconList) {
        final Color color;
        final String label;
        
        if (tronconList.isEmpty || tronconList.any((troncon) => !troncon.sync)) {
          color = Colors.orange;
          label = 'Non synchronisé';
        } else {
          color = Colors.green;
          label = 'Synchronisé'; 
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
      },
      loading: () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Colors.grey,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            const Text(
              'Chargement...',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      error: (_, __) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.red.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            const Text(
              'Erreur',
              style: TextStyle(
                color: Colors.red,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Container(
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
              _searchQuery.isNotEmpty ? Icons.search_off_rounded : Icons.folder_open_rounded,
              size: 64,
              color: theme.colorScheme.primary.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _searchQuery.isNotEmpty ? 'Aucun projet trouvé' : 'Aucun projet créé',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? 'Essayez une autre recherche ou modifiez vos filtres'
                : 'Créez votre premier projet pour commencer',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (_searchQuery.isEmpty)
            ElevatedButton.icon(
              onPressed: () => context.go(AppRoutes.newProjet),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Créer un projet'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            strokeWidth: 3,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 24),
          Text(
            'Chargement des projets...',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object error, ThemeData theme) {
    return Container(
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
              Icons.error_outline_rounded,
              size: 64,
              color: Colors.red.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Erreur de chargement',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Une erreur est survenue lors du chargement des projets',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              ref.read(projetsProvider.notifier).loadProjets();
            },
            icon: const Icon(Icons.refresh_rounded),
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
    );
  }

  Widget _buildFloatingActionButton(ThemeData theme) {
    return FloatingActionButton.extended(
      onPressed: () => context.go(AppRoutes.newProjet),
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: theme.colorScheme.onPrimary,
      elevation: 4,
      icon: const Icon(Icons.add_rounded),
      label: const Text(
        'Nouveau projet',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }

  List<Projet> _getFilteredProjects(List<Projet> projects) {
    List<Projet> filtered = projects;

    // Filtrer par statut (pour l'instant tous sont actifs)
    if (_selectedFilter != 'tous') {
      // Ici on pourrait filtrer par statut si le modèle avait ce champ
      // filtered = filtered.where((p) => p.statut == _selectedFilter).toList();
    }

    // Filtrer par recherche
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((project) {
        return project.nom.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               (project.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
               project.province.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               (project.troncon?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
               (project.agent?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      }).toList();
    }

    return filtered;
  }

  void _showProjectOptions(Projet projet) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    projet.nom,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildOptionTile(
                    Icons.visibility_outlined,
                    'Voir les détails',
                    () {
                      Navigator.pop(context);
                      context.go('${AppRoutes.projetDetail}/${projet.id}');
                    },
                  ),
                  _buildOptionTile(
                    Icons.add_location_alt_outlined,
                    'Ajouter un point d\'entrée',
                    () {
                      Navigator.pop(context);
                      context.go('${AppRoutes.newPointEntree}/${projet.id}');
                    },
                  ),
                  _buildOptionTile(
                    Icons.edit_outlined,
                    'Modifier',
                    () {
                      Navigator.pop(context);
                      // TODO: Navigation vers modification
                    },
                  ),
                    _buildOptionTile(
                    Icons.sync_outlined,
                    'Synchroniser',
                    () {
                      Navigator.pop(context);
                      _showSyncConfirmation(projet);
                    },
                    isSync: true,
                  ),
                  _buildOptionTile(
                    Icons.delete_outlined,
                    'Supprimer',
                    () {
                      Navigator.pop(context);
                      _showDeleteConfirmation(projet);
                    },
                    isDestructive: true,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile(
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool isDestructive = false,
    bool isSync = false,
  }) {
    final theme = Theme.of(context);
    final color = isDestructive ? Colors.red : isSync ? Colors.green : theme.colorScheme.onSurface;
    
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  void _showDeleteConfirmation(Projet projet) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.red,
              size: 28,
            ),
            const SizedBox(width: 12),
            const Text('Supprimer le projet'),
          ],
        ),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer le projet "${projet.nom}" ?\n\nCette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref.read(projetsProvider.notifier).deleteProjet(projet.id!);
                _showSnackBar('Projet supprimé avec succès', Colors.green);
              } catch (e) {
                _showSnackBar('Erreur lors de la suppression', Colors.red);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _showSyncConfirmation(Projet projet) {
    final troncons = ref.read(tronconsByProjetProvider(projet.id!));
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.sync_rounded,
              color: Colors.blue,
              size: 18,
            ),
            const SizedBox(width: 8),
            const Text('Synchroniser le projet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Voulez-vous synchroniser ce projet avec le serveur en ligne?',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            troncons.when(
              data: (tronconList) {
                // Filtrer uniquement les tronçons non synchronisés
                final unsyncedTroncons = tronconList.where((troncon) => !troncon.sync).toList();
                
                if (unsyncedTroncons.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          color: Colors.green,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Tous les tronçons sont déjà synchronisés',
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: Colors.green,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                return Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tronçons à synchroniser (${unsyncedTroncons.length}):',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...unsyncedTroncons.map((troncon) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.orange.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.sync_problem_rounded,
                                size: 16,
                                color: Colors.orange,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'PK${troncon.pkDebut}+PK${troncon.pkFin}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        )).toList(),
                      ],
                    ),
                  ),
                );
              },
              loading: () => Container(
                padding: const EdgeInsets.all(16),
                child: const Row(
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 12),
                    Text('Chargement des tronçons...'),
                  ],
                ),
              ),
              error: (_, __) => Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Erreur lors du chargement des tronçons',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Annuler'),
          ),
                     ElevatedButton(
             onPressed: () async {
               Navigator.pop(context);
               await _syncProject(projet);
             },
             style: ElevatedButton.styleFrom(
               backgroundColor: Colors.green,
               foregroundColor: Colors.white,
             ),
             child: const Text('Confirmer'),
           ),
        ],
      ),
    );
  }

  Future<void> _syncProject(Projet projet) async {
    // Afficher le loader
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            const Text(
              'Synchronisation en cours...',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );

    try {
      // Récupérer les tronçons non synchronisés
      final tronconsAsyncValue = ref.read(tronconsByProjetProvider(projet.id!));
      final troncons = tronconsAsyncValue.when( 
        data: (tronconList) => tronconList.where((t) => !t.sync).toList(),
        loading: () => <Troncon>[],
        error: (_, __) => <Troncon>[],
      );

      // Appeler l'API de synchronisation
      final result = await ref.read(projetsProvider.notifier).syncProjet(projet, troncons);

      // Fermer le loader
      if (mounted) Navigator.pop(context);

      // Afficher le résultat
      if (result['success']) {
        // Marquer tous les tronçons du projet comme synchronisés
        // await ref.read(tronconsByProjetProvider(projet.id!).notifier).markAllTronconsAsSynced();
        _showSuccessDialog(result['message']);
      } else {
        _showErrorDialog(result['statusCode'], result['message']);
      }
    } catch (e) {
      // Fermer le loader
      if (mounted) Navigator.pop(context);
      
      // Afficher l'erreur
      _showErrorDialog(500, 'Erreur inattendue lors de la synchronisation');
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.check_circle_rounded,
              color: Colors.green,
              size: 18,
            ),
            const SizedBox(width:8),
            const Text('Synchronisation réussie', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Recharger les données
              ref.read(projetsProvider.notifier).loadProjets();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(int statusCode, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.error_rounded,
              color: Colors.red,
              size: 18,
            ),
            const SizedBox(width: 8),
            const Text('Erreur de synchronisation', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Code d\'erreur: $statusCode',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 16,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Optionnel: proposer de réessayer
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }
} 