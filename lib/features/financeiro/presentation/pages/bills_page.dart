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
      return const Center(child: CircularProgressIndicator(color: ThemeColors.primary));
    }
    if (state is AppError) {
      return Center(child: Text('Erro: ${(state as AppError).message}', style: const TextStyle(color: ThemeColors.danger)));
    }

    final data = state.data ?? [];
    final openBills = data.where((c) => c.status == 'open').toList();

    if (openBills.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        alignment: Alignment.center,
        child: Text('Nenhuma comanda aberta no momento.', style: TextStyle(color: isDark ? Colors.white30 : Colors.grey)),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossCount = AppBreakpoints.gridColumns(context, desktopCols: 4, tabletCols: 2, mobileCols: 1);
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
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const AppStatusChip(label: 'Em Aberto', type: AppStatusType.warning),
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
                style: const TextStyle(color: ThemeColors.primary, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.add_shopping_cart, size: 18),
                    onPressed: () => _showAddItemDialog(context, bill),
                    tooltip: 'Lançar Itens',
                  ),
                  IconButton(
                    icon: const Icon(Icons.check_circle_outline, size: 18, color: ThemeColors.success),
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
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ThemeColors.darkBg,
        title: const Text('Abrir Nova Comanda', style: TextStyle(color: Colors.white)),
        content: AppInput(
          label: 'Nome do Cliente / Identificador',
          controller: _billNameController,
          placeholder: 'Ex: João Silva ou Mesa 3',
        ),
        actions: [
          TextButton(
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
            onPressed: () => Navigator.pop(ctx),
          ),
          AppButton(
            label: 'Abrir',
            onPressed: () {
              if (_billNameController.text.isNotEmpty) {
                final now = DateTime.now();
                final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
                final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

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
    final servicesState = ref.read(servicosControllerProvider);
    final productsState = ref.read(produtosControllerProvider);
    final employeesState = ref.read(funcionariosControllerProvider);

    String? selectedType = 'service';
    String? selectedItemId;
    String? selectedProfessionalId;
    int quantity = 1;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          final List<DropdownMenuItem<String>> itemsToSelect = [];

          if (selectedType == 'service' && servicesState is AppSuccess<List<Servico>>) {
            final list = servicesState.data;
            for (final item in list) {
              itemsToSelect.add(DropdownMenuItem(value: item.id, child: Text('${item.name} - R\$ ${item.price.toStringAsFixed(2)}')));
            }
          } else if (selectedType == 'product' && productsState is AppSuccess<List<Produto>>) {
            final list = productsState.data;
            for (final item in list) {
              itemsToSelect.add(DropdownMenuItem(value: item.id, child: Text('${item.name} - R\$ ${item.price.toStringAsFixed(2)}')));
            }
          }

          final List<DropdownMenuItem<String>> professionalsToSelect = [];
          if (employeesState is AppSuccess<List<Funcionario>>) {
            final list = employeesState.data;
            for (final emp in list) {
              professionalsToSelect.add(DropdownMenuItem(value: emp.id, child: Text(emp.name)));
            }
          }

          return AlertDialog(
            backgroundColor: ThemeColors.darkBg,
            title: Text('Lançar na comanda de ${bill.clientName}', style: const TextStyle(color: Colors.white, fontSize: 16)),
            content: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text('Serviço', style: TextStyle(color: Colors.white, fontSize: 12)),
                          value: 'service',
                          groupValue: selectedType,
                          activeColor: ThemeColors.primary,
                          contentPadding: EdgeInsets.zero,
                          onChanged: (val) {
                            setDialogState(() {
                              selectedType = val;
                              selectedItemId = null;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text('Produto', style: TextStyle(color: Colors.white, fontSize: 12)),
                          value: 'product',
                          groupValue: selectedType,
                          activeColor: ThemeColors.primary,
                          contentPadding: EdgeInsets.zero,
                          onChanged: (val) {
                            setDialogState(() {
                              selectedType = val;
                              selectedItemId = null;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    dropdownColor: ThemeColors.darkBg,
                    decoration: const InputDecoration(labelText: 'Selecione o item', labelStyle: TextStyle(color: Colors.grey)),
                    style: const TextStyle(color: Colors.white),
                    value: selectedItemId,
                    items: itemsToSelect,
                    onChanged: (val) => setDialogState(() => selectedItemId = val),
                  ),
                  const SizedBox(height: 12),
                  if (selectedType == 'service') ...[
                    DropdownButtonFormField<String>(
                      dropdownColor: ThemeColors.darkBg,
                      decoration: const InputDecoration(labelText: 'Barbeiro Responsável', labelStyle: TextStyle(color: Colors.grey)),
                      style: const TextStyle(color: Colors.white),
                      value: selectedProfessionalId,
                      items: professionalsToSelect,
                      onChanged: (val) => setDialogState(() => selectedProfessionalId = val),
                    ),
                    const SizedBox(height: 12),
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Quantidade:', style: TextStyle(color: Colors.white)),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove, color: Colors.white),
                            onPressed: quantity > 1 ? () => setDialogState(() => quantity--) : null,
                          ),
                          Text('$quantity', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: const Icon(Icons.add, color: Colors.white),
                            onPressed: () => setDialogState(() => quantity++),
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
                child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
                onPressed: () => Navigator.pop(ctx),
              ),
              AppButton(
                label: 'Lançar',
                onPressed: () {
                  if (selectedItemId != null) {
                    String name = '';
                    double price = 0.0;
                    String? profName;

                    if (selectedType == 'service' && servicesState is AppSuccess<List<Servico>>) {
                      final list = servicesState.data;
                      final s = list.firstWhere((x) => x.id == selectedItemId);
                      name = s.name;
                      price = s.price;
                      if (selectedProfessionalId != null && employeesState is AppSuccess<List<Funcionario>>) {
                        profName = employeesState.data.firstWhere((e) => e.id == selectedProfessionalId).name;
                      }
                    } else if (selectedType == 'product' && productsState is AppSuccess<List<Produto>>) {
                      final list = productsState.data;
                      final p = list.firstWhere((x) => x.id == selectedItemId);
                      name = p.name;
                      price = p.price;
                    }

                    final item = BillItem(
                      id: selectedItemId!,
                      name: name,
                      type: selectedType!,
                      price: price,
                      quantity: quantity,
                      professionalId: selectedProfessionalId,
                      professionalName: profName,
                    );

                    final updated = bill.copyWith(
                      items: [...bill.items, item],
                    );

                    ref.read(billControllerProvider.notifier).updateBill(updated);
                    Navigator.pop(ctx);
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }

  void _showCheckoutDialog(BuildContext context, Bill bill) {
    double discount = 0.0;
    final discountController = TextEditingController(text: '0');

    // Payments split map
    double pixAmount = 0.0;
    double cardAmount = 0.0;
    double cashAmount = 0.0;

    final pixController = TextEditingController(text: '0');
    final cardController = TextEditingController(text: '0');
    final cashController = TextEditingController(text: '0');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          final subtotal = bill.subtotal;
          final total = subtotal - discount;

          void updateValues() {
            discount = double.tryParse(discountController.text) ?? 0.0;
          }

          return AlertDialog(
            backgroundColor: ThemeColors.darkBg,
            title: Text('Fechar Comanda: ${bill.clientName}', style: const TextStyle(color: Colors.white, fontSize: 16)),
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
                      decoration: BoxDecoration(color: ThemeColors.surface, borderRadius: BorderRadius.circular(8)),
                      child: Column(
                        children: [
                          ...bill.items.map((it) => Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${it.quantity}x ${it.name}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                              Text('R\$ ${it.total.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                            ],
                          )),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Subtotal', style: TextStyle(color: Colors.grey, fontSize: 13)),
                              Text('R\$ ${subtotal.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 13)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total a Pagar', style: TextStyle(color: ThemeColors.primary, fontWeight: FontWeight.bold, fontSize: 15)),
                              Text('R\$ ${total.toStringAsFixed(2)}', style: const TextStyle(color: ThemeColors.primary, fontWeight: FontWeight.bold, fontSize: 15)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    AppInput(
                      label: 'Desconto (R\$)',
                      controller: discountController,
                      onChanged: (val) {
                        setDialogState(() {
                          updateValues();
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text('Divisão de Pagamento (Split)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: AppInput(
                            label: 'PIX (R\$)',
                            controller: pixController,
                            onChanged: (val) {
                              pixAmount = double.tryParse(val) ?? 0.0;
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: AppInput(
                            label: 'Cartão (R\$)',
                            controller: cardController,
                            onChanged: (val) {
                              cardAmount = double.tryParse(val) ?? 0.0;
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: AppInput(
                            label: 'Dinheiro (R\$)',
                            controller: cashController,
                            onChanged: (val) {
                              cashAmount = double.tryParse(val) ?? 0.0;
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
                onPressed: () => Navigator.pop(ctx),
              ),
              AppButton(
                label: 'Finalizar Pagamento',
                onPressed: () {
                  updateValues();
                  final List<PaymentSplit> payments = [];
                  if (pixAmount > 0) payments.add(PaymentSplit(method: 'pix', amount: pixAmount));
                  if (cardAmount > 0) payments.add(PaymentSplit(method: 'credit', amount: cardAmount));
                  if (cashAmount > 0) payments.add(PaymentSplit(method: 'money', amount: cashAmount));

                  // Fallback to cash if none specified
                  if (payments.isEmpty) {
                    payments.add(PaymentSplit(method: 'money', amount: total));
                  }

                  ref.read(billControllerProvider.notifier).checkoutBill(bill, payments, discount);
                  Navigator.pop(ctx);
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
