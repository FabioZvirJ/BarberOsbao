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
        style: TextStyle(
          color: isDark ? Colors.white70 : Colors.black87,
          fontSize: 15,
        ),
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

/// Modal/Diálogo responsivo, moderno e espaçoso para formulários e detalhes.
/// Garante que o conteúdo não fique espremido em telas grandes (Desktop/Web)
/// e se adapte fluidamente em telas móveis (Mobile).
class AppResponsiveDialog extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final List<Widget>? actions;
  final double maxWidth;
  final double? maxHeight;
  final EdgeInsetsGeometry? contentPadding;

  const AppResponsiveDialog({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
    this.actions,
    this.maxWidth = 620.0,
    this.maxHeight,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 680;

    return Dialog(
      backgroundColor: isDark ? ThemeColors.darkSurface : Colors.white,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isDark ? ThemeColors.darkBorder : Colors.grey.shade200,
          width: 1,
        ),
      ),
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 32,
        vertical: 24,
      ),
      clipBehavior: Clip.antiAlias,
      child: Container(
        width: isMobile ? double.infinity : maxWidth,
        constraints: BoxConstraints(
          maxWidth: maxWidth,
          maxHeight: maxHeight ?? MediaQuery.of(context).size.height * 0.88,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header elegante com título, subtítulo opcional e botão Fechar (X)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            subtitle!,
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? Colors.white60 : Colors.black54,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      size: 20,
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: 'Fechar',
                    splashRadius: 20,
                  ),
                ],
              ),
            ),
            Divider(
              height: 1,
              thickness: 1,
              color: isDark ? ThemeColors.darkBorder : Colors.grey.shade200,
            ),

            // Conteúdo interno com scroll e espaçamento generoso
            Flexible(
              child: SingleChildScrollView(
                padding: contentPadding ?? const EdgeInsets.all(24),
                child: child,
              ),
            ),

            // Rodapé com ações / botões
            if (actions != null && actions!.isNotEmpty) ...[
              Divider(
                height: 1,
                thickness: 1,
                color: isDark ? ThemeColors.darkBorder : Colors.grey.shade200,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: actions!,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
