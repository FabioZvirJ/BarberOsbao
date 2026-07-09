import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:barber_osbao/packages/design_system/theme/theme_colors.dart';
import 'package:barber_osbao/packages/design_system/layouts/app_page.dart';
import 'package:barber_osbao/packages/design_system/layouts/app_section.dart';
import 'package:barber_osbao/packages/design_system/organisms/app_table.dart';
import 'package:barber_osbao/packages/design_system/molecules/app_filters.dart';
import 'package:barber_osbao/packages/design_system/molecules/app_stat_card.dart';
import 'package:barber_osbao/packages/design_system/molecules/app_chart_card.dart';
import 'package:barber_osbao/packages/design_system/atoms/app_button.dart';
import 'package:barber_osbao/packages/design_system/atoms/app_status_chip.dart';
import 'package:barber_osbao/packages/design_system/molecules/app_input.dart';
import 'package:barber_osbao/packages/core/shared/state/app_state.dart';
import 'package:barber_osbao/features/financeiro/domain/models/transacao.dart';
import 'package:barber_osbao/features/financeiro/presentation/controllers/financeiro_controller.dart';

class FinanceiroPage extends ConsumerStatefulWidget {
  const FinanceiroPage({super.key});

  @override
  ConsumerState<FinanceiroPage> createState() => _FinanceiroPageState();
}

class _FinanceiroPageState extends ConsumerState<FinanceiroPage> {
  String _selectedTab = 'Fluxo de Caixa';

