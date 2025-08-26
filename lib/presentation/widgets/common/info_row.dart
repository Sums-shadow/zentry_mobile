import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? iconColor;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;
  final CrossAxisAlignment crossAxisAlignment;
  final bool isVertical;

  const InfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
    this.labelStyle,
    this.valueStyle,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.isVertical = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isVertical) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: AppTheme.iconS,
                color: iconColor ?? AppTheme.textSecondary,
              ),
              const SizedBox(width: AppTheme.spacingS),
              Text(
                label,
                style: labelStyle ?? AppTheme.bodySmall.copyWith(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingXS),
          Padding(
            padding: const EdgeInsets.only(left: AppTheme.iconS + AppTheme.spacingS),
            child: Text(
              value,
              style: valueStyle ?? AppTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Icon(
          icon,
          size: AppTheme.iconM,
          color: iconColor ?? AppTheme.textSecondary,
        ),
        const SizedBox(width: AppTheme.spacingM),
        Text(
          '$label: ',
          style: labelStyle ?? AppTheme.bodyMedium.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: valueStyle ?? AppTheme.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: crossAxisAlignment == CrossAxisAlignment.start ? null : 1,
          ),
        ),
      ],
    );
  }
}

class InfoCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;
  final Widget? trailing;

  const InfoCard({
    super.key,
    required this.title,
    required this.children,
    this.padding,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: AppTheme.spacingS),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(AppTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: AppTheme.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
            if (children.isNotEmpty) ...[
              const SizedBox(height: AppTheme.spacingM),
              for (final child in children)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
                  child: child,
                ),
            ],
          ],
        ),
      ),
    );
  }
} 