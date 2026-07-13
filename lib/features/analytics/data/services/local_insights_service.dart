import '../../domain/services/insights_service.dart';
import '../../../expenses/domain/entities/expense.dart';
import '../../../budget/domain/entities/budget.dart';
import '../../../savings/domain/entities/savings_goal.dart';
import '../../../../core/enums/app_enums.dart';

class LocalInsightsService implements InsightsService {
  @override
  Future<List<InsightItem>> generateInsights({
    required List<Expense> transactions,
    required List<Budget> budgets,
    required List<SavingsGoal> goals,
  }) async {
    final list = <InsightItem>[];
    final now = DateTime.now();
    final thisMonthExpenses = transactions.where((e) =>
        e.date.month == now.month &&
        e.date.year == now.year &&
        e.type == TransactionType.expense &&
        !e.isDeleted);
    final thisMonthIncome = transactions.where((e) =>
        e.date.month == now.month &&
        e.date.year == now.year &&
        e.type == TransactionType.income &&
        !e.isDeleted);

    final totalThisMonthExpenses = thisMonthExpenses.fold(0.0, (sum, e) => sum + e.amount);
    final totalThisMonthIncome = thisMonthIncome.fold(0.0, (sum, e) => sum + e.amount);

    // 1. Expense vs Income Insight
    if (totalThisMonthIncome > 0) {
      if (totalThisMonthExpenses > totalThisMonthIncome) {
        list.add(InsightItem(
          message: 'You have spent more than you earned this month. Consider cutting down non-essential costs.',
          category: InsightCategory.income,
          isPositive: false,
        ));
      } else {
        final ratio = (totalThisMonthExpenses / totalThisMonthIncome) * 100;
        list.add(InsightItem(
          message: 'Great job! You spent only ${ratio.toStringAsFixed(0)}% of your income this month.',
          category: InsightCategory.income,
          isPositive: true,
        ));
      }
    }

    // 2. Last Month Comparison Insight
    final lastMonth = now.month == 1 ? 12 : now.month - 1;
    final lastMonthYear = now.month == 1 ? now.year - 1 : now.year;
    final lastMonthExpenses = transactions.where((e) =>
        e.date.month == lastMonth &&
        e.date.year == lastMonthYear &&
        e.type == TransactionType.expense &&
        !e.isDeleted);
    final totalLastMonthExpenses = lastMonthExpenses.fold(0.0, (sum, e) => sum + e.amount);

    if (totalLastMonthExpenses > 0) {
      final change = ((totalThisMonthExpenses - totalLastMonthExpenses) / totalLastMonthExpenses) * 100;
      if (change > 5) {
        list.add(InsightItem(
          message: 'Your spending is up by ${change.toStringAsFixed(0)}% compared to last month.',
          category: InsightCategory.spending,
          changePercent: change,
          isPositive: false,
        ));
      } else if (change < -5) {
        list.add(InsightItem(
          message: 'Excellent! Your spending is down by ${(-change).toStringAsFixed(0)}% compared to last month.',
          category: InsightCategory.spending,
          changePercent: change,
          isPositive: true,
        ));
      }
    }

    // 3. Budgets Utilization Insight
    for (final budget in budgets) {
      if (budget.categoryId != null) {
        final catSpent = thisMonthExpenses
            .where((e) => e.categoryId == budget.categoryId)
            .fold(0.0, (sum, e) => sum + e.amount);
        if (catSpent > budget.amount) {
          list.add(InsightItem(
            message: 'You have exceeded your monthly category budget by \$${(catSpent - budget.amount).toStringAsFixed(2)}.',
            category: InsightCategory.budget,
            isPositive: false,
          ));
        } else if (catSpent > budget.amount * 0.8) {
          final pct = (catSpent / budget.amount) * 100;
          list.add(InsightItem(
            message: 'You have used ${pct.toStringAsFixed(0)}% of your category budget.',
            category: InsightCategory.budget,
            isPositive: false,
          ));
        }
      }
    }

    // 4. Savings Goals Progress Insight
    for (final goal in goals) {
      if (!goal.isCompleted && goal.targetAmount > 0) {
        final pct = (goal.currentAmount / goal.targetAmount) * 100;
        if (pct >= 80) {
          list.add(InsightItem(
            message: 'You are so close! Only \$${(goal.targetAmount - goal.currentAmount).toStringAsFixed(0)} left for your "${goal.name}" goal.',
            category: InsightCategory.savings,
            isPositive: true,
          ));
        } else if (pct >= 50) {
          list.add(InsightItem(
            message: 'Halfway there! You achieved ${pct.toStringAsFixed(0)}% of your "${goal.name}" goal.',
            category: InsightCategory.savings,
            isPositive: true,
          ));
        }
      }
    }

    // Fallback General Insight if we have too few
    if (list.length < 3) {
      list.add(const InsightItem(
        message: 'Consistent tracking helps keep your habits in check. Try adding tags to your transactions for deeper analysis.',
        category: InsightCategory.general,
        isPositive: true,
      ));
      list.add(const InsightItem(
        message: 'Tip: Create budgets for your top categories to keep your spending controlled.',
        category: InsightCategory.general,
        isPositive: true,
      ));
    }

    // Sort negative/warning insights first
    list.sort((a, b) => (a.isPositive ? 1 : 0).compareTo(b.isPositive ? 1 : 0));
    return list;
  }
}
