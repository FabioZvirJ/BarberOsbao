import 'package:freezed_annotation/freezed_annotation.dart';

part 'plan.freezed.dart';
part 'plan.g.dart';

@freezed
class Plan with _$Plan {
  const factory Plan({
    required String id,
    required String name,
    required double price,
    required String period, // 'mensal' or 'anual'
    required List<String> benefits,
    @Default(false) bool recommended,
  }) = _Plan;

  factory Plan.fromJson(Map<String, dynamic> json) => _$PlanFromJson(json);
}
