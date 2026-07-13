import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/enums/app_enums.dart';

part 'budget.freezed.dart';
part 'budget.g.dart';

@freezed
sealed class Budget with _$Budget {
  const factory Budget({
    required String id,
    /// null means overall budget (not per-category)
    String? categoryId,
    required double amount,
    required int month,
    required int year,
    @Default(BudgetPeriod.monthly) BudgetPeriod period,
    /// Week number within the year (for weekly budgets)
    int? week,
  }) = _Budget;

  factory Budget.fromJson(Map<String, dynamic> json) =>
      _$BudgetFromJson(json);
}
