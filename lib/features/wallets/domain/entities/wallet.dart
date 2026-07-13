import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/enums/app_enums.dart';

part 'wallet.freezed.dart';
part 'wallet.g.dart';

@freezed
sealed class Wallet with _$Wallet {
  const factory Wallet({
    required String id,
    required String name,
    @Default(WalletType.cash) WalletType type,
    @Default(0.0) double initialBalance,
    @Default('USD') String currency,
    required int colorValue,
    @Default('account_balance_wallet') String iconName,
    @Default(true) bool isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    @Default(false) bool isDeleted,
  }) = _Wallet;

  factory Wallet.fromJson(Map<String, dynamic> json) => _$WalletFromJson(json);
}
