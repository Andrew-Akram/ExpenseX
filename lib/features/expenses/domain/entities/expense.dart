import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/enums/app_enums.dart';

part 'expense.freezed.dart';
part 'expense.g.dart';

@freezed
sealed class Expense with _$Expense {
  const factory Expense({
    required String id,
    required String title,
    required double amount,
    required String categoryId,
    required DateTime date,
    // ── Pre-existing optional fields ───────────────────────────────────────
    String? note,
    // ── New fields (all optional with defaults for backward compatibility) ─
    @Default('default_wallet') String walletId,
    String? toWalletId,
    @Default(TransactionType.expense) TransactionType type,
    String? merchant,
    @Default([]) List<String> tags,
    String? receiptPath,
    @Default(false) bool isRecurring,
    @Default(RecurringInterval.none) RecurringInterval recurringInterval,
    DateTime? lastGeneratedOccurrence,
    DateTime? updatedAt,
    @Default(false) bool isDeleted,
  }) = _Expense;

  factory Expense.fromJson(Map<String, dynamic> json) =>
      _$ExpenseFromJson(json);
}
