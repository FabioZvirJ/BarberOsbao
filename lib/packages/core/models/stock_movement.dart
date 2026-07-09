import 'package:freezed_annotation/freezed_annotation.dart';

part 'stock_movement.freezed.dart';
part 'stock_movement.g.dart';

@freezed
abstract class StockMovement with _$StockMovement {
  const factory StockMovement({
    required String id,
    required String productId,
    required String productName,
    required String type, // 'in' or 'out'
    required int quantity,
    required String reason,
    required String date,
    required String responsible,
  }) = _StockMovement;

  factory StockMovement.fromJson(Map<String, dynamic> json) => _$StockMovementFromJson(json);
}
