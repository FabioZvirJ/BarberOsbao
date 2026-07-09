// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_movement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_StockMovement _$StockMovementFromJson(Map<String, dynamic> json) =>
    _StockMovement(
      id: json['id'] as String,
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      type: json['type'] as String,
      quantity: (json['quantity'] as num).toInt(),
      reason: json['reason'] as String,
      date: json['date'] as String,
      responsible: json['responsible'] as String,
    );

Map<String, dynamic> _$StockMovementToJson(_StockMovement instance) =>
    <String, dynamic>{
      'id': instance.id,
      'productId': instance.productId,
      'productName': instance.productName,
      'type': instance.type,
      'quantity': instance.quantity,
      'reason': instance.reason,
      'date': instance.date,
      'responsible': instance.responsible,
    };
