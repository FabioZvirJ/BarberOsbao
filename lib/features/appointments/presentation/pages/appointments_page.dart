import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../design_system/layouts/app_container.dart';
import '../../../../design_system/layouts/app_section.dart';
import '../../../../design_system/organisms/app_table.dart';
import '../../../../design_system/organisms/app_dialog.dart';
import '../../../../design_system/atoms/app_button.dart';
import '../../../../design_system/atoms/app_badge.dart';
import '../../../../design_system/theme/theme_colors.dart';
import '../../../../shared/models/appointment.dart';
import '../../application/appointment_controller.dart';
import '../widgets/booking_wizard.dart';
import '../../../../design_system/organisms/app_modal.dart';

class AppointmentsPage extends ConsumerStatefulWidget {
  const AppointmentsPage({super.key});

  @override
  ConsumerState<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends ConsumerState<AppointmentsPage> {
  String _filterStatus = 'todos'; // 'todos', 'confirmed', 'completed', 'cancelled'
  String _searchQuery = '';

  void _openBookingWizard() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AppModal(
        title: 'Agendar Horário',
        child: BookingWizard(),
      ),
    );
  }

  void _confirmCancel(String id) {
    showDialog(
      context: context,
      builder: (context) => AppDialog(
        title: 'Cancelar Agendamento',
        content: 'Tem certeza que deseja cancelar este agendamento?',
        confirmLabel: 'Sim, Cancelar',
        onConfirm: () {
          ref.read(appointmentsControllerProvider.notifier).cancelAppointment(id);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appointmentsState = ref.watch(appointmentsControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: AppContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Agendamentos',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Gerencie seus agendamentos passados e futuros.',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
                AppButton(
                  label: 'Novo Agendamento',
                  onPressed: _openBookingWizard,
                  icon: const Icon(Icons.add, size: 16),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Controls & Filters Row
            Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterTab('Todos', 'todos'),
                        _buildFilterTab('Próximos', 'confirmed'),
                        _buildFilterTab('Concluídos', 'completed'),
                        _buildFilterTab('Cancelados', 'cancelled'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 240,
                  height: 40,
                  child: TextField(
                    onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
                    decoration: InputDecoration(
                      hintText: 'Buscar por barbeiro...',
                      prefixIcon: const Icon(Icons.search, size: 16, color: Colors.grey),
                      filled: true,
                      fillColor: isDark ? ThemeColors.darkSurface : Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(100),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Table list
            appointmentsState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => const Center(child: Text('Erro ao carregar agendamentos.')),
              data: (apts) {
                // Apply filters
                final filtered = apts.where((apt) {
                  final matchesStatus = _filterStatus == 'todos' || apt.status == _filterStatus;
                  final matchesSearch = apt.barberName.toLowerCase().contains(_searchQuery);
                  return matchesStatus && matchesSearch;
                }).toList();

                if (filtered.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(40),
                    alignment: Alignment.center,
                    child: const Column(
                      children: [
                        Icon(Icons.calendar_today, size: 40, color: Colors.grey),
                        SizedBox(height: 12),
                        Text('Nenhum agendamento encontrado.', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                return AppTable(
                  columns: [
                    AppTableColumn(label: 'BARBEIRO'),
                    AppTableColumn(label: 'SERVIÇOS'),
                    AppTableColumn(label: 'DATA & HORA'),
                    AppTableColumn(label: 'VALOR'),
                    AppTableColumn(label: 'STATUS'),
                    AppTableColumn(label: 'AÇÕES', width: 120),
                  ],
                  rows: filtered.map((apt) {
                    AppBadgeVariant badgeVar;
                    String statusLabel;
                    switch (apt.status) {
                      case 'confirmed':
                        badgeVar = AppBadgeVariant.success;
                        statusLabel = 'Confirmado';
                        break;
                      case 'completed':
                        badgeVar = AppBadgeVariant.primary;
                        statusLabel = 'Concluído';
                        break;
                      case 'cancelled':
                        badgeVar = AppBadgeVariant.danger;
                        statusLabel = 'Cancelado';
                        break;
                      default:
                        badgeVar = AppBadgeVariant.neutral;
                        statusLabel = apt.status;
                    }

                    return AppTableRow(
                      cells: [
                        Text(apt.barberName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(apt.services.map((s) => s.name).join(', '), maxLines: 1, overflow: TextOverflow.ellipsis),
                        Text('${apt.date.split('-').reversed.join('/')} às ${apt.time}'),
                        Text('R\$ ${apt.totalValue.toStringAsFixed(2)}'),
                        AppBadge(label: statusLabel, variant: badgeVar),
                        if (apt.status == 'confirmed')
                          TextButton(
                            onPressed: () => _confirmCancel(apt.id),
                            child: const Text('Cancelar', style: TextStyle(color: Colors.red, fontSize: 13)),
                          )
                        else
                          const Text('-', style: TextStyle(color: Colors.grey)),
                      ],
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTab(String label, String status) {
    final isSelected = _filterStatus == status;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: AppButton(
        label: label,
        variant: isSelected ? AppButtonVariant.primary : AppButtonVariant.outline,
        height: 36,
        onPressed: () => setState(() => _filterStatus = status),
      ),
    );
  }
}
