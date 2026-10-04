import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:barber_osbao/packages/design_system/theme/theme_colors.dart';
import 'package:barber_osbao/packages/design_system/theme/app_breakpoints.dart';
import 'package:barber_osbao/packages/design_system/layouts/app_page.dart';
import 'package:barber_osbao/packages/design_system/layouts/app_section.dart';
import 'package:barber_osbao/packages/design_system/organisms/app_table.dart';
import 'package:barber_osbao/packages/design_system/molecules/app_filters.dart';
import 'package:barber_osbao/packages/design_system/atoms/app_avatar.dart';
import 'package:barber_osbao/packages/design_system/atoms/app_badge.dart';
import 'package:barber_osbao/packages/design_system/atoms/app_button.dart';
import 'package:barber_osbao/packages/design_system/molecules/app_input.dart';
import 'package:barber_osbao/packages/design_system/molecules/app_image_upload.dart';
import 'package:barber_osbao/packages/design_system/organisms/app_dialog.dart';
import 'package:barber_osbao/packages/design_system/molecules/app_search_bar.dart';
import 'package:barber_osbao/packages/core/shared/state/app_state.dart';
import 'package:barber_osbao/packages/core/utils/app_formatters.dart';
import 'package:barber_osbao/packages/core/utils/app_masks.dart';
import 'package:barber_osbao/features/agenda/presentation/controllers/agenda_controller.dart';
import 'package:barber_osbao/features/funcionarios/domain/models/funcionario.dart';
import 'package:barber_osbao/features/funcionarios/presentation/controllers/funcionarios_controller.dart';
import 'package:barber_osbao/features/filiais/application/branches_controller.dart';

class FuncionariosPage extends ConsumerStatefulWidget {
  const FuncionariosPage({super.key});

  @override
  ConsumerState<FuncionariosPage> createState() => _FuncionariosPageState();
}

