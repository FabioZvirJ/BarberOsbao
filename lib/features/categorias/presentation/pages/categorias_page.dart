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
import 'package:barber_osbao/packages/core/shared/state/app_state.dart';
import 'package:barber_osbao/features/categorias/domain/models/categoria.dart';
import 'package:barber_osbao/features/categorias/presentation/controllers/categorias_controller.dart';

class CategoriasPage extends ConsumerStatefulWidget {
  const CategoriasPage({super.key});

  @override
  ConsumerState<CategoriasPage> createState() => _CategoriasPageState();
}

class _CategoriasPageState extends ConsumerState<CategoriasPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedType = 'Todos';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(categoriasControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = AppBreakpoints.isMobile(context);

    return AppPage(
      title: 'Categorias',
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
              placeholder: 'Pesquisar categoria por nome...',
              onChanged: (val) =>
                  setState(() => _searchQuery = val.toLowerCase()),
              onClear: () => setState(() => _searchQuery = ''),
            ),
            const SizedBox(height: 10),
            AppButton(
              label: 'Nova Categoria',
              icon: const Icon(Icons.add, size: 16),
              onPressed: () => _showFormDialog(context),
            ),
          ] else
            Row(
              children: [
                Expanded(
                  child: AppSearchBar(
                    controller: _searchController,
                    placeholder: 'Pesquisar categoria por nome...',
                    onChanged: (val) =>
                        setState(() => _searchQuery = val.toLowerCase()),
                    onClear: () => setState(() => _searchQuery = ''),
                  ),
                ),
                const SizedBox(width: 16),
                AppButton(
                  label: 'Nova Categoria',
                  icon: const Icon(Icons.add, size: 16),
                  onPressed: () => _showFormDialog(context),
                ),
              ],
            ),
          const SizedBox(height: 16),
          AppFilters(
            options: const ['Todos', 'Serviços', 'Produtos', 'Planos'],
            selectedOption: _selectedType,
            onSelected: (val) => setState(() => _selectedType = val),
          ),
          const SizedBox(height: 32),

          AppSection(
            title: 'Gerenciamento de Categorias',
            subtitle:
                'Cadastre e edite categorias usadas nos serviços, produtos e planos',
            child: _buildContent(state, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(AppState<List<Categoria>> state, bool isDark) {
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
          'Nenhuma categoria cadastrada.',
          style: TextStyle(color: isDark ? Colors.white30 : Colors.grey),
        ),
      );
    }

    // Filter type map
    final typeMap = {
      'Serviços': 'servicos',
      'Produtos': 'produtos',
      'Planos': 'planos',
    };

    final filtered = data.where((c) {
      final matchesSearch = c.nome.toLowerCase().contains(_searchQuery);
      final matchesType =
          _selectedType == 'Todos' || c.tipo == typeMap[_selectedType];
      return matchesSearch && matchesType;
    }).toList();

    if (filtered.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        alignment: Alignment.center,
        child: Text(
          'Nenhuma categoria correspondente aos filtros.',
          style: TextStyle(color: isDark ? Colors.white30 : Colors.grey),
        ),
      );
    }

    final displayType = {
      'servicos': 'Serviço',
      'produtos': 'Produto',
      'planos': 'Plano',
    };

    return AppTable(
      minWidth: 600,
      columns: [
        AppTableColumn(label: 'ID'),
        AppTableColumn(label: 'NOME DA CATEGORIA'),
        AppTableColumn(label: 'TIPO DE MÓDULO'),
        AppTableColumn(label: 'STATUS'),
        AppTableColumn(label: 'AÇÕES', width: 100),
      ],
      rows: filtered.map((cat) {
        return AppTableRow(
          cells: [
            Text(cat.id),
            Text(cat.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(displayType[cat.tipo] ?? cat.tipo.toUpperCase()),
            const AppStatusChip(label: 'Ativo', type: AppStatusType.success),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  onPressed: () => _showFormDialog(context, cat),
                  tooltip: 'Editar',
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    size: 18,
                    color: ThemeColors.danger,
                  ),
                  onPressed: () => _showDeleteDialog(context, cat),
                  tooltip: 'Excluir',
                ),
              ],
            ),
          ],
        );
      }).toList(),
    );
  }

  void _showFormDialog(BuildContext context, [Categoria? category]) {
    showDialog(
      context: context,
      builder: (ctx) => _CategoriaFormDialog(category: category),
    );
  }

  void _showDeleteDialog(BuildContext context, Categoria category) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? ThemeColors.darkSurface : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: Text(
          'Excluir Categoria',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Tem certeza que deseja excluir a categoria "${category.nome}"? Ela pode estar vinculada a outros cadastros.',
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
            onPressed: () {
              ref
                  .read(categoriasControllerProvider.notifier)
                  .removeCategoria(category.id);
              Navigator.of(ctx).pop();
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _CategoriaFormDialog extends ConsumerStatefulWidget {
  final Categoria? category;

  const _CategoriaFormDialog({this.category});

  @override
  ConsumerState<_CategoriaFormDialog> createState() =>
      _CategoriaFormDialogState();
}

class _CategoriaFormDialogState extends ConsumerState<_CategoriaFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomeController;
  late String _tipo;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.category?.nome ?? '');
    _tipo = widget.category?.tipo ?? 'servicos';
  }

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final category = widget.category;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      backgroundColor: isDark ? ThemeColors.darkSurface : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      title: Text(
        category == null ? 'Criar Categoria' : 'Editar Categoria',
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppInput(
              label: 'Nome da Categoria',
              placeholder: 'Ex: Barboterapia',
              controller: _nomeController,
              validator: (val) =>
                  val == null || val.isEmpty ? 'Nome obrigatório' : null,
            ),
            const SizedBox(height: 16),
            Text(
              'Tipo de Módulo',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              dropdownColor: isDark ? ThemeColors.darkSurface : Colors.white,
              initialValue: _tipo,
              decoration: InputDecoration(
                filled: true,
                fillColor: isDark ? ThemeColors.darkSurface : Colors.grey.shade50,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: isDark ? ThemeColors.darkBorder : Colors.grey.shade300,
                    width: 1.0,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: isDark ? ThemeColors.darkBorder : Colors.grey.shade300,
                    width: 1.0,
                  ),
                ),
              ),
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 14,
              ),
              items: const [
                DropdownMenuItem(value: 'servicos', child: Text('Serviços')),
                DropdownMenuItem(value: 'produtos', child: Text('Produtos')),
                DropdownMenuItem(value: 'planos', child: Text('Planos')),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _tipo = val);
              },
            ),
          ],
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          ),
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              final nome = _nomeController.text.trim();
              if (category == null) {
                ref
                    .read(categoriasControllerProvider.notifier)
                    .addCategoria(nome, _tipo);
              } else {
                ref
                    .read(categoriasControllerProvider.notifier)
                    .editCategoria(category.copyWith(nome: nome, tipo: _tipo));
              }
              Navigator.of(context).pop();
            }
          },
          child: const Text('Salvar', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
