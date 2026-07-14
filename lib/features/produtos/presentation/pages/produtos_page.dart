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
import 'package:barber_osbao/features/produtos/domain/models/produto.dart';
import 'package:barber_osbao/features/produtos/presentation/controllers/produtos_controller.dart';
import 'package:barber_osbao/features/categorias/presentation/controllers/categorias_controller.dart';

class ProdutosPage extends ConsumerStatefulWidget {
  const ProdutosPage({super.key});

  @override
  ConsumerState<ProdutosPage> createState() => _ProdutosPageState();
}

class _ProdutosPageState extends ConsumerState<ProdutosPage> {
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
    final state = ref.watch(produtosControllerProvider);
    final categoriesState = ref.watch(categoriasControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Resolve categories
    final List<String> categories = ['Todos'];
    if (categoriesState is AppSuccess<dynamic>) {
      final list = (categoriesState as AppSuccess).data;
      for (final cat in list) {
        if (cat.tipo == 'produtos') {
          categories.add(cat.nome);
        }
      }
    }
    // Fallback
    if (categories.length == 1) {
      categories.addAll(['Finalizadores', 'Cuidados com a Barba', 'Cabelo', 'Consumíveis']);
    }

    return AppPage(
      title: 'Produtos',
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
                  placeholder: 'Pesquisar produto por nome, marca ou fornecedor...',
                  onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
                  onClear: () => setState(() => _searchQuery = ''),
                ),
              ),
              const SizedBox(width: 16),
              AppButton(
                label: 'Novo Produto',
                icon: const Icon(Icons.add, size: 16),
                onPressed: () => _showFormDialog(context, categories.where((c) => c != 'Todos').toList()),
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
            title: 'Inventário de Produtos',
            subtitle: 'Lista de produtos para revenda ou consumo interno com alertas de estoque crítico',
            child: _buildContent(state, isDark, categories.where((c) => c != 'Todos').toList()),
          ),
        ],
      ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0, curve: Curves.easeOut),
    );
  }

  Widget _buildContent(AppState<List<Produto>> state, bool isDark, List<String> formCategories) {
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
        child: Text('Nenhum produto cadastrado.', style: TextStyle(color: isDark ? Colors.white30 : Colors.grey)),
      );
    }

    final filtered = data.where((p) {
      final matchesSearch = p.name.toLowerCase().contains(_searchQuery) ||
          p.brand.toLowerCase().contains(_searchQuery) ||
          p.supplier.toLowerCase().contains(_searchQuery) ||
          p.code.toLowerCase().contains(_searchQuery);

      final matchesCategory = _selectedCategory == 'Todos' || p.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    if (filtered.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        alignment: Alignment.center,
        child: Text('Nenhum produto correspondente aos filtros.', style: TextStyle(color: isDark ? Colors.white30 : Colors.grey)),
      );
    }

    return AppTable(
      columns: [
        AppTableColumn(label: 'IMAGEM', width: 60),
        AppTableColumn(label: 'PRODUTO', width: 220),
        AppTableColumn(label: 'MÓDULO/CATEGORIA'),
        AppTableColumn(label: 'FORNECEDOR'),
        AppTableColumn(label: 'ESTOQUE'),
        AppTableColumn(label: 'V. VENDA'),
        AppTableColumn(label: 'STATUS'),
        AppTableColumn(label: 'AÇÕES', width: 140),
      ],
      rows: filtered.map((p) {
        final isLowStock = p.stock <= p.minStock;
        return AppTableRow(
          cells: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                p.imageUrl,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.shopping_bag_outlined, size: 24),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('Cód: ${p.code} | Marca: ${p.brand}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
            Text(p.category),
            Text(p.supplier),
            Row(
              children: [
                Text(
                  '${p.stock} un',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isLowStock ? ThemeColors.danger : (isDark ? Colors.white : Colors.black87),
                  ),
                ),
                if (isLowStock) ...[
                  const SizedBox(width: 6),
                  const Icon(Icons.warning, color: ThemeColors.danger, size: 14),
                ],
              ],
            ),
            Text(
              'R\$ ${p.price.toStringAsFixed(2)}',
              style: const TextStyle(color: ThemeColors.primary, fontWeight: FontWeight.bold),
            ),
            AppStatusChip(
              label: p.status ? 'Ativo' : 'Inativo',
              type: p.status ? AppStatusType.success : AppStatusType.danger,
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.add_circle_outline, size: 18, color: ThemeColors.primary),
                  onPressed: () => _showQuickMovementDialog(context, p, 'Entrada'),
                  tooltip: 'Entrada rápida',
                ),
                const SizedBox(width: 8),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.remove_circle_outline, size: 18, color: ThemeColors.warning),
                  onPressed: () => _showQuickMovementDialog(context, p, 'Saída'),
                  tooltip: 'Saída rápida',
                ),
                const SizedBox(width: 8),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  onPressed: () => _showFormDialog(context, formCategories, p),
                  tooltip: 'Editar',
                ),
                const SizedBox(width: 8),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.delete_outline, size: 18, color: ThemeColors.danger),
                  onPressed: () => _showDeleteDialog(context, p),
                  tooltip: 'Excluir',
                ),
              ],
            ),
          ],
        );
      }).toList(),
    );
  }

  void _showFormDialog(BuildContext context, List<String> categories, [Produto? product]) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: product?.name ?? '');
    final brandController = TextEditingController(text: product?.brand ?? '');
    final supplierController = TextEditingController(text: product?.supplier ?? '');
    final codeController = TextEditingController(text: product?.code ?? '');
    final costPriceController = TextEditingController(text: product?.costPrice.toString() ?? '');
    final priceController = TextEditingController(text: product?.price.toString() ?? '');
    final stockController = TextEditingController(text: product?.stock.toString() ?? '10');
    final minStockController = TextEditingController(text: product?.minStock.toString() ?? '5');
    final descriptionController = TextEditingController(text: product?.description ?? '');
    final imageUrlController = TextEditingController(text: product?.imageUrl ?? '');
    
    String category = product?.category ?? (categories.isNotEmpty ? categories[0] : 'Finalizadores');
    bool status = product?.status ?? true;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: ThemeColors.darkBg,
              title: Text(product == null ? 'Criar Produto' : 'Editar Produto', style: const TextStyle(color: Colors.white)),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppInput(
                        label: 'Nome do Produto',
                        placeholder: 'Ex: Pomada Modeladora',
                        controller: nameController,
                        validator: (val) => val == null || val.isEmpty ? 'Nome obrigatório' : null,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: AppInput(
                              label: 'Marca',
                              placeholder: 'Ex: BarberGroom',
                              controller: brandController,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              dropdownColor: ThemeColors.darkBg,
                              initialValue: category,
                              decoration: const InputDecoration(
                                labelText: 'Categoria',
                                labelStyle: TextStyle(color: Colors.white70),
                                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
                              ),
                              style: const TextStyle(color: Colors.white),
                              items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => category = val);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: AppInput(
                              label: 'Fornecedor',
                              placeholder: 'Ex: Distribuidora XYZ',
                              controller: supplierController,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppInput(
                              label: 'Código do Produto',
                              placeholder: 'Ex: PROD123',
                              controller: codeController,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: AppInput(
                              label: 'Preço de Custo (R\$)',
                              placeholder: 'Ex: 15.00',
                              controller: costPriceController,
                              keyboardType: TextInputType.number,
                              validator: (val) => val == null || val.isEmpty ? 'Obrigatório' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppInput(
                              label: 'Preço de Venda (R\$)',
                              placeholder: 'Ex: 45.00',
                              controller: priceController,
                              keyboardType: TextInputType.number,
                              validator: (val) => val == null || val.isEmpty ? 'Obrigatório' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: AppInput(
                              label: 'Quantidade em Estoque',
                              placeholder: 'Ex: 24',
                              controller: stockController,
                              keyboardType: TextInputType.number,
                              validator: (val) => val == null || val.isEmpty ? 'Obrigatório' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppInput(
                              label: 'Estoque Mínimo',
                              placeholder: 'Ex: 5',
                              controller: minStockController,
                              keyboardType: TextInputType.number,
                              validator: (val) => val == null || val.isEmpty ? 'Obrigatório' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      AppInput(
                        label: 'URL da Imagem',
                        placeholder: 'Ex: https://unsplash.com/...',
                        controller: imageUrlController,
                      ),
                      const SizedBox(height: 12),
                      AppInput(
                        label: 'Descrição',
                        placeholder: 'Ex: Características do produto...',
                        controller: descriptionController,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 12),
                      SwitchListTile(
                        title: const Text('Produto Ativo', style: TextStyle(color: Colors.white70, fontSize: 14)),
                        value: status,
                        activeThumbColor: ThemeColors.primary,
                        onChanged: (val) => setState(() => status = val),
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
                      final newProd = Produto(
                        id: product?.id ?? '',
                        name: nameController.text.trim(),
                        brand: brandController.text.trim(),
                        category: category,
                        supplier: supplierController.text.trim(),
                        code: codeController.text.trim(),
                        costPrice: double.parse(costPriceController.text.trim()),
                        price: double.parse(priceController.text.trim()),
                        stock: int.parse(stockController.text.trim()),
                        minStock: int.parse(minStockController.text.trim()),
                        description: descriptionController.text.trim(),
                        status: status,
                        imageUrl: imageUrlController.text.isNotEmpty
                            ? imageUrlController.text.trim()
                            : 'https://images.unsplash.com/photo-1608248597279-f99d160bfcbc?q=80&width=150',
                      );

                      if (product == null) {
                        ref.read(produtosControllerProvider.notifier).addProduto(newProd);
                      } else {
                        ref.read(produtosControllerProvider.notifier).editProduto(newProd);
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

  void _showDeleteDialog(BuildContext context, Produto product) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ThemeColors.darkBg,
        title: const Text('Excluir Produto', style: TextStyle(color: Colors.white)),
        content: Text('Tem certeza que deseja excluir o produto "${product.name}"? Essa ação removerá o registro permanente no estoque.', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: ThemeColors.danger),
            onPressed: () {
              ref.read(produtosControllerProvider.notifier).removeProduto(product.id);
              Navigator.of(ctx).pop();
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showQuickMovementDialog(BuildContext context, Produto product, String type) {
    final qtyController = TextEditingController(text: '1');
    final reasonController = TextEditingController(text: type == 'Entrada' ? 'Compra fornecedor' : 'Uso interno');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ThemeColors.darkBg,
        title: Text('$type de Estoque: ${product.name}', style: const TextStyle(color: Colors.white, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppInput(
              label: 'Quantidade',
              placeholder: 'Quantidade de itens',
              controller: qtyController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            AppInput(
              label: 'Motivo / Justificativa',
              placeholder: 'Ex: Reposição de estoque',
              controller: reasonController,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: type == 'Entrada' ? ThemeColors.success : ThemeColors.warning),
            onPressed: () {
              final qty = int.tryParse(qtyController.text.trim()) ?? 1;
              final reason = reasonController.text.trim();
              ref.read(movimentacoesControllerProvider.notifier).addMovimentacao(
                    product.id,
                    product.name,
                    type,
                    qty,
                    reason,
                  );
              Navigator.of(ctx).pop();
            },
            child: const Text('Gravar', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }
}
