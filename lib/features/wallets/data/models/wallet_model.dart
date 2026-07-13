import 'package:hive_ce/hive.dart';
import '../../../../core/enums/app_enums.dart';
import '../../domain/entities/wallet.dart';

part 'wallet_model.g.dart';

@HiveType(typeId: 3)
class WalletModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  String? typeString; // stores WalletType.name

  @HiveField(3)
  late double initialBalance;

  @HiveField(4)
  late String currency;

  @HiveField(5)
  late int colorValue;

  @HiveField(6)
  late String iconName;

  @HiveField(7)
  bool? isActive;

  @HiveField(8)
  DateTime? createdAt;

  @HiveField(9)
  DateTime? updatedAt;

  @HiveField(10)
  bool? isDeleted;

  WalletModel({
    required this.id,
    required this.name,
    this.typeString,
    required this.initialBalance,
    required this.currency,
    required this.colorValue,
    required this.iconName,
    this.isActive,
    this.createdAt,
    this.updatedAt,
    this.isDeleted,
  });

  factory WalletModel.fromEntity(Wallet w) => WalletModel(
        id: w.id,
        name: w.name,
        typeString: w.type.name,
        initialBalance: w.initialBalance,
        currency: w.currency,
        colorValue: w.colorValue,
        iconName: w.iconName,
        isActive: w.isActive,
        createdAt: w.createdAt ?? DateTime.now(),
        updatedAt: w.updatedAt ?? DateTime.now(),
        isDeleted: w.isDeleted,
      );

  Wallet toEntity() => Wallet(
        id: id,
        name: name,
        type: WalletType.fromString(typeString),
        initialBalance: initialBalance,
        currency: currency,
        colorValue: colorValue,
        iconName: iconName,
        isActive: isActive ?? true,
        createdAt: createdAt,
        updatedAt: updatedAt,
        isDeleted: isDeleted ?? false,
      );
}
