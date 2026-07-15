class CashMovement {
  final String id;
  final String cashShiftId;
  final String type; // 'input', 'output', 'withdraw', 'supply'
  final double amount;
  final String description;
  final String time; // "HH:MM"
  final String user;

  const CashMovement({
    required this.id,
    required this.cashShiftId,
    required this.type,
    required this.amount,
    required this.description,
    required this.time,
    required this.user,
  });

  CashMovement copyWith({
    String? id,
    String? cashShiftId,
    String? type,
    double? amount,
    String? description,
    String? time,
    String? user,
  }) {
    return CashMovement(
      id: id ?? this.id,
      cashShiftId: cashShiftId ?? this.cashShiftId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      time: time ?? this.time,
      user: user ?? this.user,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'cashShiftId': cashShiftId,
        'type': type,
        'amount': amount,
        'description': description,
        'time': time,
        'user': user,
      };

  factory CashMovement.fromJson(Map<String, dynamic> json) => CashMovement(
        id: json['id'] ?? '',
        cashShiftId: json['cashShiftId'] ?? '',
        type: json['type'] ?? 'input',
        amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
        description: json['description'] ?? '',
        time: json['time'] ?? '',
        user: json['user'] ?? '',
      );
}

class CashShift {
  final String id;
  final String operatorName;
  final String openDate; // "YYYY-MM-DD"
  final String openTime; // "HH:MM"
  final String? closeDate;
  final String? closeTime;
  final double initialBalance;
  final double? totalExpected;
  final double? totalReported;
  final String status; // 'open', 'closed'

  const CashShift({
    required this.id,
    required this.operatorName,
    required this.openDate,
    required this.openTime,
    this.closeDate,
    this.closeTime,
    required this.initialBalance,
    this.totalExpected,
    this.totalReported,
    required this.status,
  });

  CashShift copyWith({
    String? id,
    String? operatorName,
    String? openDate,
    String? openTime,
    String? closeDate,
    String? closeTime,
    double? initialBalance,
    double? totalExpected,
    double? totalReported,
    String? status,
  }) {
    return CashShift(
      id: id ?? this.id,
      operatorName: operatorName ?? this.operatorName,
      openDate: openDate ?? this.openDate,
      openTime: openTime ?? this.openTime,
      closeDate: closeDate ?? this.closeDate,
      closeTime: closeTime ?? this.closeTime,
      initialBalance: initialBalance ?? this.initialBalance,
      totalExpected: totalExpected ?? this.totalExpected,
      totalReported: totalReported ?? this.totalReported,
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
        'totalExpected': totalExpected,
        'totalReported': totalReported,
        'status': status,
      };

  factory CashShift.fromJson(Map<String, dynamic> json) => CashShift(
        id: json['id'] ?? '',
        operatorName: json['operatorName'] ?? '',
        openDate: json['openDate'] ?? '',
        openTime: json['openTime'] ?? '',
        closeDate: json['closeDate'],
        closeTime: json['closeTime'],
        initialBalance: (json['initialBalance'] as num?)?.toDouble() ?? 0.0,
        totalExpected: (json['totalExpected'] as num?)?.toDouble(),
        totalReported: (json['totalReported'] as num?)?.toDouble(),
        status: json['status'] ?? 'open',
      );
}
