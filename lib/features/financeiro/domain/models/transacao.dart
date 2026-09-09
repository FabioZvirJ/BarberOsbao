class TransacaoFinanceira {
  final String id;
  final String type; // 'income', 'expense'
  final String description;
  final double amount;
  final String category;
  final String date; // "YYYY-MM-DD"
  final String paymentMethod;
  final String status; // 'paid', 'pending'

  const TransacaoFinanceira({
    required this.id,
    required this.type,
    required this.description,
    required this.amount,
    required this.category,
    required this.date,
    required this.paymentMethod,
    required this.status,
  });

  TransacaoFinanceira copyWith({
    String? id,
    String? type,
    String? description,
    double? amount,
    String? category,
    String? date,
    String? paymentMethod,
    String? status,
  }) {
    return TransacaoFinanceira(
      id: id ?? this.id,
      type: type ?? this.type,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'description': description,
        'amount': amount,
        'category': category,
        'date': date,
        'paymentMethod': paymentMethod,
        'status': status,
      };

  factory TransacaoFinanceira.fromJson(Map<String, dynamic> json) => TransacaoFinanceira(
        id: json['id'] ?? '',
        type: json['type'] ?? 'income',
        description: json['description'] ?? '',
        amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
        category: json['category'] ?? '',
        date: json['date'] ?? '',
        paymentMethod: json['paymentMethod'] ?? '',
        status: json['status'] ?? 'paid',
      );
}
