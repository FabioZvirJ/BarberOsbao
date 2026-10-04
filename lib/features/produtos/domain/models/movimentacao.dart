class MovimentacaoEstoque {
  final String id;
  final String productId;
  final String productName;
  final String type; // 'Entrada', 'Saída', 'Inventário'
  final int qty;
  final String reason;
  final String date;
  final String user;

  const MovimentacaoEstoque({
    required this.id,
    required this.productId,
    required this.productName,
    required this.type,
    required this.qty,
    required this.reason,
    required this.date,
    required this.user,
  });

  MovimentacaoEstoque copyWith({
    String? id,
    String? productId,
    String? productName,
    String? type,
    int? qty,
    String? reason,
    String? date,
    String? user,
  }) {
    return MovimentacaoEstoque(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      type: type ?? this.type,
      qty: qty ?? this.qty,
      reason: reason ?? this.reason,
      date: date ?? this.date,
      user: user ?? this.user,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'productId': productId,
        'productName': productName,
        'type': type,
        'qty': qty,
        'quantity': qty,
        'reason': reason,
        'date': date,
        'user': user,
        'responsible': user,
      };

  factory MovimentacaoEstoque.fromJson(Map<String, dynamic> json) => MovimentacaoEstoque(
        id: json['id'] ?? '',
        productId: json['productId'] ?? '',
        productName: json['productName'] ?? '',
        type: json['type'] ?? 'Entrada',
        qty: json['qty'] ?? json['quantity'] ?? 0,
        reason: json['reason'] ?? '',
        date: json['date'] ?? '',
        user: json['user'] ?? json['responsible'] ?? '',
      );
}

