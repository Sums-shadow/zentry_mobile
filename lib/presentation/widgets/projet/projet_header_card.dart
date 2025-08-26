import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/projet.dart';
import '../common/status_badge.dart';

class ProjetHeaderCard extends StatelessWidget {
  final Projet projet;

  const ProjetHeaderCard({
    super.key,
    required this.projet,
  });

  @override
  Widget build(BuildContext context) {
    // Pour l'instant, utilisons un statut par défaut
    const String status = 'actif';
    final statusColor = StatusColors.forStatus(status);

    return Card(
      margin: const EdgeInsets.all(0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppTheme.spacingL),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          gradient: LinearGradient(
            colors: [
              statusColor,
              statusColor.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        projet.nom,
                        style: AppTheme.headlineSmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (projet.description?.isNotEmpty == true) ...[
                        const SizedBox(height: AppTheme.spacingS),
                        Text(
                          projet.description!,
                          style: AppTheme.bodyMedium.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: AppTheme.spacingM),
                StatusBadgeWhite(status: status),
              ],
            ),
            const SizedBox(height: AppTheme.spacingL),
            _buildInfoChips(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChips() {
    return Wrap(
      spacing: AppTheme.spacingS,
      runSpacing: AppTheme.spacingS,
      children: [
        _buildInfoChip(
          icon: Icons.location_on_outlined,
          label: projet.province,
        ),
        _buildInfoChip(
          icon: Icons.calendar_today_outlined,
          label: _formatDate(projet.date),
        ),
        if (projet.agent?.isNotEmpty == true)
          _buildInfoChip(
            icon: Icons.person_outlined,
            label: projet.agent!,
          ),
        if (projet.troncon?.isNotEmpty == true) ...[
          const SizedBox(height: 8),
          Text(
            projet.troncon!,
            style: AppTheme.bodyMedium.copyWith(
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingM,
        vertical: AppTheme.spacingS,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: AppTheme.iconS,
            color: Colors.white,
          ),
          const SizedBox(width: AppTheme.spacingS),
          Text(
            label,
            style: AppTheme.bodySmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jun',
      'Jul', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc'
    ];
    
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
} 