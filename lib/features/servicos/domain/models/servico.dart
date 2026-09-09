class Servico {
  final String id;
  final String name;
  final String category;
  final String description;
  final double price;
  final int durationMinutes;
  final String imageUrl;
  final String colorHex;
  final bool status; // true = Ativo, false = Inativo

  const Servico({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.price,
    required this.durationMinutes,
    required this.imageUrl,
    required this.colorHex,
    required this.status,
  });

  Servico copyWith({
    String? id,
    String? name,
    String? category,
    String? description,
    double? price,
    int? durationMinutes,
    String? imageUrl,
    String? colorHex,
    bool? status,
  }) {
    return Servico(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      price: price ?? this.price,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      imageUrl: imageUrl ?? this.imageUrl,
      colorHex: colorHex ?? this.colorHex,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'description': description,
        'price': price,
        'durationMinutes': durationMinutes,
        'imageUrl': imageUrl,
        'colorHex': colorHex,
        'status': status,
      };

  factory Servico.fromJson(Map<String, dynamic> json) => Servico(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        category: json['category'] ?? '',
        description: json['description'] ?? '',
        price: (json['price'] as num?)?.toDouble() ?? 0.0,
        durationMinutes: json['durationMinutes'] ?? 30,
        imageUrl: json['imageUrl'] ?? '',
        colorHex: json['colorHex'] ?? 'C89B3C',
        status: json['status'] ?? true,
      );
}
