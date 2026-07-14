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

    return AppPage(
      title: 'Funcionários',
      userName: 'Fábio Zvir',
      userAvatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&width=150',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: AppSearchBar(
                  controller: _searchController,
                  placeholder: 'Pesquisar profissional por nome, cargo ou especialidade...',
                  onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
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
            subtitle: 'Lista de barbeiros, especialidades, horários e comissões',
            child: _buildContent(state, isDark),
          ),
        ],
      ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0, curve: Curves.easeOut),
    );
  }

  Widget _buildContent(AppState<List<Funcionario>> state, bool isDark) {
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
        child: Text('Nenhum profissional cadastrado.', style: TextStyle(color: isDark ? Colors.white30 : Colors.grey)),
      );
    }

    final filtered = data.where((f) {
      final matchesSearch = f.name.toLowerCase().contains(_searchQuery) ||
          f.cargo.toLowerCase().contains(_searchQuery) ||
          f.specialties.any((s) => s.toLowerCase().contains(_searchQuery));

      final matchesStatus = _selectedStatus == 'Todos' ||
          (_selectedStatus == 'Ativo' && f.status) ||
          (_selectedStatus == 'Inativo' && !f.status);

      return matchesSearch && matchesStatus;
    }).toList();

    if (filtered.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        alignment: Alignment.center,
        child: Text('Nenhum profissional correspondente aos filtros.', style: TextStyle(color: isDark ? Colors.white30 : Colors.grey)),
      );
    }

    return AppTable(
      columns: [
        AppTableColumn(label: 'BARBEIRO', width: 200),
        AppTableColumn(label: 'CARGO'),
        AppTableColumn(label: 'ESPECIALIDADES'),
        AppTableColumn(label: 'COMISSÃO'),
        AppTableColumn(label: 'HORÁRIO'),
        AppTableColumn(label: 'AVALIAÇÃO'),
        AppTableColumn(label: 'STATUS'),
        AppTableColumn(label: 'AÇÕES', width: 140),
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
                      Text(f.name, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text(f.phone, style: const TextStyle(fontSize: 10, color: Colors.grey)),
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
                Text(f.rating.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            AppStatusChip(
              label: f.status ? 'Ativo' : 'Inativo',
              type: f.status ? AppStatusType.success : AppStatusType.danger,
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.calendar_month, size: 18),
                  onPressed: () => _showAgendaDialog(context, f),
                  tooltip: 'Visualizar Agenda',
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  onPressed: () => _showFormDialog(context, f),
                  tooltip: 'Editar',
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18, color: ThemeColors.danger),
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
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: employee?.name ?? '');
    final cargoController = TextEditingController(text: employee?.cargo ?? '');
    final phoneController = TextEditingController(text: employee?.phone ?? '');
    final emailController = TextEditingController(text: employee?.email ?? '');
    final cpfController = TextEditingController(text: employee?.cpf ?? '');
    final specialtiesController = TextEditingController(text: employee?.specialties.join(", ") ?? '');
    final commissionRateController = TextEditingController(text: employee != null ? (employee.commissionRate * 100).toStringAsFixed(0) : '30');
    final horarioController = TextEditingController(text: employee?.horarioTrabalho ?? '09:00 - 18:00');
    final avatarUrlController = TextEditingController(text: employee?.avatarUrl ?? '');
    
    // Days selection state
    List<String> selectedDays = List.from(employee?.diasDisponiveis ?? ['Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado']);
    List<String> selectedFolgas = List.from(employee?.folgas ?? ['Domingo']);
    bool active = employee?.status ?? true;

    final weekDays = ['Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado', 'Domingo'];

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: ThemeColors.darkBg,
              title: Text(employee == null ? 'Cadastrar Funcionário' : 'Editar Funcionário', style: const TextStyle(color: Colors.white)),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppInput(
                        label: 'Nome Completo',
                        placeholder: 'Ex: Arthur Mendes',
                        controller: nameController,
                        validator: (val) => val == null || val.isEmpty ? 'Nome obrigatório' : null,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: AppInput(
                              label: 'Cargo / Função',
                              placeholder: 'Ex: Barbeiro Specialist',
                              controller: cargoController,
                              validator: (val) => val == null || val.isEmpty ? 'Cargo obrigatório' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppInput(
                              label: 'Comissão (%)',
                              placeholder: 'Ex: 30',
                              controller: commissionRateController,
                              keyboardType: TextInputType.number,
                              validator: (val) => val == null || val.isEmpty ? 'Comissão obrigatória' : null,
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
                              controller: phoneController,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppInput(
                              label: 'CPF',
                              placeholder: 'Ex: 123.456.789-00',
                              controller: cpfController,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      AppInput(
                        label: 'E-mail',
                        placeholder: 'Ex: arthur@barberosbao.com',
                        controller: emailController,
                      ),
                      const SizedBox(height: 12),
                      AppInput(
                        label: 'Especialidades (separadas por vírgula)',
                        placeholder: 'Ex: Corte Degradê, Platinado, Barba',
                        controller: specialtiesController,
                      ),
                      const SizedBox(height: 12),
                      AppInput(
                        label: 'Horário de Trabalho',
                        placeholder: 'Ex: 09:00 - 18:00',
                        controller: horarioController,
                      ),
                      const SizedBox(height: 12),
                      AppInput(
                        label: 'Foto (URL)',
                        placeholder: 'Ex: https://unsplash.com/...',
                        controller: avatarUrlController,
                      ),
                      const SizedBox(height: 16),
                      const Text('Dias Disponíveis', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: weekDays.map((day) {
                          final isSelected = selectedDays.contains(day);
                          return FilterChip(
                            label: Text(day, style: TextStyle(color: isSelected ? Colors.black : Colors.white, fontSize: 11)),
                            selected: isSelected,
                            selectedColor: ThemeColors.primary,
                            backgroundColor: ThemeColors.darkSurface,
                            onSelected: (val) {
                              setState(() {
                                if (val) {
                                  selectedDays.add(day);
                                  selectedFolgas.remove(day);
                                } else {
                                  selectedDays.remove(day);
                                  selectedFolgas.add(day);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text('Funcionário Ativo', style: TextStyle(color: Colors.white70, fontSize: 14)),
                        value: active,
                        activeThumbColor: ThemeColors.primary,
                        onChanged: (val) => setState(() => active = val),
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
                      final specs = specialtiesController.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
                      final commVal = (double.tryParse(commissionRateController.text.trim()) ?? 30.0) / 100.0;
                      
                      final newFunc = Funcionario(
                        id: employee?.id ?? '',
                        name: nameController.text.trim(),
                        avatarUrl: avatarUrlController.text.isNotEmpty
                            ? avatarUrlController.text.trim()
                            : 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?q=80&width=150',
                        cargo: cargoController.text.trim(),
                        phone: phoneController.text.trim(),
                        email: emailController.text.trim(),
                        cpf: cpfController.text.trim(),
                        specialties: specs.isNotEmpty ? specs : ['Corte'],
                        commissionRate: commVal,
                        horarioTrabalho: horarioController.text.trim(),
                        diasDisponiveis: selectedDays,
                        folgas: selectedFolgas,
                        status: active,
                        rating: employee?.rating ?? 5.0,
                      );

                      if (employee == null) {
                        ref.read(funcionariosControllerProvider.notifier).addFuncionario(newFunc);
                      } else {
                        ref.read(funcionariosControllerProvider.notifier).editFuncionario(newFunc);
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

  void _showDeleteDialog(BuildContext context, Funcionario employee) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ThemeColors.darkBg,
        title: const Text('Excluir Funcionário', style: TextStyle(color: Colors.white)),
        content: Text('Tem certeza que deseja excluir o profissional "${employee.name}"? Isso apagará seu histórico de comissões.', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: ThemeColors.danger),
            onPressed: () {
              ref.read(funcionariosControllerProvider.notifier).removeFuncionario(employee.id);
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
                  Text('Agenda de ${employee.name}', style: const TextStyle(color: Colors.white, fontSize: 16)),
                  Text(employee.cargo, style: const TextStyle(color: Colors.grey, fontSize: 11)),
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
              const Text('Próximos Compromissos (Hoje)', style: TextStyle(color: ThemeColors.primary, fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 16),
              const ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Text('09:00', style: TextStyle(color: ThemeColors.primary, fontWeight: FontWeight.bold)),
                title: Text('João Silva', style: TextStyle(color: Colors.white, fontSize: 13)),
                subtitle: Text('Corte + Barba - Confirmado', style: TextStyle(color: Colors.grey, fontSize: 11)),
              ),
              const Divider(color: Colors.white10),
              const ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Text('10:30', style: TextStyle(color: ThemeColors.primary, fontWeight: FontWeight.bold)),
                title: Text('Carlos Oliveira', style: TextStyle(color: Colors.white, fontSize: 13)),
                subtitle: Text('Corte Degradê - Confirmado', style: TextStyle(color: Colors.grey, fontSize: 11)),
              ),
              const Divider(color: Colors.white10),
              const ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Text('14:30', style: TextStyle(color: ThemeColors.primary, fontWeight: FontWeight.bold)),
                title: Text('Pedro Almeida', style: TextStyle(color: Colors.white, fontSize: 13)),
                subtitle: Text('Corte + Barba + Sobrancelha - Pendente', style: TextStyle(color: Colors.grey, fontSize: 11)),
              ),
              const SizedBox(height: 16),
              Text('Horário de Trabalho: ${employee.horarioTrabalho}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
              Text('Dias de Trabalho: ${employee.diasDisponiveis.join(", ")}', style: const TextStyle(color: Colors.white54, fontSize: 11)),
            ],
          ),
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
}
