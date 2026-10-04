import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:barber_osbao/packages/core/models/appointment.dart';
import 'package:barber_osbao/packages/core/models/barber.dart';
import 'package:barber_osbao/packages/core/models/service_model.dart';
import 'package:barber_osbao/packages/design_system/atoms/app_button.dart';
import 'package:barber_osbao/packages/design_system/atoms/app_chip.dart';
import 'package:barber_osbao/packages/design_system/atoms/app_avatar.dart';
import 'package:barber_osbao/packages/design_system/atoms/app_badge.dart';
import 'package:barber_osbao/packages/design_system/molecules/app_card.dart';
import 'package:barber_osbao/packages/design_system/molecules/app_date_picker.dart';
import 'package:barber_osbao/packages/design_system/molecules/app_input.dart';
import 'package:barber_osbao/packages/design_system/theme/theme_colors.dart';
import 'package:barber_osbao/packages/core/auth/application/auth_controller.dart';
import 'package:barber_osbao/packages/core/shared/appointments/application/appointment_controller.dart';
import 'package:barber_osbao/packages/core/utils/app_formatters.dart';
import 'package:barber_osbao/features/filiais/application/branches_controller.dart';

class BookingWizard extends ConsumerStatefulWidget {
  final ServiceModel? preselectedService;
  final List<ServiceModel>? preselectedServices;
  final Barber? preselectedBarber;

  const BookingWizard({
    super.key,
    this.preselectedService,
    this.preselectedServices,
    this.preselectedBarber,
  });

  @override
  ConsumerState<BookingWizard> createState() => _BookingWizardState();
}

class _BookingWizardState extends ConsumerState<BookingWizard> {
  int _currentStep = 0;
  final List<ServiceModel> _selectedServices = [];
  Barber? _selectedBarber;
  DateTime? _selectedDate;
  String? _selectedTime;
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _searchBarberController = TextEditingController();
  String _selectedUnitFilter = 'Todas';

