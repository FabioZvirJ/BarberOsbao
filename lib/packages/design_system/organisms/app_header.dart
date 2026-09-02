import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:barber_osbao/packages/design_system/atoms/app_avatar.dart';
import 'package:barber_osbao/packages/design_system/theme/theme_colors.dart';
import 'package:barber_osbao/packages/core/auth/application/auth_controller.dart';

class AppHeader extends ConsumerWidget {
  final String userName;
  final String userAvatarUrl;
  final String barberName;
  final ValueChanged<String>? onSearch;
  final VoidCallback? onProfileTap;

  const AppHeader({
    super.key,
    required this.userName,
    required this.userAvatarUrl,
    this.barberName = 'Barbearia Osbao',
    this.onSearch,
    this.onProfileTap,
  });

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'Bom dia';
    } else if (hour >= 12 && hour < 18) {
      return 'Boa tarde';
    } else {
      return 'Boa noite';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 32,
        vertical: isMobile ? 12 : 16,
      ),
      decoration: BoxDecoration(
        color: isDark ? ThemeColors.darkBackground : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? ThemeColors.darkBorder : Colors.grey.shade200,
            width: 1.0,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Greeting & Barber name
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    '${getGreeting()}, ',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),
                  Text(
                    userName,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: ThemeColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                barberName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
            ],
          ),

          // Right side actions
          Row(
            children: [
              if (onSearch != null) ...[
                SizedBox(
                  width: 240,
                  height: 38,
                  child: TextField(
                    onChanged: onSearch,
                    decoration: InputDecoration(
                      hintText: 'Pesquisar...',
                      hintStyle: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white38 : Colors.grey.shade500,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        size: 18,
                        color: Colors.grey,
                      ),
                      filled: true,
                      fillColor: isDark
                          ? ThemeColors.darkSurface
                          : Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
              ],

              // Profile Avatar Menu
              PopupMenuButton<String>(
                offset: const Offset(0, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: isDark
                        ? ThemeColors.darkBorder
                        : Colors.grey.shade200,
                  ),
                ),
                color: isDark ? ThemeColors.darkSurface : Colors.white,
                tooltip: 'Menu de Usuário',
                onSelected: (value) {
                  if (value == 'theme') {
                    ref.read(authControllerProvider.notifier).toggleTheme();
                  } else if (value == 'settings') {
                    if (onProfileTap != null) {
                      onProfileTap!();
                    } else {
                      context.go('/configuracoes');
                    }
                  } else if (value == 'logout') {
                    ref.read(authControllerProvider.notifier).logout();
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    enabled: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          barberName,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                        const Divider(),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'theme',
                    child: Row(
                      children: [
                        Icon(
                          isDark
                              ? Icons.light_mode_outlined
                              : Icons.dark_mode_outlined,
                          size: 18,
                          color: isDark
                              ? ThemeColors.primary
                              : Colors.grey.shade800,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          isDark ? 'Tema Claro' : 'Tema Escuro',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'settings',
                    child: Row(
                      children: [
                        Icon(
                          Icons.settings_outlined,
                          size: 18,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Configurações',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'logout',
                    child: const Row(
                      children: [
                        Icon(Icons.logout, size: 18, color: ThemeColors.danger),
                        SizedBox(width: 10),
                        Text(
                          'Sair da Conta',
                          style: TextStyle(
                            fontSize: 13,
                            color: ThemeColors.danger,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Row(
                    children: [
                      AppAvatar(url: userAvatarUrl, size: 38),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.keyboard_arrow_down,
                        size: 18,
                        color: isDark ? Colors.grey : Colors.grey.shade600,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
