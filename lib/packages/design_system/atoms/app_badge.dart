import 'package:flutter/material.dart';
import 'package:barber_osbao/packages/design_system/theme/theme_colors.dart';

enum AppBadgeVariant { primary, success, warning, danger, neutral }

class AppBadge extends StatelessWidget {
  final String label;
  final AppBadgeVariant variant;

  const AppBadge({
    super.key,
    required this.label,
    this.variant = AppBadgeVariant.neutral,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color bg;
    Color fg;

    switch (variant) {
      case AppBadgeVariant.primary:
        bg = ThemeColors.primary.withOpacity(0.12);
        fg = ThemeColors.primary;
        break;
      case AppBadgeVariant.success:
        bg = ThemeColors.success.withOpacity(0.12);
        fg = ThemeColors.success;
        break;
      case AppBadgeVariant.warning:
        bg = ThemeColors.warning.withOpacity(0.12);
        fg = ThemeColors.warning;
        break;
      case AppBadgeVariant.danger:
        bg = ThemeColors.danger.withOpacity(0.12);
        fg = ThemeColors.danger;
        break;
      case AppBadgeVariant.neutral:
      default:
        bg = isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05);
        fg = isDark ? Colors.white70 : Colors.black54;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
