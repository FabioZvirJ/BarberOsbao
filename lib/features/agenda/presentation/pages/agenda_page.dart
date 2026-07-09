import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:barber_osbao/packages/design_system/theme/theme_colors.dart';
import 'package:barber_osbao/packages/design_system/layouts/app_page.dart';
import 'package:barber_osbao/packages/design_system/layouts/app_section.dart';
import 'package:barber_osbao/packages/design_system/organisms/app_table.dart';
import 'package:barber_osbao/packages/design_system/molecules/app_filters.dart';
import 'package:barber_osbao/packages/design_system/molecules/app_search_bar.dart';
import 'package:barber_osbao/packages/design_system/atoms/app_button.dart';
import 'package:barber_osbao/packages/design_system/atoms/app_status_chip.dart';
import 'package:barber_osbao/packages/design_system/molecules/app_input.dart';
import 'package:barber_osbao/packages/core/shared/state/app_state.dart';
import 'package:barber_osbao/features/agenda/domain/models/agendamento.dart';
import 'package:barber_osbao/features/agenda/presentation/controllers/agenda_controller.dart';
import 'package:barber_osbao/features/clientes/presentation/controllers/clientes_controller.dart';
import 'package:barber_osbao/features/funcionarios/presentation/controllers/funcionarios_controller.dart';
import 'package:barber_osbao/features/servicos/presentation/controllers/servicos_controller.dart';

class AgendaPage extends ConsumerStatefulWidget {
  const AgendaPage({super.key});

  @override
  ConsumerState<AgendaPage> createState() => _AgendaPageState();
}

