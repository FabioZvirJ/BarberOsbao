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
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Switch(
                  value: f.status,
                  activeThumbColor: ThemeColors.primary,
                  onChanged: (val) {
                    ref
                        .read(funcionariosControllerProvider.notifier)
                        .editFuncionario(f.copyWith(status: val));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          val
                              ? 'Profissional "${f.name}" ativado na agenda.'
                              : 'Profissional "${f.name}" inativado.',
                        ),
                        backgroundColor: val
                            ? ThemeColors.success
                            : Colors.orange.shade800,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                Text(
                  f.status ? 'Ativo' : 'Inativo',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: f.status ? ThemeColors.success : ThemeColors.danger,
                  ),
                ),
              ],
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
                const SizedBox(width: 4),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  icon: Icon(
                    f.status
                        ? Icons.person_off_outlined
                        : Icons.person_add_alt_1_outlined,
                    size: 18,
                    color: f.status ? ThemeColors.warning : ThemeColors.success,
                  ),
                  onPressed: () => _showDeleteDialog(context, f),
                  tooltip: f.status ? 'Inativar Funcionário' : 'Reativar Funcionário',
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCurrentlyActive = employee.status;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? ThemeColors.darkSurface : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: Row(
          children: [
            Icon(
              isCurrentlyActive
                  ? Icons.person_off_outlined
                  : Icons.person_add_alt_1_outlined,
              color: isCurrentlyActive ? ThemeColors.warning : ThemeColors.success,
              size: 22,
            ),
            const SizedBox(width: 8),
            Text(
              isCurrentlyActive ? 'Inativar Funcionário' : 'Reativar Funcionário',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          isCurrentlyActive
              ? 'Deseja inativar o profissional "${employee.name}"? O profissional não receberá novos agendamentos na agenda, mas todo o seu histórico de atendimentos e comissões permanecerá intacto.'
              : 'Deseja reativar o profissional "${employee.name}" para permitir novos agendamentos?',
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.black87,
            fontSize: 13,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancelar',
              style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isCurrentlyActive
                  ? ThemeColors.warning
                  : ThemeColors.success,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            onPressed: () {
              ref
                  .read(funcionariosControllerProvider.notifier)
                  .editFuncionario(employee.copyWith(status: !isCurrentlyActive));
              Navigator.of(ctx).pop();
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
            child: Text(
              isCurrentlyActive ? 'Inativar' : 'Reativar',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
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
  late final TextEditingController _horarioController;
  late final TextEditingController _avatarUrlController;
  final TextEditingController _newSpecialtyController = TextEditingController();

  late List<String> _specialties;
  late List<String> _selectedDays;
  late List<String> _selectedFolgas;
  late bool _active;

  final _weekDays = [
    'Segunda',
    'Terça',
    'Quarta',
    'Quinta',
    'Sexta',
    'Sábado',
    'Domingo',
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
    _horarioController = TextEditingController(
      text: f?.horarioTrabalho ?? '',
    );
    _avatarUrlController = TextEditingController(text: f?.avatarUrl ?? '');

    _specialties = f != null ? List<String>.from(f.specialties) : [];
    _selectedDays = List.from(
      f?.diasDisponiveis ??
          ['Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado'],
    );
    _selectedFolgas = List.from(f?.folgas ?? ['Domingo']);
    _active = f?.status ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cargoController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _cpfController.dispose();
    _commissionRateController.dispose();
    _horarioController.dispose();
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

  @override
  Widget build(BuildContext context) {
    final employee = widget.employee;
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                horarioTrabalho: _horarioController.text.trim(),
                diasDisponiveis: _selectedDays,
                folgas: _selectedFolgas,
                status: _active,
                rating: employee?.rating ?? 5.0,
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
            Row(
              children: [
                Expanded(
                  child: AppInput(
                    label: 'E-mail',
                    placeholder: 'Ex: arthur@barberosbao.com',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: AppValidators.email(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: AppInput(
                    label: 'Horário de Trabalho',
                    placeholder: 'Ex: 09:00 - 18:00',
                    controller: _horarioController,
                    validator: (val) =>
                        val == null || val.trim().isEmpty
                            ? 'Horário obrigatório'
                            : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Chip Input for Specialties
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
                  const SizedBox(height: 8),
                ],
                Row(
                  children: [
                    Expanded(
                      child: AppInput(
                        label: '',
                        placeholder:
                            'Digite uma especialidade (Ex: Degradê, Barba)',
                        controller: _newSpecialtyController,
                        onSubmitted: _addSpecialty,
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
                          horizontal: 16,
                          vertical: 14,
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
              ],
            ),
            const SizedBox(height: 16),

            AppImageUpload(
              label: 'Foto do Profissional / Barbeiro',
              controller: _avatarUrlController,
              height: 140,
              helperText: 'Upload do arquivo ou informe o link',
            ),
            const SizedBox(height: 16),
            Text(
              'Dias Disponíveis de Trabalho',
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black87,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _weekDays.map((day) {
                final isSelected = _selectedDays.contains(day);
                return FilterChip(
                  label: Text(
                    day,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.black
                          : (isDark ? Colors.white70 : Colors.black87),
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: ThemeColors.primary,
                  backgroundColor: isDark
                      ? ThemeColors.darkBg
                      : Colors.grey.shade100,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                    side: BorderSide(
                      color: isDark
                          ? ThemeColors.darkBorder
                          : Colors.grey.shade300,
                    ),
                  ),
                  onSelected: (val) {
                    setState(() {
                      if (val) {
                        _selectedDays.add(day);
                        _selectedFolgas.remove(day);
                      } else {
                        _selectedDays.remove(day);
                        _selectedFolgas.add(day);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
