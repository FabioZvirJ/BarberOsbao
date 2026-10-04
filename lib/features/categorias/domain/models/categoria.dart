class Categoria {
  final String id;
  final String nome;
  final String tipo; // 'servicos', 'produtos', 'planos'

  const Categoria({
    required this.id,
    required this.nome,
    required this.tipo,
  });

  Categoria copyWith({
    String? id,
    String? nome,
    String? tipo,
  }) {
    return Categoria(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      tipo: tipo ?? this.tipo,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nome': nome,
        'name': nome,
        'tipo': tipo,
      };

  factory Categoria.fromJson(Map<String, dynamic> json) => Categoria(
        id: json['id'] ?? '',
        nome: json['nome'] ?? json['name'] ?? '',
        tipo: json['tipo'] ?? json['iconName'] ?? 'servicos',
      );
}
