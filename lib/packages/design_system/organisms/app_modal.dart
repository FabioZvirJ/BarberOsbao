import 'package:flutter/material.dart';
import 'package:barber_osbao/packages/design_system/theme/theme_colors.dart';

class AppModal extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? footer;
  final bool isDialog;

  const AppModal({
    super.key,
    required this.title,
    required this.child,
    this.footer,
    this.isDialog = false,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required Widget child,
    Widget? footer,
  }) {
    // If the screen width is larger than 650, we display a centered Dialog.
    // Otherwise, we keep the bottom sheet layout.
    final isLargeScreen = MediaQuery.of(context).size.width > 650;

    if (isLargeScreen) {
      return showDialog<T>(
        context: context,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          elevation: 24,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 550,
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            child: AppModal(
              title: title,
              footer: footer,
              isDialog: true,
              child: child,
            ),
          ),
        ),
      );
    } else {
      return showModalBottomSheet<T>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => AppModal(
          title: title,
          footer: footer,
          isDialog: false,
          child: child,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? ThemeColors.darkSurface : Colors.white,
        borderRadius: isDialog
            ? BorderRadius.circular(ThemeColors.radius)
            : const BorderRadius.only(
                topLeft: Radius.circular(ThemeColors.radius),
                topRight: Radius.circular(ThemeColors.radius),
              ),
      ),
      padding: EdgeInsets.only(
        bottom: isDialog ? 0 : MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle - Only show for bottom sheet
          if (!isDialog)
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            )
          else
            const SizedBox(height: 12),
          
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          // Child content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: child,
            ),
          ),
          
          if (footer != null) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(24),
              child: footer!,
            ),
          ],
        ],
      ),
    );
  }
}
