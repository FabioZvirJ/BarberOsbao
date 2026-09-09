import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:barber_osbao/packages/design_system/layouts/app_container.dart';
import 'package:barber_osbao/packages/design_system/molecules/app_card.dart';
import 'package:barber_osbao/packages/design_system/molecules/app_select.dart';
import 'package:barber_osbao/packages/design_system/theme/theme_colors.dart';
import 'package:barber_osbao/packages/core/auth/application/auth_controller.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                  'Configurações',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 4),
                Text(
                  'Personalize o comportamento e a aparência do seu aplicativo.',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 32),

            userState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => const Center(child: Text('Erro ao carregar configurações.')),
              data: (user) {
                if (user == null) return const Center(child: Text('Nenhum usuário logado.'));

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Theme & Preferences
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Visual & Preferências',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Tema do Sistema', style: TextStyle(fontWeight: FontWeight.bold)),
                                  Text('Alternar entre modo claro e escuro', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                ],
                              ),
                              Switch(
                                value: user.theme == 'dark',
                                activeThumbColor: ThemeColors.primary,
                                onChanged: (val) {
                                  final updated = user.copyWith(theme: val ? 'dark' : 'light');
                                  ref.read(authControllerProvider.notifier).updateUser(updated);
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          AppSelect<String>(
                            label: 'Idioma padrão',
                            value: user.language,
                            options: [
                              AppSelectOption(value: 'pt-BR', label: 'Português (Brasil)'),
                              AppSelectOption(value: 'en', label: 'English'),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                final updated = user.copyWith(language: val);
                                ref.read(authControllerProvider.notifier).updateUser(updated);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Notification Settings
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Canais de Notificação',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 20),
                          _buildSwitchRow(
                            title: 'E-mails de Lembrete',
                            desc: 'Receba confirmações e lembretes de visitas em seu e-mail',
                            value: user.emailNotifications,
                            onChanged: (val) {
                              final updated = user.copyWith(emailNotifications: val);
                              ref.read(authControllerProvider.notifier).updateUser(updated);
                            },
                          ),
                          const Divider(height: 32),
                          _buildSwitchRow(
                            title: 'Alertas no Whatsapp',
                            desc: 'Receba confirmações diretas em seu telefone',
                            value: user.whatsappNotifications,
                            onChanged: (val) {
                              final updated = user.copyWith(whatsappNotifications: val);
                              ref.read(authControllerProvider.notifier).updateUser(updated);
                            },
                          ),
                          const Divider(height: 32),
                          _buildSwitchRow(
                            title: 'Notificações Push',
                            desc: 'Lembretes de horário no próprio aparelho',
                            value: user.pushNotifications,
                            onChanged: (val) {
                              final updated = user.copyWith(pushNotifications: val);
                              ref.read(authControllerProvider.notifier).updateUser(updated);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Help card
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Ajuda & Suporte', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          const Text(
                            'Precisa de ajuda com o aplicativo ou quer falar sobre algum agendamento?',
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () {},
                            child: const Text('Falar com o Suporte (suporte@barberosbao.com.br)', style: TextStyle(color: ThemeColors.primary)),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchRow({
    required String title,
    required String desc,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(desc, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Switch(
          value: value,
          activeThumbColor: ThemeColors.primary,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
