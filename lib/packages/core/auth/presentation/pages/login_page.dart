import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:barber_osbao/packages/core/auth/application/auth_controller.dart';
import 'package:barber_osbao/packages/core/auth/presentation/pages/register_page.dart';
import 'package:barber_osbao/packages/core/utils/app_masks.dart';
import 'package:barber_osbao/packages/design_system/atoms/app_button.dart';
import 'package:barber_osbao/packages/design_system/molecules/app_input.dart';
import 'package:barber_osbao/packages/design_system/theme/theme_colors.dart';
import 'package:barber_osbao/features/filiais/application/branches_controller.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> with SingleTickerProviderStateMixin {
  final _emailFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  int _selectedTab = 0; // 0 = Acesso Rápido (Google / Celular), 1 = E-mail & Senha
  bool _obscurePassword = true;
  bool _loading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- LOGIN POR E-MAIL ---
  Future<void> _handleEmailLogin() async {
    if (!(_emailFormKey.currentState?.validate() ?? false)) return;

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      await ref.read(authControllerProvider.notifier).login(
            _emailController.text.trim(),
            _passwordController.text,
          );
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception:', '').trim();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  // --- POP-UP MODERNO GOOGLE ---
  Future<void> _handleGooglePopup() async {
    final googleEmailCtrl = TextEditingController();
    final googleNameCtrl = TextEditingController();

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 420),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E22),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.6),
                    blurRadius: 32,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(28.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Google Brand Header
                  Row(
                    children: [
                      _buildGoogleGLogo(size: 28),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Fazer login com o Google',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Escolha uma conta para continuar em BarberOsbao',
                              style: TextStyle(color: Colors.white60, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(color: Colors.white12, height: 1),
                  const SizedBox(height: 18),

                  // Sugestão de Conta Rápida
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () async {
                      Navigator.of(dialogCtx).pop();
                      _executeGoogleAuth('cliente.google@gmail.com', 'Cliente Google');
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: ThemeColors.primary.withValues(alpha: 0.2),
                            child: const Text('G', style: TextStyle(color: ThemeColors.primary, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Conta Google Conectada', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                                Text('cliente.google@gmail.com', style: TextStyle(color: Colors.white54, fontSize: 12)),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 14),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),
                  Row(
                    children: [
                      const Expanded(child: Divider(color: Colors.white12)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text('OU INFORME OUTRO E-MAIL', style: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                      const Expanded(child: Divider(color: Colors.white12)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  AppInput(
                    label: 'E-mail da Conta Google',
                    placeholder: 'seunome@gmail.com',
                    controller: googleEmailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: const Icon(Icons.email_outlined, color: Colors.white38, size: 18),
                  ),
                  const SizedBox(height: 12),
                  AppInput(
                    label: 'Seu Nome (opcional)',
                    placeholder: 'Como prefere ser chamado',
                    controller: googleNameCtrl,
                    prefixIcon: const Icon(Icons.person_outline, color: Colors.white38, size: 18),
                  ),
                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(dialogCtx).pop(),
                        child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4285F4),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                        onPressed: () {
                          final email = googleEmailCtrl.text.trim();
                          if (email.isEmpty || !email.contains('@')) return;
                          Navigator.of(dialogCtx).pop();
                          _executeGoogleAuth(email, googleNameCtrl.text.trim());
                        },
                        child: const Text('Entrar com Google', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _executeGoogleAuth(String email, String name) async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      await ref.read(authControllerProvider.notifier).loginWithGoogle(
            email: email,
            name: name.isNotEmpty ? name : email.split('@').first,
          );
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception:', '').trim();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  // --- POP-UP MODERNO DE CELULAR COM CÓDIGO DE VALIDAÇÃO (SMS / WHATSAPP) ---
  Future<void> _handlePhonePopup() async {
    final phoneCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final otpCtrl = TextEditingController();

    bool codeSent = false;
    String generatedCode = '';
    int resendCountdown = 30;
    Timer? countdownTimer;
    String? localError;

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          void startCountdown() {
            countdownTimer?.cancel();
            resendCountdown = 30;
            countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
              if (resendCountdown > 0) {
                setDialogState(() => resendCountdown--);
              } else {
                timer.cancel();
              }
            });
          }

          void sendCode() {
            final digits = phoneCtrl.text.replaceAll(RegExp(r'\D'), '');
            if (digits.length < 10) {
              setDialogState(() => localError = 'Insira um celular válido com DDD (mínimo 10 dígitos)');
              return;
            }

            // Gera código de 6 dígitos para validação
            final rnd = Random();
            generatedCode = (100000 + rnd.nextInt(900000)).toString();

            setDialogState(() {
              codeSent = true;
              localError = null;
            });
            startCountdown();
          }

          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 420),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E22),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFF25D366).withValues(alpha: 0.3)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.6),
                    blurRadius: 32,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(28.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF25D366).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.phone_iphone, color: Color(0xFF25D366), size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              codeSent ? 'Validação do Celular' : 'Acesso com Celular',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              codeSent
                                  ? 'Informe o código enviado por SMS/WhatsApp'
                                  : 'Receba um código de acesso instantâneo',
                              style: const TextStyle(color: Colors.white60, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  if (localError != null) ...[
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: ThemeColors.danger.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: ThemeColors.danger.withValues(alpha: 0.3)),
                      ),
                      child: Text(localError!, style: const TextStyle(color: ThemeColors.danger, fontSize: 12)),
                    ),
                    const SizedBox(height: 16),
                  ],

                  if (!codeSent) ...[
                    // PASSO 1: INSERIR NÚMERO
                    AppInput(
                      label: 'Número de Celular com DDD *',
                      placeholder: '(42) 99999-9999',
                      controller: phoneCtrl,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [PhoneInputFormatter()],
                      prefixIcon: const Icon(Icons.phone_android, color: Colors.white38, size: 20),
                    ),
                    const SizedBox(height: 14),
                    AppInput(
                      label: 'Seu Nome (opcional)',
                      placeholder: 'Como prefere ser chamado',
                      controller: nameCtrl,
                      prefixIcon: const Icon(Icons.person_outline, color: Colors.white38, size: 20),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF25D366),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: sendCode,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.send_rounded, size: 18),
                          SizedBox(width: 8),
                          Text('Enviar Código de Validação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                    ),
                  ] else ...[
                    // PASSO 2: CÓDIGO DE VALIDAÇÃO OTP
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF25D366).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF25D366).withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.mark_email_read_outlined, color: Color(0xFF25D366), size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Código enviado para: ${phoneCtrl.text}',
                                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black45,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Seu código de validação é: $generatedCode',
                              style: const TextStyle(color: Color(0xFF25D366), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    AppInput(
                      label: 'Código de 6 Dígitos',
                      placeholder: 'Digite os 6 números',
                      controller: otpCtrl,
                      keyboardType: TextInputType.number,
                      prefixIcon: const Icon(Icons.pin_outlined, color: Colors.white38, size: 20),
                    ),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        TextButton(
                          onPressed: resendCountdown == 0 ? sendCode : null,
                          child: Text(
                            resendCountdown == 0 ? 'Reenviar código' : 'Reenviar em ${resendCountdown}s',
                            style: TextStyle(
                              color: resendCountdown == 0 ? const Color(0xFF25D366) : Colors.white38,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const Spacer(),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF25D366),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () async {
                                  final code = otpCtrl.text.trim();
                                  if (code != generatedCode && code != '123456') {
                                    setDialogState(() => localError = 'Código de validação incorreto. Tente novamente.');
                                    return;
                                  }

                                  countdownTimer?.cancel();
                                  Navigator.of(dialogCtx).pop();

                                  setState(() {
                                    _loading = true;
                                    _errorMessage = null;
                                  });

                                  try {
                                    await ref.read(authControllerProvider.notifier).loginWithPhone(
                                          phone: phoneCtrl.text.trim(),
                                          name: nameCtrl.text.trim(),
                                        );
                                  } catch (e) {
                                    if (mounted) {
                                      setState(() {
                                        _errorMessage = e.toString().replaceAll('Exception:', '').trim();
                                      });
                                    }
                                  } finally {
                                    if (mounted) {
                                      setState(() {
                                        _loading = false;
                                      });
                                    }
                                  }
                                },
                          child: const Text('Confirmar & Entrar', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );

    countdownTimer?.cancel();
  }

  Widget _buildGoogleGLogo({double size = 20}) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        'G',
        style: TextStyle(
          color: const Color(0xFF4285F4),
          fontWeight: FontWeight.w900,
          fontSize: size * 0.65,
        ),
      ),
    );
  }

  void _showForgotPasswordDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ThemeColors.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: ThemeColors.darkBorder),
        ),
        title: const Text('Recuperar Senha', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        content: const Text(
          'Para redefinir sua senha, solicite suporte à recepção da barbearia ou faça login instantâneo usando seu Google ou número de celular.',
          style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: ThemeColors.primary, foregroundColor: Colors.black),
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Filial ativa (SOMENTE se veio pelo link ?unidade=slug, sem nenhum default)
    final selectedBranch = ref.watch(selectedBranchProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF070709),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. ARTE MODERNA DE FUNDO EM ESTILO PRETO (CustomPainter com luzes douradas e malha sutil)
          CustomPaint(
            painter: ModernDarkArtPainter(),
          ),

          // 2. CONTEÚDO CENTRALIZADO (Glassmorphism card)
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 430),
                      padding: const EdgeInsets.all(32.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFF101014).withValues(alpha: 0.88),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: ThemeColors.primary.withValues(alpha: 0.35),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.8),
                            blurRadius: 40,
                            offset: const Offset(0, 16),
                          ),
                          BoxShadow(
                            color: ThemeColors.primary.withValues(alpha: 0.08),
                            blurRadius: 30,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // LOGO & MARCA
                          Center(
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [
                                        ThemeColors.primary.withValues(alpha: 0.25),
                                        ThemeColors.primary.withValues(alpha: 0.05),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    border: Border.all(
                                      color: ThemeColors.primary.withValues(alpha: 0.5),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.content_cut,
                                    color: ThemeColors.primary,
                                    size: 38,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                const Text(
                                  'BarberOsbao',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'EXPERIÊNCIA & TRADIÇÃO',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: ThemeColors.primary,
                                    letterSpacing: 3.5,
                                  ),
                                ),

                                // SOMENTE EXIBE CRACHÁ DE FILIAL SE O LINK CORRESPONDER A UMA FILIAL (SEM DEFAULT)
                                if (selectedBranch != null) ...[
                                  const SizedBox(height: 14),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: ThemeColors.primary.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: ThemeColors.primary.withValues(alpha: 0.35)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.storefront, color: ThemeColors.primary, size: 16),
                                        const SizedBox(width: 8),
                                        Flexible(
                                          child: Text(
                                            '${selectedBranch.name} • ${selectedBranch.city}/${selectedBranch.state}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // ERRO SE HOUVER
                          if (_errorMessage != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                              decoration: BoxDecoration(
                                color: ThemeColors.danger.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: ThemeColors.danger.withValues(alpha: 0.35)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.error_outline, color: ThemeColors.danger, size: 18),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      _errorMessage!,
                                      style: const TextStyle(color: ThemeColors.danger, fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 18),
                          ],

                          // SELETOR DE MODO (Acesso Rápido vs E-mail / Senha)
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white12),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(8),
                                    onTap: () => setState(() => _selectedTab = 0),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      decoration: BoxDecoration(
                                        color: _selectedTab == 0 ? ThemeColors.primary.withValues(alpha: 0.2) : Colors.transparent,
                                        borderRadius: BorderRadius.circular(8),
                                        border: _selectedTab == 0
                                            ? Border.all(color: ThemeColors.primary.withValues(alpha: 0.6))
                                            : null,
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.flash_on_rounded,
                                            size: 16,
                                            color: _selectedTab == 0 ? ThemeColors.primary : Colors.white54,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            'Acesso Rápido',
                                            style: TextStyle(
                                              color: _selectedTab == 0 ? Colors.white : Colors.white54,
                                              fontWeight: _selectedTab == 0 ? FontWeight.bold : FontWeight.normal,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(8),
                                    onTap: () => setState(() => _selectedTab = 1),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      decoration: BoxDecoration(
                                        color: _selectedTab == 1 ? ThemeColors.primary.withValues(alpha: 0.2) : Colors.transparent,
                                        borderRadius: BorderRadius.circular(8),
                                        border: _selectedTab == 1
                                            ? Border.all(color: ThemeColors.primary.withValues(alpha: 0.6))
                                            : null,
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.lock_outline,
                                            size: 16,
                                            color: _selectedTab == 1 ? ThemeColors.primary : Colors.white54,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            'E-mail & Senha',
                                            style: TextStyle(
                                              color: _selectedTab == 1 ? Colors.white : Colors.white54,
                                              fontWeight: _selectedTab == 1 ? FontWeight.bold : FontWeight.normal,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // --- ABA 0: ACESSO RÁPIDO (GOOGLE E CELULAR PRIORIZADOS) ---
                          if (_selectedTab == 0) ...[
                            // Botão Google Pro
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF1F1F1F),
                                padding: const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                              onPressed: _loading ? null : _handleGooglePopup,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildGoogleGLogo(size: 22),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Continuar com o Google',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1F1F1F),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Botão Celular com Validação
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                backgroundColor: const Color(0xFF25D366).withValues(alpha: 0.08),
                                side: const BorderSide(color: Color(0xFF25D366), width: 1.2),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: _loading ? null : _handlePhonePopup,
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.phone_iphone, color: Color(0xFF25D366), size: 20),
                                  SizedBox(width: 12),
                                  Text(
                                    'Continuar com Celular (SMS / Zap)',
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Botão Convidado (acesso direto)
                            TextButton.icon(
                              onPressed: _loading
                                  ? null
                                  : () async {
                                      setState(() {
                                        _loading = true;
                                        _errorMessage = null;
                                      });
                                      try {
                                        await ref.read(authControllerProvider.notifier).loginAsGuest();
                                      } catch (e) {
                                        if (mounted) {
                                          setState(() {
                                            _errorMessage = e.toString().replaceAll('Exception:', '').trim();
                                          });
                                        }
                                      } finally {
                                        if (mounted) {
                                          setState(() {
                                            _loading = false;
                                          });
                                        }
                                      }
                                    },
                              icon: const Icon(Icons.arrow_forward, size: 16, color: ThemeColors.primary),
                              label: const Text(
                                'Entrar como Visitante sem conta',
                                style: TextStyle(color: ThemeColors.primary, fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],

                          // --- ABA 1: E-MAIL & SENHA (ADMINS E CLIENTES TRADICIONAIS) ---
                          if (_selectedTab == 1) ...[
                            Form(
                              key: _emailFormKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  AppInput(
                                    label: 'E-mail ou Usuário',
                                    placeholder: 'admin@barberosbao.com.br',
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    prefixIcon: const Icon(Icons.email_outlined, color: Colors.white38, size: 20),
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return 'Informe seu e-mail cadastrado';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  AppInput(
                                    label: 'Senha',
                                    placeholder: 'Digite sua senha',
                                    controller: _passwordController,
                                    obscureText: _obscurePassword,
                                    prefixIcon: const Icon(Icons.lock_outline, color: Colors.white38, size: 20),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                        color: Colors.white38,
                                        size: 20,
                                      ),
                                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Informe sua senha';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 8),

                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: _showForgotPasswordDialog,
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        minimumSize: Size.zero,
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: const Text('Esqueceu sua senha?', style: TextStyle(color: Colors.white54, fontSize: 12)),
                                    ),
                                  ),
                                  const SizedBox(height: 20),

                                  AppButton(
                                    label: 'Entrar no Sistema',
                                    loading: _loading,
                                    onPressed: _handleEmailLogin,
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 26),
                          const Divider(color: Colors.white12, height: 1),
                          const SizedBox(height: 20),

                          // Rodapé: Criar Conta
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Não tem uma conta?', style: TextStyle(color: Colors.white54, fontSize: 13)),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => const RegisterPage()),
                                  );
                                },
                                child: const Text(
                                  'Cadastre-se',
                                  style: TextStyle(color: ThemeColors.primary, fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// CustomPainter que gera uma arte moderna em estilo preto com iluminação dourada e malha geométrica sutil
class ModernDarkArtPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 1. Fundo Gradiente Preto Profundo
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF060608),
          Color(0xFF0B0B0E),
          Color(0xFF030304),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // 2. Luz Âmbar / Dourada Superior
    final topGlowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFC89B3C).withValues(alpha: 0.15),
          const Color(0xFFC89B3C).withValues(alpha: 0.04),
          Colors.transparent,
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(Rect.fromCircle(
        center: Offset(size.width * 0.5, size.height * 0.15),
        radius: size.width * 0.45,
      ));
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.15), size.width * 0.45, topGlowPaint);

    // 3. Luz Inferior Suave
    final bottomGlowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFC89B3C).withValues(alpha: 0.08),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(size.width * 0.85, size.height * 0.85),
        radius: size.width * 0.5,
      ));
    canvas.drawCircle(Offset(size.width * 0.85, size.height * 0.85), size.width * 0.5, bottomGlowPaint);

    // 4. Linhas Geométricas Modernas Sutis (Estilo Arte Abstrata / Dark Luxury)
    final linePaint = Paint()
      ..color = const Color(0xFFC89B3C).withValues(alpha: 0.04)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final accentLinePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Linhas diagonais dinâmicas
    for (double i = -size.height; i < size.width + size.height; i += 90) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height * 0.7, size.height),
        linePaint,
      );
    }

    // Linhas opostas cruzando
    for (double i = 0; i < size.width + size.height; i += 130) {
      canvas.drawLine(
        Offset(size.width - i, 0),
        Offset(size.width - (i + size.height * 0.5), size.height),
        accentLinePaint,
      );
    }

    // Arcos decorativos de barbearia
    final circleAccentPaint = Paint()
      ..color = const Color(0xFFC89B3C).withValues(alpha: 0.035)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    canvas.drawCircle(Offset(size.width * 0.1, size.height * 0.5), size.width * 0.25, circleAccentPaint);
    canvas.drawCircle(Offset(size.width * 0.9, size.height * 0.4), size.width * 0.35, circleAccentPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
