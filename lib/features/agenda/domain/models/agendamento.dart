class Agendamento {
  final String id;
  final String clientName;
  final String barberName;
  final String services;
  final String date; // "YYYY-MM-DD"
  final String time; // "HH:MM"
  final double price;
  final String status; // 'confirmed', 'pending', 'completed', 'cancelled'
  final String notes;

  const Agendamento({
    required this.id,
    required this.clientName,
    required this.barberName,
    required this.services,
    required this.date,
    required this.time,
    required this.price,
    required this.status,
    required this.notes,
  });

  Agendamento copyWith({
    String? id,
    String? clientName,
    String? barberName,
    String? services,
    String? date,
    String? time,
    double? price,
    String? status,
    String? notes,
  }) {
    return Agendamento(
      id: id ?? this.id,
      clientName: clientName ?? this.clientName,
      barberName: barberName ?? this.barberName,
      services: services ?? this.services,
      date: date ?? this.date,
      time: time ?? this.time,
      price: price ?? this.price,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'clientName': clientName,
        'barberName': barberName,
        'services': services,
        'date': date,
        'time': time,
        'price': price,
        'status': status,
        'notes': notes,
      };

  factory Agendamento.fromJson(Map<String, dynamic> json) => Agendamento(
        id: json['id'] ?? '',
        clientName: json['clientName'] ?? '',
        barberName: json['barberName'] ?? '',
        services: json['services'] ?? '',
        date: json['date'] ?? '',
        time: json['time'] ?? '',
        price: (json['price'] as num?)?.toDouble() ?? 0.0,
        status: json['status'] ?? 'pending',
        notes: json['notes'] ?? '',
      );
}
