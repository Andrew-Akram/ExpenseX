import '../../domain/entities/budget.dart';
import '../../domain/repositories/budget_repository.dart';
import '../datasources/budget_firestore_datasource.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  final BudgetFirestoreDataSource _ds;
  BudgetRepositoryImpl(this._ds);

  @override
  Future<List<Budget>> getBudgets() => _ds.getAll();

  @override
  Future<Budget?> getMonthlyBudget(int month, int year) =>
      _ds.getMonthly(month, year);

  @override
  Future<Budget?> getCategoryBudget(
          String categoryId, int month, int year) =>
      _ds.getCategoryBudget(categoryId, month, year);

  @override
  Future<void> setBudget(Budget budget) => _ds.save(budget);

  @override
  Future<void> deleteBudget(String id) => _ds.delete(id);
}
