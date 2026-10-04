import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:barber_osbao/features/filiais/application/branches_controller.dart';
import 'package:barber_osbao/packages/core/models/branch.dart';
import 'package:barber_osbao/packages/core/utils/app_masks.dart';
import 'package:barber_osbao/packages/design_system/molecules/app_input.dart';
import 'package:barber_osbao/packages/design_system/theme/theme_colors.dart';

class FiliaisPage extends ConsumerStatefulWidget {
  const FiliaisPage({super.key});

  @override
  ConsumerState<FiliaisPage> createState() => _FiliaisPageState();
}

class _FiliaisPageState extends ConsumerState<FiliaisPage> {
  void _openCreateOrEditBranchModal([Branch? branch]) {
    final nameController = TextEditingController(text: branch?.name ?? '');
    final slugController = TextEditingController(text: branch?.slug ?? '');
    final addressController = TextEditingController(text: branch?.address ?? '');
    final neighborhoodController = TextEditingController(text: branch?.neighborhood ?? '');
    final cityController = TextEditingController(text: branch?.city ?? 'Mallet');
    final stateController = TextEditingController(text: branch?.state ?? 'PR');
    final phoneController = TextEditingController(text: branch?.phone ?? '');
    final formKey = GlobalKey<FormState>();
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) {

          return AlertDialog(
            backgroundColor: ThemeColors.darkSurface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: ThemeColors.darkBorder),
            ),
            title: Row(
              children: [
                const Icon(Icons.storefront, color: ThemeColors.primary, size: 24),
                const SizedBox(width: 10),
                Text(
                  branch == null ? 'Nova Filial / Barbearia' : 'Editar Filial',
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: SizedBox(
              width: 480,
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppInput(
                        label: 'Nome da Unidade',
                        placeholder: 'Ex: Barber Osbão - Unidade 01 Centro',
                        controller: nameController,
                        prefixIcon: const Icon(Icons.badge_outlined, color: Colors.white38, size: 18),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Nome é obrigatório' : null,
                      ),
                      const SizedBox(height: 14),
                      AppInput(
                        label: 'Identificador do Link (Slug)',
                        placeholder: 'Ex: unidade-01 (ou deixe em branco para gerar)',
                        controller: slugController,
                        prefixIcon: const Icon(Icons.link, color: Colors.white38, size: 18),
                      ),
                      const SizedBox(height: 14),
                      AppInput(
                        label: 'Endereço (Rua e Número)',
                        placeholder: 'Ex: Rua XV de Novembro, 120',
                        controller: addressController,
                        prefixIcon: const Icon(Icons.location_on_outlined, color: Colors.white38, size: 18),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Endereço é obrigatório' : null,
                      ),
                      const SizedBox(height: 14),
                      AppInput(
                        label: 'Bairro',
                        placeholder: 'Ex: Centro',
                        controller: neighborhoodController,
                        prefixIcon: const Icon(Icons.map_outlined, color: Colors.white38, size: 18),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: AppInput(
                              label: 'Cidade',
                              placeholder: 'Mallet',
                              controller: cityController,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 1,
                            child: AppInput(
                              label: 'UF',
                              placeholder: 'PR',
                              controller: stateController,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      AppInput(
                        label: 'Telefone / WhatsApp da Unidade',
                        placeholder: '(42) 99999-9999',
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [PhoneInputFormatter()],
                        prefixIcon: const Icon(Icons.phone_outlined, color: Colors.white38, size: 18),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogCtx).pop(),
                child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeColors.primary,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: isSaving
                    ? null
                    : () async {
                        if (!(formKey.currentState?.validate() ?? false)) return;
                        setDialogState(() => isSaving = true);

                        try {
                          if (branch == null) {
                            await ref.read(branchesProvider.notifier).createBranch(
                                  name: nameController.text.trim(),
                                  address: addressController.text.trim(),
                                  slug: slugController.text.trim().isNotEmpty ? slugController.text.trim() : null,
                                  neighborhood: neighborhoodController.text.trim().isNotEmpty
                                      ? neighborhoodController.text.trim()
                                      : null,
                                  city: cityController.text.trim(),
                                  state: stateController.text.trim(),
                                  phone: phoneController.text.trim().isNotEmpty ? phoneController.text.trim() : null,
                                );
                          } else {
                            await ref.read(branchesProvider.notifier).updateBranch(
                                  branch.id,
                                  {
                                    'name': nameController.text.trim(),
                                    'address': addressController.text.trim(),
                                    if (slugController.text.trim().isNotEmpty) 'slug': slugController.text.trim(),
                                    'neighborhood': neighborhoodController.text.trim(),
                                    'city': cityController.text.trim(),
                                    'state': stateController.text.trim(),
                                    'phone': phoneController.text.trim(),
                                  },
                                );
                          }
                          if (dialogCtx.mounted) {
                            Navigator.of(dialogCtx).pop();
                          }
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(branch == null ? 'Filial criada com sucesso!' : 'Filial atualizada!'),
                                backgroundColor: ThemeColors.success,
                              ),
                            );
                          }
                        } catch (e) {
                          setDialogState(() => isSaving = false);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Erro ao salvar filial: $e'),
                                backgroundColor: ThemeColors.danger,
                              ),
                            );
                          }
                        }
                      },
                child: Text(
                  branch == null ? 'Criar Filial' : 'Salvar Alterações',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _copyBranchLink(Branch branch) {
    final link = 'https://fabiozvirj.github.io/BarberOsbao/#/?unidade=${branch.slug}';
    Clipboard.setData(ClipboardData(text: link));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text('Link da ${branch.name} copiado com sucesso:\n$link')),
          ],
        ),
        backgroundColor: ThemeColors.success,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final branchesState = ref.watch(branchesProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Filiais & Lojas',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Gerencie cada barbearia, obtenha o link de agendamento e organize sua rede',
                      style: TextStyle(fontSize: 13, color: Colors.white54),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeColors.primary,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text(
                    'Nova Filial',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  onPressed: () => _openCreateOrEditBranchModal(),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Branches List
            branchesState.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(40.0),
                  child: CircularProgressIndicator(color: ThemeColors.primary),
                ),
              ),
              error: (e, _) => Center(
                child: Text('Erro ao carregar filiais: $e', style: const TextStyle(color: Colors.white70)),
              ),
              data: (branches) {
                if (branches.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(48.0),
                    decoration: BoxDecoration(
                      color: ThemeColors.darkSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: ThemeColors.darkBorder),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: ThemeColors.primary.withValues(alpha: 0.1),
                          ),
                          child: const Icon(Icons.storefront, size: 48, color: ThemeColors.primary),
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          'Nenhuma filial cadastrada ainda',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Cadastre a sua primeira barbearia para começar a receber agendamentos online!',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: Colors.white54),
                        ),
                        const SizedBox(height: 22),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ThemeColors.primary,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Cadastrar Primeira Filial', style: TextStyle(fontWeight: FontWeight.bold)),
                          onPressed: () => _openCreateOrEditBranchModal(),
                        ),
                      ],
                    ),
                  );
                }

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final isDesktop = constraints.maxWidth > 800;
                    return Wrap(
                      spacing: 20,
                      runSpacing: 20,
                      children: branches.map((branch) {
                        final cardWidth = isDesktop ? (constraints.maxWidth - 20) / 2 : constraints.maxWidth;
                        final publicLink = 'https://fabiozvirj.github.io/BarberOsbao/#/?unidade=${branch.slug}';

                        return Container(
                          width: cardWidth,
                          padding: const EdgeInsets.all(22.0),
                          decoration: BoxDecoration(
                            color: ThemeColors.darkSurface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: ThemeColors.darkBorder, width: 1.2),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: ThemeColors.primary.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: ThemeColors.primary.withValues(alpha: 0.3)),
                                    ),
                                    child: const Icon(Icons.storefront, color: ThemeColors.primary, size: 28),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                branch.name,
                                                style: const TextStyle(
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: branch.active
                                                    ? ThemeColors.success.withValues(alpha: 0.15)
                                                    : Colors.white12,
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                branch.active ? 'Ativa' : 'Inativa',
                                                style: TextStyle(
                                                  color: branch.active ? ThemeColors.success : Colors.white38,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          branch.fullAddress,
                                          style: const TextStyle(fontSize: 13, color: Colors.white70),
                                        ),
                                        if (branch.phone != null) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            'WhatsApp: ${branch.phone}',
                                            style: const TextStyle(fontSize: 12, color: Colors.white54),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              const Divider(color: Colors.white10),
                              const SizedBox(height: 14),

                              // Public Link Box
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.white12),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.link, color: ThemeColors.primary, size: 18),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        publicLink,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                          fontFamily: 'monospace',
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    TextButton.icon(
                                      style: TextButton.styleFrom(
                                        foregroundColor: ThemeColors.primary,
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      ),
                                      icon: const Icon(Icons.copy, size: 14),
                                      label: const Text('Copiar Link', style: TextStyle(fontSize: 12)),
                                      onPressed: () => _copyBranchLink(branch),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Actions
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: Colors.white24),
                                      foregroundColor: Colors.white70,
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    icon: const Icon(Icons.edit_outlined, size: 16),
                                    label: const Text('Editar', style: TextStyle(fontSize: 12)),
                                    onPressed: () => _openCreateOrEditBranchModal(branch),
                                  ),
                                  const SizedBox(width: 10),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: ThemeColors.danger, size: 20),
                                    tooltip: 'Desativar Filial',
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (c) => AlertDialog(
                                          backgroundColor: ThemeColors.darkSurface,
                                          title: const Text('Desativar Filial?', style: TextStyle(color: Colors.white)),
                                          content: Text('Deseja realmente desativar a filial "${branch.name}"?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.of(c).pop(false),
                                              child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
                                            ),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(backgroundColor: ThemeColors.danger),
                                              onPressed: () => Navigator.of(c).pop(true),
                                              child: const Text('Desativar'),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirm == true) {
                                        await ref.read(branchesProvider.notifier).deleteBranch(branch.id);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
