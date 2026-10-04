import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import 'package:barber_osbao/packages/design_system/organisms/app_dialog.dart';
import 'package:barber_osbao/packages/core/shared/state/app_state.dart';
import 'package:barber_osbao/packages/core/utils/app_masks.dart';
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
      userAvatarUrl:
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&width=150',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Actions — responsive
          Wrap(
            spacing: 12,
            runSpacing: 10,
            alignment: isMobile
                ? WrapAlignment.start
                : WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              AppFilters(
                options: const [
                  'Movimentações',
                  'Baixo Estoque',
                  'Entradas',
                  'Saídas',
                ],
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
            title: _selectedFilter == 'Baixo Estoque'
                ? 'Produtos com Estoque Baixo'
                : 'Histórico de Movimentações',
            subtitle: 'Registro de entradas, saídas e movimentações internas',
            child: _buildContent(productsState, movementsState, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildLowStockAlert(AppState<List<Produto>> productsState) {
    if (productsState is AppSuccess<List<Produto>>) {
      final lowStockItems = productsState.data
          .where((p) => p.stock <= p.minStock)
          .toList();
      if (lowStockItems.isNotEmpty) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 24.0),
          child: AppInfoCard(
            title: 'Atenção: Estoque Baixo!',
            content:
                'Há ${lowStockItems.length} produto(s) com quantidade abaixo do limite mínimo recomendado: ${lowStockItems.map((p) => p.name).join(", ")}. É recomendável realizar reposição.',
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
        return const Center(
          child: CircularProgressIndicator(color: ThemeColors.primary),
        );
      }
      final list = productsState.data ?? [];
      final lowStockItems = list.where((p) => p.stock <= p.minStock).toList();

      if (lowStockItems.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(40),
          alignment: Alignment.center,
          child: const Text(
            'Nenhum produto com baixo estoque.',
            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
          ),
        );
      }

      return AppTable(
        minWidth: 700,
        columns: [
          AppTableColumn(label: 'PRODUTO', flex: 3),
          AppTableColumn(label: 'CÓDIGO', width: 110),
          AppTableColumn(label: 'FORNECEDOR', flex: 2),
          AppTableColumn(label: 'MÍNIMO', width: 90),
          AppTableColumn(label: 'ATUAL', width: 90),
          AppTableColumn(label: 'AÇÕES', width: 130),
        ],
        rows: lowStockItems.map((prod) {
          return AppTableRow(
            cells: [
              Text(
                prod.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(prod.code),
              Text(prod.supplier),
              Text('${prod.minStock} un'),
              Text(
                '${prod.stock} un',
                style: const TextStyle(
                  color: ThemeColors.danger,
                  fontWeight: FontWeight.bold,
                ),
              ),
              AppButton(
                label: 'Repor Estoque',
                icon: const Icon(Icons.add_shopping_cart, size: 14),
                onPressed: () => _showReplenishDialog(context, prod),
                variant: AppButtonVariant.primary,
              ),
            ],
          );
        }).toList(),
      );
    }

    // Historical movements list
    if (movementsState is AppLoading) {
      return const Center(
        child: CircularProgressIndicator(color: ThemeColors.primary),
      );
    }
    if (movementsState is AppError) {
      return Center(
        child: Text(
          'Erro: ${(movementsState as AppError).message}',
          style: const TextStyle(color: ThemeColors.danger),
        ),
      );
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
        child: Text(
          'Nenhuma movimentação registrada.',
          style: TextStyle(color: isDark ? Colors.white30 : Colors.grey),
        ),
      );
    }

    return AppTable(
      minWidth: 800,
      columns: [
        AppTableColumn(label: 'CÓDIGO MOV.', width: 120),
        AppTableColumn(label: 'PRODUTO', flex: 3),
        AppTableColumn(label: 'TIPO', width: 110),
        AppTableColumn(label: 'QTD', width: 90),
        AppTableColumn(label: 'MOTIVO', flex: 2),
        AppTableColumn(label: 'DATA', width: 110),
        AppTableColumn(label: 'RESPONSÁVEL', width: 140),
      ],
      rows: filtered.map((move) {
        final isEntry = move.type == 'Entrada';
        final isInventory = move.type == 'Inventário';
        return AppTableRow(
          cells: [
            Text(move.id),
            Text(
              move.productName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            AppStatusChip(
              label: move.type,
              type: isEntry
                  ? AppStatusType.success
                  : (isInventory ? AppStatusType.info : AppStatusType.danger),
            ),
            Text(
              '${move.qty} un',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(move.reason),
            Text(move.date),
            Text(move.user),
          ],
        );
      }).toList(),
    );
  }

  void _showMovementDialog(
    BuildContext context,
    AppState<List<Produto>> productsState,
  ) {
    final products = productsState.data ?? [];
    if (products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cadastre um produto antes de realizar movimentações.'),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => EstoqueMovimentacaoDialog(products: products),
    );
  }

  void _showReplenishDialog(BuildContext context, Produto prod) {
    final qtyController = TextEditingController(text: '');
    final reasonController = TextEditingController(text: 'Reposição de estoque');
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AppResponsiveDialog(
        title: 'Repor Estoque: ${prod.name}',
        subtitle:
            'Estoque atual: ${prod.stock} un | Mínimo recomendado: ${prod.minStock} un',
        maxWidth: 480,
        actions: [
          TextButton(
            onPressed: () {
              qtyController.dispose();
              reasonController.dispose();
              Navigator.of(ctx).pop();
            },
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              final qty = int.tryParse(qtyController.text.trim()) ?? 0;
              if (qty <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Informe uma quantidade válida (> 0).'),
                    backgroundColor: ThemeColors.danger,
                  ),
                );
                return;
              }
              final reason = reasonController.text.trim();
              ref
                  .read(movimentacoesControllerProvider.notifier)
                  .addMovimentacao(
                    prod.id,
                    prod.name,
                    'Entrada',
                    qty,
                    reason.isEmpty
                        ? 'Reposição rápida de estoque baixo'
                        : reason,
                  );
              qtyController.dispose();
              reasonController.dispose();
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Entrada de $qty un para "${prod.name}" confirmada!',
                  ),
                  backgroundColor: ThemeColors.success,
                ),
              );
            },
            child: const Text(
              'Confirmar Reposição',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppInput(
              label: 'Quantidade a Repor',
              placeholder: 'Ex: 10',
              controller: qtyController,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            AppInput(
              label: 'Motivo / Nota Fiscal (Opcional)',
              placeholder: 'Ex: Pedido reposição semanal, fornecedor XYZ...',
              controller: reasonController,
            ),
          ],
        ),
      ),
    );
  }
}

