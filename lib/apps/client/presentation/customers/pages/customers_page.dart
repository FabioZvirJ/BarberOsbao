import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:barber_osbao/packages/design_system/layouts/app_container.dart';
import 'package:barber_osbao/packages/design_system/molecules/app_card.dart';
import 'package:barber_osbao/packages/design_system/atoms/app_avatar.dart';
import 'package:barber_osbao/packages/design_system/atoms/app_badge.dart';
import 'package:barber_osbao/packages/design_system/atoms/app_button.dart';
import 'package:barber_osbao/packages/design_system/organisms/app_modal.dart';
import 'package:barber_osbao/packages/design_system/theme/theme_colors.dart';
import 'package:barber_osbao/packages/core/shared/appointments/application/appointment_controller.dart';
import 'package:barber_osbao/packages/core/models/barber.dart';
import 'package:barber_osbao/apps/client/presentation/appointments/widgets/booking_wizard.dart';

class CustomersPage extends ConsumerStatefulWidget {
  const CustomersPage({super.key});

  @override
  ConsumerState<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends ConsumerState<CustomersPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedUnit = 'Todas';

  final List<String> _units = [
    'Todas',
    'Jardins',
    'Pinheiros',
    'Centro',
    'Moema',
    'Paulista',
    'Vila Madalena',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openBookingWizard(Barber barber) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AppModal(
        title: 'Agendar com ${barber.name}',
        child: BookingWizard(preselectedBarber: barber),
      ),
    );
  }

  Future<void> _openWhatsApp(String phone) async {
    final clean = phone.replaceAll(RegExp(r'\D'), '');
    if (clean.isNotEmpty) {
      final ddi = clean.startsWith('55') ? clean : '55$clean';
      final uri = Uri.parse('https://wa.me/$ddi');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final barbersState = ref.watch(barbersProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: AppContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Page Header
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Barbeiros & Unidades',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 4),
                Text(
                  'Conheça nossa equipe de especialistas, encontre a unidade mais próxima e agende diretamente.',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Search and Unit Filters
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _searchQuery = val.toLowerCase().trim()),
                    decoration: InputDecoration(
                      hintText: 'Buscar por barbeiro, unidade, bairro ou especialidade...',
                      prefixIcon: const Icon(Icons.search, size: 18, color: Colors.grey),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: isDark ? ThemeColors.darkSurface : Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Unit Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _units.map((unit) {
                  final isSelected = _selectedUnit == unit;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(unit),
                      selected: isSelected,
                      selectedColor: ThemeColors.primary,
                      backgroundColor: isDark ? ThemeColors.darkSurface : Colors.grey.shade100,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.black : (isDark ? Colors.white70 : Colors.black87),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12,
                      ),
                      onSelected: (val) {
                        if (val) setState(() => _selectedUnit = unit);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            // Barbers Grid
            barbersState.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, s) => const Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Center(child: Text('Erro ao carregar profissionais.')),
              ),
              data: (barbers) {
                final filtered = barbers.where((b) {
                  final matchesUnit = _selectedUnit == 'Todas' ||
                      b.neighborhood.toLowerCase().contains(_selectedUnit.toLowerCase()) ||
                      b.shopName.toLowerCase().contains(_selectedUnit.toLowerCase());

                  final query = _searchQuery;
                  final matchesSearch = query.isEmpty ||
                      b.name.toLowerCase().contains(query) ||
                      b.shopName.toLowerCase().contains(query) ||
                      b.address.toLowerCase().contains(query) ||
                      b.neighborhood.toLowerCase().contains(query) ||
                      b.specialties.any((s) => s.toLowerCase().contains(query));

                  return matchesUnit && matchesSearch;
                }).toList();

                if (filtered.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(48),
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        Icon(Icons.storefront_outlined, size: 48, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        const Text(
                          'Nenhum barbeiro ou unidade encontrado.',
                          style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Tente alterar os termos de busca ou o filtro de unidade.',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  );
                }

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final crossCount = constraints.maxWidth > 900
                        ? 3
                        : (constraints.maxWidth > 560 ? 2 : 1);
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossCount,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        mainAxisExtent: 310,
                      ),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final b = filtered[index];
                        return AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  AppAvatar(url: b.avatarUrl, name: b.name, size: 48),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          b.name,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
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
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: ThemeColors.primary.withValues(alpha: 0.12),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                b.neighborhood,
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: ThemeColors.primary,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Shop & Address Info
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.storefront, size: 14, color: Colors.grey),
                                  const SizedBox(width: 6),
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
                              const SizedBox(height: 4),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                                  const SizedBox(width: 6),
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
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.access_time, size: 14, color: Colors.grey),
                                  const SizedBox(width: 6),
                                  Text(
                                    b.workingHours,
                                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                                  ),
                                  const Spacer(),
                                  InkWell(
                                    onTap: () => _openWhatsApp(b.phone),
                                    borderRadius: BorderRadius.circular(4),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.chat, size: 13, color: ThemeColors.success),
                                          const SizedBox(width: 4),
                                          Text(
                                            b.phone,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: ThemeColors.success,
                                              decoration: TextDecoration.underline,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),

                              // Specialties badges
                              Wrap(
                                spacing: 4,
                                runSpacing: 4,
                                children: b.specialties.take(3).map((s) => AppBadge(label: s)).toList(),
                              ),
                              const Spacer(),

                              // Action Button
                              SizedBox(
                                width: double.infinity,
                                child: AppButton(
                                  label: 'Agendar com ${b.name.split(' ').first}',
                                  icon: const Icon(Icons.calendar_today, size: 14),
                                  height: 38,
                                  onPressed: () => _openBookingWizard(b),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
