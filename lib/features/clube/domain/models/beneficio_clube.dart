class BeneficioClube {
  final String id;
  final String name;
  final String description;
  final int pointsRequired;
  final String benefitValue;
  final String imageUrl;
  final String expirationDate; // "YYYY-MM-DD"
  final bool active;

  const BeneficioClube({
    required this.id,
    required this.name,
    required this.description,
    required this.pointsRequired,
    required this.benefitValue,
    required this.imageUrl,
    required this.expirationDate,
    required this.active,
  });

  BeneficioClube copyWith({
    String? id,
    String? name,
    String? description,
    int? pointsRequired,
    String? benefitValue,
    String? imageUrl,
    String? expirationDate,
    bool? active,
  }) {
    return BeneficioClube(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      pointsRequired: pointsRequired ?? this.pointsRequired,
      benefitValue: benefitValue ?? this.benefitValue,
      imageUrl: imageUrl ?? this.imageUrl,
      expirationDate: expirationDate ?? this.expirationDate,
      active: active ?? this.active,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'pointsRequired': pointsRequired,
        'benefitValue': benefitValue,
        'imageUrl': imageUrl,
        'expirationDate': expirationDate,
        'active': active,
      };

  factory BeneficioClube.fromJson(Map<String, dynamic> json) => BeneficioClube(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        description: json['description'] ?? '',
        pointsRequired: json['pointsRequired'] ?? 0,
        benefitValue: json['benefitValue'] ?? '',
        imageUrl: json['imageUrl'] ?? '',
        expirationDate: json['expirationDate'] ?? '',
        active: json['active'] ?? true,
      );
}
