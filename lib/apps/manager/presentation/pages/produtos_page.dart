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
import 'package:barber_osbao/packages/core/shared/repositories/product_repository.dart';

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
    final productsState = ref.watch(productsListProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                  placeholder: 'Pesquisar produto por nome ou fornecedor...',
                  onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
                  onClear: () => setState(() => _searchQuery = ''),
                ),
              ),
              const SizedBox(width: 16),
              AppButton(
                label: 'Novo Produto',
                icon: const Icon(Icons.add, size: 16),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 16),
          AppFilters(
            options: const ['Todos', 'Finalizadores', 'Cuidados com a Barba', 'Cabelo', 'Consumíveis'],
            selectedOption: _selectedCategory,
            onSelected: (val) => setState(() => _selectedCategory = val),
          ),
          const SizedBox(height: 32),

          AppSection(
            title: 'Inventário de Produtos',
            subtitle: 'Lista de produtos para venda e uso interno',
            child: productsState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => const Center(child: Text('Erro ao carregar produtos.')),
              data: (list) {
                final filtered = list.where((p) {
                  final matchesSearch = p.name.toLowerCase().contains(_searchQuery) ||
                      p.supplier.toLowerCase().contains(_searchQuery);
                  final matchesCat = _selectedCategory == 'Todos' || p.category == _selectedCategory;
                  return matchesSearch && matchesCat;
                }).toList();

                if (filtered.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(40),
                    alignment: Alignment.center,
                    child: Text(
                      'Nenhum produto encontrado.',
                      style: TextStyle(color: isDark ? Colors.white30 : Colors.grey),
                    ),
                  );
                }

                return AppTable(
                  columns: [
                    AppTableColumn(label: 'IMAGEM', width: 60),
                    AppTableColumn(label: 'PRODUTO', width: 220),
                    AppTableColumn(label: 'CATEGORIA'),
                    AppTableColumn(label: 'FORNECEDOR'),
                    AppTableColumn(label: 'ESTOQUE'),
                    AppTableColumn(label: 'PREÇO'),
                    AppTableColumn(label: 'STATUS'),
                    AppTableColumn(label: 'AÇÕES', width: 100),
                  ],
                  rows: filtered.map((prod) {
                    final isLowStock = prod.stock <= prod.minStock;

                    return AppTableRow(
                      cells: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            prod.imageUrl,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.shopping_bag_outlined, size: 24),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(prod.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 2),
                            Text('Custo: R\$ ${prod.costPrice.toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                        Text(prod.category),
                        Text(prod.supplier),
                        Row(
                          children: [
                            Text(
                              '${prod.stock} un',
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
                          'R\$ ${prod.price.toStringAsFixed(2)}',
                          style: const TextStyle(color: ThemeColors.primary, fontWeight: FontWeight.bold),
                        ),
                        AppStatusChip(
                          label: prod.status == 'active' ? 'Ativo' : 'Inativo',
                          type: prod.status == 'active' ? AppStatusType.success : AppStatusType.danger,
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 18),
                              onPressed: () {},
                              tooltip: 'Editar',
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline, size: 18, color: ThemeColors.primary),
                              onPressed: () {
                                // Fast restock action
                                ref.read(productRepositoryProvider).updateStock(prod.id, prod.stock + 10);
                                ref.invalidate(productsListProvider);
                              },
                              tooltip: 'Entrada rápida +10',
                            ),
                          ],
                        ),
                      ],
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0, curve: Curves.easeOut),
    );
  }
}
