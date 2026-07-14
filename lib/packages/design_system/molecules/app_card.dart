import 'package:flutter/material.dart';
import 'package:barber_osbao/packages/design_system/theme/theme_colors.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final bool borderGlow;
  final Color? borderColor;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24.0),
    this.onTap,
    this.borderGlow = false,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final decoration = BoxDecoration(
      color: isDark ? ThemeColors.darkSurface : Colors.white,
      borderRadius: BorderRadius.circular(ThemeColors.radius),
      border: Border.all(
        color: borderColor ?? (borderGlow 
            ? ThemeColors.primary.withValues(alpha: 0.5)
            : (isDark ? ThemeColors.darkBorder : Colors.grey.shade100)),
        width: 1.5,
      ),
      boxShadow: borderGlow ? ThemeColors.goldGlow : ThemeColors.softShadow,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: decoration,
            padding: padding,
            child: child,
          ),
        ),
      );
    }

    return Container(
      decoration: decoration,
      padding: padding,
      child: child,
    );
  }
}
