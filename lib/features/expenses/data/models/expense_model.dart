import 'package:hive_ce/hive.dart';

import '../../../../core/enums/app_enums.dart';
import '../../domain/entities/expense.dart';

part 'expense_model.g.dart';

@HiveType(typeId: 1)
class ExpenseModel extends HiveObject {
  // ── Original fields (preserved verbatim) ──────────────────────────────────
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String title;

  @HiveField(2)
  late double amount;

  @HiveField(3)
  late String categoryId;

  @HiveField(4)
  late DateTime date;

  @HiveField(5)
  String? note;

  // ── New fields (all nullable/defaulted for backward compatibility) ─────────
  @HiveField(6)
  String? walletId;

  @HiveField(7)
  String? toWalletId;

  @HiveField(8)
  String? typeString; // stores TransactionType.name

  @HiveField(9)
  String? merchant;

  @HiveField(10)
  List<String>? tags;

  @HiveField(11)
  String? receiptPath;

  @HiveField(12)
  bool? isRecurring;

  @HiveField(13)
  String? recurringIntervalString; // stores RecurringInterval.name

  @HiveField(14)
  DateTime? lastGeneratedOccurrence;

  @HiveField(15)
  DateTime? updatedAt;

  @HiveField(16)
  bool? isDeleted;

  ExpenseModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.categoryId,
    required this.date,
    this.note,
    this.walletId,
    this.toWalletId,
    this.typeString,
    this.merchant,
    this.tags,
    this.receiptPath,
    this.isRecurring,
    this.recurringIntervalString,
    this.lastGeneratedOccurrence,
    this.updatedAt,
    this.isDeleted,
  });

  factory ExpenseModel.fromEntity(Expense e) => ExpenseModel(
        id: e.id,
        title: e.title,
        amount: e.amount,
        categoryId: e.categoryId,
        date: e.date,
        note: e.note,
        walletId: e.walletId,
        toWalletId: e.toWalletId,
        typeString: e.type.name,
        merchant: e.merchant,
        tags: e.tags.isEmpty ? null : e.tags,
        receiptPath: e.receiptPath,
        isRecurring: e.isRecurring,
        recurringIntervalString: e.recurringInterval.name,
        lastGeneratedOccurrence: e.lastGeneratedOccurrence,
        updatedAt: e.updatedAt ?? DateTime.now(),
        isDeleted: e.isDeleted,
      );

  Expense toEntity() => Expense(
        id: id,
        title: title,
        amount: amount,
        categoryId: categoryId,
        date: date,
        note: note,
        walletId: walletId ?? 'default_wallet',
        toWalletId: toWalletId,
        type: TransactionType.fromString(typeString),
        merchant: merchant,
        tags: tags ?? [],
        receiptPath: receiptPath,
        isRecurring: isRecurring ?? false,
        recurringInterval: RecurringInterval.fromString(recurringIntervalString),
        lastGeneratedOccurrence: lastGeneratedOccurrence,
        updatedAt: updatedAt,
        isDeleted: isDeleted ?? false,
      );
}
