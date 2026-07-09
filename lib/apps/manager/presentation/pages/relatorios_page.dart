import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:barber_osbao/packages/design_system/theme/theme_colors.dart';
import 'package:barber_osbao/packages/design_system/layouts/app_page.dart';
import 'package:barber_osbao/packages/design_system/layouts/app_section.dart';
import 'package:barber_osbao/packages/design_system/molecules/app_card.dart';

class RelatoriosPage extends StatelessWidget {
  const RelatoriosPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final List<Map<String, dynamic>> reportTypes = [
      {
        'title': 'Relatório de Clientes',
        'desc': 'Crescimento de base, taxa de retorno, histórico de visitas e fidelidade.',
        'icon': Icons.people_outline,
        'stats': '1,420 clientes cadastrados',
        'color': Colors.blue,
      },
      {
        'title': 'Relatório Financeiro',
        'desc': 'Demonstrativo de resultados (DRE), fluxo de caixa, despesas e faturamento.',
        'icon': Icons.bar_chart_outlined,
        'stats': '+15% de lucro líquido',
        'color': ThemeColors.success,
      },
      {
        'title': 'Relatório de Produtos',
        'desc': 'Mais vendidos, curva ABC de estoque, rotatividade de inventário e margens.',
        'icon': Icons.shopping_bag_outlined,
        'stats': 'Óleo Woodsmoke líder',
        'color': Colors.purple,
      },
      {
        'title': 'Relatório de Funcionários',
        'desc': 'Performance por barbeiro, faturamento individual, comissões pagas e avaliações.',
        'icon': Icons.badge_outlined,
        'stats': 'Arthur Santos 4.9*',
        'color': ThemeColors.warning,
      },
      {
        'title': 'Relatório de Serviços',
        'desc': 'Volume de serviços vendidos, tempo médio de cadeira e ticket médio por visita.',
        'icon': Icons.content_cut_outlined,
        'stats': 'Corte Degradê (54% vendas)',
        'color': Colors.red,
      },
    ];

    return AppPage(
      title: 'Relatórios',
      userName: 'Fábio Zvir',
      userAvatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&width=150',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSection(
            title: 'Centro de Relatórios',
            subtitle: 'Gere relatórios gerenciais e exporte planilhas Excel ou PDF',
            child: LayoutBuilder(
              builder: (context, constraints) {
                final crossCount = constraints.maxWidth > 800 ? 3 : (constraints.maxWidth > 550 ? 2 : 1);
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossCount,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    mainAxisExtent: 220,
                  ),
                  itemCount: reportTypes.length,
                  itemBuilder: (context, index) {
                    final report = reportTypes[index];
                    return AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: (report['color'] as Color).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  report['icon'] as IconData,
                                  color: report['color'] as Color,
                                  size: 24,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.download, size: 20),
                                onPressed: () {
                                  // Trigger download mock
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Exportando ${report['title']} em formato Excel...'),
                                      backgroundColor: ThemeColors.primary,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            report['title'] as String,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          Expanded(
                            child: Text(
                              report['desc'] as String,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.white60 : Colors.black54,
                                height: 1.4,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Divider(),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.trending_up, color: ThemeColors.success, size: 14),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  report['stats'] as String,
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0, curve: Curves.easeOut),
    );
  }
}