class EstoqueMovimentacaoDialog extends ConsumerStatefulWidget {
  final List<Produto>? products;

  const EstoqueMovimentacaoDialog({super.key, this.products});

  @override
  ConsumerState<EstoqueMovimentacaoDialog> createState() =>
      _EstoqueMovimentacaoDialogState();
}

class _EstoqueMovimentacaoDialogState
    extends ConsumerState<EstoqueMovimentacaoDialog> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedProductId;
  late String _type;
  late final TextEditingController _qtyController;
  late final TextEditingController _reasonController;

  @override
  void initState() {
    super.initState();
    _selectedProductId = null; // Do NOT pre-select as requested
    _type = 'Entrada';
    _qtyController = TextEditingController(text: '');
    _reasonController = TextEditingController(text: '');
  }

  @override
  void dispose() {
    _qtyController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final availableProducts =
        widget.products ?? (ref.watch(produtosControllerProvider).data ?? []);

    return AppResponsiveDialog(
      title: 'Lançar Movimentação de Estoque',
      subtitle:
          'Registre entradas, saídas ou acertos de inventário dos produtos',
      maxWidth: 540,
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
            if (_selectedProductId == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Por favor, selecione um produto.'),
                  backgroundColor: ThemeColors.danger,
                ),
              );
              return;
            }
            if (_formKey.currentState?.validate() ?? false) {
              final prod = availableProducts.firstWhere(
                (p) => p.id == _selectedProductId,
              );
              final qty = int.tryParse(_qtyController.text.trim()) ?? 0;
              final reason = _reasonController.text.trim();

              ref
                  .read(movimentacoesControllerProvider.notifier)
                  .addMovimentacao(
                    _selectedProductId!,
                    prod.name,
                    _type,
                    qty,
                    reason,
                  );
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Movimentação de $_type ($qty un) para "${prod.name}" registrada!',
                  ),
                  backgroundColor: _type == 'Entrada'
                      ? ThemeColors.success
                      : Colors.orange.shade800,
                ),
              );
            }
          },
          child: const Text(
            'Confirmar Movimentação',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
      ],
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Produto',
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
                  initialValue: _selectedProductId,
                  hint: const Text('Selecione um produto...'),
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
                  validator: (val) =>
                      val == null ? 'Selecione um produto' : null,
                  items: availableProducts
                      .map(
                        (p) => DropdownMenuItem(
                          value: p.id,
                          child: Text('${p.name} (Atual: ${p.stock} un)'),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedProductId = val);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tipo de Lançamento',
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
                  initialValue: _type,
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
                      value: 'Entrada',
                      child: Text('Entrada (+)'),
                    ),
                    DropdownMenuItem(value: 'Saída', child: Text('Saída (-)')),
                    DropdownMenuItem(
                      value: 'Inventário',
                      child: Text('Inventário / Acerto (=)'),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _type = val);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            AppInput(
              label: _type == 'Inventário'
                  ? 'Nova Quantidade Real em Estoque'
                  : 'Quantidade de Itens',
              placeholder: 'Ex: 10',
              controller: _qtyController,
              keyboardType: TextInputType.number,
              inputFormatters: [AppMasks.digitsOnly],
              validator: AppValidators.integer(required: true, min: 1),
            ),
            const SizedBox(height: 16),
            AppInput(
              label: 'Motivo / Justificativa',
              placeholder:
                  'Ex: Compra de lote, fornecedor XYZ, avaria, consumo...',
              controller: _reasonController,
              validator: (val) =>
                  val == null || val.trim().isEmpty
                      ? 'Motivo obrigatório'
                      : null,
            ),
          ],
        ),
      ),
    );
  }
}
