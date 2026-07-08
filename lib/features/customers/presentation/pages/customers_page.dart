import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../design_system/layouts/app_container.dart';
import '../../../../design_system/layouts/app_section.dart';
import '../../../../design_system/molecules/app_card.dart';
import '../../../../design_system/atoms/app_avatar.dart';
import '../../../../design_system/atoms/app_badge.dart';
import '../../../../design_system/theme/theme_colors.dart';
import '../../../appointments/application/appointment_controller.dart';
import '../../../../shared/models/customer.dart';

class CustomersPage extends ConsumerWidget {
  const CustomersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final barbersState = ref.watch(barbersProvider);
    
    // Custom mockup list for customers
    final List<Customer> mockCustomers = [
      const Customer(id: 'c_1', name: 'Danilo Alencar', email: 'danilo@gmail.com', phone: '(11) 98888-8888', avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&width=150'),
      const Customer(id: 'c_2', name: 'Rodrigo Lima', email: 'rodrigo@gmail.com', phone: '(11) 97777-7777', avatarUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?q=80&width=150'),
      const Customer(id: 'c_3', name: 'Lucas Pinho', email: 'lucas@gmail.com', phone: '(11) 96666-6666', avatarUrl: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?q=80&width=150'),
    ];

    return Scaffold(
      body: AppContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Clientes & Equipe',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 4),
                Text(
                  'Visualize a lista de clientes frequentes e a equipe de barbeiros.',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 32),

            AppSection(
              title: 'Nossos Profissionais (Equipe)',
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
                        mainAxisExtent: 180,
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
                                  AppAvatar(url: b.avatarUrl, size: 44),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(b.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                      Row(
                                        children: [
                                          const Icon(Icons.star, color: ThemeColors.primary, size: 14),
                                          const SizedBox(width: 4),
                                          Text(b.rating.toString(), style: const TextStyle(fontSize: 12)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(b.bio, style: const TextStyle(color: Colors.grey, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
                              const Spacer(),
                              Wrap(
                                spacing: 4,
                                children: b.specialties.take(2).map((s) => AppBadge(label: s)).toList(),
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
            const SizedBox(height: 40),

            AppSection(
              title: 'Clientes Frequentes',
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final crossCount = constraints.maxWidth > 800 ? 3 : 1;
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossCount,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      mainAxisExtent: 140,
                    ),
                    itemCount: mockCustomers.length,
                    itemBuilder: (context, index) {
                      final c = mockCustomers[index];
                      return AppCard(
                        child: Row(
                          children: [
                            AppAvatar(url: c.avatarUrl, size: 48),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Text(c.email, style: const TextStyle(color: Colors.grey, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 2),
                                  Text(c.phone, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                ],
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
          ],
        ),
      ),
    );
  }
}
