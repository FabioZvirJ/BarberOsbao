import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:barber_osbao/packages/design_system/theme/theme_colors.dart';
import 'package:barber_osbao/packages/design_system/theme/app_breakpoints.dart';
import 'package:barber_osbao/packages/design_system/layouts/app_section.dart';
import 'package:barber_osbao/packages/design_system/organisms/app_table.dart';
import 'package:barber_osbao/packages/design_system/atoms/app_button.dart';
import 'package:barber_osbao/packages/design_system/atoms/app_status_chip.dart';
import 'package:barber_osbao/packages/design_system/molecules/app_input.dart';
import 'package:barber_osbao/packages/design_system/molecules/app_stat_card.dart';
import 'package:barber_osbao/packages/core/shared/state/app_state.dart';
import 'package:barber_osbao/features/financeiro/domain/models/cash_shift.dart';
import 'package:barber_osbao/features/financeiro/presentation/controllers/cash_controller.dart';

class CashPage extends ConsumerStatefulWidget {
  const CashPage({super.key});

  @override
  ConsumerState<CashPage> createState() => _CashPageState();
}

class _CashPageState extends ConsumerState<CashPage> {
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cashControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (state is AppLoading) {
      return const Center(child: CircularProgressIndicator(color: ThemeColors.primary));
    }
    if (state is AppError) {
      return Center(child: Text('Erro: ${(state as AppError).message}', style: const TextStyle(color: ThemeColors.danger)));
    }

