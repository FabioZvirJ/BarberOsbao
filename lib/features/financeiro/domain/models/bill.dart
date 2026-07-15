class PaymentSplit {
  final String method; // 'pix', 'credit', 'debit', 'money'
  final double amount;

  const PaymentSplit({
    required this.method,
    required this.amount,
  });

  Map<String, dynamic> toJson() => {
        'method': method,
        'amount': amount,
      };

  factory PaymentSplit.fromJson(Map<String, dynamic> json) => PaymentSplit(
        method: json['method'] ?? 'money',
        amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      );
}

class BillItem {
  final String id;
  final String name;
  final String type; // 'service' or 'product'
  final double price;
  final int quantity;
  final String? professionalId;
  final String? professionalName;

  const BillItem({
    required this.id,
    required this.name,
    required this.type,
    required this.price,
    this.quantity = 1,
    this.professionalId,
    this.professionalName,
  });

  double get total => price * quantity;

  BillItem copyWith({
    String? id,
    String? name,
    String? type,
    double? price,
    int? quantity,
    String? professionalId,
    String? professionalName,
  }) {
    return BillItem(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      professionalId: professionalId ?? this.professionalId,
      professionalName: professionalName ?? this.professionalName,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type,
        'price': price,
        'quantity': quantity,
        'professionalId': professionalId,
        'professionalName': professionalName,
      };

  factory BillItem.fromJson(Map<String, dynamic> json) => BillItem(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        type: json['type'] ?? 'service',
        price: (json['price'] as num?)?.toDouble() ?? 0.0,
        quantity: json['quantity'] ?? 1,
        professionalId: json['professionalId'],
        professionalName: json['professionalName'],
      );
}

class Bill {
  final String id;
  final String clientName;
  final List<BillItem> items;
  final String status; // 'open', 'paid', 'cancelled'
  final List<PaymentSplit> payments;
  final String date; // YYYY-MM-DD
  final String time; // HH:MM
  final double discount;

  const Bill({
    required this.id,
    required this.clientName,
    required this.items,
    required this.status,
    required this.payments,
    required this.date,
    required this.time,
    this.discount = 0.0,
  });

  double get subtotal => items.fold(0.0, (sum, item) => sum + item.total);
  double get total => subtotal - discount;

  Bill copyWith({
    String? id,
    String? clientName,
    List<BillItem>? items,
    String? status,
    List<PaymentSplit>? payments,
    String? date,
    String? time,
    double? discount,
  }) {
    return Bill(
      id: id ?? this.id,
      clientName: clientName ?? this.clientName,
      items: items ?? this.items,
      status: status ?? this.status,
      payments: payments ?? this.payments,
      date: date ?? this.date,
      time: time ?? this.time,
      discount: discount ?? this.discount,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'clientName': clientName,
        'items': items.map((x) => x.toJson()).toList(),
        'status': status,
        'payments': payments.map((x) => x.toJson()).toList(),
        'date': date,
        'time': time,
        'discount': discount,
      };

  factory Bill.fromJson(Map<String, dynamic> json) => Bill(
        id: json['id'] ?? '',
        clientName: json['clientName'] ?? '',
        items: (json['items'] as List?)?.map((x) => BillItem.fromJson(x)).toList() ?? [],
        status: json['status'] ?? 'open',
        payments: (json['payments'] as List?)?.map((x) => PaymentSplit.fromJson(x)).toList() ?? [],
        date: json['date'] ?? '',
        time: json['time'] ?? '',
        discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      );
}
