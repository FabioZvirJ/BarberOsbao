class SystemUser {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String? avatarUrl;
  final DateTime createdAt;

  SystemUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.avatarUrl,
    required this.createdAt,
  });

  factory SystemUser.fromJson(Map<String, dynamic> json) {
    return SystemUser(
      id: json['id']?.toString() ?? '',
      name: (json['name']?.toString() ?? 'Sem nome').trim(),
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      role: (json['role']?.toString() ?? 'client').toLowerCase(),
      avatarUrl: json['avatarUrl']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'role': role,
        'avatarUrl': avatarUrl,
        'createdAt': createdAt.toIso8601String(),
      };

  String get roleLabel {
    switch (role.toLowerCase()) {
      case 'admin':
        return 'Admin Supremo';
      case 'barber':
        return 'Barbeiro';
      default:
        return 'Cliente';
    }
  }
}

