import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/models/appointment.dart';
import '../../../../shared/models/barber.dart';
import '../../../../shared/models/service_model.dart';
import '../../../../shared/models/user.dart';
import '../../../../design_system/atoms/app_button.dart';
import '../../../../design_system/atoms/app_chip.dart';
import '../../../../design_system/atoms/app_avatar.dart';
import '../../../../design_system/molecules/app_card.dart';
import '../../../../design_system/molecules/app_date_picker.dart';
import '../../../../design_system/theme/theme_colors.dart';
import '../../../authentication/application/auth_controller.dart';
import '../../application/appointment_controller.dart';

class BookingWizard extends ConsumerStatefulWidget {
  final ServiceModel? preselectedService;

  const BookingWizard({super.key, this.preselectedService});

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

  @override
  void initState() {
    super.initState();
    if (widget.preselectedService != null) {
      _selectedServices.add(widget.preselectedService!);
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  double get _totalPrice => _selectedServices.fold(0.0, (sum, s) => sum + s.price);
  int get _totalDuration => _selectedServices.fold(0, (sum, s) => sum + s.durationMinutes);

  void _nextStep() {
    setState(() => _currentStep++);
  }

  void _prevStep() {
    setState(() => _currentStep--);
  }

  Future<void> _submitBooking() async {
    if (_selectedBarber == null || _selectedDate == null || _selectedTime == null || _selectedServices.isEmpty) {
      return;
    }

    final user = ref.read(authControllerProvider).value;
    if (user == null) return;

    final apt = Appointment(
      id: 'apt_${DateTime.now().millisecondsSinceEpoch}',
      userId: user.id,
      barberId: _selectedBarber!.id,
      barberName: _selectedBarber!.name,
      barberAvatar: _selectedBarber!.avatarUrl,
      services: _selectedServices,
      date: _selectedDate!.toIso8601String().split('T')[0],
      time: _selectedTime!,
      totalValue: _totalPrice,
      status: 'confirmed',
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
    );

    try {
      await ref.read(appointmentsControllerProvider.notifier).createAppointment(apt);
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

  Widget _buildServicesStep(List<ServiceModel> services) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Selecione os Serviços',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: services.length,
          itemBuilder: (context, index) {
            final srv = services[index];
            final isSelected = _selectedServices.any((s) => s.id == srv.id);

            return Padding(
              padding: const EdgeInsets.bottom(10),
              child: AppCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                    Icon(
                      srv.category == 'cabelo'
                          ? Icons.content_cut
                          : (srv.category == 'barba' ? Icons.face : Icons.brush),
                      color: ThemeColors.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(srv.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            '${srv.durationMinutes} min • R\$ ${srv.price.toStringAsFixed(2)}',
                            style: const TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    Checkbox(
                      value: isSelected,
                      activeColor: ThemeColors.primary,
                      onChanged: (val) {
                        setState(() {
                          if (val == true) {
                            _selectedServices.add(srv);
                          } else {
                            _selectedServices.removeWhere((s) => s.id == srv.id);
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
      ],
    );
  }

  Widget _buildBarberStep(List<Barber> barbers) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Escolha o Profissional',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 220,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: 180,
          ),
          itemCount: barbers.length,
          itemBuilder: (context, index) {
            final barber = barbers[index];
            final isSelected = _selectedBarber?.id == barber.id;

            return AppCard(
              borderGlow: isSelected,
              onTap: () {
                setState(() => _selectedBarber = barber);
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppAvatar(url: barber.avatarUrl, size: 50),
                  const SizedBox(height: 10),
                  Text(
                    barber.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star, color: ThemeColors.primary, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        barber.rating.toString(),
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDateTimeStep() {
    final times = ['09:00', '10:00', '11:00', '13:00', '14:00', '15:00', '16:00', '17:00', '18:00'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppDatePicker(
          label: 'Data do Agendamento',
          selectedDate: _selectedDate,
          onDateSelected: (date) {
            setState(() => _selectedDate = date);
          },
        ),
        const SizedBox(height: 24),
        if (_selectedDate != null) ...[
          const Text(
            'Horários Disponíveis',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: times.map((t) {
              final isSelected = _selectedTime == t;
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

  Widget _buildSummaryStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Resumo do Agendamento',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        AppCard(
          child: Column(
            children: [
              Row(
                children: [
                  if (_selectedBarber != null) AppAvatar(url: _selectedBarber!.avatarUrl, size: 44),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_selectedBarber?.name ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                      const Text('Profissional selecionado', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ],
              ),
              const Divider(height: 32),
              ..._selectedServices.map((s) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(s.name),
                        Text('R\$ ${s.price.toStringAsFixed(2)}'),
                      ],
                    ),
                  )),
              const Divider(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Duração Estimada:', style: TextStyle(color: Colors.grey)),
                  Text('$_totalDuration min'),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Valor Total:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    'R\$ ${_totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: ThemeColors.primary, fontSize: 16),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _notesController,
          maxLines: 2,
          decoration: InputDecoration(
            hintText: 'Observações adicionais (opcional)',
            filled: true,
            fillColor: Theme.of(context).brightness == Brightness.dark ? ThemeColors.darkSurface : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ThemeColors.radius),
              borderSide: BorderSide.none,
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

    return servicesState.when(
      loading: () => const SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),
      error: (e, s) => const SizedBox(height: 200, child: Center(child: Text('Erro ao carregar dados.'))),
      data: (services) => barbersState.when(
        loading: () => const SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),
        error: (e, s) => const SizedBox(height: 200, child: Center(child: Text('Erro ao carregar profissionais.'))),
        data: (barbers) {
          Widget stepWidget;
          bool canAdvance = false;

          switch (_currentStep) {
            case 0:
              stepWidget = _buildServicesStep(services);
              canAdvance = _selectedServices.isNotEmpty;
              break;
            case 1:
              stepWidget = _buildBarberStep(barbers);
              canAdvance = _selectedBarber != null;
              break;
            case 2:
              stepWidget = _buildDateTimeStep();
              canAdvance = _selectedDate != null && _selectedTime != null;
              break;
            case 3:
            default:
              stepWidget = _buildSummaryStep();
              canAdvance = true;
              break;
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              stepWidget,
              const SizedBox(height: 32),
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
                    label: _currentStep == 3 ? 'Confirmar' : 'Avançar',
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
