import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:barber_osbao/packages/design_system/theme/theme_colors.dart';
import 'package:barber_osbao/packages/design_system/theme/app_breakpoints.dart';
import 'package:barber_osbao/packages/design_system/layouts/app_page.dart';
import 'package:barber_osbao/packages/design_system/layouts/app_section.dart';
import 'package:barber_osbao/packages/design_system/organisms/app_table.dart';
import 'package:barber_osbao/packages/design_system/molecules/app_filters.dart';
import 'package:barber_osbao/packages/design_system/molecules/app_info_card.dart';
import 'package:barber_osbao/packages/design_system/atoms/app_button.dart';
import 'package:barber_osbao/packages/design_system/atoms/app_status_chip.dart';
import 'package:barber_osbao/packages/design_system/molecules/app_input.dart';
import 'package:barber_osbao/packages/core/shared/state/app_state.dart';
import 'package:barber_osbao/features/produtos/domain/models/produto.dart';
import 'package:barber_osbao/features/produtos/domain/models/movimentacao.dart';
import 'package:barber_osbao/features/produtos/presentation/controllers/produtos_controller.dart';

class EstoquePage extends ConsumerStatefulWidget {
  const EstoquePage({super.key});

  @override
  ConsumerState<EstoquePage> createState() => _EstoquePageState();
}

class _EstoquePageState extends ConsumerState<EstoquePage> {
  String _selectedFilter = 'Movimentações';

