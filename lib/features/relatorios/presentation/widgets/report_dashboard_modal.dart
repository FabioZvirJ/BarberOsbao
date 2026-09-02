import 'package:flutter/material.dart';
import 'package:barber_osbao/packages/design_system/theme/theme_colors.dart';
import 'package:barber_osbao/packages/design_system/molecules/app_card.dart';
import 'package:barber_osbao/packages/design_system/molecules/app_stat_card.dart';
import 'package:barber_osbao/packages/design_system/molecules/app_chart_card.dart';
import 'package:barber_osbao/packages/design_system/atoms/app_status_chip.dart';
import 'package:barber_osbao/packages/design_system/organisms/app_table.dart';

class ReportDashboardModal extends StatefulWidget {
  final Map<String, dynamic> report;
  final Color themeColor;
  final IconData icon;

  const ReportDashboardModal({
    super.key,
    required this.report,
    required this.themeColor,
    required this.icon,
  });

  static void show(
    BuildContext context, {
    required Map<String, dynamic> report,
    required Color themeColor,
    required IconData icon,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: ReportDashboardModal(
          report: report,
          themeColor: themeColor,
          icon: icon,
        ),
      ),
    );
  }

  @override
  State<ReportDashboardModal> createState() => _ReportDashboardModalState();
}

class _ReportDashboardModalState extends State<ReportDashboardModal> {
  String _selectedPeriod = 'Este Mês';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final id = widget.report['id'] as String;
    final title = widget.report['title'] as String;
    final desc = widget.report['desc'] as String;
    final color = widget.themeColor;

    final data = _getReportDetailedData(id, _selectedPeriod);

