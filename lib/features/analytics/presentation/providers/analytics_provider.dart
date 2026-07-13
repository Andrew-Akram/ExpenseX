import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/enums/app_enums.dart';
import '../../../expenses/presentation/providers/expense_provider.dart';

// ── This-month expense total ──────────────────────────────────────────────────

final monthlyTotalProvider = FutureProvider<double>((ref) async {
  final expenses = await ref.watch(expenseListProvider.future);
  final now = DateTime.now();
  return expenses
      .where((e) =>
          !e.isDeleted &&
          e.type == TransactionType.expense &&
          e.date.month == now.month &&
          e.date.year == now.year)
      .fold<double>(0.0, (sum, e) => sum + e.amount);
});

// ── This-month income total ───────────────────────────────────────────────────

final monthlyIncomeTotalProvider = FutureProvider<double>((ref) async {
  final expenses = await ref.watch(expenseListProvider.future);
  final now = DateTime.now();
  return expenses
      .where((e) =>
          !e.isDeleted &&
          e.type == TransactionType.income &&
          e.date.month == now.month &&
          e.date.year == now.year)
      .fold<double>(0.0, (sum, e) => sum + e.amount);
});

// ── Previous-month totals ─────────────────────────────────────────────────────

final prevMonthExpensesTotalProvider = FutureProvider<double>((ref) async {
  final expenses = await ref.watch(expenseListProvider.future);
  final now = DateTime.now();
  final prevMonth = now.month == 1 ? 12 : now.month - 1;
  final prevYear = now.month == 1 ? now.year - 1 : now.year;
  return expenses
      .where((e) =>
          !e.isDeleted &&
          e.type == TransactionType.expense &&
          e.date.month == prevMonth &&
          e.date.year == prevYear)
      .fold<double>(0.0, (sum, e) => sum + e.amount);
});

final prevMonthIncomeTotalProvider = FutureProvider<double>((ref) async {
  final expenses = await ref.watch(expenseListProvider.future);
  final now = DateTime.now();
  final prevMonth = now.month == 1 ? 12 : now.month - 1;
  final prevYear = now.month == 1 ? now.year - 1 : now.year;
  return expenses
      .where((e) =>
          !e.isDeleted &&
          e.type == TransactionType.income &&
          e.date.month == prevMonth &&
          e.date.year == prevYear)
      .fold<double>(0.0, (sum, e) => sum + e.amount);
});

// ── Today's expense total ─────────────────────────────────────────────────────

final todayTotalProvider = FutureProvider<double>((ref) async {
  final expenses = await ref.watch(expenseListProvider.future);
  final today = DateTime.now();
  return expenses
      .where((e) =>
          !e.isDeleted &&
          e.type == TransactionType.expense &&
          e.date.year == today.year &&
          e.date.month == today.month &&
          e.date.day == today.day)
      .fold<double>(0.0, (sum, e) => sum + e.amount);
});

// ── Category totals (current month, expenses only) ────────────────────────────

final categoryTotalsProvider = FutureProvider<Map<String, double>>((ref) async {
  final expenses = await ref.watch(expenseListProvider.future);
  final now = DateTime.now();
  final map = <String, double>{};
  for (final e in expenses) {
    if (!e.isDeleted &&
        e.type == TransactionType.expense &&
        e.date.month == now.month &&
        e.date.year == now.year) {
      map[e.categoryId] = (map[e.categoryId] ?? 0) + e.amount;
    }
  }
  return map;
});

// ── Daily expense totals for last 7 days ─────────────────────────────────────

final dailyTotals7Provider = FutureProvider<Map<DateTime, double>>((ref) async {
  final expenses = await ref.watch(expenseListProvider.future);
  final map = <DateTime, double>{};
  final now = DateTime.now();
  final cutoff = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6));
  for (final e in expenses) {
    if (!e.isDeleted &&
        e.type == TransactionType.expense &&
        !e.date.isBefore(cutoff)) {
      final day = DateTime(e.date.year, e.date.month, e.date.day);
      map[day] = (map[day] ?? 0) + e.amount;
    }
  }
  return map;
});

// ── Daily income totals for last 7 days ──────────────────────────────────────

final dailyIncome7Provider = FutureProvider<Map<DateTime, double>>((ref) async {
  final expenses = await ref.watch(expenseListProvider.future);
  final map = <DateTime, double>{};
  final now = DateTime.now();
  final cutoff = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6));
  for (final e in expenses) {
    if (!e.isDeleted &&
        e.type == TransactionType.income &&
        !e.date.isBefore(cutoff)) {
      final day = DateTime(e.date.year, e.date.month, e.date.day);
      map[day] = (map[day] ?? 0) + e.amount;
    }
  }
  return map;
});

// ── Daily expense totals for last 30 days ────────────────────────────────────

final dailyTotals30Provider = FutureProvider<Map<DateTime, double>>((ref) async {
  final expenses = await ref.watch(expenseListProvider.future);
  final map = <DateTime, double>{};
  final now = DateTime.now();
  final cutoff = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 29));
  for (final e in expenses) {
    if (!e.isDeleted &&
        e.type == TransactionType.expense &&
        !e.date.isBefore(cutoff)) {
      final day = DateTime(e.date.year, e.date.month, e.date.day);
      map[day] = (map[day] ?? 0) + e.amount;
    }
  }
  return map;
});

// ── Monthly expense totals for bar chart (12 months) ─────────────────────────

final monthly12TotalsProvider =
    FutureProvider<List<MapEntry<DateTime, double>>>((ref) async {
  final expenses = await ref.watch(expenseListProvider.future);
  final now = DateTime.now();
  final entries = <MapEntry<DateTime, double>>[];
  for (int i = 11; i >= 0; i--) {
    int month = now.month - i;
    int year = now.year;
    while (month <= 0) {
      month += 12;
      year--;
    }
    final dt = DateTime(year, month);
    final total = expenses
        .where((e) =>
            !e.isDeleted &&
            e.type == TransactionType.expense &&
            e.date.month == dt.month &&
            e.date.year == dt.year)
        .fold<double>(0.0, (sum, e) => sum + e.amount);
    entries.add(MapEntry(dt, total));
  }
  return entries;
});

// ── Monthly income totals for bar chart (12 months) ──────────────────────────

final monthly12IncomeTotalsProvider =
    FutureProvider<List<MapEntry<DateTime, double>>>((ref) async {
  final expenses = await ref.watch(expenseListProvider.future);
  final now = DateTime.now();
  final entries = <MapEntry<DateTime, double>>[];
  for (int i = 11; i >= 0; i--) {
    int month = now.month - i;
    int year = now.year;
    while (month <= 0) {
      month += 12;
      year--;
    }
    final dt = DateTime(year, month);
    final total = expenses
        .where((e) =>
            !e.isDeleted &&
            e.type == TransactionType.income &&
            e.date.month == dt.month &&
            e.date.year == dt.year)
        .fold<double>(0.0, (sum, e) => sum + e.amount);
    entries.add(MapEntry(dt, total));
  }
  return entries;
});
