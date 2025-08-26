import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/troncon.dart';
import '../../providers/troncon_provider.dart';
import '../../widgets/common/status_badge.dart';
import '../../widgets/troncon/troncon_list_widget.dart';

class TronconDetailPage extends ConsumerStatefulWidget {
  final String tronconId;

  const TronconDetailPage({
    super.key,
    required this.tronconId,
  });

  @override
  ConsumerState<TronconDetailPage> createState() => _TronconDetailPageState();
}

class _TronconDetailPageState extends ConsumerState<TronconDetailPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final DateFormat _dateFormatter = DateFormat('dd/MM/yyyy à HH:mm');

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
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

  @override
  Widget build(BuildContext context) {
    final tronconAsyncValue = ref.watch(tronconByIdProvider(int.parse(widget.tronconId)));

    return Scaffold(
      body: tronconAsyncValue.when(
        loading: () => const _LoadingScaffold(),
        error: (error, stackTrace) => _ErrorScaffold(
          error: error,
          onRetry: () => ref.refresh(tronconByIdProvider(int.parse(widget.tronconId))),
        ),
        data: (troncon) {
          if (troncon == null) {
            return _NotFoundScaffold(
              onGoBack: () => context.pop(),
            );
          }
          return _TronconDetailContent(
            troncon: troncon,
            tronconId: widget.tronconId,
            ref: ref,
          );
        },
      ),
    );
  }


}

class _TronconDetailContent extends StatefulWidget {
  final Troncon troncon;
  final String tronconId;
  final WidgetRef ref;

  const _TronconDetailContent({
    required this.troncon,
    required this.tronconId,
    required this.ref,
  });

  @override
  State<_TronconDetailContent> createState() => _TronconDetailContentState();
}

