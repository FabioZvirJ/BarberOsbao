import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:barber_osbao/packages/design_system/theme/theme_colors.dart';
import 'package:barber_osbao/packages/design_system/layouts/app_page.dart';
import 'package:barber_osbao/packages/design_system/layouts/app_section.dart';
import 'package:barber_osbao/packages/design_system/organisms/app_table.dart';
import 'package:barber_osbao/packages/design_system/atoms/app_button.dart';
import 'package:barber_osbao/packages/design_system/atoms/app_status_chip.dart';
import 'package:barber_osbao/packages/design_system/molecules/app_input.dart';
import 'package:barber_osbao/packages/core/shared/state/app_state.dart';
import 'package:barber_osbao/features/planos/domain/models/plano.dart';
import 'package:barber_osbao/features/planos/presentation/controllers/planos_controller.dart';

class PlanosPage extends ConsumerWidget {
  const PlanosPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(planosControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppPage(
      title: 'Planos',
      userName: 'Fábio Zvir',
      userAvatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&width=150',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox.shrink(),
              AppButton(
                label: 'Novo Plano',
                icon: const Icon(Icons.add, size: 16),
                onPressed: () => _showFormDialog(context, ref),
              ),
            ],
          ),
          const SizedBox(height: 32),

          AppSection(
            title: 'Planos de Assinatura (SaaS)',
            subtitle: 'Gerencie os planos de assinatura recorrentes para os clientes fidelizados',
            child: _buildContent(context, state, isDark, ref),
          ),
        ],
      ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0, curve: Curves.easeOut),
    );
  }

  Widget _buildContent(BuildContext context, AppState<List<Plano>> state, bool isDark, WidgetRef ref) {
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
        child: Text('Nenhum plano cadastrado.', style: TextStyle(color: isDark ? Colors.white30 : Colors.grey)),
      );
    }

    return AppTable(
      columns: [
        AppTableColumn(label: 'PLANO'),
        AppTableColumn(label: 'VALOR RECORRENTE'),
        AppTableColumn(label: 'COBRANÇA'),
        AppTableColumn(label: 'LIMITES (CORTES/DESCONTOS)'),
        AppTableColumn(label: 'BENEFÍCIOS INCLUSOS', width: 350),
        AppTableColumn(label: 'STATUS'),
        AppTableColumn(label: 'AÇÕES', width: 100),
      ],
      rows: data.map((plan) {
        return AppTableRow(
          cells: [
            Row(
              children: [
                Text(plan.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                if (plan.recommended) ...[
                  const SizedBox(width: 8),
                  const AppStatusChip(label: 'Destaque', type: AppStatusType.info),
                ]
              ],
            ),
            Text(
              'R\$ ${plan.price.toStringAsFixed(2)}',
              style: const TextStyle(color: ThemeColors.primary, fontWeight: FontWeight.bold),
            ),
            Text(plan.period.toUpperCase()),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan.cutsCount == 9999 ? 'Cortes Ilimitados' : '${plan.cutsCount} cortes/mês',
                  style: const TextStyle(fontSize: 12),
                ),
                Text(
                  plan.productDiscount > 0
                      ? 'Desconto produtos: ${(plan.productDiscount * 100).toStringAsFixed(0)}%'
                      : 'Sem desc. em produtos',
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: plan.benefits.map((b) => Row(
                  children: [
                    const Icon(Icons.check_circle_outline, color: ThemeColors.primary, size: 12),
                    const SizedBox(width: 6),
                    Expanded(child: Text(b, style: const TextStyle(fontSize: 12))),
                  ],
                )).toList(),
              ),
            ),
            AppStatusChip(
              label: plan.status ? 'Ativo' : 'Inativo',
              type: plan.status ? AppStatusType.success : AppStatusType.danger,
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  onPressed: () => _showFormDialog(context, ref, plan),
                  tooltip: 'Editar',
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18, color: ThemeColors.danger),
                  onPressed: () => _showDeleteDialog(context, ref, plan),
                  tooltip: 'Excluir',
                ),
              ],
            ),
          ],
        );
      }).toList(),
    );
  }

  void _showFormDialog(BuildContext context, WidgetRef ref, [Plano? plan]) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: plan?.name ?? '');
    final priceController = TextEditingController(text: plan?.price.toString() ?? '');
    final cutsController = TextEditingController(text: plan != null ? (plan.cutsCount == 9999 ? '9999' : plan.cutsCount.toString()) : '4');
    final discountController = TextEditingController(text: plan != null ? (plan.productDiscount * 100).toStringAsFixed(0) : '10');
    final benefitInputController = TextEditingController();

    String period = plan?.period ?? 'mensal';
    bool recommended = plan?.recommended ?? false;
    bool status = plan?.status ?? true;
    List<String> benefits = List.from(plan?.benefits ?? []);

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: ThemeColors.darkBg,
              title: Text(plan == null ? 'Criar Novo Plano' : 'Editar Plano', style: const TextStyle(color: Colors.white)),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppInput(
                        label: 'Nome do Plano',
                        placeholder: 'Ex: Plano Imperial',
                        controller: nameController,
                        validator: (val) => val == null || val.isEmpty ? 'Nome obrigatório' : null,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: AppInput(
                              label: 'Valor Recorrente (R\$)',
                              placeholder: 'Ex: 139.90',
                              controller: priceController,
                              keyboardType: TextInputType.number,
                              validator: (val) => val == null || val.isEmpty ? 'Valor obrigatório' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              dropdownColor: ThemeColors.darkBg,
                              initialValue: period,
                              decoration: const InputDecoration(
                                labelText: 'Cobrança',
                                labelStyle: TextStyle(color: Colors.white70),
                                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
                              ),
                              style: const TextStyle(color: Colors.white),
                              items: const [
                                DropdownMenuItem(value: 'mensal', child: Text('Mensal')),
                                DropdownMenuItem(value: 'trimestral', child: Text('Trimestral')),
                                DropdownMenuItem(value: 'semestral', child: Text('Semestral')),
                                DropdownMenuItem(value: 'anual', child: Text('Anual')),
                              ],
                              onChanged: (val) {
                                if (val != null) setState(() => period = val);
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
                              label: 'Qtd de Cortes (9999 = Ilimitado)',
                              placeholder: 'Ex: 4',
                              controller: cutsController,
                              keyboardType: TextInputType.number,
                              validator: (val) => val == null || val.isEmpty ? 'Qtd de cortes obrigatória' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppInput(
                              label: 'Desconto em Produtos (%)',
                              placeholder: 'Ex: 10',
                              controller: discountController,
                              keyboardType: TextInputType.number,
                              validator: (val) => val == null || val.isEmpty ? 'Desconto obrigatório' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text('Destacar Plano (Recomendado)', style: TextStyle(color: Colors.white70, fontSize: 14)),
                        value: recommended,
                        activeThumbColor: ThemeColors.primary,
                        onChanged: (val) => setState(() => recommended = val),
                      ),
                      SwitchListTile(
                        title: const Text('Plano Ativo', style: TextStyle(color: Colors.white70, fontSize: 14)),
                        value: status,
                        activeThumbColor: ThemeColors.primary,
                        onChanged: (val) => setState(() => status = val),
                      ),
                      const SizedBox(height: 16),
                      const Text('Benefícios Adicionais', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: AppInput(
                              label: 'Novo Benefício',
                              placeholder: 'Ex: Cerveja grátis por visita',
                              controller: benefitInputController,
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.add_circle, color: ThemeColors.primary, size: 36),
                            onPressed: () {
                              final text = benefitInputController.text.trim();
                              if (text.isNotEmpty) {
                                setState(() {
                                  benefits.add(text);
                                  benefitInputController.clear();
                                });
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (benefits.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Text('Nenhum benefício adicionado.', style: TextStyle(color: Colors.white30, fontSize: 12, fontStyle: FontStyle.italic)),
                        )
                      else
                        ...benefits.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final b = entry.value;
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.check, color: ThemeColors.primary, size: 16),
                            title: Text(b, style: const TextStyle(color: Colors.white, fontSize: 13)),
                            trailing: IconButton(
                              icon: const Icon(Icons.remove_circle_outline, color: ThemeColors.danger, size: 18),
                              onPressed: () => setState(() => benefits.removeAt(idx)),
                            ),
                          );
                        }),
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
                      final newPlan = Plano(
                        id: plan?.id ?? '',
                        name: nameController.text.trim(),
                        price: double.parse(priceController.text.trim()),
                        period: period,
                        benefits: benefits,
                        cutsCount: int.parse(cutsController.text.trim()),
                        productDiscount: double.parse(discountController.text.trim()) / 100.0,
                        status: status,
                        recommended: recommended,
                      );

                      if (plan == null) {
                        ref.read(planosControllerProvider.notifier).addPlano(newPlan);
                      } else {
                        ref.read(planosControllerProvider.notifier).editPlano(newPlan);
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

  void _showDeleteDialog(BuildContext context, WidgetRef ref, Plano plan) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ThemeColors.darkBg,
        title: const Text('Excluir Plano', style: TextStyle(color: Colors.white)),
        content: Text('Tem certeza que deseja excluir o plano "${plan.name}"? Isso cancelará as cobranças futuras.', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: ThemeColors.danger),
            onPressed: () {
              ref.read(planosControllerProvider.notifier).removePlano(plan.id);
              Navigator.of(ctx).pop();
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
