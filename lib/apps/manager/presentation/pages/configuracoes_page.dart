import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:barber_osbao/packages/design_system/theme/theme_colors.dart';
import 'package:barber_osbao/packages/design_system/layouts/app_page.dart';
import 'package:barber_osbao/packages/design_system/layouts/app_section.dart';
import 'package:barber_osbao/packages/design_system/molecules/app_card.dart';
import 'package:barber_osbao/packages/design_system/molecules/app_input.dart';

class ConfiguracoesPage extends StatefulWidget {
  const ConfiguracoesPage({super.key});

  @override
  State<ConfiguracoesPage> createState() => _ConfiguracoesPageState();
}

class _ConfiguracoesPageState extends State<ConfiguracoesPage> {
  final _nameController = TextEditingController(text: 'Barbearia Osbão Matriz');
  final _phoneController = TextEditingController(text: '(11) 99999-9999');
  final _addressController = TextEditingController(text: 'Av. Paulista, 1000 - São Paulo, SP');

  bool _pixEnabled = true;
  bool _creditEnabled = true;
  bool _cashEnabled = true;
  bool _whatsappEnabled = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Configurações',
      userName: 'Fábio Zvir',
      userAvatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&width=150',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Empresa details
          AppSection(
            title: 'Dados da Empresa',
            subtitle: 'Configure os dados principais da sua barbearia',
            child: AppCard(
              child: Column(
                children: [
                  AppInput(label: 'Nome da Barbearia', controller: _nameController),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: AppInput(label: 'Telefone para Contato', controller: _phoneController)),
                      const SizedBox(width: 16),
                      const Expanded(child: AppInput(label: 'CNPJ', placeholder: '00.000.000/0001-00')),
                    ],
                  ),
                  const SizedBox(height: 16),
                  AppInput(label: 'Endereço Comercial', controller: _addressController),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // 2. Business hours & Payments
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
                      subtitle: 'Defina os horários de atendimento',
                      child: AppCard(
                        child: Column(
                          children: [
                            _buildHourRow('Segunda a Sexta', '09:00 - 20:00'),
                            const Divider(height: 24),
                            _buildHourRow('Sábado', '09:00 - 18:00'),
                            const Divider(height: 24),
                            _buildHourRow('Domingo', 'Fechado', isOpen: false),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (isDesktop) ...[
                    const SizedBox(width: 24),
                    // Payments
                    Expanded(
                      child: AppSection(
                        title: 'Formas de Pagamento',
                        subtitle: 'Habilite os métodos no caixa',
                        child: AppCard(
                          child: Column(
                            children: [
                              SwitchListTile(
                                title: const Text('PIX (Liquidação Imediata)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                value: _pixEnabled,
                                activeColor: ThemeColors.primary,
                                onChanged: (val) => setState(() => _pixEnabled = val),
                              ),
                              SwitchListTile(
                                title: const Text('Cartão de Crédito / Débito', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                value: _creditEnabled,
                                activeColor: ThemeColors.primary,
                                onChanged: (val) => setState(() => _creditEnabled = val),
                              ),
                              SwitchListTile(
                                title: const Text('Dinheiro em Espécie', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                value: _cashEnabled,
                                activeColor: ThemeColors.primary,
                                onChanged: (val) => setState(() => _cashEnabled = val),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
          const SizedBox(height: 32),

          // 3. Integrations
          AppSection(
            title: 'Integrações',
            subtitle: 'Conecte serviços externos para potencializar o negócio',
            child: AppCard(
              child: SwitchListTile(
                title: const Text('WhatsApp Notificações Automáticas', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Envia lembretes automáticos de agendamentos e aniversários via WhatsApp para os clientes.'),
                value: _whatsappEnabled,
                activeColor: ThemeColors.primary,
                onChanged: (val) => setState(() => _whatsappEnabled = val),
              ),
            ),
          ),
        ],
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
