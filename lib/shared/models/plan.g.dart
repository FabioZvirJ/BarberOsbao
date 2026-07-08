// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plan.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Plan _$PlanFromJson(Map<String, dynamic> json) => _Plan(
  id: json['id'] as String,
  name: json['name'] as String,
  price: (json['price'] as num).toDouble(),
  period: json['period'] as String,
  benefits: (json['benefits'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  recommended: json['recommended'] as bool? ?? false,
);

Map<String, dynamic> _$PlanToJson(_Plan instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'price': instance.price,
  'period': instance.period,
  'benefits': instance.benefits,
  'recommended': instance.recommended,
};
