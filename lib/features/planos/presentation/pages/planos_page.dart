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
import 'package:barber_osbao/packages/design_system/organisms/app_dialog.dart';
import 'package:barber_osbao/packages/core/shared/state/app_state.dart';
import 'package:barber_osbao/packages/core/utils/app_formatters.dart';
import 'package:barber_osbao/packages/core/utils/app_masks.dart';
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
                    AppFormatters.formatCurrency(plan.price),
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
                AppFormatters.formatCurrency(plan.price),
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
    AppConfirmDialog.show(
      context: context,
      title: 'Excluir Plano',
      message: 'Tem certeza que deseja excluir o plano "${plan.name}"? Isso cancelará as cobranças futuras.',
      confirmLabel: 'Excluir',
      confirmColor: ThemeColors.danger,
      confirmTextColor: Colors.white,
      icon: Icons.delete_outline,
      iconColor: ThemeColors.danger,
      details: [
        MapEntry('Plano', plan.name),
        MapEntry('Valor', '${AppFormatters.formatCurrency(plan.price)}/${plan.period}'),
        MapEntry('Cortes/mês', plan.cutsCount >= 9999 ? 'Ilimitados' : '${plan.cutsCount} cortes'),
        MapEntry('Desconto em produtos', '${(plan.productDiscount * 100).toStringAsFixed(0)}%'),
      ],
      onConfirm: () {
        ref.read(planosControllerProvider.notifier).removePlano(plan.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Plano "${plan.name}" excluído.'),
            backgroundColor: ThemeColors.danger,
          ),
        );
      },
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

  late bool _isUnlimitedCuts;
  late String _period;
  late bool _recommended;
  late bool _status;
  late List<String> _benefits;

  @override
  void initState() {
    super.initState();
    final p = widget.plan;
    _nameController = TextEditingController(text: p?.name ?? '');
    _priceController = TextEditingController(
      text: p != null ? AppMasks.formatCurrencyValue(p.price) : '',
    );
    _isUnlimitedCuts = p != null && p.cutsCount >= 9999;
    _cutsController = TextEditingController(
      text: p != null ? (_isUnlimitedCuts ? '' : p.cutsCount.toString()) : '',
    );
    _discountController = TextEditingController(
      text: p != null ? (p.productDiscount * 100).toStringAsFixed(0) : '',
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

    return AppResponsiveDialog(
      title: plan == null ? 'Criar Novo Plano' : 'Editar Plano',
      subtitle: plan == null
          ? 'Cadastre um plano de assinatura para clientes da barbearia'
          : 'Atualize os valores, periodicidade e benefícios do plano',
      maxWidth: 640,
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
            if (_formKey.currentState?.validate() ?? false) {
              final priceParsed = AppMasks.parseCurrency(_priceController.text);
              final cutsParsed = _isUnlimitedCuts
                  ? 9999
                  : (int.tryParse(_cutsController.text.trim()) ?? 1);
              final discountNum = double.tryParse(
                    _discountController.text.trim().replaceAll(',', '.'),
                  ) ??
                  0.0;

              final newPlan = Plano(
                id: plan?.id ?? '',
                name: _nameController.text.trim(),
                price: priceParsed,
                period: _period,
                benefits: _benefits,
                cutsCount: cutsParsed,
                productDiscount: discountNum / 100.0,
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
            'Salvar Plano',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
      ],
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppInput(
              label: 'Nome do Plano',
              placeholder: 'Ex: Plano Imperial',
              controller: _nameController,
              validator: (val) =>
                  val == null || val.isEmpty ? 'Nome obrigatório' : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: AppInput(
                    label: 'Valor Recorrente (R\$)',
                    placeholder: '0,00',
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [AppMasks.currency],
                    validator: AppValidators.currency(required: true, min: 0.01),
                  ),
                ),
                const SizedBox(width: 16),
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
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppInput(
                        label: 'Qtd de Cortes por Mês',
                        placeholder: _isUnlimitedCuts ? 'Ilimitado' : 'Ex: 4',
                        controller: _cutsController,
                        readOnly: _isUnlimitedCuts,
                        keyboardType: TextInputType.number,
                        inputFormatters: [AppMasks.digitsOnly],
                        validator: _isUnlimitedCuts
                            ? null
                            : AppValidators.integer(required: true, min: 1),
                      ),
                      const SizedBox(height: 4),
                      InkWell(
                        onTap: () {
                          setState(() {
                            _isUnlimitedCuts = !_isUnlimitedCuts;
                            if (_isUnlimitedCuts) {
                              _cutsController.clear();
                            }
                          });
                        },
                        borderRadius: BorderRadius.circular(4),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: Checkbox(
                                  value: _isUnlimitedCuts,
                                  activeColor: ThemeColors.primary,
                                  checkColor: Colors.black,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  onChanged: (val) {
                                    setState(() {
                                      _isUnlimitedCuts = val ?? false;
                                      if (_isUnlimitedCuts) {
                                        _cutsController.clear();
                                      }
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Cortes Ilimitados',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? Colors.white70
                                      : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: AppInput(
                    label: 'Desconto em Produtos (%)',
                    placeholder: 'Ex: 10',
                    controller: _discountController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [AppMasks.percentage],
                    validator: AppValidators.percentage(required: true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.03)
                    : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark ? ThemeColors.darkBorder : Colors.grey.shade200,
                ),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    title: Text(
                      'Destacar Plano (Recomendado)',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      'Exibe badge dourada de mais popular na vitrine',
                      style: TextStyle(
                        color: isDark ? Colors.white54 : Colors.black45,
                        fontSize: 12,
                      ),
                    ),
                    value: _recommended,
                    activeThumbColor: ThemeColors.primary,
                    onChanged: (val) => setState(() => _recommended = val),
                  ),
                  Divider(
                    height: 1,
                    color: isDark
                        ? ThemeColors.darkBorder
                        : Colors.grey.shade200,
                  ),
                  SwitchListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    title: Text(
                      'Plano Ativo',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      'Disponível para novas adesões de clientes',
                      style: TextStyle(
                        color: isDark ? Colors.white54 : Colors.black45,
                        fontSize: 12,
                      ),
                    ),
                    value: _status,
                    activeThumbColor: ThemeColors.primary,
                    onChanged: (val) => setState(() => _status = val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
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
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: AppInput(
                    label: 'Novo Benefício',
                    placeholder: 'Ex: Cerveja cortesia em todas as visitas',
                    controller: _benefitInputController,
                  ),
                ),
                const SizedBox(width: 10),
                Padding(
                  padding: const EdgeInsets.only(bottom: 2.0),
                  child: SizedBox(
                    height: 46,
                    child: AppButton(
                      label: 'Adicionar',
                      icon: const Icon(Icons.add, size: 16),
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
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_benefits.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Nenhum benefício adicional cadastrado.',
                  style: TextStyle(
                    color: isDark ? Colors.white30 : Colors.grey,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _benefits.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final b = entry.value;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? ThemeColors.darkSurface
                          : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isDark
                            ? ThemeColors.darkBorder
                            : Colors.grey.shade200,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          color: ThemeColors.primary,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            b,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(
                            Icons.close,
                            color: ThemeColors.danger,
                            size: 16,
                          ),
                          onPressed: () =>
                              setState(() => _benefits.removeAt(idx)),
                          tooltip: 'Remover benefício',
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}
