import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:barber_osbao/packages/design_system/theme/theme_colors.dart';
import 'package:barber_osbao/packages/design_system/layouts/app_page.dart';
import 'package:barber_osbao/packages/design_system/layouts/app_section.dart';
import 'package:barber_osbao/packages/design_system/organisms/app_table.dart';
import 'package:barber_osbao/packages/design_system/molecules/app_filters.dart';
import 'package:barber_osbao/packages/design_system/molecules/app_stat_card.dart';
import 'package:barber_osbao/packages/design_system/atoms/app_button.dart';
import 'package:barber_osbao/packages/design_system/atoms/app_status_chip.dart';
import 'package:barber_osbao/packages/core/shared/repositories/finance_repository.dart';

class FinanceiroPage extends ConsumerStatefulWidget {
  const FinanceiroPage({super.key});

  @override
  ConsumerState<FinanceiroPage> createState() => _FinanceiroPageState();
}

class _FinanceiroPageState extends ConsumerState<FinanceiroPage> {
  String _selectedTab = 'Fluxo de Caixa';

  @override
  Widget build(BuildContext context) {
    final entriesState = ref.watch(financeEntriesProvider);
    final summaryState = ref.watch(financeSummaryProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppPage(
      title: 'Financeiro',
      userName: 'Fábio Zvir',
      userAvatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&width=150',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Summary cards
          summaryState.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => const Center(child: Text('Erro ao carregar resumo.')),
            data: (summary) {
              final monthlyRev = summary['monthlyRevenue'] as double;
              final commissions = summary['commissionsDue'] as double;
              final expenses = summary['totalExpenses'] as double;
              final netProfit = monthlyRev - commissions - expenses;

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
                      mainAxisExtent: 110,
                    ),
                    children: [
                      AppStatCard(
                        title: 'FATURAMENTO TOTAL',
                        value: 'R\$ ${monthlyRev.toStringAsFixed(2)}',
                        icon: const Icon(Icons.monetization_on, color: ThemeColors.success),
                      ),
                      AppStatCard(
                        title: 'DESPESAS FIXAS/VARIAV.',
                        value: 'R\$ ${expenses.toStringAsFixed(2)}',
                        icon: const Icon(Icons.payment, color: ThemeColors.danger),
                      ),
                      AppStatCard(
                        title: 'COMISSÕES A PAGAR',
                        value: 'R\$ ${commissions.toStringAsFixed(2)}',
                        icon: const Icon(Icons.people_outline, color: ThemeColors.warning),
                      ),
                      AppStatCard(
                        title: 'LUCRO LÍQUIDO ESTIMADO',
                        value: 'R\$ ${netProfit.toStringAsFixed(2)}',
                        icon: const Icon(Icons.account_balance, color: Colors.blue),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          const SizedBox(height: 32),

          // Filters and Actions Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppFilters(
                options: const ['Fluxo de Caixa', 'Receitas', 'Despesas', 'Comissões'],
                selectedOption: _selectedTab,
                onSelected: (val) => setState(() => _selectedTab = val),
              ),
              AppButton(
                label: 'Nova Transação',
                icon: const Icon(Icons.add, size: 16),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Entries table
          AppSection(
            title: _selectedTab,
            subtitle: 'Histórico detalhado de transações financeiras',
            child: entriesState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => const Center(child: Text('Erro ao buscar transações.')),
              data: (list) {
                final filtered = list.where((item) {
                  if (_selectedTab == 'Receitas') return item.type == 'income';
                  if (_selectedTab == 'Despesas') return item.type == 'expense';
                  if (_selectedTab == 'Comissões') return item.category == 'Comissão';
                  return true;
                }).toList();

                if (filtered.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(40),
                    alignment: Alignment.center,
                    child: Text('Nenhuma transação encontrada.', style: TextStyle(color: isDark ? Colors.white30 : Colors.grey)),
                  );
                }

                return AppTable(
                  columns: [
                    AppTableColumn(label: 'DESCRIÇÃO', width: 250),
                    AppTableColumn(label: 'CATEGORIA'),
                    AppTableColumn(label: 'FORMA DE PAG.'),
                    AppTableColumn(label: 'DATA'),
                    AppTableColumn(label: 'TIPO'),
                    AppTableColumn(label: 'VALOR'),
                    AppTableColumn(label: 'STATUS'),
                  ],
                  rows: filtered.map((entry) {
                    final isIncome = entry.type == 'income';

                    return AppTableRow(
                      cells: [
                        Text(entry.description, style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(entry.category),
                        Text(entry.paymentMethod),
                        Text(entry.date.split('-').reversed.join('/')),
                        AppStatusChip(
                          label: isIncome ? 'Receita' : 'Despesa',
                          type: isIncome ? AppStatusType.success : AppStatusType.danger,
                        ),
                        Text(
                          '${isIncome ? "+" : "-"} R\$ ${entry.amount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isIncome ? ThemeColors.success : ThemeColors.danger,
                          ),
                        ),
                        AppStatusChip(
                          label: entry.status == 'paid' ? 'Pago' : 'Pendente',
                          type: entry.status == 'paid' ? AppStatusType.success : AppStatusType.warning,
                        ),
                      ],
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0, curve: Curves.easeOut),
    );
  }
}
