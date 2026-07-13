import '../../domain/entities/savings_goal.dart';
import '../../domain/repositories/savings_repository.dart';
import '../datasources/savings_firestore_datasource.dart';

class SavingsRepositoryImpl implements SavingsRepository {
  final SavingsFirestoreDataSource _ds;
  SavingsRepositoryImpl(this._ds);

  @override
  Future<List<SavingsGoal>> getGoals() => _ds.getAll();

  @override
  Future<SavingsGoal?> getById(String id) => _ds.getById(id);

  @override
  Future<void> saveGoal(SavingsGoal goal) => _ds.save(goal);

  @override
  Future<void> deleteGoal(String id) => _ds.delete(id);

  @override
  Future<void> contribute(String id, double amount) =>
      _ds.contribute(id, amount);
}
