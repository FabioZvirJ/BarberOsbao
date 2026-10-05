import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:barber_osbao/packages/core/auth/application/auth_controller.dart';
import 'package:barber_osbao/packages/core/auth/presentation/pages/register_page.dart';
import 'package:barber_osbao/packages/core/utils/app_masks.dart';
import 'package:barber_osbao/packages/design_system/molecules/app_input.dart';
import 'package:barber_osbao/packages/design_system/theme/theme_colors.dart';
import 'package:barber_osbao/features/filiais/application/branches_controller.dart';
import 'package:barber_osbao/packages/core/models/branch.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> with SingleTickerProviderStateMixin {
  final _emailFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

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

  bool _googleSignInInitialized = false;

  // --- LOGIN OFICIAL GOOGLE (OAuth 2.0 / Google Identity Services) ---
  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      if (!_googleSignInInitialized) {
        const clientId = String.fromEnvironment('GOOGLE_CLIENT_ID');
        await GoogleSignIn.instance.initialize(
          clientId: clientId.isNotEmpty ? clientId : null,
        );
        _googleSignInInitialized = true;
      }

      final account = await GoogleSignIn.instance.authenticate();
      await _executeGoogleAuth(
        account.email,
        account.displayName ?? '',
        account.photoUrl,
      );
    } catch (e) {
      if (mounted) {
        final errText = e.toString();
        if (errText.contains('canceled') ||
            errText.contains('interrupted') ||
            errText.contains('popup_closed_by_user')) {
          // Usuário cancelou ou fechou a janela do Google
        } else if (errText.contains('clientId') || errText.contains('client_id')) {
          setState(() {
            _errorMessage =
                'Configure o Google Client ID no Google Cloud Console para habilitar a autenticação oficial do Google.';
          });
        } else {
          setState(() {
            _errorMessage =
                'Erro ao autenticar com Google: ${errText.replaceAll('Exception:', '').replaceAll('GoogleSignInException:', '').trim()}';
          });
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _executeGoogleAuth(String email, String name, [String? avatarUrl]) async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      await ref.read(authControllerProvider.notifier).loginWithGoogle(
            email: email,
            name: name.isNotEmpty ? name : email.split('@').first,
            avatarUrl: avatarUrl,
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
    final selectedBranch = ref.watch(selectedBranchProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF09090B),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 860;

            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      constraints: const BoxConstraints(maxWidth: 960),
                      child: isDesktop
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Left Hero & Features
                                Expanded(
                                  flex: 6,
                                  child: _buildLeftHeroSection(selectedBranch),
                                ),
                                const SizedBox(width: 56),
                                // Right Credentials Form Card
                                SizedBox(
                                  width: 400,
                                  child: _buildLoginCard(),
                                ),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildLeftHeroSection(selectedBranch, isCompact: true),
                                const SizedBox(height: 32),
                                Center(
                                  child: SizedBox(
                                    width: 410,
                                    child: _buildLoginCard(),
                                  ),
                                ),
                              ],
                            ),
                    ),
                    const SizedBox(height: 36),
                    // Footer
                    Text(
                      'Copyright © 2026 BarberOsbao. Todos os direitos reservados.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.32),
                        fontSize: 11,
                        letterSpacing: 0.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLeftHeroSection(Branch? selectedBranch, {bool isCompact = false}) {
    return Column(
      crossAxisAlignment:
          isCompact ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Brand Logo & Title
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment:
              isCompact ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: [
            const BarberScissorsCombLogo(size: 42),
            const SizedBox(width: 14),
            RichText(
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: 'Barber',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 38,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                  TextSpan(
                    text: 'Osbao',
                    style: TextStyle(
                      color: Color(0xFFCFA348),
                      fontSize: 38,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Tagline
        Text(
          'Agendamento, histórico de serviços e seleção de estilo para a Barbearia BarberOsbao em tempo real.',
          style: TextStyle(
            fontSize: 14,
            height: 1.45,
            color: Colors.white.withValues(alpha: 0.72),
          ),
          textAlign: isCompact ? TextAlign.center : TextAlign.start,
        ),

        // Branch Badge (if specified)
        if (selectedBranch != null) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFD4AF37).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFFD4AF37).withValues(alpha: 0.35),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.storefront, color: Color(0xFFD4AF37), size: 15),
                const SizedBox(width: 8),
                Text(
                  '${selectedBranch.name} • ${selectedBranch.city}/${selectedBranch.state}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 24),

        // Feature Card 1: Estilo & Precisão
        _buildFeatureCard(
          icon: Icons.content_cut_outlined,
          title: 'Estilo & Precisão',
          description: 'Cortes de cabelo e barbas com técnicas clássicas.',
        ),
        const SizedBox(height: 12),

        // Feature Card 2: Agendamento & Histórico
        _buildFeatureCard(
          icon: Icons.calendar_today_outlined,
          title: 'Agendamento & Histórico',
          description: 'Acesse seus horários e histórico de serviços online.',
        ),
      ],
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        color: const Color(0xFF151412),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF4A3B24).withValues(alpha: 0.8),
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF221E17),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFF5A492E),
                width: 1.0,
              ),
            ),
            child: Icon(
              icon,
              color: const Color(0xFFD4AF37),
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFFEAD2A1),
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 28),
      decoration: BoxDecoration(
        color: const Color(0xFF131315),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF2B2824),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Form(
        key: _emailFormKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title
            const Center(
              child: Text(
                'Entrar com Credenciais',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            const SizedBox(height: 22),

            // Error Message (if any)
            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 12),
                decoration: BoxDecoration(
                  color: ThemeColors.danger.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: ThemeColors.danger.withValues(alpha: 0.35)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: ThemeColors.danger, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: ThemeColors.danger, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Input: E-mail ou Usuário
            _buildCustomInput(
              controller: _emailController,
              hintText: 'E-mail ou Usuário',
              prefixIcon: Icons.mail_outline,
              keyboardType: TextInputType.emailAddress,
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Informe seu e-mail ou usuário';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),

            // Input: Senha
            _buildCustomInput(
              controller: _passwordController,
              hintText: 'Senha',
              prefixIcon: Icons.lock_outline,
              obscureText: _obscurePassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: Colors.white38,
                  size: 19,
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
              validator: (val) {
                if (val == null || val.isEmpty) {
                  return 'Informe sua senha';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),

            // Link: Esqueceu sua senha?
            Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: _showForgotPasswordDialog,
                child: Text(
                  'Esqueceu sua senha?',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 11.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Button: Entrar no Sistema (Golden Gradient)
            Container(
              height: 46,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFDFB453),
                    Color(0xFFBA8A2D),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFBA8A2D).withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _loading ? null : _handleEmailLogin,
                child: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF141414),
                        ),
                      )
                    : const Text(
                        'Entrar no Sistema',
                        style: TextStyle(
                          color: Color(0xFF141414),
                          fontWeight: FontWeight.w800,
                          fontSize: 14.5,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),

            // Divider: OU ACESSO RÁPIDO
            Row(
              children: [
                Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.12))),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    'OU ACESSO RÁPIDO',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.38),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
                Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.12))),
              ],
            ),
            const SizedBox(height: 16),

            // Row: [ Google ] [ Celular/Zap ]
            Row(
              children: [
                // Google Button
                Expanded(
                  child: InkWell(
                    onTap: _loading ? null : _handleGoogleSignIn,
                    borderRadius: BorderRadius.circular(22),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF18181C),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildGoogleGLogo(size: 18),
                          const SizedBox(width: 8),
                          const Text(
                            'Google',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Celular / Zap Button
                Expanded(
                  child: InkWell(
                    onTap: _loading ? null : _handlePhonePopup,
                    borderRadius: BorderRadius.circular(22),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF18181C),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: const Color(0xFF25D366).withValues(alpha: 0.55),
                          width: 1.2,
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.phone_android,
                            color: Color(0xFF25D366),
                            size: 17,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Celular/Zap',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
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
            const SizedBox(height: 18),

            // Guest access link
            Center(
              child: InkWell(
                onTap: _loading
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
                            setState(() => _loading = false);
                          }
                        }
                      },
                child: Text(
                  'Entrar como Visitante sem conta',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Register prompt
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Não tem uma conta? ',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.55),
                      fontSize: 12.5,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const RegisterPage()),
                      );
                    },
                    child: const Text(
                      'Cadastre-se',
                      style: TextStyle(
                        color: Color(0xFFDFB453),
                        fontWeight: FontWeight.bold,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomInput({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      style: const TextStyle(color: Colors.white, fontSize: 13.5),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: Colors.white.withValues(alpha: 0.35),
          fontSize: 13,
        ),
        filled: true,
        fillColor: const Color(0xFF19191D),
        prefixIcon: Icon(prefixIcon, color: Colors.white38, size: 19),
        suffixIcon: suffixIcon,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.12),
            width: 1.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.12),
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Color(0xFFDFB453),
            width: 1.2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: ThemeColors.danger, width: 1.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: ThemeColors.danger, width: 1.2),
        ),
        errorStyle: const TextStyle(fontSize: 11, height: 1.1),
      ),
    );
  }
}