class _TronconDetailContentState extends State<_TronconDetailContent>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = TronconStatusCalculator.calculate(widget.troncon);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(theme, status),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderCard(theme, status),
                    const SizedBox(height: 24),
                    _buildLocationCard(theme),
                    const SizedBox(height: 24),
                    _buildGeneralInfoCard(theme),
                    const SizedBox(height: 24),
                    _buildRoadConditionCard(theme),
                    const SizedBox(height: 24),
                    _buildInfrastructureCard(theme),
                    const SizedBox(height: 24),
                    _buildSafetyCard(theme),
                    const SizedBox(height: 24),
                    _buildEnvironmentCard(theme),
                    const SizedBox(height: 24),
                    _buildRecommendationsCard(theme),
                    const SizedBox(height: 24),
                    _buildImagesCard(theme),
                    const SizedBox(height: 100), // Espace pour le FAB
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(theme),
    );
  }

  Widget _buildSliverAppBar(ThemeData theme, TronconStatus status) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: theme.colorScheme.primary,
      actions: [
        IconButton(
          onPressed: () => _showDeleteConfirmDialog(context),
          icon: const Icon(
            Icons.delete_rounded,
            color: Colors.white,
          ),
          tooltip: 'Supprimer le tronçon',
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'PK ${widget.troncon.pkDebut} → PK ${widget.troncon.pkFin}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.primary.withOpacity(0.8),
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 80,
                right: 20,
                child: StatusBadgeWhite(status: status.status),
              ),
              Positioned(
                bottom: 60,
                left: 20,
                right: 20,
                child: Row(
                  children: [
                    Icon(
                      Icons.alt_route_rounded,
                      color: Colors.white.withOpacity(0.8),
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${widget.troncon.distance?.toStringAsFixed(2) ?? "?"} km',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(ThemeData theme, TronconStatus status) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        side: BorderSide(
          color: theme.colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: StatusColors.forStatus(status.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.info_outline_rounded,
                    color: StatusColors.forStatus(status.status),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Informations générales',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Créé le ${DateFormat('dd/MM/yyyy à HH:mm').format(widget.troncon.dateCreation)}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                StatusBadge(
                  status: status.status,
                  isLarge: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard(ThemeData theme) {
    return _SectionCard(
      title: '📍 Localisation GPS',
      icon: Icons.location_on_rounded,
      theme: theme,
      child: Column(
        children: [
          _InfoRow(
            label: 'Latitude',
            value: widget.troncon.latitude != null 
                ? '${widget.troncon.latitude!.toStringAsFixed(6)}°'
                : 'Non définie',
            icon: Icons.explore_rounded,
          ),
          _InfoRow(
            label: 'Longitude',
            value: widget.troncon.longitude != null 
                ? '${widget.troncon.longitude!.toStringAsFixed(6)}°'
                : 'Non définie',
            icon: Icons.explore_rounded,
          ),
          _InfoRow(
            label: 'Altitude',
            value: widget.troncon.altitude != null 
                ? '${widget.troncon.altitude!.toStringAsFixed(1)} m'
                : 'Non définie',
            icon: Icons.terrain_rounded,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralInfoCard(ThemeData theme) {
    return _SectionCard(
      title: '📋 Informations générales',
      icon: Icons.info_outline_rounded,
      theme: theme,
      child: Column(
        children: [
          _InfoRow(
            label: 'Longueur du tronçon',
            value: '${widget.troncon.longueurTroncon?.toStringAsFixed(0) ?? "Non défini"} m',
            icon: Icons.straighten_rounded,
          ),
          _InfoRow(
            label: 'Largeur d\'emprise',
            value: '${widget.troncon.largeurEmprise?.toStringAsFixed(1) ?? "Non défini"} m',
            icon: Icons.width_wide_rounded,
          ),
          _InfoRow(
            label: 'Classe de route',
            value: widget.troncon.classeRoute ?? 'Non défini',
            icon: Icons.category_rounded,
          ),
          _InfoRow(
            label: 'Profil topographique',
            value: widget.troncon.profilTopographique ?? 'Non défini',
            icon: Icons.terrain_rounded,
          ),
          _InfoRow(
            label: 'Conditions climatiques',
            value: widget.troncon.conditionsClimatiques ?? 'Non défini',
            icon: Icons.wb_sunny_rounded,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildRoadConditionCard(ThemeData theme) {
    return _SectionCard(
      title: '🛣️ État de la chaussée',
      icon: Icons.route_rounded,
      theme: theme,
      child: Column(
        children: [
          _InfoRow(
            label: 'Type de chaussée',
            value: widget.troncon.typeChaussee ?? 'Non défini',
            icon: Icons.layers_rounded,
          ),
          _InfoRow(
            label: 'Type de sol',
            value: widget.troncon.typeSol ?? 'Non défini',
            icon: Icons.landscape_rounded,
          ),
          const SizedBox(height: 16),
          _buildProblemsGrid(theme),
        ],
      ),
    );
  }

  Widget _buildProblemsGrid(ThemeData theme) {
    final problems = [
      _ProblemItem('Nids de poules', widget.troncon.presenceNidsPoules, Icons.warning_rounded),
      _ProblemItem('Zones d\'érosion', widget.troncon.zonesErosion, Icons.water_damage_rounded),
      _ProblemItem('Eau stagnante', widget.troncon.zonesEauStagnante, Icons.water_rounded),
             _ProblemItem('Bourbiers', widget.troncon.bourbiers, Icons.water_damage_rounded),
      _ProblemItem('Déformations', widget.troncon.deformations, Icons.broken_image_rounded),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Problèmes identifiés',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: problems.map((problem) => _ProblemChip(
            problem: problem,
            theme: theme,
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildInfrastructureCard(ThemeData theme) {
    return _SectionCard(
      title: '🏗️ Ouvrages d\'art & Assainissement',
      icon: Icons.engineering_rounded,
      theme: theme,
      child: Column(
        children: [
                     _InfoRow(
             label: 'État ponts et dalots',
             value: widget.troncon.etatPontsDalots ?? 'Non évalué',
             icon: Icons.architecture_rounded,
           ),
          _InfoRow(
            label: 'Buses fonctionnelles',
            value: widget.troncon.busesFonctionnelles == true ? 'Oui' : 'Non',
            icon: Icons.plumbing_rounded,
          ),
          _InfoRow(
            label: 'Exutoires zones évacuation',
            value: widget.troncon.exutoiresZonesEvac ? 'Présents' : 'Absents',
            icon: Icons.outlet_rounded,
          ),
          _InfoRow(
            label: 'Zones érosion/dépôts',
            value: widget.troncon.zonesErosionDepots ? 'Présentes' : 'Absentes',
            icon: Icons.landslide_rounded,
          ),
          _InfoRow(
            label: 'Drainage suffisant',
            value: widget.troncon.drainageSuffisant ? 'Oui' : 'Non',
            icon: Icons.water_drop_rounded,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyCard(ThemeData theme) {
    return _SectionCard(
      title: '🚦 Sécurité routière',
      icon: Icons.security_rounded,
      theme: theme,
      child: Column(
        children: [
          _InfoRow(
            label: 'Signalisation verticale',
            value: widget.troncon.signalisationVerticale ? 'Présente' : 'Absente',
            icon: Icons.sign_language_rounded,
          ),
          _InfoRow(
            label: 'Signalisation horizontale',
            value: widget.troncon.signalisationHorizontale ? 'Présente' : 'Absente',
            icon: Icons.linear_scale_rounded,
          ),
          _InfoRow(
            label: 'Glissières de sécurité',
            value: widget.troncon.glissieresSecurite ? 'Présentes' : 'Absentes',
            icon: Icons.safety_divider_rounded,
          ),
          _InfoRow(
            label: 'Visibilité',
            value: widget.troncon.visibilite ?? 'Non évaluée',
            icon: Icons.visibility_rounded,
          ),
          _InfoRow(
            label: 'Zones sensibles',
            value: widget.troncon.zonesSensibles ? 'Présentes' : 'Absentes',
            icon: Icons.warning_amber_rounded,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildEnvironmentCard(ThemeData theme) {
    return _SectionCard(
      title: '🌍 Villages et environnement',
      icon: Icons.location_city_rounded,
      theme: theme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoRow(
            label: 'Nombre de villages',
            value: '${widget.troncon.nombreVillages ?? 0}',
            icon: Icons.home_work_rounded,
          ),
          const SizedBox(height: 16),
          if (widget.troncon.occupationSol.isNotEmpty) ...[
            _buildTagSection(
              'Occupation du sol',
              widget.troncon.occupationSol,
              theme,
              Icons.landscape_rounded,
            ),
            const SizedBox(height: 16),
          ],
          if (widget.troncon.equipementsSociaux.isNotEmpty) ...[
            _buildTagSection(
              'Équipements sociaux',
              widget.troncon.equipementsSociaux,
              theme,
              Icons.school_rounded,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRecommendationsCard(ThemeData theme) {
    return _SectionCard(
      title: '💡 Recommandations techniques',
      icon: Icons.lightbulb_outline_rounded,
      theme: theme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.troncon.observationsGenerales != null && widget.troncon.observationsGenerales!.isNotEmpty) ...[
            Row(
              children: [
                Icon(
                  Icons.note_rounded,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Observations générales',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface.withOpacity(0.8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.2),
                ),
              ),
              child: Text(
                widget.troncon.observationsGenerales!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.8),
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (widget.troncon.interventionsSuggerees.isNotEmpty) ...[
            _buildTagSection(
              'Interventions suggérées',
              widget.troncon.interventionsSuggerees,
              theme,
              Icons.build_rounded,
              color: theme.colorScheme.secondary,
            ),
            const SizedBox(height: 16),
          ],
          if (widget.troncon.observationsInterventions.isNotEmpty) ...[
            Text(
              'Observations détaillées',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 12),
            ...widget.troncon.observationsInterventions.entries.map(
              (entry) => _ObservationItem(
                title: entry.key,
                description: entry.value,
                theme: theme,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildImagesCard(ThemeData theme) {
    return _SectionCard(
      title: '📸 Galerie photos (${widget.troncon.images.length})',
      icon: Icons.photo_library_rounded,
      theme: theme,
      child: widget.troncon.images.isEmpty
          ? Container(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    Icons.photo_library_outlined,
                    size: 48,
                    color: theme.colorScheme.onSurface.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Aucune photo disponible',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),

                ],
              ),
            )
          : _ImageGallery(images: widget.troncon.images),
    );
  }

  Widget _buildTagSection(String title, List<String> items, ThemeData theme, IconData icon, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: color ?? theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items.map((item) => Chip(
            label: Text(
              item,
              style: TextStyle(
                fontSize: 12,
                color: color ?? theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: (color ?? theme.colorScheme.primary).withOpacity(0.1),
            side: BorderSide(
              color: (color ?? theme.colorScheme.primary).withOpacity(0.3),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildFloatingActionButton(ThemeData theme) {
    return FloatingActionButton.extended(
      onPressed: () {
        // Action pour modifier le tronçon
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fonctionnalité de modification à implémenter'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      icon: const Icon(Icons.edit_rounded),
      label: const Text('Modifier'),
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: theme.colorScheme.onPrimary,
    );
  }

  void _showDeleteConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusL),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.delete_rounded,
                  color: AppTheme.errorColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text('Attention'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Êtes-vous sûr de vouloir supprimer ce tronçon ?',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.errorColor.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: AppTheme.errorColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'PK ${widget.troncon.pkDebut} → PK ${widget.troncon.pkFin}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.errorColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              
              Text(
                'Cette action est irréversible.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.errorColor,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _deleteTroncon();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }

  void _deleteTroncon() async {
    try {
      // Afficher un indicateur de chargement
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusL),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  'Suppression en cours...',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          );
        },
      );

             // Supprimer le tronçon via le provider
       final tronconId = widget.troncon.id!;
       final projetId = widget.troncon.projetId!;
       await widget.ref.read(tronconsProvider.notifier).deleteTroncon(tronconId);
       
       // Rafraîchir aussi les tronçons du projet spécifique
       widget.ref.refresh(tronconsByProjetProvider(projetId));

      // Fermer le dialogue de chargement
      if (mounted) Navigator.of(context).pop();

      // Afficher le dialogue de succès
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusL),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.successColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.check_circle_rounded,
                      color: AppTheme.successColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text('Suppression réussie'),
                ],
              ),
              content: Text(
                'Le tronçon a été supprimé avec succès.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    _navigateToProjectDetail();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.successColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } catch (error) {
      // Fermer le dialogue de chargement si ouvert
      if (mounted) Navigator.of(context).pop();

      // Afficher l'erreur
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusL),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.errorColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.error_rounded,
                      color: AppTheme.errorColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text('Erreur'),
                ],
              ),
              content: Text(
                'Une erreur est survenue lors de la suppression : ${error.toString()}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              actions: [
                ElevatedButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    }
  }

  void _navigateToProjectDetail() {
    // Rafraîchir les données des tronçons du projet avant de naviguer
    widget.ref.refresh(tronconsByProjetProvider(widget.troncon.projetId!));
    
    // Retourner au détail du projet
    context.go('/projet-detail/${widget.troncon.projetId}');
  }
}

// Widgets auxiliaires

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final ThemeData theme;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        side: BorderSide(
          color: theme.colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isLast;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 20,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (!isLast) ...[
          const SizedBox(height: 16),
          Divider(
            color: theme.colorScheme.outline.withOpacity(0.1),
            height: 1,
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}

class _ProblemItem {
  final String name;
  final bool isPresent;
  final IconData icon;

  const _ProblemItem(this.name, this.isPresent, this.icon);
}

class _ProblemChip extends StatelessWidget {
  final _ProblemItem problem;
  final ThemeData theme;

  const _ProblemChip({
    required this.problem,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final color = problem.isPresent 
        ? AppTheme.errorColor 
        : theme.colorScheme.outline.withOpacity(0.5);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            problem.isPresent ? problem.icon : Icons.check_circle_outline,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            problem.name,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ObservationItem extends StatelessWidget {
  final String title;
  final String description;
  final ThemeData theme;

  const _ObservationItem({
    required this.title,
    required this.description,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.secondary.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.secondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageGallery extends StatelessWidget {
  final List<TronconImage> images;

  const _ImageGallery({required this.images});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          itemCount: images.length,
          itemBuilder: (context, index) {
            return _ImageTile(
              tronconImage: images[index],
              index: index,
              onTap: () => _showImageViewer(context, images, index),
            );
          },
        ),
        if (images.length > 4) ...[
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () => _showAllImages(context, images),
            icon: const Icon(Icons.photo_library_rounded),
            label: Text('Voir toutes les photos (${images.length})'),
          ),
        ],
      ],
    );
  }

  void _showImageViewer(BuildContext context, List<TronconImage> images, int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _ImageViewerPage(
          images: images,
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  void _showAllImages(BuildContext context, List<TronconImage> images) {
    // Implémentation pour afficher toutes les images
    _showImageViewer(context, images, 0);
  }
}

class _ImageTile extends StatelessWidget {
  final TronconImage tronconImage;
  final int index;
  final VoidCallback onTap;

  const _ImageTile({
    required this.tronconImage,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Image réelle ou placeholder en cas d'erreur
              Image.file(
                File(tronconImage.path),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: theme.colorScheme.surfaceVariant,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.broken_image_rounded,
                          size: 40,
                          color: theme.colorScheme.error.withOpacity(0.5),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Erreur image ${index + 1}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.error.withOpacity(0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
              // Overlay pour l'interaction
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.3),
                    ],
                  ),
                ),
              ),
              // Icône GPS si disponible
              if (tronconImage.latitude != null && tronconImage.longitude != null)
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              // Icône d'agrandissement
              const Positioned(
                top: 8,
                right: 8,
                child: Icon(
                  Icons.zoom_in_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImageViewerPage extends StatefulWidget {
  final List<TronconImage> images;
  final int initialIndex;

  const _ImageViewerPage({
    required this.images,
    required this.initialIndex,
  });

  @override
  State<_ImageViewerPage> createState() => _ImageViewerPageState();
}

class _ImageViewerPageState extends State<_ImageViewerPage> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('Photo ${_currentIndex + 1} sur ${widget.images.length}'),
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.images.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          final currentImage = widget.images[index];
          return Center(
            child: Container(
              margin: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(currentImage.path),
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.broken_image_rounded,
                                  size: 80,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Erreur - Image ${index + 1}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  currentImage.path,
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  // Informations GPS et carte si disponibles
                  if (currentImage.latitude != null && currentImage.longitude != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.location_on, color: Colors.green, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                'Coordonnées GPS',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Lat: ${currentImage.latitude!.toStringAsFixed(6)}°',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                          Text(
                            'Lng: ${currentImage.longitude!.toStringAsFixed(6)}°',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                          if (currentImage.altitude != null)
                            Text(
                              'Alt: ${currentImage.altitude!.toStringAsFixed(1)}m',
                              style: TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          const SizedBox(height: 12),
                          // Mini carte Google Maps avec bouton plein écran
                          _ImageLocationMap(
                            image: currentImage,
                            imageIndex: index,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Prise le ${DateFormat('dd/MM/yyyy à HH:mm').format(currentImage.datePrise)}',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// États de chargement, erreur et non trouvé

class _LoadingScaffold extends StatelessWidget {
  const _LoadingScaffold();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chargement...'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Chargement des détails du tronçon...'),
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
      appBar: AppBar(
        title: const Text('Erreur'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  size: 48,
                  color: AppTheme.errorColor,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Erreur lors du chargement',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.errorColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                error.toString(),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Réessayer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.errorColor,
                  foregroundColor: Colors.white,
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

  const _NotFoundScaffold({
    required this.onGoBack,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tronçon non trouvé'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.search_off_rounded,
                  size: 48,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Tronçon non trouvé',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Le tronçon demandé n\'existe pas ou a été supprimé.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: onGoBack,
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('Retour'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget pour afficher une mini carte avec la localisation d'une image
class _ImageLocationMap extends StatelessWidget {
  final TronconImage image;
  final int imageIndex;

  const _ImageLocationMap({
    required this.image,
    required this.imageIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white24),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  image.latitude!,
                  image.longitude!,
                ),
                zoom: 16.0,
              ),
              markers: {
                Marker(
                  markerId: MarkerId('image_location_$imageIndex'),
                  position: LatLng(
                    image.latitude!,
                    image.longitude!,
                  ),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueRed,
                  ),
                  infoWindow: InfoWindow(
                    title: 'Photo ${imageIndex + 1}',
                    snippet: 'Prise le ${DateFormat('dd/MM/yyyy HH:mm').format(image.datePrise)}',
                  ),
                ),
              },
              mapType: MapType.hybrid,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              scrollGesturesEnabled: true,
              zoomGesturesEnabled: true,
              rotateGesturesEnabled: false,
              tiltGesturesEnabled: false,
              onMapCreated: (GoogleMapController controller) {
                // Carte créée
              },
            ),
          ),
          // Bouton pour ouvrir en plein écran
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.fullscreen,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () => _openFullScreenMap(context),
                tooltip: 'Ouvrir en plein écran',
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openFullScreenMap(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _FullScreenImageMap(
          image: image,
          imageIndex: imageIndex,
        ),
      ),
    );
  }
}

// Page plein écran pour la carte d'une image
class _FullScreenImageMap extends StatelessWidget {
  final TronconImage image;
  final int imageIndex;

  const _FullScreenImageMap({
    required this.image,
    required this.imageIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('Localisation - Photo ${imageIndex + 1}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showLocationInfo(context),
          ),
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(
            image.latitude!,
            image.longitude!,
          ),
          zoom: 18.0,
        ),
        markers: {
          Marker(
            markerId: MarkerId('image_location_fullscreen_$imageIndex'),
            position: LatLng(
              image.latitude!,
              image.longitude!,
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueRed,
            ),
            infoWindow: InfoWindow(
              title: 'Photo ${imageIndex + 1}',
              snippet: 'Prise le ${DateFormat('dd/MM/yyyy HH:mm').format(image.datePrise)}',
            ),
          ),
        },
        mapType: MapType.hybrid,
        myLocationButtonEnabled: true,
        zoomControlsEnabled: true,
        scrollGesturesEnabled: true,
        zoomGesturesEnabled: true,
        rotateGesturesEnabled: true,
        tiltGesturesEnabled: true,
        onMapCreated: (GoogleMapController controller) {
          // Carte plein écran créée
        },
      ),
    );
  }

  void _showLocationInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Informations de localisation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Photo ${imageIndex + 1}'),
            const SizedBox(height: 8),
            Text('Latitude: ${image.latitude!.toStringAsFixed(6)}°'),
            Text('Longitude: ${image.longitude!.toStringAsFixed(6)}°'),
            if (image.altitude != null)
              Text('Altitude: ${image.altitude!.toStringAsFixed(1)}m'),
            const SizedBox(height: 8),
            Text('Date: ${DateFormat('dd/MM/yyyy à HH:mm:ss').format(image.datePrise)}'),
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
