import '../../domain/entities/bill.dart';
import '../../domain/repositories/bill_repository.dart';
import '../datasources/bill_firestore_datasource.dart';

class BillRepositoryImpl implements BillRepository {
  final BillFirestoreDataSource _ds;
  BillRepositoryImpl(this._ds);

  @override
  Future<List<Bill>> getBills() => _ds.getAll();

  @override
  Future<Bill?> getById(String id) => _ds.getById(id);

  @override
  Future<void> saveBill(Bill bill) => _ds.save(bill);

  @override
  Future<void> deleteBill(String id) => _ds.delete(id);

  @override
  Future<List<Bill>> getUpcoming(int days) => _ds.getUpcoming(days);
}
