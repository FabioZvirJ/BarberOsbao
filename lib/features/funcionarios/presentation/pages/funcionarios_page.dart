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
import 'package:barber_osbao/packages/design_system/atoms/app_status_chip.dart';
import 'package:barber_osbao/packages/design_system/molecules/app_input.dart';
import 'package:barber_osbao/packages/design_system/molecules/app_search_bar.dart';
import 'package:barber_osbao/packages/core/shared/state/app_state.dart';
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
        AppTableColumn(label: 'STATUS', width: 85),
        AppTableColumn(label: 'AÇÕES', width: 130),
      ],
      rows: filtered.map((f) {
        return AppTableRow(
          cells: [
            Row(
              children: [
                AppAvatar(url: f.avatarUrl, size: 36),
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
            AppStatusChip(
              label: f.status ? 'Ativo' : 'Inativo',
              type: f.status ? AppStatusType.success : AppStatusType.danger,
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
                  icon: const Icon(
                    Icons.delete_outline,
                    size: 18,
                    color: ThemeColors.danger,
                  ),
                  onPressed: () => _showDeleteDialog(context, f),
                  tooltip: 'Excluir',
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
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ThemeColors.darkBg,
        title: const Text(
          'Excluir Funcionário',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Tem certeza que deseja excluir o profissional "${employee.name}"? Isso apagará seu histórico de comissões.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeColors.danger,
            ),
            onPressed: () {
              ref
                  .read(funcionariosControllerProvider.notifier)
                  .removeFuncionario(employee.id);
              Navigator.of(ctx).pop();
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAgendaDialog(BuildContext context, Funcionario employee) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ThemeColors.darkBg,
        title: Row(
          children: [
            AppAvatar(url: employee.avatarUrl, size: 36),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Agenda de ${employee.name}',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  Text(
                    employee.cargo,
                    style: const TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Próximos Compromissos (Hoje)',
                style: TextStyle(
                  color: ThemeColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              const ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Text(
                  '09:00',
                  style: TextStyle(
                    color: ThemeColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                title: Text(
                  'João Silva',
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
                subtitle: Text(
                  'Corte + Barba - Confirmado',
                  style: TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ),
              const Divider(color: Colors.white10),
              const ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Text(
                  '10:30',
                  style: TextStyle(
                    color: ThemeColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                title: Text(
                  'Carlos Oliveira',
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
                subtitle: Text(
                  'Corte Degradê - Confirmado',
                  style: TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ),
              const Divider(color: Colors.white10),
              const ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Text(
                  '14:30',
                  style: TextStyle(
                    color: ThemeColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                title: Text(
                  'Pedro Almeida',
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
                subtitle: Text(
                  'Corte + Barba + Sobrancelha - Pendente',
                  style: TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Horário de Trabalho: ${employee.horarioTrabalho}',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              Text(
                'Dias de Trabalho: ${employee.diasDisponiveis.join(", ")}',
                style: const TextStyle(color: Colors.white54, fontSize: 11),
              ),
            ],
          ),
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
  late final TextEditingController _specialtiesController;
  late final TextEditingController _commissionRateController;
  late final TextEditingController _horarioController;
  late final TextEditingController _avatarUrlController;

  late List<String> _selectedDays;
  late List<String> _selectedFolgas;
  late bool _active;

  final _weekDays = const [
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
    final emp = widget.employee;
    _nameController = TextEditingController(text: emp?.name ?? '');
    _cargoController = TextEditingController(text: emp?.cargo ?? '');
    _phoneController = TextEditingController(text: emp?.phone ?? '');
    _emailController = TextEditingController(text: emp?.email ?? '');
    _cpfController = TextEditingController(text: emp?.cpf ?? '');
    _specialtiesController = TextEditingController(
      text: emp?.specialties.join(", ") ?? '',
    );
    _commissionRateController = TextEditingController(
      text: emp != null ? (emp.commissionRate * 100).toStringAsFixed(0) : '30',
    );
    _horarioController = TextEditingController(
      text: emp?.horarioTrabalho ?? '09:00 - 18:00',
    );
    _avatarUrlController = TextEditingController(text: emp?.avatarUrl ?? '');

    _selectedDays = List.from(
      emp?.diasDisponiveis ??
          ['Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado'],
    );
    _selectedFolgas = List.from(emp?.folgas ?? ['Domingo']);
    _active = emp?.status ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cargoController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _cpfController.dispose();
    _specialtiesController.dispose();
    _commissionRateController.dispose();
    _horarioController.dispose();
    _avatarUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final employee = widget.employee;

    return AlertDialog(
      backgroundColor: ThemeColors.darkBg,
      title: Text(
        employee == null ? 'Cadastrar Funcionário' : 'Editar Funcionário',
        style: const TextStyle(color: Colors.white),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppInput(
                label: 'Nome Completo',
                placeholder: 'Ex: Arthur Mendes',
                controller: _nameController,
                validator: (val) =>
                    val == null || val.isEmpty ? 'Nome obrigatório' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: AppInput(
                      label: 'Cargo / Função',
                      placeholder: 'Ex: Barbeiro Specialist',
                      controller: _cargoController,
                      validator: (val) => val == null || val.isEmpty
                          ? 'Cargo obrigatório'
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppInput(
                      label: 'Comissão (%)',
                      placeholder: 'Ex: 30',
                      controller: _commissionRateController,
                      keyboardType: TextInputType.number,
                      validator: (val) => val == null || val.isEmpty
                          ? 'Comissão obrigatória'
                          : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: AppInput(
                      label: 'Telefone',
                      placeholder: 'Ex: (11) 97777-2222',
                      controller: _phoneController,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppInput(
                      label: 'CPF',
                      placeholder: 'Ex: 123.456.789-00',
                      controller: _cpfController,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              AppInput(
                label: 'E-mail',
                placeholder: 'Ex: arthur@barberosbao.com',
                controller: _emailController,
              ),
              const SizedBox(height: 12),
              AppInput(
                label: 'Especialidades (separadas por vírgula)',
                placeholder: 'Ex: Corte Degradê, Platinado, Barba',
                controller: _specialtiesController,
              ),
              const SizedBox(height: 12),
              AppInput(
                label: 'Horário de Trabalho',
                placeholder: 'Ex: 09:00 - 18:00',
                controller: _horarioController,
              ),
              const SizedBox(height: 12),
              AppInput(
                label: 'Foto (URL)',
                placeholder: 'Ex: https://unsplash.com/...',
                controller: _avatarUrlController,
              ),
              const SizedBox(height: 16),
              const Text(
                'Dias Disponíveis',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _weekDays.map((day) {
                  final isSelected = _selectedDays.contains(day);
                  return FilterChip(
                    label: Text(
                      day,
                      style: TextStyle(
                        color: isSelected ? Colors.black : Colors.white,
                        fontSize: 11,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: ThemeColors.primary,
                    backgroundColor: ThemeColors.darkSurface,
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
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text(
                  'Funcionário Ativo',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                value: _active,
                activeThumbColor: ThemeColors.primary,
                onChanged: (val) => setState(() => _active = val),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Cancelar',
            style: TextStyle(color: Colors.white70),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: ThemeColors.primary),
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              final specs = _specialtiesController.text
                  .split(',')
                  .map((s) => s.trim())
                  .where((s) => s.isNotEmpty)
                  .toList();
              final commVal =
                  (double.tryParse(_commissionRateController.text.trim()) ??
                      30.0) /
                  100.0;

              final newFunc = Funcionario(
                id: employee?.id ?? '',
                name: _nameController.text.trim(),
                avatarUrl: _avatarUrlController.text.isNotEmpty
                    ? _avatarUrlController.text.trim()
                    : 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?q=80&width=150',
                cargo: _cargoController.text.trim(),
                phone: _phoneController.text.trim(),
                email: _emailController.text.trim(),
                cpf: _cpfController.text.trim(),
                specialties: specs.isNotEmpty ? specs : ['Corte'],
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
          child: const Text('Salvar', style: TextStyle(color: Colors.black)),
        ),
      ],
    );
  }
}
