import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:barber_osbao/packages/design_system/theme/theme_colors.dart';
import 'package:barber_osbao/packages/design_system/layouts/app_page.dart';
import 'package:barber_osbao/packages/design_system/layouts/app_section.dart';
import 'package:barber_osbao/packages/design_system/organisms/app_table.dart';
import 'package:barber_osbao/packages/design_system/molecules/app_search_bar.dart';
import 'package:barber_osbao/packages/design_system/atoms/app_avatar.dart';
import 'package:barber_osbao/packages/design_system/atoms/app_button.dart';
import 'package:barber_osbao/packages/core/shared/repositories/customer_repository.dart';

class ClientesPage extends ConsumerStatefulWidget {
  const ClientesPage({super.key});

  @override
  ConsumerState<ClientesPage> createState() => _ClientesPageState();
}

class _ClientesPageState extends ConsumerState<ClientesPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customersState = ref.watch(customersListProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppPage(
      title: 'Clientes',
      userName: 'Fábio Zvir',
      userAvatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&width=150',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: AppSearchBar(
                  controller: _searchController,
                  placeholder: 'Pesquisar por nome, email ou telefone...',
                  onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
                  onClear: () => setState(() => _searchQuery = ''),
                ),
              ),
              const SizedBox(width: 16),
              AppButton(
                label: 'Novo Cliente',
                icon: const Icon(Icons.add, size: 16),
                onPressed: () {
                  // Dialog or bottom sheet triggers for add customer
                },
              ),
            ],
          ),
          const SizedBox(height: 32),

          AppSection(
            title: 'Base de Clientes',
            subtitle: 'Lista de clientes cadastrados no sistema',
            child: customersState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => const Center(child: Text('Erro ao carregar clientes.')),
              data: (list) {
                final filtered = list.where((c) {
                  return c.name.toLowerCase().contains(_searchQuery) ||
                      c.email.toLowerCase().contains(_searchQuery) ||
                      c.phone.contains(_searchQuery);
                }).toList();

                if (filtered.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(40),
                    alignment: Alignment.center,
                    child: Text(
                      'Nenhum cliente encontrado.',
                      style: TextStyle(color: isDark ? Colors.white30 : Colors.grey),
                    ),
                  );
                }

                return AppTable(
                  columns: [
                    AppTableColumn(label: 'AVATAR', width: 60),
                    AppTableColumn(label: 'NOME'),
                    AppTableColumn(label: 'E-MAIL'),
                    AppTableColumn(label: 'TELEFONE'),
                    AppTableColumn(label: 'AÇÕES', width: 100),
                  ],
                  rows: filtered.map((cust) {
                    return AppTableRow(
                      cells: [
                        AppAvatar(url: cust.avatarUrl, size: 36),
                        Text(cust.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(cust.email),
                        Text(cust.phone),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 18),
                              onPressed: () {},
                              tooltip: 'Editar',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 18, color: ThemeColors.danger),
                              onPressed: () {},
                              tooltip: 'Remover',
                            ),
                          ],
                        ),
                      ],
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0, curve: Curves.easeOut),
    );
  }
}
