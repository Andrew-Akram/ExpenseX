import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_ce/hive.dart';
import '../../domain/entities/bill.dart';
import '../models/bill_model.dart';

class BillLocalDataSource {
  static String get _boxName => 'bills_${FirebaseAuth.instance.currentUser?.uid ?? 'guest'}';
  static Box<BillModel> get _box => Hive.box<BillModel>(_boxName);

  List<Bill> getAll() {
    return _box.values.map((m) => m.toEntity()).toList();
  }

  Bill? getById(String id) {
    return _box.get(id)?.toEntity();
  }

  Future<void> save(Bill bill) async {
    await _box.put(bill.id, BillModel.fromEntity(bill));
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  List<Bill> getUpcoming(int days) {
    final now = DateTime.now();
    final limit = now.add(Duration(days: days));
    return getAll()
        .where((b) => !b.isPaid && b.dueDate.isAfter(now.subtract(const Duration(days: 1))) && b.dueDate.isBefore(limit))
        .toList();
  }
}
