import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/enums/app_enums.dart';
import '../../domain/entities/expense.dart';
import '../../domain/entities/expense_filter.dart';

class ExpenseFirestoreDataSource {
  static String get _uid =>
      FirebaseAuth.instance.currentUser?.uid ?? 'guest';

  CollectionReference<Map<String, dynamic>> get _col =>
      FirebaseFirestore.instance.collection('users/$_uid/expenses');

  Future<List<Expense>> getAll() async {
    final snap = await _col.get();
    final list = snap.docs
        .map((d) => Expense.fromJson({...d.data(), 'id': d.id}))
        .where((e) => !e.isDeleted)
        .toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  Future<Expense?> getById(String id) async {
    final doc = await _col.doc(id).get();
    if (!doc.exists) return null;
    return Expense.fromJson({...doc.data()!, 'id': doc.id});
  }

  Future<void> save(Expense expense) async {
    final data = expense.toJson();
    data.remove('id');
    await _col.doc(expense.id).set(data, SetOptions(merge: true));
  }

  Future<void> delete(String id) async {
    await _col.doc(id).update({'isDeleted': true});
  }

  Future<List<Expense>> filter(ExpenseFilter f) async {
    var list = (await getAll()).where((e) => !e.isDeleted).toList();

    if (f.searchQuery != null && f.searchQuery!.isNotEmpty) {
      final q = f.searchQuery!.toLowerCase();
      list = list.where((e) =>
          e.title.toLowerCase().contains(q) ||
          (e.note?.toLowerCase().contains(q) ?? false) ||
          (e.merchant?.toLowerCase().contains(q) ?? false) ||
          e.tags.any((t) => t.toLowerCase().contains(q))).toList();
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
      list = list.where((e) =>
          f.hasReceipt! ? e.receiptPath != null : e.receiptPath == null).toList();
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

  Future<double> getMonthlyTotal(int month, int year) async {
    final all = await getAll();
    return all
        .where((e) =>
            !e.isDeleted &&
            e.type == TransactionType.expense &&
            e.date.month == month &&
            e.date.year == year)
        .fold<double>(0.0, (sum, e) => sum + e.amount);
  }

  Future<Map<String, double>> getCategoryTotals(int month, int year) async {
    final map = <String, double>{};
    final all = await getAll();
    for (final e in all) {
      if (!e.isDeleted &&
          e.type == TransactionType.expense &&
          e.date.month == month &&
          e.date.year == year) {
        map[e.categoryId] = (map[e.categoryId] ?? 0) + e.amount;
      }
    }
    return map;
  }

  Future<Map<DateTime, double>> getDailyTotals(int days) async {
    final map = <DateTime, double>{};
    final cutoff = DateTime.now().subtract(Duration(days: days - 1));
    final all = await getAll();
    for (final e in all) {
      if (!e.isDeleted &&
          e.type == TransactionType.expense &&
          e.date.isAfter(cutoff)) {
        final day = DateTime(e.date.year, e.date.month, e.date.day);
        map[day] = (map[day] ?? 0) + e.amount;
      }
    }
    return map;
  }

  /// Seeds 4 demo expenses on first login (collection empty).
  static Future<void> seedDefaultExpenses() async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'guest';
    final col = FirebaseFirestore.instance.collection('users/$uid/expenses');
    final snap = await col.limit(1).get();
    if (snap.docs.isNotEmpty) return;

    final now = DateTime.now();
    final seeds = [
      {
        'title': 'Spotify Subscriptions',
        'amount': 4.99,
        'categoryId': 'entertainment',
        'date': DateTime(now.year, now.month, 15).toIso8601String(),
        'note': 'Monthly subscription',
        'walletId': 'default_wallet',
        'type': TransactionType.expense.name,
        'tags': <String>[],
        'isRecurring': false,
        'recurringInterval': RecurringInterval.none.name,
        'isDeleted': false,
      },
      {
        'title': 'Copay Balance Top up',
        'amount': 11.32,
        'categoryId': 'health',
        'date': DateTime(now.year, now.month, 14).toIso8601String(),
        'note': 'Medical copay',
        'walletId': 'default_wallet',
        'type': TransactionType.expense.name,
        'tags': <String>[],
        'isRecurring': false,
        'recurringInterval': RecurringInterval.none.name,
        'isDeleted': false,
      },
      {
        'title': 'UI8 Subscriptions',
        'amount': 188.00,
        'categoryId': 'shopping',
        'date': DateTime(now.year, now.month, 12).toIso8601String(),
        'note': 'Design resources',
        'walletId': 'default_wallet',
        'type': TransactionType.expense.name,
        'tags': <String>[],
        'isRecurring': false,
        'recurringInterval': RecurringInterval.none.name,
        'isDeleted': false,
      },
      {
        'title': 'Freepik Subscriptions',
        'amount': 109.00,
        'categoryId': 'shopping',
        'date': DateTime(now.year, now.month, 13).toIso8601String(),
        'note': 'Stock assets',
        'walletId': 'default_wallet',
        'type': TransactionType.expense.name,
        'tags': <String>[],
        'isRecurring': false,
        'recurringInterval': RecurringInterval.none.name,
        'isDeleted': false,
      },
    ];

    final batch = FirebaseFirestore.instance.batch();
    for (final seed in seeds) {
      batch.set(col.doc(), seed);
    }
    await batch.commit();
  }
}
