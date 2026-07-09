import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:barber_osbao/packages/design_system/theme/theme_colors.dart';
import 'package:barber_osbao/packages/design_system/layouts/app_page.dart';
import 'package:barber_osbao/packages/design_system/layouts/app_section.dart';
import 'package:barber_osbao/packages/design_system/organisms/app_table.dart';
import 'package:barber_osbao/packages/design_system/molecules/app_filters.dart';
import 'package:barber_osbao/packages/design_system/molecules/app_info_card.dart';
import 'package:barber_osbao/packages/design_system/atoms/app_button.dart';
import 'package:barber_osbao/packages/design_system/atoms/app_status_chip.dart';
import 'package:barber_osbao/packages/core/shared/repositories/product_repository.dart';

class EstoquePage extends ConsumerStatefulWidget {
  const EstoquePage({super.key});

  @override
  ConsumerState<EstoquePage> createState() => _EstoquePageState();
}

class _EstoquePageState extends ConsumerState<EstoquePage> {
  String _selectedFilter = 'Movimentações';

  // Mock stock movements
  final List<Map<String, dynamic>> _movements = [
    {'id': 'm_1', 'product': 'Pomada Efeito Matte Premium', 'type': 'Entrada', 'qty': 12, 'reason': 'Compra fornecedor', 'date': '08/07/2026', 'user': 'Fábio Zvir'},
    {'id': 'm_2', 'product': 'Óleo para Barba Woodsmoke', 'type': 'Saída', 'qty': 1, 'reason': 'Venda cliente', 'date': '08/07/2026', 'user': 'Arthur Santos'},
    {'id': 'm_3', 'product': 'Gilete Pro-Blade Pack 100un', 'type': 'Saída', 'qty': 1, 'reason': 'Uso interno cabine', 'date': '07/07/2026', 'user': 'Marcos Silva'},
    {'id': 'm_4', 'product': 'Shampoo Fortificante Mentolado', 'type': 'Entrada', 'qty': 6, 'reason': 'Ajuste inventário', 'date': '05/07/2026', 'user': 'Fábio Zvir'},
  ];

  @override
  Widget build(BuildContext context) {
    final productsState = ref.watch(productsListProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppPage(
      title: 'Estoque',
      userName: 'Fábio Zvir',
      userAvatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&width=150',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppFilters(
                options: const ['Movimentações', 'Baixo Estoque', 'Entradas', 'Saídas'],
                selectedOption: _selectedFilter,
                onSelected: (val) => setState(() => _selectedFilter = val),
              ),
              AppButton(
                label: 'Nova Movimentação',
                icon: const Icon(Icons.swap_horiz, size: 16),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Low Stock Alert
          productsState.maybeWhen(
            data: (list) {
              final lowStockItems = list.where((p) => p.stock <= p.minStock).toList();
              if (lowStockItems.isNotEmpty) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: AppInfoCard(
                    title: 'Atenção: Estoque Baixo!',
                    content: 'Há ${lowStockItems.length} produto(s) com quantidade abaixo do limite mínimo recomendado: ${lowStockItems.map((p) => p.name).join(", ")}. É recomendável realizar nova compra com os fornecedores.',
                    color: ThemeColors.danger,
                    icon: Icons.warning_amber_rounded,
                  ),
                );
              }
              return const SizedBox.shrink();
            },
            orElse: () => const SizedBox.shrink(),
          ),

          // Content section
          AppSection(
            title: _selectedFilter == 'Baixo Estoque' ? 'Produtos com Estoque Baixo' : 'Histórico de Movimentações',
            subtitle: 'Registro de entradas, saídas e movimentações internas',
            child: productsState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => const Center(child: Text('Erro ao carregar estoque.')),
              data: (list) {
                if (_selectedFilter == 'Baixo Estoque') {
                  final lowStockItems = list.where((p) => p.stock <= p.minStock).toList();
                  if (lowStockItems.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(40),
                      alignment: Alignment.center,
                      child: const Text('Nenhum produto com baixo estoque.', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                    );
                  }
                  return AppTable(
                    columns: [
                      AppTableColumn(label: 'PRODUTO'),
                      AppTableColumn(label: 'FORNECEDOR'),
                      AppTableColumn(label: 'MÍNIMO'),
                      AppTableColumn(label: 'ATUAL'),
                      AppTableColumn(label: 'AÇÕES', width: 100),
                    ],
                    rows: lowStockItems.map((prod) {
                      return AppTableRow(
                        cells: [
                          Text(prod.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(prod.supplier),
                          Text('${prod.minStock} un'),
                          Text('${prod.stock} un', style: const TextStyle(color: ThemeColors.danger, fontWeight: FontWeight.bold)),
                          AppButton(
                            label: 'Comprar',
                            onPressed: () {},
                            variant: AppButtonVariant.primary,
                          ),
                        ],
                      );
                    }).toList(),
                  );
                }

                // Filter movements by Type if needed
                final filteredMovements = _movements.where((m) {
                  if (_selectedFilter == 'Entradas') return m['type'] == 'Entrada';
                  if (_selectedFilter == 'Saídas') return m['type'] == 'Saída';
                  return true;
                }).toList();

                if (filteredMovements.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(40),
                    alignment: Alignment.center,
                    child: Text('Nenhuma movimentação registrada.', style: TextStyle(color: isDark ? Colors.white30 : Colors.grey)),
                  );
                }

                return AppTable(
                  columns: [
                    AppTableColumn(label: 'CÓDIGO'),
                    AppTableColumn(label: 'PRODUTO'),
                    AppTableColumn(label: 'TIPO'),
                    AppTableColumn(label: 'QTD'),
                    AppTableColumn(label: 'MOTIVO'),
                    AppTableColumn(label: 'DATA'),
                    AppTableColumn(label: 'RESPONSÁVEL'),
                  ],
                  rows: filteredMovements.map((move) {
                    final isEntry = move['type'] == 'Entrada';
                    return AppTableRow(
                      cells: [
                        Text(move['id'] as String),
                        Text(move['product'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                        AppStatusChip(
                          label: move['type'] as String,
                          type: isEntry ? AppStatusType.success : AppStatusType.danger,
                        ),
                        Text('${move['qty']} un', style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(move['reason'] as String),
                        Text(move['date'] as String),
                        Text(move['user'] as String),
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
