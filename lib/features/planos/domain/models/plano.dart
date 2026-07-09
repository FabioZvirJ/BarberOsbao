class Plano {
  final String id;
  final String name;
  final double price;
  final String period; // 'mensal', 'trimestral', 'semestral', 'anual'
  final List<String> benefits;
  final int cutsCount; // quantity of cuts
  final double productDiscount; // discounts e.g. 0.10 = 10%
  final bool status; // true = Ativo, false = Inativo
  final bool recommended; // Destacar plano

  const Plano({
    required this.id,
    required this.name,
    required this.price,
    required this.period,
    required this.benefits,
    required this.cutsCount,
    required this.productDiscount,
    required this.status,
    required this.recommended,
  });

  Plano copyWith({
    String? id,
    String? name,
    double? price,
    String? period,
    List<String>? benefits,
    int? cutsCount,
    double? productDiscount,
    bool? status,
    bool? recommended,
  }) {
    return Plano(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      period: period ?? this.period,
      benefits: benefits ?? this.benefits,
      cutsCount: cutsCount ?? this.cutsCount,
      productDiscount: productDiscount ?? this.productDiscount,
      status: status ?? this.status,
      recommended: recommended ?? this.recommended,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'period': period,
        'benefits': benefits,
        'cutsCount': cutsCount,
        'productDiscount': productDiscount,
        'status': status,
        'recommended': recommended,
      };

  factory Plano.fromJson(Map<String, dynamic> json) => Plano(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        price: (json['price'] as num?)?.toDouble() ?? 0.0,
        period: json['period'] ?? 'mensal',
        benefits: List<String>.from(json['benefits'] ?? []),
        cutsCount: json['cutsCount'] ?? 0,
        productDiscount: (json['productDiscount'] as num?)?.toDouble() ?? 0.0,
        status: json['status'] ?? true,
        recommended: json['recommended'] ?? false,
      );
}
