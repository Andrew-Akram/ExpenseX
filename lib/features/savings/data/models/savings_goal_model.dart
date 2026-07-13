import 'package:hive_ce/hive.dart';
import '../../domain/entities/savings_goal.dart';

part 'savings_goal_model.g.dart';

@HiveType(typeId: 4)
class SavingsGoalModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late double targetAmount;

  @HiveField(3)
  late double currentAmount;

  @HiveField(4)
  late DateTime deadline;

  @HiveField(5)
  late int colorValue;

  @HiveField(6)
  late String iconName;

  @HiveField(7)
  bool? isCompleted;

  @HiveField(8)
  String? walletId;

  @HiveField(9)
  String? note;

  @HiveField(10)
  DateTime? createdAt;

  @HiveField(11)
  DateTime? updatedAt;

  SavingsGoalModel({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.deadline,
    required this.colorValue,
    required this.iconName,
    this.isCompleted,
    this.walletId,
    this.note,
    this.createdAt,
    this.updatedAt,
  });

  factory SavingsGoalModel.fromEntity(SavingsGoal g) => SavingsGoalModel(
        id: g.id,
        name: g.name,
        targetAmount: g.targetAmount,
        currentAmount: g.currentAmount,
        deadline: g.deadline,
        colorValue: g.colorValue,
        iconName: g.iconName,
        isCompleted: g.isCompleted,
        walletId: g.walletId,
        note: g.note,
        createdAt: g.createdAt ?? DateTime.now(),
        updatedAt: g.updatedAt ?? DateTime.now(),
      );

  SavingsGoal toEntity() => SavingsGoal(
        id: id,
        name: name,
        targetAmount: targetAmount,
        currentAmount: currentAmount,
        deadline: deadline,
        colorValue: colorValue,
        iconName: iconName,
        isCompleted: isCompleted ?? false,
        walletId: walletId ?? 'default_wallet',
        note: note,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
