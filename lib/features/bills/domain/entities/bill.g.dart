// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bill.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Bill _$BillFromJson(Map<String, dynamic> json) => _Bill(
  id: json['id'] as String,
  name: json['name'] as String,
  amount: (json['amount'] as num).toDouble(),
  dueDate: DateTime.parse(json['dueDate'] as String),
  categoryId: json['categoryId'] as String,
  walletId: json['walletId'] as String? ?? 'default_wallet',
  isPaid: json['isPaid'] as bool? ?? false,
  isSubscription: json['isSubscription'] as bool? ?? false,
  cycle:
      $enumDecodeNullable(_$RecurringIntervalEnumMap, json['cycle']) ??
      RecurringInterval.monthly,
  reminderDaysBefore: (json['reminderDaysBefore'] as num?)?.toInt() ?? 3,
  note: json['note'] as String?,
  paidDate: json['paidDate'] == null
      ? null
      : DateTime.parse(json['paidDate'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$BillToJson(_Bill instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'amount': instance.amount,
  'dueDate': instance.dueDate.toIso8601String(),
  'categoryId': instance.categoryId,
  'walletId': instance.walletId,
  'isPaid': instance.isPaid,
  'isSubscription': instance.isSubscription,
  'cycle': _$RecurringIntervalEnumMap[instance.cycle]!,
  'reminderDaysBefore': instance.reminderDaysBefore,
  'note': instance.note,
  'paidDate': instance.paidDate?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};

const _$RecurringIntervalEnumMap = {
  RecurringInterval.none: 'none',
  RecurringInterval.daily: 'daily',
  RecurringInterval.weekly: 'weekly',
  RecurringInterval.monthly: 'monthly',
  RecurringInterval.yearly: 'yearly',
};
