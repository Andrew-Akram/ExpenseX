import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_ce/hive.dart';
import '../../domain/entities/savings_goal.dart';
import '../models/savings_goal_model.dart';

class SavingsLocalDataSource {
  static String get _boxName => 'savings_goals_${FirebaseAuth.instance.currentUser?.uid ?? 'guest'}';
  static Box<SavingsGoalModel> get _box => Hive.box<SavingsGoalModel>(_boxName);

  List<SavingsGoal> getAll() {
    return _box.values.map((m) => m.toEntity()).toList();
  }

  SavingsGoal? getById(String id) {
    return _box.get(id)?.toEntity();
  }

  Future<void> save(SavingsGoal goal) async {
    await _box.put(goal.id, SavingsGoalModel.fromEntity(goal));
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  Future<void> contribute(String id, double amount) async {
    final m = _box.get(id);
    if (m != null) {
      final current = m.currentAmount;
      m.currentAmount = current + amount;
      if (m.currentAmount >= m.targetAmount) {
        m.isCompleted = true;
      }
      m.updatedAt = DateTime.now();
      await m.save();
    }
  }
}
