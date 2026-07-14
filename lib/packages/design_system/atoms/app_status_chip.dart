import 'package:flutter/material.dart';
import 'package:barber_osbao/packages/design_system/theme/theme_colors.dart';

enum AppStatusType { success, warning, danger, info }

class AppStatusChip extends StatelessWidget {
  final String label;
  final AppStatusType type;

  const AppStatusChip({
    super.key,
    required this.label,
    required this.type,
  });

  Color _getColor() {
    switch (type) {
      case AppStatusType.success:
        return ThemeColors.success;
      case AppStatusType.warning:
        return ThemeColors.warning;
      case AppStatusType.danger:
        return ThemeColors.danger;
      case AppStatusType.info:
        return ThemeColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
