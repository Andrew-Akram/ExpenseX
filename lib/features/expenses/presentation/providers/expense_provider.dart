import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../domain/entities/expense.dart';
import '../../domain/repositories/expense_repository.dart';
import 'expense_filter_provider.dart';

// ── Expense list state ─────────────────────────────────────────────────────────

final expenseListProvider =
    AsyncNotifierProvider<ExpenseNotifier, List<Expense>>(
  ExpenseNotifier.new,
);

class ExpenseNotifier extends AsyncNotifier<List<Expense>> {
  ExpenseRepository get _repo => ref.read(expenseRepositoryProvider);

  @override
  Future<List<Expense>> build() => _repo.getExpenses();

  Future<void> addExpense(Expense expense) async {
    await _repo.addExpense(expense);
    ref.invalidateSelf();
  }

  Future<void> updateExpense(Expense expense) async {
    await _repo.updateExpense(expense);
    ref.invalidateSelf();
    // Also invalidate filter results
    ref.invalidate(filteredExpensesProvider);
  }

  Future<void> deleteExpense(String id) async {
    await _repo.deleteExpense(id);
    ref.invalidateSelf();
    ref.invalidate(filteredExpensesProvider);
  }
}

// ── Filtered expense list ──────────────────────────────────────────────────────

final filteredExpensesProvider =
    AsyncNotifierProvider<FilteredExpenseNotifier, List<Expense>>(
  FilteredExpenseNotifier.new,
);

class FilteredExpenseNotifier extends AsyncNotifier<List<Expense>> {
  @override
  Future<List<Expense>> build() {
    // Watch expenseListProvider so this rebuilds whenever expenses change
    ref.watch(expenseListProvider);
    final filter = ref.watch(expenseFilterProvider);
    return ref.read(expenseRepositoryProvider).filterExpenses(filter);
  }
}
