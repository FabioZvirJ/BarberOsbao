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
import 'package:barber_osbao/packages/core/models/plan.dart';
import 'package:barber_osbao/packages/core/shared/repositories/plan_repository.dart';

class PlanosPage extends ConsumerWidget {
  const PlanosPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plansState = ref.watch(plansListProvider);

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
                onPressed: () => _showPlanFormDialog(context, ref),
              ),
            ],
          ),
          const SizedBox(height: 32),

          AppSection(
            title: 'Planos de Assinatura',
            subtitle: 'Gerencie os planos do clube de fidelidade recorrente (SaaS)',
            child: plansState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => const Center(child: Text('Erro ao carregar planos.')),
              data: (list) {
                return AppTable(
                  columns: [
                    AppTableColumn(label: 'PLANO'),
                    AppTableColumn(label: 'VALOR RECORRENTE'),
                    AppTableColumn(label: 'BENEFÍCIOS INCLUSOS', width: 450),
                    AppTableColumn(label: 'STATUS'),
                    AppTableColumn(label: 'AÇÕES', width: 100),
                  ],
                  rows: list.map((plan) {
                    return AppTableRow(
                      cells: [
                        Row(
                          children: [
                            Text(plan.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            if (plan.recommended) ...[
                              const SizedBox(width: 8),
                              const AppStatusChip(label: 'Popular', type: AppStatusType.info),
                            ]
                          ],
                        ),
                        Text(
                          'R\$ ${plan.price.toStringAsFixed(2)} / ${plan.period}',
                          style: const TextStyle(color: ThemeColors.primary, fontWeight: FontWeight.bold),
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
                        const AppStatusChip(label: 'Ativo', type: AppStatusType.success),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 18),
                              onPressed: () => _showPlanFormDialog(context, ref, plan),
                              tooltip: 'Editar',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 18, color: ThemeColors.danger),
                              onPressed: () => _showDeleteConfirmation(context, ref, plan),
                              tooltip: 'Remover',
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

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, Plan plan) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ThemeColors.darkBg,
        title: const Text('Excluir Plano', style: TextStyle(color: Colors.white)),
        content: Text('Tem certeza que deseja excluir o plano "${plan.name}"? Isso não poderá ser desfeito.', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: ThemeColors.danger),
            onPressed: () async {
              await ref.read(plansListProvider.notifier).deletePlan(plan.id);
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showPlanFormDialog(BuildContext context, WidgetRef ref, [Plan? plan]) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: plan?.name ?? '');
    final priceController = TextEditingController(text: plan?.price.toString() ?? '');
    String period = plan?.period ?? 'mensal';
    bool recommended = plan?.recommended ?? false;
    List<String> benefits = List.from(plan?.benefits ?? []);
    final benefitInputController = TextEditingController();

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
                        validator: (value) => value == null || value.isEmpty ? 'Campo obrigatório' : null,
                      ),
                      const SizedBox(height: 16),
                      AppInput(
                        label: 'Valor Recorrente (R\$)',
                        placeholder: 'Ex: 149.90',
                        controller: priceController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Campo obrigatório';
                          if (double.tryParse(value) == null) return 'Valor inválido';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        dropdownColor: ThemeColors.darkBg,
                        value: period,
                        decoration: const InputDecoration(
                          labelText: 'Frequência de Cobrança',
                          labelStyle: TextStyle(color: Colors.white70),
                          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
                        ),
                        style: const TextStyle(color: Colors.white),
                        items: const [
                          DropdownMenuItem(value: 'mensal', child: Text('Mensal')),
                          DropdownMenuItem(value: 'anual', child: Text('Anual')),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => period = val);
                        },
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text('Plano Recomendado / Popular', style: TextStyle(color: Colors.white70, fontSize: 14)),
                        value: recommended,
                        activeColor: ThemeColors.primary,
                        onChanged: (val) => setState(() => recommended = val),
                      ),
                      const SizedBox(height: 16),
                      const Text('Benefícios do Plano', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: AppInput(
                              label: 'Novo Benefício',
                              placeholder: 'Ex: Bebida grátis por visita',
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
                  onPressed: () async {
                    if (formKey.currentState?.validate() ?? false) {
                      final name = nameController.text.trim();
                      final price = double.parse(priceController.text.trim());
                      final newPlan = Plan(
                        id: plan?.id ?? 'pl_${DateTime.now().millisecondsSinceEpoch}',
                        name: name,
                        price: price,
                        period: period,
                        benefits: benefits,
                        recommended: recommended,
                      );

                      if (plan == null) {
                        await ref.read(plansListProvider.notifier).addPlan(newPlan);
                      } else {
                        await ref.read(plansListProvider.notifier).updatePlan(newPlan);
                      }

                      if (ctx.mounted) Navigator.of(ctx).pop();
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
}
