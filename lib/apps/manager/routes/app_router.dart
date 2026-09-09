import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:barber_osbao/packages/core/auth/application/auth_controller.dart';
import 'package:barber_osbao/packages/design_system/layouts/app_scaffold.dart';
import 'package:barber_osbao/packages/design_system/organisms/app_sidebar.dart';
import 'package:barber_osbao/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:barber_osbao/features/agenda/presentation/pages/agenda_page.dart';
import 'package:barber_osbao/features/clientes/presentation/pages/clientes_page.dart';
import 'package:barber_osbao/features/funcionarios/presentation/pages/funcionarios_page.dart';
import 'package:barber_osbao/features/servicos/presentation/pages/servicos_page.dart';
import 'package:barber_osbao/features/produtos/presentation/pages/produtos_page.dart';
import 'package:barber_osbao/features/produtos/presentation/pages/estoque_page.dart';
import 'package:barber_osbao/features/planos/presentation/pages/planos_page.dart';
import 'package:barber_osbao/features/clube/presentation/pages/clube_page.dart';
import 'package:barber_osbao/features/financeiro/presentation/pages/financeiro_page.dart';
import 'package:barber_osbao/features/relatorios/presentation/pages/relatorios_page.dart';
import 'package:barber_osbao/features/configuracoes/presentation/pages/configuracoes_page.dart';
import 'package:barber_osbao/features/categorias/presentation/pages/categorias_page.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'manager_root');
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'manager_shell');

final GoRouter managerRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        final location = state.uri.path;
        String activeId = 'dashboard';

        if (location.startsWith('/agenda')) {
          activeId = 'agenda';
        } else if (location.startsWith('/clientes')) {
          activeId = 'clientes';
        } else if (location.startsWith('/funcionarios')) {
          activeId = 'funcionarios';
        } else if (location.startsWith('/servicos')) {
          activeId = 'servicos';
        } else if (location.startsWith('/produtos')) {
          activeId = 'produtos';
        } else if (location.startsWith('/estoque')) {
          activeId = 'estoque';
        } else if (location.startsWith('/planos')) {
          activeId = 'planos';
        } else if (location.startsWith('/clube')) {
          activeId = 'clube';
        } else if (location.startsWith('/financeiro')) {
          activeId = 'financeiro';
        } else if (location.startsWith('/relatorios')) {
          activeId = 'relatorios';
        } else if (location.startsWith('/configuracoes')) {
          activeId = 'configuracoes';
        } else if (location.startsWith('/categorias')) {
          activeId = 'categorias';
        }

        return Consumer(
          builder: (context, ref, _) {
            return AppScaffold(
              activeSidebarId: activeId,
              sidebarItems: [
                AppSidebarItem(id: 'dashboard', title: 'Dashboard', icon: Icons.dashboard_outlined),
                AppSidebarItem(id: 'agenda', title: 'Agenda', icon: Icons.calendar_today_outlined),
                AppSidebarItem(id: 'clientes', title: 'Clientes', icon: Icons.people_outline),
                AppSidebarItem(id: 'funcionarios', title: 'Funcionários', icon: Icons.badge_outlined),
                AppSidebarItem(id: 'servicos', title: 'Serviços', icon: Icons.content_cut_outlined),
                AppSidebarItem(id: 'produtos', title: 'Produtos', icon: Icons.shopping_bag_outlined),
                AppSidebarItem(id: 'estoque', title: 'Estoque', icon: Icons.inventory_2_outlined),
                AppSidebarItem(id: 'planos', title: 'Planos', icon: Icons.card_membership_outlined),
                AppSidebarItem(id: 'clube', title: 'Clube', icon: Icons.stars_outlined),
                AppSidebarItem(id: 'financeiro', title: 'Financeiro', icon: Icons.account_balance_wallet_outlined),
                AppSidebarItem(id: 'relatorios', title: 'Relatórios', icon: Icons.bar_chart_outlined),
                AppSidebarItem(id: 'configuracoes', title: 'Configurações', icon: Icons.settings_outlined),
              ],
              onSidebarSelected: (id) {
                switch (id) {
                  case 'dashboard':
                    context.go('/');
                    break;
                  case 'agenda':
                    context.go('/agenda');
                    break;
                  case 'clientes':
                    context.go('/clientes');
                    break;
                  case 'funcionarios':
                    context.go('/funcionarios');
                    break;
                  case 'servicos':
                    context.go('/servicos');
                    break;
                  case 'produtos':
                    context.go('/produtos');
                    break;
                  case 'estoque':
                    context.go('/estoque');
                    break;
                  case 'planos':
                    context.go('/planos');
                    break;
                  case 'clube':
                    context.go('/clube');
                    break;
                  case 'financeiro':
                    context.go('/financeiro');
                    break;
                  case 'relatorios':
                    context.go('/relatorios');
                    break;
                  case 'configuracoes':
                    context.go('/configuracoes');
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
          path: '/agenda',
          builder: (context, state) => const AgendaPage(),
        ),
        GoRoute(
          path: '/clientes',
          builder: (context, state) => const ClientesPage(),
        ),
        GoRoute(
          path: '/funcionarios',
          builder: (context, state) => const FuncionariosPage(),
        ),
        GoRoute(
          path: '/servicos',
          builder: (context, state) => const ServicosPage(),
        ),
        GoRoute(
          path: '/produtos',
          builder: (context, state) => const ProdutosPage(),
        ),
        GoRoute(
          path: '/estoque',
          builder: (context, state) => const EstoquePage(),
        ),
        GoRoute(
          path: '/planos',
          builder: (context, state) => const PlanosPage(),
        ),
        GoRoute(
          path: '/clube',
          builder: (context, state) => const ClubePage(),
        ),
        GoRoute(
          path: '/financeiro',
          builder: (context, state) => const FinanceiroPage(),
        ),
        GoRoute(
          path: '/relatorios',
          builder: (context, state) => const RelatoriosPage(),
        ),
        GoRoute(
          path: '/configuracoes',
          builder: (context, state) => const ConfiguracoesPage(),
        ),
        GoRoute(
          path: '/categorias',
          builder: (context, state) => const CategoriasPage(),
        ),
      ],
    ),
  ],
);
