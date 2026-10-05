import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:barber_osbao/packages/design_system/theme/theme_colors.dart';
import 'package:barber_osbao/packages/design_system/layouts/app_section.dart';
import 'package:barber_osbao/packages/design_system/molecules/app_card.dart';
import 'package:barber_osbao/packages/core/network/dio_client.dart';

class ChatMessage {
  final bool isUser;
  final String text;
  final DateTime time;

  ChatMessage({required this.isUser, required this.text, DateTime? time})
      : time = time ?? DateTime.now();
}

class WhatsAppBotPage extends ConsumerStatefulWidget {
  const WhatsAppBotPage({super.key});

  @override
  ConsumerState<WhatsAppBotPage> createState() => _WhatsAppBotPageState();
}

class _WhatsAppBotPageState extends ConsumerState<WhatsAppBotPage> {
  final _phoneController = TextEditingController(text: '41999998877');
  final _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<ChatMessage> _messages = [
    ChatMessage(
      isUser: false,
      text: '💈 *BarberOsbao Bot Inicializado!*\nEnvie uma mensagem ou utilize os atalhos abaixo para testar o atendimento automático.',
    ),
  ];

  bool _sending = false;

  final String _webhookUrl = 'https://barberosbao-api.onrender.com/webhook/whatsapp';
  final String _verifyToken = 'barberosbao_verify_token';

  @override
  void dispose() {
    _phoneController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage(String text) async {
    final cleanText = text.trim();
    if (cleanText.isEmpty || _sending) return;

    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe um número de telefone para o teste')),
      );
      return;
    }

    setState(() {
      _messages.add(ChatMessage(isUser: true, text: cleanText));
      _sending = true;
      _messageController.clear();
    });
    _scrollToBottom();

