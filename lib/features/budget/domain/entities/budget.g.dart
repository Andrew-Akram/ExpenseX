// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Budget _$BudgetFromJson(Map<String, dynamic> json) => _Budget(
  id: json['id'] as String,
  categoryId: json['categoryId'] as String?,
  amount: (json['amount'] as num).toDouble(),
  month: (json['month'] as num).toInt(),
  year: (json['year'] as num).toInt(),
  period:
      $enumDecodeNullable(_$BudgetPeriodEnumMap, json['period']) ??
      BudgetPeriod.monthly,
  week: (json['week'] as num?)?.toInt(),
);

Map<String, dynamic> _$BudgetToJson(_Budget instance) => <String, dynamic>{
  'id': instance.id,
  'categoryId': instance.categoryId,
  'amount': instance.amount,
  'month': instance.month,
  'year': instance.year,
  'period': _$BudgetPeriodEnumMap[instance.period]!,
  'week': instance.week,
};

const _$BudgetPeriodEnumMap = {
  BudgetPeriod.monthly: 'monthly',
  BudgetPeriod.weekly: 'weekly',
};
