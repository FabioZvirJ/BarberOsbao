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
import 'package:barber_osbao/packages/design_system/atoms/app_avatar.dart';
import 'package:barber_osbao/packages/design_system/molecules/app_input.dart';
import 'package:barber_osbao/packages/design_system/molecules/app_image_upload.dart';
import 'package:barber_osbao/packages/design_system/organisms/app_dialog.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:barber_osbao/packages/core/utils/app_formatters.dart';
import 'package:barber_osbao/packages/core/utils/app_masks.dart';
import 'package:barber_osbao/packages/core/shared/state/app_state.dart';
import 'package:barber_osbao/features/agenda/presentation/controllers/agenda_controller.dart';
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
    final isMobile = AppBreakpoints.isMobile(context);

    return AppPage(
      title: 'Clientes',
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
              placeholder: 'Pesquisar por nome, email ou telefone...',
              onChanged: (val) =>
                  setState(() => _searchQuery = val.toLowerCase()),
              onClear: () => setState(() => _searchQuery = ''),
            ),
            const SizedBox(height: 10),
            AppButton(
              label: 'Novo Cliente',
              icon: const Icon(Icons.add, size: 16),
              onPressed: () => _showFormDialog(context),
            ),
          ] else
            Row(
              children: [
                Expanded(
                  child: AppSearchBar(
                    controller: _searchController,
                    placeholder: 'Pesquisar por nome, email ou telefone...',
                    onChanged: (val) =>
                        setState(() => _searchQuery = val.toLowerCase()),
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
          // Filters — Wrap so they reflow on smaller screens
          Wrap(
            spacing: 12,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              AppFilters(
                options: const ['Todos', 'Ativos', 'Inativos'],
                selectedOption: _selectedStatus,
                onSelected: (val) => setState(() => _selectedStatus = val),
              ),
              // Sorting dropdown
              Row(
                children: [
                  const Text(
                    'Ordenar por: ',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(width: 8),
                  DropdownButton<String>(
                    dropdownColor: isDark
                        ? ThemeColors.darkSurface
                        : Colors.white,
                    value: _orderBy,
                    underline: const SizedBox(),
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Nome', child: Text('Nome')),
                      DropdownMenuItem(
                        value: 'Gasto',
                        child: Text('Total Gasto'),
                      ),
                      DropdownMenuItem(
                        value: 'Visita',
                        child: Text('Última Visita'),
                      ),
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
      ),
    );
  }

  Widget _buildContent(AppState<List<Cliente>> state, bool isDark) {
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
          'Nenhum cliente cadastrado.',
          style: TextStyle(color: isDark ? Colors.white30 : Colors.grey),
        ),
      );
    }

    // Apply filters
    var filtered = data.where((c) {
      final matchesSearch =
          c.name.toLowerCase().contains(_searchQuery) ||
          c.email.toLowerCase().contains(_searchQuery) ||
          c.phone.contains(_searchQuery);

      final matchesStatus =
          _selectedStatus == 'Todos' ||
          (_selectedStatus == 'Ativos' && c.status == 'active') ||
          (_selectedStatus == 'Inativos' && c.status == 'inactive');

      return matchesSearch && matchesStatus;
    }).toList();

    // Apply sorting
    if (_orderBy == 'Nome') {
      filtered.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );
    } else if (_orderBy == 'Gasto') {
      filtered.sort((a, b) => b.totalGasto.compareTo(a.totalGasto));
    } else if (_orderBy == 'Visita') {
      filtered.sort((a, b) => b.ultimaVisita.compareTo(a.ultimaVisita));
    }

    if (filtered.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        alignment: Alignment.center,
        child: Text(
          'Nenhum cliente correspondente aos filtros.',
          style: TextStyle(color: isDark ? Colors.white30 : Colors.grey),
        ),
      );
    }

    return AppTable(
      minWidth: 1050,
      columns: [
        AppTableColumn(label: 'FOTO', width: 50),
        AppTableColumn(label: 'NOME', flex: 3),
        AppTableColumn(label: 'TELEFONE', width: 165),
        AppTableColumn(label: 'EMAIL', flex: 2),
        AppTableColumn(label: 'NASCIMENTO', width: 105),
        AppTableColumn(label: 'PLANO', width: 100),
        AppTableColumn(label: 'ÚLT. VISITA', width: 105),
        AppTableColumn(label: 'TOTAL GASTO', width: 110),
        AppTableColumn(label: 'STATUS', width: 85),
        AppTableColumn(label: 'AÇÕES', width: 130),
      ],
      rows: filtered.map((c) {
        return AppTableRow(
          cells: [
            AppAvatar(url: c.avatarUrl, name: c.name, size: 36),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  c.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (c.observacoes.isNotEmpty)
                  Text(
                    c.observacoes,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
            InkWell(
              onTap: () async {
                final clean = c.phone.replaceAll(RegExp(r'\D'), '');
                if (clean.isNotEmpty) {
                  final ddi = clean.startsWith('55') ? clean : '55$clean';
                  final uri = Uri.parse('https://wa.me/$ddi');
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                }
              },
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        c.phone,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          decoration: TextDecoration.underline,
                          decorationColor: ThemeColors.success,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.chat, size: 13, color: ThemeColors.success),
                  ],
                ),
              ),
            ),
            Text(
              c.email,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              c.nascimento,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              c.plano,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: c.plano != 'Nenhum'
                    ? FontWeight.bold
                    : FontWeight.normal,
                color: c.plano != 'Nenhum' ? ThemeColors.primary : null,
              ),
            ),
            Text(c.ultimaVisita),
            Text(
              AppFormatters.formatCurrency(c.totalGasto),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: ThemeColors.success,
              ),
            ),
            AppStatusChip(
              label: c.status == 'active' ? 'Ativo' : 'Inativo',
              type: c.status == 'active'
                  ? AppStatusType.success
                  : AppStatusType.danger,
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
                  icon: const Icon(Icons.history, size: 18),
                  onPressed: () => _showHistoryDialog(context, c),
                  tooltip: 'Visualizar Histórico',
                ),
                const SizedBox(width: 4),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  onPressed: () => _showFormDialog(context, c),
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
                    c.status == 'active'
                        ? Icons.person_off_outlined
                        : Icons.person_add_alt_1_outlined,
                    size: 18,
                    color: c.status == 'active'
                        ? ThemeColors.warning
                        : ThemeColors.success,
                  ),
                  onPressed: () => _showDeleteDialog(context, c),
                  tooltip: c.status == 'active' ? 'Inativar Cliente' : 'Reativar Cliente',
                ),
              ],
            ),
          ],
        );
      }).toList(),
    );
  }

  void _showDeleteDialog(BuildContext context, Cliente customer) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCurrentlyActive = customer.status == 'active';

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
              isCurrentlyActive ? 'Inativar Cliente' : 'Reativar Cliente',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          isCurrentlyActive
              ? 'Deseja inativar o cliente "${customer.name}"? O cliente não aparecerá em novos agendamentos, mas todo o seu histórico de consumo de ${AppFormatters.formatCurrency(customer.totalGasto)} permanecerá seguro na base de dados.'
              : 'Deseja reativar o cadastro do cliente "${customer.name}" para permitir novos agendamentos?',
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
              final newStatus = isCurrentlyActive ? 'inactive' : 'active';
              ref
                  .read(clientesControllerProvider.notifier)
                  .editCliente(customer.copyWith(status: newStatus));
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isCurrentlyActive
                        ? 'Cliente "${customer.name}" inativado com sucesso.'
                        : 'Cliente "${customer.name}" reativado.',
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

  void _showHistoryDialog(BuildContext context, Cliente customer) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final agendaState = ref.watch(agendaControllerProvider);
    final allApts = agendaState.data ?? [];
    final customerAppointments = allApts.where((a) {
      return a.clientName.trim().toLowerCase() == customer.name.trim().toLowerCase();
    }).toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

    showDialog(
      context: context,
      builder: (ctx) => AppResponsiveDialog(
        title: customer.name,
        subtitle: '${customer.email.isNotEmpty ? customer.email : 'Sem e-mail'} • Plano: ${customer.plano}',
        maxWidth: 540,
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Fechar',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AppAvatar(url: customer.avatarUrl, name: customer.name, size: 48),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Telefone: ${customer.phone}',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Histórico de Visitas',
                  style: TextStyle(
                    color: ThemeColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${customerAppointments.length} agendamento(s)',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (customerAppointments.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
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
                      Icons.event_busy,
                      size: 40,
                      color: isDark ? Colors.white24 : Colors.black26,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Nenhum agendamento registrado para este cliente.',
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
                constraints: const BoxConstraints(maxHeight: 280),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: customerAppointments.length,
                  separatorBuilder: (_, _) => Divider(
                    height: 1,
                    color: isDark ? Colors.white10 : Colors.grey.shade200,
                  ),
                  itemBuilder: (context, index) {
                    final apt = customerAppointments[index];
                    final isCompleted =
                        apt.status == 'Concluído' || apt.status == 'completed';
                    final isCanceled =
                        apt.status == 'Cancelado' || apt.status == 'canceled';
                    final statusColor = isCompleted
                        ? ThemeColors.success
                        : (isCanceled ? ThemeColors.danger : ThemeColors.primary);

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        isCompleted
                            ? Icons.check_circle
                            : (isCanceled ? Icons.cancel : Icons.schedule),
                        color: statusColor,
                      ),
                      title: Text(
                        '${apt.serviceName} (${apt.barberName})',
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        'Data: ${AppFormatters.formatDateTime(apt.dateTime)} • Status: ${apt.status}',
                        style: const TextStyle(color: Colors.grey, fontSize: 11),
                      ),
                      trailing: Text(
                        AppFormatters.formatCurrency(apt.price),
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.03)
                    : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark ? ThemeColors.darkBorder : Colors.grey.shade200,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Consumido Histórico:',
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black87,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    AppFormatters.formatCurrency(customer.totalGasto),
                    style: const TextStyle(
                      color: ThemeColors.success,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFormDialog(BuildContext context, [Cliente? customer]) {
    showDialog(
      context: context,
      builder: (ctx) => _ClienteFormDialog(customer: customer),
    );
  }
}

class _ClienteFormDialog extends ConsumerStatefulWidget {
  final Cliente? customer;

  const _ClienteFormDialog({this.customer});

  @override
  ConsumerState<_ClienteFormDialog> createState() => _ClienteFormDialogState();
}

class _ClienteFormDialogState extends ConsumerState<_ClienteFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _nascimentoController;
  late final TextEditingController _avatarUrlController;
  late final TextEditingController _observacoesController;
  late String _plano;
  late String _status;

  @override
  void initState() {
    super.initState();
    final c = widget.customer;
    _nameController = TextEditingController(text: c?.name ?? '');
    _emailController = TextEditingController(text: c?.email ?? '');
    _phoneController = TextEditingController(text: c?.phone ?? '');
    _nascimentoController = TextEditingController(text: c?.nascimento ?? '');
    _avatarUrlController = TextEditingController(text: c?.avatarUrl ?? '');
    _observacoesController = TextEditingController(text: c?.observacoes ?? '');
    _plano = c?.plano ?? 'Nenhum';
    _status = c?.status ?? 'active';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _nascimentoController.dispose();
    _avatarUrlController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customer = widget.customer;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppResponsiveDialog(
      title: customer == null ? 'Cadastrar Cliente' : 'Editar Cliente',
      subtitle: customer == null
          ? 'Preencha os dados cadastrais e preferências do cliente'
          : 'Atualize os dados de contato, plano e observações',
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
              final newCli = Cliente(
                id: customer?.id ?? '',
                name: _nameController.text.trim(),
                email: _emailController.text.trim(),
                phone: _phoneController.text.trim(),
                avatarUrl: _avatarUrlController.text.trim(),
                nascimento: _nascimentoController.text.trim(),
                plano: _plano,
                ultimaVisita: customer?.ultimaVisita ?? 'Nunca',
                totalGasto: customer?.totalGasto ?? 0.0,
                observacoes: _observacoesController.text.trim(),
                status: _status,
              );

              if (customer == null) {
                ref
                    .read(clientesControllerProvider.notifier)
                    .addCliente(newCli);
              } else {
                ref
                    .read(clientesControllerProvider.notifier)
                    .editCliente(newCli);
              }
              Navigator.of(context).pop();
            }
          },
          child: const Text(
            'Salvar Cliente',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
      ],
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppInput(
              label: 'Nome Completo',
              placeholder: 'Ex: João Carlos da Silva',
              controller: _nameController,
              validator: (val) =>
                  val == null || val.trim().isEmpty ? 'Nome obrigatório' : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: AppInput(
                    label: 'Telefone',
                    placeholder: '(11) 99999-9999',
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [AppMasks.phone],
                    validator: AppValidators.phone(required: true),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      DateTime initial = DateTime.now().subtract(
                        const Duration(days: 365 * 25),
                      );
                      if (_nascimentoController.text.isNotEmpty) {
                        try {
                          final parts = _nascimentoController.text.split('/');
                          if (parts.length == 3) {
                            initial = DateTime(
                              int.parse(parts[2]),
                              int.parse(parts[1]),
                              int.parse(parts[0]),
                            );
                          }
                        } catch (_) {}
                      }
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: initial,
                        firstDate: DateTime(1920),
                        lastDate: DateTime.now(),
                        locale: const Locale('pt', 'BR'),
                      );
                      if (picked != null) {
                        _nascimentoController.text =
                            AppFormatters.formatDate(picked);
                      }
                    },
                    child: IgnorePointer(
                      child: AppInput(
                        label: 'Nascimento',
                        placeholder: 'DD/MM/AAAA',
                        controller: _nascimentoController,
                        inputFormatters: [AppMasks.date],
                        validator: AppValidators.date(),
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
                    label: 'E-mail',
                    placeholder: 'Ex: joao@gmail.com',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: AppValidators.email(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Plano do Clube',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        dropdownColor: isDark
                            ? ThemeColors.darkSurface
                            : Colors.white,
                        initialValue: _plano,
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
                            value: 'Nenhum',
                            child: Text('Nenhum'),
                          ),
                          DropdownMenuItem(
                            value: 'Plano Cavalheiro',
                            child: Text('Plano Cavalheiro'),
                          ),
                          DropdownMenuItem(
                            value: 'Plano Barão',
                            child: Text('Plano Barão'),
                          ),
                          DropdownMenuItem(
                            value: 'Plano Imperial',
                            child: Text('Plano Imperial'),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _plano = val);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AppImageUpload(
              label: 'Foto do Cliente (Avatar)',
              controller: _avatarUrlController,
              height: 140,
              helperText: 'Upload do arquivo ou informe o link',
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status do Cadastro',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  dropdownColor: isDark
                      ? ThemeColors.darkSurface
                      : Colors.white,
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
                    DropdownMenuItem(value: 'active', child: Text('Ativo')),
                    DropdownMenuItem(value: 'inactive', child: Text('Inativo')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _status = val);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            AppInput(
              label: 'Observações / Preferências',
              placeholder:
                  'Ex: Alérgico a produtos mentolados, prefere café expresso...',
              controller: _observacoesController,
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }
}