class _AgendaPageState extends ConsumerState<AgendaPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  
  String _selectedDateRange = 'Hoje'; // 'Hoje', 'Semana', 'Mês', 'Todos'
  String _selectedStatus = 'Todos';
  String _selectedBarber = 'Todos';
  String _calendarSelectedDate = ''; // if empty, not filtering by calendar

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(agendaControllerProvider);
    final clientsState = ref.watch(clientesControllerProvider);
    final employeesState = ref.watch(funcionariosControllerProvider);
    final servicesState = ref.watch(servicosControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Resolve list of barbers for filtering
    final List<String> barbers = ['Todos'];
    if (employeesState is AppSuccess<dynamic>) {
      final list = (employeesState as AppSuccess).data;
      for (final f in list) {
        if (f.cargo.toLowerCase().contains('barbeiro')) {
          barbers.add(f.name);
        }
      }
    }
    if (barbers.length == 1) {
      barbers.addAll(['Marcos Silva', 'Arthur Santos', 'Gabriel Neves']);
    }

    return AppPage(
      title: 'Agenda',
      userName: 'Fábio Zvir',
      userAvatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&width=150',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Filter section
          Row(
            children: [
              Expanded(
                child: AppSearchBar(
                  controller: _searchController,
                  placeholder: 'Pesquisar cliente, barbeiro ou serviço...',
                  onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
                  onClear: () => setState(() => _searchQuery = ''),
                ),
              ),
              const SizedBox(width: 16),
              AppButton(
                label: 'Novo Agendamento',
                icon: const Icon(Icons.add, size: 16),
                onPressed: () => _showFormDialog(context, clientsState, employeesState, servicesState),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth > 800;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      AppFilters(
                        options: const ['Hoje', 'Semana', 'Mês', 'Todos'],
                        selectedOption: _selectedDateRange,
                        onSelected: (val) => setState(() {
                          _selectedDateRange = val;
                          _calendarSelectedDate = ''; // Clear calendar filter
                        }),
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: const Icon(Icons.calendar_month, color: ThemeColors.primary),
                        onPressed: () => _showCalendarPicker(context),
                        tooltip: 'Escolher Data no Calendário',
                      ),
                      if (_calendarSelectedDate.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Chip(
                          backgroundColor: ThemeColors.primary.withOpacity(0.2),
                          label: Text(_calendarSelectedDate.split('-').reversed.join('/'), style: const TextStyle(color: ThemeColors.primary, fontSize: 11)),
                          onDeleted: () => setState(() {
                            _calendarSelectedDate = '';
                            _selectedDateRange = 'Hoje';
                          }),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('Barbeiro: ', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      const SizedBox(width: 6),
                      DropdownButton<String>(
                        dropdownColor: ThemeColors.darkBg,
                        value: _selectedBarber,
                        underline: const SizedBox(),
                        style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 13, fontWeight: FontWeight.bold),
                        items: barbers.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedBarber = val);
                        },
                      ),
                      const SizedBox(width: 24),
                      const Text('Status: ', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      const SizedBox(width: 6),
                      DropdownButton<String>(
                        dropdownColor: ThemeColors.darkBg,
                        value: _selectedStatus,
                        underline: const SizedBox(),
                        style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 13, fontWeight: FontWeight.bold),
                        items: const [
                          DropdownMenuItem(value: 'Todos', child: Text('Todos')),
                          DropdownMenuItem(value: 'pending', child: Text('Pendente')),
                          DropdownMenuItem(value: 'confirmed', child: Text('Confirmado')),
                          DropdownMenuItem(value: 'completed', child: Text('Finalizado')),
                          DropdownMenuItem(value: 'cancelled', child: Text('Cancelado')),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedStatus = val);
                        },
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          AppSection(
            title: 'Tabela de Agendamentos',
            subtitle: 'Visualize e gerencie os atendimentos do salão',
            child: _buildContent(state, isDark, clientsState, employeesState, servicesState),
          ),
        ],
      ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0, curve: Curves.easeOut),
    );
  }

  Widget _buildContent(
    AppState<List<Agendamento>> state,
    bool isDark,
    dynamic clientsState,
    dynamic employeesState,
    dynamic servicesState,
  ) {
    if (state is AppLoading) {
      return const Padding(
        padding: EdgeInsets.all(40.0),
        child: Center(child: CircularProgressIndicator(color: ThemeColors.primary)),
      );
    }

    if (state is AppError) {
      return Padding(
        padding: const EdgeInsets.all(40.0),
        child: Center(child: Text('Erro: ${(state as AppError).message}', style: const TextStyle(color: ThemeColors.danger))),
      );
    }

    final data = state.data ?? [];
    if (state is AppEmpty || data.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        alignment: Alignment.center,
        child: Text('Nenhum agendamento encontrado.', style: TextStyle(color: isDark ? Colors.white30 : Colors.grey)),
      );
    }

    // Apply filtering
    final filtered = data.where((apt) {
      // 1. Search Query
      final matchesSearch = apt.clientName.toLowerCase().contains(_searchQuery) ||
          apt.barberName.toLowerCase().contains(_searchQuery) ||
          apt.services.toLowerCase().contains(_searchQuery);

      // 2. Barber filter
      final matchesBarber = _selectedBarber == 'Todos' || apt.barberName == _selectedBarber;

      // 3. Status filter
      final matchesStatus = _selectedStatus == 'Todos' || apt.status == _selectedStatus;

      // 4. Date range filter
      bool matchesDate = true;
      if (_calendarSelectedDate.isNotEmpty) {
        matchesDate = apt.date == _calendarSelectedDate;
      } else {
        final today = '2026-07-09';
        if (_selectedDateRange == 'Hoje') {
          matchesDate = apt.date == today;
        } else if (_selectedDateRange == 'Semana') {
          // simple check: dates matching 2026-07-08 to 14
          matchesDate = apt.date.startsWith('2026-07-0') || apt.date.startsWith('2026-07-1');
        } else if (_selectedDateRange == 'Mês') {
          matchesDate = apt.date.startsWith('2026-07');
        }
      }

      return matchesSearch && matchesBarber && matchesStatus && matchesDate;
    }).toList();

    // Sort by date then time
    filtered.sort((a, b) {
      final dateCompare = a.date.compareTo(b.date);
      if (dateCompare != 0) return dateCompare;
      return a.time.compareTo(b.time);
    });

    if (filtered.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        alignment: Alignment.center,
        child: Text('Nenhum agendamento correspondente aos filtros.', style: TextStyle(color: isDark ? Colors.white30 : Colors.grey)),
      );
    }

    final statusLabel = {
      'pending': 'Pendente',
      'confirmed': 'Confirmado',
      'completed': 'Finalizado',
      'cancelled': 'Cancelado',
    };

    final statusType = {
      'pending': AppStatusType.info,
      'confirmed': AppStatusType.warning,
      'completed': AppStatusType.success,
      'cancelled': AppStatusType.danger,
    };

    return AppTable(
      columns: [
        AppTableColumn(label: 'DATA/HORÁRIO'),
        AppTableColumn(label: 'CLIENTE'),
        AppTableColumn(label: 'BARBEIRO'),
        AppTableColumn(label: 'SERVIÇOS'),
        AppTableColumn(label: 'VALOR'),
        AppTableColumn(label: 'STATUS'),
        AppTableColumn(label: 'AÇÕES', width: 180),
      ],
      rows: filtered.map((apt) {
        return AppTableRow(
          cells: [
            Text('${apt.date.split('-').reversed.join('/')} às ${apt.time}', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(apt.clientName),
            Text(apt.barberName),
            Text(apt.services),
            Text(
              'R\$ ${apt.price.toStringAsFixed(2)}',
              style: const TextStyle(color: ThemeColors.primary, fontWeight: FontWeight.bold),
            ),
            AppStatusChip(
              label: statusLabel[apt.status] ?? apt.status.toUpperCase(),
              type: statusType[apt.status] ?? AppStatusType.info,
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_red_eye_outlined, size: 18),
                  onPressed: () => _showDetailDialog(context, apt),
                  tooltip: 'Visualizar Detalhes',
                ),
                if (apt.status == 'pending') ...[
                  IconButton(
                    icon: const Icon(Icons.check, size: 18, color: ThemeColors.success),
                    onPressed: () => ref.read(agendaControllerProvider.notifier).updateStatus(apt.id, 'confirmed'),
                    tooltip: 'Confirmar',
                  ),
                ],
                if (apt.status == 'confirmed') ...[
                  IconButton(
                    icon: const Icon(Icons.done_all, size: 18, color: Colors.blue),
                    onPressed: () => ref.read(agendaControllerProvider.notifier).updateStatus(apt.id, 'completed'),
                    tooltip: 'Finalizar',
                  ),
                ],
                if (apt.status == 'pending' || apt.status == 'confirmed') ...[
                  IconButton(
                    icon: const Icon(Icons.cancel_outlined, size: 18, color: ThemeColors.danger),
                    onPressed: () => ref.read(agendaControllerProvider.notifier).updateStatus(apt.id, 'cancelled'),
                    tooltip: 'Cancelar',
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    onPressed: () => _showFormDialog(context, clientsState, employeesState, servicesState, apt),
                    tooltip: 'Editar',
                  ),
                ] else ...[
                  const SizedBox(width: 72),
                ],
              ],
            ),
          ],
        );
      }).toList(),
    );
  }

  void _showCalendarPicker(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2026, 7, 9),
      firstDate: DateTime(2026, 1, 1),
      lastDate: DateTime(2027, 12, 31),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: ThemeColors.primary,
              onPrimary: Colors.black,
              surface: ThemeColors.darkSurface,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      final dateStr = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      setState(() {
        _calendarSelectedDate = dateStr;
        _selectedDateRange = 'Todos'; // override quick filter
      });
    }
  }

  void _showDetailDialog(BuildContext context, Agendamento apt) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ThemeColors.darkBg,
        title: const Text('Detalhes do Agendamento', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Cliente:', apt.clientName),
            _buildDetailRow('Barbeiro:', apt.barberName),
            _buildDetailRow('Serviços:', apt.services),
            _buildDetailRow('Data:', apt.date.split('-').reversed.join('/')),
            _buildDetailRow('Horário:', apt.time),
            _buildDetailRow('Valor:', 'R\$ ${apt.price.toStringAsFixed(2)}'),
            _buildDetailRow('Status:', apt.status.toUpperCase()),
            const SizedBox(height: 12),
            const Text('Observações:', style: TextStyle(color: ThemeColors.primary, fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 4),
            Text(apt.notes.isNotEmpty ? apt.notes : 'Sem observações adicionais.', style: const TextStyle(color: Colors.white70, fontSize: 13)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Fechar', style: TextStyle(color: ThemeColors.primary)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 13))),
        ],
      ),
    );
  }

  void _showFormDialog(
    BuildContext context,
    AppState<List<dynamic>> clientsState,
    AppState<List<dynamic>> employeesState,
    AppState<List<dynamic>> servicesState, [
    Agendamento? appointment,
  ]) {
    final formKey = GlobalKey<FormState>();
    final notesController = TextEditingController(text: appointment?.notes ?? '');
    final dateController = TextEditingController(text: appointment?.date ?? '2026-07-09');
    final timeController = TextEditingController(text: appointment?.time ?? '09:00');
    final priceController = TextEditingController(text: appointment?.price.toString() ?? '50.00');

    // Extract dynamic dropdown items from controllers
    final List<String> clients = [];
    if (clientsState is AppSuccess<dynamic> && clientsState.data != null) {
      clients.addAll(clientsState.data!.map((c) => c.name as String).cast<String>());
    }
    if (clients.isEmpty) clients.add('João Silva');

    final List<String> barbers = [];
    if (employeesState is AppSuccess<dynamic> && employeesState.data != null) {
      barbers.addAll(employeesState.data!
          .where((f) => f.cargo.toLowerCase().contains('barbeiro'))
          .map((f) => f.name as String)
          .cast<String>());
    }
    if (barbers.isEmpty) barbers.addAll(['Marcos Silva', 'Arthur Santos', 'Gabriel Neves']);

    final List<String> services = [];
    if (servicesState is AppSuccess<dynamic> && servicesState.data != null) {
      services.addAll(servicesState.data!.map((s) => s.name as String).cast<String>());
    }
    if (services.isEmpty) services.addAll(['Corte de Cabelo', 'Barba Completa', 'Combo Cabelo + Barba']);

    String selectedClient = appointment?.clientName ?? clients[0];
    String selectedBarber = appointment?.barberName ?? barbers[0];
    String selectedService = appointment?.services.split(',')[0] ?? services[0];
    String status = appointment?.status ?? 'pending';

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: ThemeColors.darkBg,
              title: Text(appointment == null ? 'Novo Agendamento' : 'Editar Agendamento', style: const TextStyle(color: Colors.white)),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        dropdownColor: ThemeColors.darkBg,
                        value: selectedClient,
                        decoration: const InputDecoration(
                          labelText: 'Cliente',
                          labelStyle: TextStyle(color: Colors.white70),
                          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
                        ),
                        style: const TextStyle(color: Colors.white),
                        items: clients.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => selectedClient = val);
                        },
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              dropdownColor: ThemeColors.darkBg,
                              value: selectedBarber,
                              decoration: const InputDecoration(
                                labelText: 'Barbeiro',
                                labelStyle: TextStyle(color: Colors.white70),
                                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
                              ),
                              style: const TextStyle(color: Colors.white),
                              items: barbers.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => selectedBarber = val);
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              dropdownColor: ThemeColors.darkBg,
                              value: selectedService,
                              decoration: const InputDecoration(
                                labelText: 'Serviço Principal',
                                labelStyle: TextStyle(color: Colors.white70),
                                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
                              ),
                              style: const TextStyle(color: Colors.white),
                              items: services.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() {
                                    selectedService = val;
                                    // Try updating price dynamically if matches mock services
                                    if (val.contains('Combo')) {
                                      priceController.text = '70.00';
                                    } else if (val.contains('Barba')) {
                                      priceController.text = '35.00';
                                    } else {
                                      priceController.text = '45.00';
                                    }
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: AppInput(
                              label: 'Data (AAAA-MM-DD)',
                              placeholder: 'Ex: 2026-07-09',
                              controller: dateController,
                              validator: (val) => val == null || val.isEmpty ? 'Data obrigatória' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppInput(
                              label: 'Horário (HH:MM)',
                              placeholder: 'Ex: 14:30',
                              controller: timeController,
                              validator: (val) => val == null || val.isEmpty ? 'Horário obrigatório' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: AppInput(
                              label: 'Valor Cobrado (R\$)',
                              placeholder: 'Ex: 80.00',
                              controller: priceController,
                              keyboardType: TextInputType.number,
                              validator: (val) => val == null || val.isEmpty ? 'Obrigatório' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              dropdownColor: ThemeColors.darkBg,
                              value: status,
                              decoration: const InputDecoration(
                                labelText: 'Status',
                                labelStyle: TextStyle(color: Colors.white70),
                                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
                              ),
                              style: const TextStyle(color: Colors.white),
                              items: const [
                                DropdownMenuItem(value: 'pending', child: Text('Pendente')),
                                DropdownMenuItem(value: 'confirmed', child: Text('Confirmado')),
                                DropdownMenuItem(value: 'completed', child: Text('Finalizado')),
                                DropdownMenuItem(value: 'cancelled', child: Text('Cancelado')),
                              ],
                              onChanged: (val) {
                                if (val != null) setState(() => status = val);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      AppInput(
                        label: 'Observações do Agendamento',
                        placeholder: 'Ex: Cabelo molhado, deseja degradê baixo...',
                        controller: notesController,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: ThemeColors.primary),
                  onPressed: () {
                    if (formKey.currentState?.validate() ?? false) {
                      final newApt = Agendamento(
                        id: appointment?.id ?? '',
                        clientName: selectedClient,
                        barberName: selectedBarber,
                        services: selectedService,
                        date: dateController.text.trim(),
                        time: timeController.text.trim(),
                        price: double.parse(priceController.text.trim()),
                        status: status,
                        notes: notesController.text.trim(),
                      );

                      if (appointment == null) {
                        ref.read(agendaControllerProvider.notifier).addAgendamento(newApt);
                      } else {
                        ref.read(agendaControllerProvider.notifier).editAgendamento(newApt);
                      }
                      Navigator.of(ctx).pop();
                    }
                  },
                  child: const Text('Salvar', style: TextStyle(color: Colors.black)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
