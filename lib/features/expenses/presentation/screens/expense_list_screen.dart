import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/category_constants.dart';
import '../../../../core/extensions/num_extensions.dart';
import '../../../../core/extensions/date_extensions.dart';
import '../../../../core/enums/app_enums.dart';
import '../../../../core/localization/app_lang.dart';
import '../../../categories/domain/entities/category.dart';
import '../../../categories/presentation/providers/category_provider.dart';
import '../../../wallets/presentation/providers/wallet_provider.dart';
import '../../domain/entities/expense.dart';
import '../../domain/entities/expense_filter.dart';
import '../providers/expense_filter_provider.dart';
import '../providers/expense_provider.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/app_error_widget.dart';

class ExpenseListScreen extends ConsumerStatefulWidget {
  const ExpenseListScreen({super.key});
  @override
  ConsumerState<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends ConsumerState<ExpenseListScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filter = ref.watch(expenseFilterProvider);
    final expenses = ref.watch(filteredExpensesProvider);
    final cats = ref.watch(categoryListProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Top bar ─────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                child: Row(
                  children: [
                    Text(
                      ref.tr('navExpenses'),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: isDark ? Colors.white : const Color(0xFF14102B),
                      ),
                    ),
                    const Spacer(),
                    _CircleIconButton(
                      icon: Icons.sort_rounded,
                      isDark: isDark,
                      onTap: () => _showSortSheet(context, ref),
                    ),
                    const Gap(8),
                    _CircleIconButton(
                      icon: Icons.filter_list_rounded,
                      isDark: isDark,
                      onTap: () => _showFilterSheet(context, ref),
                    ),
                  ],
                ),
              ),
            ),
            // ── Financial tools chips ────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                child: Row(
                  children: [
                    _ToolChip(
                      icon: Icons.account_balance_wallet_rounded,
                      label: ref.tr('myWallets'),
                      isDark: isDark,
                      onTap: () => context.push('/expenses/wallets'),
                    ),
                    const Gap(10),
                    _ToolChip(
                      icon: Icons.pie_chart_rounded,
                      label: ref.tr('manageBudgets'),
                      isDark: isDark,
                      onTap: () => context.push('/expenses/budget'),
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: Gap(12)),

            // ── Search bar (pill style) ──────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (q) =>
                      ref.read(expenseFilterProvider.notifier).setSearch(q),
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF14102B),
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: ref.tr('searchExpenses'),
                    hintStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: isDark ? Colors.white54 : Colors.black45,
                    ),
                    suffixIcon: _searchCtrl.text.isNotEmpty
                        ? IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: isDark ? Colors.white54 : Colors.black45,
                      ),
                      onPressed: () {
                        _searchCtrl.clear();
                        ref
                            .read(expenseFilterProvider.notifier)
                            .setSearch('');
                        setState(() {});
                      },
                    )
                        : null,
                    filled: true,
                    fillColor: isDark ? const Color(0xFF141414) : Colors.white,
                    contentPadding:
                    const EdgeInsets.symmetric(vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color:
                        isDark ? Colors.white10 : Colors.black.withOpacity(0.06),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color:
                        isDark ? Colors.white10 : Colors.black.withOpacity(0.06),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide:
                      const BorderSide(color: AppColors.primary, width: 1.5),
                    ),
                  ),
                  onTapOutside: (_) {},
                ),
              ),
            ),
            const SliverToBoxAdapter(child: Gap(16)),

            // ── Category filter chips ────────────────────────────────
            SliverToBoxAdapter(
              child: cats.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (list) => _CategoryFilterChips(
                  categories: list,
                  selected: filter.categoryId,
                  isDark: isDark,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: Gap(12)),

            // ── Date range row ───────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    if (filter.dateFrom != null || filter.dateTo != null) ...[
                      Expanded(
                        child: _DateRangeChip(
                          label: _dateRangeLabel(filter, ref),
                          isDark: isDark,
                          onDeleted: () => ref
                              .read(expenseFilterProvider.notifier)
                              .setDateRange(null, null),
                        ),
                      ),
                      const Gap(10),
                    ] else
                      const Spacer(),
                    _DatePickerButton(
                      isDark: isDark,
                      onTap: () => _pickDateRange(context, ref),
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: Gap(12)),

            // ── Expense list ──────────────────────────────────────────
            ...expenses.when(
              loading: () => [
                const SliverToBoxAdapter(
                  child: ShimmerLoading(),
                ),
              ],
              error: (e, _) => [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: AppErrorWidget(
                    message: e.toString(),
                    onRetry: () => ref.invalidate(filteredExpensesProvider),
                  ),
                ),
              ],
              data: (list) {
                if (list.isEmpty) {
                  return [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: EmptyStateWidget(
                        icon: Icons.receipt_long_rounded,
                        title: ref.tr('noExpenses'),
                        subtitle: ref.tr('noExpensesDesc'),
                        actionLabel: ref.tr('addExpense'),
                        onAction: () => context.push('/expenses/add'),
                      ),
                    ),
                  ];
                }
                return [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) {
                          final expense = list[i];
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: i == list.length - 1 ? 0 : 12,
                            ),
                            child: _ExpenseTile(
                              expense: expense,
                              index: i,
                              cats: cats.value ?? [],
                              isDark: isDark,
                            ),
                          );
                        },
                        childCount: list.length,
                      ),
                    ),
                  ),
                ];
              },
            ),
          ],
        ),
      ),

    );
  }

  String _dateRangeLabel(ExpenseFilter f, WidgetRef ref) {
    final from =
    f.dateFrom != null ? '${f.dateFrom!.day}/${f.dateFrom!.month}' : '';
    final to = f.dateTo != null ? '${f.dateTo!.day}/${f.dateTo!.month}' : '';
    if (from.isEmpty && to.isNotEmpty) return '${ref.tr('dateUntil')} $to';
    if (from.isNotEmpty && to.isEmpty) return '${ref.tr('dateFrom')} $from';
    return '$from – $to';
  }

  Future<void> _pickDateRange(BuildContext context, WidgetRef ref) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (ctx, child) {
        return Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: Theme.of(ctx).colorScheme.copyWith(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: isDark ? const Color(0xFF141414) : Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (range != null) {
      ref
          .read(expenseFilterProvider.notifier)
          .setDateRange(range.start, range.end);
    }
  }

  void _showSortSheet(BuildContext context, WidgetRef ref) {
    final filter = ref.read(expenseFilterProvider);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _SortSheet(current: filter.sortOrder),
    ).then((order) {
      if (order is SortOrder) {
        ref.read(expenseFilterProvider.notifier).setSortOrder(order);
      }
    });
  }

  void _showFilterSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _FilterSheet(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Circular icon button — matches other screens' top-bar buttons
// ─────────────────────────────────────────────────────────────────────────
class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isDark;

  const _CircleIconButton({
    required this.icon,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.08) : Colors.white,
          shape: BoxShape.circle,
          boxShadow: isDark
              ? null
              : [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 18,
          color: isDark ? Colors.white : const Color(0xFF14102B),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Category filter chips — pill style, colored per category
// ─────────────────────────────────────────────────────────────────────────
class _CategoryFilterChips extends ConsumerWidget {
  final List<Category> categories;
  final String? selected;
  final bool isDark;

  const _CategoryFilterChips({
    required this.categories,
    required this.selected,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: 40,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        children: [
          _FilterPill(
            label: AppStrings.allCategories,
            color: AppColors.primary,
            selected: selected == null,
            isDark: isDark,
            onTap: () =>
                ref.read(expenseFilterProvider.notifier).setCategory(null),
          ),
          ...categories.map(
                (c) => Padding(
              padding: const EdgeInsets.only(left: 8),
              child: _FilterPill(
                label: c.name,
                color: Color(c.colorValue),
                icon: CategoryConstants.iconFromKey(c.iconName),
                selected: selected == c.id,
                isDark: isDark,
                onTap: () => ref
                    .read(expenseFilterProvider.notifier)
                    .setCategory(selected == c.id ? null : c.id),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;

  const _FilterPill({
    required this.label,
    required this.color,
    required this.selected,
    required this.isDark,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? color
              : isDark
              ? const Color(0xFF141414)
              : Colors.white,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: selected
                ? color
                : isDark
                ? Colors.white10
                : Colors.black.withOpacity(0.08),
          ),
          boxShadow: selected
              ? [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: selected
                    ? Colors.white
                    : isDark
                    ? Colors.white70
                    : Colors.black54,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected
                    ? Colors.white
                    : isDark
                    ? Colors.white70
                    : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Date range chip (active filter) + date picker trigger button
// ─────────────────────────────────────────────────────────────────────────
class _DateRangeChip extends StatelessWidget {
  final String label;
  final bool isDark;
  final VoidCallback onDeleted;

  const _DateRangeChip({
    required this.label,
    required this.isDark,
    required this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.date_range_rounded,
              size: 14, color: AppColors.primary),
          const Gap(6),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Gap(6),
          GestureDetector(
            onTap: onDeleted,
            child: const Icon(Icons.close_rounded,
                size: 14, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}

class _DatePickerButton extends ConsumerWidget {
  final bool isDark;
  final VoidCallback onTap;

  const _DatePickerButton({required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF141414) : Colors.white,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: isDark ? Colors.white10 : Colors.black.withOpacity(0.08),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_month_rounded,
              size: 15,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
            const Gap(6),
            Text(
              ref.tr('date'),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Expense list tile — matches RecentTransactionsList card styling
// ─────────────────────────────────────────────────────────────────────────
class _ExpenseTile extends ConsumerWidget {
  final Expense expense;
  final int index;
  final List<Category> cats;
  final bool isDark;

  const _ExpenseTile({
    required this.expense,
    required this.index,
    required this.cats,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cat = cats.where((c) => c.id == expense.categoryId).firstOrNull;
    final catColor = cat != null ? Color(cat.colorValue) : AppColors.catOther;
    final catIcon = cat != null
        ? CategoryConstants.iconFromKey(cat.iconName)
        : Icons.category_rounded;

    return Dismissible(
      key: Key(expense.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: isDark ? const Color(0xFF141414) : Colors.white,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
            title: Text(
              ref.tr('deleteConfirmTitle'),
              style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF14102B)),
            ),
            content: Text(
              '${ref.tr('delete')} "${expense.title}"? ${ref.tr('deleteConfirmMsg')}',
              style:
              TextStyle(color: isDark ? Colors.white70 : Colors.black54),
            ),
            actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(
                  ref.tr('cancel'),
                  style: TextStyle(
                    color: isDark ? Colors.white60 : Colors.black54,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.error,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(ref.tr('delete')),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) =>
          ref.read(expenseListProvider.notifier).deleteExpense(expense.id),
      child: Material(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.hardEdge,
        elevation: 0,
        child: InkWell(
          onTap: () =>
              context.push('/expenses/${expense.id}', extra: expense),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              boxShadow: isDark
                  ? null
                  : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: catColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(catIcon, color: catColor, size: 22),
                ),
                const Gap(14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        expense.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14.5,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF14102B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Gap(3),
                      Text(
                        '${cat?.name ?? expense.categoryId} • ${expense.date.relative}',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: isDark ? Colors.white54 : Colors.black45,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      expense.type == TransactionType.income
                          ? '+${expense.amount.asCurrency}'
                          : expense.type == TransactionType.transfer
                              ? expense.amount.asCurrency
                              : '-${expense.amount.asCurrency}',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: expense.type == TransactionType.income
                            ? AppColors.success
                            : expense.type == TransactionType.transfer
                                ? AppColors.primary
                                : AppColors.error,
                      ),
                    ),
                    if (expense.note != null && expense.note!.isNotEmpty) ...[
                      const Gap(4),
                      Icon(
                        Icons.notes_rounded,
                        size: 13,
                        color: isDark ? Colors.white30 : Colors.black26,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate(delay: (index * 40).ms).fadeIn(duration: 250.ms).slideX(begin: 0.05);
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Sort bottom sheet — rounded card, matches app dialog/card language
// ─────────────────────────────────────────────────────────────────────────
class _SortSheet extends ConsumerWidget {
  final SortOrder current;
  const _SortSheet({required this.current});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final items = [
      (SortOrder.dateDesc, ref.tr('newestFirst'), Icons.arrow_downward_rounded),
      (SortOrder.dateAsc, ref.tr('oldestFirst'), Icons.arrow_upward_rounded),
      (SortOrder.amountDesc, ref.tr('highestAmount'), Icons.attach_money_rounded),
      (SortOrder.amountAsc, ref.tr('lowestAmount'), Icons.money_off_rounded),
      (SortOrder.category, ref.tr('byCategory'), Icons.category_rounded),
    ];

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141414) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
              const Gap(20),
              Text(
                ref.tr('sortBy'),
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF14102B),
                ),
              ),
              const Gap(12),
              ...items.map((item) {
                final isSelected = current == item.$1;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Material(
                    color: isSelected
                        ? AppColors.primary.withOpacity(0.10)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => Navigator.pop(context, item.$1),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        child: Row(
                          children: [
                            Icon(
                              item.$3,
                              size: 20,
                              color: isSelected
                                  ? AppColors.primary
                                  : isDark
                                  ? Colors.white60
                                  : Colors.black54,
                            ),
                            const Gap(14),
                            Text(
                              item.$2,
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isSelected
                                    ? AppColors.primary
                                    : isDark
                                    ? Colors.white
                                    : const Color(0xFF14102B),
                              ),
                            ),
                            const Spacer(),
                            if (isSelected)
                              const Icon(Icons.check_rounded,
                                  size: 18, color: AppColors.primary),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Advanced Filter Bottom Sheet Widget
// ─────────────────────────────────────────────────────────────────────────
class _FilterSheet extends ConsumerStatefulWidget {
  const _FilterSheet();
  @override
  ConsumerState<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends ConsumerState<_FilterSheet> {
  TransactionType? _type;
  String? _walletId;
  final _minCtrl = TextEditingController();
  final _maxCtrl = TextEditingController();
  bool? _hasReceipt;

  @override
  void initState() {
    super.initState();
    final f = ref.read(expenseFilterProvider);
    _type = f.type;
    _walletId = f.walletId;
    _minCtrl.text = f.amountMin?.toString() ?? '';
    _maxCtrl.text = f.amountMax?.toString() ?? '';
    _hasReceipt = f.hasReceipt;
  }

  @override
  void dispose() {
    _minCtrl.dispose();
    _maxCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final wallets = ref.watch(walletListProvider);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141414) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
            const Gap(20),
            Text(
              ref.tr('advancedFilters'),
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF14102B),
              ),
            ),
            const Gap(20),

            // Type filter
            Text(ref.tr('transactionType'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const Gap(8),
            Row(
              children: [
                _buildTypeButton(ref.tr('allTransactions'), null),
                const Gap(8),
                _buildTypeButton(ref.tr('income'), TransactionType.income),
                const Gap(8),
                _buildTypeButton(ref.tr('expense'), TransactionType.expense),
              ],
            ),
            const Gap(20),

            // Wallet filter
            Text(ref.tr('paymentWallet'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const Gap(8),
            wallets.when(
              data: (list) => DropdownButtonFormField<String>(
                value: _walletId,
                onChanged: (v) => setState(() => _walletId = v),
                decoration: _fieldDecoration(isDark, ref.tr('selectWallet')),
                items: [
                  DropdownMenuItem(value: null, child: Text(ref.tr('allWallets'))),
                  ...list.map((w) => DropdownMenuItem(value: w.id, child: Text(w.name))),
                ],
              ),
              loading: () => const CircularProgressIndicator(),
              error: (_, __) => const Text('Error loading wallets'),
            ),
            const Gap(20),

            // Amount range
            Text(ref.tr('amountRange'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const Gap(8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _minCtrl,
                    keyboardType: TextInputType.number,
                    decoration: _fieldDecoration(isDark, ref.tr('minAmount')),
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: TextField(
                    controller: _maxCtrl,
                    keyboardType: TextInputType.number,
                    decoration: _fieldDecoration(isDark, ref.tr('maxAmount')),
                  ),
                ),
              ],
            ),
            const Gap(20),

            // Has Receipt
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(ref.tr('hasReceipt'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Switch(
                  value: _hasReceipt ?? false,
                  activeColor: AppColors.primary,
                  onChanged: (val) {
                    setState(() => _hasReceipt = val ? true : null);
                  },
                ),
              ],
            ),
            const Gap(30),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      ref.read(expenseFilterProvider.notifier).clearFilters();
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(ref.tr('clearAll')),
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      final notifier = ref.read(expenseFilterProvider.notifier);
                      notifier.setType(_type);
                      notifier.setWallet(_walletId);
                      final min = double.tryParse(_minCtrl.text);
                      final max = double.tryParse(_maxCtrl.text);
                      notifier.setAmountRange(min, max);
                      notifier.setHasReceipt(_hasReceipt);
                      Navigator.pop(context);
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(ref.tr('apply')),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeButton(String label, TransactionType? type) {
    final isSel = _type == type;
    return Expanded(
      child: ChoiceChip(
        label: Text(label),
        selected: isSel,
        onSelected: (val) {
          if (val) setState(() => _type = type);
        },
        selectedColor: AppColors.primary.withOpacity(0.15),
        labelStyle: TextStyle(
          color: isSel ? AppColors.primary : Colors.grey,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration(bool isDark, String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
      filled: true,
      fillColor: isDark ? Colors.white10 : Colors.black.withOpacity(0.04),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Tool chip — compact pill button for Wallets / Budget quick access
// ─────────────────────────────────────────────────────────────────────────
class _ToolChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  final VoidCallback onTap;

  const _ToolChip({
    required this.icon,
    required this.label,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF141414) : Colors.white,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: isDark ? Colors.white10 : Colors.black.withOpacity(0.08),
          ),
          boxShadow: isDark
              ? null
              : [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : const Color(0xFF14102B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}