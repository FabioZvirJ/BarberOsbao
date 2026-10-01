import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:barber_osbao/packages/design_system/theme/theme_colors.dart';
import 'package:barber_osbao/packages/design_system/theme/app_breakpoints.dart';
import 'package:barber_osbao/packages/design_system/layouts/app_page.dart';
import 'package:barber_osbao/packages/design_system/layouts/app_section.dart';
import 'package:barber_osbao/packages/design_system/molecules/app_card.dart';
import 'package:barber_osbao/packages/design_system/molecules/app_input.dart';
import 'package:barber_osbao/packages/design_system/molecules/app_image_upload.dart';
import 'package:barber_osbao/packages/design_system/atoms/app_button.dart';
import 'package:barber_osbao/packages/design_system/organisms/app_dialog.dart';
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
  bool _initialized = false;

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

    if (businessState is AppLoading ||
        userState.isLoading ||
        businessState.data == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: ThemeColors.primary),
        ),
      );
    }

    final settings = businessState.data!;
    final user = userState.value;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (!_initialized) {
      _nameController.text = settings.name;
      _phoneController.text = settings.phone;
      _addressController.text = settings.address;
      _logoController.text = settings.logoUrl;
      _instaController.text = settings.instagram;
      _faceController.text = settings.facebook;
      _pixController.text = settings.pixKey;
      _initialized = true;
    }

    return AppPage(
      title: 'Configurações',
      userName: user?.name ?? 'Fábio Zvir',
      userAvatarUrl:
          user?.avatarUrl ??
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&width=150',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Company Data
            AppSection(
              title: 'Dados da Barbearia',
              subtitle:
                  'Nome da barbearia, canais sociais e configurações de PIX',
              child: AppCard(
                child: Column(
                  children: [
                    AppBreakpoints.isMobile(context)
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppImageUpload(
                                label: 'Logotipo da Barbearia',
                                controller: _logoController,
                                height: 160,
                                helperText:
                                    'Upload direto ou cole o link (PNG, JPG, WEBP)',
                              ),
                              const SizedBox(height: 16),
                              AppInput(
                                label: 'Nome Comercial',
                                controller: _nameController,
                              ),
                              const SizedBox(height: 16),
                              AppInput(
                                label: 'Telefone de Contato',
                                controller: _phoneController,
                              ),
                              const SizedBox(height: 16),
                              AppInput(
                                label: 'Chave PIX Recebimento',
                                controller: _pixController,
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: AppImageUpload(
                                      label: 'Logotipo da Barbearia',
                                      controller: _logoController,
                                      height: 160,
                                      helperText:
                                          'Upload direto ou cole o link (PNG, JPG, WEBP)',
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    flex: 3,
                                    child: Column(
                                      children: [
                                        AppInput(
                                          label: 'Nome Comercial',
                                          controller: _nameController,
                                        ),
                                        const SizedBox(height: 16),
                                        AppInput(
                                          label: 'Telefone de Contato',
                                          controller: _phoneController,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: AppInput(
                                      label: 'Chave PIX Recebimento',
                                      controller: _pixController,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                    const SizedBox(height: 16),
                    AppInput(
                      label: 'Endereço Completo',
                      controller: _addressController,
                    ),
                    const SizedBox(height: 16),
                    AppBreakpoints.isMobile(context)
                        ? Column(
                            children: [
                              AppInput(
                                label: 'Instagram',
                                controller: _instaController,
                                placeholder: '@usuario',
                              ),
                              const SizedBox(height: 16),
                              AppInput(
                                label: 'Facebook Page',
                                controller: _faceController,
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              Expanded(
                                child: AppInput(
                                  label: 'Instagram',
                                  controller: _instaController,
                                  placeholder: '@usuario',
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: AppInput(
                                  label: 'Facebook Page',
                                  controller: _faceController,
                                ),
                              ),
                            ],
                          ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // 2. Schedule options & working hours
            AppBreakpoints.isMobile(context)
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Working hours
                      AppSection(
                        title: 'Horário de Funcionamento',
                        subtitle:
                            'Defina os horários de atendimento da barbearia (clique para alterar)',
                        child: AppCard(
                          child: Column(
                            children: [
                              _buildHourRow(
                                context,
                                settings,
                                'Segunda a Sexta',
                                settings.workingHours['Segunda a Sexta'] ??
                                    '09:00 - 20:00',
                              ),
                              const Divider(height: 24),
                              _buildHourRow(
                                context,
                                settings,
                                'Sábado',
                                settings.workingHours['Sábado'] ??
                                    '09:00 - 18:00',
                              ),
                              const Divider(height: 24),
                              _buildHourRow(
                                context,
                                settings,
                                'Domingo',
                                settings.workingHours['Domingo'] ?? 'Fechado',
                                isOpen: false,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Intervals and schedule conflict settings
                      AppSection(
                        title: 'Configurações de Agendamento',
                        subtitle:
                            'Intervalos de encaixe e validação de conflitos na agenda',
                        child: AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DropdownButtonFormField<String>(
                                dropdownColor: isDark
                                    ? ThemeColors.darkSurface
                                    : Colors.white,
                                initialValue: settings.slotInterval,
                                decoration: InputDecoration(
                                  labelText:
                                      'Tempo entre Atendimentos (Intervalo de Encaixe)',
                                  labelStyle: TextStyle(
                                    color: isDark
                                        ? Colors.white70
                                        : Colors.black87,
                                    fontSize: 13,
                                  ),
                                  filled: true,
                                  fillColor: isDark
                                      ? ThemeColors.darkSurface
                                      : Colors.grey.shade50,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: isDark
                                          ? ThemeColors.darkBorder
                                          : Colors.grey.shade300,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: isDark
                                          ? ThemeColors.darkBorder
                                          : Colors.grey.shade300,
                                    ),
                                  ),
                                ),
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black87,
                                  fontSize: 14,
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: '15',
                                    child: Text('15 Minutos'),
                                  ),
                                  DropdownMenuItem(
                                    value: '30',
                                    child: Text('30 Minutos (Padrão)'),
                                  ),
                                  DropdownMenuItem(
                                    value: '45',
                                    child: Text('45 Minutos'),
                                  ),
                                  DropdownMenuItem(
                                    value: '60',
                                    child: Text('60 Minutos'),
                                  ),
                                ],
                                onChanged: (val) {
                                  if (val != null) {
                                    ref
                                        .read(
                                          businessSettingsControllerProvider
                                              .notifier,
                                        )
                                        .updateSettings(
                                          settings.copyWith(slotInterval: val),
                                        );
                                  }
                                },
                              ),
                              const SizedBox(height: 12),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.info_outline,
                                    size: 16,
                                    color: ThemeColors.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Utilizado para validar conflitos de horários na agenda do barbeiro. Ex: com 30m, se houver um atendimento às 08:40, um novo agendamento às 09:00 é bloqueado por sobreposição.',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark
                                            ? Colors.white54
                                            : Colors.black54,
                                        height: 1.3,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Working hours
                      Expanded(
                        child: AppSection(
                          title: 'Horário de Funcionamento',
                          subtitle:
                              'Defina os horários de atendimento da barbearia (clique para alterar)',
                          child: AppCard(
                            child: Column(
                              children: [
                                _buildHourRow(
                                  context,
                                  settings,
                                  'Segunda a Sexta',
                                  settings.workingHours['Segunda a Sexta'] ??
                                      '09:00 - 20:00',
                                ),
                                const Divider(height: 24),
                                _buildHourRow(
                                  context,
                                  settings,
                                  'Sábado',
                                  settings.workingHours['Sábado'] ??
                                      '09:00 - 18:00',
                                ),
                                const Divider(height: 24),
                                _buildHourRow(
                                  context,
                                  settings,
                                  'Domingo',
                                  settings.workingHours['Domingo'] ?? 'Fechado',
                                  isOpen: false,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                      // Intervals and schedule conflict settings
                      Expanded(
                        child: AppSection(
                          title: 'Configurações de Agendamento',
                          subtitle:
                              'Intervalos de encaixe e validação de conflitos na agenda',
                          child: AppCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                DropdownButtonFormField<String>(
                                  dropdownColor: isDark
                                      ? ThemeColors.darkSurface
                                      : Colors.white,
                                  initialValue: settings.slotInterval,
                                  decoration: InputDecoration(
                                    labelText:
                                        'Tempo entre Atendimentos (Intervalo de Encaixe)',
                                    labelStyle: TextStyle(
                                      color: isDark
                                          ? Colors.white70
                                          : Colors.black87,
                                      fontSize: 13,
                                    ),
                                    filled: true,
                                    fillColor: isDark
                                        ? ThemeColors.darkSurface
                                        : Colors.grey.shade50,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: isDark
                                            ? ThemeColors.darkBorder
                                            : Colors.grey.shade300,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: isDark
                                            ? ThemeColors.darkBorder
                                            : Colors.grey.shade300,
                                      ),
                                    ),
                                  ),
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.white
                                        : Colors.black87,
                                    fontSize: 14,
                                  ),
                                  items: const [
                                    DropdownMenuItem(
                                      value: '15',
                                      child: Text('15 Minutos'),
                                    ),
                                    DropdownMenuItem(
                                      value: '30',
                                      child: Text('30 Minutos (Padrão)'),
                                    ),
                                    DropdownMenuItem(
                                      value: '45',
                                      child: Text('45 Minutos'),
                                    ),
                                    DropdownMenuItem(
                                      value: '60',
                                      child: Text('60 Minutos'),
                                    ),
                                  ],
                                  onChanged: (val) {
                                    if (val != null) {
                                      ref
                                          .read(
                                            businessSettingsControllerProvider
                                                .notifier,
                                          )
                                          .updateSettings(
                                            settings.copyWith(
                                              slotInterval: val,
                                            ),
                                          );
                                    }
                                  },
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.info_outline,
                                      size: 16,
                                      color: ThemeColors.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Utilizado para validar conflitos de horários na agenda do barbeiro. Ex: com 30m, se houver um atendimento às 08:40, um novo agendamento às 09:00 é bloqueado por sobreposição.',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isDark
                                              ? Colors.white54
                                              : Colors.black54,
                                          height: 1.3,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
            const SizedBox(height: 32),

            // 3. Theme & Appearance (Separated dedicated section)
            AppSection(
              title: 'Aparência e Identidade Visual',
              subtitle: 'Personalize as preferências de tema e exibição do ERP',
              child: AppCard(
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  secondary: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: ThemeColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      user?.theme == 'dark'
                          ? Icons.dark_mode_outlined
                          : Icons.light_mode_outlined,
                      color: ThemeColors.primary,
                    ),
                  ),
                  title: const Text(
                    'Tema Escuro (Dark Mode)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: const Text(
                    'Alterna a identidade visual entre claro e escuro para todo o painel',
                  ),
                  value: user?.theme == 'dark',
                  activeThumbColor: ThemeColors.primary,
                  onChanged: (val) {
                    if (user != null) {
                      ref
                          .read(authControllerProvider.notifier)
                          .updateUser(
                            user.copyWith(
                              theme: val ? 'dark' : 'light',
                            ),
                          );
                    }
                  },
                ),
              ),
            ),

            // 3. Notification switches & WhatsApp Integration
            AppSection(
              title: 'Notificações & Integrações',
              subtitle: 'Habilite o envio de alertas automáticos para clientes',
              child: AppCard(
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text(
                        'WhatsApp Notificações Automáticas',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: const Text(
                        'Envia lembretes automáticos de agendamentos e aniversários via WhatsApp API.',
                      ),
                      value: user?.whatsappNotifications ?? false,
                      activeThumbColor: ThemeColors.primary,
                      onChanged: (val) {
                        if (user != null) {
                          ref
                              .read(authControllerProvider.notifier)
                              .updateUser(
                                user.copyWith(whatsappNotifications: val),
                              );
                        }
                      },
                    ),
                    const Divider(height: 24),
                    SwitchListTile(
                      title: const Text(
                        'Notificações de E-mail',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      value: user?.emailNotifications ?? true,
                      activeThumbColor: ThemeColors.primary,
                      onChanged: (val) {
                        if (user != null) {
                          ref
                              .read(authControllerProvider.notifier)
                              .updateUser(
                                user.copyWith(emailNotifications: val),
                              );
                        }
                      },
                    ),
                    const Divider(height: 24),
                    SwitchListTile(
                      title: const Text(
                        'Notificações Push (Navegador)',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      value: user?.pushNotifications ?? true,
                      activeThumbColor: ThemeColors.primary,
                      onChanged: (val) {
                        if (user != null) {
                          ref
                              .read(authControllerProvider.notifier)
                              .updateUser(
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
                      ref
                          .read(businessSettingsControllerProvider.notifier)
                          .updateSettings(updated);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Configurações atualizadas com sucesso!',
                          ),
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
      ),
    );
  }

  Widget _buildHourRow(
    BuildContext context,
    dynamic settings,
    String day,
    String hours, {
    bool isOpen = true,
  }) {
    final isActuallyOpen = isOpen && hours.toLowerCase() != 'fechado';
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              isActuallyOpen ? Icons.access_time_filled : Icons.access_time,
              size: 16,
              color: isActuallyOpen ? ThemeColors.primary : Colors.grey,
            ),
            const SizedBox(width: 8),
            Text(day, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isActuallyOpen
                    ? ThemeColors.primary.withValues(alpha: 0.1)
                    : Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                hours,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isActuallyOpen ? ThemeColors.primary : Colors.red,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 18),
              tooltip: 'Alterar Horário',
              onPressed: () => _showEditHoursDialog(
                context,
                settings,
                day,
                hours,
                isActuallyOpen,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showEditHoursDialog(
    BuildContext context,
    dynamic settings,
    String day,
    String currentHours,
    bool isOpenInitial,
  ) {
    bool isOpen = isOpenInitial && currentHours.toLowerCase() != 'fechado';
    String startTime = '09:00';
    String endTime = '20:00';

    if (currentHours.contains('-')) {
      final parts = currentHours.split('-');
      if (parts.length == 2) {
        startTime = parts[0].trim();
        endTime = parts[1].trim();
      }
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            return AppResponsiveDialog(
              title: 'Horário de Funcionamento - $day',
              subtitle: 'Defina os horários de abertura e encerramento da loja',
              maxWidth: 480,
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogCtx).pop(),
                  child: Text(
                    'Cancelar',
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                AppButton(
                  label: 'Salvar Horário',
                  onPressed: () {
                    final newHours =
                        Map<String, String>.from(settings.workingHours as Map);
                    newHours[day] =
                        isOpen ? '$startTime - $endTime' : 'Fechado';
                    ref
                        .read(businessSettingsControllerProvider.notifier)
                        .updateSettings(
                          settings.copyWith(workingHours: newHours),
                        );
                    Navigator.of(dialogCtx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Horário de $day atualizado para ${newHours[day]}!',
                        ),
                        backgroundColor: ThemeColors.success,
                      ),
                    );
                  },
                ),
              ],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Loja Aberta neste dia',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    subtitle: Text(
                      isOpen
                          ? 'A barbearia realiza atendimentos'
                          : 'Loja fechada (sem agendamentos)',
                    ),
                    value: isOpen,
                    activeThumbColor: ThemeColors.primary,
                    onChanged: (val) => setDialogState(() => isOpen = val),
                  ),
                  if (isOpen) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final parts = startTime.split(':');
                              final initial = TimeOfDay(
                                hour: int.tryParse(parts[0]) ?? 9,
                                minute: int.tryParse(parts[1]) ?? 0,
                              );
                              final picked = await showTimePicker(
                                context: dialogCtx,
                                initialTime: initial,
                              );
                              if (picked != null) {
                                setDialogState(() {
                                  startTime =
                                      '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                                });
                              }
                            },
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'Abertura',
                                filled: true,
                                fillColor: isDark
                                    ? ThemeColors.darkSurface
                                    : Colors.grey.shade50,
                                suffixIcon: const Icon(
                                  Icons.access_time,
                                  size: 18,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                startTime,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final parts = endTime.split(':');
                              final initial = TimeOfDay(
                                hour: int.tryParse(parts[0]) ?? 20,
                                minute: int.tryParse(parts[1]) ?? 0,
                              );
                              final picked = await showTimePicker(
                                context: dialogCtx,
                                initialTime: initial,
                              );
                              if (picked != null) {
                                setDialogState(() {
                                  endTime =
                                      '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                                });
                              }
                            },
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'Fechamento',
                                filled: true,
                                fillColor: isDark
                                    ? ThemeColors.darkSurface
                                    : Colors.grey.shade50,
                                suffixIcon: const Icon(
                                  Icons.access_time,
                                  size: 18,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                endTime,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }
}