    final activeCash = state.data;
    if (activeCash == null) {
      return _buildClosedCashView(context);
    }
    return _buildOpenCashView(context, activeCash, isDark);
  }

  Widget _buildClosedCashView(BuildContext context) {
    final controller = TextEditingController();
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: ThemeColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.lock_outline, size: 60, color: ThemeColors.primary),
            const SizedBox(height: 16),
            const Text(
              'O Caixa está Fechado',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            const Text(
              'Para iniciar as operações de venda e comissão hoje, abra o caixa informando o saldo em dinheiro inicial.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 24),
            AppInput(
              label: 'Saldo Inicial de Abertura (R\$)',
              controller: controller,
              placeholder: 'Ex: 100.00',
            ),
            const SizedBox(height: 16),
            AppButton(
              label: 'Abrir Caixa',
              icon: const Icon(Icons.key, size: 16),
              onPressed: () {
                final val = double.tryParse(controller.text) ?? 0.0;
                ref.read(cashControllerProvider.notifier).open(val);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOpenCashView(BuildContext context, CashShift cash, bool isDark) {
    final movementsState = ref.watch(cashMovementsControllerProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Metrics Summary
        LayoutBuilder(
          builder: (context, constraints) {
            final colCount = AppBreakpoints.gridColumns(context, desktopCols: 3, tabletCols: 3, mobileCols: 1);
            
            // Calculate sum dynamically from state if available
            double entries = 0.0;
            double exits = 0.0;
            if (movementsState is AppSuccess<List<CashMovement>>) {
              for (final mv in movementsState.data) {
                if (mv.type == 'input' || mv.type == 'supply') {
                  entries += mv.amount;
                } else if (mv.type == 'output' || mv.type == 'withdraw') {
                  exits += mv.amount;
                }
              }
            }

            final currentBalance = cash.initialBalance + entries - exits;

            return GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: colCount,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                mainAxisExtent: 100,
              ),
              children: [
                AppStatCard(
                  title: 'SALDO INICIAL',
                  value: 'R\$ ${cash.initialBalance.toStringAsFixed(2)}',
                  icon: const Icon(Icons.wallet, color: Colors.blue),
                ),
                AppStatCard(
                  title: 'MOVIMENTAÇÕES (LÍQ.)',
                  value: 'R\$ ${(entries - exits).toStringAsFixed(2)}',
                  icon: const Icon(Icons.swap_horiz, color: ThemeColors.warning),
                ),
                AppStatCard(
                  title: 'SALDO ATUAL EM CAIXA',
                  value: 'R\$ ${currentBalance.toStringAsFixed(2)}',
                  icon: const Icon(Icons.account_balance_wallet, color: ThemeColors.success),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 24),

        // Action Toolbar
        Wrap(
          spacing: 12,
          runSpacing: 10,
          children: [
            AppButton(
              label: 'Registrar Sangria',
              icon: const Icon(Icons.remove, size: 16),
              onPressed: () => _showMovementDialog(context, 'withdraw'),
            ),
            AppButton(
              label: 'Registrar Suprimento',
              icon: const Icon(Icons.add, size: 16),
              onPressed: () => _showMovementDialog(context, 'supply'),
            ),
            AppButton(
              label: 'Fechar Turno de Caixa',
              icon: const Icon(Icons.lock, size: 16),
              variant: AppButtonVariant.primary,
              onPressed: () => _showCloseCashDialog(context, cash, movementsState),
            ),
          ],
        ),
        const SizedBox(height: 32),

        // Movements Table
        AppSection(
          title: 'Histórico do Caixa de Hoje',
          subtitle: 'Acompanhe todas as entradas, saídas, sangrias e suprimentos do turno ativo',
          child: _buildMovementsTable(movementsState, isDark),
        ),
      ],
    );
  }

  Widget _buildMovementsTable(AppState<List<CashMovement>> state, bool isDark) {
    if (state is AppLoading) {
      return const Center(child: CircularProgressIndicator(color: ThemeColors.primary));
    }
    if (state is AppError) {
      return Center(child: Text('Erro: ${(state as AppError).message}', style: const TextStyle(color: ThemeColors.danger)));
    }

    final data = state.data ?? [];
    if (data.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        alignment: Alignment.center,
        child: Text('Nenhuma movimentação registrada neste caixa.', style: TextStyle(color: isDark ? Colors.white30 : Colors.grey)),
      );
    }

    return AppTable(
      minWidth: 700,
      columns: [
        AppTableColumn(label: 'HORA'),
        AppTableColumn(label: 'TIPO'),
        AppTableColumn(label: 'DESCRIÇÃO', width: 250),
        AppTableColumn(label: 'VALOR'),
        AppTableColumn(label: 'OPERADOR'),
      ],
      rows: data.map((mv) {
        final isInput = mv.type == 'input' || mv.type == 'supply';
        return AppTableRow(
          cells: [
            Text(mv.time),
            AppStatusChip(
              label: mv.type == 'withdraw' ? 'SANGRIA' : (mv.type == 'supply' ? 'SUPRIMENTO' : mv.type.toUpperCase()),
              type: isInput ? AppStatusType.success : AppStatusType.danger,
            ),
            Text(mv.description),
            Text(
              'R\$ ${mv.amount.toStringAsFixed(2)}',
              style: TextStyle(
                color: isInput ? ThemeColors.success : ThemeColors.danger,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(mv.user),
          ],
        );
      }).toList(),
    );
  }

  void _showMovementDialog(BuildContext context, String type) {
    _amountController.clear();
    _descriptionController.clear();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ThemeColors.darkBg,
        title: Text(type == 'withdraw' ? 'Registrar Sangria (Retirada)' : 'Registrar Suprimento (Troco)', style: const TextStyle(color: Colors.white, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppInput(
              label: 'Valor (R\$)',
              controller: _amountController,
              placeholder: 'Ex: 50.00',
            ),
            const SizedBox(height: 12),
            AppInput(
              label: 'Motivo / Descrição',
              controller: _descriptionController,
              placeholder: 'Ex: Pagamento motoboy ou troco inicial',
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
            onPressed: () => Navigator.pop(ctx),
          ),
          AppButton(
            label: 'Registrar',
            onPressed: () {
              final val = double.tryParse(_amountController.text) ?? 0.0;
              if (val > 0) {
                ref.read(cashControllerProvider.notifier).registerMovement(
                      type,
                      val,
                      _descriptionController.text.isNotEmpty ? _descriptionController.text : 'Movimentação manual de $type',
                    );
                Navigator.pop(ctx);
              }
            },
          ),
        ],
      ),
    );
  }

  void _showCloseCashDialog(BuildContext context, CashShift cash, AppState<List<CashMovement>> movementsState) {
    final reportController = TextEditingController();

    // Calculate sum dynamically from state if available
    double moneyEntries = 0.0;
    if (movementsState is AppSuccess<List<CashMovement>>) {
      for (final mv in movementsState.data) {
        if (mv.type == 'input' || mv.type == 'supply') {
          moneyEntries += mv.amount;
        } else if (mv.type == 'output' || mv.type == 'withdraw') {
          moneyEntries -= mv.amount;
        }
      }
    }

    final totalExpected = cash.initialBalance + moneyEntries;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ThemeColors.darkBg,
        title: const Text('Confirmar Fechamento de Caixa', style: TextStyle(color: Colors.white, fontSize: 16)),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: ThemeColors.surface, borderRadius: BorderRadius.circular(8)),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Saldo Inicial de Abertura', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        Text('R\$ ${cash.initialBalance.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total de Movimentações em Dinheiro', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        Text('R\$ ${moneyEntries.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                      ],
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Saldo de Caixa Esperado', style: TextStyle(color: ThemeColors.primary, fontWeight: FontWeight.bold, fontSize: 14)),
                        Text('R\$ ${totalExpected.toStringAsFixed(2)}', style: const TextStyle(color: ThemeColors.primary, fontWeight: FontWeight.bold, fontSize: 14)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AppInput(
                label: 'Valor Físico Contado em Dinheiro (R\$)',
                controller: reportController,
                placeholder: 'Ex: 230.00',
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
            label: 'Confirmar Fechamento',
            onPressed: () {
              final reported = double.tryParse(reportController.text) ?? 0.0;
              ref.read(cashControllerProvider.notifier).close(totalExpected, reported);
              Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
  }
}
