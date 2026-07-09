class Funcionario {
  final String id;
  final String name;
  final String avatarUrl;
  final String cargo;
  final String phone;
  final String email;
  final String cpf;
  final List<String> specialties;
  final double commissionRate; // e.g. 0.3 = 30%
  final String horarioTrabalho; // e.g. '09:00 - 18:00'
  final List<String> diasDisponiveis;
  final List<String> folgas;
  final bool status; // true = Ativo, false = Inativo
  final double rating;

  const Funcionario({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.cargo,
    required this.phone,
    required this.email,
    required this.cpf,
    required this.specialties,
    required this.commissionRate,
    required this.horarioTrabalho,
    required this.diasDisponiveis,
    required this.folgas,
    required this.status,
    this.rating = 5.0,
  });

  Funcionario copyWith({
    String? id,
    String? name,
    String? avatarUrl,
    String? cargo,
    String? phone,
    String? email,
    String? cpf,
    List<String>? specialties,
    double? commissionRate,
    String? horarioTrabalho,
    List<String>? diasDisponiveis,
    List<String>? folgas,
    bool? status,
    double? rating,
  }) {
    return Funcionario(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      cargo: cargo ?? this.cargo,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      cpf: cpf ?? this.cpf,
      specialties: specialties ?? this.specialties,
      commissionRate: commissionRate ?? this.commissionRate,
      horarioTrabalho: horarioTrabalho ?? this.horarioTrabalho,
      diasDisponiveis: diasDisponiveis ?? this.diasDisponiveis,
      folgas: folgas ?? this.folgas,
      status: status ?? this.status,
      rating: rating ?? this.rating,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'avatarUrl': avatarUrl,
        'cargo': cargo,
        'phone': phone,
        'email': email,
        'cpf': cpf,
        'specialties': specialties,
        'commissionRate': commissionRate,
        'horarioTrabalho': horarioTrabalho,
        'diasDisponiveis': diasDisponiveis,
        'folgas': folgas,
        'status': status,
        'rating': rating,
      };

  factory Funcionario.fromJson(Map<String, dynamic> json) => Funcionario(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        avatarUrl: json['avatarUrl'] ?? '',
        cargo: json['cargo'] ?? '',
        phone: json['phone'] ?? '',
        email: json['email'] ?? '',
        cpf: json['cpf'] ?? '',
        specialties: List<String>.from(json['specialties'] ?? []),
        commissionRate: (json['commissionRate'] as num?)?.toDouble() ?? 0.3,
        horarioTrabalho: json['horarioTrabalho'] ?? '09:00 - 18:00',
        diasDisponiveis: List<String>.from(json['diasDisponiveis'] ?? []),
        folgas: List<String>.from(json['folgas'] ?? []),
        status: json['status'] ?? true,
        rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      );
}
