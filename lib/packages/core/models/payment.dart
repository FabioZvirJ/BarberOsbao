import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment.freezed.dart';
part 'payment.g.dart';

@freezed
abstract class Payment with _$Payment {
  const factory Payment({
    required String id,
    String? scheduleId,
    String? membershipId,
    required double amount,
    required String method, // 'pix', 'credit_card', 'stripe', 'mercado_pago'
    required String status, // 'pending', 'paid', 'failed', 'refunded'
    required String transactionCode,
    String? qrCodeData,
    required String createdAt,
  }) = _Payment;

  factory Payment.fromJson(Map<String, dynamic> json) => _$PaymentFromJson(json);
}
