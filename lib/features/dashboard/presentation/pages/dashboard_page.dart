import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:barber_osbao/packages/design_system/theme/theme_colors.dart';
import 'package:barber_osbao/packages/design_system/layouts/app_page.dart';
import 'package:barber_osbao/packages/design_system/layouts/app_section.dart';
import 'package:barber_osbao/packages/design_system/molecules/app_card.dart';
import 'package:barber_osbao/packages/design_system/molecules/app_stat_card.dart';
import 'package:barber_osbao/packages/design_system/molecules/app_chart_card.dart';
import 'package:barber_osbao/packages/design_system/atoms/app_action_button.dart';
import 'package:barber_osbao/packages/design_system/atoms/app_status_chip.dart';
import 'package:barber_osbao/packages/design_system/atoms/app_avatar.dart';
import 'package:barber_osbao/packages/core/shared/state/app_state.dart';
import 'package:barber_osbao/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:barber_osbao/features/agenda/presentation/controllers/agenda_controller.dart';
import 'package:barber_osbao/features/produtos/presentation/controllers/produtos_controller.dart';
import 'package:barber_osbao/features/financeiro/presentation/controllers/financeiro_controller.dart';
import 'package:barber_osbao/features/produtos/domain/models/produto.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsState = ref.watch(dashboardControllerProvider);
    final appointmentsState = ref.watch(agendaControllerProvider);
    final productsState = ref.watch(produtosControllerProvider);
    final summaryState = ref.watch(financeSummaryControllerProvider);

    return AppPage(
      title: 'Dashboard',
      userName: 'Fábio Zvir',
      userAvatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&width=150',
      barberName: 'Sua Barbearia - Gerenciador',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Greeting & Intro
          const Text(
            'Olá, Fernando! 👋',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 4),
          const Text(
            'Aqui está o resumo da sua barbearia hoje.',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 24),

          // Stat Cards Grid
          _buildStatCards(statsState, context),
          const SizedBox(height: 32),

          // Charts Row (Faturamento & Despesas)
          _buildChartsRow(summaryState, context),
          const SizedBox(height: 32),

          // Gerenciar cadastros (Manage Cards)
          _buildManageCardsSection(context),
          const SizedBox(height: 32),

          // Quick Access Grid
          _buildQuickAccessSection(context),
          const SizedBox(height: 32),

          // Bottom Lists: Upcoming Appointments & Critical Stock
          _buildBottomLists(appointmentsState, productsState, context),
        ],
      ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0, curve: Curves.easeOut),
    );
  }

  Widget _buildStatCards(AppState<Map<String, dynamic>> state, BuildContext context) {
    if (state is AppLoading) {
      return const Center(child: CircularProgressIndicator(color: ThemeColors.primary));
    }
    if (state is AppError) {
      return Center(child: Text('Erro: ${(state as AppError).message}', style: const TextStyle(color: ThemeColors.danger)));
    }

    final stats = state.data ?? {};
    final appointmentsToday = stats['appointmentsTodayCount'] as int? ?? 0;
    final dailyRevenue = stats['dailyRevenue'] as double? ?? 0.0;
    final newClients = stats['newClientsCount'] as int? ?? 0;
    final avgRating = stats['averageRating'] as double? ?? 4.8;

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossCount = constraints.maxWidth > 800 ? 4 : 2;
        return GridView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            mainAxisExtent: 130,
          ),
          children: [
            InkWell(
              onTap: () => context.go('/agenda'),
              child: AppStatCard(
                title: 'AGENDAMENTOS HOJE',
                value: appointmentsToday.toString(),
                icon: const Icon(Icons.calendar_today_outlined, color: ThemeColors.primary),
                trendText: '+12% que ontem',
                positiveTrend: true,
              ),
            ),
            InkWell(
              onTap: () => context.go('/financeiro'),
              child: AppStatCard(
                title: 'FATURAMENTO HOJE',
                value: 'R\$ ${dailyRevenue.toStringAsFixed(2)}',
                icon: const Icon(Icons.monetization_on_outlined, color: ThemeColors.success),
                trendText: '+18% que ontem',
                positiveTrend: true,
              ),
            ),
            InkWell(
              onTap: () => context.go('/clientes'),
              child: AppStatCard(
                title: 'NOVOS CLIENTES',
                value: newClients.toString(),
                icon: const Icon(Icons.people_outline, color: Colors.blue),
                trendText: '+2% que ontem',
                positiveTrend: true,
              ),
            ),
            AppStatCard(
              title: 'AVALIAÇÃO MÉDIA',
              value: avgRating.toString(),
              icon: const Icon(Icons.star_outline, color: Colors.orange),
              trendText: 'Média de avaliações',
              positiveTrend: true,
            ),
          ],
        );
      },
    );
  }

  Widget _buildChartsRow(AppState<Map<String, dynamic>> summaryState, BuildContext context) {
    if (summaryState is! AppSuccess<Map<String, dynamic>>) {
      return const SizedBox.shrink();
    }
    final summary = summaryState.data;
    final revHistory = summary['revenueHistory'] as List<dynamic>? ?? [];

    final chartPoints = revHistory.map((item) => AppChartDataPoint(
      label: item['date'] as String,
      value: (item['value'] as num).toDouble(),
    )).toList();

    return SizedBox(
      height: 280,
      child: InkWell(
        onTap: () => context.go('/financeiro'),
        child: AppChartCard(
          title: 'FATURAMENTO (ÚLTIMOS 7 DIAS)',
          subtitle: 'Clique para abrir o módulo financeiro completo',
          data: chartPoints,
          chartColor: ThemeColors.primary,
        ),
      ),
    );
  }

  Widget _buildManageCardsSection(BuildContext context) {
    final items = [
      {'label': 'Serviços', 'icon': Icons.content_cut_outlined, 'path': '/servicos', 'desc': 'Gerenciar serviços, preços e duração.'},
      {'label': 'Produtos', 'icon': Icons.shopping_bag_outlined, 'path': '/produtos', 'desc': 'Gerenciar produtos da loja.'},
      {'label': 'Funcionários', 'icon': Icons.badge_outlined, 'path': '/funcionarios', 'desc': 'Gerenciar equipe e comissões.'},
      {'label': 'Planos', 'icon': Icons.card_membership_outlined, 'path': '/planos', 'desc': 'Gerenciar planos e preços.'},
      {'label': 'Clube', 'icon': Icons.stars_outlined, 'path': '/clube', 'desc': 'Gerenciar benefícios e descontos.'},
      {'label': 'Categorias', 'icon': Icons.category_outlined, 'path': '/categorias', 'desc': 'Gerenciar categorias.'},
    ];

    return AppSection(
      title: 'Gerenciar cadastros',
      subtitle: 'Administre todos os cadastros base do sistema ERP',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final crossCount = constraints.maxWidth > 960 ? 6 : (constraints.maxWidth > 600 ? 3 : 2);
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossCount,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              mainAxisExtent: 140,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return InkWell(
                onTap: () => context.go(item['path'] as String),
                child: AppCard(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(item['icon'] as IconData, color: ThemeColors.primary, size: 28),
                      const SizedBox(height: 10),
                      Text(item['label'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 4),
                      Text(
                        item['desc'] as String,
                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildQuickAccessSection(BuildContext context) {
    return AppSection(
      title: 'Acessos rápidos',
      subtitle: 'Ações administrativas rápidas',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final crossCount = constraints.maxWidth > 960 ? 5 : (constraints.maxWidth > 600 ? 3 : 2);
          return GridView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossCount,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              mainAxisExtent: 150,
            ),
            children: [
              AppActionButton(
                label: 'Novo serviço',
                icon: Icons.add_circle_outline,
                onPressed: () => context.go('/servicos'),
              ),
              AppActionButton(
                label: 'Novo produto',
                icon: Icons.add_shopping_cart,
                onPressed: () => context.go('/produtos'),
              ),
              AppActionButton(
                label: 'Novo funcionário',
                icon: Icons.person_add,
                onPressed: () => context.go('/funcionarios'),
              ),
              AppActionButton(
                label: 'Novo plano',
                icon: Icons.card_membership,
                onPressed: () => context.go('/planos'),
              ),
              AppActionButton(
                label: 'Relatório financeiro',
                icon: Icons.bar_chart,
                onPressed: () => context.go('/relatorios'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBottomLists(
    AppState<List<dynamic>> appointmentsState,
    AppState<List<Produto>> productsState,
    BuildContext context,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 960;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Appointments List
            Expanded(
              flex: 2,
              child: AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'PRÓXIMOS AGENDAMENTOS',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                        ),
                        TextButton(
                          onPressed: () => context.go('/agenda'),
                          child: const Text('Ver todos', style: TextStyle(color: ThemeColors.primary, fontSize: 13)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildAppointmentsList(appointmentsState),
                  ],
                ),
              ),
            ),
            if (isDesktop) ...[
              const SizedBox(width: 24),
              // Low Stock Products
              Expanded(
                flex: 1,
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'ESTOQUE CRÍTICO',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                          ),
                          TextButton(
                            onPressed: () => context.go('/estoque'),
                            child: const Text('Ver estoque', style: TextStyle(color: ThemeColors.primary, fontSize: 13)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildCriticalStockList(productsState),
                    ],
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildAppointmentsList(AppState<List<dynamic>> state) {
    if (state is AppLoading) {
      return const Center(child: CircularProgressIndicator(color: ThemeColors.primary));
    }
    final list = state.data ?? [];
    final current = list.where((apt) => apt.status == 'confirmed' || apt.status == 'pending').take(4).toList();

    if (current.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: Text('Nenhum agendamento pendente para hoje')),
      );
    }

    final statusLabel = {
      'pending': 'Pendente',
      'confirmed': 'Confirmado',
      'completed': 'Finalizado',
      'cancelled': 'Cancelado',
    };

    final statusType = {
      'pending': AppStatusType.info,
      'confirmed': AppStatusType.warning,
      'completed': AppStatusType.success,
      'cancelled': AppStatusType.danger,
    };

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: current.length,
      separatorBuilder: (context, index) => const Divider(height: 24),
      itemBuilder: (context, index) {
        final apt = current[index];
        return Row(
          children: [
            const Icon(Icons.person_pin, size: 36, color: ThemeColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    apt.clientName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Barbeiro: ${apt.barberName} | ${apt.services} - ${apt.time}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            AppStatusChip(
              label: statusLabel[apt.status] ?? 'Agendado',
              type: statusType[apt.status] ?? AppStatusType.info,
            ),
          ],
        );
      },
    );
  }

  Widget _buildCriticalStockList(AppState<List<Produto>> state) {
    if (state is AppLoading) {
      return const Center(child: CircularProgressIndicator(color: ThemeColors.primary));
    }
    final list = state.data ?? [];
    final critical = list.where((p) => p.stock <= p.minStock).toList();

    if (critical.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: Text('Estoque OK', style: TextStyle(color: ThemeColors.success))),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: critical.length,
      separatorBuilder: (context, index) => const Divider(height: 16),
      itemBuilder: (context, index) {
        final prod = critical[index];
        return Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: ThemeColors.danger, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    prod.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Mín: ${prod.minStock} | Atual: ${prod.stock}',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ),
            AppStatusChip(label: 'Crítico', type: AppStatusType.danger),
          ],
        );
      },
    );
  }
}
