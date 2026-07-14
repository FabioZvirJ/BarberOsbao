import 'package:flutter/material.dart';
import 'package:barber_osbao/packages/design_system/organisms/app_sidebar.dart';
import 'package:barber_osbao/packages/design_system/theme/theme_colors.dart';

class AppScaffold extends StatelessWidget {
  final Widget body;
  final String activeSidebarId;
  final List<AppSidebarItem> sidebarItems;
  final ValueChanged<String> onSidebarSelected;
  final VoidCallback? onLogout;
  final Widget? header;

  const AppScaffold({
    super.key,
    required this.body,
    required this.activeSidebarId,
    required this.sidebarItems,
    required this.onSidebarSelected,
    this.onLogout,
    this.header,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 960;

    final sidebar = AppSidebar(
      activeId: activeSidebarId,
      items: sidebarItems,
      onSelected: (id) {
        onSidebarSelected(id);
        if (!isDesktop) {
          Navigator.of(context).pop(); // Close drawer on mobile
        }
      },
      onLogout: onLogout,
    );

    return Scaffold(
      drawer: isDesktop ? null : Drawer(child: sidebar),
      body: SafeArea(
        child: Row(
          children: [
            if (isDesktop) sidebar,
            Expanded(
              child: Column(
                children: [
                  if (!isDesktop)
                    // Mobile AppBar
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark ? ThemeColors.darkBackground : Colors.white,
                        border: Border(
                          bottom: BorderSide(
                            color: isDark ? ThemeColors.darkBorder : Colors.grey.shade100,
                            width: 1.5,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Builder(
                            builder: (context) => IconButton(
                              icon: const Icon(Icons.menu, color: ThemeColors.primary),
                              onPressed: () => Scaffold.of(context).openDrawer(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'OSBÃO BARBEARIA',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: ThemeColors.primary,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ?header,
                  Expanded(
                    child: body,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
