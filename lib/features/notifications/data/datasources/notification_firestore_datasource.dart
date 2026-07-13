import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/app_notification.dart';

class NotificationFirestoreDataSource {
  static String get _uid =>
      FirebaseAuth.instance.currentUser?.uid ?? 'guest';

  CollectionReference<Map<String, dynamic>> get _col =>
      FirebaseFirestore.instance.collection('users/$_uid/notifications');

  Future<List<AppNotification>> getAll() async {
    final snap = await _col.get();
    final list = snap.docs
        .map((d) => AppNotification.fromJson({...d.data(), 'id': d.id}))
        .toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  Future<void> save(AppNotification notification) async {
    final data = notification.toJson();
    data.remove('id');
    await _col.doc(notification.id).set(data, SetOptions(merge: true));
  }

  Future<void> markRead(String id) async {
    await _col.doc(id).update({'isRead': true});
  }

  Future<void> markAllRead() async {
    final snap = await _col.where('isRead', isEqualTo: false).get();
    final batch = FirebaseFirestore.instance.batch();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  Future<void> clearOld() async {
    final cutoff = DateTime.now()
        .subtract(const Duration(days: 30))
        .toIso8601String();
    final snap = await _col.where('date', isLessThan: cutoff).get();
    final batch = FirebaseFirestore.instance.batch();
    for (final doc in snap.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  Future<int> getUnreadCount() async {
    final snap = await _col.where('isRead', isEqualTo: false).get();
    return snap.size;
  }
}
