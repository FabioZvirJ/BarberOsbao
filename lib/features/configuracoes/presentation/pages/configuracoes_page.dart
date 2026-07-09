import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:barber_osbao/packages/design_system/theme/theme_colors.dart';
import 'package:barber_osbao/packages/design_system/layouts/app_page.dart';
import 'package:barber_osbao/packages/design_system/layouts/app_section.dart';
import 'package:barber_osbao/packages/design_system/molecules/app_card.dart';
import 'package:barber_osbao/packages/design_system/molecules/app_input.dart';
import 'package:barber_osbao/packages/design_system/atoms/app_button.dart';
import 'package:barber_osbao/packages/core/auth/application/auth_controller.dart';
import 'package:barber_osbao/packages/core/shared/state/app_state.dart';
import 'package:barber_osbao/features/configuracoes/presentation/controllers/configuracoes_controller.dart';

class ConfiguracoesPage extends ConsumerStatefulWidget {
  const ConfiguracoesPage({super.key});

  @override
  ConsumerState<ConfiguracoesPage> createState() => _ConfiguracoesPageState();
}

class _ConfiguracoesPageState extends ConsumerState<ConfiguracoesPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _logoController;
  late TextEditingController _instaController;
  late TextEditingController _faceController;
  late TextEditingController _pixController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
    _logoController = TextEditingController();
    _instaController = TextEditingController();
    _faceController = TextEditingController();
    _pixController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _logoController.dispose();
    _instaController.dispose();
    _faceController.dispose();
    _pixController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final businessState = ref.watch(businessSettingsControllerProvider);
    final userState = ref.watch(authControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (businessState is AppLoading || userState.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: ThemeColors.primary)));
    }

    final settings = businessState.data!;
    final user = userState.value;

    // Load initial values only once or when settings change
    _nameController.text = settings.name;
    _phoneController.text = settings.phone;
    _addressController.text = settings.address;
    _logoController.text = settings.logoUrl;
    _instaController.text = settings.instagram;
    _faceController.text = settings.facebook;
    _pixController.text = settings.pixKey;

    return AppPage(
      title: 'Configurações',
      userName: user?.name ?? 'Fábio Zvir',
      userAvatarUrl: user?.avatarUrl ?? 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&width=150',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Company Data
            AppSection(
              title: 'Dados da Barbearia',
              subtitle: 'Nome da barbearia, canais sociais e configurações de PIX',
              child: AppCard(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: AppInput(label: 'Nome Comercial', controller: _nameController)),
                        const SizedBox(width: 16),
                        Expanded(child: AppInput(label: 'Link do Logotipo (URL)', controller: _logoController)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: AppInput(label: 'Telefone de Contato', controller: _phoneController)),
                        const SizedBox(width: 16),
                        Expanded(child: AppInput(label: 'Chave PIX Recebimento', controller: _pixController)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    AppInput(label: 'Endereço Completo', controller: _addressController),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: AppInput(label: 'Instagram', controller: _instaController, placeholder: '@usuario')),
                        const SizedBox(width: 16),
                        Expanded(child: AppInput(label: 'Facebook Page', controller: _faceController)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // 2. Schedule options & working hours
            LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth > 800;
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Working hours
                    Expanded(
                      child: AppSection(
                        title: 'Horário de Funcionamento',
                        subtitle: 'Defina os horários de atendimento da loja',
                        child: AppCard(
                          child: Column(
                            children: [
                              _buildHourRow('Segunda a Sexta', settings.workingHours['Segunda a Sexta'] ?? '09:00 - 20:00'),
                              const Divider(height: 24),
                              _buildHourRow('Sábado', settings.workingHours['Sábado'] ?? '09:00 - 18:00'),
                              const Divider(height: 24),
                              _buildHourRow('Domingo', settings.workingHours['Domingo'] ?? 'Fechado', isOpen: false),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    // Intervals and theme preference
                    Expanded(
                      child: AppSection(
                        title: 'Configurações de Agendamento',
                        subtitle: 'Defina intervalos e opções visuais',
                        child: AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DropdownButtonFormField<String>(
                                dropdownColor: ThemeColors.darkBg,
                                value: settings.slotInterval,
                                decoration: const InputDecoration(
                                  labelText: 'Tempo entre Atendimentos',
                                  labelStyle: TextStyle(color: Colors.white70, fontSize: 13),
                                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
                                ),
                                style: const TextStyle(color: Colors.white),
                                items: const [
                                  DropdownMenuItem(value: '15', child: Text('15 Minutos')),
                                  DropdownMenuItem(value: '30', child: Text('30 Minutos')),
                                  DropdownMenuItem(value: '45', child: Text('45 Minutos')),
                                  DropdownMenuItem(value: '60', child: Text('60 Minutos')),
                                ],
                                onChanged: (val) {
                                  if (val != null) {
                                    ref.read(businessSettingsControllerProvider.notifier).updateSettings(
                                          settings.copyWith(slotInterval: val),
                                        );
                                  }
                                },
                              ),
                              const SizedBox(height: 24),
                              SwitchListTile(
                                contentPadding: EdgeInsets.zero,
                                title: const Text('Tema Escuro (Dark Mode)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                subtitle: const Text('Alterna a identidade visual da dashboard admin'),
                                value: user?.theme == 'dark',
                                activeColor: ThemeColors.primary,
                                onChanged: (val) {
                                  if (user != null) {
                                    ref.read(authControllerProvider.notifier).updateUser(
                                          user.copyWith(theme: val ? 'dark' : 'light'),
                                        );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 32),

            // 3. Notification switches & WhatsApp Integration
            AppSection(
              title: 'Notificações & Integrações',
              subtitle: 'Habilite o envio de alertas automáticos para clientes',
              child: AppCard(
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('WhatsApp Notificações Automáticas', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text('Envia lembretes automáticos de agendamentos e aniversários via WhatsApp API.'),
                      value: user?.whatsappNotifications ?? false,
                      activeColor: ThemeColors.primary,
                      onChanged: (val) {
                        if (user != null) {
                          ref.read(authControllerProvider.notifier).updateUser(
                                user.copyWith(whatsappNotifications: val),
                              );
                        }
                      },
                    ),
                    const Divider(height: 24),
                    SwitchListTile(
                      title: const Text('Notificações de E-mail', style: TextStyle(fontWeight: FontWeight.bold)),
                      value: user?.emailNotifications ?? true,
                      activeColor: ThemeColors.primary,
                      onChanged: (val) {
                        if (user != null) {
                          ref.read(authControllerProvider.notifier).updateUser(
                                user.copyWith(emailNotifications: val),
                              );
                        }
                      },
                    ),
                    const Divider(height: 24),
                    SwitchListTile(
                      title: const Text('Notificações Push (Navegador)', style: TextStyle(fontWeight: FontWeight.bold)),
                      value: user?.pushNotifications ?? true,
                      activeColor: ThemeColors.primary,
                      onChanged: (val) {
                        if (user != null) {
                          ref.read(authControllerProvider.notifier).updateUser(
                                user.copyWith(pushNotifications: val),
                              );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Save changes button
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AppButton(
                  label: 'Salvar Configurações',
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      final updated = settings.copyWith(
                        name: _nameController.text.trim(),
                        logoUrl: _logoController.text.trim(),
                        phone: _phoneController.text.trim(),
                        address: _addressController.text.trim(),
                        instagram: _instaController.text.trim(),
                        facebook: _faceController.text.trim(),
                        pixKey: _pixController.text.trim(),
                      );
                      ref.read(businessSettingsControllerProvider.notifier).updateSettings(updated);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Configurações atualizadas com sucesso!'),
                          backgroundColor: ThemeColors.success,
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0, curve: Curves.easeOut),
    );
  }

  Widget _buildHourRow(String day, String hours, {bool isOpen = true}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(day, style: const TextStyle(fontWeight: FontWeight.bold)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isOpen ? ThemeColors.primary.withOpacity(0.1) : Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            hours,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isOpen ? ThemeColors.primary : Colors.red,
            ),
          ),
        ),
      ],
    );
  }
}
