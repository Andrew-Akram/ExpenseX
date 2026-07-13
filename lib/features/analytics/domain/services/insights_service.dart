import '../../../expenses/domain/entities/expense.dart';
import '../../../budget/domain/entities/budget.dart';
import '../../../savings/domain/entities/savings_goal.dart';

abstract class InsightsService {
  Future<List<InsightItem>> generateInsights({
    required List<Expense> transactions,
    required List<Budget> budgets,
    required List<SavingsGoal> goals,
  });
}

class InsightItem {
  final String message;
  final InsightCategory category;
  final double? changePercent;
  final bool isPositive;

  const InsightItem({
    required this.message,
    required this.category,
    this.changePercent,
    required this.isPositive,
  });
}

enum InsightCategory {
  spending, income, budget, savings, bills, general
}