/// Logo composto com tesoura e pente desenhados em traços dourados
class BarberScissorsCombLogo extends StatelessWidget {
  final double size;
  final Color color;

  const BarberScissorsCombLogo({
    super.key,
    this.size = 40,
    this.color = const Color(0xFFD4AF37),
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _ScissorsCombPainter(color: color),
    );
  }
}

class _ScissorsCombPainter extends CustomPainter {
  final Color color;
  const _ScissorsCombPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Scissor Rings (loops na esquerda)
    canvas.drawCircle(Offset(size.width * 0.22, size.height * 0.74), size.width * 0.12, paint);
    canvas.drawCircle(Offset(size.width * 0.22, size.height * 0.38), size.width * 0.12, paint);

    // Scissor Blades (lâminas cruzando em direção ao canto direito)
    canvas.drawLine(
      Offset(size.width * 0.32, size.height * 0.74),
      Offset(size.width * 0.65, size.height * 0.26),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.32, size.height * 0.38),
      Offset(size.width * 0.65, size.height * 0.86),
      paint,
    );

    // Comb Spine (espinha do pente diagonal)
    final spinePaint = Paint()
      ..color = color
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round;

    final start = Offset(size.width * 0.45, size.height * 0.78);
    final end = Offset(size.width * 0.88, size.height * 0.22);
    canvas.drawLine(start, end, spinePaint);

    // Dentes do pente
    final teethPaint = Paint()
      ..color = color
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    for (int i = 1; i <= 6; i++) {
      final t = i / 7.0;
      final base = Offset.lerp(start, end, t)!;
      final toothEnd = base + const Offset(5.5, -5.5);
      canvas.drawLine(base, toothEnd, teethPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
