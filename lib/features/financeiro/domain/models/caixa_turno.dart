class MovimentoCaixa {
  final String id;
  final String caixaId;
  final String type; // 'entrada', 'saida', 'sangria', 'suprimento'
  final double amount;
  final String description;
  final String time; // "HH:MM"
  final String user;

  const MovimentoCaixa({
    required this.id,
    required this.caixaId,
    required this.type,
    required this.amount,
    required this.description,
    required this.time,
    required this.user,
  });

  MovimentoCaixa copyWith({
    String? id,
    String? caixaId,
    String? type,
    double? amount,
    String? description,
    String? time,
    String? user,
  }) {
    return MovimentoCaixa(
      id: id ?? this.id,
      caixaId: caixaId ?? this.caixaId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      time: time ?? this.time,
      user: user ?? this.user,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'caixaId': caixaId,
        'type': type,
        'amount': amount,
        'description': description,
        'time': time,
        'user': user,
      };

  factory MovimentoCaixa.fromJson(Map<String, dynamic> json) => MovimentoCaixa(
        id: json['id'] ?? '',
        caixaId: json['caixaId'] ?? '',
        type: json['type'] ?? 'entrada',
        amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
        description: json['description'] ?? '',
        time: json['time'] ?? '',
        user: json['user'] ?? '',
      );
}

class CaixaTurno {
  final String id;
  final String operatorName;
  final String openDate; // "YYYY-MM-DD"
  final String openTime; // "HH:MM"
  final String? closeDate;
  final String? closeTime;
  final double initialBalance;
  final double? finalBalance;
  final double? moneyExpected;
  final double? moneyReported;
  final String status; // 'open', 'closed'

  const CaixaTurno({
    required this.id,
    required this.operatorName,
    required this.openDate,
    required this.openTime,
    this.closeDate,
    this.closeTime,
    required this.initialBalance,
    this.finalBalance,
    this.moneyExpected,
    this.moneyReported,
    required this.status,
  });

  CaixaTurno copyWith({
    String? id,
    String? operatorName,
    String? openDate,
    String? openTime,
    String? closeDate,
    String? closeTime,
    double? initialBalance,
    double? finalBalance,
    double? moneyExpected,
    double? moneyReported,
    String? status,
  }) {
    return CaixaTurno(
      id: id ?? this.id,
      operatorName: operatorName ?? this.operatorName,
      openDate: openDate ?? this.openDate,
      openTime: openTime ?? this.openTime,
      closeDate: closeDate ?? this.closeDate,
      closeTime: closeTime ?? this.closeTime,
      initialBalance: initialBalance ?? this.initialBalance,
      finalBalance: finalBalance ?? this.finalBalance,
      moneyExpected: moneyExpected ?? this.moneyExpected,
      moneyReported: moneyReported ?? this.moneyReported,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'operatorName': operatorName,
        'openDate': openDate,
        'openTime': openTime,
        'closeDate': closeDate,
        'closeTime': closeTime,
        'initialBalance': initialBalance,
        'finalBalance': finalBalance,
        'moneyExpected': moneyExpected,
        'moneyReported': moneyReported,
        'status': status,
      };

  factory CaixaTurno.fromJson(Map<String, dynamic> json) => CaixaTurno(
        id: json['id'] ?? '',
        operatorName: json['operatorName'] ?? '',
        openDate: json['openDate'] ?? '',
        openTime: json['openTime'] ?? '',
        closeDate: json['closeDate'],
        closeTime: json['closeTime'],
        initialBalance: (json['initialBalance'] as num?)?.toDouble() ?? 0.0,
        finalBalance: (json['finalBalance'] as num?)?.toDouble(),
        moneyExpected: (json['moneyExpected'] as num?)?.toDouble(),
        moneyReported: (json['moneyReported'] as num?)?.toDouble(),
        status: json['status'] ?? 'open',
      );
}
