// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coupon.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Coupon _$CouponFromJson(Map<String, dynamic> json) => _Coupon(
  id: json['id'] as String,
  code: json['code'] as String,
  discountPercentage: (json['discountPercentage'] as num).toDouble(),
  maxDiscount: (json['maxDiscount'] as num).toDouble(),
  expirationDate: json['expirationDate'] as String,
  active: json['active'] as bool,
);

Map<String, dynamic> _$CouponToJson(_Coupon instance) => <String, dynamic>{
  'id': instance.id,
  'code': instance.code,
  'discountPercentage': instance.discountPercentage,
  'maxDiscount': instance.maxDiscount,
  'expirationDate': instance.expirationDate,
  'active': instance.active,
};
