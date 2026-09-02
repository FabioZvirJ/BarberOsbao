import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:barber_osbao/packages/design_system/theme/theme_colors.dart';
import 'package:barber_osbao/packages/design_system/theme/app_breakpoints.dart';
import 'package:barber_osbao/packages/design_system/molecules/app_card.dart';
import 'package:barber_osbao/packages/design_system/atoms/app_button.dart';
import 'package:barber_osbao/packages/design_system/atoms/app_status_chip.dart';
import 'package:barber_osbao/packages/design_system/molecules/app_input.dart';
import 'package:barber_osbao/packages/core/shared/state/app_state.dart';
import 'package:barber_osbao/features/financeiro/domain/models/bill.dart';
import 'package:barber_osbao/features/financeiro/presentation/controllers/bill_controller.dart';
import 'package:barber_osbao/features/servicos/presentation/controllers/servicos_controller.dart';
import 'package:barber_osbao/features/produtos/presentation/controllers/produtos_controller.dart';
import 'package:barber_osbao/features/funcionarios/presentation/controllers/funcionarios_controller.dart';
import 'package:barber_osbao/features/servicos/domain/models/servico.dart';
import 'package:barber_osbao/features/produtos/domain/models/produto.dart';
import 'package:barber_osbao/features/funcionarios/domain/models/funcionario.dart';

class BillsPage extends ConsumerStatefulWidget {
  const BillsPage({super.key});

  @override
  ConsumerState<BillsPage> createState() => _BillsPageState();
}

class _BillsPageState extends ConsumerState<BillsPage> {
  final _billNameController = TextEditingController();

  @override
  void dispose() {
    _billNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(billControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Comandas e PDV',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            AppButton(
              label: 'Abrir Comanda',
              icon: const Icon(Icons.add_card, size: 16),
              onPressed: () => _showCreateBillDialog(context),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildContent(state, isDark),
      ],
    );
  }

  Widget _buildContent(AppState<List<Bill>> state, bool isDark) {
    if (state is AppLoading) {
      return const Center(
        child: CircularProgressIndicator(color: ThemeColors.primary),
      );
    }
    if (state is AppError) {
      return Center(
        child: Text(
          'Erro: ${(state as AppError).message}',
          style: const TextStyle(color: ThemeColors.danger),
        ),
      );
    }

    final data = state.data ?? [];
    final openBills = data.where((c) => c.status == 'open').toList();

    if (openBills.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        alignment: Alignment.center,
        child: Text(
          'Nenhuma comanda aberta no momento.',
          style: TextStyle(color: isDark ? Colors.white30 : Colors.grey),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossCount = AppBreakpoints.gridColumns(
          context,
          desktopCols: 4,
          tabletCols: 2,
          mobileCols: 1,
        );
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.15,
          ),
          itemCount: openBills.length,
          itemBuilder: (context, index) {
            final bill = openBills[index];
            return _buildBillCard(context, bill);
          },
        );
      },
    );
  }

  Widget _buildBillCard(BuildContext context, Bill bill) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  bill.clientName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const AppStatusChip(
                label: 'Em Aberto',
                type: AppStatusType.warning,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Hora: ${bill.time}',
            style: const TextStyle(color: Colors.grey, fontSize: 11),
          ),
          const SizedBox(height: 12),
          Text(
            '${bill.items.length} itens lançados',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'R\$ ${bill.total.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: ThemeColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.add_shopping_cart, size: 18),
                    onPressed: () => _showAddItemDialog(context, bill),
                    tooltip: 'Lançar Itens',
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.check_circle_outline,
                      size: 18,
                      color: ThemeColors.success,
                    ),
                    onPressed: () => _showCheckoutDialog(context, bill),
                    tooltip: 'Fechar Conta',
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCreateBillDialog(BuildContext context) {
    _billNameController.clear();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? ThemeColors.darkSurface : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: Text(
          'Abrir Nova Comanda',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: AppInput(
          label: 'Nome do Cliente / Identificador',
          controller: _billNameController,
          placeholder: 'Ex: João Silva ou Mesa 3',
        ),
        actions: [
          TextButton(
            child: Text(
              'Cancelar',
              style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
            ),
            onPressed: () => Navigator.pop(ctx),
          ),
          AppButton(
            label: 'Abrir',
            onPressed: () {
              if (_billNameController.text.isNotEmpty) {
                final now = DateTime.now();
                final todayStr =
                    '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
                final timeStr =
                    '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

                final newBill = Bill(
                  id: '',
                  clientName: _billNameController.text,
                  items: [],
                  status: 'open',
                  payments: [],
                  date: todayStr,
                  time: timeStr,
                );

                ref.read(billControllerProvider.notifier).addBill(newBill);
                Navigator.pop(ctx);
              }
            },
          ),
        ],
      ),
    );
  }

  void _showAddItemDialog(BuildContext context, Bill bill) {
    showDialog(
      context: context,
      builder: (ctx) => _AddBillItemDialog(bill: bill),
    );
  }

  void _showCheckoutDialog(BuildContext context, Bill bill) {
    showDialog(
      context: context,
      builder: (ctx) => _CheckoutBillDialog(bill: bill),
    );
  }
}

