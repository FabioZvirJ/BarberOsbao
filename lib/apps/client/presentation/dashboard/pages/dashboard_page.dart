import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:barber_osbao/packages/design_system/layouts/app_container.dart';
import 'package:barber_osbao/packages/design_system/layouts/app_section.dart';
import 'package:barber_osbao/packages/design_system/molecules/app_card.dart';
import 'package:barber_osbao/packages/design_system/molecules/app_stat_card.dart';
import 'package:barber_osbao/packages/design_system/organisms/app_header.dart';
import 'package:barber_osbao/packages/design_system/organisms/app_modal.dart';
import 'package:barber_osbao/packages/design_system/atoms/app_avatar.dart';
import 'package:barber_osbao/packages/design_system/atoms/app_button.dart';
import 'package:barber_osbao/packages/design_system/atoms/app_badge.dart';
import 'package:barber_osbao/packages/design_system/theme/theme_colors.dart';
import 'package:barber_osbao/packages/core/models/barber.dart';
import 'package:barber_osbao/packages/core/models/appointment.dart';
import 'package:barber_osbao/packages/core/models/service_model.dart';
import 'package:barber_osbao/packages/core/utils/app_formatters.dart';
import 'package:barber_osbao/packages/core/auth/application/auth_controller.dart';
import 'package:barber_osbao/packages/core/shared/appointments/application/appointment_controller.dart';
import 'package:barber_osbao/apps/client/presentation/appointments/widgets/booking_wizard.dart';
import 'package:barber_osbao/packages/core/shared/plans/application/plans_controller.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  void _openBookingWizard(
    BuildContext context, {
    ServiceModel? preselectedService,
    Barber? preselectedBarber,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AppModal(
        title: 'Agendar Horário',
        child: BookingWizard(
          preselectedService: preselectedService,
          preselectedBarber: preselectedBarber,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(authControllerProvider);
    final appointmentsState = ref.watch(appointmentsControllerProvider);
    final membershipState = ref.watch(membershipControllerProvider);
    final barbersState = ref.watch(barbersProvider);
    final servicesState = ref.watch(servicesProvider);

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return userState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => const Center(child: Text('Erro ao carregar dados do usuário.')),
      data: (user) {
        if (user == null) return const Center(child: Text('Nenhum usuário logado.'));

        return Scaffold(
          body: Column(
            children: [
              AppHeader(
                userName: user.name,
                userAvatarUrl: user.avatarUrl,
                onProfileTap: () {
                  // Profile handle
                },
              ),
              Expanded(
                child: AppContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Banner
                      AppCard(
                        padding: const EdgeInsets.all(32),
                        borderGlow: true,
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Estilo de Rei, Atendimento Único',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w900,
                                      color: ThemeColors.primary,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Faça parte do clube de fidelidade e tenha acesso a cortes ilimitados, descontos especiais e atendimento exclusivo sem filas.',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isDark ? Colors.white60 : Colors.black54,
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  AppButton(
                                    label: 'Agendar Novo Horário',
                                    onPressed: () => _openBookingWizard(context),
                                    icon: const Icon(Icons.calendar_today, size: 16),
                                  ),
                                ],
                              ),
                            ),
                            if (MediaQuery.of(context).size.width > 700) ...[
                              const SizedBox(width: 32),
                              Icon(
                                Icons.content_cut,
                                size: 100,
                                color: ThemeColors.primary.withValues(alpha: 0.2),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Metric Stat Cards Grid
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final crossCount = constraints.maxWidth > 800 ? 3 : 1;
                          return GridView(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossCount,
                              crossAxisSpacing: 20,
                              mainAxisSpacing: 20,
                              mainAxisExtent: 195,
                            ),
                            children: [
                              // 1. Next Appointment Card
                              appointmentsState.when(
                                loading: () => const AppCard(child: Center(child: CircularProgressIndicator())),
                                error: (e, s) => const AppCard(child: Center(child: Text('Erro.'))),
                                data: (apts) {
                                  final upcoming = apts.isEmpty
                                      ? null
                                      : apts.firstWhere((a) => a.status == 'confirmed', orElse: () => apts.first);
                                  
                                  if (upcoming == null) {
                                    return AppStatCard(
                                      title: 'PRÓXIMO AGENDAMENTO',
                                      value: 'Nenhum',
                                      icon: const Icon(Icons.calendar_today, color: Colors.grey),
                                    );
                                  }

                                  return AppCard(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'PRÓXIMO AGENDAMENTO',
                                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
                                            ),
                                            AppBadge(label: 'Confirmado', variant: AppBadgeVariant.success),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          '${upcoming.date.split('-').reversed.join('/')} às ${upcoming.time}',
                                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(Icons.person_outline, size: 14, color: ThemeColors.primary),
                                            const SizedBox(width: 4),
                                            Text(
                                              upcoming.barberName,
                                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 3),
                                        Row(
                                          children: [
                                            const Icon(Icons.location_on_outlined, size: 13, color: ThemeColors.primary),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                '${upcoming.locationName} • ${upcoming.locationAddress}',
                                                style: const TextStyle(fontSize: 11, color: Colors.grey),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const Spacer(),
                                        Row(
                                          children: [
                                            TextButton(
                                              onPressed: () {
                                                ref.read(appointmentsControllerProvider.notifier).cancelAppointment(upcoming.id);
                                              },
                                              child: const Text('Cancelar', style: TextStyle(color: Colors.red, fontSize: 13)),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),

                              // 2. Active Membership Card
                              membershipState.when(
                                loading: () => const AppCard(child: Center(child: CircularProgressIndicator())),
                                error: (e, s) => const AppCard(child: Center(child: Text('Erro.'))),
                                data: (mem) {
                                  if (mem == null || mem.status != 'active') {
                                    return AppStatCard(
                                      title: 'PLANO ATIVO',
                                      value: 'Sem Assinatura',
                                      icon: const Icon(Icons.star_outline, color: Colors.grey),
                                    );
                                  }

                                  return AppStatCard(
                                    title: 'PLANO ATIVO',
                                    value: mem.planName,
                                    icon: const Icon(Icons.star, color: ThemeColors.primary),
                                    trendText: 'Renova em ${mem.nextRenewalDate.split('-').reversed.join('/')}',
                                    positiveTrend: true,
                                  );
                                },
                              ),

                              // 3. Benefits / Club summary
                              membershipState.when(
                                loading: () => const AppCard(child: Center(child: CircularProgressIndicator())),
                                error: (e, s) => const AppCard(child: Center(child: Text('Erro.'))),
                                data: (mem) {
                                  if (mem == null || mem.status != 'active') {
                                    return AppStatCard(
                                      title: 'CLUBE FIDELIDADE',
                                      value: '0 pontos',
                                      icon: const Icon(Icons.card_membership, color: Colors.grey),
                                    );
                                  }

                                  return AppCard(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'BENEFÍCIOS DISPONÍVEIS',
                                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
                                        ),
                                        const SizedBox(height: 12),
                                        Expanded(
                                          child: ListView(
                                            physics: const NeverScrollableScrollPhysics(),
                                            children: mem.remainingBenefits.map((b) => Padding(
                                              padding: const EdgeInsets.only(bottom: 4.0),
                                              child: Row(
                                                children: [
                                                  const Icon(Icons.check_circle_outline, color: ThemeColors.success, size: 14),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      b,
                                                      style: const TextStyle(fontSize: 12),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )).toList(),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 32),

                      // Quick Services Section
                      AppSection(
                        title: 'Nossos Serviços',
                        subtitle:
                            'Catálogo completo de serviços disponíveis na rede Barber Osbão',
                        child: servicesState.when(
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (e, s) => const Center(child: Text('Erro ao carregar serviços.')),
                          data: (services) => LayoutBuilder(
                            builder: (context, constraints) {
                              final crossCount = constraints.maxWidth > 800 ? 4 : 2;
                              return GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossCount,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  mainAxisExtent: 140,
                                ),
                                itemCount: services.length,
                                itemBuilder: (context, index) {
                                  final s = services[index];
                                  return AppCard(
                                    onTap: () => _openBookingWizard(context, preselectedService: s),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          s.category == 'cabelo'
                                              ? Icons.content_cut
                                              : (s.category == 'barba' ? Icons.face : Icons.brush),
                                          color: ThemeColors.primary,
                                          size: 28,
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          s.name,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          AppFormatters.formatCurrency(s.price),
                                          style: const TextStyle(color: ThemeColors.primary, fontSize: 12, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Barbers list section
                      AppSection(
                        title: 'Barbeiros Disponíveis',
                        subtitle:
                            'Conheça nossos profissionais especialistas, confira unidades e agende seu horário',
                        child: barbersState.when(
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (e, s) => const Center(child: Text('Erro ao carregar profissionais.')),
                          data: (barbers) => LayoutBuilder(
                            builder: (context, constraints) {
                              final crossCount = constraints.maxWidth > 800 ? 3 : 1;
                              return GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossCount,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  mainAxisExtent: 260,
                                ),
                                itemCount: barbers.length,
                                itemBuilder: (context, index) {
                                  final b = barbers[index];
                                  return AppCard(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            AppAvatar(url: b.avatarUrl, name: b.name, size: 48),
                                            const SizedBox(width: 14),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    b.name,
                                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Row(
                                                    children: [
                                                      const Icon(Icons.star, color: ThemeColors.primary, size: 14),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        b.rating.toString(),
                                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            const Icon(Icons.store, size: 13, color: ThemeColors.primary),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                b.shopName,
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
                                            const Icon(Icons.location_on_outlined, size: 13, color: Colors.grey),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                b.address,
                                                style: const TextStyle(fontSize: 11, color: Colors.grey),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Wrap(
                                          spacing: 6,
                                          children: b.specialties.take(3).map((s) => AppBadge(label: s)).toList(),
                                        ),
                                        const Spacer(),
                                        SizedBox(
                                          width: double.infinity,
                                          child: AppButton(
                                            label: 'Agendar com ${b.name.split(' ').first}',
                                            icon: const Icon(Icons.calendar_today, size: 13),
                                            onPressed: () => _openBookingWizard(context, preselectedBarber: b),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
