import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../design_system/layouts/app_container.dart';
import '../../../../design_system/layouts/app_section.dart';
import '../../../../design_system/molecules/app_card.dart';
import '../../../../design_system/atoms/app_button.dart';
import '../../../../design_system/atoms/app_badge.dart';
import '../../../../design_system/theme/theme_colors.dart';
import '../../application/plans_controller.dart';
import '../../../../shared/models/plan.dart';

class PlansPage extends ConsumerWidget {
  const PlansPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membershipState = ref.watch(membershipControllerProvider);
    final plansState = ref.watch(plansProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: AppContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Clube do Assinante',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 4),
                Text(
                  'Gerencie sua assinatura, veja seus benefícios ativos ou assine um novo plano.',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Active subscriber club panel
            membershipState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => const Center(child: Text('Erro ao carregar dados do clube.')),
              data: (mem) {
                if (mem == null || mem.status != 'active') {
                  return AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(Icons.star_outline, size: 48, color: ThemeColors.primary),
                        const SizedBox(height: 16),
                        const Text(
                          'Você ainda não faz parte do clube',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Assine um plano e tenha acesso a cortes ilimitados, descontos especiais e bebidas exclusivas.',
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        Icon(Icons.arrow_downward, color: ThemeColors.primary.withOpacity(0.5)),
                      ],
                    ),
                  );
                }

                return AppCard(
                  borderGlow: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const AppBadge(label: 'Assinatura Ativa', variant: AppBadgeVariant.success),
                              const SizedBox(height: 8),
                              Text(
                                mem.planName,
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                              ),
                            ],
                          ),
                          AppButton(
                            label: 'Cancelar Assinatura',
                            variant: AppButtonVariant.outline,
                            height: 40,
                            onPressed: () {
                              ref.read(membershipControllerProvider.notifier).cancel();
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Sua assinatura renova automaticamente em: ${mem.nextRenewalDate.split('-').reversed.join('/')}',
                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                      const Divider(height: 32),
                      const Text(
                        'Benefícios Ativos neste mês:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(height: 12),
                      ...mem.remainingBenefits.map((b) => Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle, color: ThemeColors.success, size: 18),
                                const SizedBox(width: 10),
                                Text(b, style: const TextStyle(fontSize: 14)),
                              ],
                            ),
                          )),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 40),

            // Plans grid
            AppSection(
              title: 'Planos Disponíveis',
              subtitle: 'Escolha a melhor assinatura para o seu estilo',
              child: plansState.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => const Center(child: Text('Erro ao carregar planos.')),
                data: (plans) => LayoutBuilder(
                  builder: (context, constraints) {
                    final crossCount = constraints.maxWidth > 800 ? 3 : 1;
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossCount,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        mainAxisExtent: 400,
                      ),
                      itemCount: plans.length,
                      itemBuilder: (context, index) {
                        final p = plans[index];
                        final isCurrent = membershipState.value?.planId == p.id && membershipState.value?.status == 'active';

                        return AppCard(
                          borderGlow: p.recommended,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (p.recommended)
                                const Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: EdgeInsets.only(bottom: 8.0),
                                    child: AppBadge(label: 'MAIS POPULAR', variant: AppBadgeVariant.primary),
                                  ),
                                ),
                              Text(p.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    'R\$ ${p.price.toStringAsFixed(2).split('.')[0]}',
                                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900),
                                  ),
                                  Text(
                                    ',${p.price.toStringAsFixed(2).split('.')[1]}',
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    ' / ${p.period}',
                                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                                  ),
                                ],
                              ),
                              const Divider(height: 24),
                              Expanded(
                                child: ListView(
                                  physics: const NeverScrollableScrollPhysics(),
                                  children: p.benefits.map((b) => Padding(
                                    padding: const EdgeInsets.only(bottom: 6.0),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.check, color: ThemeColors.primary, size: 16),
                                        const SizedBox(width: 8),
                                        Expanded(child: Text(b, style: const TextStyle(fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis)),
                                      ],
                                    ),
                                  )).toList(),
                                ),
                              ),
                              const SizedBox(height: 16),
                              if (isCurrent)
                                AppButton(
                                  label: 'Plano Atual',
                                  variant: AppButtonVariant.outline,
                                  onPressed: null,
                                )
                              else
                                AppButton(
                                  label: 'Assinar Plano',
                                  variant: p.recommended ? AppButtonVariant.primary : AppButtonVariant.secondary,
                                  onPressed: () {
                                    ref.read(membershipControllerProvider.notifier).subscribe(p.id);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Assinatura do ${p.name} realizada com sucesso!'),
                                        backgroundColor: ThemeColors.success,
                                      ),
                                    );
                                  },
                                ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
