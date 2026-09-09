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
}
