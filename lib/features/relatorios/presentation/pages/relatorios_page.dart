import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:barber_osbao/packages/design_system/theme/theme_colors.dart';
import 'package:barber_osbao/packages/design_system/layouts/app_page.dart';
import 'package:barber_osbao/packages/design_system/layouts/app_section.dart';
import 'package:barber_osbao/packages/design_system/molecules/app_card.dart';
import 'package:barber_osbao/packages/core/shared/state/app_state.dart';
import 'package:barber_osbao/features/relatorios/presentation/controllers/relatorios_controller.dart';

class RelatoriosPage extends ConsumerWidget {
  const RelatoriosPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(relatoriosControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppPage(
      title: 'Relatórios',
      userName: 'Fábio Zvir',
      userAvatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&width=150',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSection(
            title: 'Centro de Relatórios Gerenciais',
            subtitle: 'Gere relatórios analíticos completos e exporte em formatos Excel (XLSX) ou PDF',
            child: _buildContent(context, state, isDark),
          ),
        ],
      ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0, curve: Curves.easeOut),
    );
  }

  Widget _buildContent(BuildContext context, AppState<List<Map<String, dynamic>>> state, bool isDark) {
    if (state is AppLoading) {
      return const Padding(
        padding: EdgeInsets.all(40.0),
        child: Center(child: CircularProgressIndicator(color: ThemeColors.primary)),
      );
    }
    if (state is AppError) {
      return Center(child: Text('Erro: ${(state as AppError).message}', style: const TextStyle(color: ThemeColors.danger)));
    }

    final reports = state.data ?? [];

    final iconMap = {
      'people': Icons.people_outline,
      'monetization_on': Icons.monetization_on_outlined,
      'shopping_bag': Icons.shopping_bag_outlined,
      'badge': Icons.badge_outlined,
      'content_cut': Icons.content_cut_outlined,
      'card_membership': Icons.card_membership_outlined,
      'stars': Icons.stars_outlined,
    };

    final colorMap = {
      'rep_clientes': Colors.blue,
      'rep_financeiro': ThemeColors.success,
      'rep_produtos': Colors.purple,
      'rep_funcionarios': ThemeColors.warning,
      'rep_servicos': Colors.red,
      'rep_planos': Colors.teal,
      'rep_clube': Colors.orange,
    };

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossCount = constraints.maxWidth > 960 ? 3 : (constraints.maxWidth > 600 ? 2 : 1);
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossCount,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            mainAxisExtent: 220,
          ),
          itemCount: reports.length,
          itemBuilder: (context, index) {
            final report = reports[index];
            final id = report['id'] as String;
            final color = colorMap[id] ?? ThemeColors.primary;
            final icon = iconMap[report['icon']] ?? Icons.bar_chart;

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
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          icon,
                          color: color,
                          size: 24,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.picture_as_pdf, size: 20, color: Colors.red),
                            onPressed: () => _exportMock(context, report['title'] as String, 'PDF'),
                            tooltip: 'Exportar PDF',
                          ),
                          IconButton(
                            icon: const Icon(Icons.download, size: 20),
                            onPressed: () => _exportMock(context, report['title'] as String, 'Excel (XLSX)'),
                            tooltip: 'Exportar Excel',
                          ),
                        ],
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
    );
  }

  void _exportMock(BuildContext context, String title, String format) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.of(ctx).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Download concluído: $title.$format'),
              backgroundColor: ThemeColors.success,
            ),
          );
        });

        return AlertDialog(
          backgroundColor: ThemeColors.darkBg,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: ThemeColors.primary),
              const SizedBox(height: 16),
              Text(
                'Compilando base de dados para $format...',
                style: const TextStyle(color: Colors.white, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }
}
