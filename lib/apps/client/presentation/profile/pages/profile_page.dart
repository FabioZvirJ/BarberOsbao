import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:barber_osbao/packages/design_system/layouts/app_container.dart';
import 'package:barber_osbao/packages/design_system/molecules/app_card.dart';
import 'package:barber_osbao/packages/design_system/molecules/app_input.dart';
import 'package:barber_osbao/packages/design_system/atoms/app_button.dart';
import 'package:barber_osbao/packages/design_system/atoms/app_avatar.dart';
import 'package:barber_osbao/packages/design_system/theme/theme_colors.dart';
import 'package:barber_osbao/packages/core/auth/application/auth_controller.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _avatarUrlController;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authControllerProvider).value;
    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _avatarUrlController = TextEditingController(text: user?.avatarUrl ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _avatarUrlController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(authControllerProvider).value;
    if (user == null) return;

    final updated = user.copyWith(
      name: _nameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      avatarUrl: _avatarUrlController.text,
    );

    await ref.read(authControllerProvider.notifier).updateUser(updated);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil atualizado com sucesso!'),
          backgroundColor: ThemeColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(authControllerProvider);

    return Scaffold(
      body: AppContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Meu Perfil',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 4),
                Text(
                  'Mantenha suas informações de contato atualizadas.',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 32),

            userState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => const Center(child: Text('Erro ao carregar perfil.')),
              data: (user) {
                if (user == null) return const Center(child: Text('Nenhum usuário logado.'));

                return AppCard(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Avatar Row
                        Row(
                          children: [
                            AppAvatar(url: _avatarUrlController.text.isNotEmpty ? _avatarUrlController.text : user.avatarUrl, size: 70),
                            const SizedBox(width: 24),
                            Expanded(
                              child: AppInput(
                                label: 'Link da Foto de Perfil',
                                placeholder: 'Insira a URL de uma imagem',
                                controller: _avatarUrlController,
                                onChanged: (val) => setState(() {}),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Form Fields Grid
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final isWide = constraints.maxWidth > 600;
                            return Column(
                              children: [
                                if (isWide)
                                  Row(
                                    children: [
                                      Expanded(
                                        child: AppInput(
                                          label: 'Nome Completo',
                                          controller: _nameController,
                                          validator: (val) => val == null || val.isEmpty ? 'Campo obrigatório' : null,
                                        ),
                                      ),
                                      const SizedBox(width: 20),
                                      Expanded(
                                        child: AppInput(
                                          label: 'Celular / WhatsApp',
                                          controller: _phoneController,
                                          validator: (val) => val == null || val.isEmpty ? 'Campo obrigatório' : null,
                                        ),
                                      ),
                                    ],
                                  )
                                else ...[
                                  AppInput(
                                    label: 'Nome Completo',
                                    controller: _nameController,
                                    validator: (val) => val == null || val.isEmpty ? 'Campo obrigatório' : null,
                                  ),
                                  const SizedBox(height: 20),
                                  AppInput(
                                    label: 'Celular / WhatsApp',
                                    controller: _phoneController,
                                    validator: (val) => val == null || val.isEmpty ? 'Campo obrigatório' : null,
                                  ),
                                ],
                                const SizedBox(height: 20),
                                AppInput(
                                  label: 'E-mail',
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (val) => val == null || val.isEmpty ? 'Campo obrigatório' : null,
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 40),

                        // Save action
                        Align(
                          alignment: Alignment.centerRight,
                          child: AppButton(
                            label: 'Salvar Alterações',
                            onPressed: _saveProfile,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
