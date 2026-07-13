// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'savings_goal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SavingsGoal _$SavingsGoalFromJson(Map<String, dynamic> json) => _SavingsGoal(
  id: json['id'] as String,
  name: json['name'] as String,
  targetAmount: (json['targetAmount'] as num).toDouble(),
  currentAmount: (json['currentAmount'] as num?)?.toDouble() ?? 0.0,
  deadline: DateTime.parse(json['deadline'] as String),
  colorValue: (json['colorValue'] as num).toInt(),
  iconName: json['iconName'] as String? ?? 'savings',
  isCompleted: json['isCompleted'] as bool? ?? false,
  walletId: json['walletId'] as String? ?? 'default_wallet',
  note: json['note'] as String?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$SavingsGoalToJson(_SavingsGoal instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'targetAmount': instance.targetAmount,
      'currentAmount': instance.currentAmount,
      'deadline': instance.deadline.toIso8601String(),
      'colorValue': instance.colorValue,
      'iconName': instance.iconName,
      'isCompleted': instance.isCompleted,
      'walletId': instance.walletId,
      'note': instance.note,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
