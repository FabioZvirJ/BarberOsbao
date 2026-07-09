// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'finance_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FinanceEntry _$FinanceEntryFromJson(Map<String, dynamic> json) =>
    _FinanceEntry(
      id: json['id'] as String,
      type: json['type'] as String,
      description: json['description'] as String,
      amount: (json['amount'] as num).toDouble(),
      category: json['category'] as String,
      date: json['date'] as String,
      paymentMethod: json['paymentMethod'] as String,
      status: json['status'] as String,
    );

Map<String, dynamic> _$FinanceEntryToJson(_FinanceEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'description': instance.description,
      'amount': instance.amount,
      'category': instance.category,
      'date': instance.date,
      'paymentMethod': instance.paymentMethod,
      'status': instance.status,
    };