class _CheckoutBillDialog extends ConsumerStatefulWidget {
  final Bill bill;

  const _CheckoutBillDialog({required this.bill});

  @override
  ConsumerState<_CheckoutBillDialog> createState() =>
      _CheckoutBillDialogState();
}

class _CheckoutBillDialogState extends ConsumerState<_CheckoutBillDialog> {
  late final TextEditingController _discountController;
  late final TextEditingController _pixController;
  late final TextEditingController _cardController;
  late final TextEditingController _cashController;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _discountController = TextEditingController(text: '0');
    _pixController = TextEditingController(text: '0');
    _cardController = TextEditingController(text: '0');
    _cashController = TextEditingController(text: '0');
  }

  @override
  void dispose() {
    _discountController.dispose();
    _pixController.dispose();
    _cardController.dispose();
    _cashController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final subtotal = widget.bill.subtotal;
    final discount = double.tryParse(_discountController.text) ?? 0.0;
    final total = (subtotal - discount).clamp(0.0, double.infinity);

    final pixAmount = double.tryParse(_pixController.text) ?? 0.0;
    final cardAmount = double.tryParse(_cardController.text) ?? 0.0;
    final cashAmount = double.tryParse(_cashController.text) ?? 0.0;
    final totalPaid = pixAmount + cardAmount + cashAmount;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      backgroundColor: isDark ? ThemeColors.darkSurface : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      title: Text(
        'Fechar Comanda: ${widget.bill.clientName}',
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SizedBox(
        width: 450,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Invoice Summary
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? ThemeColors.darkBg : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    ...widget.bill.items.map(
                      (it) => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${it.quantity}x ${it.name}',
                            style: TextStyle(
                              color: isDark ? Colors.white70 : Colors.black87,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            'R\$ ${it.total.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: isDark ? Colors.white70 : Colors.black87,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      color: isDark ? Colors.white10 : Colors.grey.shade300,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Subtotal',
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                        Text(
                          'R\$ ${subtotal.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total a Pagar',
                          style: TextStyle(
                            color: ThemeColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          'R\$ ${total.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: ThemeColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AppInput(
                label: 'Desconto (R\$)',
                controller: _discountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: (_) => setState(() => _errorMessage = null),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Divisão de Pagamento (Split)',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _pixController.text = total.toStringAsFixed(2);
                        _cardController.text = '0';
                        _cashController.text = '0';
                        _errorMessage = null;
                      });
                    },
                    child: const Text(
                      'Preencher Total no PIX',
                      style: TextStyle(
                        color: ThemeColors.primary,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: AppInput(
                      label: 'PIX (R\$)',
                      controller: _pixController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (_) => setState(() => _errorMessage = null),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AppInput(
                      label: 'Cartão (R\$)',
                      controller: _cardController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (_) => setState(() => _errorMessage = null),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AppInput(
                      label: 'Dinheiro (R\$)',
                      controller: _cashController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (_) => setState(() => _errorMessage = null),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: (totalPaid - total).abs() < 0.01
                      ? ThemeColors.success.withValues(alpha: 0.1)
                      : Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Informado no Split:',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade300,
                      ),
                    ),
                    Text(
                      'R\$ ${totalPaid.toStringAsFixed(2)} / R\$ ${total.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: (totalPaid - total).abs() < 0.01
                            ? ThemeColors.success
                            : ThemeColors.danger,
                      ),
                    ),
                  ],
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 10),
                Text(
                  _errorMessage!,
                  style: const TextStyle(
                    color: ThemeColors.danger,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          onPressed: () => Navigator.pop(context),
        ),
        AppButton(
          label: 'Finalizar Pagamento',
          onPressed: () {
            if (discount > subtotal) {
              setState(
                () => _errorMessage =
                    'O desconto não pode ser maior que o subtotal.',
              );
              return;
            }

            final List<PaymentSplit> payments = [];
            if (pixAmount > 0) {
              payments.add(PaymentSplit(method: 'pix', amount: pixAmount));
            }
            if (cardAmount > 0) {
              payments.add(PaymentSplit(method: 'credit', amount: cardAmount));
            }
            if (cashAmount > 0) {
              payments.add(PaymentSplit(method: 'money', amount: cashAmount));
            }

            // If no split provided, default to money full total
            if (payments.isEmpty) {
              payments.add(PaymentSplit(method: 'money', amount: total));
            } else {
              // Double check split sum matches total due
              if ((totalPaid - total).abs() > 0.01) {
                setState(
                  () => _errorMessage =
                      'A soma das formas de pagamento (R\$ ${totalPaid.toStringAsFixed(2)}) não confere com o total (R\$ ${total.toStringAsFixed(2)}).',
                );
                return;
              }
            }

            ref
                .read(billControllerProvider.notifier)
                .checkoutBill(widget.bill, payments, discount);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}

class _AddBillItemDialog extends ConsumerStatefulWidget {
  final Bill bill;

  const _AddBillItemDialog({required this.bill});

  @override
  ConsumerState<_AddBillItemDialog> createState() => _AddBillItemDialogState();
}

class _AddBillItemDialogState extends ConsumerState<_AddBillItemDialog> {
  String _selectedType = 'service';
  String? _selectedItemId;
  String? _selectedProfessionalId;
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final servicesState = ref.watch(servicosControllerProvider);
    final productsState = ref.watch(produtosControllerProvider);
    final employeesState = ref.watch(funcionariosControllerProvider);

    final List<DropdownMenuItem<String>> itemsToSelect = [];

    if (_selectedType == 'service' &&
        servicesState is AppSuccess<List<Servico>>) {
      for (final item in servicesState.data) {
        itemsToSelect.add(
          DropdownMenuItem(
            value: item.id,
            child: Text('${item.name} - R\$ ${item.price.toStringAsFixed(2)}'),
          ),
        );
      }
    } else if (_selectedType == 'product' &&
        productsState is AppSuccess<List<Produto>>) {
      for (final item in productsState.data) {
        itemsToSelect.add(
          DropdownMenuItem(
            value: item.id,
            child: Text('${item.name} - R\$ ${item.price.toStringAsFixed(2)}'),
          ),
        );
      }
    }

    final List<DropdownMenuItem<String>> professionalsToSelect = [];
    if (employeesState is AppSuccess<List<Funcionario>>) {
      for (final emp in employeesState.data) {
        professionalsToSelect.add(
          DropdownMenuItem(value: emp.id, child: Text(emp.name)),
        );
      }
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      backgroundColor: isDark ? ThemeColors.darkSurface : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      title: Text(
        'Lançar na comanda de ${widget.bill.clientName}',
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text('Serviço')),
                    selected: _selectedType == 'service',
                    selectedColor: ThemeColors.primary,
                    labelStyle: TextStyle(
                      color: _selectedType == 'service'
                          ? Colors.black
                          : (isDark ? Colors.white70 : Colors.black87),
                      fontWeight: FontWeight.bold,
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedType = 'service';
                          _selectedItemId = null;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text('Produto')),
                    selected: _selectedType == 'product',
                    selectedColor: ThemeColors.primary,
                    labelStyle: TextStyle(
                      color: _selectedType == 'product'
                          ? Colors.black
                          : (isDark ? Colors.white70 : Colors.black87),
                      fontWeight: FontWeight.bold,
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedType = 'product';
                          _selectedItemId = null;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              key: ValueKey('item_$_selectedType'),
              dropdownColor: isDark ? ThemeColors.darkSurface : Colors.white,
              decoration: InputDecoration(
                labelText: 'Selecione o item',
                labelStyle: TextStyle(
                  color: isDark ? Colors.grey : Colors.grey.shade600,
                ),
                filled: true,
                fillColor: isDark
                    ? ThemeColors.darkSurface
                    : Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: isDark
                        ? ThemeColors.darkBorder
                        : Colors.grey.shade300,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: isDark
                        ? ThemeColors.darkBorder
                        : Colors.grey.shade300,
                  ),
                ),
              ),
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              initialValue: _selectedItemId,
              items: itemsToSelect,
              onChanged: (val) => setState(() => _selectedItemId = val),
            ),
            const SizedBox(height: 12),
            if (_selectedType == 'service') ...[
              DropdownButtonFormField<String>(
                dropdownColor: isDark ? ThemeColors.darkSurface : Colors.white,
                decoration: InputDecoration(
                  labelText: 'Barbeiro Responsável',
                  labelStyle: TextStyle(
                    color: isDark ? Colors.grey : Colors.grey.shade600,
                  ),
                  filled: true,
                  fillColor: isDark
                      ? ThemeColors.darkSurface
                      : Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: isDark
                          ? ThemeColors.darkBorder
                          : Colors.grey.shade300,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: isDark
                          ? ThemeColors.darkBorder
                          : Colors.grey.shade300,
                    ),
                  ),
                ),
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                initialValue: _selectedProfessionalId,
                items: professionalsToSelect,
                onChanged: (val) =>
                    setState(() => _selectedProfessionalId = val),
              ),
              const SizedBox(height: 12),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Quantidade:',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.remove,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      onPressed: _quantity > 1
                          ? () => setState(() => _quantity--)
                          : null,
                    ),
                    Text(
                      '$_quantity',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.add,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      onPressed: () => setState(() => _quantity++),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: Text(
            'Cancelar',
            style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        AppButton(
          label: 'Lançar',
          onPressed: () {
            if (_selectedItemId != null) {
              String name = '';
              double price = 0.0;
              String? profName;

              if (_selectedType == 'service' &&
                  servicesState is AppSuccess<List<Servico>>) {
                final s = servicesState.data.firstWhere(
                  (x) => x.id == _selectedItemId,
                );
                name = s.name;
                price = s.price;
                if (_selectedProfessionalId != null &&
                    employeesState is AppSuccess<List<Funcionario>>) {
                  profName = employeesState.data
                      .firstWhere((e) => e.id == _selectedProfessionalId)
                      .name;
                }
              } else if (_selectedType == 'product' &&
                  productsState is AppSuccess<List<Produto>>) {
                final p = productsState.data.firstWhere(
                  (x) => x.id == _selectedItemId,
                );
                name = p.name;
                price = p.price;
              }

              final item = BillItem(
                id: _selectedItemId!,
                name: name,
                type: _selectedType,
                price: price,
                quantity: _quantity,
                professionalId: _selectedProfessionalId,
                professionalName: profName,
              );

              final updated = widget.bill.copyWith(
                items: [...widget.bill.items, item],
              );
              ref.read(billControllerProvider.notifier).updateBill(updated);
              Navigator.pop(context);
            }
          },
        ),
      ],
    );
  }
}
