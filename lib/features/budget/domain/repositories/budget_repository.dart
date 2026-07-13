import '../entities/budget.dart';

abstract class BudgetRepository {
  Future<List<Budget>> getBudgets();
  Future<Budget?> getMonthlyBudget(int month, int year);
  Future<Budget?> getCategoryBudget(String categoryId, int month, int year);
  Future<void> setBudget(Budget budget);
  Future<void> deleteBudget(String id);
}
