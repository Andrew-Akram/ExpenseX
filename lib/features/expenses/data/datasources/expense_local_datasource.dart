import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_ce/hive.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/enums/app_enums.dart';
import '../../domain/entities/expense.dart';
import '../../domain/entities/expense_filter.dart';
import '../models/expense_model.dart';

class ExpenseLocalDataSource {
  static String get _boxName => 'expenses_${FirebaseAuth.instance.currentUser?.uid ?? 'guest'}';
  static Box<ExpenseModel> get _box => Hive.box<ExpenseModel>(_boxName);

  List<Expense> getAll() {
    final list = _box.values.map((m) => m.toEntity()).toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  Expense? getById(String id) => _box.get(id)?.toEntity();

  Future<void> save(Expense expense) async {
    await _box.put(expense.id, ExpenseModel.fromEntity(expense));
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  List<Expense> filter(ExpenseFilter f) {
    var list = getAll().where((e) => !e.isDeleted).toList();

    if (f.searchQuery != null && f.searchQuery!.isNotEmpty) {
      final q = f.searchQuery!.toLowerCase();
      list = list
          .where((e) =>
              e.title.toLowerCase().contains(q) ||
              (e.note?.toLowerCase().contains(q) ?? false) ||
              (e.merchant?.toLowerCase().contains(q) ?? false) ||
              e.tags.any((t) => t.toLowerCase().contains(q)))
          .toList();
    }

    if (f.categoryId != null && f.categoryId!.isNotEmpty) {
      list = list.where((e) => e.categoryId == f.categoryId).toList();
    }

    if (f.walletId != null && f.walletId!.isNotEmpty) {
      list = list.where((e) => e.walletId == f.walletId).toList();
    }

    if (f.type != null) {
      list = list.where((e) => e.type == f.type).toList();
    }

    if (f.dateFrom != null) {
      list = list.where((e) => !e.date.isBefore(f.dateFrom!)).toList();
    }

    if (f.dateTo != null) {
      final end = f.dateTo!.add(const Duration(days: 1));
      list = list.where((e) => e.date.isBefore(end)).toList();
    }

    if (f.amountMin != null) {
      list = list.where((e) => e.amount >= f.amountMin!).toList();
    }

    if (f.amountMax != null) {
      list = list.where((e) => e.amount <= f.amountMax!).toList();
    }

    if (f.hasReceipt != null) {
      list = list
          .where((e) => f.hasReceipt! ? e.receiptPath != null : e.receiptPath == null)
          .toList();
    }

    switch (f.sortOrder) {
      case SortOrder.dateDesc:
        list.sort((a, b) => b.date.compareTo(a.date));
      case SortOrder.dateAsc:
        list.sort((a, b) => a.date.compareTo(b.date));
      case SortOrder.amountDesc:
        list.sort((a, b) => b.amount.compareTo(a.amount));
      case SortOrder.amountAsc:
        list.sort((a, b) => a.amount.compareTo(b.amount));
      case SortOrder.category:
        list.sort((a, b) => a.categoryId.compareTo(b.categoryId));
    }

    return list;
  }


  double getMonthlyTotal(int month, int year) => getAll()
      .where((e) =>
          !e.isDeleted &&
          e.date.month == month &&
          e.date.year == year &&
          e.type == TransactionType.expense)
      .fold(0, (sum, e) => sum + e.amount);

  Map<String, double> getCategoryTotals(int month, int year) {
    final map = <String, double>{};
    for (final e in getAll()) {
      if (!e.isDeleted &&
          e.date.month == month &&
          e.date.year == year &&
          e.type == TransactionType.expense) {
        map[e.categoryId] = (map[e.categoryId] ?? 0) + e.amount;
      }
    }
    return map;
  }

  Map<DateTime, double> getDailyTotals(int days) {
    final map = <DateTime, double>{};
    final cutoff = DateTime.now().subtract(Duration(days: days - 1));
    for (final e in getAll()) {
      if (!e.isDeleted &&
          e.type == TransactionType.expense &&
          e.date.isAfter(cutoff)) {
        final day = DateTime(e.date.year, e.date.month, e.date.day);
        map[day] = (map[day] ?? 0) + e.amount;
      }
    }
    return map;
  }

  /// Seeds 4 demo transactions on first launch so the dashboard
  /// matches the design mockup with $313.31 total spend this month.
  static Future<void> seedDefaultExpensesForUser(String uid) async {
    final box = Hive.box<ExpenseModel>('expenses_$uid');
    if (box.isNotEmpty) return;

    const uuid = Uuid();
    final now = DateTime.now();

    final seeds = [
      ExpenseModel(
        id: uuid.v4(),
        title: 'Spotify Subscriptions',
        amount: 4.99,
        categoryId: 'entertainment',
        date: DateTime(now.year, now.month, 15),
        note: 'Monthly subscription',
      ),
      ExpenseModel(
        id: uuid.v4(),
        title: 'Copay Balance Top up',
        amount: 11.32,
        categoryId: 'health',
        date: DateTime(now.year, now.month, 14),
        note: 'Medical copay',
      ),
      ExpenseModel(
        id: uuid.v4(),
        title: 'UI8 Subscriptions',
        amount: 188.00,
        categoryId: 'shopping',
        date: DateTime(now.year, now.month, 12),
        note: 'Design resources',
      ),
      ExpenseModel(
        id: uuid.v4(),
        title: 'Freepik Subscriptions',
        amount: 109.00,
        categoryId: 'shopping',
        date: DateTime(now.year, now.month, 13),
        note: 'Stock assets',
      ),
    ];

    for (final model in seeds) {
      await box.put(model.id, model);
    }
  }
}
