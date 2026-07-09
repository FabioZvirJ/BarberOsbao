import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:barber_osbao/packages/design_system/theme/theme_colors.dart';
import 'package:barber_osbao/packages/design_system/layouts/app_page.dart';
import 'package:barber_osbao/packages/design_system/layouts/app_section.dart';
import 'package:barber_osbao/packages/design_system/organisms/app_table.dart';
import 'package:barber_osbao/packages/design_system/molecules/app_filters.dart';
import 'package:barber_osbao/packages/design_system/atoms/app_status_chip.dart';
import 'package:barber_osbao/packages/core/shared/appointments/application/appointment_controller.dart';

class AgendaPage extends ConsumerStatefulWidget {
  const AgendaPage({super.key});

  @override
  ConsumerState<AgendaPage> createState() => _AgendaPageState();
}

class _AgendaPageState extends ConsumerState<AgendaPage> {
  String _selectedBarber = 'Todos';

  @override
  Widget build(BuildContext context) {
    final appointmentsState = ref.watch(appointmentsControllerProvider);
    final barbersState = ref.watch(barbersProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppPage(
      title: 'Agenda',
      userName: 'Fábio Zvir',
      userAvatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&width=150',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Filter Row
          barbersState.maybeWhen(
            data: (barbers) {
              final options = ['Todos', ...barbers.map((b) => b.name)];
              return AppSection(
                title: 'Filtrar por Barbeiro',
                child: AppFilters(
                  options: options,
                  selectedOption: _selectedBarber,
                  onSelected: (val) => setState(() => _selectedBarber = val),
                ),
              );
            },
            orElse: () => const SizedBox.shrink(),
          ),
          const SizedBox(height: 32),

          AppSection(
            title: 'Lista de Agendamentos',
            subtitle: 'Visualize e gerencie os horários dos clientes',
            child: appointmentsState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => const Center(child: Text('Erro ao carregar agendamentos.')),
              data: (list) {
                final filteredList = _selectedBarber == 'Todos'
                    ? list
                    : list.where((a) => a.barberName == _selectedBarber).toList();

                if (filteredList.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(40),
                    alignment: Alignment.center,
                    child: Text(
                      'Nenhum agendamento encontrado.',
                      style: TextStyle(color: isDark ? Colors.white30 : Colors.grey),
                    ),
                  );
                }

                return AppTable(
                  columns: [
                    AppTableColumn(label: 'CLIENTE'),
                    AppTableColumn(label: 'BARBEIRO'),
                    AppTableColumn(label: 'SERVIÇO'),
                    AppTableColumn(label: 'DATA/HORA'),
                    AppTableColumn(label: 'VALOR'),
                    AppTableColumn(label: 'STATUS'),
                    AppTableColumn(label: 'AÇÕES', width: 100),
                  ],
                  rows: filteredList.map((apt) {
                    return AppTableRow(
                      cells: [
                        Text(
                          'Cliente #${apt.id.substring(0, 4)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(apt.barberName),
                        Text(apt.services.map((s) => s.name).join(", ")),
                        Text('${apt.date.split('-').reversed.join('/')} às ${apt.time}'),
                        Text(
                          'R\$ ${apt.totalValue.toStringAsFixed(2)}',
                          style: const TextStyle(color: ThemeColors.primary, fontWeight: FontWeight.bold),
                        ),
                        AppStatusChip(
                          label: apt.status == 'confirmed' ? 'Confirmado' : (apt.status == 'completed' ? 'Concluido' : 'Cancelado'),
                          type: apt.status == 'confirmed'
                              ? AppStatusType.warning
                              : (apt.status == 'completed' ? AppStatusType.success : AppStatusType.danger),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (apt.status == 'confirmed') ...[
                              IconButton(
                                icon: const Icon(Icons.check_circle_outline, color: ThemeColors.success, size: 20),
                                onPressed: () {
                                  // Update state or action
                                },
                                tooltip: 'Concluir',
                              ),
                              IconButton(
                                icon: const Icon(Icons.cancel_outlined, color: ThemeColors.danger, size: 20),
                                onPressed: () {
                                  ref.read(appointmentsControllerProvider.notifier).cancelAppointment(apt.id);
                                },
                                tooltip: 'Cancelar',
                              ),
                            ] else ...[
                              const Text('-', style: TextStyle(color: Colors.grey)),
                            ],
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
