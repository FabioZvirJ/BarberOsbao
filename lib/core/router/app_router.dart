import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/appointments/presentation/pages/appointments_page.dart';
import '../../features/customers/presentation/pages/customers_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/plans/presentation/pages/plans_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../design_system/layouts/app_scaffold.dart';
import '../../design_system/organisms/app_sidebar.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        // Find active sidebar ID from route location
        final location = state.uri.path;
        String activeId = 'dashboard';
        if (location.startsWith('/appointments')) {
          activeId = 'appointments';
        } else if (location.startsWith('/customers')) {
          activeId = 'customers';
        } else if (location.startsWith('/profile')) {
          activeId = 'profile';
        } else if (location.startsWith('/plans')) {
          activeId = 'plans';
        } else if (location.startsWith('/settings')) {
          activeId = 'settings';
        }

        return AppScaffold(
          activeSidebarId: activeId,
          sidebarItems: [
            AppSidebarItem(id: 'dashboard', title: 'Início', icon: Icons.dashboard_outlined),
            AppSidebarItem(id: 'appointments', title: 'Agendamentos', icon: Icons.calendar_today_outlined),
            AppSidebarItem(id: 'customers', title: 'Clientes', icon: Icons.people_outline),
            AppSidebarItem(id: 'plans', title: 'Planos & Clube', icon: Icons.star_outline),
            AppSidebarItem(id: 'profile', title: 'Meu Perfil', icon: Icons.person_outlined),
            AppSidebarItem(id: 'settings', title: 'Configurações', icon: Icons.settings_outlined),
          ],
          onSidebarSelected: (id) {
            switch (id) {
              case 'dashboard':
                context.go('/');
                break;
              case 'appointments':
                context.go('/appointments');
                break;
              case 'customers':
                context.go('/customers');
                break;
              case 'plans':
                context.go('/plans');
                break;
              case 'profile':
                context.go('/profile');
                break;
              case 'settings':
                context.go('/settings');
                break;
            }
          },
          onLogout: () {
            // Logout handle
          },
          body: child,
        );
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const DashboardPage(),
        ),
        GoRoute(
          path: '/appointments',
          builder: (context, state) => const AppointmentsPage(),
        ),
        GoRoute(
          path: '/customers',
          builder: (context, state) => const CustomersPage(),
        ),
        GoRoute(
          path: '/plans',
          builder: (context, state) => const PlansPage(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfilePage(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsPage(),
        ),
      ],
    ),
  ],
);
