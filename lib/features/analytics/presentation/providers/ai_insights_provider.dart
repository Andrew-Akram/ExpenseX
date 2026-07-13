import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/services/insights_service.dart';
import '../../data/services/local_insights_service.dart';
import '../../../expenses/presentation/providers/expense_provider.dart';
import '../../../budget/presentation/providers/budget_provider.dart';
import '../../../savings/presentation/providers/savings_provider.dart';

final insightsServiceProvider = Provider<InsightsService>((ref) {
  return LocalInsightsService();
});

final aiInsightsProvider = FutureProvider<List<InsightItem>>((ref) async {
  final expenses = await ref.watch(expenseListProvider.future);
  final budgets = await ref.watch(budgetListProvider.future);
  final goals = await ref.watch(savingsGoalListProvider.future);
  final service = ref.watch(insightsServiceProvider);

  return service.generateInsights(
    transactions: expenses,
    budgets: budgets,
    goals: goals,
  );
});
