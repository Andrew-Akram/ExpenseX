import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../analytics/presentation/providers/analytics_provider.dart';
import '../../../expenses/presentation/providers/expense_provider.dart';

// Dashboard aggregates all providers into a single convenience access point.
// Consumers watch the individual providers directly for granular rebuilds.

/// Top category name + amount for the current month.
final topCategoryProvider =
    FutureProvider<MapEntry<String, double>?>((ref) async {
  final totals = await ref.watch(categoryTotalsProvider.future);
  if (totals.isEmpty) return null;
  return totals.entries.reduce((a, b) => a.value >= b.value ? a : b);
});

/// Recent 5 expenses.
final recentExpensesProvider = Provider((ref) {
  final asyncList = ref.watch(expenseListProvider);
  return asyncList.maybeWhen(
    data: (list) => list.take(5).toList(),
    orElse: () => <dynamic>[],
  );
});
