import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_routes.dart';
import '../../../domain/entities/troncon.dart';
import '../../providers/troncon_provider.dart';
import '../common/status_badge.dart';

/// Widget principal pour afficher la liste des tronçons d'un projet
/// 
/// Fonctionnalités :
/// - Affichage de la liste des tronçons avec pagination
/// - États de chargement, erreur et vide
/// - Navigation vers les détails et création de nouveaux tronçons
/// - Design moderne et responsive
class TronconListWidget extends ConsumerWidget {
  final int projetId;
  final String projetNom;
  final int? maxItems;
  final bool showViewAllButton;
  final EdgeInsetsGeometry? padding;

  const TronconListWidget({
    super.key,
    required this.projetId,
    required this.projetNom,
    this.maxItems,
    this.showViewAllButton = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tronconsAsyncValue = ref.watch(tronconsByProjetProvider(projetId));

    return _TronconContainer(
      title: 'Tronçons',
      trailing: showViewAllButton ? _TronconActions(
        onViewAll: () => _navigateToTroncons(context),
        onAdd: () => _navigateToNewTroncon(context),
      ) : null,
      padding: padding,
      child: tronconsAsyncValue.when(
        loading: () => const _TronconLoadingState(),
        error: (error, stackTrace) => _TronconErrorState(
          error: error,
          onRetry: () => ref.refresh(tronconsByProjetProvider(projetId)),
        ),
        data: (troncons) => _TronconDataState(
          troncons: troncons,
          maxItems: maxItems,
          projetId: projetId,
          projetNom: projetNom,
          onNavigateToList: () => _navigateToTroncons(context),
          onNavigateToNew: () => _navigateToNewTroncon(context),
          onNavigateToDetail: (troncon) => _navigateToTronconDetail(context, troncon),
        ),
      ),
    );
  }

  void _navigateToTroncons(BuildContext context) {
    context.push('/projets/$projetId/troncons', extra: {
      'projetNom': projetNom,
    });
  }

  void _navigateToNewTroncon(BuildContext context) {
    context.go('${AppRoutes.newTroncon}/$projetId');
  }

  void _navigateToTronconDetail(BuildContext context, Troncon troncon) {
    context.push('/troncons/${troncon.id}/detail');
  }
}

/// Container principal avec header et contenu
class _TronconContainer extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const _TronconContainer({
    required this.title,
    required this.child,
    this.trailing,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppTheme.spacingS),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TronconHeader(title: title, trailing: trailing),
          Padding(
            padding: padding ?? const EdgeInsets.fromLTRB(
              AppTheme.spacingL,
              0,
              AppTheme.spacingL,
              AppTheme.spacingL,
            ),
            child: child,
          ),
        ],
      ),
    );
  }
}

/// Header avec titre et actions
class _TronconHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const _TronconHeader({
    required this.title,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppTheme.radiusL),
          topRight: Radius.circular(AppTheme.radiusL),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.alt_route_rounded,
            color: Theme.of(context).colorScheme.primary,
            size: AppTheme.iconM,
          ),
          const SizedBox(width: AppTheme.spacingM),
          Expanded(
            child: Text(
              title,
              style: AppTheme.titleLarge.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Actions du header (Voir tout + Ajouter)
class _TronconActions extends StatelessWidget {
  final VoidCallback onViewAll;
  final VoidCallback onAdd;

  const _TronconActions({
    required this.onViewAll,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ActionButton(
          onPressed: onViewAll,
          icon: Icons.visibility_outlined,
          label: '',
          isPrimary: false,
        ),
        const SizedBox(width: AppTheme.spacingS),
        _ActionButton(
          onPressed: onAdd,
          icon: Icons.add_rounded,
          tooltip: 'Ajouter un tronçon',
          isPrimary: true,
        ),
      ],
    );
  }
}

/// Bouton d'action réutilisable
class _ActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String? label;
  final String? tooltip;
  final bool isPrimary;

  const _ActionButton({
    required this.onPressed,
    required this.icon,
    this.label,
    this.tooltip,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (label != null) {
      return TextButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: AppTheme.iconS),
        label: Text(label!),
        style: TextButton.styleFrom(
          foregroundColor: theme.colorScheme.primary,
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingM,
            vertical: AppTheme.spacingS,
          ),
        ),
      );
    }

    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon),
      tooltip: tooltip,
      style: IconButton.styleFrom(
        backgroundColor: isPrimary 
            ? theme.colorScheme.primary.withValues(alpha: 0.1)
            : theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusS),
          side: isPrimary ? BorderSide.none : BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
    );
  }
}

