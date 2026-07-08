// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Payment _$PaymentFromJson(Map<String, dynamic> json) => _Payment(
  id: json['id'] as String,
  scheduleId: json['scheduleId'] as String?,
  membershipId: json['membershipId'] as String?,
  amount: (json['amount'] as num).toDouble(),
  method: json['method'] as String,
  status: json['status'] as String,
  transactionCode: json['transactionCode'] as String,
  qrCodeData: json['qrCodeData'] as String?,
  createdAt: json['createdAt'] as String,
);

Map<String, dynamic> _$PaymentToJson(_Payment instance) => <String, dynamic>{
  'id': instance.id,
  'scheduleId': instance.scheduleId,
  'membershipId': instance.membershipId,
  'amount': instance.amount,
  'method': instance.method,
  'status': instance.status,
  'transactionCode': instance.transactionCode,
  'qrCodeData': instance.qrCodeData,
  'createdAt': instance.createdAt,
};
