import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../design_system/layouts/app_container.dart';
import '../../../../design_system/layouts/app_section.dart';
import '../../../../design_system/molecules/app_card.dart';
import '../../../../design_system/molecules/app_stat_card.dart';
import '../../../../design_system/organisms/app_header.dart';
import '../../../../design_system/organisms/app_modal.dart';
import '../../../../design_system/atoms/app_avatar.dart';
import '../../../../design_system/atoms/app_button.dart';
import '../../../../design_system/atoms/app_badge.dart';
import '../../../../design_system/theme/theme_colors.dart';
import '../../../authentication/application/auth_controller.dart';
import '../../../appointments/application/appointment_controller.dart';
import '../../../appointments/presentation/widgets/booking_wizard.dart';
import '../../../plans/application/plans_controller.dart';
import 'package:intl/intl.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  void _openBookingWizard(BuildContext context, {dynamic preselectedService}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AppModal(
        title: 'Agendar Horário',
        child: BookingWizard(preselectedService: preselectedService),
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
                                color: ThemeColors.primary.withOpacity(0.2),
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
                              mainAxisExtent: 180,
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
                                        const SizedBox(height: 12),
                                        Text(
                                          '${upcoming.date.split('-').reversed.join('/')} às ${upcoming.time}',
                                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Barbeiro: ${upcoming.barberName}',
                                          style: const TextStyle(fontSize: 13, color: Colors.grey),
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
                        subtitle: 'Selecione um serviço rápido para abrir o agendamento',
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
                                          'R\$ ${s.price.toStringAsFixed(2)}',
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
                        subtitle: 'Conheça nossos profissionais especialistas',
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
                                  mainAxisExtent: 220,
                                ),
                                itemCount: barbers.length,
                                itemBuilder: (context, index) {
                                  final b = barbers[index];
                                  return AppCard(
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            AppAvatar(url: b.avatarUrl, size: 50),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(b.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
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
                                        const SizedBox(height: 12),
                                        Text(
                                          b.bio,
                                          style: const TextStyle(fontSize: 12, color: Colors.grey, height: 1.3),
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const Spacer(),
                                        Wrap(
                                          spacing: 6,
                                          children: b.specialties.map((s) => AppBadge(label: s)).toList(),
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
