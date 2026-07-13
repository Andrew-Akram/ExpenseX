import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/savings_goal.dart';

class SavingsFirestoreDataSource {
  static String get _uid =>
      FirebaseAuth.instance.currentUser?.uid ?? 'guest';

  CollectionReference<Map<String, dynamic>> get _col =>
      FirebaseFirestore.instance.collection('users/$_uid/savings_goals');

  Future<List<SavingsGoal>> getAll() async {
    final snap = await _col.get();
    return snap.docs
        .map((d) => SavingsGoal.fromJson({...d.data(), 'id': d.id}))
        .toList();
  }

  Future<SavingsGoal?> getById(String id) async {
    final doc = await _col.doc(id).get();
    if (!doc.exists) return null;
    return SavingsGoal.fromJson({...doc.data()!, 'id': doc.id});
  }

  Future<void> save(SavingsGoal goal) async {
    final data = goal.toJson();
    data.remove('id');
    await _col.doc(goal.id).set(data, SetOptions(merge: true));
  }

  Future<void> delete(String id) async {
    await _col.doc(id).delete();
  }

  /// Adds [amount] to the goal's current amount, marks complete if reached.
  Future<void> contribute(String id, double amount) async {
    final goal = await getById(id);
    if (goal == null) return;
    final newAmount = goal.currentAmount + amount;
    final isCompleted = newAmount >= goal.targetAmount;
    await _col.doc(id).update({
      'currentAmount': newAmount,
      'isCompleted': isCompleted,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }
}
