import 'package:flutter/material.dart';
import 'package:barber_osbao/packages/design_system/theme/theme_colors.dart';

class AppSidebarItem {
  final String id;
  final String title;
  final IconData icon;

  AppSidebarItem({
    required this.id,
    required this.title,
    required this.icon,
  });
}

class AppSidebar extends StatelessWidget {
  final String activeId;
  final List<AppSidebarItem> items;
  final ValueChanged<String> onSelected;
  final VoidCallback? onLogout;

  const AppSidebar({
    super.key,
    required this.activeId,
    required this.items,
    required this.onSelected,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: isDark ? ThemeColors.darkSurface : Colors.white,
        border: Border(
          right: BorderSide(
            color: isDark ? ThemeColors.darkBorder : Colors.grey.shade200,
            width: 1.5,
          ),
        ),
      ),
      child: Column(
        children: [
          // Logo & Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: ThemeColors.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.content_cut,
                    color: ThemeColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'OSBÃO',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        color: ThemeColors.primary,
                      ),
                    ),
                    Text(
                      'BARBEARIA',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 3,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),
          const SizedBox(height: 20),

          // Menu Items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final isActive = item.id == activeId;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: InkWell(
                    onTap: () => onSelected(item.id),
                    borderRadius: BorderRadius.circular(12),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: isActive
                            ? ThemeColors.primary.withOpacity(isDark ? 0.15 : 0.08)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: isActive
                            ? Border.all(color: ThemeColors.primary.withOpacity(0.3), width: 1)
                            : Border.all(color: Colors.transparent, width: 1),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            item.icon,
                            color: isActive ? ThemeColors.primary : (isDark ? Colors.white60 : Colors.black54),
                            size: 20,
                          ),
                          const SizedBox(width: 16),
                          Text(
                            item.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                              color: isActive ? ThemeColors.primary : (isDark ? Colors.white70 : Colors.black87),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Logout button
          if (onLogout != null) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: InkWell(
                onTap: onLogout,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.logout,
                        color: ThemeColors.danger,
                        size: 20,
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Sair da Conta',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: ThemeColors.danger.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
