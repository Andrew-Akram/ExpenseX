import '../../domain/entities/expense.dart';
import '../../domain/entities/expense_filter.dart';
import '../../domain/repositories/expense_repository.dart';
import '../datasources/expense_firestore_datasource.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseFirestoreDataSource _ds;
  ExpenseRepositoryImpl(this._ds);

  @override
  Future<List<Expense>> getExpenses() => _ds.getAll();

  @override
  Future<Expense?> getExpenseById(String id) => _ds.getById(id);

  @override
  Future<void> addExpense(Expense expense) => _ds.save(expense);

  @override
  Future<void> updateExpense(Expense expense) => _ds.save(expense);

  @override
  Future<void> deleteExpense(String id) => _ds.delete(id);

  @override
  Future<List<Expense>> filterExpenses(ExpenseFilter filter) =>
      _ds.filter(filter);

  @override
  Future<double> getMonthlyTotal(int month, int year) =>
      _ds.getMonthlyTotal(month, year);

  @override
  Future<Map<String, double>> getCategoryTotals(int month, int year) =>
      _ds.getCategoryTotals(month, year);

  @override
  Future<Map<DateTime, double>> getDailyTotals(int days) =>
      _ds.getDailyTotals(days);
}
