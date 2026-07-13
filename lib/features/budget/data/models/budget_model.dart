import 'package:hive_ce/hive.dart';

import '../../../../core/enums/app_enums.dart';
import '../../domain/entities/budget.dart';

part 'budget_model.g.dart';

@HiveType(typeId: 2)
class BudgetModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  String? categoryId;

  @HiveField(2)
  late double amount;

  @HiveField(3)
  late int month;

  @HiveField(4)
  late int year;

  @HiveField(5)
  String? periodString; // BudgetPeriod.name

  @HiveField(6)
  int? week;

  BudgetModel({
    required this.id,
    this.categoryId,
    required this.amount,
    required this.month,
    required this.year,
    this.periodString,
    this.week,
  });

  factory BudgetModel.fromEntity(Budget b) => BudgetModel(
        id: b.id,
        categoryId: b.categoryId,
        amount: b.amount,
        month: b.month,
        year: b.year,
        periodString: b.period.name,
        week: b.week,
      );

  Budget toEntity() => Budget(
        id: id,
        categoryId: categoryId,
        amount: amount,
        month: month,
        year: year,
        period: BudgetPeriod.fromString(periodString),
        week: week,
      );
}
