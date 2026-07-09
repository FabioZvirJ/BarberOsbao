import 'package:freezed_annotation/freezed_annotation.dart';

part 'finance_entry.freezed.dart';
part 'finance_entry.g.dart';

@freezed
abstract class FinanceEntry with _$FinanceEntry {
  const factory FinanceEntry({
    required String id,
    required String type, // 'income' or 'expense'
    required String description,
    required double amount,
    required String category,
    required String date,
    required String paymentMethod,
    required String status, // 'paid', 'pending'
  }) = _FinanceEntry;

  factory FinanceEntry.fromJson(Map<String, dynamic> json) => _$FinanceEntryFromJson(json);
}
