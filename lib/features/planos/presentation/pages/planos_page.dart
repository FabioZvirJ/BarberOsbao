import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:barber_osbao/packages/design_system/theme/theme_colors.dart';
import 'package:barber_osbao/packages/design_system/theme/app_breakpoints.dart';
import 'package:barber_osbao/packages/design_system/layouts/app_page.dart';
import 'package:barber_osbao/packages/design_system/layouts/app_section.dart';
import 'package:barber_osbao/packages/design_system/organisms/app_table.dart';
import 'package:barber_osbao/packages/design_system/atoms/app_button.dart';
import 'package:barber_osbao/packages/design_system/atoms/app_status_chip.dart';
import 'package:barber_osbao/packages/design_system/molecules/app_input.dart';
import 'package:barber_osbao/packages/design_system/molecules/app_card.dart';
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
      userAvatarUrl:
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&width=150',
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
            subtitle:
                'Gerencie os planos de assinatura recorrentes para os clientes fidelizados',
            child: _buildContent(context, state, isDark, ref),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    AppState<List<Plano>> state,
    bool isDark,
    WidgetRef ref,
  ) {
    if (state is AppLoading) {
      return const Padding(
        padding: EdgeInsets.all(40.0),
        child: Center(
          child: CircularProgressIndicator(color: ThemeColors.primary),
        ),
      );
    }

    if (state is AppError) {
      return Padding(
        padding: const EdgeInsets.all(40.0),
        child: Center(
          child: Text(
            'Erro: ${(state as AppError).message}',
            style: const TextStyle(color: ThemeColors.danger),
          ),
        ),
      );
    }

    final data = state.data ?? [];
    if (state is AppEmpty || data.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        alignment: Alignment.center,
        child: Text(
          'Nenhum plano cadastrado.',
          style: TextStyle(color: isDark ? Colors.white30 : Colors.grey),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (AppBreakpoints.isDesktop(context)) {
          return AppTable(
            minWidth: 960,
            columns: [
              AppTableColumn(label: 'PLANO', flex: 3),
              AppTableColumn(label: 'VALOR RECORRENTE', width: 140),
              AppTableColumn(label: 'COBRANÇA', width: 110),
              AppTableColumn(label: 'LIMITES (CORTES/DESCONTOS)', flex: 2),
              AppTableColumn(label: 'BENEFÍCIOS INCLUSOS', flex: 4),
              AppTableColumn(label: 'STATUS', width: 90),
              AppTableColumn(label: 'AÇÕES', width: 90),
            ],
            rows: data.map((plan) {
              return AppTableRow(
                cells: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      Text(
                        plan.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      if (plan.recommended)
                        const AppStatusChip(
                          label: 'Destaque',
                          type: AppStatusType.info,
                        ),
                    ],
                  ),
                  Text(
                    'R\$ ${plan.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: ThemeColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(plan.period.toUpperCase()),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan.cutsCount == 9999
                            ? 'Cortes Ilimitados'
                            : '${plan.cutsCount} cortes/mês',
                        style: const TextStyle(fontSize: 12),
                      ),
                      Text(
                        plan.productDiscount > 0
                            ? 'Desconto produtos: ${(plan.productDiscount * 100).toStringAsFixed(0)}%'
                            : 'Sem desc. em produtos',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: plan.benefits
                          .map(
                            (b) => Row(
                              children: [
                                const Icon(
                                  Icons.check_circle_outline,
                                  color: ThemeColors.primary,
                                  size: 12,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    b,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  AppStatusChip(
                    label: plan.status ? 'Ativo' : 'Inativo',
                    type: plan.status
                        ? AppStatusType.success
                        : AppStatusType.danger,
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        onPressed: () => _showFormDialog(context, ref, plan),
                        tooltip: 'Editar',
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          size: 18,
                          color: ThemeColors.danger,
                        ),
                        onPressed: () => _showDeleteDialog(context, ref, plan),
                        tooltip: 'Excluir',
                      ),
                    ],
                  ),
                ],
              );
            }).toList(),
          );
        } else {
          final isTablet = constraints.maxWidth > 650;
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isTablet ? 2 : 1,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: isTablet ? 1.25 : 1.1,
            ),
            itemCount: data.length,
            itemBuilder: (context, index) {
              return _buildCard(context, data[index], isDark, ref);
            },
          );
        }
      },
    );
  }

  Widget _buildCard(
    BuildContext context,
    Plano plan,
    bool isDark,
    WidgetRef ref,
  ) {
    return AppCard(
      borderGlow: plan.recommended,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      plan.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (plan.recommended)
                      const AppStatusChip(
                        label: 'Destaque',
                        type: AppStatusType.info,
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              AppStatusChip(
                label: plan.status ? 'Ativo' : 'Inativo',
                type: plan.status
                    ? AppStatusType.success
                    : AppStatusType.danger,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                'R\$ ${plan.price.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: ThemeColors.primary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '/ ${plan.period}',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),
          Text(
            plan.cutsCount == 9999
                ? 'Cortes Ilimitados'
                : '${plan.cutsCount} cortes/mês',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(
            plan.productDiscount > 0
                ? 'Desconto produtos: ${(plan.productDiscount * 100).toStringAsFixed(0)}%'
                : 'Sem desc. em produtos',
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          const Text(
            'Benefícios:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: plan.benefits
                    .map(
                      (b) => Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 2.0),
                              child: Icon(
                                Icons.check_circle_outline,
                                color: ThemeColors.primary,
                                size: 12,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                b,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 18),
                onPressed: () => _showFormDialog(context, ref, plan),
                tooltip: 'Editar',
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  size: 18,
                  color: ThemeColors.danger,
                ),
                onPressed: () => _showDeleteDialog(context, ref, plan),
                tooltip: 'Excluir',
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showFormDialog(BuildContext context, WidgetRef ref, [Plano? plan]) {
    showDialog(
      context: context,
      builder: (ctx) => _PlanoFormDialog(plan: plan),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, Plano plan) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? ThemeColors.darkSurface : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: Text(
          'Excluir Plano',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Tem certeza que deseja excluir o plano "${plan.name}"? Isso cancelará as cobranças futuras.',
          style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancelar',
              style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeColors.danger,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
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

class _PlanoFormDialog extends ConsumerStatefulWidget {
  final Plano? plan;

  const _PlanoFormDialog({this.plan});

  @override
  ConsumerState<_PlanoFormDialog> createState() => _PlanoFormDialogState();
}

class _PlanoFormDialogState extends ConsumerState<_PlanoFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _cutsController;
  late final TextEditingController _discountController;
  late final TextEditingController _benefitInputController;

  late String _period;
  late bool _recommended;
  late bool _status;
  late List<String> _benefits;

  @override
  void initState() {
    super.initState();
    final p = widget.plan;
    _nameController = TextEditingController(text: p?.name ?? '');
    _priceController = TextEditingController(text: p?.price.toString() ?? '');
    _cutsController = TextEditingController(
      text: p != null
          ? (p.cutsCount == 9999 ? '9999' : p.cutsCount.toString())
          : '4',
    );
    _discountController = TextEditingController(
      text: p != null ? (p.productDiscount * 100).toStringAsFixed(0) : '10',
    );
    _benefitInputController = TextEditingController();

    _period = p?.period ?? 'mensal';
    _recommended = p?.recommended ?? false;
    _status = p?.status ?? true;
    _benefits = List.from(p?.benefits ?? []);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _cutsController.dispose();
    _discountController.dispose();
    _benefitInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final plan = widget.plan;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      backgroundColor: isDark ? ThemeColors.darkSurface : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      title: Text(
        plan == null ? 'Criar Novo Plano' : 'Editar Plano',
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppInput(
                label: 'Nome do Plano',
                placeholder: 'Ex: Plano Imperial',
                controller: _nameController,
                validator: (val) =>
                    val == null || val.isEmpty ? 'Nome obrigatório' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: AppInput(
                      label: 'Valor Recorrente (R\$)',
                      placeholder: 'Ex: 139.90',
                      controller: _priceController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (val) => val == null || val.isEmpty
                          ? 'Valor obrigatório'
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cobrança',
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
                          initialValue: _period,
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
                              value: 'mensal',
                              child: Text('Mensal'),
                            ),
                            DropdownMenuItem(
                              value: 'trimestral',
                              child: Text('Trimestral'),
                            ),
                            DropdownMenuItem(
                              value: 'semestral',
                              child: Text('Semestral'),
                            ),
                            DropdownMenuItem(
                              value: 'anual',
                              child: Text('Anual'),
                            ),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => _period = val);
                          },
                        ),
                      ],
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
                      controller: _cutsController,
                      keyboardType: TextInputType.number,
                      validator: (val) => val == null || val.isEmpty
                          ? 'Qtd de cortes obrigatória'
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppInput(
                      label: 'Desconto em Produtos (%)',
                      placeholder: 'Ex: 10',
                      controller: _discountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (val) => val == null || val.isEmpty
                          ? 'Desconto obrigatório'
                          : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: Text(
                  'Destacar Plano (Recomendado)',
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black87,
                    fontSize: 14,
                  ),
                ),
                value: _recommended,
                activeThumbColor: ThemeColors.primary,
                onChanged: (val) => setState(() => _recommended = val),
              ),
              SwitchListTile(
                title: Text(
                  'Plano Ativo',
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black87,
                    fontSize: 14,
                  ),
                ),
                value: _status,
                activeThumbColor: ThemeColors.primary,
                onChanged: (val) => setState(() => _status = val),
              ),
              const SizedBox(height: 16),
              Text(
                'Benefícios Adicionais',
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black87,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: AppInput(
                      label: 'Novo Benefício',
                      placeholder: 'Ex: Cerveja grátis por visita',
                      controller: _benefitInputController,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(
                      Icons.add_circle,
                      color: ThemeColors.primary,
                      size: 36,
                    ),
                    onPressed: () {
                      final text = _benefitInputController.text.trim();
                      if (text.isNotEmpty) {
                        setState(() {
                          _benefits.add(text);
                          _benefitInputController.clear();
                        });
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_benefits.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Nenhum benefício adicionado.',
                    style: TextStyle(
                      color: isDark ? Colors.white30 : Colors.grey,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                )
              else
                ..._benefits.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final b = entry.value;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.check,
                      color: ThemeColors.primary,
                      size: 16,
                    ),
                    title: Text(
                      b,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 13,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.remove_circle_outline,
                        color: ThemeColors.danger,
                        size: 18,
                      ),
                      onPressed: () => setState(() => _benefits.removeAt(idx)),
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancelar',
            style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: ThemeColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              final newPlan = Plano(
                id: plan?.id ?? '',
                name: _nameController.text.trim(),
                price: double.tryParse(_priceController.text.trim()) ?? 0.0,
                period: _period,
                benefits: _benefits,
                cutsCount: int.tryParse(_cutsController.text.trim()) ?? 4,
                productDiscount:
                    (double.tryParse(_discountController.text.trim()) ?? 10.0) /
                    100.0,
                status: _status,
                recommended: _recommended,
              );

              if (plan == null) {
                ref.read(planosControllerProvider.notifier).addPlano(newPlan);
              } else {
                ref.read(planosControllerProvider.notifier).editPlano(newPlan);
              }
              Navigator.of(context).pop();
            }
          },
          child: const Text(
            'Salvar',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