class _FuncionariosPageState extends ConsumerState<FuncionariosPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedStatus = 'Todos';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(funcionariosControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = AppBreakpoints.isMobile(context);

    return AppPage(
      title: 'Funcionários',
      userName: 'Fábio Zvir',
      userAvatarUrl:
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&width=150',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Responsive toolbar
          if (isMobile) ...[
            AppSearchBar(
              controller: _searchController,
              placeholder:
                  'Pesquisar profissional por nome, cargo ou especialidade...',
              onChanged: (val) =>
                  setState(() => _searchQuery = val.toLowerCase()),
              onClear: () => setState(() => _searchQuery = ''),
            ),
            const SizedBox(height: 10),
            AppButton(
              label: 'Cadastrar Funcionário',
              icon: const Icon(Icons.add, size: 16),
              onPressed: () => _showFormDialog(context),
            ),
          ] else
            Row(
              children: [
                Expanded(
                  child: AppSearchBar(
                    controller: _searchController,
                    placeholder:
                        'Pesquisar profissional por nome, cargo ou especialidade...',
                    onChanged: (val) =>
                        setState(() => _searchQuery = val.toLowerCase()),
                    onClear: () => setState(() => _searchQuery = ''),
                  ),
                ),
                const SizedBox(width: 16),
                AppButton(
                  label: 'Cadastrar Funcionário',
                  icon: const Icon(Icons.add, size: 16),
                  onPressed: () => _showFormDialog(context),
                ),
              ],
            ),
          const SizedBox(height: 16),
          AppFilters(
            options: const ['Todos', 'Ativo', 'Inativo'],
            selectedOption: _selectedStatus,
            onSelected: (val) => setState(() => _selectedStatus = val),
          ),
          const SizedBox(height: 32),

          AppSection(
            title: 'Equipe de Profissionais',
            subtitle:
                'Lista de barbeiros, especialidades, horários e comissões',
            child: _buildContent(state, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(AppState<List<Funcionario>> state, bool isDark) {
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
          'Nenhum profissional cadastrado.',
          style: TextStyle(color: isDark ? Colors.white30 : Colors.grey),
        ),
      );
    }

    final filtered = data.where((f) {
      final matchesSearch =
          f.name.toLowerCase().contains(_searchQuery) ||
          f.cargo.toLowerCase().contains(_searchQuery) ||
          f.specialties.any((s) => s.toLowerCase().contains(_searchQuery));

      final matchesStatus =
          _selectedStatus == 'Todos' ||
          (_selectedStatus == 'Ativo' && f.status) ||
          (_selectedStatus == 'Inativo' && !f.status);

      return matchesSearch && matchesStatus;
    }).toList();

    if (filtered.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        alignment: Alignment.center,
        child: Text(
          'Nenhum profissional correspondente aos filtros.',
          style: TextStyle(color: isDark ? Colors.white30 : Colors.grey),
        ),
      );
    }

    return AppTable(
      minWidth: 960,
      columns: [
        AppTableColumn(label: 'BARBEIRO', flex: 3),
        AppTableColumn(label: 'CARGO', flex: 2),
        AppTableColumn(label: 'ESPECIALIDADES', flex: 3),
        AppTableColumn(label: 'COMISSÃO', width: 90),
        AppTableColumn(label: 'HORÁRIO', width: 110),
        AppTableColumn(label: 'AVALIAÇÃO', width: 90),
        AppTableColumn(label: 'STATUS', width: 120),
        AppTableColumn(label: 'AÇÕES', width: 130),
      ],
      rows: filtered.map((f) {
        return AppTableRow(
          cells: [
            Row(
              children: [
                AppAvatar(url: f.avatarUrl, name: f.name, size: 36),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        f.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        f.phone,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Text(f.cargo),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: f.specialties.map((s) => AppBadge(label: s)).toList(),
            ),
            Text(
              '${(f.commissionRate * 100).toStringAsFixed(0)}%',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(f.horarioTrabalho, style: const TextStyle(fontSize: 12)),
                Text(
                  'Folga: ${f.folgas.join(", ")}',
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.star, color: ThemeColors.primary, size: 14),
                const SizedBox(width: 4),
                Text(
                  f.rating.toString(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Transform.scale(
              scale: 0.75,
              child: Switch.adaptive(
                value: f.status,
                activeThumbColor: ThemeColors.primary,
                onChanged: (val) {
                  _showDeleteDialog(context, f);
                },
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  icon: const Icon(Icons.calendar_month, size: 18),
                  onPressed: () => _showAgendaDialog(context, f),
                  tooltip: 'Visualizar Agenda',
                ),
                const SizedBox(width: 4),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  onPressed: () => _showFormDialog(context, f),
                  tooltip: 'Editar',
                ),
              ],
            ),
          ],
        );
      }).toList(),
    );
  }

  void _showFormDialog(BuildContext context, [Funcionario? employee]) {
    showDialog(
      context: context,
      builder: (ctx) => _FuncionarioFormDialog(employee: employee),
    );
  }

  void _showDeleteDialog(BuildContext context, Funcionario employee) {
    final isCurrentlyActive = employee.status;

    AppConfirmDialog.show(
      context: context,
      title: isCurrentlyActive ? 'Inativar Funcionário' : 'Reativar Funcionário',
      message: isCurrentlyActive
          ? 'Tem certeza que deseja inativar o profissional da agenda? O histórico de atendimentos e comissões permanecerá intacto.'
          : 'Deseja reativar este profissional para voltar a receber agendamentos?',
      confirmLabel: isCurrentlyActive ? 'Inativar' : 'Reativar',
      confirmColor: isCurrentlyActive ? ThemeColors.warning : ThemeColors.success,
      confirmTextColor: isCurrentlyActive ? Colors.black : Colors.white,
      icon: isCurrentlyActive
          ? Icons.person_off_outlined
          : Icons.person_add_alt_1_outlined,
      iconColor: isCurrentlyActive ? ThemeColors.warning : ThemeColors.success,
      details: [
        MapEntry('Profissional', employee.name),
        MapEntry('Cargo', employee.cargo),
        if (employee.phone.isNotEmpty) MapEntry('Telefone', employee.phone),
        MapEntry('Comissão', '${(employee.commissionRate * 100).toStringAsFixed(0)}%'),
      ],
      onConfirm: () {
        ref
            .read(funcionariosControllerProvider.notifier)
            .editFuncionario(employee.copyWith(status: !isCurrentlyActive));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isCurrentlyActive
                  ? 'Profissional "${employee.name}" inativado com sucesso.'
                  : 'Profissional "${employee.name}" reativado.',
            ),
            backgroundColor: isCurrentlyActive
                ? Colors.orange.shade800
                : ThemeColors.success,
          ),
        );
      },
    );
  }

  void _showAgendaDialog(BuildContext context, Funcionario employee) {
    showDialog(
      context: context,
      builder: (ctx) => _FuncionarioAgendaDialog(employee: employee),
    );
  }
}

