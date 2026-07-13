import 'package:hive_ce/hive.dart';
import '../../../../core/enums/app_enums.dart';
import '../../domain/entities/bill.dart';

part 'bill_model.g.dart';

@HiveType(typeId: 5)
class BillModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late double amount;

  @HiveField(3)
  late DateTime dueDate;

  @HiveField(4)
  late String categoryId;

  @HiveField(5)
  String? walletId;

  @HiveField(6)
  bool? isPaid;

  @HiveField(7)
  bool? isSubscription;

  @HiveField(8)
  String? cycleString; // stores RecurringInterval.name

  @HiveField(9)
  int? reminderDaysBefore;

  @HiveField(10)
  String? note;

  @HiveField(11)
  DateTime? paidDate;

  @HiveField(12)
  DateTime? updatedAt;

  BillModel({
    required this.id,
    required this.name,
    required this.amount,
    required this.dueDate,
    required this.categoryId,
    this.walletId,
    this.isPaid,
    this.isSubscription,
    this.cycleString,
    this.reminderDaysBefore,
    this.note,
    this.paidDate,
    this.updatedAt,
  });

  factory BillModel.fromEntity(Bill b) => BillModel(
        id: b.id,
        name: b.name,
        amount: b.amount,
        dueDate: b.dueDate,
        categoryId: b.categoryId,
        walletId: b.walletId,
        isPaid: b.isPaid,
        isSubscription: b.isSubscription,
        cycleString: b.cycle.name,
        reminderDaysBefore: b.reminderDaysBefore,
        note: b.note,
        paidDate: b.paidDate,
        updatedAt: b.updatedAt ?? DateTime.now(),
      );

  Bill toEntity() => Bill(
        id: id,
        name: name,
        amount: amount,
        dueDate: dueDate,
        categoryId: categoryId,
        walletId: walletId ?? 'default_wallet',
        isPaid: isPaid ?? false,
        isSubscription: isSubscription ?? false,
        cycle: RecurringInterval.fromString(cycleString),
        reminderDaysBefore: reminderDaysBefore ?? 3,
        note: note,
        paidDate: paidDate,
        updatedAt: updatedAt,
      );
}
