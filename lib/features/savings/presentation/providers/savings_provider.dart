import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import '../../domain/entities/savings_goal.dart';
import '../../domain/repositories/savings_repository.dart';

final savingsGoalListProvider =
    AsyncNotifierProvider<SavingsGoalNotifier, List<SavingsGoal>>(
  SavingsGoalNotifier.new,
);

class SavingsGoalNotifier extends AsyncNotifier<List<SavingsGoal>> {
  SavingsRepository get _repo => ref.read(savingsRepositoryProvider);

  @override
  Future<List<SavingsGoal>> build() => _repo.getGoals();

  Future<void> addGoal(SavingsGoal goal) async {
    await _repo.saveGoal(goal);
    ref.invalidateSelf();
  }

  Future<void> updateGoal(SavingsGoal goal) async {
    await _repo.saveGoal(goal);
    ref.invalidateSelf();
  }

  Future<void> deleteGoal(String id) async {
    await _repo.deleteGoal(id);
    ref.invalidateSelf();
  }

  Future<void> contribute(String id, double amount) async {
    await _repo.contribute(id, amount);
    ref.invalidateSelf();
  }
}

final totalSavedAmountProvider = FutureProvider<double>((ref) async {
  final goals = await ref.watch(savingsGoalListProvider.future);
  return goals.fold<double>(0.0, (sum, g) => sum + g.currentAmount);
});