  @override
  Widget build(BuildContext context) {
    final transacoesState = ref.watch(transacoesControllerProvider);
    final summaryState = ref.watch(financeSummaryControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppPage(
      title: 'Financeiro',
      userName: 'Fábio Zvir',
      userAvatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&width=150',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Stat cards summary
          _buildStatCards(summaryState),
          const SizedBox(height: 24),

          // Charts Row
          _buildChartsRow(summaryState),
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
              Row(
                children: [
                  AppButton(
                    label: 'Exportar Excel',
                    icon: const Icon(Icons.download, size: 16),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Planilha financeira exportada com sucesso!'),
                          backgroundColor: ThemeColors.success,
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  AppButton(
                    label: 'Nova Transação',
                    icon: const Icon(Icons.add, size: 16),
                    onPressed: () => _showFormDialog(context),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Entries table
          AppSection(
            title: _selectedTab,
            subtitle: 'Histórico detalhado de transações financeiras',
            child: _buildContent(transacoesState, isDark),
          ),
        ],
      ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0, curve: Curves.easeOut),
    );
  }

  Widget _buildStatCards(AppState<Map<String, dynamic>> state) {
    if (state is AppLoading) {
      return const Center(child: CircularProgressIndicator(color: ThemeColors.primary));
    }
    if (state is AppError) {
      return Center(child: Text('Erro: ${(state as AppError).message}', style: const TextStyle(color: ThemeColors.danger)));
    }

    final summary = state.data ?? {};
    final dailyRev = summary['dailyRevenue'] as double? ?? 0.0;
    final weeklyRev = summary['weeklyRevenue'] as double? ?? 0.0;
    final monthlyRev = summary['monthlyRevenue'] as double? ?? 0.0;
    final expenses = summary['totalExpenses'] as double? ?? 0.0;
    final commissions = summary['commissionsDue'] as double? ?? 0.0;
    final netProfit = summary['netProfit'] as double? ?? 0.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossCount = constraints.maxWidth > 960 ? 6 : (constraints.maxWidth > 600 ? 3 : 2);
        return GridView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: 130,
          ),
          children: [
            AppStatCard(
              title: 'RECEITA HOJE',
              value: 'R\$ ${dailyRev.toStringAsFixed(2)}',
              icon: const Icon(Icons.today, color: ThemeColors.primary),
            ),
            AppStatCard(
              title: 'RECEITA SEMANA',
              value: 'R\$ ${weeklyRev.toStringAsFixed(2)}',
              icon: const Icon(Icons.date_range, color: Colors.blue),
            ),
            AppStatCard(
              title: 'RECEITA MÊS',
              value: 'R\$ ${monthlyRev.toStringAsFixed(2)}',
              icon: const Icon(Icons.calendar_month, color: ThemeColors.success),
            ),
            AppStatCard(
              title: 'DESPESAS',
              value: 'R\$ ${expenses.toStringAsFixed(2)}',
              icon: const Icon(Icons.payment, color: ThemeColors.danger),
            ),
            AppStatCard(
              title: 'COMISSÕES A PAGAR',
              value: 'R\$ ${commissions.toStringAsFixed(2)}',
              icon: const Icon(Icons.people_outline, color: ThemeColors.warning),
            ),
            AppStatCard(
              title: 'LUCRO LÍQUIDO',
              value: 'R\$ ${netProfit.toStringAsFixed(2)}',
              icon: Icon(Icons.account_balance, color: netProfit >= 0 ? ThemeColors.success : ThemeColors.danger),
            ),
          ],
        );
      },
    );
  }

  Widget _buildChartsRow(AppState<Map<String, dynamic>> state) {
    if (state is! AppSuccess<Map<String, dynamic>>) {
      return const SizedBox.shrink();
    }
    final summary = state.data;
    final revHistory = summary['revenueHistory'] as List<dynamic>? ?? [];
    final expHistory = summary['expenseHistory'] as List<dynamic>? ?? [];

    final chartPoints = revHistory.map((item) => AppChartDataPoint(
      label: item['date'] as String,
      value: (item['value'] as num).toDouble(),
    )).toList();

    final expensePoints = expHistory.map((item) => AppChartDataPoint(
      label: item['date'] as String,
      value: (item['value'] as num).toDouble(),
    )).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 800;
        return Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 260,
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
                  height: 260,
                  child: AppChartCard(
                    title: 'DESPESAS DIÁRIAS',
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
  }

  Widget _buildContent(AppState<List<TransacaoFinanceira>> state, bool isDark) {
    if (state is AppLoading) {
      return const Padding(
        padding: EdgeInsets.all(40.0),
        child: Center(child: CircularProgressIndicator(color: ThemeColors.primary)),
      );
    }
    if (state is AppError) {
      return Padding(
        padding: const EdgeInsets.all(40.0),
        child: Center(child: Text('Erro ao buscar transações.', style: const TextStyle(color: ThemeColors.danger))),
      );
    }

    final data = state.data ?? [];
    final filtered = data.where((item) {
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
  }

  void _showFormDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final descriptionController = TextEditingController();
    final amountController = TextEditingController();
    final dateController = TextEditingController(text: '2026-07-09');
    
    String type = 'income';
    String category = 'Serviço';
    String paymentMethod = 'PIX';
    String status = 'paid';

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            final categories = type == 'income'
                ? ['Serviço', 'Produto', 'Assinatura', 'Outros']
                : ['Aluguel', 'Utilidades', 'Insumos', 'Comissão', 'Marketing', 'Outros'];

            return AlertDialog(
              backgroundColor: ThemeColors.darkBg,
              title: const Text('Lançar Nova Transação', style: TextStyle(color: Colors.white)),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        dropdownColor: ThemeColors.darkBg,
                        value: type,
                        decoration: const InputDecoration(
                          labelText: 'Tipo de Lançamento',
                          labelStyle: TextStyle(color: Colors.white70),
                          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
                        ),
                        style: const TextStyle(color: Colors.white),
                        items: const [
                          DropdownMenuItem(value: 'income', child: Text('Receita (+)')),
                          DropdownMenuItem(value: 'expense', child: Text('Despesa (-)')),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              type = val;
                              category = val == 'income' ? 'Serviço' : 'Insumos';
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      AppInput(
                        label: 'Descrição',
                        placeholder: 'Ex: Conta de internet',
                        controller: descriptionController,
                        validator: (val) => val == null || val.isEmpty ? 'Descrição obrigatória' : null,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: AppInput(
                              label: 'Valor (R\$)',
                              placeholder: 'Ex: 120.00',
                              controller: amountController,
                              keyboardType: TextInputType.number,
                              validator: (val) => val == null || val.isEmpty ? 'Valor obrigatório' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              dropdownColor: ThemeColors.darkBg,
                              value: category,
                              decoration: const InputDecoration(
                                labelText: 'Categoria',
                                labelStyle: TextStyle(color: Colors.white70),
                                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
                              ),
                              style: const TextStyle(color: Colors.white),
                              items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => category = val);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              dropdownColor: ThemeColors.darkBg,
                              value: paymentMethod,
                              decoration: const InputDecoration(
                                labelText: 'Forma de Pagamento',
                                labelStyle: TextStyle(color: Colors.white70),
                                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
                              ),
                              style: const TextStyle(color: Colors.white),
                              items: const [
                                DropdownMenuItem(value: 'PIX', child: Text('PIX')),
                                DropdownMenuItem(value: 'Cartão de Crédito', child: Text('Cartão de Crédito')),
                                DropdownMenuItem(value: 'Cartão de Débito', child: Text('Cartão de Débito')),
                                DropdownMenuItem(value: 'Dinheiro', child: Text('Dinheiro')),
                                DropdownMenuItem(value: 'Boleto', child: Text('Boleto')),
                                DropdownMenuItem(value: 'Transferência', child: Text('Transferência')),
                              ],
                              onChanged: (val) {
                                if (val != null) setState(() => paymentMethod = val);
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              dropdownColor: ThemeColors.darkBg,
                              value: status,
                              decoration: const InputDecoration(
                                labelText: 'Status',
                                labelStyle: TextStyle(color: Colors.white70),
                                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
                              ),
                              style: const TextStyle(color: Colors.white),
                              items: const [
                                DropdownMenuItem(value: 'paid', child: Text('Pago / Recebido')),
                                DropdownMenuItem(value: 'pending', child: Text('Pendente')),
                              ],
                              onChanged: (val) {
                                if (val != null) setState(() => status = val);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      AppInput(
                        label: 'Data (AAAA-MM-DD)',
                        placeholder: 'Ex: 2026-07-09',
                        controller: dateController,
                        validator: (val) => val == null || val.isEmpty ? 'Data obrigatória' : null,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: ThemeColors.primary),
                  onPressed: () {
                    if (formKey.currentState?.validate() ?? false) {
                      final newT = TransacaoFinanceira(
                        id: '',
                        type: type,
                        description: descriptionController.text.trim(),
                        amount: double.parse(amountController.text.trim()),
                        category: category,
                        date: dateController.text.trim(),
                        paymentMethod: paymentMethod,
                        status: status,
                      );
                      ref.read(transacoesControllerProvider.notifier).addTransacao(newT);
                      Navigator.of(ctx).pop();
                    }
                  },
                  child: const Text('Confirmar', style: TextStyle(color: Colors.black)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
