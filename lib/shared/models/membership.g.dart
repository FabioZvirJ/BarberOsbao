// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'membership.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Membership _$MembershipFromJson(Map<String, dynamic> json) => _Membership(
  id: json['id'] as String,
  userId: json['userId'] as String,
  planId: json['planId'] as String,
  planName: json['planName'] as String,
  startDate: json['startDate'] as String,
  endDate: json['endDate'] as String,
  status: json['status'] as String,
  remainingBenefits: (json['remainingBenefits'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  discountsUsed: (json['discountsUsed'] as num).toInt(),
  nextRenewalDate: json['nextRenewalDate'] as String,
);

Map<String, dynamic> _$MembershipToJson(_Membership instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'planId': instance.planId,
      'planName': instance.planName,
      'startDate': instance.startDate,
      'endDate': instance.endDate,
      'status': instance.status,
      'remainingBenefits': instance.remainingBenefits,
      'discountsUsed': instance.discountsUsed,
      'nextRenewalDate': instance.nextRenewalDate,
    };
