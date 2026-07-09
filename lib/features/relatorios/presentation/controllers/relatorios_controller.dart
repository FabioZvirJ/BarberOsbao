import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:barber_osbao/packages/core/shared/state/app_state.dart';

class RelatoriosController extends Notifier<AppState<List<Map<String, dynamic>>>> {
  @override
  AppState<List<Map<String, dynamic>>> build() {
    Future.microtask(() => loadRelatorios());
    return const AppLoading();
  }

  void loadRelatorios() {
    state = const AppLoading();
    try {
      final List<Map<String, dynamic>> reportTypes = [
        {
          'id': 'rep_clientes',
          'title': 'Relatório de Clientes',
          'desc': 'Crescimento de base, taxa de retorno, histórico de visitas e fidelidade.',
          'icon': 'people',
          'stats': '1,420 clientes ativos',
        },
        {
          'id': 'rep_financeiro',
          'title': 'Relatório Financeiro',
          'desc': 'Demonstrativo de resultados (DRE), fluxo de caixa, despesas e faturamento.',
          'icon': 'monetization_on',
          'stats': '+15% de lucro líquido',
        },
        {
          'id': 'rep_produtos',
          'title': 'Relatório de Produtos',
          'desc': 'Mais vendidos, curva ABC de estoque, rotatividade de inventário e margens.',
          'icon': 'shopping_bag',
          'stats': 'Pomada Matte líder',
        },
        {
          'id': 'rep_funcionarios',
          'title': 'Relatório de Funcionários',
          'desc': 'Performance por barbeiro, faturamento individual, comissões pagas e avaliações.',
          'icon': 'badge',
          'stats': 'Arthur Santos 4.8*',
        },
        {
          'id': 'rep_servicos',
          'title': 'Relatório de Serviços',
          'desc': 'Volume de serviços vendidos, tempo médio de cadeira e ticket médio por visita.',
          'icon': 'content_cut',
          'stats': 'Corte Degradê (54% vendas)',
        },
        {
          'id': 'rep_planos',
          'title': 'Relatório de Planos',
          'desc': 'Taxa de churn, novas assinaturas, faturamento recorrente total e popularidade de planos.',
          'icon': 'card_membership',
          'stats': 'Plano Barão líder',
        },
        {
          'id': 'rep_clube',
          'title': 'Relatório de Clube',
          'desc': 'Pontos acumulados, taxa de resgate de recompensas e engajamento do programa de fidelidade.',
          'icon': 'stars',
          'stats': 'Chopp recompensa mais resgatada',
        },
      ];
      state = AppSuccess(reportTypes);
    } catch (e) {
      state = AppError(e.toString());
    }
  }
}

final relatoriosControllerProvider = NotifierProvider<RelatoriosController, AppState<List<Map<String, dynamic>>>>(
  () => RelatoriosController(),
);
