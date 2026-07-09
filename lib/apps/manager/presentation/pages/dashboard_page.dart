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
import 'package:barber_osbao/packages/core/shared/repositories/finance_repository.dart';
import 'package:barber_osbao/packages/core/shared/repositories/barber_repository.dart';
import 'package:barber_osbao/packages/core/shared/repositories/product_repository.dart';
import 'package:barber_osbao/packages/core/shared/repositories/customer_repository.dart';
import 'package:barber_osbao/packages/core/shared/appointments/application/appointment_controller.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final financeSummary = ref.watch(financeSummaryProvider);
    final barbers = ref.watch(barbersListProvider);
    final products = ref.watch(productsListProvider);
    final appointments = ref.watch(appointmentsControllerProvider);

    return AppPage(
      title: 'Dashboard',
      userName: 'Fábio Zvir',
      userAvatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&width=150',
      barberName: 'Gerência Osbão',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Stat Cards
          financeSummary.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => const Center(child: Text('Erro ao carregar dados financeiros.')),
            data: (summary) {
              final dailyRev = summary['dailyRevenue'] as double;
              final monthlyRev = summary['monthlyRevenue'] as double;
              final appointmentsCount = summary['dailyAppointments'] as int;
              final newCustomers = summary['newCustomers'] as int;

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
                      mainAxisExtent: 120,
                    ),
                    children: [
                      AppStatCard(
                        title: 'RECEITA DO DIA',
                        value: 'R\$ ${dailyRev.toStringAsFixed(2)}',
                        icon: const Icon(Icons.monetization_on_outlined, color: ThemeColors.success),
                        trendText: '+12% em relação a ontem',
                        positiveTrend: true,
                      ),
                      AppStatCard(
                        title: 'RECEITA DO MÊS',
                        value: 'R\$ ${monthlyRev.toStringAsFixed(2)}',
                        icon: const Icon(Icons.trending_up, color: ThemeColors.primary),
                        trendText: '+8% em relação ao mês anterior',
                        positiveTrend: true,
                      ),
                      AppStatCard(
                        title: 'ATENDIMENTOS HOJE',
                        value: appointmentsCount.toString(),
                        icon: const Icon(Icons.people_outline, color: Colors.blue),
                        trendText: '80% da capacidade preenchida',
                        positiveTrend: true,
                      ),
                      AppStatCard(
                        title: 'NOVOS CLIENTES',
                        value: '+$newCustomers',
                        icon: const Icon(Icons.person_add_outlined, color: Colors.purple),
                        trendText: 'Nesta semana',
                        positiveTrend: true,
                      ),
                    ],
                  );
                },
              );
            },
          ),
          const SizedBox(height: 32),

          // Charts Row
          financeSummary.maybeWhen(
            data: (summary) {
              final revHistory = summary['revenueHistory'] as List<dynamic>;
              final expHistory = summary['expenseHistory'] as List<dynamic>;

              final chartPoints = revHistory.map((item) => AppChartDataPoint(
                label: item['date'] as String,
                value: item['value'] as double,
              )).toList();

              final expensePoints = expHistory.map((item) => AppChartDataPoint(
                label: item['date'] as String,
                value: item['value'] as double,
              )).toList();

              return LayoutBuilder(
                builder: (context, constraints) {
                  final isDesktop = constraints.maxWidth > 800;
                  return Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 300,
                          child: AppChartCard(
                            title: 'FATURAMENTO DIÁRIO',
                            subtitle: 'Últimos 7 dias',
                            data: chartPoints,
                            chartColor: ThemeColors.primary,
                          ),
                        ),
                      ),
                      if (isDesktop) ...[
                        const SizedBox(width: 16),
                        Expanded(
                          child: SizedBox(
                            height: 300,
                            child: AppChartCard(
                              title: 'DESPESAS OPERACIONAIS',
                              subtitle: 'Últimos 7 dias',
                              data: expensePoints,
                              chartColor: ThemeColors.danger,
                            ),
                          ),
                        ),
                      ],
                    ],
                  );
                },
              );
            },
            orElse: () => const SizedBox.shrink(),
          ),
          const SizedBox(height: 32),

          // Quick Action Cards Grid (Cards Rápidos)
          AppSection(
            title: 'Ações Rápidas',
            subtitle: 'Gerenciamento rápido da barbearia',
            child: LayoutBuilder(
              builder: (context, constraints) {
                final crossCount = constraints.maxWidth > 960 ? 4 : (constraints.maxWidth > 600 ? 3 : 2);
                return GridView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    mainAxisExtent: 140,
                  ),
                  children: [
                    AppActionButton(
                      label: 'Cadastrar Serviço',
                      icon: Icons.add_circle_outline,
                      onPressed: () => context.go('/servicos'),
                    ),
                    AppActionButton(
                      label: 'Cadastrar Produto',
                      icon: Icons.add_shopping_cart,
                      onPressed: () => context.go('/produtos'),
                    ),
                    AppActionButton(
                      label: 'Cadastrar Funcionário',
                      icon: Icons.person_add,
                      onPressed: () => context.go('/funcionarios'),
                    ),
                    AppActionButton(
                      label: 'Cadastrar Plano',
                      icon: Icons.card_membership,
                      onPressed: () => context.go('/planos'),
                    ),
                    AppActionButton(
                      label: 'Cadastrar Cliente',
                      icon: Icons.group_add,
                      onPressed: () => context.go('/clientes'),
                    ),
                    AppActionButton(
                      label: 'Novo Agendamento',
                      icon: Icons.calendar_today,
                      onPressed: () => context.go('/agenda'),
                    ),
                    AppActionButton(
                      label: 'Relatório Financeiro',
                      icon: Icons.bar_chart,
                      onPressed: () => context.go('/relatorios'),
                    ),
                    AppActionButton(
                      label: 'Abrir / Fechar Caixa',
                      icon: Icons.account_balance_wallet,
                      onPressed: () => context.go('/financeiro'),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 32),

          // Lists Row: Upcoming Appointments, Low Stock, Active Employees
          LayoutBuilder(
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
                          appointments.when(
                            loading: () => const Center(child: CircularProgressIndicator()),
                            error: (e, s) => const Center(child: Text('Erro ao buscar agenda.')),
                            data: (list) {
                              final current = list.take(4).toList();
                              if (current.isEmpty) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 24),
                                  child: Center(child: Text('Nenhum agendamento para hoje')),
                                );
                              }
                              return ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: current.length,
                                separatorBuilder: (context, index) => const Divider(height: 24),
                                itemBuilder: (context, index) {
                                  final apt = current[index];
                                  return Row(
                                    children: [
                                      AppAvatar(url: apt.barberAvatar, size: 40),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              apt.barberName,
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              '${apt.services.map((s) => s.name).join(", ")} - ${apt.time}',
                                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                                            ),
                                          ],
                                        ),
                                      ),
                                      AppStatusChip(
                                        label: apt.status == 'confirmed' ? 'Confirmado' : 'Finalizado',
                                        type: apt.status == 'confirmed' ? AppStatusType.warning : AppStatusType.success,
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
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
                            products.when(
                              loading: () => const Center(child: CircularProgressIndicator()),
                              error: (e, s) => const Center(child: Text('Erro.')),
                              data: (list) {
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
                                        Icon(Icons.warning_amber_rounded, color: ThemeColors.danger, size: 20),
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
                                                'Min: ${prod.minStock} | Atual: ${prod.stock}',
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
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0, curve: Curves.easeOut),
    );
  }
}
