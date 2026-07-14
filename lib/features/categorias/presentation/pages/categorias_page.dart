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

    return AppPage(
      title: 'Categorias',
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
                  placeholder: 'Pesquisar categoria por nome...',
                  onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
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
            subtitle: 'Cadastre e edite categorias usadas nos serviços, produtos e planos',
            child: _buildContent(state, isDark),
          ),
        ],
      ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0, curve: Curves.easeOut),
    );
  }

  Widget _buildContent(AppState<List<Categoria>> state, bool isDark) {
    if (state is AppLoading) {
      return const Padding(
        padding: EdgeInsets.all(40.0),
        child: Center(child: CircularProgressIndicator(color: ThemeColors.primary)),
      );
    }

    if (state is AppError) {
      return Padding(
        padding: const EdgeInsets.all(40.0),
        child: Center(
          child: Text('Erro: ${(state as AppError).message}', style: const TextStyle(color: ThemeColors.danger)),
        ),
      );
    }

    final data = state.data ?? [];
    if (state is AppEmpty || data.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        alignment: Alignment.center,
        child: Text('Nenhuma categoria cadastrada.', style: TextStyle(color: isDark ? Colors.white30 : Colors.grey)),
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
      final matchesType = _selectedType == 'Todos' || c.tipo == typeMap[_selectedType];
      return matchesSearch && matchesType;
    }).toList();

    if (filtered.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        alignment: Alignment.center,
        child: Text('Nenhuma categoria correspondente aos filtros.', style: TextStyle(color: isDark ? Colors.white30 : Colors.grey)),
      );
    }

    final displayType = {
      'servicos': 'Serviço',
      'produtos': 'Produto',
      'planos': 'Plano',
    };

    return AppTable(
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
                  icon: const Icon(Icons.delete_outline, size: 18, color: ThemeColors.danger),
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
    final formKey = GlobalKey<FormState>();
    final nomeController = TextEditingController(text: category?.nome ?? '');
    String tipo = category?.tipo ?? 'servicos';

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: ThemeColors.darkBg,
              title: Text(category == null ? 'Criar Categoria' : 'Editar Categoria', style: const TextStyle(color: Colors.white)),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppInput(
                      label: 'Nome da Categoria',
                      placeholder: 'Ex: Barboterapia',
                      controller: nomeController,
                      validator: (val) => val == null || val.isEmpty ? 'Nome obrigatório' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      dropdownColor: ThemeColors.darkBg,
                      initialValue: tipo,
                      decoration: const InputDecoration(
                        labelText: 'Tipo de Módulo',
                        labelStyle: TextStyle(color: Colors.white70),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
                      ),
                      style: const TextStyle(color: Colors.white),
                      items: const [
                        DropdownMenuItem(value: 'servicos', child: Text('Serviços')),
                        DropdownMenuItem(value: 'produtos', child: Text('Produtos')),
                        DropdownMenuItem(value: 'planos', child: Text('Planos')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => tipo = val);
                      },
                    ),
                  ],
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
                      final nome = nomeController.text.trim();
                      if (category == null) {
                        ref.read(categoriasControllerProvider.notifier).addCategoria(nome, tipo);
                      } else {
                        ref.read(categoriasControllerProvider.notifier).editCategoria(category.copyWith(nome: nome, tipo: tipo));
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

  void _showDeleteDialog(BuildContext context, Categoria category) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ThemeColors.darkBg,
        title: const Text('Excluir Categoria', style: TextStyle(color: Colors.white)),
        content: Text('Tem certeza que deseja excluir a categoria "${category.nome}"? Ela pode estar vinculada a outros cadastros.', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: ThemeColors.danger),
            onPressed: () {
              ref.read(categoriasControllerProvider.notifier).removeCategoria(category.id);
              Navigator.of(ctx).pop();
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
