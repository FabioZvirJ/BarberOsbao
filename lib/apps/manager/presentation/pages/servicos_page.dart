import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:barber_osbao/packages/design_system/theme/theme_colors.dart';
import 'package:barber_osbao/packages/design_system/layouts/app_page.dart';
import 'package:barber_osbao/packages/design_system/layouts/app_section.dart';
import 'package:barber_osbao/packages/design_system/organisms/app_table.dart';
import 'package:barber_osbao/packages/design_system/molecules/app_filters.dart';
import 'package:barber_osbao/packages/design_system/atoms/app_button.dart';
import 'package:barber_osbao/packages/design_system/atoms/app_status_chip.dart';
import 'package:barber_osbao/packages/core/shared/repositories/service_repository.dart';

class ServicosPage extends ConsumerStatefulWidget {
  const ServicosPage({super.key});

  @override
  ConsumerState<ServicosPage> createState() => _ServicosPageState();
}

class _ServicosPageState extends ConsumerState<ServicosPage> {
  String _selectedCategory = 'Todos';

  @override
  Widget build(BuildContext context) {
    final servicesState = ref.watch(servicesListProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppPage(
      title: 'Serviços',
      userName: 'Fábio Zvir',
      userAvatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&width=150',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppFilters(
                options: const ['Todos', 'cabelo', 'barba', 'sobrancelha', 'combo'],
                selectedOption: _selectedCategory,
                onSelected: (val) => setState(() => _selectedCategory = val),
              ),
              AppButton(
                label: 'Novo Serviço',
                icon: const Icon(Icons.add, size: 16),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 32),

          AppSection(
            title: 'Catálogo de Serviços',
            subtitle: 'Lista de cortes, barbas, combos e serviços estéticos',
            child: servicesState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => const Center(child: Text('Erro ao carregar serviços.')),
              data: (list) {
                final filtered = _selectedCategory == 'Todos'
                    ? list
                    : list.where((s) => s.category == _selectedCategory).toList();

                if (filtered.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(40),
                    alignment: Alignment.center,
                    child: Text(
                      'Nenhum serviço encontrado.',
                      style: TextStyle(color: isDark ? Colors.white30 : Colors.grey),
                    ),
                  );
                }

                return AppTable(
                  columns: [
                    AppTableColumn(label: 'NOME'),
                    AppTableColumn(label: 'CATEGORIA'),
                    AppTableColumn(label: 'DURAÇÃO'),
                    AppTableColumn(label: 'PREÇO'),
                    AppTableColumn(label: 'STATUS'),
                    AppTableColumn(label: 'AÇÕES', width: 100),
                  ],
                  rows: filtered.map((srv) {
                    return AppTableRow(
                      cells: [
                        Text(srv.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(srv.category.toUpperCase()),
                        Text('${srv.durationMinutes} min'),
                        Text(
                          'R\$ ${srv.price.toStringAsFixed(2)}',
                          style: const TextStyle(color: ThemeColors.primary, fontWeight: FontWeight.bold),
                        ),
                        const AppStatusChip(label: 'Ativo', type: AppStatusType.success),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 18),
                              onPressed: () {},
                              tooltip: 'Editar',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 18, color: ThemeColors.danger),
                              onPressed: () {},
                              tooltip: 'Remover',
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
