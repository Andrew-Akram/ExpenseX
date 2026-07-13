import '../entities/expense.dart';
import '../entities/expense_filter.dart';

abstract class ExpenseRepository {
  /// Returns all expenses, newest first.
  Future<List<Expense>> getExpenses();

  /// Returns a single expense by [id], or null if not found.
  Future<Expense?> getExpenseById(String id);

  /// Persists a new expense and returns it.
  Future<void> addExpense(Expense expense);

  /// Updates an existing expense.
  Future<void> updateExpense(Expense expense);

  /// Deletes an expense by [id].
  Future<void> deleteExpense(String id);

  /// Returns filtered and sorted expenses based on [filter].
  Future<List<Expense>> filterExpenses(ExpenseFilter filter);

  /// Returns the total amount of expenses in a given month/year.
  Future<double> getMonthlyTotal(int month, int year);

  /// Returns total spent per categoryId for a given month/year.
  Future<Map<String, double>> getCategoryTotals(int month, int year);

  /// Returns daily totals for the last [days] days.
  Future<Map<DateTime, double>> getDailyTotals(int days);
}
