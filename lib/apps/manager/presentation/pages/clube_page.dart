import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:barber_osbao/packages/design_system/theme/theme_colors.dart';
import 'package:barber_osbao/packages/design_system/layouts/app_page.dart';
import 'package:barber_osbao/packages/design_system/layouts/app_section.dart';
import 'package:barber_osbao/packages/design_system/organisms/app_table.dart';
import 'package:barber_osbao/packages/design_system/molecules/app_card.dart';
import 'package:barber_osbao/packages/design_system/atoms/app_button.dart';
import 'package:barber_osbao/packages/design_system/atoms/app_status_chip.dart';
import 'package:barber_osbao/packages/core/shared/repositories/club_repository.dart';

class ClubePage extends ConsumerWidget {
  const ClubePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final couponsState = ref.watch(clubCouponsProvider);
    final settingsState = ref.watch(clubSettingsProvider);

    return AppPage(
      title: 'Clube',
      userName: 'Fábio Zvir',
      userAvatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&width=150',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Statistics and Settings Row
          settingsState.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => const Center(child: Text('Erro ao carregar configurações.')),
            data: (settings) {
              final rules = settings['rules'] as List<dynamic>;
              final activeMembers = settings['activeMembersCount'] as int;

              return LayoutBuilder(
                builder: (context, constraints) {
                  final isDesktop = constraints.maxWidth > 800;
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'CLUBE FIDELIDADE',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '$activeMembers',
                                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                              ),
                              const Text('Clientes participando ativamente do clube', style: TextStyle(color: Colors.grey, fontSize: 12)),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  const Icon(Icons.stars, color: ThemeColors.primary),
                                  const SizedBox(width: 8),
                                  Text(
                                    '1 Real gasto = ${settings['pointsPerReal']} ponto(s)',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (isDesktop) ...[
                        const SizedBox(width: 24),
                        Expanded(
                          child: AppCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'REGRAS DE RESGATE',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                                ),
                                const SizedBox(height: 12),
                                ...rules.map((rule) => Padding(
                                  padding: const EdgeInsets.only(bottom: 6.0),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.arrow_right, color: ThemeColors.primary),
                                      const SizedBox(width: 4),
                                      Expanded(child: Text(rule as String, style: const TextStyle(fontSize: 13))),
                                    ],
                                  ),
                                )).toList(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  );
                },
              );
            },
          ),
          const SizedBox(height: 32),

          // Coupons section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Cupons de Desconto',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              AppButton(
                label: 'Novo Cupom',
                icon: const Icon(Icons.add, size: 16),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 16),
          couponsState.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => const Center(child: Text('Erro ao carregar cupons.')),
            data: (list) {
              return AppTable(
                columns: [
                  AppTableColumn(label: 'CÓDIGO'),
                  AppTableColumn(label: 'DESCONTO'),
                  AppTableColumn(label: 'TIPO'),
                  AppTableColumn(label: 'EXPIRAÇÃO'),
                  AppTableColumn(label: 'STATUS'),
                  AppTableColumn(label: 'AÇÕES', width: 100),
                ],
                rows: list.map((coupon) {
                  return AppTableRow(
                    cells: [
                      Text(coupon.code, style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                      Text(
                        '${coupon.discountPercentage.toStringAsFixed(0)}%',
                        style: const TextStyle(color: ThemeColors.primary, fontWeight: FontWeight.bold),
                      ),
                      const Text('Percentual'),
                      Text(coupon.expirationDate.split('-').reversed.join('/')),
                      AppStatusChip(
                        label: coupon.active ? 'Ativo' : 'Expirado',
                        type: coupon.active ? AppStatusType.success : AppStatusType.danger,
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 18, color: ThemeColors.danger),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ],
                  );
                }).toList(),
              );
            },
          ),
        ],
      ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0, curve: Curves.easeOut),
    );
  }
}
