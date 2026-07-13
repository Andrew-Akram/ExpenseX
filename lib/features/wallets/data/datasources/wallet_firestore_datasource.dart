import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/enums/app_enums.dart';
import '../../domain/entities/wallet.dart';

class WalletFirestoreDataSource {
  static String get _uid =>
      FirebaseAuth.instance.currentUser?.uid ?? 'guest';

  CollectionReference<Map<String, dynamic>> get _col =>
      FirebaseFirestore.instance.collection('users/$_uid/wallets');

  Future<List<Wallet>> getAll() async {
    final snap = await _col.get();
    return snap.docs
        .map((d) => Wallet.fromJson({...d.data(), 'id': d.id}))
        .where((w) => !w.isDeleted)
        .toList();
  }

  Future<Wallet?> getById(String id) async {
    final doc = await _col.doc(id).get();
    if (!doc.exists) return null;
    final w = Wallet.fromJson({...doc.data()!, 'id': doc.id});
    return w.isDeleted ? null : w;
  }

  Future<void> save(Wallet wallet) async {
    final data = wallet.toJson();
    data.remove('id');
    await _col.doc(wallet.id).set(data, SetOptions(merge: true));
  }

  Future<void> delete(String id) async {
    await _col.doc(id).update({
      'isDeleted': true,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  /// Seeds the default Main Wallet on first login (collection empty).
  static Future<void> seedDefaultWallet() async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'guest';
    final col = FirebaseFirestore.instance.collection('users/$uid/wallets');
    final snap = await col.limit(1).get();
    if (snap.docs.isNotEmpty) return;

    await col.doc('default_wallet').set({
      'name': 'Main Wallet',
      'type': WalletType.cash.name,
      'initialBalance': 0.0,
      'currency': 'USD',
      'colorValue': 0xFF7B6CF6,
      'iconName': 'account_balance_wallet',
      'isActive': true,
      'isDeleted': false,
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }
}