    try {
      final dio = ref.read(dioClientProvider).dio;
      final response = await dio.post(
        '/webhook/whatsapp/simulate',
        data: {
          'phone': phone,
          'text': cleanText,
        },
      );

      final reply = response.data['reply']?.toString() ?? 'Sem resposta do bot.';

      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(isUser: false, text: reply));
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(
            isUser: false,
            text: '❌ Erro ao comunicar com o servidor do bot: $e',
          ));
        });
        _scrollToBottom();
      }
    } finally {
      if (mounted) {
        setState(() {
          _sending = false;
        });
      }
    }
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copiado para a área de transferência!'),
        backgroundColor: Colors.green.shade800,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bot do WhatsApp & Atendimento',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Configuração do Webhook oficial e simulador de agendamento em tempo real',
                    style: TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF25D366).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF25D366)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, color: Color(0xFF25D366), size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Motor Ativo & Online',
                      style: TextStyle(
                        color: Color(0xFF25D366),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Responsive Columns
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 900;

              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 5, child: _buildConfigColumn()),
                    const SizedBox(width: 24),
                    Expanded(flex: 6, child: _buildSimulatorColumn()),
                  ],
                );
              }

              return Column(
                children: [
                  _buildConfigColumn(),
                  const SizedBox(height: 24),
                  _buildSimulatorColumn(),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildConfigColumn() {
    return Column(
      children: [
        AppSection(
          title: 'Credenciais de Integração Webhook',
          child: AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'URL do Webhook (Callback URL)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white70),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: SelectableText(
                          _webhookUrl,
                          style: const TextStyle(fontFamily: 'monospace', fontSize: 12, color: Colors.white),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy, size: 18, color: ThemeColors.primary),
                        onPressed: () => _copyToClipboard(_webhookUrl, 'Webhook URL'),
                        tooltip: 'Copiar URL',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Token de Verificação (Verify Token)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white70),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: SelectableText(
                          _verifyToken,
                          style: const TextStyle(fontFamily: 'monospace', fontSize: 13, color: Colors.white),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy, size: 18, color: ThemeColors.primary),
                        onPressed: () => _copyToClipboard(_verifyToken, 'Verify Token'),
                        tooltip: 'Copiar Token',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        AppSection(
          title: 'Como Conectar ao WhatsApp Gratuito da Meta',
          child: AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStepItem(
                  number: '1',
                  title: 'Acesse o Meta for Developers',
                  description: 'Vá em developers.facebook.com, crie um App do tipo "Business" e adicione o produto "WhatsApp".',
                ),
                const Divider(color: Colors.white10, height: 24),
                _buildStepItem(
                  number: '2',
                  title: 'Configure o Webhook Oficial',
                  description: 'Cole a URL do Webhook e o Token de Verificação listados acima. Assine os eventos de "messages".',
                ),
                const Divider(color: Colors.white10, height: 24),
                _buildStepItem(
                  number: '3',
                  title: '1.000 Conversas Gratuitas por Mês',
                  description: 'A Meta fornece 1.000 conversas por mês sem custo algum, com estabilidade oficial e sem risco de banimento de chip.',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStepItem({required String number, required String title, required String description}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: ThemeColors.primary.withValues(alpha: 0.2),
          child: Text(number, style: const TextStyle(color: ThemeColors.primary, fontSize: 12, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
              const SizedBox(height: 4),
              Text(description, style: const TextStyle(fontSize: 12, color: Colors.white60)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSimulatorColumn() {
    return AppSection(
      title: 'Simulador do Bot (Teste ao Vivo)',
      child: Container(
        height: 600,
        decoration: BoxDecoration(
          color: const Color(0xFF0F141A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          children: [
            // Top Bar do Simulador
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1F2C34),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 18,
                    backgroundColor: Color(0xFF25D366),
                    child: Icon(Icons.chat, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('BarberOsbao Bot', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)),
                        Text('Atendente Virtual • Online', style: TextStyle(color: Color(0xFF25D366), fontSize: 11)),
                      ],
                    ),
                  ),
                  // Input de telefone de teste
                  SizedBox(
                    width: 150,
                    child: TextField(
                      controller: _phoneController,
                      style: const TextStyle(fontSize: 12, color: Colors.white),
                      decoration: InputDecoration(
                        isDense: true,
                        labelText: 'Nº Teste',
                        labelStyle: const TextStyle(color: Colors.white54, fontSize: 11),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Área de Mensagens
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  return _buildChatBubble(msg);
                },
              ),
            ),

            // Botões de Acesso Rápido
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                children: [
                  _buildQuickAction('Oi / Iniciar', 'Olá'),
                  _buildQuickAction('1 - Agendar', '1'),
                  _buildQuickAction('2 - Agendamentos', '2'),
                  _buildQuickAction('3 - Cancelar', '3'),
                  _buildQuickAction('4 - Serviços', '4'),
                  _buildQuickAction('5 - Info', '5'),
                ],
              ),
            ),

            // Input inferior
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1F2C34),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(15)),
                border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Digite como se fosse o cliente no WhatsApp...',
                        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontSize: 13),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        filled: true,
                        fillColor: const Color(0xFF2A3942),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: _sendMessage,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFF00A884),
                      foregroundColor: Colors.white,
                    ),
                    icon: _sending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.send, size: 20),
                    onPressed: _sending ? null : () => _sendMessage(_messageController.text),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Text(label, style: const TextStyle(fontSize: 11, color: Colors.white70)),
        backgroundColor: const Color(0xFF2A3942),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        side: BorderSide.none,
        onPressed: _sending ? null : () => _sendMessage(value),
      ),
    );
  }

  Widget _buildChatBubble(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: const BoxConstraints(maxWidth: 420),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: message.isUser ? const Color(0xFF005C4B) : const Color(0xFF202C33),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: Radius.circular(message.isUser ? 12 : 2),
            bottomRight: Radius.circular(message.isUser ? 2 : 12),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: SelectableText(
          message.text,
          style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
        ),
      ),
    );
  }
}
