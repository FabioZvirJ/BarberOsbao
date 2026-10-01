import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:barber_osbao/packages/design_system/theme/theme_colors.dart';
import 'package:barber_osbao/packages/design_system/theme/app_breakpoints.dart';
import 'package:barber_osbao/packages/design_system/layouts/app_page.dart';
import 'package:barber_osbao/packages/design_system/layouts/app_section.dart';
import 'package:barber_osbao/packages/design_system/organisms/app_table.dart';
import 'package:barber_osbao/packages/design_system/molecules/app_filters.dart';
import 'package:barber_osbao/packages/design_system/molecules/app_search_bar.dart';
import 'package:barber_osbao/packages/design_system/atoms/app_button.dart';
import 'package:barber_osbao/packages/design_system/atoms/app_status_chip.dart';
import 'package:barber_osbao/packages/design_system/molecules/app_input.dart';
import 'package:barber_osbao/packages/design_system/organisms/app_dialog.dart';
import 'package:barber_osbao/packages/core/shared/state/app_state.dart';
import 'package:barber_osbao/features/agenda/domain/models/agendamento.dart';
import 'package:barber_osbao/features/agenda/presentation/controllers/agenda_controller.dart';
import 'package:barber_osbao/features/clientes/presentation/controllers/clientes_controller.dart';
import 'package:barber_osbao/features/funcionarios/presentation/controllers/funcionarios_controller.dart';
import 'package:barber_osbao/features/servicos/presentation/controllers/servicos_controller.dart';
import 'package:barber_osbao/features/configuracoes/presentation/controllers/configuracoes_controller.dart';
import 'package:barber_osbao/features/financeiro/domain/models/transacao.dart';
import 'package:barber_osbao/features/financeiro/presentation/controllers/financeiro_controller.dart';
import 'package:barber_osbao/packages/core/utils/app_formatters.dart';
import 'package:barber_osbao/packages/core/utils/app_masks.dart';

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
    final isMobile = AppBreakpoints.isMobile(context);

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
      userAvatarUrl:
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&width=150',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Responsive toolbar: row on tablet+, column on mobile
          if (isMobile) ...[
            AppSearchBar(
              controller: _searchController,
              placeholder: 'Pesquisar cliente, barbeiro ou serviço...',
              onChanged: (val) =>
                  setState(() => _searchQuery = val.toLowerCase()),
              onClear: () => setState(() => _searchQuery = ''),
            ),
            const SizedBox(height: 10),
            AppButton(
              label: 'Novo Agendamento',
              icon: const Icon(Icons.add, size: 16),
              onPressed: () => _showFormDialog(
                context,
                clientsState,
                employeesState,
                servicesState,
              ),
            ),
          ] else
            Row(
              children: [
                Expanded(
                  child: AppSearchBar(
                    controller: _searchController,
                    placeholder: 'Pesquisar cliente, barbeiro ou serviço...',
                    onChanged: (val) =>
                        setState(() => _searchQuery = val.toLowerCase()),
                    onClear: () => setState(() => _searchQuery = ''),
                  ),
                ),
                const SizedBox(width: 16),
                AppButton(
                  label: 'Novo Agendamento',
                  icon: const Icon(Icons.add, size: 16),
                  onPressed: () => _showFormDialog(
                    context,
                    clientsState,
                    employeesState,
                    servicesState,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 16),
          // Secondary filters
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  AppFilters(
                    options: const ['Hoje', 'Amanhã', 'Esta Semana', 'Todos'],
                    selectedOption: _selectedDateRange,
                    onSelected: (val) => setState(() {
                      _selectedDateRange = val;
                      _calendarSelectedDate = ''; // Clear calendar filter
                    }),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.calendar_month,
                      color: ThemeColors.primary,
                    ),
                    onPressed: () => _showCalendarPicker(context),
                    tooltip: 'Escolher Data no Calendário',
                  ),
                  if (_calendarSelectedDate.isNotEmpty)
                    Chip(
                      backgroundColor: ThemeColors.primary.withValues(
                        alpha: 0.2,
                      ),
                      label: Text(
                        _calendarSelectedDate.split('-').reversed.join('/'),
                        style: const TextStyle(
                          color: ThemeColors.primary,
                          fontSize: 11,
                        ),
                      ),
                      onDeleted: () => setState(() {
                        _calendarSelectedDate = '';
                        _selectedDateRange = 'Hoje';
                      }),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 16,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Barbeiro: ',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      const SizedBox(width: 6),
                      DropdownButton<String>(
                        dropdownColor: isDark
                            ? ThemeColors.darkSurface
                            : Colors.white,
                        value: _selectedBarber,
                        underline: const SizedBox(),
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                        items: barbers
                            .map(
                              (b) => DropdownMenuItem(value: b, child: Text(b)),
                            )
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedBarber = val);
                          }
                        },
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Status: ',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      const SizedBox(width: 6),
                      DropdownButton<String>(
                        dropdownColor: isDark
                            ? ThemeColors.darkSurface
                            : Colors.white,
                        value: _selectedStatus,
                        underline: const SizedBox(),
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Todos',
                            child: Text('Todos'),
                          ),
                          DropdownMenuItem(
                            value: 'pending',
                            child: Text('Pendente'),
                          ),
                          DropdownMenuItem(
                            value: 'confirmed',
                            child: Text('Confirmado'),
                          ),
                          DropdownMenuItem(
                            value: 'completed',
                            child: Text('Finalizado'),
                          ),
                          DropdownMenuItem(
                            value: 'cancelled',
                            child: Text('Cancelado'),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedStatus = val);
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          AppSection(
            title: 'Tabela de Agendamentos',
            subtitle: 'Visualize e gerencie os atendimentos do salão',
            child: _buildContent(
              state,
              isDark,
              clientsState,
              employeesState,
              servicesState,
            ),
          ),
        ],
      ),
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
        child: Center(
          child: CircularProgressIndicator(color: ThemeColors.primary),
        ),
      );
    }

    if (state is AppError) {
      return Padding(
        padding: const EdgeInsets.all(40.0),
        child: Center(
          child: Text(
            'Erro: ${(state as AppError).message}',
            style: const TextStyle(color: ThemeColors.danger),
          ),
        ),
      );
    }

    final data = state.data ?? [];
    if (state is AppEmpty || data.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        alignment: Alignment.center,
        child: Text(
          'Nenhum agendamento encontrado.',
          style: TextStyle(color: isDark ? Colors.white30 : Colors.grey),
        ),
      );
    }

    // Apply filtering
    final filtered = data.where((apt) {
      // 1. Search Query
      final matchesSearch =
          apt.clientName.toLowerCase().contains(_searchQuery) ||
          apt.barberName.toLowerCase().contains(_searchQuery) ||
          apt.services.toLowerCase().contains(_searchQuery);

      // 2. Barber filter
      final matchesBarber =
          _selectedBarber == 'Todos' || apt.barberName == _selectedBarber;

      // 3. Status filter
      final matchesStatus =
          _selectedStatus == 'Todos' || apt.status == _selectedStatus;

      // 4. Date range filter
      bool matchesDate = true;
      if (_calendarSelectedDate.isNotEmpty) {
        matchesDate = apt.date == _calendarSelectedDate;
      } else {
        final now = DateTime.now();
        final todayStr =
            '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
        final tomorrow = now.add(const Duration(days: 1));
        final tomorrowStr =
            '${tomorrow.year}-${tomorrow.month.toString().padLeft(2, '0')}-${tomorrow.day.toString().padLeft(2, '0')}';

        if (_selectedDateRange == 'Hoje') {
          matchesDate = apt.date == todayStr || apt.date == '2026-07-09';
        } else if (_selectedDateRange == 'Amanhã') {
          matchesDate = apt.date == tomorrowStr || apt.date == '2026-07-10';
        } else if (_selectedDateRange == 'Esta Semana') {
          matchesDate = apt.date.startsWith('2026-07-0') ||
              apt.date.startsWith('2026-07-1') ||
              apt.date.startsWith(todayStr.substring(0, 7));
        } else if (_selectedDateRange == 'Todos') {
          matchesDate = true;
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
        child: Text(
          'Nenhum agendamento correspondente aos filtros.',
          style: TextStyle(color: isDark ? Colors.white30 : Colors.grey),
        ),
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
      minWidth: 900,
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
            Text(
              '${AppFormatters.formatDate(apt.date)} às ${apt.time}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(apt.clientName),
            Text(apt.barberName),
            Text(apt.services),
            Text(
              AppFormatters.formatCurrency(apt.price),
              style: const TextStyle(
                color: ThemeColors.primary,
                fontWeight: FontWeight.bold,
              ),
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
                    icon: const Icon(
                      Icons.check,
                      size: 18,
                      color: ThemeColors.success,
                    ),
                    onPressed: () => ref
                        .read(agendaControllerProvider.notifier)
                        .updateStatus(apt.id, 'confirmed'),
                    tooltip: 'Confirmar',
                  ),
                ],
                if (apt.status == 'confirmed') ...[
                  IconButton(
                    icon: const Icon(
                      Icons.done_all,
                      size: 18,
                      color: Colors.blue,
                    ),
                    onPressed: () => _confirmFinish(context, apt),
                    tooltip: 'Finalizar',
                  ),
                ],
                if (apt.status == 'pending' || apt.status == 'confirmed') ...[
                  IconButton(
                    icon: const Icon(
                      Icons.cancel_outlined,
                      size: 18,
                      color: ThemeColors.danger,
                    ),
                    onPressed: () => _confirmCancel(context, apt),
                    tooltip: 'Cancelar',
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    onPressed: () => _showFormDialog(
                      context,
                      clientsState,
                      employeesState,
                      servicesState,
                      apt,
                    ),
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

  void _confirmFinish(BuildContext context, Agendamento apt) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    String selectedPaymentMethod = 'PIX';
    bool launchInCashRegister = true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: isDark ? ThemeColors.darkSurface : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ThemeColors.success.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  color: ThemeColors.success,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Finalizar Atendimento',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.04)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Cliente:',
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                          Text(
                            apt.clientName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Serviço:',
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                          Flexible(
                            child: Text(
                              apt.services,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total a Receber:',
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                          Text(
                            AppFormatters.formatCurrency(apt.price),
                            style: const TextStyle(
                              color: ThemeColors.success,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Forma de Pagamento:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    'PIX',
                    'Dinheiro',
                    'Cartão Crédito',
                    'Cartão Débito',
                  ].map((method) {
                    final isSel = selectedPaymentMethod == method;
                    return ChoiceChip(
                      label: Text(method),
                      selected: isSel,
                      selectedColor: ThemeColors.primary,
                      labelStyle: TextStyle(
                        color: isSel
                            ? Colors.black
                            : (isDark ? Colors.white70 : Colors.black87),
                        fontWeight:
                            isSel ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12,
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          setDialogState(() => selectedPaymentMethod = method);
                        }
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  value: launchInCashRegister,
                  activeColor: ThemeColors.primary,
                  title: const Text(
                    'Lançar no Caixa / Financeiro',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text(
                    'Gera receita de serviço automaticamente',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                  onChanged: (val) {
                    setDialogState(() => launchInCashRegister = val ?? true);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(
                'Voltar',
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeColors.success,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                ref
                    .read(agendaControllerProvider.notifier)
                    .updateStatus(apt.id, 'completed');

                if (launchInCashRegister) {
                  final now = DateTime.now();
                  final dateStr =
                      '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
                  ref.read(transacoesControllerProvider.notifier).addTransacao(
                        TransacaoFinanceira(
                          id: '',
                          type: 'income',
                          description: '${apt.services} - ${apt.clientName}',
                          amount: apt.price,
                          category: 'Serviço',
                          date: dateStr,
                          paymentMethod: selectedPaymentMethod,
                          status: 'paid',
                        ),
                      );
                }

                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      launchInCashRegister
                          ? 'Atendimento finalizado e ${AppFormatters.formatCurrency(apt.price)} ($selectedPaymentMethod) lançado no Caixa!'
                          : 'Atendimento marcado como finalizado!',
                    ),
                    backgroundColor: ThemeColors.success,
                  ),
                );
              },
              child: const Text(
                'Finalizar & Concluir',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmCancel(BuildContext context, Agendamento apt) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? ThemeColors.darkSurface : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: const Text(
          'Cancelar Agendamento',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Tem certeza que deseja cancelar o agendamento de "${apt.clientName}" às ${apt.time}? O horário do profissional será liberado.',
          style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Voltar',
              style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeColors.danger,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            onPressed: () {
              ref
                  .read(agendaControllerProvider.notifier)
                  .updateStatus(apt.id, 'cancelled');
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Agendamento cancelado com sucesso.'),
                  backgroundColor: ThemeColors.danger,
                ),
              );
            },
            child: const Text('Sim, Cancelar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showCalendarPicker(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      locale: const Locale('pt', 'BR'),
      initialDate: DateTime.now(),
      firstDate: DateTime(2025, 1, 1),
      lastDate: DateTime(2027, 12, 31),
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? const ColorScheme.dark(
                    primary: ThemeColors.primary,
                    onPrimary: Colors.black,
                    surface: ThemeColors.darkSurface,
                    onSurface: Colors.white,
                  )
                : const ColorScheme.light(
                    primary: ThemeColors.primary,
                    onPrimary: Colors.white,
                  ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      final dateStr =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      setState(() {
        _calendarSelectedDate = dateStr;
        _selectedDateRange = 'Todos'; // override quick filter
      });
    }
  }

  void _showDetailDialog(BuildContext context, Agendamento apt) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? ThemeColors.darkSurface : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: Text(
          'Detalhes do Agendamento',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Cliente:', apt.clientName, isDark),
            _buildDetailRow('Barbeiro:', apt.barberName, isDark),
            _buildDetailRow('Serviços:', apt.services, isDark),
            _buildDetailRow(
              'Data:',
              apt.date.split('-').reversed.join('/'),
              isDark,
            ),
            _buildDetailRow('Horário:', apt.time, isDark),
            _buildDetailRow(
              'Valor:',
              'R\$ ${apt.price.toStringAsFixed(2)}',
              isDark,
            ),
            _buildDetailRow('Status:', apt.status.toUpperCase(), isDark),
            const SizedBox(height: 12),
            const Text(
              'Observações:',
              style: TextStyle(
                color: ThemeColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              apt.notes.isNotEmpty ? apt.notes : 'Sem observações adicionais.',
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black87,
                fontSize: 13,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Fechar',
              style: TextStyle(color: ThemeColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, [bool isDark = true]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
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
    showDialog(
      context: context,
      builder: (ctx) => AppointmentFormDialog(
        clientsState: clientsState,
        employeesState: employeesState,
        servicesState: servicesState,
        appointment: appointment,
      ),
    );
  }
}

class AppointmentFormDialog extends ConsumerStatefulWidget {
  final AppState<List<dynamic>>? clientsState;
  final AppState<List<dynamic>>? employeesState;
  final AppState<List<dynamic>>? servicesState;
  final Agendamento? appointment;

  const AppointmentFormDialog({
    super.key,
    this.clientsState,
    this.employeesState,
    this.servicesState,
    this.appointment,
  });

  @override
  ConsumerState<AppointmentFormDialog> createState() =>
      _AppointmentFormDialogState();
}

class _AppointmentFormDialogState
    extends ConsumerState<AppointmentFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _notesController;
  late final TextEditingController _dateController;
  late final TextEditingController _timeController;
  late final TextEditingController _priceController;

  String? _selectedClient;
  String? _selectedBarber;
  String? _selectedService;
  late String _status;
  String? _conflictError;

  final List<String> _clients = [];
  final List<String> _barbers = [];
  final List<String> _services = [];

  @override
  void initState() {
    super.initState();
    final apt = widget.appointment;
    _notesController = TextEditingController(text: apt?.notes ?? '');
    _dateController = TextEditingController(text: apt?.date ?? '');
    _timeController = TextEditingController(text: apt?.time ?? '');
    _priceController = TextEditingController(
      text: apt != null ? AppMasks.formatCurrencyValue(apt.price) : '',
    );

    // Extract dynamic dropdown items
    final List<dynamic>? cData =
        widget.clientsState?.data ?? ref.read(clientesControllerProvider).data;
    if (cData != null) {
      _clients.addAll(
        cData.map((c) => c.name as String).cast<String>(),
      );
    }
    if (_clients.isEmpty) {
      _clients.addAll([
        'João Silva',
        'Lucas Ferreira',
        'Rafael Costa',
        'Bruno Albuquerque',
        'Matheus Lima',
      ]);
    }

    final List<dynamic>? eData = widget.employeesState?.data ??
        ref.read(funcionariosControllerProvider).data;
    if (eData != null) {
      _barbers.addAll(
        eData
            .where((f) => f.cargo.toString().toLowerCase().contains('barbeiro'))
            .map((f) => f.name as String)
            .cast<String>(),
      );
    }
    if (_barbers.isEmpty) {
      _barbers.addAll(['Marcos Silva', 'Arthur Santos', 'Gabriel Neves']);
    }

    final List<dynamic>? sData = widget.servicesState?.data ??
        ref.read(servicosControllerProvider).data;
    if (sData != null) {
      _services.addAll(
        sData.map((s) => s.name as String).cast<String>(),
      );
    }
    if (_services.isEmpty) {
      _services.addAll([
        'Corte de Cabelo',
        'Barba Completa',
        'Combo Cabelo + Barba',
        'Corte Infantil',
        'Corte Degradê Navalhado',
        'Design de Sobrancelha',
      ]);
    }

    if (apt != null) {
      if (apt.clientName.isNotEmpty && !_clients.contains(apt.clientName)) {
        _clients.insert(0, apt.clientName);
      }
      _selectedClient = apt.clientName;

      if (apt.barberName.isNotEmpty && !_barbers.contains(apt.barberName)) {
        _barbers.insert(0, apt.barberName);
      }
      _selectedBarber = apt.barberName;

      final sName = apt.services.trim();
      if (sName.isNotEmpty && !_services.contains(sName)) {
        _services.insert(0, sName);
      }
      _selectedService = sName;
      _status = apt.status;
    } else {
      _selectedClient = null;
      _selectedBarber = null;
      _selectedService = null;
      _status = 'pending';
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  int _getServiceDurationMinutes(String? serviceName) {
    final List<dynamic>? sData = widget.servicesState?.data ??
        ref.read(servicosControllerProvider).data;
    if (serviceName != null && sData != null) {
      for (final s in sData) {
        if (s.name == serviceName) {
          return s.durationMinutes as int;
        }
      }
    }
    final settings = ref.read(businessSettingsControllerProvider).data;
    return int.tryParse(settings?.slotInterval ?? '30') ?? 30;
  }

  void _onServiceChanged(String val) {
    setState(() {
      _selectedService = val;
      _conflictError = null;

      // Auto-fill service price if empty or changing
      final List<dynamic>? sData = widget.servicesState?.data ??
          ref.read(servicosControllerProvider).data;
      if (sData != null) {
        for (final s in sData) {
          if (s.name == val) {
            _priceController.text =
                AppMasks.formatCurrencyValue(s.price as double);
            return;
          }
        }
      }

      if (val.contains('Combo')) {
        _priceController.text = '70,00';
      } else if (val.contains('Barba')) {
        _priceController.text = '35,00';
      } else if (val.contains('Sobrancelha')) {
        _priceController.text = '25,00';
      } else {
        _priceController.text = '50,00';
      }
    });
  }

  Future<void> _selectDate() async {
    DateTime initDate = DateTime.now();
    if (_dateController.text.isNotEmpty) {
      final parts = _dateController.text.split('-');
      if (parts.length == 3) {
        initDate = DateTime(
          int.tryParse(parts[0]) ?? initDate.year,
          int.tryParse(parts[1]) ?? initDate.month,
          int.tryParse(parts[2]) ?? initDate.day,
        );
      }
    }

    final picked = await showDatePicker(
      context: context,
      locale: const Locale('pt', 'BR'),
      initialDate: initDate,
      firstDate: DateTime(2025, 1, 1),
      lastDate: DateTime(2027, 12, 31),
    );

    if (picked != null) {
      final formattedStr =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      setState(() {
        _dateController.text = formattedStr;
        _conflictError = null;
      });
    }
  }

  Future<void> _selectTime() async {
    TimeOfDay initTime = const TimeOfDay(hour: 9, minute: 0);
    if (_timeController.text.isNotEmpty) {
      final parts = _timeController.text.split(':');
      if (parts.length == 2) {
        initTime = TimeOfDay(
          hour: int.tryParse(parts[0]) ?? 9,
          minute: int.tryParse(parts[1]) ?? 0,
        );
      }
    }

    final picked = await showTimePicker(
      context: context,
      initialTime: initTime,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final timeStr =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      setState(() {
        _timeController.text = timeStr;
        _conflictError = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appointment = widget.appointment;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppResponsiveDialog(
      title: appointment == null ? 'Novo Agendamento' : 'Editar Agendamento',
      subtitle: appointment == null
          ? 'Agende um novo horário para o cliente com o profissional selecionado'
          : 'Atualize os dados, horário ou status do agendamento',
      maxWidth: 640,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancelar',
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: ThemeColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              final targetDate = _dateController.text.trim();
              final targetTime = _timeController.text.trim();

              if (_selectedClient == null || _selectedClient!.isEmpty) {
                setState(() => _conflictError = 'Selecione o cliente.');
                return;
              }
              if (_selectedBarber == null || _selectedBarber!.isEmpty) {
                setState(() => _conflictError = 'Selecione o barbeiro.');
                return;
              }
              if (_selectedService == null || _selectedService!.isEmpty) {
                setState(() => _conflictError = 'Selecione o serviço.');
                return;
              }

              // Overlap conflict prevention using service duration / slot interval
              if (_status != 'cancelled') {
                final agendaState = ref.read(agendaControllerProvider);
                final existingList = agendaState.data ?? [];

                final targetParts = targetTime.split(':');
                final targetStartMin = (int.tryParse(targetParts[0]) ?? 0) * 60 +
                    (int.tryParse(targetParts[1]) ?? 0);
                final targetDuration = _getServiceDurationMinutes(_selectedService);
                final targetEndMin = targetStartMin + targetDuration;

                for (final existing in existingList) {
                  if (existing.id == appointment?.id) continue;
                  if (existing.status == 'cancelled') continue;
                  if (existing.barberName != _selectedBarber) continue;
                  if (existing.date != targetDate) continue;

                  final exParts = existing.time.split(':');
                  if (exParts.length != 2) continue;
                  final exStartMin = (int.tryParse(exParts[0]) ?? 0) * 60 +
                      (int.tryParse(exParts[1]) ?? 0);
                  final exDuration = _getServiceDurationMinutes(existing.services);
                  final exEndMin = exStartMin + exDuration;

                  // Overlap condition
                  if (targetStartMin < exEndMin && targetEndMin > exStartMin) {
                    final exEndH = (exEndMin ~/ 60).toString().padLeft(2, '0');
                    final exEndM = (exEndMin % 60).toString().padLeft(2, '0');
                    setState(() {
                      _conflictError =
                          'O barbeiro $_selectedBarber já possui agendamento das ${existing.time} às $exEndH:$exEndM ($exDuration min). Horário livre após às $exEndH:$exEndM.';
                    });
                    return;
                  }
                }
              }

              final cleanPrice = AppMasks.parseCurrency(_priceController.text);

              final newApt = Agendamento(
                id: appointment?.id ?? '',
                clientName: _selectedClient!,
                barberName: _selectedBarber!,
                services: _selectedService!,
                date: targetDate,
                time: targetTime,
                price: cleanPrice,
                status: _status,
                notes: _notesController.text.trim(),
              );

              if (appointment == null) {
                ref
                    .read(agendaControllerProvider.notifier)
                    .addAgendamento(newApt);
              } else {
                ref
                    .read(agendaControllerProvider.notifier)
                    .editAgendamento(newApt);
              }
              Navigator.of(context).pop();
            }
          },
          child: const Text(
            'Salvar Agendamento',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
      ],
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_conflictError != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: ThemeColors.danger.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: ThemeColors.danger.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: ThemeColors.danger,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _conflictError!,
                        style: const TextStyle(
                          color: ThemeColors.danger,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cliente',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  dropdownColor:
                      isDark ? ThemeColors.darkSurface : Colors.white,
                  initialValue: _selectedClient,
                  hint: Text(
                    'Selecione o cliente',
                    style: TextStyle(
                      color: isDark ? Colors.white38 : Colors.grey.shade400,
                      fontSize: 14,
                    ),
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: isDark
                        ? ThemeColors.darkSurface
                        : Colors.grey.shade50,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: isDark
                            ? ThemeColors.darkBorder
                            : Colors.grey.shade300,
                        width: 1.0,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: isDark
                            ? ThemeColors.darkBorder
                            : Colors.grey.shade300,
                        width: 1.0,
                      ),
                    ),
                  ),
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 14,
                  ),
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Selecione o cliente' : null,
                  items: _clients
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedClient = val;
                        _conflictError = null;
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Barbeiro',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        dropdownColor:
                            isDark ? ThemeColors.darkSurface : Colors.white,
                        initialValue: _selectedBarber,
                        hint: Text(
                          'Selecione o barbeiro',
                          style: TextStyle(
                            color: isDark
                                ? Colors.white38
                                : Colors.grey.shade400,
                            fontSize: 14,
                          ),
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: isDark
                              ? ThemeColors.darkSurface
                              : Colors.grey.shade50,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: isDark
                                  ? ThemeColors.darkBorder
                                  : Colors.grey.shade300,
                              width: 1.0,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: isDark
                                  ? ThemeColors.darkBorder
                                  : Colors.grey.shade300,
                              width: 1.0,
                            ),
                          ),
                        ),
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontSize: 14,
                        ),
                        validator: (val) => val == null || val.isEmpty
                            ? 'Selecione o barbeiro'
                            : null,
                        items: _barbers
                            .map(
                              (b) =>
                                  DropdownMenuItem(value: b, child: Text(b)),
                            )
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedBarber = val;
                              _conflictError = null;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Serviço Principal',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        dropdownColor:
                            isDark ? ThemeColors.darkSurface : Colors.white,
                        initialValue: _selectedService,
                        hint: Text(
                          'Selecione o serviço',
                          style: TextStyle(
                            color: isDark
                                ? Colors.white38
                                : Colors.grey.shade400,
                            fontSize: 14,
                          ),
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: isDark
                              ? ThemeColors.darkSurface
                              : Colors.grey.shade50,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: isDark
                                  ? ThemeColors.darkBorder
                                  : Colors.grey.shade300,
                              width: 1.0,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: isDark
                                  ? ThemeColors.darkBorder
                                  : Colors.grey.shade300,
                              width: 1.0,
                            ),
                          ),
                        ),
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontSize: 14,
                        ),
                        validator: (val) => val == null || val.isEmpty
                            ? 'Selecione o serviço'
                            : null,
                        items: _services
                            .map(
                              (s) =>
                                  DropdownMenuItem(value: s, child: Text(s)),
                            )
                            .toList(),
                        onChanged: (val) {
                          if (val != null) _onServiceChanged(val);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _selectDate,
                    borderRadius: BorderRadius.circular(8),
                    child: IgnorePointer(
                      child: AppInput(
                        label: 'Data do Atendimento',
                        placeholder: 'Toque para selecionar',
                        controller: TextEditingController(
                          text: _dateController.text.isNotEmpty
                              ? AppFormatters.formatDate(_dateController.text)
                              : '',
                        ),
                        suffixIcon: const Icon(
                          Icons.calendar_today,
                          size: 18,
                          color: ThemeColors.primary,
                        ),
                        validator: (_) => _dateController.text.isEmpty
                            ? 'Data obrigatória'
                            : null,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: _selectTime,
                    borderRadius: BorderRadius.circular(8),
                    child: IgnorePointer(
                      child: AppInput(
                        label: 'Horário do Atendimento',
                        placeholder: 'Toque para selecionar',
                        controller: _timeController,
                        suffixIcon: const Icon(
                          Icons.access_time,
                          size: 18,
                          color: ThemeColors.primary,
                        ),
                        validator: (_) => _timeController.text.isEmpty
                            ? 'Horário obrigatório'
                            : null,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: AppInput(
                    label: 'Valor Cobrado (R\$)',
                    placeholder: '0,00',
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [AppMasks.currency],
                    validator: AppValidators.currency(required: true, min: 0.01),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Status',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        dropdownColor:
                            isDark ? ThemeColors.darkSurface : Colors.white,
                        initialValue: _status,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: isDark
                              ? ThemeColors.darkSurface
                              : Colors.grey.shade50,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: isDark
                                  ? ThemeColors.darkBorder
                                  : Colors.grey.shade300,
                              width: 1.0,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: isDark
                                  ? ThemeColors.darkBorder
                                  : Colors.grey.shade300,
                              width: 1.0,
                            ),
                          ),
                        ),
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontSize: 14,
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'pending',
                            child: Text('Pendente'),
                          ),
                          DropdownMenuItem(
                            value: 'confirmed',
                            child: Text('Confirmado'),
                          ),
                          DropdownMenuItem(
                            value: 'completed',
                            child: Text('Finalizado'),
                          ),
                          DropdownMenuItem(
                            value: 'cancelled',
                            child: Text('Cancelado'),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _status = val);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AppInput(
              label: 'Observações do Agendamento',
              placeholder: 'Ex: Cabelo molhado, deseja degradê baixo...',
              controller: _notesController,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}
