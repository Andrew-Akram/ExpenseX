import '../entities/savings_goal.dart';

abstract class SavingsRepository {
  Future<List<SavingsGoal>> getGoals();
  Future<SavingsGoal?> getById(String id);
  Future<void> saveGoal(SavingsGoal goal);
  Future<void> deleteGoal(String id);
  Future<void> contribute(String id, double amount);
}
