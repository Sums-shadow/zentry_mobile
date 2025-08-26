import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final double? fontSize;
  final EdgeInsetsGeometry? padding;
  final bool isLarge;

  const StatusBadge({
    super.key,
    required this.status,
    this.fontSize,
    this.padding,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = StatusColors.forStatus(status);
    final displayText = _formatStatusText(status);
    
    return Container(
      padding: padding ?? EdgeInsets.symmetric(
        horizontal: isLarge ? AppTheme.spacingM : AppTheme.spacingS + 4,
        vertical: isLarge ? AppTheme.spacingS : AppTheme.spacingXS + 2,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(
          isLarge ? AppTheme.radiusM : AppTheme.radiusS + 4,
        ),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: fontSize ?? (isLarge ? 14 : 12),
        ),
      ),
    );
  }

  String _formatStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'actif':
        return 'Actif';
      case 'en_cours':
        return 'En cours';
      case 'termine':
        return 'Terminé';
      case 'suspendu':
        return 'Suspendu';
      case 'bon_etat':
        return 'Bon état';
      case 'etat_moyen':
        return 'État moyen';
      case 'mauvais_etat':
        return 'Mauvais état';
      default:
        return status.replaceAll('_', ' ').toUpperCase();
    }
  }
}

class StatusBadgeWhite extends StatelessWidget {
  final String status;
  final double? fontSize;
  final EdgeInsetsGeometry? padding;

  const StatusBadgeWhite({
    super.key,
    required this.status,
    this.fontSize,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final displayText = _formatStatusText(status);
    
    return Container(
      padding: padding ?? const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingM,
        vertical: AppTheme.spacingS - 2,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(AppTheme.radiusXL),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize ?? 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'actif':
        return 'ACTIF';
      case 'en_cours':
        return 'EN COURS';
      case 'termine':
        return 'TERMINÉ';
      case 'suspendu':
        return 'SUSPENDU';
      default:
        return status.replaceAll('_', ' ').toUpperCase();
    }
  }
} 