  @override
  Widget build(BuildContext context) {
    final productsState = ref.watch(produtosControllerProvider);
    final movementsState = ref.watch(movimentacoesControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = AppBreakpoints.isMobile(context);

    return AppPage(
      title: 'Estoque',
      userName: 'Fábio Zvir',
      userAvatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&width=150',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Actions — responsive
          Wrap(
            spacing: 12,
            runSpacing: 10,
            alignment: isMobile ? WrapAlignment.start : WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              AppFilters(
                options: const ['Movimentações', 'Baixo Estoque', 'Entradas', 'Saídas'],
                selectedOption: _selectedFilter,
                onSelected: (val) => setState(() => _selectedFilter = val),
              ),
              AppButton(
                label: 'Nova Movimentação',
                icon: const Icon(Icons.swap_horiz, size: 16),
                onPressed: () => _showMovementDialog(context, productsState),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Low Stock Alert
          _buildLowStockAlert(productsState),

          // Content section
          AppSection(
            title: _selectedFilter == 'Baixo Estoque' ? 'Produtos com Estoque Baixo' : 'Histórico de Movimentações',
            subtitle: 'Registro de entradas, saídas e movimentações internas',
            child: _buildContent(productsState, movementsState, isDark),
          ),
        ],
      ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0, curve: Curves.easeOut),
    );
  }

  Widget _buildLowStockAlert(AppState<List<Produto>> productsState) {
    if (productsState is AppSuccess<List<Produto>>) {
      final lowStockItems = productsState.data.where((p) => p.stock <= p.minStock).toList();
      if (lowStockItems.isNotEmpty) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 24.0),
          child: AppInfoCard(
            title: 'Atenção: Estoque Baixo!',
            content: 'Há ${lowStockItems.length} produto(s) com quantidade abaixo do limite mínimo recomendado: ${lowStockItems.map((p) => p.name).join(", ")}. É recomendável realizar reposição.',
            color: ThemeColors.danger,
            icon: Icons.warning_amber_rounded,
          ),
        );
      }
    }
    return const SizedBox.shrink();
  }

  Widget _buildContent(
    AppState<List<Produto>> productsState,
    AppState<List<MovimentacaoEstoque>> movementsState,
    bool isDark,
  ) {
    if (_selectedFilter == 'Baixo Estoque') {
      if (productsState is AppLoading) {
        return const Center(child: CircularProgressIndicator(color: ThemeColors.primary));
      }
      final list = productsState.data ?? [];
      final lowStockItems = list.where((p) => p.stock <= p.minStock).toList();
      
      if (lowStockItems.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(40),
          alignment: Alignment.center,
          child: const Text('Nenhum produto com baixo estoque.', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
        );
      }

      return AppTable(
        minWidth: 700,
        columns: [
          AppTableColumn(label: 'PRODUTO'),
          AppTableColumn(label: 'CÓDIGO'),
          AppTableColumn(label: 'FORNECEDOR'),
          AppTableColumn(label: 'MÍNIMO'),
          AppTableColumn(label: 'ATUAL'),
          AppTableColumn(label: 'AÇÕES', width: 140),
        ],
        rows: lowStockItems.map((prod) {
          return AppTableRow(
            cells: [
              Text(prod.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(prod.code),
              Text(prod.supplier),
              Text('${prod.minStock} un'),
              Text('${prod.stock} un', style: const TextStyle(color: ThemeColors.danger, fontWeight: FontWeight.bold)),
              AppButton(
                label: 'Repor +10',
                onPressed: () {
                  ref.read(movimentacoesControllerProvider.notifier).addMovimentacao(
                        prod.id,
                        prod.name,
                        'Entrada',
                        10,
                        'Reposição rápida de estoque',
                      );
                },
                variant: AppButtonVariant.primary,
              ),
            ],
          );
        }).toList(),
      );
    }

    // Historical movements list
    if (movementsState is AppLoading) {
      return const Center(child: CircularProgressIndicator(color: ThemeColors.primary));
    }
    if (movementsState is AppError) {
      return Center(child: Text('Erro: ${(movementsState as AppError).message}', style: const TextStyle(color: ThemeColors.danger)));
    }

    final data = movementsState.data ?? [];
    final filtered = data.where((m) {
      if (_selectedFilter == 'Entradas') return m.type == 'Entrada';
      if (_selectedFilter == 'Saídas') return m.type == 'Saída';
      return true;
    }).toList();

    if (filtered.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        alignment: Alignment.center,
        child: Text('Nenhuma movimentação registrada.', style: TextStyle(color: isDark ? Colors.white30 : Colors.grey)),
      );
    }

    return AppTable(
      minWidth: 800,
      columns: [
        AppTableColumn(label: 'CÓDIGO MOV.'),
        AppTableColumn(label: 'PRODUTO'),
        AppTableColumn(label: 'TIPO'),
        AppTableColumn(label: 'QTD'),
        AppTableColumn(label: 'MOTIVO'),
        AppTableColumn(label: 'DATA'),
        AppTableColumn(label: 'RESPONSÁVEL'),
      ],
      rows: filtered.map((move) {
        final isEntry = move.type == 'Entrada';
        final isInventory = move.type == 'Inventário';
        return AppTableRow(
          cells: [
            Text(move.id),
            Text(move.productName, style: const TextStyle(fontWeight: FontWeight.bold)),
            AppStatusChip(
              label: move.type,
              type: isEntry
                  ? AppStatusType.success
                  : (isInventory ? AppStatusType.info : AppStatusType.danger),
            ),
            Text('${move.qty} un', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(move.reason),
            Text(move.date),
            Text(move.user),
          ],
        );
      }).toList(),
    );
  }

  void _showMovementDialog(BuildContext context, AppState<List<Produto>> productsState) {
    final products = productsState.data ?? [];
    if (products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cadastre um produto antes de realizar movimentações.')),
      );
      return;
    }

    final formKey = GlobalKey<FormState>();
    String selectedProductId = products[0].id;
    String type = 'Entrada';
    final qtyController = TextEditingController(text: '5');
    final reasonController = TextEditingController(text: 'Compra de fornecedor');

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            final currentProduct = products.firstWhere((p) => p.id == selectedProductId);
            return AlertDialog(
              backgroundColor: ThemeColors.darkBg,
              title: const Text('Lançar Movimentação de Estoque', style: TextStyle(color: Colors.white)),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      dropdownColor: ThemeColors.darkBg,
                      initialValue: selectedProductId,
                      decoration: const InputDecoration(
                        labelText: 'Produto',
                        labelStyle: TextStyle(color: Colors.white70),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
                      ),
                      style: const TextStyle(color: Colors.white),
                      items: products.map((p) => DropdownMenuItem(value: p.id, child: Text('${p.name} (Qtd atual: ${p.stock})'))).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => selectedProductId = val);
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      dropdownColor: ThemeColors.darkBg,
                      initialValue: type,
                      decoration: const InputDecoration(
                        labelText: 'Tipo de Lançamento',
                        labelStyle: TextStyle(color: Colors.white70),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
                      ),
                      style: const TextStyle(color: Colors.white),
                      items: const [
                        DropdownMenuItem(value: 'Entrada', child: Text('Entrada (+)')),
                        DropdownMenuItem(value: 'Saída', child: Text('Saída (-)')),
                        DropdownMenuItem(value: 'Inventário', child: Text('Inventário / Acerto (=)')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            type = val;
                            if (val == 'Entrada') {
                              reasonController.text = 'Compra de fornecedor';
                            } else if (val == 'Saída') {
                              reasonController.text = 'Consumo interno cabine';
                            } else {
                              reasonController.text = 'Ajuste de inventário periódico';
                            }
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    AppInput(
                      label: type == 'Inventário' ? 'Nova Quantidade Real' : 'Quantidade de Itens',
                      placeholder: 'Ex: 10',
                      controller: qtyController,
                      keyboardType: TextInputType.number,
                      validator: (val) => val == null || val.isEmpty ? 'Quantidade obrigatória' : null,
                    ),
                    const SizedBox(height: 12),
                    AppInput(
                      label: 'Motivo',
                      placeholder: 'Justifique a alteração',
                      controller: reasonController,
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
                      final qty = int.parse(qtyController.text.trim());
                      ref.read(movimentacoesControllerProvider.notifier).addMovimentacao(
                            selectedProductId,
                            currentProduct.name,
                            type,
                            qty,
                            reasonController.text.trim(),
                          );
                      Navigator.of(ctx).pop();
                    }
                  },
                  child: const Text('Confirmar', style: TextStyle(color: Colors.black)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
