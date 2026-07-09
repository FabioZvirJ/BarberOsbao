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
import 'package:barber_osbao/packages/design_system/atoms/app_avatar.dart';
import 'package:barber_osbao/packages/design_system/molecules/app_input.dart';
import 'package:barber_osbao/packages/core/shared/state/app_state.dart';
import 'package:barber_osbao/features/clientes/domain/models/cliente.dart';
import 'package:barber_osbao/features/clientes/presentation/controllers/clientes_controller.dart';

class ClientesPage extends ConsumerStatefulWidget {
  const ClientesPage({super.key});

  @override
  ConsumerState<ClientesPage> createState() => _ClientesPageState();
}

class _ClientesPageState extends ConsumerState<ClientesPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedStatus = 'Todos';
  String _orderBy = 'Nome'; // 'Nome', 'Gasto', 'Visita'

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(clientesControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppPage(
      title: 'Clientes',
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
                  placeholder: 'Pesquisar por nome, email ou telefone...',
                  onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
                  onClear: () => setState(() => _searchQuery = ''),
                ),
              ),
              const SizedBox(width: 16),
              AppButton(
                label: 'Novo Cliente',
                icon: const Icon(Icons.add, size: 16),
                onPressed: () => _showFormDialog(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppFilters(
                options: const ['Todos', 'Ativos', 'Inativos'],
                selectedOption: _selectedStatus,
                onSelected: (val) => setState(() => _selectedStatus = val),
              ),
              // Sorting dropdown
              Row(
                children: [
                  const Text('Ordenar por: ', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(width: 8),
                  DropdownButton<String>(
                    dropdownColor: ThemeColors.darkBg,
                    value: _orderBy,
                    underline: const SizedBox(),
                    style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 13, fontWeight: FontWeight.bold),
                    items: const [
                      DropdownMenuItem(value: 'Nome', child: Text('Nome')),
                      DropdownMenuItem(value: 'Gasto', child: Text('Total Gasto')),
                      DropdownMenuItem(value: 'Visita', child: Text('Última Visita')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _orderBy = val);
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),

          AppSection(
            title: 'Base de Clientes',
            subtitle: 'Lista de clientes cadastrados no sistema ERP',
            child: _buildContent(state, isDark),
          ),
        ],
      ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0, curve: Curves.easeOut),
    );
  }

  Widget _buildContent(AppState<List<Cliente>> state, bool isDark) {
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
        child: Text('Nenhum cliente cadastrado.', style: TextStyle(color: isDark ? Colors.white30 : Colors.grey)),
      );
    }

    // Apply filters
    var filtered = data.where((c) {
      final matchesSearch = c.name.toLowerCase().contains(_searchQuery) ||
          c.email.toLowerCase().contains(_searchQuery) ||
          c.phone.contains(_searchQuery);
      
      final matchesStatus = _selectedStatus == 'Todos' ||
          (_selectedStatus == 'Ativos' && c.status == 'active') ||
          (_selectedStatus == 'Inativos' && c.status == 'inactive');

      return matchesSearch && matchesStatus;
    }).toList();

    // Apply sorting
    if (_orderBy == 'Nome') {
      filtered.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    } else if (_orderBy == 'Gasto') {
      filtered.sort((a, b) => b.totalGasto.compareTo(a.totalGasto));
    } else if (_orderBy == 'Visita') {
      filtered.sort((a, b) => b.ultimaVisita.compareTo(a.ultimaVisita));
    }

    if (filtered.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        alignment: Alignment.center,
        child: Text('Nenhum cliente correspondente aos filtros.', style: TextStyle(color: isDark ? Colors.white30 : Colors.grey)),
      );
    }

    return AppTable(
      columns: [
        AppTableColumn(label: 'FOTO', width: 60),
        AppTableColumn(label: 'NOME'),
        AppTableColumn(label: 'TELEFONE'),
        AppTableColumn(label: 'EMAIL'),
        AppTableColumn(label: 'NASCIMENTO'),
        AppTableColumn(label: 'PLANO'),
        AppTableColumn(label: 'ÚLT. VISITA'),
        AppTableColumn(label: 'TOTAL GASTO'),
        AppTableColumn(label: 'STATUS'),
        AppTableColumn(label: 'AÇÕES', width: 140),
      ],
      rows: filtered.map((c) {
        return AppTableRow(
          cells: [
            AppAvatar(url: c.avatarUrl, size: 36),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                if (c.observacoes.isNotEmpty)
                  Text(
                    c.observacoes,
                    style: const TextStyle(fontSize: 10, color: Colors.grey, fontStyle: FontStyle.italic),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
            Text(c.phone),
            Text(c.email),
            Text(c.nascimento),
            Text(
              c.plano,
              style: TextStyle(
                fontWeight: c.plano != 'Nenhum' ? FontWeight.bold : FontWeight.normal,
                color: c.plano != 'Nenhum' ? ThemeColors.primary : null,
              ),
            ),
            Text(c.ultimaVisita),
            Text(
              'R\$ ${c.totalGasto.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold, color: ThemeColors.success),
            ),
            AppStatusChip(
              label: c.status == 'active' ? 'Ativo' : 'Inativo',
              type: c.status == 'active' ? AppStatusType.success : AppStatusType.danger,
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.history, size: 18),
                  onPressed: () => _showHistoryDialog(context, c),
                  tooltip: 'Visualizar Histórico',
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  onPressed: () => _showFormDialog(context, c),
                  tooltip: 'Editar',
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18, color: ThemeColors.danger),
                  onPressed: () => _showDeleteDialog(context, c),
                  tooltip: 'Excluir',
                ),
              ],
            ),
          ],
        );
      }).toList(),
    );
  }

  void _showFormDialog(BuildContext context, [Cliente? customer]) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: customer?.name ?? '');
    final emailController = TextEditingController(text: customer?.email ?? '');
    final phoneController = TextEditingController(text: customer?.phone ?? '');
    final nascimentoController = TextEditingController(text: customer?.nascimento ?? '');
    final avatarUrlController = TextEditingController(text: customer?.avatarUrl ?? '');
    final observacoesController = TextEditingController(text: customer?.observacoes ?? '');
    String plano = customer?.plano ?? 'Nenhum';
    String status = customer?.status ?? 'active';

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: ThemeColors.darkBg,
              title: Text(customer == null ? 'Cadastrar Cliente' : 'Editar Cliente', style: const TextStyle(color: Colors.white)),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppInput(
                        label: 'Nome Completo',
                        placeholder: 'Ex: João Carlos da Silva',
                        controller: nameController,
                        validator: (val) => val == null || val.isEmpty ? 'Nome obrigatório' : null,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: AppInput(
                              label: 'Telefone',
                              placeholder: 'Ex: (11) 99999-9999',
                              controller: phoneController,
                              validator: (val) => val == null || val.isEmpty ? 'Telefone obrigatório' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppInput(
                              label: 'Nascimento',
                              placeholder: 'Ex: 15/08/1990',
                              controller: nascimentoController,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      AppInput(
                        label: 'E-mail',
                        placeholder: 'Ex: joao@gmail.com',
                        controller: emailController,
                      ),
                      const SizedBox(height: 12),
                      AppInput(
                        label: 'URL da Foto (Avatar)',
                        placeholder: 'Ex: https://images.unsplash.com/...',
                        controller: avatarUrlController,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              dropdownColor: ThemeColors.darkBg,
                              value: plano,
                              decoration: const InputDecoration(
                                labelText: 'Plano',
                                labelStyle: TextStyle(color: Colors.white70),
                                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
                              ),
                              style: const TextStyle(color: Colors.white),
                              items: const [
                                DropdownMenuItem(value: 'Nenhum', child: Text('Nenhum')),
                                DropdownMenuItem(value: 'Plano Cavalheiro', child: Text('Plano Cavalheiro')),
                                DropdownMenuItem(value: 'Plano Barão', child: Text('Plano Barão')),
                                DropdownMenuItem(value: 'Plano Imperial', child: Text('Plano Imperial')),
                              ],
                              onChanged: (val) {
                                if (val != null) setState(() => plano = val);
                              },
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
                                DropdownMenuItem(value: 'active', child: Text('Ativo')),
                                DropdownMenuItem(value: 'inactive', child: Text('Inativo')),
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
                        label: 'Observações',
                        placeholder: 'Ex: Alérgico a produtos mentolados...',
                        controller: observacoesController,
                        maxLines: 3,
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
                      final newCli = Cliente(
                        id: customer?.id ?? '',
                        name: nameController.text.trim(),
                        email: emailController.text.trim(),
                        phone: phoneController.text.trim(),
                        avatarUrl: avatarUrlController.text.isNotEmpty
                            ? avatarUrlController.text.trim()
                            : 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&width=150',
                        nascimento: nascimentoController.text.trim(),
                        plano: plano,
                        ultimaVisita: customer?.ultimaVisita ?? 'Nunca',
                        totalGasto: customer?.totalGasto ?? 0.0,
                        observacoes: observacoesController.text.trim(),
                        status: status,
                      );

                      if (customer == null) {
                        ref.read(clientesControllerProvider.notifier).addCliente(newCli);
                      } else {
                        ref.read(clientesControllerProvider.notifier).editCliente(newCli);
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

  void _showDeleteDialog(BuildContext context, Cliente customer) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ThemeColors.darkBg,
        title: const Text('Excluir Cliente', style: TextStyle(color: Colors.white)),
        content: Text('Tem certeza que deseja excluir o cliente "${customer.name}"? Isso apagará permanentemente o registro comercial.', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: ThemeColors.danger),
            onPressed: () {
              ref.read(clientesControllerProvider.notifier).removeCliente(customer.id);
              Navigator.of(ctx).pop();
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showHistoryDialog(BuildContext context, Cliente customer) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ThemeColors.darkBg,
        title: Row(
          children: [
            AppAvatar(url: customer.avatarUrl, size: 36),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(customer.name, style: const TextStyle(color: Colors.white, fontSize: 16)),
                  Text(customer.email, style: const TextStyle(color: Colors.grey, fontSize: 11)),
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
              const Text('Histórico de Visitas Recentes', style: TextStyle(color: ThemeColors.primary, fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.check_circle, color: ThemeColors.success),
                title: const Text('Corte + Barba (Arthur Santos)', style: TextStyle(color: Colors.white, fontSize: 13)),
                subtitle: Text('Data: ${customer.ultimaVisita} - R\$ 80.00', style: const TextStyle(color: Colors.grey, fontSize: 11)),
              ),
              const Divider(color: Colors.white10),
              const ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.check_circle, color: ThemeColors.success),
                title: Text('Corte Degradê (Marcos Silva)', style: TextStyle(color: Colors.white, fontSize: 13)),
                subtitle: Text('Data: 10/05/2026 - R\$ 45.00', style: TextStyle(color: Colors.grey, fontSize: 11)),
              ),
              const Divider(color: Colors.white10),
              const ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.check_circle, color: ThemeColors.success),
                title: Text('Design de Sobrancelha (Gabriel Neves)', style: TextStyle(color: Colors.white, fontSize: 13)),
                subtitle: Text('Data: 15/04/2026 - R\$ 20.00', style: TextStyle(color: Colors.grey, fontSize: 11)),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total Consumido:', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  Text('R\$ ${customer.totalGasto.toStringAsFixed(2)}', style: const TextStyle(color: ThemeColors.success, fontWeight: FontWeight.bold, fontSize: 15)),
                ],
              ),
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
