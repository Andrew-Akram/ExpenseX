import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../domain/entities/budget.dart';

final budgetListProvider =
    AsyncNotifierProvider<BudgetNotifier, List<Budget>>(BudgetNotifier.new);

class BudgetNotifier extends AsyncNotifier<List<Budget>> {
  @override
  Future<List<Budget>> build() =>
      ref.read(budgetRepositoryProvider).getBudgets();

  Future<void> setBudget(Budget budget) async {
    await ref.read(budgetRepositoryProvider).setBudget(budget);
    ref.invalidateSelf();
  }

  Future<void> deleteBudget(String id) async {
    await ref.read(budgetRepositoryProvider).deleteBudget(id);
    ref.invalidateSelf();
  }
}

// ── Helpers for current-month budget ─────────────────────────────────────────

final currentMonthBudgetProvider = FutureProvider<Budget?>((ref) {
  final now = DateTime.now();
  return ref
      .watch(budgetRepositoryProvider)
      .getMonthlyBudget(now.month, now.year);
});
