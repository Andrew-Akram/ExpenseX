import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/budget.dart';

class BudgetFirestoreDataSource {
  static String get _uid =>
      FirebaseAuth.instance.currentUser?.uid ?? 'guest';

  CollectionReference<Map<String, dynamic>> get _col =>
      FirebaseFirestore.instance.collection('users/$_uid/budgets');

  Future<List<Budget>> getAll() async {
    final snap = await _col.get();
    return snap.docs
        .map((d) => Budget.fromJson({...d.data(), 'id': d.id}))
        .toList();
  }

  Future<Budget?> getMonthly(int month, int year) async {
    final snap = await _col
        .where('month', isEqualTo: month)
        .where('year', isEqualTo: year)
        .where('categoryId', isNull: true)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    final d = snap.docs.first;
    return Budget.fromJson({...d.data(), 'id': d.id});
  }

  Future<Budget?> getCategoryBudget(
      String categoryId, int month, int year) async {
    final snap = await _col
        .where('categoryId', isEqualTo: categoryId)
        .where('month', isEqualTo: month)
        .where('year', isEqualTo: year)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    final d = snap.docs.first;
    return Budget.fromJson({...d.data(), 'id': d.id});
  }

  Future<void> save(Budget budget) async {
    final data = budget.toJson();
    data.remove('id');
    await _col.doc(budget.id).set(data, SetOptions(merge: true));
  }

  Future<void> delete(String id) async {
    await _col.doc(id).delete();
  }
}
