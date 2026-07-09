import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:barber_osbao/packages/design_system/theme/theme_colors.dart';
import 'package:barber_osbao/packages/design_system/layouts/app_page.dart';
import 'package:barber_osbao/packages/design_system/layouts/app_section.dart';
import 'package:barber_osbao/packages/design_system/organisms/app_table.dart';
import 'package:barber_osbao/packages/design_system/molecules/app_filters.dart';
import 'package:barber_osbao/packages/design_system/atoms/app_avatar.dart';
import 'package:barber_osbao/packages/design_system/atoms/app_badge.dart';
import 'package:barber_osbao/packages/design_system/atoms/app_button.dart';
import 'package:barber_osbao/packages/design_system/atoms/app_status_chip.dart';
import 'package:barber_osbao/packages/core/shared/repositories/barber_repository.dart';

class FuncionariosPage extends ConsumerStatefulWidget {
  const FuncionariosPage({super.key});

  @override
  ConsumerState<FuncionariosPage> createState() => _FuncionariosPageState();
}

class _FuncionariosPageState extends ConsumerState<FuncionariosPage> {
  String _selectedStatus = 'Todos';

  @override
  Widget build(BuildContext context) {
    final barbersState = ref.watch(barbersListProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppPage(
      title: 'Funcionários',
      userName: 'Fábio Zvir',
      userAvatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&width=150',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppFilters(
                options: const ['Todos', 'Ativo', 'Inativo'],
                selectedOption: _selectedStatus,
                onSelected: (val) => setState(() => _selectedStatus = val),
              ),
              AppButton(
                label: 'Novo Funcionário',
                icon: const Icon(Icons.add, size: 16),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 32),

          AppSection(
            title: 'Equipe de Profissionais',
            subtitle: 'Lista de barbeiros, especialidades e configurações de comissão',
            child: barbersState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => const Center(child: Text('Erro ao carregar equipe.')),
              data: (list) {
                final filtered = _selectedStatus == 'Todos'
                    ? list
                    : list.where((b) {
                        final statusMap = {'Ativo': 'active', 'Inativo': 'inactive'};
                        return b.status == statusMap[_selectedStatus];
                      }).toList();

                if (filtered.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(40),
                    alignment: Alignment.center,
                    child: Text(
                      'Nenhum profissional cadastrado com este filtro.',
                      style: TextStyle(color: isDark ? Colors.white30 : Colors.grey),
                    ),
                  );
                }

                return AppTable(
                  columns: [
                    AppTableColumn(label: 'BARBEIRO', width: 220),
                    AppTableColumn(label: 'ESPECIALIDADES'),
                    AppTableColumn(label: 'COMISSÃO'),
                    AppTableColumn(label: 'AVALIAÇÃO'),
                    AppTableColumn(label: 'STATUS'),
                    AppTableColumn(label: 'AÇÕES', width: 100),
                  ],
                  rows: filtered.map((barber) {
                    return AppTableRow(
                      cells: [
                        Row(
                          children: [
                            AppAvatar(url: barber.avatarUrl, size: 36),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                barber.name,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: barber.specialties.map((s) => AppBadge(label: s)).toList(),
                        ),
                        Text(
                          '${(barber.commissionRate * 100).toStringAsFixed(0)}%',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.star, color: ThemeColors.primary, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              barber.rating.toString(),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        AppStatusChip(
                          label: barber.status == 'active' ? 'Ativo' : 'Inativo',
                          type: barber.status == 'active' ? AppStatusType.success : AppStatusType.danger,
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 18),
                              onPressed: () {},
                              tooltip: 'Editar comissão/perfil',
                            ),
                            IconButton(
                              icon: Icon(
                                barber.status == 'active' ? Icons.block : Icons.check_circle_outline,
                                size: 18,
                                color: barber.status == 'active' ? ThemeColors.danger : ThemeColors.success,
                              ),
                              onPressed: () {
                                final newStatus = barber.status == 'active' ? 'inactive' : 'active';
                                ref.read(barberRepositoryProvider).updateBarberStatus(barber.id, newStatus);
                                ref.invalidate(barbersListProvider);
                              },
                              tooltip: barber.status == 'active' ? 'Desativar' : 'Ativar',
                            ),
                          ],
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