/// État de chargement
class _TronconLoadingState extends StatelessWidget {
  const _TronconLoadingState();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            strokeWidth: 3,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: AppTheme.spacingL),
          Text(
            'Chargement des tronçons...',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// État d'erreur avec possibilité de retry
class _TronconErrorState extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;

  const _TronconErrorState({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingL),
            decoration: BoxDecoration(
              color: AppTheme.errorColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusXL),
            ),
            child: Icon(
              Icons.error_outline_rounded,
              size: AppTheme.iconL,
              color: AppTheme.errorColor,
            ),
          ),
          const SizedBox(height: AppTheme.spacingL),
          Text(
            'Erreur lors du chargement',
            style: AppTheme.titleMedium.copyWith(
              color: AppTheme.errorColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            error.toString().length > 100 
                ? '${error.toString().substring(0, 100)}...'
                : error.toString(),
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppTheme.spacingL),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Réessayer'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.errorColor,
              side: BorderSide(color: AppTheme.errorColor.withValues(alpha: 0.5)),
            ),
          ),
        ],
      ),
    );
  }
}

/// État avec données
class _TronconDataState extends StatelessWidget {
  final List<Troncon> troncons;
  final int? maxItems;
  final int projetId;
  final String projetNom;
  final VoidCallback onNavigateToList;
  final VoidCallback onNavigateToNew;
  final Function(Troncon) onNavigateToDetail;

  const _TronconDataState({
    required this.troncons,
    required this.maxItems,
    required this.projetId,
    required this.projetNom,
    required this.onNavigateToList,
    required this.onNavigateToNew,
    required this.onNavigateToDetail,
  });

  @override
  Widget build(BuildContext context) {
    if (troncons.isEmpty) {
      return _TronconEmptyState(
        projetId: projetId,
        projetNom: projetNom,
        onAddTroncon: onNavigateToNew,
      );
    }

    final displayTroncons = maxItems != null 
        ? troncons.take(maxItems!).toList()
        : troncons;

    final remainingCount = maxItems != null && troncons.length > maxItems!
        ? troncons.length - maxItems!
        : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Statistiques en en-tête
        // _TronconStats(troncons: troncons),
        const SizedBox(height: AppTheme.spacingL),
        
        // Liste des tronçons
        ...displayTroncons.asMap().entries.map((entry) {
          final index = entry.key;
          final troncon = entry.value;
          return Padding(
            padding: EdgeInsets.only(
              bottom: index < displayTroncons.length - 1 ? AppTheme.spacingM : 0,
            ),
            child: TronconCard(
              troncon: troncon,
              onTap: () => onNavigateToDetail(troncon),
            ),
          );
        }),
        
        // Bouton "Voir plus"
        if (remainingCount > 0) ...[
          const SizedBox(height: AppTheme.spacingL),
          _ViewMoreButton(
            count: remainingCount,
            onPressed: onNavigateToList,
          ),
        ],
      ],
    );
  }
}

/// Statistiques rapides des tronçons
class _TronconStats extends StatelessWidget {
  final List<Troncon> troncons;

  const _TronconStats({required this.troncons});

  @override
  Widget build(BuildContext context) {
    final stats = _calculateStats();
    
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          _StatItem(
            icon: Icons.straighten_rounded,
            label: 'Total',
            value: '${stats['total']}',
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: AppTheme.spacingL),
          _StatItem(
            icon: Icons.check_circle_outline_rounded,
            label: 'Bon état',
            value: '${stats['good']}',
            color: AppTheme.successColor,
          ),
          const SizedBox(width: AppTheme.spacingL),
          _StatItem(
            icon: Icons.warning_amber_rounded,
            label: 'À surveiller',
            value: '${stats['warning']}',
            color: AppTheme.warningColor,
          ),
        ],
      ),
    );
  }

  Map<String, int> _calculateStats() {
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
}

/// Item de statistique
class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, color: color, size: AppTheme.iconS),
          const SizedBox(width: AppTheme.spacingS),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: AppTheme.titleMedium.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  label,
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// État vide avec CTA
class _TronconEmptyState extends StatelessWidget {
  final int projetId;
  final String projetNom;
  final VoidCallback onAddTroncon;

