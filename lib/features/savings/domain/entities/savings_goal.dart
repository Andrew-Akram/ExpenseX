import 'package:freezed_annotation/freezed_annotation.dart';

part 'savings_goal.freezed.dart';
part 'savings_goal.g.dart';

@freezed
sealed class SavingsGoal with _$SavingsGoal {
  const factory SavingsGoal({
    required String id,
    required String name,
    required double targetAmount,
    @Default(0.0) double currentAmount,
    required DateTime deadline,
    required int colorValue,
    @Default('savings') String iconName,
    @Default(false) bool isCompleted,
    @Default('default_wallet') String walletId,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _SavingsGoal;

  factory SavingsGoal.fromJson(Map<String, dynamic> json) =>
      _$SavingsGoalFromJson(json);
}
