import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/bill.dart';

class BillFirestoreDataSource {
  static String get _uid =>
      FirebaseAuth.instance.currentUser?.uid ?? 'guest';

  CollectionReference<Map<String, dynamic>> get _col =>
      FirebaseFirestore.instance.collection('users/$_uid/bills');

  Future<List<Bill>> getAll() async {
    final snap = await _col.get();
    return snap.docs
        .map((d) => Bill.fromJson({...d.data(), 'id': d.id}))
        .toList();
  }

  Future<Bill?> getById(String id) async {
    final doc = await _col.doc(id).get();
    if (!doc.exists) return null;
    return Bill.fromJson({...doc.data()!, 'id': doc.id});
  }

  Future<void> save(Bill bill) async {
    final data = bill.toJson();
    data.remove('id');
    await _col.doc(bill.id).set(data, SetOptions(merge: true));
  }

  Future<void> delete(String id) async {
    await _col.doc(id).delete();
  }

  /// Returns bills due within the next [days] days that haven't been paid.
  Future<List<Bill>> getUpcoming(int days) async {
    final now = DateTime.now();
    final limit = now.add(Duration(days: days));
    final all = await getAll();
    return all.where((b) =>
        !b.isPaid &&
        b.dueDate.isAfter(now.subtract(const Duration(days: 1))) &&
        b.dueDate.isBefore(limit)).toList();
  }
}
