import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:barber_osbao/packages/design_system/theme/theme_colors.dart';
import 'package:barber_osbao/packages/design_system/theme/app_breakpoints.dart';
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
import 'package:barber_osbao/features/financeiro/presentation/pages/bills_page.dart';
import 'package:barber_osbao/features/financeiro/presentation/pages/cash_page.dart';

class FinanceiroPage extends ConsumerStatefulWidget {
  const FinanceiroPage({super.key});

  @override
  ConsumerState<FinanceiroPage> createState() => _FinanceiroPageState();
}

class _FinanceiroPageState extends ConsumerState<FinanceiroPage> {
  String _selectedModule = 'Relatórios';
  String _selectedTab = 'Fluxo de Caixa';

  @override
  Widget build(BuildContext context) {
    final transacoesState = ref.watch(transacoesControllerProvider);
    final summaryState = ref.watch(financeSummaryControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppPage(
      title: 'Financeiro',
      userName: 'Fábio Zvir',
      userAvatarUrl:
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&width=150',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Module Selection Bar
          AppFilters(
            options: const [
              'Relatórios',
              'Comandas & PDV',
              'Operação de Caixa',
            ],
            selectedOption: _selectedModule,
            onSelected: (val) => setState(() => _selectedModule = val),
          ),
          const SizedBox(height: 24),

          // Render selected module
          if (_selectedModule == 'Comandas & PDV')
            const BillsPage()
          else if (_selectedModule == 'Operação de Caixa')
            const CashPage()
          else ...[
            // Stat cards summary
            _buildStatCards(summaryState),
            const SizedBox(height: 24),

            // Charts Row
            _buildChartsRow(summaryState),
            const SizedBox(height: 32),

            // Filters and Actions — responsive Wrap
            Wrap(
              spacing: 12,
              runSpacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                AppFilters(
                  options: const [
                    'Fluxo de Caixa',
                    'Receitas',
                    'Despesas',
                    'Comissões',
                  ],
                  selectedOption: _selectedTab,
                  onSelected: (val) => setState(() => _selectedTab = val),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppButton(
                      label: 'Exportar Excel',
                      icon: const Icon(Icons.download, size: 16),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Planilha financeira exportada com sucesso!',
                            ),
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
        ],
      ),
    );
  }

  Widget _buildStatCards(AppState<Map<String, dynamic>> state) {
    if (state is AppLoading) {
      return const Center(
        child: CircularProgressIndicator(color: ThemeColors.primary),
      );
    }
    if (state is AppError) {
      return Center(
        child: Text(
          'Erro: ${(state as AppError).message}',
          style: const TextStyle(color: ThemeColors.danger),
        ),
      );
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
        final crossCount = constraints.maxWidth > 960
            ? 6
            : (constraints.maxWidth > 600 ? 3 : 2);
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
              icon: const Icon(
                Icons.calendar_month,
                color: ThemeColors.success,
              ),
            ),
            AppStatCard(
              title: 'DESPESAS',
              value: 'R\$ ${expenses.toStringAsFixed(2)}',
              icon: const Icon(Icons.payment, color: ThemeColors.danger),
            ),
            AppStatCard(
              title: 'COMISSÕES A PAGAR',
              value: 'R\$ ${commissions.toStringAsFixed(2)}',
              icon: const Icon(
                Icons.people_outline,
                color: ThemeColors.warning,
              ),
            ),
            AppStatCard(
              title: 'LUCRO LÍQUIDO',
              value: 'R\$ ${netProfit.toStringAsFixed(2)}',
              icon: Icon(
                Icons.account_balance,
                color: netProfit >= 0
                    ? ThemeColors.success
                    : ThemeColors.danger,
              ),
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

    final chartPoints = revHistory
        .map(
          (item) => AppChartDataPoint(
            label: item['date'] as String,
            value: (item['value'] as num).toDouble(),
          ),
        )
        .toList();

    final expensePoints = expHistory
        .map(
          (item) => AppChartDataPoint(
            label: item['date'] as String,
            value: (item['value'] as num).toDouble(),
          ),
        )
        .toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= AppBreakpoints.desktop;
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
        child: Center(
          child: CircularProgressIndicator(color: ThemeColors.primary),
        ),
      );
    }
    if (state is AppError) {
      return Padding(
        padding: const EdgeInsets.all(40.0),
        child: Center(
          child: Text(
            'Erro ao buscar transações.',
            style: const TextStyle(color: ThemeColors.danger),
          ),
        ),
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
        child: Text(
          'Nenhuma transação encontrada.',
          style: TextStyle(color: isDark ? Colors.white30 : Colors.grey),
        ),
      );
    }

    return AppTable(
      minWidth: 850,
      columns: [
        AppTableColumn(label: 'DESCRIÇÃO', flex: 3),
        AppTableColumn(label: 'CATEGORIA', flex: 2),
        AppTableColumn(label: 'FORMA DE PAG.', flex: 2),
        AppTableColumn(label: 'DATA', width: 110),
        AppTableColumn(label: 'TIPO', width: 90),
        AppTableColumn(label: 'VALOR', width: 120),
        AppTableColumn(label: 'STATUS', width: 90),
      ],
      rows: filtered.map((entry) {
        final isIncome = entry.type == 'income';
        return AppTableRow(
          cells: [
            Text(
              entry.description,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
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
              type: entry.status == 'paid'
                  ? AppStatusType.success
                  : AppStatusType.warning,
            ),
          ],
        );
      }).toList(),
    );
  }

  void _showFormDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => const _NewTransactionDialog(),
    );
  }
}

