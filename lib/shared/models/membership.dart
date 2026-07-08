import 'package:freezed_annotation/freezed_annotation.dart';

part 'membership.freezed.dart';
part 'membership.g.dart';

@freezed
class Membership with _$Membership {
  const factory Membership({
    required String id,
    required String userId,
    required String planId,
    required String planName,
    required String startDate,
    required String endDate,
    required String status, // 'active', 'inactive', 'expired'
    required List<String> remainingBenefits,
    required int discountsUsed,
    required String nextRenewalDate,
  }) = _Membership;

  factory Membership.fromJson(Map<String, dynamic> json) => _$MembershipFromJson(json);
}
