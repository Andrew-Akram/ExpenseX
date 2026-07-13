import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/di/providers.dart';
import '../../domain/entities/bill.dart';
import '../../domain/repositories/bill_repository.dart';
import '../../../expenses/domain/entities/expense.dart';
import '../../../expenses/presentation/providers/expense_provider.dart';
import '../../../../core/enums/app_enums.dart';

final billListProvider = AsyncNotifierProvider<BillNotifier, List<Bill>>(
  BillNotifier.new,
);

class BillNotifier extends AsyncNotifier<List<Bill>> {
  BillRepository get _repo => ref.read(billRepositoryProvider);

  @override
  Future<List<Bill>> build() => _repo.getBills();

  Future<void> addBill(Bill bill) async {
    await _repo.saveBill(bill);
    ref.invalidateSelf();
  }

  Future<void> updateBill(Bill bill) async {
    await _repo.saveBill(bill);
    ref.invalidateSelf();
  }

  Future<void> deleteBill(String id) async {
    await _repo.deleteBill(id);
    ref.invalidateSelf();
  }

  Future<void> markAsPaid(String id) async {
    final bill = await _repo.getById(id);
    if (bill != null && !bill.isPaid) {
      final updatedBill = bill.copyWith(
        isPaid: true,
        paidDate: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _repo.saveBill(updatedBill);

      // Create an Expense record representing this payment
      final expense = Expense(
        id: const Uuid().v4(),
        title: 'Paid: ${bill.name}',
        amount: bill.amount,
        categoryId: bill.categoryId,
        walletId: bill.walletId,
        type: TransactionType.expense,
        date: DateTime.now(),
        note: bill.note ?? 'Automated bill payment',
        updatedAt: DateTime.now(),
      );

      // Add to Expense Provider
      await ref.read(expenseListProvider.notifier).addExpense(expense);

      ref.invalidateSelf();
    }
  }
}

final upcomingBillsProvider = FutureProvider<List<Bill>>((ref) async {
  final bills = await ref.watch(billListProvider.future);
  final now = DateTime.now();
  final limit = now.add(const Duration(days: 7));
  return bills
      .where((b) =>
          !b.isPaid &&
          b.dueDate.isAfter(now.subtract(const Duration(days: 1))) &&
          b.dueDate.isBefore(limit))
      .toList();
});

final unpaidBillsProvider = FutureProvider<List<Bill>>((ref) async {
  final bills = await ref.watch(billListProvider.future);
  return bills.where((b) => !b.isPaid).toList();
});

final monthlyBillTotalProvider = FutureProvider<double>((ref) async {
  final bills = await ref.watch(billListProvider.future);
  final now = DateTime.now();
  return bills
      .where((b) => b.dueDate.month == now.month && b.dueDate.year == now.year)
      .fold<double>(0.0, (sum, b) => sum + b.amount);
});
