class ItemComanda {
  final String id;
  final String name;
  final String type; // 'service' or 'product'
  final double price;
  final int quantity;
  final String? professionalId;
  final String? professionalName;

  const ItemComanda({
    required this.id,
    required this.name,
    required this.type,
    required this.price,
    this.quantity = 1,
    this.professionalId,
    this.professionalName,
  });

  double get total => price * quantity;

  ItemComanda copyWith({
    String? id,
    String? name,
    String? type,
    double? price,
    int? quantity,
    String? professionalId,
    String? professionalName,
  }) {
    return ItemComanda(
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

  factory ItemComanda.fromJson(Map<String, dynamic> json) => ItemComanda(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        type: json['type'] ?? 'service',
        price: (json['price'] as num?)?.toDouble() ?? 0.0,
        quantity: json['quantity'] ?? 1,
        professionalId: json['professionalId'],
        professionalName: json['professionalName'],
      );
}

class PagamentoSplit {
  final String method; // 'money', 'pix', 'credit', 'debit'
  final double amount;

  const PagamentoSplit({
    required this.method,
    required this.amount,
  });

  Map<String, dynamic> toJson() => {
        'method': method,
        'amount': amount,
      };

  factory PagamentoSplit.fromJson(Map<String, dynamic> json) => PagamentoSplit(
        method: json['method'] ?? 'money',
        amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      );
}

class Comanda {
  final String id;
  final String? clienteId;
  final String clienteNome;
  final List<ItemComanda> itens;
  final String status; // 'open', 'paid', 'cancelled'
  final double discount;
  final List<PagamentoSplit> pagamentos;
  final String date; // "YYYY-MM-DD"
  final String time; // "HH:MM"

  const Comanda({
    required this.id,
    this.clienteId,
    required this.clienteNome,
    required this.itens,
    required this.status,
    this.discount = 0.0,
    required this.pagamentos,
    required this.date,
    required this.time,
  });

  double get subtotal => itens.fold(0.0, (sum, item) => sum + item.total);
  double get total => subtotal - discount;

  Comanda copyWith({
    String? id,
    String? clienteId,
    String? clienteNome,
    List<ItemComanda>? itens,
    String? status,
    double? discount,
    List<PagamentoSplit>? pagamentos,
    String? date,
    String? time,
  }) {
    return Comanda(
      id: id ?? this.id,
      clienteId: clienteId ?? this.clienteId,
      clienteNome: clienteNome ?? this.clienteNome,
      itens: itens ?? this.itens,
      status: status ?? this.status,
      discount: discount ?? this.discount,
      pagamentos: pagamentos ?? this.pagamentos,
      date: date ?? this.date,
      time: time ?? this.time,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'clienteId': clienteId,
        'clienteNome': clienteNome,
        'itens': itens.map((i) => i.toJson()).toList(),
        'status': status,
        'discount': discount,
        'pagamentos': pagamentos.map((p) => p.toJson()).toList(),
        'date': date,
        'time': time,
      };

  factory Comanda.fromJson(Map<String, dynamic> json) => Comanda(
        id: json['id'] ?? '',
        clienteId: json['clienteId'],
        clienteNome: json['clienteNome'] ?? '',
        itens: (json['itens'] as List?)?.map((i) => ItemComanda.fromJson(i)).toList() ?? [],
        status: json['status'] ?? 'open',
        discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
        pagamentos: (json['pagamentos'] as List?)?.map((p) => PagamentoSplit.fromJson(p)).toList() ?? [],
        date: json['date'] ?? '',
        time: json['time'] ?? '',
      );
}