class _FuncionarioAgendaDialog extends ConsumerStatefulWidget {
  final Funcionario employee;

  const _FuncionarioAgendaDialog({required this.employee});

  @override
  ConsumerState<_FuncionarioAgendaDialog> createState() =>
      _FuncionarioAgendaDialogState();
}

class _FuncionarioAgendaDialogState
    extends ConsumerState<_FuncionarioAgendaDialog> {
  String _selectedRange = 'Hoje'; // 'Hoje' or '7 Dias'

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final agendaState = ref.watch(agendaControllerProvider);
    final allApts = agendaState.data ?? [];

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);
    final weekEnd =
        todayStart.add(const Duration(days: 7, hours: 23, minutes: 59));

    final employeeApts = allApts.where((a) {
      final matchesBarber =
          a.barberName.trim().toLowerCase() ==
          widget.employee.name.trim().toLowerCase();
      if (!matchesBarber) return false;
      if (_selectedRange == 'Hoje') {
        return a.dateTime.isAfter(
              todayStart.subtract(const Duration(seconds: 1)),
            ) &&
            a.dateTime.isBefore(todayEnd);
      } else {
        return a.dateTime.isAfter(
              todayStart.subtract(const Duration(seconds: 1)),
            ) &&
            a.dateTime.isBefore(weekEnd);
      }
    }).toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

    return AppResponsiveDialog(
      title: 'Agenda de ${widget.employee.name}',
      subtitle:
          '${widget.employee.cargo} • ${widget.employee.horarioTrabalho.isNotEmpty ? widget.employee.horarioTrabalho : "Horário padrão"}',
      maxWidth: 580,
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: ThemeColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Fechar',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppAvatar(
                url: widget.employee.avatarUrl,
                name: widget.employee.name,
                size: 44,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.employee.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                      'Horário: ${widget.employee.horarioTrabalho.isNotEmpty ? widget.employee.horarioTrabalho : "Padrão"} • Folgas: ${widget.employee.folgas.join(", ")}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Filter Tabs (Hoje vs Próximos 7 Dias)
          Row(
            children: [
              ChoiceChip(
                label: const Text('Hoje'),
                selected: _selectedRange == 'Hoje',
                onSelected: (val) {
                  if (val) setState(() => _selectedRange = 'Hoje');
                },
                selectedColor: ThemeColors.primary,
                labelStyle: TextStyle(
                  color: _selectedRange == 'Hoje'
                      ? Colors.black
                      : (isDark ? Colors.white70 : Colors.black87),
                  fontWeight: _selectedRange == 'Hoje'
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Próximos 7 Dias'),
                selected: _selectedRange == '7 Dias',
                onSelected: (val) {
                  if (val) setState(() => _selectedRange = '7 Dias');
                },
                selectedColor: ThemeColors.primary,
                labelStyle: TextStyle(
                  color: _selectedRange == '7 Dias'
                      ? Colors.black
                      : (isDark ? Colors.white70 : Colors.black87),
                  fontWeight: _selectedRange == '7 Dias'
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
              const Spacer(),
              Text(
                '${employeeApts.length} atendimento(s)',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (employeeApts.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.02)
                    : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark ? ThemeColors.darkBorder : Colors.grey.shade200,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 36,
                    color: isDark ? Colors.white24 : Colors.black26,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _selectedRange == 'Hoje'
                        ? 'Nenhum agendamento para hoje.'
                        : 'Nenhum agendamento para os próximos 7 dias.',
                    style: TextStyle(
                      color: isDark ? Colors.white38 : Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            )
          else
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: employeeApts.length,
                separatorBuilder: (_, _) => Divider(
                  height: 1,
                  color: isDark ? Colors.white10 : Colors.grey.shade200,
                ),
                itemBuilder: (context, index) {
                  final apt = employeeApts[index];
                  final isCompleted =
                      apt.status == 'Concluído' || apt.status == 'completed';
                  final isCanceled =
                      apt.status == 'Cancelado' || apt.status == 'canceled';
                  final statusColor = isCompleted
                      ? ThemeColors.success
                      : (isCanceled ? ThemeColors.danger : ThemeColors.primary);

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: ThemeColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        AppFormatters.formatTime(apt.dateTime),
                        style: const TextStyle(
                          color: ThemeColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    title: Text(
                      apt.clientName,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      '${apt.serviceName} • ${AppFormatters.formatDate(apt.dateTime)}',
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          AppFormatters.formatCurrency(apt.price),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          apt.status,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _FuncionarioFormDialog extends ConsumerStatefulWidget {
  final Funcionario? employee;

  const _FuncionarioFormDialog({this.employee});

  @override
  ConsumerState<_FuncionarioFormDialog> createState() =>
      _FuncionarioFormDialogState();
}

class _FuncionarioFormDialogState
    extends ConsumerState<_FuncionarioFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _cargoController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _cpfController;
  late final TextEditingController _commissionRateController;
  late final TextEditingController _avatarUrlController;
  final TextEditingController _newSpecialtyController = TextEditingController();

  late List<String> _specialties;
  late bool _active;
  String? _selectedBranchId;

  bool _workWeekdays = true;
  String _weekStart = '09:00';
  String _weekEnd = '18:00';

  bool _workSaturday = true;
  String _satStart = '09:00';
  String _satEnd = '13:00';

  bool _workSunday = false;
  String _sunStart = '09:00';
  String _sunEnd = '13:00';

  static const _timeSlots = [
    '07:00', '07:30', '08:00', '08:30', '09:00', '09:30',
    '10:00', '10:30', '11:00', '11:30', '12:00', '12:30',
    '13:00', '13:30', '14:00', '14:30', '15:00', '15:30',
    '16:00', '16:30', '17:00', '17:30', '18:00', '18:30',
    '19:00', '19:30', '20:00', '20:30', '21:00', '21:30', '22:00',
  ];

  static const _catalogSpecialties = [
    'Corte Tradicional',
    'Degradê / Fade',
    'Barba Terapia',
    'Pigmentação',
    'Design de Sobrancelha',
    'Platinado / Luzes',
    'Corte Infantil',
    'Selagem / Alisamento',
    'Limpeza de Pele',
  ];

  @override
  void initState() {
    super.initState();
    final f = widget.employee;
    _nameController = TextEditingController(text: f?.name ?? '');
    _cargoController = TextEditingController(text: f?.cargo ?? '');
    _phoneController = TextEditingController(text: f?.phone ?? '');
    _emailController = TextEditingController(text: f?.email ?? '');
    _cpfController = TextEditingController(text: f?.cpf ?? '');
    _commissionRateController = TextEditingController(
      text: f != null ? (f.commissionRate * 100).toStringAsFixed(0) : '',
    );
    _avatarUrlController = TextEditingController(text: f?.avatarUrl ?? '');
    _specialties = f != null ? List<String>.from(f.specialties) : [];
    _active = f?.status ?? true;
    _selectedBranchId = f?.branchId;

    if (f != null && f.diasDisponiveis.isNotEmpty) {
      _workWeekdays = f.diasDisponiveis.any(
        (d) => ['Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta'].contains(d),
      );
      _workSaturday = f.diasDisponiveis.contains('Sábado');
      _workSunday = f.diasDisponiveis.contains('Domingo');

      final hoursMatches = RegExp(r'(\d{2}:\d{2})')
          .allMatches(f.horarioTrabalho)
          .map((m) => m.group(0)!)
          .toList();
      if (hoursMatches.length >= 2) {
        if (_timeSlots.contains(hoursMatches[0])) _weekStart = hoursMatches[0];
        if (_timeSlots.contains(hoursMatches[1])) _weekEnd = hoursMatches[1];
      }
      if (hoursMatches.length >= 4) {
        if (_timeSlots.contains(hoursMatches[2])) _satStart = hoursMatches[2];
        if (_timeSlots.contains(hoursMatches[3])) _satEnd = hoursMatches[3];
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cargoController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _cpfController.dispose();
    _commissionRateController.dispose();
    _avatarUrlController.dispose();
    _newSpecialtyController.dispose();
    super.dispose();
  }

  void _addSpecialty(String val) {
    final trimmed = val.trim();
    if (trimmed.isNotEmpty && !_specialties.contains(trimmed)) {
      setState(() {
        _specialties.add(trimmed);
        _newSpecialtyController.clear();
      });
    }
  }

  Widget _buildScheduleRow({
    required BuildContext context,
    required String label,
    required bool enabled,
    required ValueChanged<bool> onToggle,
    required String start,
    required String end,
    required ValueChanged<String> onStartChanged,
    required ValueChanged<String> onEndChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? ThemeColors.darkSurface : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? ThemeColors.darkBorder : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Checkbox(
            value: enabled,
            activeColor: ThemeColors.primary,
            checkColor: Colors.black,
            onChanged: (val) => onToggle(val ?? false),
          ),
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
          const Spacer(),
          if (enabled) ...[
            _buildTimeDropdown(
              context: context,
              value: start,
              onChanged: onStartChanged,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                'às',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white54 : Colors.black54,
                ),
              ),
            ),
            _buildTimeDropdown(
              context: context,
              value: end,
              onChanged: onEndChanged,
            ),
          ] else ...[
            Text(
              'Folga',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: isDark ? Colors.white38 : Colors.black38,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeDropdown({
    required BuildContext context,
    required String value,
    required ValueChanged<String> onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: isDark ? ThemeColors.darkBg : Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isDark ? ThemeColors.darkBorder : Colors.grey.shade300,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _timeSlots.contains(value) ? value : _timeSlots.first,
          isDense: true,
          dropdownColor: isDark ? ThemeColors.darkSurface : Colors.white,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          items: _timeSlots.map((time) {
            return DropdownMenuItem<String>(
              value: time,
              child: Text(time),
            );
          }).toList(),
          onChanged: (newVal) {
            if (newVal != null) onChanged(newVal);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final employee = widget.employee;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final branches = ref.watch(branchesProvider).value ?? [];

    final existingEmployees =
        ref.watch(funcionariosControllerProvider).data ?? [];
    final allKnownSpecialties = <String>{
      ..._catalogSpecialties,
      for (final emp in existingEmployees) ...emp.specialties,
    };
    final availableSuggestions = allKnownSpecialties
        .where((s) => !_specialties.contains(s))
        .toList();

    return AppResponsiveDialog(
      title: employee == null ? 'Cadastrar Funcionário' : 'Editar Funcionário',
      subtitle: employee == null
          ? 'Cadastre um novo barbeiro ou colaborador da barbearia'
          : 'Atualize os dados cadastrais, horários e comissões',
      maxWidth: 660,
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
              final commRateParsed =
                  double.tryParse(
                    _commissionRateController.text.trim().replaceAll(',', '.'),
                  ) ??
                  0.0;
              final commVal = commRateParsed / 100.0;

              final scheduleParts = <String>[];
              final computedDays = <String>[];
              final computedFolgas = <String>[];

              if (_workWeekdays) {
                scheduleParts.add('Seg-Sex: $_weekStart às $_weekEnd');
                computedDays.addAll([
                  'Segunda',
                  'Terça',
                  'Quarta',
                  'Quinta',
                  'Sexta',
                ]);
              } else {
                computedFolgas.addAll([
                  'Segunda',
                  'Terça',
                  'Quarta',
                  'Quinta',
                  'Sexta',
                ]);
              }

              if (_workSaturday) {
                scheduleParts.add('Sáb: $_satStart às $_satEnd');
                computedDays.add('Sábado');
              } else {
                computedFolgas.add('Sábado');
              }

              if (_workSunday) {
                scheduleParts.add('Dom: $_sunStart às $_sunEnd');
                computedDays.add('Domingo');
              } else {
                computedFolgas.add('Domingo');
              }

              final finalHorario = scheduleParts.isNotEmpty
                  ? scheduleParts.join(' • ')
                  : 'Sem horário cadastrado';

              final newFunc = Funcionario(
                id: employee?.id ?? '',
                name: _nameController.text.trim(),
                avatarUrl: _avatarUrlController.text.trim(),
                cargo: _cargoController.text.trim(),
                phone: _phoneController.text.trim(),
                email: _emailController.text.trim(),
                cpf: _cpfController.text.trim(),
                specialties: _specialties.isNotEmpty
                    ? _specialties
                    : ['Atendimento Geral'],
                commissionRate: commVal,
                horarioTrabalho: finalHorario,
                diasDisponiveis: computedDays,
                folgas: computedFolgas,
                status: _active,
                rating: employee?.rating ?? 5.0,
                branchId: _selectedBranchId,
              );

              if (employee == null) {
                ref
                    .read(funcionariosControllerProvider.notifier)
                    .addFuncionario(newFunc);
              } else {
                ref
                    .read(funcionariosControllerProvider.notifier)
                    .editFuncionario(newFunc);
              }
              Navigator.of(context).pop();
            }
          },
          child: const Text(
            'Salvar Funcionário',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
      ],
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Active toggle on top as requested
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.03)
                    : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark ? ThemeColors.darkBorder : Colors.grey.shade200,
                ),
              ),
              child: SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                title: Text(
                  'Funcionário Ativo para Agenda',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  'Habilita o profissional para receber agendamentos de clientes',
                  style: TextStyle(
                    color: isDark ? Colors.white54 : Colors.black45,
                    fontSize: 12,
                  ),
                ),
                value: _active,
                activeThumbColor: ThemeColors.primary,
                onChanged: (val) => setState(() => _active = val),
              ),
            ),

            if (branches.isNotEmpty) ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filial / Unidade de Atendimento',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String?>(
                    initialValue: _selectedBranchId,
                    dropdownColor: isDark ? ThemeColors.darkSurface : Colors.white,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.storefront_outlined,
                        size: 20,
                        color: ThemeColors.primary,
                      ),
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
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: isDark
                              ? ThemeColors.darkBorder
                              : Colors.grey.shade300,
                        ),
                      ),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Todas as Filiais / Geral'),
                      ),
                      ...branches.map(
                        (b) => DropdownMenuItem(
                          value: b.id,
                          child: Text('${b.name} (${b.neighborhood})'),
                        ),
                      ),
                    ],
                    onChanged: (val) => setState(() => _selectedBranchId = val),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            AppInput(
              label: 'Nome Completo',
              placeholder: 'Ex: Arthur Mendes',
              controller: _nameController,
              validator: (val) =>
                  val == null || val.trim().isEmpty ? 'Nome obrigatório' : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: AppInput(
                    label: 'Cargo / Função',
                    placeholder: 'Ex: Barbeiro Especialista',
                    controller: _cargoController,
                    validator: (val) =>
                        val == null || val.trim().isEmpty
                            ? 'Cargo obrigatório'
                            : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: AppInput(
                    label: 'Comissão (%)',
                    placeholder: 'Ex: 35',
                    controller: _commissionRateController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [AppMasks.percentage],
                    validator: AppValidators.percentage(required: true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: AppInput(
                    label: 'Telefone',
                    placeholder: '(11) 97777-2222',
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [AppMasks.phone],
                    validator: AppValidators.phone(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: AppInput(
                    label: 'CPF',
                    placeholder: '123.456.789-00',
                    controller: _cpfController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [AppMasks.cpf],
                    validator: AppValidators.cpf(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AppInput(
              label: 'E-mail',
              placeholder: 'Ex: arthur@barberosbao.com',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              validator: AppValidators.email(),
            ),
            const SizedBox(height: 20),

            // Especialidades Section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Especialidades',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                if (_specialties.isNotEmpty) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _specialties.map((s) {
                      return Chip(
                        label: Text(
                          s,
                          style: const TextStyle(fontSize: 12),
                        ),
                        backgroundColor: isDark
                            ? ThemeColors.darkSurface
                            : Colors.grey.shade100,
                        deleteIcon: const Icon(Icons.close, size: 14),
                        onDeleted: () {
                          setState(() {
                            _specialties.remove(s);
                          });
                        },
                        side: BorderSide(
                          color: isDark
                              ? ThemeColors.darkBorder
                              : Colors.grey.shade300,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 10),
                ],
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _newSpecialtyController,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontSize: 13,
                        ),
                        decoration: InputDecoration(
                          isDense: true,
                          hintText:
                              'Digite ou selecione uma especialidade abaixo...',
                          hintStyle: TextStyle(
                            color: isDark ? Colors.white38 : Colors.black38,
                            fontSize: 13,
                          ),
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
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: isDark
                                  ? ThemeColors.darkBorder
                                  : Colors.grey.shade300,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: ThemeColors.primary,
                              width: 1.5,
                            ),
                          ),
                        ),
                        onFieldSubmitted: _addSpecialty,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ThemeColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 13,
                        ),
                      ),
                      onPressed: () =>
                          _addSpecialty(_newSpecialtyController.text),
                      child: const Text(
                        'Adicionar',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                if (availableSuggestions.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    'Sugestões rápidas:',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: availableSuggestions.map((s) {
                      return ActionChip(
                        avatar: const Icon(Icons.add, size: 13),
                        label: Text(
                          s,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                        backgroundColor: isDark
                            ? ThemeColors.darkSurface
                            : Colors.grey.shade100,
                        side: BorderSide(
                          color: isDark
                              ? ThemeColors.darkBorder
                              : Colors.grey.shade300,
                        ),
                        onPressed: () => _addSpecialty(s),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 20),

            // Structured Schedule Section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Jornada e Horário de Trabalho',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Defina os dias e horários em que o profissional estará disponível para agendamento',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white38 : Colors.black45,
                  ),
                ),
                const SizedBox(height: 12),
                _buildScheduleRow(
                  context: context,
                  label: 'Segunda a Sexta',
                  enabled: _workWeekdays,
                  onToggle: (v) => setState(() => _workWeekdays = v),
                  start: _weekStart,
                  end: _weekEnd,
                  onStartChanged: (v) => setState(() => _weekStart = v),
                  onEndChanged: (v) => setState(() => _weekEnd = v),
                ),
                const SizedBox(height: 8),
                _buildScheduleRow(
                  context: context,
                  label: 'Sábado',
                  enabled: _workSaturday,
                  onToggle: (v) => setState(() => _workSaturday = v),
                  start: _satStart,
                  end: _satEnd,
                  onStartChanged: (v) => setState(() => _satStart = v),
                  onEndChanged: (v) => setState(() => _satEnd = v),
                ),
                const SizedBox(height: 8),
                _buildScheduleRow(
                  context: context,
                  label: 'Domingo',
                  enabled: _workSunday,
                  onToggle: (v) => setState(() => _workSunday = v),
                  start: _sunStart,
                  end: _sunEnd,
                  onStartChanged: (v) => setState(() => _sunStart = v),
                  onEndChanged: (v) => setState(() => _sunEnd = v),
                ),
              ],
            ),
            const SizedBox(height: 20),

            AppImageUpload(
              label: 'Foto do Profissional / Barbeiro',
              controller: _avatarUrlController,
              height: 140,
              helperText: 'Upload do arquivo ou informe o link',
            ),
          ],
        ),
      ),
    );
  }
}
