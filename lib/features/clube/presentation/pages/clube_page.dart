import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:barber_osbao/packages/design_system/theme/theme_colors.dart';
import 'package:barber_osbao/packages/design_system/theme/app_breakpoints.dart';
import 'package:barber_osbao/packages/design_system/layouts/app_page.dart';
import 'package:barber_osbao/packages/design_system/organisms/app_table.dart';
import 'package:barber_osbao/packages/design_system/molecules/app_card.dart';
import 'package:barber_osbao/packages/design_system/atoms/app_button.dart';
import 'package:barber_osbao/packages/design_system/atoms/app_status_chip.dart';
import 'package:barber_osbao/packages/design_system/molecules/app_input.dart';
import 'package:barber_osbao/packages/design_system/molecules/app_image_upload.dart';
import 'package:barber_osbao/packages/design_system/organisms/app_dialog.dart';
import 'package:barber_osbao/packages/core/shared/state/app_state.dart';
import 'package:barber_osbao/packages/core/utils/app_masks.dart';
import 'package:barber_osbao/features/clube/domain/models/beneficio_clube.dart';
import 'package:barber_osbao/features/clube/presentation/controllers/clube_controller.dart';

class ClubePage extends ConsumerWidget {
  const ClubePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(clubeControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppPage(
      title: 'Clube do Assinante',
      userName: 'Fábio Zvir',
      userAvatarUrl:
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&width=150',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Statistics and Rules Row
          LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= AppBreakpoints.desktop;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'CLUBE FIDELIDADE',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            '148',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'Clientes participando ativamente do clube de pontos',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: const [
                              Icon(Icons.stars, color: ThemeColors.primary),
                              SizedBox(width: 8),
                              Text(
                                'Regra: R\$ 1,00 gasto = 1 ponto',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (isDesktop) ...[
                    const SizedBox(width: 24),
                    Expanded(
                      child: AppCard(
                        child: Builder(
                          builder: (context) {
                            final allRewards = state.data ?? [];
                            final activeRewards = allRewards
                                .where((b) => b.active)
                                .toList()
                              ..sort(
                                (a, b) => a.pointsRequired
                                    .compareTo(b.pointsRequired),
                              );

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'REGRAS DE RESGATE RÁPIDO',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      '${activeRewards.length} ativas',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: ThemeColors.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Baseado nas recompensas ativas cadastradas:',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                if (activeRewards.isEmpty)
                                  const Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 8.0),
                                    child: Text(
                                      'Nenhuma recompensa ativa no momento.',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  )
                                else
                                  ...activeRewards.take(4).map(
                                        (r) => _buildRuleRow(
                                          '${r.pointsRequired} pts: ${r.name}',
                                        ),
                                      ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
          const SizedBox(height: 32),

          // Coupons section header — responsive
          Wrap(
            spacing: 12,
            runSpacing: 10,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text(
                'Recompensas do Clube',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              AppButton(
                label: 'Nova Recompensa',
                icon: const Icon(Icons.add, size: 16),
                onPressed: () => _showFormDialog(context, ref),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildContent(context, state, isDark, ref),
        ],
      ),
    );
  }

  Widget _buildRuleRow(String rule) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        children: [
          const Icon(Icons.arrow_right, color: ThemeColors.primary),
          const SizedBox(width: 4),
          Expanded(child: Text(rule, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    AppState<List<BeneficioClube>> state,
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
          'Nenhuma recompensa cadastrada.',
          style: TextStyle(color: isDark ? Colors.white30 : Colors.grey),
        ),
      );
    }

    return AppTable(
      minWidth: 900,
      columns: [
        AppTableColumn(label: 'IMAGEM', width: 50),
        AppTableColumn(label: 'RECOMPENSA', flex: 3),
        AppTableColumn(label: 'BENEFÍCIO', flex: 3),
        AppTableColumn(label: 'PONTOS REQUERIDOS', width: 140),
        AppTableColumn(label: 'VALIDADE', width: 100),
        AppTableColumn(label: 'STATUS', width: 85),
        AppTableColumn(label: 'ORDENAR', width: 90),
        AppTableColumn(label: 'AÇÕES', width: 90),
      ],
      rows: data.map((b) {
        final idx = data.indexOf(b);
        return AppTableRow(
          cells: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                b.imageUrl,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.stars,
                  size: 24,
                  color: ThemeColors.primary,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  b.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (b.description.isNotEmpty)
                  Text(
                    b.description,
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
            Text(b.benefitValue),
            Text(
              '${b.pointsRequired} pts',
              style: const TextStyle(
                color: ThemeColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              b.expirationDate.contains('-')
                  ? b.expirationDate.split('-').reversed.join('/')
                  : b.expirationDate,
            ),
            AppStatusChip(
              label: b.active ? 'Ativo' : 'Inativo',
              type: b.active ? AppStatusType.success : AppStatusType.danger,
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_upward, size: 16),
                  onPressed: idx > 0
                      ? () {
                          final updated = List<BeneficioClube>.from(data);
                          final temp = updated[idx];
                          updated[idx] = updated[idx - 1];
                          updated[idx - 1] = temp;
                          ref
                              .read(clubeControllerProvider.notifier)
                              .updateOrder(updated);
                        }
                      : null,
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_downward, size: 16),
                  onPressed: idx < data.length - 1
                      ? () {
                          final updated = List<BeneficioClube>.from(data);
                          final temp = updated[idx];
                          updated[idx] = updated[idx + 1];
                          updated[idx + 1] = temp;
                          ref
                              .read(clubeControllerProvider.notifier)
                              .updateOrder(updated);
                        }
                      : null,
                ),
              ],
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  onPressed: () => _showFormDialog(context, ref, b),
                  tooltip: 'Editar',
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    size: 18,
                    color: ThemeColors.danger,
                  ),
                  onPressed: () => _showDeleteDialog(context, ref, b),
                  tooltip: 'Excluir',
                ),
              ],
            ),
          ],
        );
      }).toList(),
    );
  }

  void _showFormDialog(
    BuildContext context,
    WidgetRef ref, [
    BeneficioClube? benefit,
  ]) {
    showDialog(
      context: context,
      builder: (ctx) => _ClubeFormDialog(benefit: benefit),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    BeneficioClube benefit,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? ThemeColors.darkSurface : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: Text(
          'Excluir Recompensa',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Tem certeza que deseja excluir a recompensa "${benefit.name}"? Clientes não conseguirão mais resgatar seus pontos por ela.',
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
              ref
                  .read(clubeControllerProvider.notifier)
                  .removeBeneficio(benefit.id);
              Navigator.of(ctx).pop();
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _ClubeFormDialog extends ConsumerStatefulWidget {
  final BeneficioClube? benefit;

  const _ClubeFormDialog({this.benefit});

  @override
  ConsumerState<_ClubeFormDialog> createState() => _ClubeFormDialogState();
}

class _ClubeFormDialogState extends ConsumerState<_ClubeFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _pointsController;
  late final TextEditingController _benefitValueController;
  late final TextEditingController _expirationController;
  late final TextEditingController _imageUrlController;
  late bool _active;

  @override
  void initState() {
    super.initState();
    final b = widget.benefit;
    _nameController = TextEditingController(text: b?.name ?? '');
    _descriptionController = TextEditingController(text: b?.description ?? '');
    _pointsController = TextEditingController(
      text: b != null ? b.pointsRequired.toString() : '',
    );
    _benefitValueController = TextEditingController(
      text: b?.benefitValue ?? '',
    );

    String expInitial = '';
    if (b != null) {
      if (b.expirationDate.contains('-')) {
        expInitial = b.expirationDate.split('-').reversed.join('/');
      } else {
        expInitial = b.expirationDate;
      }
    }
    _expirationController = TextEditingController(text: expInitial);
    _imageUrlController = TextEditingController(text: b?.imageUrl ?? '');
    _active = b?.active ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _pointsController.dispose();
    _benefitValueController.dispose();
    _expirationController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickExpirationDate() async {
    final now = DateTime.now();
    DateTime initial = now.add(const Duration(days: 90));
    if (_expirationController.text.isNotEmpty) {
      final parts = _expirationController.text.split('/');
      if (parts.length == 3) {
        final d = int.tryParse(parts[0]);
        final m = int.tryParse(parts[1]);
        final y = int.tryParse(parts[2]);
        if (d != null && m != null && y != null) {
          initial = DateTime(y, m, d);
        }
      }
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      locale: const Locale('pt', 'BR'),
    );

    if (picked != null) {
      setState(() {
        _expirationController.text =
            '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final benefit = widget.benefit;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppResponsiveDialog(
      title: benefit == null ? 'Criar Recompensa' : 'Editar Recompensa',
      subtitle: benefit == null
          ? 'Cadastre um benefício ou prêmio para o Clube do Assinante'
          : 'Atualize os requisitos de pontos e detalhes da recompensa',
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
              final expText = _expirationController.text.trim();
              String expSaved = expText;
              if (expText.contains('/')) {
                final parts = expText.split('/');
                if (parts.length == 3) {
                  expSaved = '${parts[2]}-${parts[1]}-${parts[0]}';
                }
              }

              final newBenefit = BeneficioClube(
                id: benefit?.id ?? '',
                name: _nameController.text.trim(),
                description: _descriptionController.text.trim(),
                pointsRequired:
                    int.tryParse(_pointsController.text.trim()) ?? 100,
                benefitValue: _benefitValueController.text.trim(),
                imageUrl: _imageUrlController.text.isNotEmpty
                    ? _imageUrlController.text.trim()
                    : 'https://images.unsplash.com/photo-1571613316887-6f8d5cbf7ef7?q=80&width=150',
                expirationDate: expSaved,
                active: _active,
              );

              if (benefit == null) {
                ref
                    .read(clubeControllerProvider.notifier)
                    .addBeneficio(newBenefit);
              } else {
                ref
                    .read(clubeControllerProvider.notifier)
                    .editBeneficio(newBenefit);
              }
              Navigator.of(context).pop();
            }
          },
          child: const Text(
            'Salvar Recompensa',
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
              label: 'Nome da Recompensa',
              placeholder: 'Ex: Cerveja IPA Artesanal Gelada',
              controller: _nameController,
              validator: (val) =>
                  val == null || val.trim().isEmpty ? 'Nome obrigatório' : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: AppInput(
                    label: 'Pontos Necessários',
                    placeholder: 'Ex: 100',
                    controller: _pointsController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [AppMasks.digitsOnly],
                    validator: AppValidators.integer(required: true, min: 1),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: AppInput(
                    label: 'Validade do Benefício',
                    placeholder: 'DD/MM/AAAA',
                    controller: _expirationController,
                    readOnly: true,
                    onTap: _pickExpirationDate,
                    suffixIcon: const Icon(Icons.calendar_today, size: 18),
                    validator: AppValidators.date(required: true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AppInput(
              label: 'Valor/Benefício Concedido',
              placeholder: 'Ex: 1 Dose Grátis de IPA',
              controller: _benefitValueController,
              validator: (val) => val == null || val.isEmpty
                  ? 'Valor de benefício obrigatório'
                  : null,
            ),
            const SizedBox(height: 16),
            AppImageUpload(
              label: 'Imagem do Benefício',
              controller: _imageUrlController,
              height: 140,
              helperText: 'Upload do arquivo ou informe o link',
            ),
            const SizedBox(height: 16),
            AppInput(
              label: 'Descrição Detalhada',
              placeholder:
                  'Ex: Condições de resgate no salão e disponibilidade...',
              controller: _descriptionController,
              maxLines: 2,
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
              child: SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                title: Text(
                  'Recompensa Ativa',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  'Disponível para resgate imediato por membros do clube',
                  style: TextStyle(
                    color: isDark ? Colors.white54 : Colors.black45,
                    fontSize: 12,
                  ),
                ),
                value: _active,
                activeThumbColor: ThemeColors.primary,
                onChanged: (val) => setState(() => _active = val),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
