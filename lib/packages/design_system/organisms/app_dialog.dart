import 'package:flutter/material.dart';
import 'package:barber_osbao/packages/design_system/theme/theme_colors.dart';
import 'package:barber_osbao/packages/design_system/atoms/app_button.dart';

class AppDialog extends StatelessWidget {
  final String title;
  final String content;
  final String confirmLabel;
  final VoidCallback onConfirm;
  final String cancelLabel;
  final VoidCallback? onCancel;

  const AppDialog({
    super.key,
    required this.title,
    required this.content,
    required this.confirmLabel,
    required this.onConfirm,
    this.cancelLabel = 'Cancelar',
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      backgroundColor: isDark ? ThemeColors.darkSurface : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeColors.radius),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
      ),
      content: Text(
        content,
        style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 15),
      ),
      actionsPadding: const EdgeInsets.all(16),
      actions: [
        AppButton(
          label: cancelLabel,
          variant: AppButtonVariant.outline,
          height: 40,
          onPressed: onCancel ?? () => Navigator.of(context).pop(),
        ),
        const SizedBox(width: 8),
        AppButton(
          label: confirmLabel,
          variant: AppButtonVariant.primary,
          height: 40,
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm();
          },
        ),
      ],
    );
  }
}