  @override
  void initState() {
    super.initState();
    if (widget.preselectedServices != null &&
        widget.preselectedServices!.isNotEmpty) {
      _selectedServices.addAll(widget.preselectedServices!);
    } else if (widget.preselectedService != null) {
      _selectedServices.add(widget.preselectedService!);
    }

    if (widget.preselectedBarber != null) {
      _selectedBarber = widget.preselectedBarber;
      if (_selectedServices.isNotEmpty) {
        _currentStep = 2; // Go straight to date & time
      } else {
        _currentStep = 1; // Go to services selection for this barber
      }
    } else if (_selectedServices.isNotEmpty) {
      _currentStep = 0; // Pick professional first
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    _searchBarberController.dispose();
    super.dispose();
  }

  double get _totalPrice =>
      _selectedServices.fold(0.0, (sum, s) => sum + s.price);
  int get _totalDuration =>
      _selectedServices.fold(0, (sum, s) => sum + s.durationMinutes);

  void _nextStep() {
    setState(() => _currentStep++);
  }

  void _prevStep() {
    setState(() => _currentStep--);
  }

  Future<void> _submitBooking() async {
    if (_selectedBarber == null ||
        _selectedDate == null ||
        _selectedTime == null ||
        _selectedServices.isEmpty) {
      return;
    }

    final user = ref.read(authControllerProvider).value;
    if (user == null) return;

    final dateStr = _selectedDate!.toIso8601String().split('T')[0];
    final appointmentsState = ref.read(appointmentsControllerProvider);
    final existingList = appointmentsState.value ?? [];

    // Double check conflict
    final hasConflict = existingList.any(
      (a) =>
          a.barberId == _selectedBarber!.id &&
          a.date == dateStr &&
          a.time == _selectedTime &&
          a.status != 'cancelled',
    );

    if (hasConflict) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Este horário já está reservado. Por favor, escolha outro.',
            ),
            backgroundColor: ThemeColors.warning,
          ),
        );
      }
      return;
    }

    final apt = Appointment(
      id: 'apt_${DateTime.now().millisecondsSinceEpoch}',
      userId: user.id,
      barberId: _selectedBarber!.id,
      barberName: _selectedBarber!.name,
      barberAvatar: _selectedBarber!.avatarUrl,
      services: _selectedServices,
      date: dateStr,
      time: _selectedTime!,
      totalValue: _totalPrice,
      status: 'confirmed',
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
    );

    try {
      await ref
          .read(appointmentsControllerProvider.notifier)
          .createAppointment(apt);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Agendamento realizado com sucesso!'),
            backgroundColor: ThemeColors.success,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Falha ao registrar agendamento.'),
            backgroundColor: ThemeColors.danger,
          ),
        );
      }
    }
  }

  Widget _buildStepIndicator(bool isDark) {
    final steps = ['Profissional', 'Serviços', 'Data & Hora', 'Confirmação'];
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: List.generate(steps.length, (idx) {
          final isActive = idx == _currentStep;
          final isDone = idx < _currentStep;
          return Expanded(
            child: Row(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDone
                        ? ThemeColors.success
                        : (isActive
                            ? ThemeColors.primary
                            : (isDark ? Colors.white12 : Colors.grey.shade300)),
                  ),
                  alignment: Alignment.center,
                  child: isDone
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : Text(
                          '${idx + 1}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isActive
                                ? Colors.black
                                : (isDark ? Colors.white70 : Colors.black54),
                          ),
                        ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    steps[idx],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          isActive ? FontWeight.bold : FontWeight.normal,
                      color: isActive
                          ? ThemeColors.primary
                          : (isDark ? Colors.white60 : Colors.black54),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (idx < steps.length - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      color: isDone
                          ? ThemeColors.success
                          : (isDark ? Colors.white10 : Colors.grey.shade300),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // STEP 0: Professional & Barbershop Selection
  Widget _buildBarberStep(List<Barber> barbers, bool isDark) {
    final branches = ref.watch(branchesProvider).value ?? [];
    final selectedBranch = ref.watch(selectedBranchProvider);
    final query = _searchBarberController.text.trim().toLowerCase();
    final units = ['Todas', ...branches.map((b) => b.name)];

    final filtered = barbers.where((b) {
      final matchesUnit = _selectedUnitFilter == 'Todas' ||
          b.shopName.toLowerCase() == _selectedUnitFilter.toLowerCase() ||
          b.neighborhood.toLowerCase() == _selectedUnitFilter.toLowerCase();
      final matchesSearch = query.isEmpty ||
          b.name.toLowerCase().contains(query) ||
          b.shopName.toLowerCase().contains(query) ||
          b.address.toLowerCase().contains(query) ||
          b.specialties.any((s) => s.toLowerCase().contains(query));
      return matchesUnit && matchesSearch;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (selectedBranch != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: ThemeColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: ThemeColors.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.storefront,
                  color: ThemeColors.primary,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            selectedBranch.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: ThemeColors.primary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Unidade Ativa',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${selectedBranch.address}, ${selectedBranch.neighborhood} - ${selectedBranch.city}/${selectedBranch.state}',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                      if (selectedBranch.phone != null &&
                          selectedBranch.phone!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          'WhatsApp: ${selectedBranch.phone}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: ThemeColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (branches.length > 1)
                  PopupMenuButton<String>(
                    tooltip: 'Trocar Filial',
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: ThemeColors.primary),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text(
                            'Trocar',
                            style: TextStyle(
                              color: ThemeColors.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Icon(
                            Icons.arrow_drop_down,
                            color: ThemeColors.primary,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                    onSelected: (slug) {
                      ref.read(currentBranchSlugProvider.notifier).setSlug(slug);
                    },
                    itemBuilder: (context) => branches
                        .map(
                          (b) => PopupMenuItem(
                            value: b.slug,
                            child: Text(b.name),
                          ),
                        )
                        .toList(),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
        ],

        const Text(
          '1. Escolha o Profissional & Barbearia',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Selecione o profissional de atendimento da sua preferência',
          style: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.white60 : Colors.black54,
          ),
        ),
        const SizedBox(height: 16),

        // Live Search Input
        AppInput(
          label: '',
          placeholder: 'Buscar por nome, barbearia, endereço ou especialidade...',
          controller: _searchBarberController,
          prefixIcon: const Icon(Icons.search, size: 20),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),

        // Unit Filter Chips
        if (branches.length > 1)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: units.map((u) {
                final isSel = _selectedUnitFilter == u;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(u),
                    selected: isSel,
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedUnitFilter = u);
                    },
                    selectedColor: ThemeColors.primary,
                    labelStyle: TextStyle(
                      color: isSel
                          ? Colors.black
                          : (isDark ? Colors.white70 : Colors.black87),
                      fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        const SizedBox(height: 16),

        if (barbers.isNotEmpty &&
            _searchBarberController.text.isEmpty &&
            _selectedUnitFilter == 'Todas') ...[
          InkWell(
            onTap: () {
              setState(() {
                _selectedBarber = barbers.first;
              });
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: _selectedBarber?.id == barbers.first.id
                    ? ThemeColors.primary.withValues(alpha: 0.12)
                    : (isDark ? ThemeColors.darkSurface : Colors.grey.shade50),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _selectedBarber?.id == barbers.first.id
                      ? ThemeColors.primary
                      : (isDark ? ThemeColors.darkBorder : Colors.grey.shade300),
                  width: _selectedBarber?.id == barbers.first.id ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: ThemeColors.primary.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.bolt,
                      color: ThemeColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Qualquer Profissional',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: ThemeColors.primary,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Mais Rápido',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Encontraremos o profissional com o horário mais próximo para você.',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white60 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_selectedBarber?.id == barbers.first.id)
                    const Icon(
                      Icons.check_circle,
                      color: ThemeColors.primary,
                      size: 20,
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],

        if (filtered.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            alignment: Alignment.center,
            child: Column(
              children: [
                Icon(
                  Icons.person_search,
                  size: 44,
                  color: isDark ? Colors.white30 : Colors.grey.shade400,
                ),
                const SizedBox(height: 12),
                Text(
                  'Nenhum profissional cadastrado para esta filial ainda.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Assim que o administrador cadastrar profissionais nesta unidade, eles estarão disponíveis para agendamento aqui.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white38 : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          )
        else
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 380),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: filtered.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final barber = filtered[index];
                final isSelected = _selectedBarber?.id == barber.id;

                return AppCard(
                  borderGlow: isSelected,
                  padding: const EdgeInsets.all(14),
                  onTap: () {
                    setState(() => _selectedBarber = barber);
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppAvatar(url: barber.avatarUrl, name: barber.name, size: 52),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    barber.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      color: ThemeColors.primary,
                                      size: 15,
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      barber.rating.toString(),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.store,
                                  size: 14,
                                  color: ThemeColors.primary,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    barber.shopName,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? Colors.white70 : Colors.black87,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on_outlined,
                                  size: 13,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    barber.address,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: barber.specialties
                                  .map((s) => AppBadge(label: s))
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? ThemeColors.primary : (isDark ? Colors.white38 : Colors.grey.shade400),
                            width: isSelected ? 6 : 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  // STEP 1: Services Selection
  Widget _buildServicesStep(List<ServiceModel> services, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '2. Selecione os Serviços',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Serviços disponíveis com ${_selectedBarber?.name ?? "o profissional"} na ${_selectedBarber?.shopName ?? "Barber Osbão"}',
          style: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.white60 : Colors.black54,
          ),
        ),
        const SizedBox(height: 16),
        if (services.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            alignment: Alignment.center,
            child: Column(
              children: [
                Icon(
                  Icons.content_cut,
                  size: 44,
                  color: isDark ? Colors.white30 : Colors.grey.shade400,
                ),
                const SizedBox(height: 12),
                Text(
                  'Nenhum serviço cadastrado no momento.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Cadastre serviços no Painel do Administrador para exibi-los aqui.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white38 : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          )
        else
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 380),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: services.length,
            itemBuilder: (context, index) {
              final srv = services[index];
              final isSelected = _selectedServices.any((s) => s.id == srv.id);

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: AppCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  borderGlow: isSelected,
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedServices.removeWhere((s) => s.id == srv.id);
                      } else {
                        _selectedServices.add(srv);
                      }
                    });
                  },
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: ThemeColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          srv.category == 'cabelo'
                              ? Icons.content_cut
                              : (srv.category == 'barba'
                                  ? Icons.face
                                  : Icons.brush),
                          color: ThemeColors.primary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              srv.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              srv.description,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 11,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${srv.durationMinutes} min • ${AppFormatters.formatCurrency(srv.price)}',
                              style: const TextStyle(
                                color: ThemeColors.primary,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Checkbox(
                        value: isSelected,
                        activeColor: ThemeColors.primary,
                        checkColor: Colors.black,
                        onChanged: (val) {
                          setState(() {
                            if (val == true) {
                              _selectedServices.add(srv);
                            } else {
                              _selectedServices.removeWhere(
                                (s) => s.id == srv.id,
                              );
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // STEP 2: Date & Time Selection
  Widget _buildDateTimeStep(
    List<Appointment> existingAppointments,
    bool isDark,
  ) {
    final times = [
      '09:00',
      '10:00',
      '11:00',
      '13:00',
      '14:00',
      '15:00',
      '16:00',
      '17:00',
      '18:00',
      '19:00',
    ];

    final dateStr = _selectedDate?.toIso8601String().split('T')[0] ?? '';
    final bookedTimes = existingAppointments
        .where(
          (a) =>
              a.barberId == _selectedBarber?.id &&
              a.date == dateStr &&
              a.status != 'cancelled',
        )
        .map((a) => a.time)
        .toSet();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '3. Escolha a Data e Horário',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Selecione a data e o melhor horário livre para atendimento',
          style: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.white60 : Colors.black54,
          ),
        ),
        const SizedBox(height: 16),
        AppDatePicker(
          label: 'Data do Atendimento',
          selectedDate: _selectedDate,
          onDateSelected: (date) {
            setState(() {
              _selectedDate = date;
              _selectedTime = null;
            });
          },
        ),
        const SizedBox(height: 24),
        if (_selectedDate != null) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Horários Disponíveis',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              if (bookedTimes.isNotEmpty)
                Text(
                  '${bookedTimes.length} horário(s) ocupado(s)',
                  style: const TextStyle(
                    fontSize: 12,
                    color: ThemeColors.warning,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: times.map((t) {
              final isBooked = bookedTimes.contains(t);
              final isSelected = _selectedTime == t;

              if (isBooked) {
                return Opacity(
                  opacity: 0.45,
                  child: Tooltip(
                    message: 'Horário já reservado para este barbeiro',
                    child: AppChip(
                      label: '$t (Ocupado)',
                      selected: false,
                      onTap: () {},
                    ),
                  ),
                );
              }

              return AppChip(
                label: t,
                selected: isSelected,
                onTap: () => setState(() => _selectedTime = t),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  // STEP 3: Review & Summary
  Widget _buildSummaryStep(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '4. Resumo e Confirmação',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Revise os detalhes antes de confirmar seu agendamento',
          style: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.white60 : Colors.black54,
          ),
        ),
        const SizedBox(height: 16),
        AppCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Barber & Location details
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_selectedBarber != null)
                    AppAvatar(
                      url: _selectedBarber!.avatarUrl,
                      name: _selectedBarber!.name,
                      size: 48,
                    ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedBarber?.name ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(
                              Icons.store,
                              size: 13,
                              color: ThemeColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                _selectedBarber?.shopName ?? '',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 13,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                _selectedBarber?.address ?? '',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 28),

              // Date and time
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Data & Horário:',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  Text(
                    '${AppFormatters.formatDate(_selectedDate)} às ${_selectedTime ?? ""}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),

              // Selected services
              ..._selectedServices.map(
                (s) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(s.name, style: const TextStyle(fontSize: 13)),
                      Text(
                        AppFormatters.formatCurrency(s.price),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 24),

              // Duration & Total
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Duração Estimada:',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  Text(
                    '$_totalDuration min',
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Valor Total:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  Text(
                    AppFormatters.formatCurrency(_totalPrice),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: ThemeColors.primary,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _notesController,
          maxLines: 2,
          decoration: InputDecoration(
            hintText: 'Observações adicionais para o barbeiro (opcional)...',
            filled: true,
            fillColor: isDark ? ThemeColors.darkSurface : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ThemeColors.radius),
              borderSide: BorderSide(
                color: isDark ? ThemeColors.darkBorder : Colors.grey.shade300,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final servicesState = ref.watch(servicesProvider);
    final barbersState = ref.watch(barbersProvider);
    final appointmentsState = ref.watch(appointmentsControllerProvider);
    final existingAppointments = appointmentsState.value ?? [];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return servicesState.when(
      loading: () => const SizedBox(
        height: 220,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, s) => const SizedBox(
        height: 220,
        child: Center(child: Text('Erro ao carregar dados.')),
      ),
      data: (services) => barbersState.when(
        loading: () => const SizedBox(
          height: 220,
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (e, s) => const SizedBox(
          height: 220,
          child: Center(child: Text('Erro ao carregar profissionais.')),
        ),
        data: (barbers) {
          Widget stepWidget;
          bool canAdvance = false;

          switch (_currentStep) {
            case 0:
              stepWidget = _buildBarberStep(barbers, isDark);
              canAdvance = _selectedBarber != null;
              break;
            case 1:
              stepWidget = _buildServicesStep(services, isDark);
              canAdvance = _selectedServices.isNotEmpty;
              break;
            case 2:
              stepWidget = _buildDateTimeStep(existingAppointments, isDark);
              canAdvance = _selectedDate != null && _selectedTime != null;
              break;
            case 3:
            default:
              stepWidget = _buildSummaryStep(isDark);
              canAdvance = true;
              break;
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStepIndicator(isDark),
              stepWidget,
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentStep > 0)
                    AppButton(
                      label: 'Voltar',
                      variant: AppButtonVariant.outline,
                      onPressed: _prevStep,
                    )
                  else
                    const SizedBox.shrink(),
                  AppButton(
                    label: _currentStep == 3 ? 'Confirmar Agendamento' : 'Avançar',
                    variant: AppButtonVariant.primary,
                    onPressed: canAdvance
                        ? (_currentStep == 3 ? _submitBooking : _nextStep)
                        : null,
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