    return Container(
      constraints: const BoxConstraints(maxWidth: 1100, maxHeight: 850),
      decoration: BoxDecoration(
        color: isDark ? ThemeColors.darkBg : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? ThemeColors.darkBorder : Colors.grey.shade200,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Scaffold(
          backgroundColor: isDark ? ThemeColors.darkBg : Colors.grey.shade50,
          body: Column(
            children: [
              // 1. Header Bar
              _buildHeader(context, title, desc, color, isDark),
              const Divider(height: 1),

              // 2. Scrollable Dashboard Body
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Filters & Date Switcher
                      _buildPeriodSelector(color, isDark),
                      const SizedBox(height: 20),

                      // 4 Executive KPI Cards
                      _buildKpiGrid(
                        data['kpis'] as List<Map<String, dynamic>>,
                        isDark,
                      ),
                      const SizedBox(height: 24),

                      // Main Chart & Distribution Breakdown
                      _buildChartAndBreakdownRow(data, color, isDark),
                      const SizedBox(height: 24),

                      // Detailed Analytical Table
                      _buildDetailedTable(data, isDark),
                      const SizedBox(height: 24),

                      // Strategic Insights & Actionable Recommendations
                      _buildExecutiveInsights(
                        data['insights'] as List<String>,
                        color,
                        isDark,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    String title,
    String desc,
    Color color,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      color: isDark ? ThemeColors.darkSurface : Colors.white,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Icon(widget.icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: ThemeColors.success.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.bolt,
                            color: ThemeColors.success,
                            size: 12,
                          ),
                          SizedBox(width: 3),
                          Text(
                            'Dados em Tempo Real',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: ThemeColors.success,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          // Export Actions
          Row(
            children: [
              OutlinedButton.icon(
                icon: const Icon(
                  Icons.picture_as_pdf,
                  size: 16,
                  color: Colors.red,
                ),
                label: const Text('PDF', style: TextStyle(fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
                onPressed: () => _showExportFeedback(context, title, 'PDF'),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                icon: const Icon(
                  Icons.table_chart,
                  size: 16,
                  color: Colors.green,
                ),
                label: const Text('Excel', style: TextStyle(fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
                onPressed: () =>
                    _showExportFeedback(context, title, 'Excel (XLSX)'),
              ),
              const SizedBox(width: 12),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
                tooltip: 'Fechar',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector(Color color, bool isDark) {
    final periods = [
      'Hoje',
      'Últimos 7 dias',
      'Este Mês',
      'Últimos 90 dias',
      'Ano 2026',
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
            const SizedBox(width: 8),
            const Text(
              'Período de Análise:',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Wrap(
          spacing: 6,
          children: periods.map((p) {
            final isSelected = _selectedPeriod == p;
            return ChoiceChip(
              label: Text(
                p,
                style: TextStyle(
                  fontSize: 11,
                  color: isSelected
                      ? Colors.black
                      : (isDark ? Colors.white70 : Colors.black87),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              selected: isSelected,
              selectedColor: ThemeColors.primary,
              backgroundColor: isDark ? ThemeColors.darkSurface : Colors.white,
              onSelected: (val) {
                if (val) setState(() => _selectedPeriod = p);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildKpiGrid(List<Map<String, dynamic>> kpis, bool isDark) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossCount = constraints.maxWidth > 700
            ? 4
            : (constraints.maxWidth > 450 ? 2 : 1);
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossCount,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            mainAxisExtent: 115,
          ),
          itemCount: kpis.length,
          itemBuilder: (context, idx) {
            final k = kpis[idx];
            return AppStatCard(
              title: k['title'] as String,
              value: k['value'] as String,
              trendText: k['trend'] as String?,
              positiveTrend: (k['positive'] as bool?) ?? true,
              icon: Icon(
                k['icon'] as IconData? ?? Icons.analytics,
                size: 20,
                color: ThemeColors.primary,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildChartAndBreakdownRow(
    Map<String, dynamic> data,
    Color color,
    bool isDark,
  ) {
    final chartData =
        (data['chart'] as List<Map<String, dynamic>>?)
            ?.map(
              (d) => AppChartDataPoint(
                label: d['label'] as String,
                value: (d['value'] as num).toDouble(),
              ),
            )
            .toList() ??
        [];

    final breakdown = (data['breakdown'] as List<Map<String, dynamic>>?) ?? [];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 800;

        final chartWidget = SizedBox(
          height: 280,
          child: AppChartCard(
            title: 'EVOLUÇÃO TEMPORAL (${_selectedPeriod.toUpperCase()})',
            subtitle: data['chartTitle'] as String? ?? 'Tendência Histórica',
            data: chartData,
            chartColor: color,
            valuePrefix: (data['chartPrefix'] as String?) ?? '',
          ),
        );

        final breakdownWidget = AppCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'DISTRIBUIÇÃO & COMPOSIÇÃO',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white60 : Colors.black54,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const Icon(
                    Icons.pie_chart_outline,
                    size: 16,
                    color: Colors.grey,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...breakdown.map((item) {
                final label = item['label'] as String;
                final pct = (item['pct'] as num).toDouble();
                final val = item['val'] as String;
                final itemColor = item['color'] as Color? ?? color;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            label,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '$val (${pct.toStringAsFixed(0)}%)',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white70 : Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: (pct / 100).clamp(0.0, 1.0),
                          minHeight: 8,
                          backgroundColor: isDark
                              ? Colors.white10
                              : Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(itemColor),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );

        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: chartWidget),
              const SizedBox(width: 16),
              Expanded(flex: 2, child: breakdownWidget),
            ],
          );
        } else {
          return Column(
            children: [
              chartWidget,
              const SizedBox(height: 16),
              breakdownWidget,
            ],
          );
        }
      },
    );
  }

  Widget _buildDetailedTable(Map<String, dynamic> data, bool isDark) {
    final columns =
        (data['tableColumns'] as List<String>?) ??
        ['ITEM', 'VOLUME', 'VALOR', 'PARTICIPAÇÃO', 'STATUS'];
    final rows = (data['tableRows'] as List<List<dynamic>>?) ?? [];

    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Detalhamento Analítico',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                '${rows.length} registros computados',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AppTable(
            minWidth: 800,
            columns: columns.map((col) => AppTableColumn(label: col)).toList(),
            rows: rows.map((r) {
              return AppTableRow(
                cells: [
                  Text(
                    r[0].toString(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(r[1].toString()),
                  Text(
                    r[2].toString(),
                    style: const TextStyle(
                      color: ThemeColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(r[3].toString()),
                  AppStatusChip(
                    label: r[4].toString(),
                    type:
                        r[4].toString().contains('Alta') ||
                            r[4].toString().contains('Líder') ||
                            r[4].toString().contains('Ativo') ||
                            r[4].toString().contains('Excelente')
                        ? AppStatusType.success
                        : AppStatusType.info,
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildExecutiveInsights(
    List<String> insights,
    Color color,
    bool isDark,
  ) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: color, size: 20),
              const SizedBox(width: 10),
              const Text(
                'Insights Estratégicos & Recomendações da Gestão',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...insights.map((insight) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_circle_outline, color: color, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      insight,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white70 : Colors.black87,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  void _showExportFeedback(BuildContext context, String title, String format) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        Future.delayed(const Duration(milliseconds: 1200), () {
          if (ctx.mounted) Navigator.of(ctx).pop();
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Relatório "$title" exportado com sucesso em $format!',
                ),
                backgroundColor: ThemeColors.success,
              ),
            );
          }
        });

        return AlertDialog(
          backgroundColor: ThemeColors.darkBg,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: ThemeColors.primary),
              const SizedBox(height: 16),
              Text(
                'Gerando arquivo executivo $format...',
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ],
          ),
        );
      },
    );
  }

  Map<String, dynamic> _getReportDetailedData(String reportId, String period) {
    switch (reportId) {
      case 'rep_clientes':
        return {
          'kpis': [
            {
              'title': 'Total de Clientes',
              'value': '1.420',
              'trend': '+12% vs mês ant.',
              'positive': true,
              'icon': Icons.people,
            },
            {
              'title': 'Novos Clientes',
              'value': '184',
              'trend': '+18.4%',
              'positive': true,
              'icon': Icons.person_add,
            },
            {
              'title': 'Taxa de Retorno',
              'value': '78.5%',
              'trend': '+4.2%',
              'positive': true,
              'icon': Icons.replay,
            },
            {
              'title': 'LTV Médio',
              'value': 'R\$ 490',
              'trend': '+R\$ 45',
              'positive': true,
              'icon': Icons.account_balance_wallet,
            },
          ],
          'chartTitle': 'Aquisição Mensal de Clientes (2026)',
          'chartPrefix': '',
          'chart': [
            {'label': 'Jan', 'value': 95.0},
            {'label': 'Fev', 'value': 110.0},
            {'label': 'Mar', 'value': 135.0},
            {'label': 'Abr', 'value': 148.0},
            {'label': 'Mai', 'value': 162.0},
            {'label': 'Jun', 'value': 175.0},
            {'label': 'Jul', 'value': 184.0},
          ],
          'breakdown': [
            {
              'label': 'Assinantes de Plano VIP',
              'pct': 42.0,
              'val': '596 clientes',
              'color': ThemeColors.primary,
            },
            {
              'label': 'Clientes Recorrentes (Mensal)',
              'pct': 36.0,
              'val': '511 clientes',
              'color': Colors.blue,
            },
            {
              'label': 'Clientes Esporádicos',
              'pct': 14.0,
              'val': '199 clientes',
              'color': Colors.orange,
            },
            {
              'label': 'Inativos (> 60 dias)',
              'pct': 8.0,
              'val': '114 clientes',
              'color': Colors.red,
            },
          ],
          'tableColumns': [
            'CLIENTE',
            'VISITAS',
            'TOTAL CONSUMIDO',
            'CATEGORIA',
            'STATUS',
          ],
          'tableRows': [
            [
              'Fábio Zvir',
              '18 visitas',
              'R\$ 1.450,00',
              'Plano Imperial',
              'Líder / VIP',
            ],
            [
              'Lucas Silveira',
              '14 visitas',
              'R\$ 980,00',
              'Plano Barão',
              'Ativo / VIP',
            ],
            [
              'Carlos Eduardo',
              '11 visitas',
              'R\$ 720,00',
              'Plano Barão',
              'Ativo',
            ],
            [
              'Matheus Rocha',
              '9 visitas',
              'R\$ 610,00',
              'Plano Cavalheiro',
              'Ativo',
            ],
            [
              'Rodrigo Martins',
              '7 visitas',
              'R\$ 480,00',
              'Avulso',
              'Frequente',
            ],
            ['Guilherme Lima', '6 visitas', 'R\$ 390,00', 'Avulso', 'Ativo'],
          ],
          'insights': [
            '82% dos clientes de Plano VIP retornam com frequência média de 12 dias ao salão.',
            'Campanhas automáticas de WhatsApp reativaram 38 clientes inativos nas últimas 4 semanas.',
            'O ticket médio de clientes do Plano Barão é 2.4x superior ao cliente avulso.',
          ],
        };

      case 'rep_financeiro':
        return {
          'kpis': [
            {
              'title': 'Receita Bruta',
              'value': 'R\$ 48.950',
              'trend': '+15.2% vs mês ant.',
              'positive': true,
              'icon': Icons.trending_up,
            },
            {
              'title': 'Despesas Totais',
              'value': 'R\$ 18.320',
              'trend': '-3.5% controladas',
              'positive': true,
              'icon': Icons.trending_down,
            },
            {
              'title': 'Lucro Líquido',
              'value': 'R\$ 30.630',
              'trend': '+18.1%',
              'positive': true,
              'icon': Icons.savings,
            },
            {
              'title': 'Margem Líquida',
              'value': '62.5%',
              'trend': '+4.1 p.p.',
              'positive': true,
              'icon': Icons.pie_chart,
            },
          ],
          'chartTitle': 'Evolução de Lucro Líquido (R\$)',
          'chartPrefix': 'R\$ ',
          'chart': [
            {'label': 'Jan', 'value': 21000.0},
            {'label': 'Fev', 'value': 23500.0},
            {'label': 'Mar', 'value': 26000.0},
            {'label': 'Abr', 'value': 27800.0},
            {'label': 'Mai', 'value': 29100.0},
            {'label': 'Jun', 'value': 29800.0},
            {'label': 'Jul', 'value': 30630.0},
          ],
          'breakdown': [
            {
              'label': 'PIX (Instantâneo)',
              'pct': 64.0,
              'val': 'R\$ 31.328,00',
              'color': ThemeColors.success,
            },
            {
              'label': 'Cartão de Crédito',
              'pct': 24.0,
              'val': 'R\$ 11.748,00',
              'color': Colors.blue,
            },
            {
              'label': 'Cartão de Débito',
              'pct': 8.0,
              'val': 'R\$ 3.916,00',
              'color': Colors.purple,
            },
            {
              'label': 'Dinheiro em Espécie',
              'pct': 4.0,
              'val': 'R\$ 1.958,00',
              'color': Colors.amber,
            },
          ],
          'tableColumns': [
            'CATEGORIA DRE',
            'LANÇAMENTOS',
            'VALOR TOTAL',
            'PARTICIPAÇÃO',
            'STATUS',
          ],
          'tableRows': [
            [
              'Serviços Executados',
              '840 atend.',
              'R\$ 37.800,00',
              '77.2%',
              'Alta Margem',
            ],
            [
              'Comissões de Barbeiros',
              'Equipe (3)',
              'R\$ 12.630,00',
              '25.8%',
              'Variável',
            ],
            [
              'Planos & Assinaturas SaaS',
              '168 ass.',
              'R\$ 21.480,00',
              '43.8%',
              'Receita Recorrente',
            ],
            [
              'Venda de Produtos & Cosméticos',
              '342 un.',
              'R\$ 15.680,00',
              '32.0%',
              'Alta Margem',
            ],
            [
              'Aluguel & Infraestrutura',
              'Fixos',
              'R\$ 3.800,00',
              '7.7%',
              'Custo Fixo',
            ],
            [
              'Insumos & Descartáveis',
              'Lotes',
              'R\$ 1.890,00',
              '3.8%',
              'Otimizado',
            ],
          ],
          'insights': [
            'O faturamento bateu recorde impulsionado pela adesão aos planos recorrentes (+22%).',
            'O PIX é o principal meio de recebimento (64%), economizando R\$ 1.120 em taxas de máquina.',
            'O ponto de equilíbrio operacional foi atingido logo no 11º dia útil do mês.',
          ],
        };

      case 'rep_produtos':
        return {
          'kpis': [
            {
              'title': 'Itens Vendidos',
              'value': '342 un',
              'trend': '+24% no mês',
              'positive': true,
              'icon': Icons.shopping_bag,
            },
            {
              'title': 'Faturamento Produtos',
              'value': 'R\$ 15.680',
              'trend': '+19.5%',
              'positive': true,
              'icon': Icons.attach_money,
            },
            {
              'title': 'Giro Médio Estoque',
              'value': '14 dias',
              'trend': '-3 dias (mais rápido)',
              'positive': true,
              'icon': Icons.sync,
            },
            {
              'title': 'Margem Média',
              'value': '58.4%',
              'trend': '+2.2 p.p.',
              'positive': true,
              'icon': Icons.percent,
            },
          ],
          'chartTitle': 'Faturamento Mensal de Produtos (R\$)',
          'chartPrefix': 'R\$ ',
          'chart': [
            {'label': 'Jan', 'value': 8200.0},
            {'label': 'Fev', 'value': 9400.0},
            {'label': 'Mar', 'value': 11200.0},
            {'label': 'Abr', 'value': 12800.0},
            {'label': 'Mai', 'value': 13900.0},
            {'label': 'Jun', 'value': 14800.0},
            {'label': 'Jul', 'value': 15680.0},
          ],
          'breakdown': [
            {
              'label': 'Pomadas & Modeladores',
              'pct': 46.0,
              'val': 'R\$ 7.212,00',
              'color': Colors.purple,
            },
            {
              'label': 'Óleos & Balms para Barba',
              'pct': 28.0,
              'val': 'R\$ 4.390,00',
              'color': Colors.amber,
            },
            {
              'label': 'Shampoos & Condicionadores',
              'pct': 16.0,
              'val': 'R\$ 2.508,00',
              'color': Colors.blue,
            },
            {
              'label': 'Bebidas & Cafés do Bar',
              'pct': 10.0,
              'val': 'R\$ 1.570,00',
              'color': Colors.teal,
            },
          ],
          'tableColumns': [
            'PRODUTO',
            'QTD VENDIDA',
            'RECEITA TOTAL',
            'ESTOQUE ATUAL',
            'STATUS',
          ],
          'tableRows': [
            [
              'Pomada Matte Efeito Seco',
              '142 un',
              'R\$ 6.390,00',
              '38 un em estoque',
              'Líder / Alta Margem',
            ],
            [
              'Óleo para Barba Premium 30ml',
              '68 un',
              'R\$ 3.060,00',
              '12 un em estoque',
              'Estoque Crítico',
            ],
            [
              'Shampoo Cabelo & Barba Menthol',
              '54 un',
              'R\$ 2.430,00',
              '29 un em estoque',
              'Ativo',
            ],
            [
              'Balm Hidratante Amadeirado',
              '42 un',
              'R\$ 1.890,00',
              '21 un em estoque',
              'Ativo',
            ],
            [
              'Cerveja IPA Artesanal 500ml',
              '36 un',
              'R\$ 720,00',
              '45 un em estoque',
              'Giro Alto',
            ],
          ],
          'insights': [
            'A Pomada Matte representa quase metade de todas as vendas de produtos no salão.',
            'O estoque de Óleo para Barba Premium atingiu o nível mínimo de segurança (12 un) — sugerido reposição imediata.',
            'Barbeiros que oferecem demonstração de produto ao final do corte convertem 41% das vendas.',
          ],
        };

      case 'rep_funcionarios':
        return {
          'kpis': [
            {
              'title': 'Faturamento Equipe',
              'value': 'R\$ 42.100',
              'trend': '+14.8%',
              'positive': true,
              'icon': Icons.badge,
            },
            {
              'title': 'Comissões Pagas',
              'value': 'R\$ 12.630',
              'trend': 'Média 30%',
              'positive': true,
              'icon': Icons.payments,
            },
            {
              'title': 'Ticket Médio/Prof.',
              'value': 'R\$ 68,50',
              'trend': '+R\$ 8,20',
              'positive': true,
              'icon': Icons.receipt_long,
            },
            {
              'title': 'Média de Avaliações',
              'value': '4.88 ★',
              'trend': '98.5% 5 estrelas',
              'positive': true,
              'icon': Icons.star,
            },
          ],
          'chartTitle': 'Atendimentos Realizados por Mês',
          'chartPrefix': '',
          'chart': [
            {'label': 'Jan', 'value': 480.0},
            {'label': 'Fev', 'value': 540.0},
            {'label': 'Mar', 'value': 620.0},
            {'label': 'Abr', 'value': 690.0},
            {'label': 'Mai', 'value': 740.0},
            {'label': 'Jun', 'value': 790.0},
            {'label': 'Jul', 'value': 840.0},
          ],
          'breakdown': [
            {
              'label': 'Arthur Santos (Senior Specialist)',
              'pct': 38.0,
              'val': 'R\$ 15.998,00',
              'color': ThemeColors.primary,
            },
            {
              'label': 'Marcos Silva (Barbeiro Master)',
              'pct': 34.0,
              'val': 'R\$ 14.314,00',
              'color': Colors.blue,
            },
            {
              'label': 'Gabriel Neves (Barbeiro Fade)',
              'pct': 28.0,
              'val': 'R\$ 11.788,00',
              'color': Colors.orange,
            },
          ],
          'tableColumns': [
            'PROFISSIONAL',
            'ATENDIMENTOS',
            'FATURAMENTO',
            'COMISSÃO PAGA',
            'AVALIAÇÃO',
          ],
          'tableRows': [
            [
              'Arthur Santos',
              '320 cortes',
              'R\$ 15.998,00',
              'R\$ 4.799,40 (30%)',
              '4.95 ★ (Líder)',
            ],
            [
              'Marcos Silva',
              '285 cortes',
              'R\$ 14.314,00',
              'R\$ 4.294,20 (30%)',
              '4.88 ★ (Excelente)',
            ],
            [
              'Gabriel Neves',
              '235 cortes',
              'R\$ 11.788,00',
              'R\$ 3.536,40 (30%)',
              '4.82 ★ (Excelente)',
            ],
          ],
          'insights': [
            'Arthur Santos lidera o faturamento com média de 9.4 atendimentos/dia e menor índice de cancelamentos.',
            'A equipe alcançou nota 4.88 em mais de 380 avaliações de clientes coletadas no app.',
            'A taxa de conversão em cross-selling de produtos pelos profissionais subiu 18%.',
          ],
        };

      case 'rep_servicos':
        return {
          'kpis': [
            {
              'title': 'Total Atendimentos',
              'value': '840',
              'trend': '+16% no período',
              'positive': true,
              'icon': Icons.content_cut,
            },
            {
              'title': 'Receita de Serviços',
              'value': 'R\$ 37.800',
              'trend': '+14.2%',
              'positive': true,
              'icon': Icons.monetization_on,
            },
            {
              'title': 'Tempo Médio Cadeira',
              'value': '38 min',
              'trend': 'Otimizado',
              'positive': true,
              'icon': Icons.timer,
            },
            {
              'title': 'Ticket Médio',
              'value': 'R\$ 45,00',
              'trend': '+R\$ 5,00',
              'positive': true,
              'icon': Icons.price_check,
            },
          ],
          'chartTitle': 'Faturamento por Categoria de Serviço (R\$)',
          'chartPrefix': 'R\$ ',
          'chart': [
            {'label': 'Jan', 'value': 22000.0},
            {'label': 'Fev', 'value': 25000.0},
            {'label': 'Mar', 'value': 28500.0},
            {'label': 'Abr', 'value': 31000.0},
            {'label': 'Mai', 'value': 33500.0},
            {'label': 'Jun', 'value': 36000.0},
            {'label': 'Jul', 'value': 37800.0},
          ],
          'breakdown': [
            {
              'label': 'Corte Degradê / Clássico',
              'pct': 54.0,
              'val': '454 cortes',
              'color': Colors.red,
            },
            {
              'label': 'Barba Completa / Terapia',
              'pct': 24.0,
              'val': '201 barbas',
              'color': Colors.orange,
            },
            {
              'label': 'Combo Cabelo + Barba',
              'pct': 16.0,
              'val': '134 combos',
              'color': ThemeColors.primary,
            },
            {
              'label': 'Sobrancelha & Estética',
              'pct': 6.0,
              'val': '51 serviços',
              'color': Colors.teal,
            },
          ],
          'tableColumns': [
            'SERVIÇO',
            'VOLUME',
            'PREÇO UNIT.',
            'FATURAMENTO',
            'PARTICIPAÇÃO',
          ],
          'tableRows': [
            [
              'Corte Degradê Navalhado',
              '454 atend.',
              'R\$ 45,00',
              'R\$ 20.430,00',
              '54.0% (Líder)',
            ],
            [
              'Barba Completa com Toalha Quente',
              '201 atend.',
              'R\$ 35,00',
              'R\$ 7.035,00',
              '18.6%',
            ],
            [
              'Combo Cabelo + Barba Imperial',
              '134 atend.',
              'R\$ 70,00',
              'R\$ 9.380,00',
              '24.8% (Maior Ticket)',
            ],
            [
              'Design de Sobrancelha na Navalha',
              '51 atend.',
              'R\$ 20,00',
              'R\$ 1.020,00',
              '2.6%',
            ],
          ],
          'insights': [
            'O Combo Cabelo + Barba gera o maior ticket médio unitário (R\$ 70,00) e teve alta de 28%.',
            'O horário de maior procura ocorre de Quinta a Sábado entre 16:00 e 20:30.',
            'O tempo médio de 38 minutos por atendimento mantém a pontualidade da agenda em 96.4%.',
          ],
        };

      case 'rep_planos':
        return {
          'kpis': [
            {
              'title': 'Assinantes Ativos',
              'value': '168',
              'trend': '+22 novas adesões',
              'positive': true,
              'icon': Icons.card_membership,
            },
            {
              'title': 'MRR Recorrente',
              'value': 'R\$ 21.480',
              'trend': '+18.5% no mês',
              'positive': true,
              'icon': Icons.repeat,
            },
            {
              'title': 'Taxa de Churn',
              'value': '1.8%',
              'trend': '-0.4 p.p. (Baixíssimo)',
              'positive': true,
              'icon': Icons.sentiment_very_satisfied,
            },
            {
              'title': 'LTV por Assinante',
              'value': 'R\$ 1.280',
              'trend': '+14 meses médios',
              'positive': true,
              'icon': Icons.all_inclusive,
            },
          ],
          'chartTitle': 'Evolução de Receita Recorrente Mensal - MRR (R\$)',
          'chartPrefix': 'R\$ ',
          'chart': [
            {'label': 'Jan', 'value': 9800.0},
            {'label': 'Fev', 'value': 11500.0},
            {'label': 'Mar', 'value': 14200.0},
            {'label': 'Abr', 'value': 16500.0},
            {'label': 'Mai', 'value': 18200.0},
            {'label': 'Jun', 'value': 19900.0},
            {'label': 'Jul', 'value': 21480.0},
          ],
          'breakdown': [
            {
              'label': 'Plano Barão (R\$ 139,90)',
              'pct': 52.0,
              'val': '87 assinantes',
              'color': ThemeColors.primary,
            },
            {
              'label': 'Plano Imperial (R\$ 199,90)',
              'pct': 31.0,
              'val': '52 assinantes',
              'color': Colors.purple,
            },
            {
              'label': 'Plano Cavalheiro (R\$ 89,90)',
              'pct': 17.0,
              'val': '29 assinantes',
              'color': Colors.teal,
            },
          ],
          'tableColumns': [
            'PLANO',
            'ASSINANTES',
            'VALOR PLANO',
            'MRR GERADO',
            'CHURN RATE',
          ],
          'tableRows': [
            [
              'Plano Barão (Recomendado)',
              '87 membros',
              'R\$ 139,90/mês',
              'R\$ 12.171,30',
              '1.2% (Líder)',
            ],
            [
              'Plano Imperial (VIP)',
              '52 membros',
              'R\$ 199,90/mês',
              'R\$ 10.394,80',
              '0.8% (Mais Fiel)',
            ],
            [
              'Plano Cavalheiro (Básico)',
              '29 membros',
              'R\$ 89,90/mês',
              'R\$ 2.607,10',
              '3.4%',
            ],
          ],
          'insights': [
            'O modelo de assinatura já representa 43.8% de todo o faturamento da barbearia com receita previsível.',
            'O Plano Barão converte mais de 52% dos novos clientes que assinam o programa.',
            'A retenção de clientes em planos é 3.8x maior do que a de clientes sem assinatura.',
          ],
        };

      case 'rep_clube':
        return {
          'kpis': [
            {
              'title': 'Pontos Gerados',
              'value': '84.500',
              'trend': '+28% engajamento',
              'positive': true,
              'icon': Icons.stars,
            },
            {
              'title': 'Pontos Resgatados',
              'value': '52.300',
              'trend': '61.8% conversão',
              'positive': true,
              'icon': Icons.redeem,
            },
            {
              'title': 'Membros no Clube',
              'value': '620',
              'trend': '+75 novos',
              'positive': true,
              'icon': Icons.loyalty,
            },
            {
              'title': 'Ticket Plus Clube',
              'value': '+28%',
              'trend': 'Gastam mais/visita',
              'positive': true,
              'icon': Icons.trending_up,
            },
          ],
          'chartTitle': 'Pontos Emitidos vs Resgatados',
          'chartPrefix': '',
          'chart': [
            {'label': 'Jan', 'value': 42000.0},
            {'label': 'Fev', 'value': 48000.0},
            {'label': 'Mar', 'value': 56000.0},
            {'label': 'Abr', 'value': 63000.0},
            {'label': 'Mai', 'value': 71000.0},
            {'label': 'Jun', 'value': 78000.0},
            {'label': 'Jul', 'value': 84500.0},
          ],
          'breakdown': [
            {
              'label': 'Chopp IPA Artesanal (100 pts)',
              'pct': 45.0,
              'val': '235 resgates',
              'color': Colors.amber,
            },
            {
              'label': 'Pomada Matte Modeladora (250 pts)',
              'pct': 28.0,
              'val': '146 resgates',
              'color': Colors.purple,
            },
            {
              'label': 'Corte Cortesia Aniversário (400 pts)',
              'pct': 18.0,
              'val': '94 resgates',
              'color': ThemeColors.primary,
            },
            {
              'label': 'Café Expresso Especial (40 pts)',
              'pct': 9.0,
              'val': '47 resgates',
              'color': Colors.brown,
            },
          ],
          'tableColumns': [
            'RECOMPENSA',
            'PONTOS EXIGIDOS',
            'TOTAL RESGATES',
            'PONTOS QUEIMADOS',
            'ENGAJAMENTO',
          ],
          'tableRows': [
            [
              'Chopp IPA Artesanal Gelado',
              '100 pontos',
              '235 resgates',
              '23.500 pts',
              'Campeão / Alta Conversão',
            ],
            [
              'Pomada Matte Modeladora',
              '250 pontos',
              '146 resgates',
              '36.500 pts',
              'Alta Procura',
            ],
            [
              'Corte Cortesia de Fidelidade',
              '400 pontos',
              '94 resgates',
              '37.600 pts',
              'Fidelidade Alta',
            ],
            [
              'Café Expresso Gourmet',
              '40 pontos',
              '47 resgates',
              '1.880 pts',
              'Constante',
            ],
          ],
          'insights': [
            'O Chopp Artesanal continua sendo o maior atrativo para clientes acumularem e utilizarem pontos.',
            'Clientes cadastrados no Clube têm frequência de visita 35% mais alta do que os não cadastrados.',
            'A taxa de queima de pontos de 61.8% indica um programa de fidelidade ativo e com alto engajamento.',
          ],
        };

      default:
        return {
          'kpis': [
            {
              'title': 'Total Registros',
              'value': '1.240',
              'trend': '+10%',
              'positive': true,
              'icon': Icons.assessment,
            },
            {
              'title': 'Média Geral',
              'value': 'R\$ 120',
              'trend': '+5%',
              'positive': true,
              'icon': Icons.trending_up,
            },
            {
              'title': 'Índice de Eficiência',
              'value': '94.2%',
              'trend': '+2%',
              'positive': true,
              'icon': Icons.check_circle,
            },
            {
              'title': 'Satisfação',
              'value': '4.9 ★',
              'trend': 'Excelente',
              'positive': true,
              'icon': Icons.star,
            },
          ],
          'chartTitle': 'Tendência Consolidada',
          'chartPrefix': '',
          'chart': [
            {'label': 'Jan', 'value': 100.0},
            {'label': 'Fev', 'value': 120.0},
            {'label': 'Mar', 'value': 140.0},
            {'label': 'Abr', 'value': 160.0},
            {'label': 'Mai', 'value': 180.0},
            {'label': 'Jun', 'value': 200.0},
            {'label': 'Jul', 'value': 220.0},
          ],
          'breakdown': [
            {
              'label': 'Item Principal',
              'pct': 60.0,
              'val': '60%',
              'color': ThemeColors.primary,
            },
            {
              'label': 'Item Secundário',
              'pct': 40.0,
              'val': '40%',
              'color': Colors.blue,
            },
          ],
          'tableColumns': [
            'INDICADOR',
            'MÉTRICA',
            'RESULTADO',
            'VARIAÇÃO',
            'STATUS',
          ],
          'tableRows': [
            ['Desempenho Geral', '1.240 ops', 'Consolidado', '+12%', 'Ativo'],
          ],
          'insights': [
            'Dados compilados com base no histórico recente de movimentações do sistema.',
          ],
        };
    }
  }
}
