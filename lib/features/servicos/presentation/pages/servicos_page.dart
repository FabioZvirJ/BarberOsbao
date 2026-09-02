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
import 'package:barber_osbao/packages/design_system/molecules/app_image_upload.dart';
import 'package:barber_osbao/packages/core/shared/state/app_state.dart';
import 'package:barber_osbao/features/servicos/domain/models/servico.dart';
import 'package:barber_osbao/features/servicos/presentation/controllers/servicos_controller.dart';
import 'package:barber_osbao/features/categorias/presentation/controllers/categorias_controller.dart';

class ServicosPage extends ConsumerStatefulWidget {
  const ServicosPage({super.key});

  @override
  ConsumerState<ServicosPage> createState() => _ServicosPageState();
}

class _ServicosPageState extends ConsumerState<ServicosPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'Todos';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(servicosControllerProvider);
    final categoriesState = ref.watch(categoriasControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = AppBreakpoints.isMobile(context);

    // Resolve categories
    final List<String> categories = ['Todos'];
    if (categoriesState is AppSuccess<dynamic>) {
      final list = (categoriesState as AppSuccess).data;
      for (final cat in list) {
        if (cat.tipo == 'servicos') {
          categories.add(cat.nome);
        }
      }
    }
    // Fallback if empty or loading
    if (categories.length == 1) {
      categories.addAll(['Cabelo', 'Barba', 'Sobrancelha', 'Combo']);
    }

    return AppPage(
      title: 'Serviços',
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
              placeholder: 'Pesquisar serviço por nome ou descrição...',
              onChanged: (val) =>
                  setState(() => _searchQuery = val.toLowerCase()),
              onClear: () => setState(() => _searchQuery = ''),
            ),
            const SizedBox(height: 10),
            AppButton(
              label: 'Novo Serviço',
              icon: const Icon(Icons.add, size: 16),
              onPressed: () => _showFormDialog(
                context,
                categories.where((c) => c != 'Todos').toList(),
              ),
            ),
          ] else
            Row(
              children: [
                Expanded(
                  child: AppSearchBar(
                    controller: _searchController,
                    placeholder: 'Pesquisar serviço por nome ou descrição...',
                    onChanged: (val) =>
                        setState(() => _searchQuery = val.toLowerCase()),
                    onClear: () => setState(() => _searchQuery = ''),
                  ),
                ),
                const SizedBox(width: 16),
                AppButton(
                  label: 'Novo Serviço',
                  icon: const Icon(Icons.add, size: 16),
                  onPressed: () => _showFormDialog(
                    context,
                    categories.where((c) => c != 'Todos').toList(),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 16),
          AppFilters(
            options: categories,
            selectedOption: _selectedCategory,
            onSelected: (val) => setState(() => _selectedCategory = val),
          ),
          const SizedBox(height: 32),

          AppSection(
            title: 'Catálogo de Serviços',
            subtitle:
                'Lista de serviços oferecidos na barbearia. Use as setas para reordenar a exibição.',
            child: _buildContent(
              state,
              isDark,
              categories.where((c) => c != 'Todos').toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    AppState<List<Servico>> state,
    bool isDark,
    List<String> formCategories,
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
          'Nenhum serviço cadastrado.',
          style: TextStyle(color: isDark ? Colors.white30 : Colors.grey),
        ),
      );
    }

    final filtered = data.where((s) {
      final matchesSearch =
          s.name.toLowerCase().contains(_searchQuery) ||
          s.description.toLowerCase().contains(_searchQuery);
      final matchesCategory =
          _selectedCategory == 'Todos' || s.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    if (filtered.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        alignment: Alignment.center,
        child: Text(
          'Nenhum serviço correspondente aos filtros.',
          style: TextStyle(color: isDark ? Colors.white30 : Colors.grey),
        ),
      );
    }

    return AppTable(
      minWidth: 900,
      columns: [
        AppTableColumn(label: 'IMAGEM', width: 50),
        AppTableColumn(label: 'NOME DO SERVIÇO', flex: 3),
        AppTableColumn(label: 'CATEGORIA', flex: 2),
        AppTableColumn(label: 'DURAÇÃO', width: 90),
        AppTableColumn(label: 'PREÇO', width: 100),
        AppTableColumn(label: 'COR', width: 60),
        AppTableColumn(label: 'STATUS', width: 85),
        AppTableColumn(label: 'REORDENAR', width: 90),
        AppTableColumn(label: 'AÇÕES', width: 90),
      ],
      rows: filtered.map((s) {
        final idx = data.indexOf(s);
        return AppTableRow(
          cells: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                s.imageUrl,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.content_cut, size: 24),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (s.description.isNotEmpty)
                  Text(
                    s.description,
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
            Text(s.category.toUpperCase()),
            Text('${s.durationMinutes} min'),
            Text(
              'R\$ ${s.price.toStringAsFixed(2)}',
              style: const TextStyle(
                color: ThemeColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: Color(int.parse('FF${s.colorHex}', radix: 16)),
                shape: BoxShape.circle,
              ),
            ),
            AppStatusChip(
              label: s.status ? 'Ativo' : 'Inativo',
              type: s.status ? AppStatusType.success : AppStatusType.danger,
            ),
            // Reorder actions
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_upward, size: 16),
                  onPressed: idx > 0
                      ? () {
                          final updated = List<Servico>.from(data);
                          final temp = updated[idx];
                          updated[idx] = updated[idx - 1];
                          updated[idx - 1] = temp;
                          ref
                              .read(servicosControllerProvider.notifier)
                              .updateOrder(updated);
                        }
                      : null,
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_downward, size: 16),
                  onPressed: idx < data.length - 1
                      ? () {
                          final updated = List<Servico>.from(data);
                          final temp = updated[idx];
                          updated[idx] = updated[idx + 1];
                          updated[idx + 1] = temp;
                          ref
                              .read(servicosControllerProvider.notifier)
                              .updateOrder(updated);
                        }
                      : null,
                ),
              ],
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  onPressed: () => _showFormDialog(context, formCategories, s),
                  tooltip: 'Editar',
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    size: 18,
                    color: ThemeColors.danger,
                  ),
                  onPressed: () => _showDeleteDialog(context, s),
                  tooltip: 'Excluir',
                ),
              ],
            ),
          ],
        );
      }).toList(),
    );
  }

  void _showDeleteDialog(BuildContext context, Servico service) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? ThemeColors.darkSurface : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: Text(
          'Excluir Serviço',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Tem certeza que deseja excluir o serviço "${service.name}"? Clientes não conseguirão mais agendá-lo.',
          style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
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
              backgroundColor: ThemeColors.danger,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            onPressed: () {
              ref
                  .read(servicosControllerProvider.notifier)
                  .removeServico(service.id);
              Navigator.of(ctx).pop();
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showFormDialog(
    BuildContext context,
    List<String> categories, [
    Servico? service,
  ]) {
    showDialog(
      context: context,
      builder: (ctx) =>
          _ServicoFormDialog(categories: categories, service: service),
    );
  }
}

class _ServicoFormDialog extends ConsumerStatefulWidget {
  final List<String> categories;
  final Servico? service;

  const _ServicoFormDialog({required this.categories, this.service});

  @override
  ConsumerState<_ServicoFormDialog> createState() => _ServicoFormDialogState();
}

class _ServicoFormDialogState extends ConsumerState<_ServicoFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _durationController;
  late final TextEditingController _imageUrlController;
  late String _category;
  late String _colorHex;
  late bool _status;

  final _colorOptions = const [
    {'name': 'Dourado', 'hex': 'C89B3C'},
    {'name': 'Verde', 'hex': '22C55E'},
    {'name': 'Azul', 'hex': '3B82F6'},
    {'name': 'Roxo', 'hex': 'A855F7'},
    {'name': 'Vermelho', 'hex': 'EF4444'},
  ];

  @override
  void initState() {
    super.initState();
    final s = widget.service;
    _nameController = TextEditingController(text: s?.name ?? '');
    _descriptionController = TextEditingController(text: s?.description ?? '');
    _priceController = TextEditingController(text: s?.price.toString() ?? '');
    _durationController = TextEditingController(
      text: s?.durationMinutes.toString() ?? '30',
    );
    _imageUrlController = TextEditingController(text: s?.imageUrl ?? '');
    _category =
        s?.category ??
        (widget.categories.isNotEmpty ? widget.categories[0] : 'Cabelo');
    _colorHex = s?.colorHex ?? 'C89B3C';
    _status = s?.status ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final service = widget.service;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      backgroundColor: isDark ? ThemeColors.darkSurface : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      title: Text(
        service == null ? 'Criar Serviço' : 'Editar Serviço',
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppInput(
                label: 'Nome do Serviço',
                placeholder: 'Ex: Barboterapia Completa',
                controller: _nameController,
                validator: (val) =>
                    val == null || val.isEmpty ? 'Nome obrigatório' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Categoria',
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
                          initialValue: _category,
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
                          items: widget.categories
                              .map(
                                (c) =>
                                    DropdownMenuItem(value: c, child: Text(c)),
                              )
                              .toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _category = val);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppInput(
                      label: 'Preço (R\$)',
                      placeholder: 'Ex: 45.00',
                      controller: _priceController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (val) => val == null || val.isEmpty
                          ? 'Preço obrigatório'
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
                      label: 'Duração (minutos)',
                      placeholder: 'Ex: 30',
                      controller: _durationController,
                      keyboardType: TextInputType.number,
                      validator: (val) => val == null || val.isEmpty
                          ? 'Duração obrigatória'
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cor do Card',
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
                          initialValue: _colorHex,
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
                          items: _colorOptions
                              .map(
                                (c) => DropdownMenuItem(
                                  value: c['hex'],
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: Color(
                                            int.parse(
                                              'FF${c['hex']!}',
                                              radix: 16,
                                            ),
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(c['name']!),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _colorHex = val);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              AppImageUpload(
                label: 'Foto do Serviço',
                controller: _imageUrlController,
                height: 130,
                helperText: 'Upload do arquivo ou informe o link',
              ),
              const SizedBox(height: 12),
              AppInput(
                label: 'Descrição do Serviço',
                placeholder: 'Ex: Detalhes do que está incluso...',
                controller: _descriptionController,
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: Text(
                  'Serviço Ativo',
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black87,
                    fontSize: 14,
                  ),
                ),
                value: _status,
                activeThumbColor: ThemeColors.primary,
                onChanged: (val) => setState(() => _status = val),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancelar',
            style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: ThemeColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              final newServico = Servico(
                id: service?.id ?? '',
                name: _nameController.text.trim(),
                category: _category,
                description: _descriptionController.text.trim(),
                price: double.tryParse(_priceController.text.trim()) ?? 0.0,
                durationMinutes:
                    int.tryParse(_durationController.text.trim()) ?? 30,
                imageUrl: _imageUrlController.text.isNotEmpty
                    ? _imageUrlController.text.trim()
                    : 'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?q=80&width=150',
                colorHex: _colorHex,
                status: _status,
              );

              if (service == null) {
                ref
                    .read(servicosControllerProvider.notifier)
                    .addServico(newServico);
              } else {
                ref
                    .read(servicosControllerProvider.notifier)
                    .editServico(newServico);
              }
              Navigator.of(context).pop();
            }
          },
          child: const Text(
            'Salvar',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
