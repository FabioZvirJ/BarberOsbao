import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:barber_osbao/packages/core/auth/application/auth_controller.dart';
import 'package:barber_osbao/apps/client/presentation/dashboard/pages/dashboard_page.dart';
import 'package:barber_osbao/apps/client/presentation/appointments/pages/appointments_page.dart';
import 'package:barber_osbao/apps/client/presentation/customers/pages/customers_page.dart';
import 'package:barber_osbao/apps/client/presentation/profile/pages/profile_page.dart';
import 'package:barber_osbao/apps/client/presentation/plans/pages/plans_page.dart';
import 'package:barber_osbao/apps/client/presentation/settings/pages/settings_page.dart';
import 'package:barber_osbao/packages/design_system/layouts/app_scaffold.dart';
import 'package:barber_osbao/packages/design_system/organisms/app_sidebar.dart';

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

        return Consumer(
          builder: (context, ref, _) {
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
                ref.read(authControllerProvider.notifier).logout();
              },
              body: child,
            );
          },
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
