import '../entities/bill.dart';

abstract class BillRepository {
  Future<List<Bill>> getBills();
  Future<Bill?> getById(String id);
  Future<void> saveBill(Bill bill);
  Future<void> deleteBill(String id);
  Future<List<Bill>> getUpcoming(int days);
}