class _NewTransactionDialog extends ConsumerStatefulWidget {
  const _NewTransactionDialog();

  @override
  ConsumerState<_NewTransactionDialog> createState() =>
      _NewTransactionDialogState();
}

class _NewTransactionDialogState extends ConsumerState<_NewTransactionDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _descriptionController;
  late final TextEditingController _amountController;
  late final TextEditingController _dateController;

  String _type = 'income';
  String _category = 'Serviço';
  String _paymentMethod = 'PIX';
  String _status = 'paid';

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController();
    _amountController = TextEditingController();
    _dateController = TextEditingController(text: '2026-07-09');
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = _type == 'income'
        ? ['Serviço', 'Produto', 'Assinatura', 'Outros']
        : [
            'Aluguel',
            'Utilidades',
            'Insumos',
            'Comissão',
            'Marketing',
            'Outros',
          ];

    return AlertDialog(
      backgroundColor: ThemeColors.darkBg,
      title: const Text(
        'Lançar Nova Transação',
        style: TextStyle(color: Colors.white),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                dropdownColor: ThemeColors.darkBg,
                initialValue: _type,
                decoration: const InputDecoration(
                  labelText: 'Tipo de Lançamento',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white30),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                items: const [
                  DropdownMenuItem(value: 'income', child: Text('Receita (+)')),
                  DropdownMenuItem(
                    value: 'expense',
                    child: Text('Despesa (-)'),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _type = val;
                      _category = val == 'income' ? 'Serviço' : 'Insumos';
                    });
                  }
                },
              ),
              const SizedBox(height: 12),
              AppInput(
                label: 'Descrição',
                placeholder: 'Ex: Conta de internet',
                controller: _descriptionController,
                validator: (val) =>
                    val == null || val.isEmpty ? 'Descrição obrigatória' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: AppInput(
                      label: 'Valor (R\$)',
                      placeholder: 'Ex: 120.00',
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (val) => val == null || val.isEmpty
                          ? 'Valor obrigatório'
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      dropdownColor: ThemeColors.darkBg,
                      initialValue: _category,
                      decoration: const InputDecoration(
                        labelText: 'Categoria',
                        labelStyle: TextStyle(color: Colors.white70),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white30),
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                      items: categories
                          .map(
                            (c) => DropdownMenuItem(value: c, child: Text(c)),
                          )
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _category = val);
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
                      initialValue: _paymentMethod,
                      decoration: const InputDecoration(
                        labelText: 'Forma de Pagamento',
                        labelStyle: TextStyle(color: Colors.white70),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white30),
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                      items: const [
                        DropdownMenuItem(value: 'PIX', child: Text('PIX')),
                        DropdownMenuItem(
                          value: 'Cartão de Crédito',
                          child: Text('Cartão de Crédito'),
                        ),
                        DropdownMenuItem(
                          value: 'Cartão de Débito',
                          child: Text('Cartão de Débito'),
                        ),
                        DropdownMenuItem(
                          value: 'Dinheiro',
                          child: Text('Dinheiro'),
                        ),
                        DropdownMenuItem(
                          value: 'Boleto',
                          child: Text('Boleto'),
                        ),
                        DropdownMenuItem(
                          value: 'Transferência',
                          child: Text('Transferência'),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _paymentMethod = val);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      dropdownColor: ThemeColors.darkBg,
                      initialValue: _status,
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        labelStyle: TextStyle(color: Colors.white70),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white30),
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                      items: const [
                        DropdownMenuItem(
                          value: 'paid',
                          child: Text('Pago / Recebido'),
                        ),
                        DropdownMenuItem(
                          value: 'pending',
                          child: Text('Pendente'),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _status = val);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              AppInput(
                label: 'Data (AAAA-MM-DD)',
                placeholder: 'Ex: 2026-07-09',
                controller: _dateController,
                validator: (val) =>
                    val == null || val.isEmpty ? 'Data obrigatória' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Cancelar',
            style: TextStyle(color: Colors.white70),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: ThemeColors.primary),
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              final newT = TransacaoFinanceira(
                id: '',
                type: _type,
                description: _descriptionController.text.trim(),
                amount: double.tryParse(_amountController.text.trim()) ?? 0.0,
                category: _category,
                date: _dateController.text.trim(),
                paymentMethod: _paymentMethod,
                status: _status,
              );
              ref
                  .read(transacoesControllerProvider.notifier)
                  .addTransacao(newT);
              Navigator.of(context).pop();
            }
          },
          child: const Text('Confirmar', style: TextStyle(color: Colors.black)),
        ),
      ],
    );
  }
}
