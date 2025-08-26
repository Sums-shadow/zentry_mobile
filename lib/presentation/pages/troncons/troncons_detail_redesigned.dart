import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../domain/entities/troncon.dart';
import '../../providers/troncon_provider.dart';
import '../../widgets/common/status_badge.dart';

// Énumération pour le statut du tronçon
enum TronconStatus { excellent, good, fair, poor }

// Calculateur de statut du tronçon
class TronconStatusCalculator {
  static TronconStatus calculate(Troncon troncon) {
    int issues = 0;
    
    // Compter les problèmes identifiés
    if (troncon.presenceNidsPoules) issues++;
    if (troncon.zonesErosion) issues++;
    if (troncon.zonesEauStagnante) issues++;
    if (troncon.bourbiers) issues++;
    if (troncon.deformations) issues++;
    if (troncon.busesFonctionnelles == false) issues++;
    if (troncon.drainageSuffisant == false) issues++;
    if (troncon.signalisationVerticale == false) issues++;
    if (troncon.signalisationHorizontale == false) issues++;
    
    // Déterminer le statut basé sur le nombre de problèmes
    if (issues == 0) return TronconStatus.excellent;
    if (issues <= 2) return TronconStatus.good;
    if (issues <= 4) return TronconStatus.fair;
    return TronconStatus.poor;
  }
}

class TronconDetailRedesignedPage extends ConsumerWidget {
  final String tronconId;

  const TronconDetailRedesignedPage({
    super.key,
    required this.tronconId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tronconAsyncValue = ref.watch(tronconByIdProvider(int.parse(tronconId)));

    return tronconAsyncValue.when(
      loading: () => const _LoadingScaffold(),
      error: (error, stackTrace) => _ErrorScaffold(
        error: error,
        onRetry: () => ref.refresh(tronconByIdProvider(int.parse(tronconId))),
      ),
      data: (troncon) {
        if (troncon == null) {
          return _NotFoundScaffold(
            onGoBack: () => context.pop(),
          );
        }
        return _TronconDetailContent(
          troncon: troncon,
          tronconId: tronconId,
          ref: ref,
        );
      },
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
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = TronconStatusCalculator.calculate(widget.troncon);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          _buildSliverAppBar(theme, status, innerBoxIsScrolled),
        ],
        body: SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(theme, status),
                _buildConditionsTab(theme),
                _buildInfrastructureTab(theme),
                _buildMediaTab(theme),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(theme),
    );
  }

