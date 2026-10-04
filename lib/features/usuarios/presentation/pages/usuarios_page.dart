import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:barber_osbao/features/usuarios/application/users_controller.dart';
import 'package:barber_osbao/packages/core/models/system_user.dart';
import 'package:barber_osbao/packages/core/auth/application/auth_controller.dart';
import 'package:barber_osbao/packages/core/utils/app_masks.dart';
import 'package:barber_osbao/packages/design_system/molecules/app_input.dart';
import 'package:barber_osbao/packages/design_system/theme/theme_colors.dart';

class UsuariosPage extends ConsumerStatefulWidget {
  const UsuariosPage({super.key});

  @override
  ConsumerState<UsuariosPage> createState() => _UsuariosPageState();
}

class _UsuariosPageState extends ConsumerState<UsuariosPage> {
  final _searchController = TextEditingController();
  String _selectedRoleFilter = 'all';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openCreateOrEditUserModal([SystemUser? user]) {
    final nameController = TextEditingController(text: user?.name ?? '');
    final emailController = TextEditingController(text: user?.email ?? '');
    final phoneController = TextEditingController(text: user?.phone ?? '');
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    String selectedRole = user?.role ?? 'client';

    final formKey = GlobalKey<FormState>();
    bool isSaving = false;
    bool obscurePassword = true;
    bool obscureConfirm = true;

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            backgroundColor: ThemeColors.darkSurface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: ThemeColors.darkBorder),
            ),
            title: Row(
              children: [
                const Icon(Icons.manage_accounts, color: ThemeColors.primary, size: 24),
                const SizedBox(width: 10),
                Text(
                  user == null ? 'Cadastrar Novo Usuário' : 'Editar Usuário',
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: SizedBox(
              width: 500,
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Nome
                      AppInput(
                        label: 'Nome Completo *',
                        placeholder: 'Ex: Maria Oliveira',
                        controller: nameController,
                        prefixIcon: const Icon(Icons.person_outline, color: Colors.white38, size: 20),
                        validator: (value) {
                          if (value == null || value.trim().length < 2) {
                            return 'O nome deve ter no mínimo 2 caracteres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // E-mail
                      AppInput(
                        label: 'E-mail de Acesso *',
                        placeholder: 'usuario@exemplo.com',
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: const Icon(Icons.email_outlined, color: Colors.white38, size: 20),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Informe o e-mail do usuário';
                          }
                          final email = value.trim();
                          if (!email.contains('@') || !email.contains('.')) {
                            return 'Formato de e-mail inválido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // Celular / WhatsApp
                      AppInput(
                        label: 'Telefone / Celular (opcional)',
                        placeholder: '(42) 99999-9999',
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [PhoneInputFormatter()],
                        prefixIcon: const Icon(Icons.phone_outlined, color: Colors.white38, size: 20),
                      ),
                      const SizedBox(height: 14),

                      // Perfil (Role)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Perfil de Acesso (Cargo) *',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white70),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: ThemeColors.darkSurface,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: ThemeColors.darkBorder),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: selectedRole,
                                isExpanded: true,
                                dropdownColor: ThemeColors.darkSurface,
                                items: const [
                                  DropdownMenuItem(
                                    value: 'client',
                                    child: Row(
                                      children: [
                                        Icon(Icons.person, size: 18, color: Colors.purpleAccent),
                                        SizedBox(width: 10),
                                        Text('Cliente (Agendamentos e Perfil)', style: TextStyle(color: Colors.white)),
                                      ],
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'barber',
                                    child: Row(
                                      children: [
                                        Icon(Icons.content_cut, size: 18, color: Colors.blueAccent),
                                        SizedBox(width: 10),
                                        Text('Barbeiro (Agenda e Atendimentos)', style: TextStyle(color: Colors.white)),
                                      ],
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'admin',
                                    child: Row(
                                      children: [
                                        Icon(Icons.shield, size: 18, color: ThemeColors.primary),
                                        SizedBox(width: 10),
                                        Text('Admin Supremo (Acesso Total ao Gestor)', style: TextStyle(color: Colors.white)),
                                      ],
                                    ),
                                  ),
                                ],
                                onChanged: (val) {
                                  if (val != null) setDialogState(() => selectedRole = val);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Senha
                      AppInput(
                        label: user == null ? 'Senha de Acesso *' : 'Nova Senha (deixe em branco para manter atual)',
                        placeholder: user == null ? 'Mínimo de 6 caracteres' : 'Opcional na edição',
                        controller: passwordController,
                        obscureText: obscurePassword,
                        prefixIcon: const Icon(Icons.lock_outline, color: Colors.white38, size: 20),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            color: Colors.white38,
                            size: 18,
                          ),
                          onPressed: () => setDialogState(() => obscurePassword = !obscurePassword),
                        ),
                        validator: (value) {
                          if (user == null) {
                            if (value == null || value.length < 6) {
                              return 'A senha deve conter no mínimo 6 caracteres';
                            }
                          } else {
                            if (value != null && value.isNotEmpty && value.length < 6) {
                              return 'A nova senha deve ter no mínimo 6 caracteres';
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // Confirmação de Senha
                      AppInput(
                        label: 'Confirmar Senha',
                        placeholder: 'Repita a senha digitada',
                        controller: confirmPasswordController,
                        obscureText: obscureConfirm,
                        prefixIcon: const Icon(Icons.lock_reset, color: Colors.white38, size: 20),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            color: Colors.white38,
                            size: 18,
                          ),
                          onPressed: () => setDialogState(() => obscureConfirm = !obscureConfirm),
                        ),
                        validator: (value) {
                          if (passwordController.text.isNotEmpty) {
                            if (value != passwordController.text) {
                              return 'As senhas não coincidem';
                            }
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: isSaving ? null : () => Navigator.of(dialogCtx).pop(),
                child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeColors.primary,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                onPressed: isSaving
                    ? null
                    : () async {
                        if (!formKey.currentState!.validate()) return;

                        setDialogState(() => isSaving = true);
                        try {
                          if (user == null) {
                            await ref.read(usersProvider.notifier).createUser(
                                  name: nameController.text.trim(),
                                  email: emailController.text.trim().toLowerCase(),
                                  password: passwordController.text,
                                  phone: phoneController.text.trim().isNotEmpty ? phoneController.text.trim() : null,
                                  role: selectedRole,
                                );
                          } else {
                            final updateData = <String, dynamic>{
                              'name': nameController.text.trim(),
                              'email': emailController.text.trim().toLowerCase(),
                              'phone': phoneController.text.trim(),
                              'role': selectedRole,
                            };
                            if (passwordController.text.isNotEmpty) {
                              updateData['password'] = passwordController.text;
                            }
                            await ref.read(usersProvider.notifier).updateUser(user.id, updateData);
                          }

                          if (dialogCtx.mounted) {
                            Navigator.of(dialogCtx).pop();
                          }
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  user == null ? 'Usuário cadastrado com sucesso!' : 'Usuário atualizado com sucesso!',
                                ),
                                backgroundColor: ThemeColors.success,
                              ),
                            );
                          }
                        } catch (e) {
                          setDialogState(() => isSaving = false);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Erro: ${e.toString().replaceAll('Exception:', '').trim()}'),
                                backgroundColor: ThemeColors.danger,
                              ),
                            );
                          }
                        }
                      },
                child: isSaving
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                    : Text(user == null ? 'Cadastrar Usuário' : 'Salvar Alterações', style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmDeleteUser(SystemUser user) {
    final currentUser = ref.read(authControllerProvider).value;
    if (currentUser?.id == user.id) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Você não pode excluir sua própria conta de administrador em uso.'),
          backgroundColor: ThemeColors.warning,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ThemeColors.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: ThemeColors.darkBorder),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: ThemeColors.danger, size: 24),
            SizedBox(width: 10),
            Text('Excluir Usuário', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'Tem certeza que deseja remover o usuário "${user.name}" (${user.email})? Esta ação não pode ser desfeita.',
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeColors.danger,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                await ref.read(usersProvider.notifier).deleteUser(user.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Usuário removido com sucesso!'),
                      backgroundColor: ThemeColors.success,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erro ao remover: ${e.toString().replaceAll('Exception:', '').trim()}'),
                      backgroundColor: ThemeColors.danger,
                    ),
                  );
                }
              }
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return ThemeColors.primary;
      case 'barber':
        return Colors.blueAccent;
      default:
        return Colors.purpleAccent;
    }
  }

  IconData _getRoleIcon(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Icons.shield;
      case 'barber':
        return Icons.content_cut;
      default:
        return Icons.person;
    }
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(usersProvider);

    return Scaffold(
      backgroundColor: ThemeColors.darkBg,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Usuários do Sistema',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Gerencie logins, senhas e perfis de administradores, equipe e clientes',
                      style: TextStyle(color: Colors.white54, fontSize: 13),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeColors.primary,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => _openCreateOrEditUserModal(),
                  icon: const Icon(Icons.person_add, size: 20),
                  label: const Text('Novo Usuário', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Métricas Cards
            usersAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (err, stack) => const SizedBox.shrink(),
              data: (users) {
                final total = users.length;
                final admins = users.where((u) => u.role == 'admin').length;
                final barbers = users.where((u) => u.role == 'barber').length;
                final clients = users.where((u) => u.role == 'client').length;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Row(
                    children: [
                      _buildMetricCard('Total Usuários', total.toString(), Icons.people, Colors.white70),
                      const SizedBox(width: 14),
                      _buildMetricCard('Admins Supremos', admins.toString(), Icons.shield, ThemeColors.primary),
                      const SizedBox(width: 14),
                      _buildMetricCard('Barbeiros', barbers.toString(), Icons.content_cut, Colors.blueAccent),
                      const SizedBox(width: 14),
                      _buildMetricCard('Clientes', clients.toString(), Icons.person, Colors.purpleAccent),
                    ],
                  ),
                );
              },
            ),

            // Filtros e Busca
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ThemeColors.darkSurface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: ThemeColors.darkBorder),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: AppInput(
                      label: '',
                      placeholder: 'Buscar por nome, e-mail ou celular...',
                      controller: _searchController,
                      prefixIcon: const Icon(Icons.search, color: Colors.white38, size: 20),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildFilterChip('all', 'Todos'),
                      _buildFilterChip('admin', 'Admins'),
                      _buildFilterChip('barber', 'Barbeiros'),
                      _buildFilterChip('client', 'Clientes'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Lista de Usuários
            usersAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(40.0),
                  child: CircularProgressIndicator(color: ThemeColors.primary),
                ),
              ),
              error: (err, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Text('Erro ao carregar usuários: $err', style: const TextStyle(color: ThemeColors.danger)),
                ),
              ),
              data: (users) {
                final query = _searchController.text.trim().toLowerCase();
                final filtered = users.where((u) {
                  final matchesRole = _selectedRoleFilter == 'all' || u.role == _selectedRoleFilter;
                  final matchesQuery = query.isEmpty ||
                      u.name.toLowerCase().contains(query) ||
                      u.email.toLowerCase().contains(query) ||
                      u.phone.contains(query);
                  return matchesRole && matchesQuery;
                }).toList();

                if (filtered.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(48),
                    decoration: BoxDecoration(
                      color: ThemeColors.darkSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: ThemeColors.darkBorder),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.person_off_outlined, size: 48, color: Colors.white24),
                        const SizedBox(height: 16),
                        const Text(
                          'Nenhum usuário encontrado',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Tente alterar os filtros ou cadastre um novo usuário com o botão acima.',
                          style: TextStyle(color: Colors.white54, fontSize: 13),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filtered.length,
                  separatorBuilder: (ctx, index) => const SizedBox(height: 12),
                  itemBuilder: (ctx, idx) {
                    final u = filtered[idx];
                    final roleColor = _getRoleColor(u.role);
                    final roleIcon = _getRoleIcon(u.role);
                    final formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(u.createdAt);

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: ThemeColors.darkSurface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: ThemeColors.darkBorder),
                      ),
                      child: Row(
                        children: [
                          // Avatar com Iniciais
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: roleColor.withValues(alpha: 0.15),
                            child: Text(
                              u.name.isNotEmpty ? u.name[0].toUpperCase() : 'U',
                              style: TextStyle(color: roleColor, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Dados Principais
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      u.name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    // Badge do Perfil
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: roleColor.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: roleColor.withValues(alpha: 0.4)),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(roleIcon, size: 12, color: roleColor),
                                          const SizedBox(width: 4),
                                          Text(
                                            u.roleLabel,
                                            style: TextStyle(color: roleColor, fontSize: 11, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.email_outlined, size: 14, color: Colors.white38),
                                    const SizedBox(width: 6),
                                    Text(u.email, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                                    if (u.phone.isNotEmpty) ...[
                                      const SizedBox(width: 16),
                                      const Icon(Icons.phone_outlined, size: 14, color: Colors.white38),
                                      const SizedBox(width: 6),
                                      Text(u.phone, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Data de Cadastro
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text('Criado em', style: TextStyle(color: Colors.white38, fontSize: 11)),
                                const SizedBox(height: 2),
                                Text(formattedDate, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                              ],
                            ),
                          ),

                          // Ações
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, color: Colors.white54, size: 20),
                                tooltip: 'Editar Usuário',
                                onPressed: () => _openCreateOrEditUserModal(u),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: ThemeColors.danger, size: 20),
                                tooltip: 'Excluir Usuário',
                                onPressed: () => _confirmDeleteUser(u),
                              ),
                            ],
                          ),
                        ],
                      ),
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

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ThemeColors.darkSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: ThemeColors.darkBorder),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String role, String label) {
    final isSelected = _selectedRoleFilter == role;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _selectedRoleFilter = role),
      selectedColor: ThemeColors.primary.withValues(alpha: 0.2),
      backgroundColor: ThemeColors.darkSurface,
      labelStyle: TextStyle(
        color: isSelected ? ThemeColors.primary : Colors.white70,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      side: BorderSide(color: isSelected ? ThemeColors.primary : ThemeColors.darkBorder),
    );
  }
}
