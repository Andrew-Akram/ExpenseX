import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/category_constants.dart';
import '../../../../core/enums/app_enums.dart';
import '../../../../core/extensions/num_extensions.dart';
import '../../../../core/extensions/date_extensions.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../categories/presentation/providers/category_provider.dart';
import '../../domain/entities/bill.dart';
import '../providers/bill_provider.dart';

class BillsScreen extends ConsumerStatefulWidget {
  final int initialTab;
  const BillsScreen({super.key, this.initialTab = 0});

  @override
  ConsumerState<BillsScreen> createState() => _BillsScreenState();
}

class _BillsScreenState extends ConsumerState<BillsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this, initialIndex: widget.initialTab);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final billsAsync = ref.watch(billListProvider);
    final monthlyTotalAsync = ref.watch(monthlyBillTotalProvider);
    final unpaidBillsAsync = ref.watch(unpaidBillsProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
      appBar: AppBar(
        title: const Text('Bills & Subscriptions', style: TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : const Color(0xFF14102B),
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'All Bills'),
            Tab(text: 'Upcoming'),
            Tab(text: 'Subscriptions'),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Gap(16),
            // ── Summary Cards ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.pagePadding),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.cardDark : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('MONTHLY TOTAL', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                          const Gap(4),
                          monthlyTotalAsync.when(
                            data: (val) => Text(val.asCurrency, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                            loading: () => const Text('\$--'),
                            error: (_, __) => const Text('\$--'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.cardDark : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('UNPAID BILLS', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                          const Gap(4),
                          unpaidBillsAsync.when(
                            data: (list) => Text('${list.length}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: list.isNotEmpty ? AppColors.error : AppColors.success)),
                            loading: () => const Text('--'),
                            error: (_, __) => const Text('--'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Gap(16),

            // ── Tab View Content ───────────────────────────────────────
            Expanded(
              child: billsAsync.when(
                loading: () => const ShimmerLoading(),
                error: (err, _) => Center(child: Text('Error: $err')),
                data: (bills) {
                  return TabBarView(
                    controller: _tabCtrl,
                    children: [
                      _buildBillList(bills, isDark),
                      _buildBillList(bills.where((b) => !b.isPaid).toList(), isDark),
                      _buildBillList(bills.where((b) => b.isSubscription).toList(), isDark),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/dashboard/bills/add'),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildBillList(List<Bill> list, bool isDark) {
    if (list.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.receipt_long_rounded,
        title: 'No Bills Yet',
        subtitle: 'Add upcoming bills or recurring service subscriptions.',
        actionLabel: 'Add Bill',
        onAction: () => context.push('/dashboard/bills/add'),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(AppSizes.pagePadding, 4, AppSizes.pagePadding, 100),
      itemCount: list.length,
      separatorBuilder: (_, __) => const Gap(12),
      itemBuilder: (context, index) {
        final bill = list[index];
        return _BillTile(bill: bill, isDark: isDark, index: index);
      },
    );
  }
}

class _BillTile extends ConsumerWidget {
  final Bill bill;
  final bool isDark;
  final int index;

  const _BillTile({
    required this.bill,
    required this.isDark,
    required this.index,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final daysLeft = bill.dueDate.difference(now).inDays;

    Color badgeColor;
    String badgeText;

    if (bill.isPaid) {
      badgeColor = AppColors.success;
      badgeText = 'Paid';
    } else if (daysLeft < 0) {
      badgeColor = AppColors.error;
      badgeText = 'Overdue';
    } else if (daysLeft <= 3) {
      badgeColor = AppColors.warning;
      badgeText = '$daysLeft days left';
    } else {
      badgeColor = Colors.grey;
      badgeText = '$daysLeft days left';
    }

    return Dismissible(
      key: Key(bill.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      onDismissed: (_) {
        ref.read(billListProvider.notifier).deleteBill(bill.id);
      },
      child: Material(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          bill.name,
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: isDark ? Colors.white : const Color(0xFF14102B)),
                        ),
                        const Gap(8),
                        if (bill.isSubscription)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: const Text('SUB', style: TextStyle(color: AppColors.primary, fontSize: 8, fontWeight: FontWeight.bold)),
                          ),
                      ],
                    ),
                    const Gap(4),
                    Text(
                      'Due ${bill.dueDate.day}/${bill.dueDate.month}/${bill.dueDate.year}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    bill.amount.asCurrency,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: isDark ? Colors.white : const Color(0xFF14102B)),
                  ),
                  const Gap(4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: badgeColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          badgeText,
                          style: TextStyle(color: badgeColor, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Gap(8),
                      if (!bill.isPaid)
                        GestureDetector(
                          onTap: () {
                            ref.read(billListProvider.notifier).markAsPaid(bill.id);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.12), shape: BoxShape.circle),
                            child: const Icon(Icons.check_rounded, color: AppColors.primary, size: 16),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate(delay: (index * 40).ms).fadeIn(duration: 200.ms).slideX(begin: 0.05);
  }
}