  Widget _buildSliverAppBar(ThemeData theme, TronconStatus status, bool innerBoxIsScrolled) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      stretch: true,
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground, StretchMode.blurBackground],
        title: AnimatedOpacity(
          opacity: innerBoxIsScrolled ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: Text(
            'PK ${widget.troncon.pkDebut} → ${widget.troncon.pkFin}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        background: _buildHeaderBackground(theme, status),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: Container(
          color: theme.colorScheme.primary,
          child: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            tabs: const [
              Tab(icon: Icon(Icons.info_outline, size: 20), text: 'Aperçu'),
              Tab(icon: Icon(Icons.construction, size: 20), text: 'État'),
              Tab(icon: Icon(Icons.engineering_outlined, size: 20), text: 'Infrastructure'),
              Tab(icon: Icon(Icons.photo_library_outlined, size: 20), text: 'Médias'),
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => _showEditDialog(context),
          icon: const Icon(Icons.edit_outlined),
          tooltip: 'Modifier',
        ),
        PopupMenuButton<String>(
          onSelected: (value) => _handleMenuAction(context, value),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'sync',
              child: ListTile(
                leading: Icon(Icons.sync, size: 20),
                title: Text('Synchroniser'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'export',
              child: ListTile(
                leading: Icon(Icons.download_outlined, size: 20),
                title: Text('Exporter'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete_outline, color: Colors.red, size: 20),
                title: Text('Supprimer', style: TextStyle(color: Colors.red)),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeaderBackground(ThemeData theme, TronconStatus status) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withOpacity(0.8),
            theme.colorScheme.secondary.withOpacity(0.6),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Titre principal
              Text(
                'Tronçon ${widget.troncon.pkDebut} → ${widget.troncon.pkFin}',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              
              // Badge de statut
              Row(
                children: [
                  _buildModernStatusBadge(status, theme),
                  const SizedBox(width: 12),
                  if (widget.troncon.sync)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.withOpacity(0.5)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.cloud_done, color: Colors.green[300], size: 14),
                          const SizedBox(width: 4),
                          Text(
                            'Synchronisé',
                            style: TextStyle(
                              color: Colors.green[300],
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Informations rapides
              Row(
                children: [
                  _buildQuickInfo(
                    Icons.straighten,
                    '${widget.troncon.distance?.toStringAsFixed(1) ?? "N/A"} km',
                    'Distance',
                  ),
                  const SizedBox(width: 24),
                  _buildQuickInfo(
                    Icons.photo_camera,
                    '${widget.troncon.images.length}',
                    'Photos',
                  ),
                  const SizedBox(width: 24),
                  _buildQuickInfo(
                    Icons.calendar_today,
                    DateFormat('dd/MM/yy').format(widget.troncon.dateCreation),
                    'Créé le',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickInfo(IconData icon, String value, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildModernStatusBadge(TronconStatus status, ThemeData theme) {
    Color color;
    String label;
    IconData icon;
    
    switch (status) {
      case TronconStatus.excellent:
        color = Colors.green;
        label = 'Excellent';
        icon = Icons.check_circle;
        break;
      case TronconStatus.good:
        color = Colors.blue;
        label = 'Bon';
        icon = Icons.thumb_up;
        break;
      case TronconStatus.fair:
        color = Colors.orange;
        label = 'Moyen';
        icon = Icons.warning;
        break;
      case TronconStatus.poor:
        color = Colors.red;
        label = 'Mauvais';
        icon = Icons.error;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color.withOpacity(0.9), size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color.withOpacity(0.9),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // Onglet Aperçu
  Widget _buildOverviewTab(ThemeData theme, TronconStatus status) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildModernCard(
            theme: theme,
            title: 'Informations générales',
            icon: Icons.info_outline,
            child: _buildGeneralInfoContent(theme),
          ),
          const SizedBox(height: 16),
          _buildModernCard(
            theme: theme,
            title: 'Localisation',
            icon: Icons.location_on_outlined,
            child: _buildLocationContent(theme),
          ),
          const SizedBox(height: 16),
          _buildModernCard(
            theme: theme,
            title: 'Résumé des conditions',
            icon: Icons.assessment_outlined,
            child: _buildConditionsSummary(theme, status),
          ),
        ],
      ),
    );
  }

  // Onglet État des routes
  Widget _buildConditionsTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildModernCard(
            theme: theme,
            title: 'État de la chaussée',
            icon: Icons.construction,
            child: _buildRoadConditionContent(theme),
          ),
          const SizedBox(height: 16),
          _buildModernCard(
            theme: theme,
            title: 'Dégradations observées',
            icon: Icons.warning_outlined,
            child: _buildDegradationsContent(theme),
          ),
          const SizedBox(height: 16),
          _buildModernCard(
            theme: theme,
            title: 'Recommandations',
            icon: Icons.build_outlined,
            child: _buildRecommendationsContent(theme),
          ),
        ],
      ),
    );
  }

  // Onglet Infrastructure
  Widget _buildInfrastructureTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildModernCard(
            theme: theme,
            title: 'Ouvrages d\'art',
            icon: Icons.engineering_outlined,
            child: _buildInfrastructureContent(theme),
          ),
          const SizedBox(height: 16),
          _buildModernCard(
            theme: theme,
            title: 'Sécurité routière',
            icon: Icons.security_outlined,
            child: _buildSafetyContent(theme),
          ),
          const SizedBox(height: 16),
          _buildModernCard(
            theme: theme,
            title: 'Environnement',
            icon: Icons.nature_outlined,
            child: _buildEnvironmentContent(theme),
          ),
        ],
      ),
    );
  }

  // Onglet Médias
  Widget _buildMediaTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildModernCard(
            theme: theme,
            title: 'Galerie photos (${widget.troncon.images.length})',
            icon: Icons.photo_library_outlined,
            child: widget.troncon.images.isEmpty
                ? _buildEmptyMediaState(theme)
                : _buildImageGallery(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildModernCard({
    required ThemeData theme,
    required String title,
    required IconData icon,
    required Widget child,
    Color? headerColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header de la carte
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: headerColor ?? theme.colorScheme.primary.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
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
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Contenu de la carte
          Padding(
            padding: const EdgeInsets.all(20),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralInfoContent(ThemeData theme) {
    return Column(
      children: [
        _buildInfoRow(
          icon: Icons.straighten,
          label: 'Longueur',
          value: '${widget.troncon.longueurTroncon?.toStringAsFixed(1) ?? "N/A"} km',
          theme: theme,
        ),
        const SizedBox(height: 12),
        _buildInfoRow(
          icon: Icons.width_wide,
          label: 'Largeur emprise',
          value: '${widget.troncon.largeurEmprise?.toStringAsFixed(1) ?? "N/A"} m',
          theme: theme,
        ),
        const SizedBox(height: 12),
        _buildInfoRow(
          icon: Icons.category,
          label: 'Classe de route',
          value: widget.troncon.classeRoute ?? 'Non spécifiée',
          theme: theme,
        ),
        const SizedBox(height: 12),
        _buildInfoRow(
          icon: Icons.terrain,
          label: 'Profil topographique',
          value: widget.troncon.profilTopographique ?? 'Non spécifié',
          theme: theme,
        ),
        const SizedBox(height: 12),
        _buildInfoRow(
          icon: Icons.cloud,
          label: 'Conditions climatiques',
          value: widget.troncon.conditionsClimatiques ?? 'Non spécifiées',
          theme: theme,
        ),
      ],
    );
  }

  Widget _buildLocationContent(ThemeData theme) {
    return Column(
      children: [
        if (widget.troncon.latitude != null && widget.troncon.longitude != null) ...[
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(widget.troncon.latitude!, widget.troncon.longitude!),
                  zoom: 15.0,
                ),
                markers: {
                  Marker(
                    markerId: const MarkerId('troncon_location'),
                    position: LatLng(widget.troncon.latitude!, widget.troncon.longitude!),
                    infoWindow: InfoWindow(
                      title: 'Tronçon ${widget.troncon.pkDebut} → ${widget.troncon.pkFin}',
                      snippet: 'Position GPS du tronçon',
                    ),
                  ),
                },
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        _buildInfoRow(
          icon: Icons.gps_fixed,
          label: 'Coordonnées',
          value: widget.troncon.latitude != null && widget.troncon.longitude != null
              ? '${widget.troncon.latitude!.toStringAsFixed(6)}, ${widget.troncon.longitude!.toStringAsFixed(6)}'
              : 'Non disponibles',
          theme: theme,
        ),
        if (widget.troncon.altitude != null) ...[
          const SizedBox(height: 12),
          _buildInfoRow(
            icon: Icons.height,
            label: 'Altitude',
            value: '${widget.troncon.altitude!.toStringAsFixed(1)} m',
            theme: theme,
          ),
        ],
      ],
    );
  }

  Widget _buildConditionsSummary(ThemeData theme, TronconStatus status) {
    final issues = <String>[];
    if (widget.troncon.presenceNidsPoules) issues.add('Nids de poules');
    if (widget.troncon.zonesErosion) issues.add('Zones d\'érosion');
    if (widget.troncon.zonesEauStagnante) issues.add('Eau stagnante');
    if (widget.troncon.bourbiers) issues.add('Bourbiers');
    if (widget.troncon.deformations) issues.add('Déformations');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildModernStatusBadge(status, theme),
            const Spacer(),
            Text(
              '${issues.length} problème(s) détecté(s)',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
        if (issues.isNotEmpty) ...[
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: issues.map((issue) => _buildIssueChip(issue, theme)).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildIssueChip(String issue, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warning, color: Colors.orange, size: 14),
          const SizedBox(width: 6),
          Text(
            issue,
            style: TextStyle(
              color: Colors.orange.shade700,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoadConditionContent(ThemeData theme) {
    return Column(
      children: [
        _buildInfoRow(
          icon: Icons.construction,
          label: 'Type de chaussée',
          value: widget.troncon.typeChaussee ?? 'Non spécifié',
          theme: theme,
        ),
        const SizedBox(height: 12),
        _buildInfoRow(
          icon: Icons.terrain,
          label: 'Type de sol',
          value: widget.troncon.typeSol ?? 'Non spécifié',
          theme: theme,
        ),
      ],
    );
  }

  Widget _buildDegradationsContent(ThemeData theme) {
    return Column(
      children: [
        _buildBooleanRow('Nids de poules', widget.troncon.presenceNidsPoules, theme),
        _buildBooleanRow('Zones d\'érosion', widget.troncon.zonesErosion, theme),
        _buildBooleanRow('Zones d\'eau stagnante', widget.troncon.zonesEauStagnante, theme),
        _buildBooleanRow('Bourbiers', widget.troncon.bourbiers, theme),
        _buildBooleanRow('Déformations', widget.troncon.deformations, theme),
      ],
    );
  }

  Widget _buildInfrastructureContent(ThemeData theme) {
    return Column(
      children: [
        _buildInfoRow(
          icon: Icons.engineering,
          label: 'État ponts/dalots',
          value: widget.troncon.etatPontsDalots ?? 'Non évalué',
          theme: theme,
        ),
        const SizedBox(height: 12),
        _buildBooleanRow('Buses fonctionnelles', widget.troncon.busesFonctionnelles, theme),
        _buildBooleanRow('Exutoires zones évac.', widget.troncon.exutoiresZonesEvac, theme),
        _buildBooleanRow('Zones érosion/dépôts', widget.troncon.zonesErosionDepots, theme),
        _buildBooleanRow('Drainage suffisant', widget.troncon.drainageSuffisant, theme),
      ],
    );
  }

  Widget _buildSafetyContent(ThemeData theme) {
    return Column(
      children: [
        _buildBooleanRow('Signalisation verticale', widget.troncon.signalisationVerticale, theme),
        _buildBooleanRow('Signalisation horizontale', widget.troncon.signalisationHorizontale, theme),
        _buildBooleanRow('Glissières de sécurité', widget.troncon.glissieresSecurite, theme),
        const SizedBox(height: 12),
        _buildInfoRow(
          icon: Icons.visibility,
          label: 'Visibilité',
          value: widget.troncon.visibilite ?? 'Non évaluée',
          theme: theme,
        ),
        const SizedBox(height: 12),
        _buildBooleanRow('Zones sensibles', widget.troncon.zonesSensibles, theme),
      ],
    );
  }

  Widget _buildEnvironmentContent(ThemeData theme) {
    return Column(
      children: [
        _buildInfoRow(
          icon: Icons.home,
          label: 'Nombre de villages',
          value: widget.troncon.nombreVillages?.toString() ?? 'Non spécifié',
          theme: theme,
        ),
        if (widget.troncon.occupationSol.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildTagSection('Occupation du sol', widget.troncon.occupationSol, theme),
        ],
        if (widget.troncon.equipementsSociaux.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildTagSection('Équipements sociaux', widget.troncon.equipementsSociaux, theme),
        ],
      ],
    );
  }

  Widget _buildRecommendationsContent(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.troncon.interventionsSuggerees.isNotEmpty) ...[
          _buildTagSection('Interventions suggérées', widget.troncon.interventionsSuggerees, theme),
          const SizedBox(height: 16),
        ],
        if (widget.troncon.observationsGenerales != null && widget.troncon.observationsGenerales!.isNotEmpty) ...[
          Text(
            'Observations générales',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.colorScheme.primary.withOpacity(0.2),
              ),
            ),
            child: Text(
              widget.troncon.observationsGenerales!,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildImageGallery(ThemeData theme) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: widget.troncon.images.length,
      itemBuilder: (context, index) {
        return _buildImageTile(widget.troncon.images[index], index, theme);
      },
    );
  }

  Widget _buildImageTile(TronconImage image, int index, ThemeData theme) {
    return GestureDetector(
      onTap: () => _showImageViewer(context, widget.troncon.images, index),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.file(
                File(image.path),
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
                          'Image ${index + 1}',
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
              // Overlay avec informations
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                  child: Row(
                    children: [
                      if (image.latitude != null && image.longitude != null)
                        const Icon(
                          Icons.location_on,
                          color: Colors.white,
                          size: 16,
                        ),
                      const Spacer(),
                      Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
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
    );
  }

  Widget _buildEmptyMediaState(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.photo_library_outlined,
            size: 64,
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune photo disponible',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Les photos prises lors de l\'inspection apparaîtront ici',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required ThemeData theme,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 16,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBooleanRow(String label, bool? value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            value == true ? Icons.check_circle : 
            value == false ? Icons.cancel : Icons.help_outline,
            color: value == true ? Colors.green : 
                   value == false ? Colors.red : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value == true ? 'Oui' : 
            value == false ? 'Non' : 'N/A',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagSection(String title, List<String> items, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items.map((item) => _buildTag(item, theme)).toList(),
        ),
      ],
    );
  }

  Widget _buildTag(String text, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: Text(
        text,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton(ThemeData theme) {
    return FloatingActionButton.extended(
      onPressed: () => _showEditDialog(context),
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: theme.colorScheme.onPrimary,
      icon: const Icon(Icons.edit),
      label: const Text('Modifier'),
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

  void _showEditDialog(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fonctionnalité de modification en cours de développement'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'sync':
        _showSyncDialog(context);
        break;
      case 'export':
        _showExportDialog(context);
        break;
      case 'delete':
        _showDeleteConfirmDialog(context);
        break;
    }
  }

  void _showSyncDialog(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Synchronisation en cours de développement'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showExportDialog(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Export en cours de développement'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le tronçon'),
        content: const Text(
          'Êtes-vous sûr de vouloir supprimer ce tronçon ? Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}

// Widgets d'état (Loading, Error, NotFound) - réutilisés de l'original
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
              'Chargement des détails du tronçon...',
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
                'Tronçon introuvable',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Le tronçon demandé n\'existe pas ou a été supprimé.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onGoBack,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Retour'),
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

// Widget ImageViewer réutilisé de l'original avec les cartes
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