import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/constants/category_constants.dart';
import '../../domain/entities/category.dart';

class CategoryFirestoreDataSource {
  static String get _uid =>
      FirebaseAuth.instance.currentUser?.uid ?? 'guest';

  CollectionReference<Map<String, dynamic>> get _col =>
      FirebaseFirestore.instance.collection('users/$_uid/categories');

  Future<List<Category>> getAll() async {
    final snap = await _col.get();
    return snap.docs.map((d) => Category.fromJson({...d.data(), 'id': d.id})).toList();
  }

  Future<Category?> getById(String id) async {
    final doc = await _col.doc(id).get();
    if (!doc.exists) return null;
    return Category.fromJson({...doc.data()!, 'id': doc.id});
  }

  Future<void> save(Category category) async {
    final data = category.toJson();
    data.remove('id');
    await _col.doc(category.id).set(data, SetOptions(merge: true));
  }

  Future<void> delete(String id) async {
    await _col.doc(id).delete();
  }

  /// Seeds the 9 built-in categories on first login (collection empty).
  static Future<void> seedDefaultCategories() async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'guest';
    final col = FirebaseFirestore.instance.collection('users/$uid/categories');
    final snap = await col.limit(1).get();
    if (snap.docs.isNotEmpty) return; // already seeded

    final batch = FirebaseFirestore.instance.batch();
    for (final data in CategoryConstants.defaultCategories) {
      final id = data['id'] as String;
      final doc = col.doc(id);
      batch.set(doc, {
        'name': data['name'],
        'iconName': data['iconName'],
        'colorValue': (data['colorValue'] as dynamic).value as int,
        'isCustom': data['isCustom'],
        'displayOrder': 999,
        'isHidden': false,
      });
    }
    await batch.commit();
  }
}