  const _TronconEmptyState({
    required this.projetId,
    required this.projetNom,
    required this.onAddTroncon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingXL),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusXL),
            ),
            child: Icon(
              Icons.alt_route_rounded,
              size: AppTheme.iconXL + 16,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: AppTheme.spacingL),
          Text(
            'Aucun tronçon',
            style: AppTheme.titleLarge.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            'Commencez par ajouter votre premier tronçon\npour analyser l\'état de la route',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacingXL),
         ],
      ),
    );
  }
}

/// Bouton "Voir plus"
class _ViewMoreButton extends StatelessWidget {
  final int count;
  final VoidCallback onPressed;

  const _ViewMoreButton({
    required this.count,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.expand_more_rounded),
        label: Text('Voir les $count tronçons restants'),
        style: OutlinedButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.primary,
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingL,
            vertical: AppTheme.spacingM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
          ),
        ),
      ),
    );
  }
}

/// Carte de tronçon moderne et interactive
class TronconCard extends StatelessWidget {
  final Troncon troncon;
  final VoidCallback onTap;

  const TronconCard({
    super.key,
    required this.troncon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final status = TronconStatusCalculator.calculate(troncon);
    final theme = Theme.of(context);
    
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        child: Container(
          padding: const EdgeInsets.all(AppTheme.spacingL),
          child: Row(
            children: [
              _TronconAvatar(troncon: troncon, status: status),
              const SizedBox(width: AppTheme.spacingL),
              Expanded(
                child: _TronconInfo(troncon: troncon),
              ),
              const SizedBox(width: AppTheme.spacingM),
              
            ],
          ),
        ),
      ),
    );
  }
}

/// Avatar du tronçon avec indicateur de statut
class _TronconAvatar extends StatelessWidget {
  final Troncon troncon;
  final TronconStatus status;

  const _TronconAvatar({required this.troncon, required this.status});

  @override
  Widget build(BuildContext context) {
    // Si le tronçon n'est pas synchronisé, utiliser la couleur orange
    final Color color = !troncon.sync 
        ? Colors.orange 
        : StatusColors.forStatus(status.status);
    
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 2,
        ),
      ),
      child: Icon(
        Icons.alt_route_rounded,
        color: color,
        size: AppTheme.iconL,
      ),
    );
  }
}

/// Informations du tronçon
class _TronconInfo extends StatelessWidget {
  final Troncon troncon;

  const _TronconInfo({required this.troncon});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PK${troncon.pkDebut ?? "X"}+PK${troncon.pkFin ?? "X"}',
          style: AppTheme.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.surfaceColor
          ),
        ),
        const SizedBox(height: AppTheme.spacingXS),
        if (troncon.distance != null)
          _InfoChip(
            icon: Icons.straighten_rounded,
            text: '${troncon.distance!.toStringAsFixed(2)} km',
          ),
        if (troncon.typeChaussee?.isNotEmpty == true) ...[
          const SizedBox(height: AppTheme.spacingXS),
          _InfoChip(
            icon: Icons.layers_rounded,
            text: troncon.typeChaussee!,
          ),
        ],
      ],
    );
  }
}

/// Chip d'information
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoChip({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: AppTheme.iconS,
          color: AppTheme.textSecondary,
        ),
        const SizedBox(width: AppTheme.spacingXS),
        Flexible(
          child: Text(
            text,
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// Calculateur de statut de tronçon (logique extraite pour la réutilisation)
class TronconStatusCalculator {
  static TronconStatus calculate(Troncon troncon) {
    int problemes = 0;
    if (troncon.presenceNidsPoules) problemes++;
    if (troncon.zonesErosion) problemes++;
    if (troncon.zonesEauStagnante) problemes++;
    if (troncon.bourbiers) problemes++;
    if (troncon.deformations) problemes++;

    if (problemes == 0) {
      return TronconStatus('bon_etat', 'Bon état');
    } else if (problemes <= 2) {
      return TronconStatus('etat_moyen', 'État moyen');
    } else {
      return TronconStatus('mauvais_etat', 'Mauvais état');
    }
  }
}

/// Modèle de statut de tronçon
class TronconStatus {
  final String status;
  final String displayText;

  const TronconStatus(this.status, this.displayText);
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TronconStatus &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          displayText == other.displayText;

  @override
  int get hashCode => status.hashCode ^ displayText.hashCode;

  @override
  String toString() => 'TronconStatus(status: $status, displayText: $displayText)';
} 