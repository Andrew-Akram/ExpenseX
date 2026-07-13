// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Wallet _$WalletFromJson(Map<String, dynamic> json) => _Wallet(
  id: json['id'] as String,
  name: json['name'] as String,
  type:
      $enumDecodeNullable(_$WalletTypeEnumMap, json['type']) ?? WalletType.cash,
  initialBalance: (json['initialBalance'] as num?)?.toDouble() ?? 0.0,
  currency: json['currency'] as String? ?? 'USD',
  colorValue: (json['colorValue'] as num).toInt(),
  iconName: json['iconName'] as String? ?? 'account_balance_wallet',
  isActive: json['isActive'] as bool? ?? true,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  isDeleted: json['isDeleted'] as bool? ?? false,
);

Map<String, dynamic> _$WalletToJson(_Wallet instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'type': _$WalletTypeEnumMap[instance.type]!,
  'initialBalance': instance.initialBalance,
  'currency': instance.currency,
  'colorValue': instance.colorValue,
  'iconName': instance.iconName,
  'isActive': instance.isActive,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'isDeleted': instance.isDeleted,
};

const _$WalletTypeEnumMap = {
  WalletType.cash: 'cash',
  WalletType.bank: 'bank',
  WalletType.visa: 'visa',
  WalletType.mastercard: 'mastercard',
  WalletType.vodafoneCash: 'vodafoneCash',
  WalletType.instapay: 'instapay',
  WalletType.other: 'other',
};
