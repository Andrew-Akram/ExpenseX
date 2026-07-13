// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Expense _$ExpenseFromJson(Map<String, dynamic> json) => _Expense(
  id: json['id'] as String,
  title: json['title'] as String,
  amount: (json['amount'] as num).toDouble(),
  categoryId: json['categoryId'] as String,
  date: DateTime.parse(json['date'] as String),
  note: json['note'] as String?,
  walletId: json['walletId'] as String? ?? 'default_wallet',
  toWalletId: json['toWalletId'] as String?,
  type:
      $enumDecodeNullable(_$TransactionTypeEnumMap, json['type']) ??
      TransactionType.expense,
  merchant: json['merchant'] as String?,
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  receiptPath: json['receiptPath'] as String?,
  isRecurring: json['isRecurring'] as bool? ?? false,
  recurringInterval:
      $enumDecodeNullable(
        _$RecurringIntervalEnumMap,
        json['recurringInterval'],
      ) ??
      RecurringInterval.none,
  lastGeneratedOccurrence: json['lastGeneratedOccurrence'] == null
      ? null
      : DateTime.parse(json['lastGeneratedOccurrence'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  isDeleted: json['isDeleted'] as bool? ?? false,
);

Map<String, dynamic> _$ExpenseToJson(_Expense instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'amount': instance.amount,
  'categoryId': instance.categoryId,
  'date': instance.date.toIso8601String(),
  'note': instance.note,
  'walletId': instance.walletId,
  'toWalletId': instance.toWalletId,
  'type': _$TransactionTypeEnumMap[instance.type]!,
  'merchant': instance.merchant,
  'tags': instance.tags,
  'receiptPath': instance.receiptPath,
  'isRecurring': instance.isRecurring,
  'recurringInterval': _$RecurringIntervalEnumMap[instance.recurringInterval]!,
  'lastGeneratedOccurrence': instance.lastGeneratedOccurrence
      ?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'isDeleted': instance.isDeleted,
};

const _$TransactionTypeEnumMap = {
  TransactionType.income: 'income',
  TransactionType.expense: 'expense',
  TransactionType.transfer: 'transfer',
};

const _$RecurringIntervalEnumMap = {
  RecurringInterval.none: 'none',
  RecurringInterval.daily: 'daily',
  RecurringInterval.weekly: 'weekly',
  RecurringInterval.monthly: 'monthly',
  RecurringInterval.yearly: 'yearly',
};
