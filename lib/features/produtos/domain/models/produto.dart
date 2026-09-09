class Produto {
  final String id;
  final String name;
  final String brand;
  final String category;
  final String supplier;
  final String code;
  final double costPrice;
  final double price;
  final int stock;
  final int minStock;
  final String description;
  final bool status; // true = Ativo, false = Inativo
  final String imageUrl;

  const Produto({
    required this.id,
    required this.name,
    required this.brand,
    required this.category,
    required this.supplier,
    required this.code,
    required this.costPrice,
    required this.price,
    required this.stock,
    required this.minStock,
    required this.description,
    required this.status,
    required this.imageUrl,
  });

  Produto copyWith({
    String? id,
    String? name,
    String? brand,
    String? category,
    String? supplier,
    String? code,
    double? costPrice,
    double? price,
    int? stock,
    int? minStock,
    String? description,
    bool? status,
    String? imageUrl,
  }) {
    return Produto(
      id: id ?? this.id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      category: category ?? this.category,
      supplier: supplier ?? this.supplier,
      code: code ?? this.code,
      costPrice: costPrice ?? this.costPrice,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      minStock: minStock ?? this.minStock,
      description: description ?? this.description,
      status: status ?? this.status,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'brand': brand,
        'category': category,
        'supplier': supplier,
        'code': code,
        'costPrice': costPrice,
        'price': price,
        'stock': stock,
        'minStock': minStock,
        'description': description,
        'status': status,
        'imageUrl': imageUrl,
      };

  factory Produto.fromJson(Map<String, dynamic> json) => Produto(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        brand: json['brand'] ?? '',
        category: json['category'] ?? '',
        supplier: json['supplier'] ?? '',
        code: json['code'] ?? '',
        costPrice: (json['costPrice'] as num?)?.toDouble() ?? 0.0,
        price: (json['price'] as num?)?.toDouble() ?? 0.0,
        stock: json['stock'] ?? 0,
        minStock: json['minStock'] ?? 0,
        description: json['description'] ?? '',
        status: json['status'] ?? true,
        imageUrl: json['imageUrl'] ?? '',
      );
}
