import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_ce/hive.dart';

import '../../domain/entities/budget.dart';
import '../models/budget_model.dart';

class BudgetLocalDataSource {
  static String get _boxName => 'budgets_${FirebaseAuth.instance.currentUser?.uid ?? 'guest'}';
  static Box<BudgetModel> get _box => Hive.box<BudgetModel>(_boxName);

  List<Budget> getAll() =>
      _box.values.map((m) => m.toEntity()).toList();

  Budget? getMonthly(int month, int year) {
    try {
      return _box.values
          .firstWhere(
            (m) => m.categoryId == null && m.month == month && m.year == year,
          )
          .toEntity();
    } catch (_) {
      return null;
    }
  }

  Budget? getCategoryBudget(String categoryId, int month, int year) {
    try {
      return _box.values
          .firstWhere(
            (m) =>
                m.categoryId == categoryId &&
                m.month == month &&
                m.year == year,
          )
          .toEntity();
    } catch (_) {
      return null;
    }
  }

  Future<void> save(Budget budget) async {
    await _box.put(budget.id, BudgetModel.fromEntity(budget));
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }
}
