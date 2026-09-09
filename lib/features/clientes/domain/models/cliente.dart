class Cliente {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String avatarUrl;
  final String nascimento;
  final String plano;
  final String ultimaVisita;
  final double totalGasto;
  final String observacoes;
  final String status; // 'active', 'inactive'

  const Cliente({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.avatarUrl,
    required this.nascimento,
    required this.plano,
    required this.ultimaVisita,
    required this.totalGasto,
    required this.observacoes,
    required this.status,
  });

  Cliente copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? avatarUrl,
    String? nascimento,
    String? plano,
    String? ultimaVisita,
    double? totalGasto,
    String? observacoes,
    String? status,
  }) {
    return Cliente(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      nascimento: nascimento ?? this.nascimento,
      plano: plano ?? this.plano,
      ultimaVisita: ultimaVisita ?? this.ultimaVisita,
      totalGasto: totalGasto ?? this.totalGasto,
      observacoes: observacoes ?? this.observacoes,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'avatarUrl': avatarUrl,
        'nascimento': nascimento,
        'plano': plano,
        'ultimaVisita': ultimaVisita,
        'totalGasto': totalGasto,
        'observacoes': observacoes,
        'status': status,
      };

  factory Cliente.fromJson(Map<String, dynamic> json) => Cliente(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        email: json['email'] ?? '',
        phone: json['phone'] ?? '',
        avatarUrl: json['avatarUrl'] ?? '',
        nascimento: json['nascimento'] ?? '',
        plano: json['plano'] ?? '',
        ultimaVisita: json['ultimaVisita'] ?? '',
        totalGasto: (json['totalGasto'] as num?)?.toDouble() ?? 0.0,
        observacoes: json['observacoes'] ?? '',
        status: json['status'] ?? 'active',
      );
}
