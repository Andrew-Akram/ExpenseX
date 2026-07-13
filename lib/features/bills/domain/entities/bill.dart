import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/enums/app_enums.dart';

part 'bill.freezed.dart';
part 'bill.g.dart';

@freezed
sealed class Bill with _$Bill {
  const factory Bill({
    required String id,
    required String name,
    required double amount,
    required DateTime dueDate,
    required String categoryId,
    @Default('default_wallet') String walletId,
    @Default(false) bool isPaid,
    @Default(false) bool isSubscription,
    @Default(RecurringInterval.monthly) RecurringInterval cycle,
    @Default(3) int reminderDaysBefore,
    String? note,
    DateTime? paidDate,
    DateTime? updatedAt,
  }) = _Bill;

  factory Bill.fromJson(Map<String, dynamic> json) => _$BillFromJson(json);
}
