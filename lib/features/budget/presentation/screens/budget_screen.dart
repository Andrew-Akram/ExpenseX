import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/category_constants.dart';
import '../../../../core/extensions/num_extensions.dart';
import '../../../../core/localization/app_lang.dart';
import '../../../analytics/presentation/providers/analytics_provider.dart';
import '../../../budget/domain/entities/budget.dart';
import '../../../categories/presentation/providers/category_provider.dart';
import '../providers/budget_provider.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/app_card.dart';

class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text   = Theme.of(context).textTheme;
    final budgets= ref.watch(budgetListProvider);
    final cats   = ref.watch(categoryListProvider);
    final catTotals= ref.watch(categoryTotalsProvider);
    final monthTotal= ref.watch(monthlyTotalProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(ref.tr('budget')),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _showBudgetDialog(context, ref, null),
          ),
        ],
      ),
      body: budgets.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (list) {
          if (list.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.account_balance_wallet_outlined,
              title: ref.tr('noBudget'),
              subtitle: ref.tr('noBudgetDesc'),
              actionLabel: ref.tr('setBudget'),
              onAction: () => _showBudgetDialog(context, ref, null),
            );
          }

          final now        = DateTime.now();
          final monthly    = list.where((b) =>
                  b.categoryId == null &&
                  b.month == now.month &&
                  b.year == now.year)
              .firstOrNull;
          final perCat     = list.where((b) =>
                  b.categoryId != null &&
                  b.month == now.month &&
                  b.year == now.year)
              .toList();
          final catMap     = cats.maybeWhen(
            data: (c) => {for (final x in c) x.id: x},
            orElse: () => <String, dynamic>{},
          );
          final catTotalsV = catTotals.value ?? {};
          final monthTotalV= monthTotal.value ?? 0;

          return ListView(
            padding: const EdgeInsets.all(AppSizes.pagePadding),
            children: [
              // Overall monthly budget
              Text(ref.tr('monthlyBudget'),
                  style: text.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700)),
              const Gap(AppSizes.sm),
              if (monthly != null)
                _BudgetProgressCard(
                  label: 'Overall',
                  budgeted: monthly.amount,
                  spent: monthTotalV,
                  onEdit: () => _showBudgetDialog(context, ref, monthly),
                  onDelete: () => ref
                      .read(budgetListProvider.notifier)
                      .deleteBudget(monthly.id),
                )
              else
                OutlinedButton.icon(
                  onPressed: () => _showBudgetDialog(context, ref, null),
                  icon: const Icon(Icons.add_rounded),
                  label: Text(ref.tr('setMonthlyBudget')),
                ),
              const Gap(AppSizes.lg),

              // Per-category budgets
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(ref.tr('categoryBudgets'),
                      style: text.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  TextButton.icon(
                    onPressed: () =>
                        _showBudgetDialog(context, ref, null, isCategory: true),
                    icon: const Icon(Icons.add_rounded, size: 16),
                    label: Text(ref.tr('addBudget')),
                  ),
                ],
              ),
              const Gap(AppSizes.sm),
              if (perCat.isEmpty)
                Text(ref.tr('noCategoryBudgets'),
                    style: const TextStyle(color: Colors.grey))
              else
                ...perCat.map((b) {
                  final cat   = catMap[b.categoryId];
                  final spent = catTotalsV[b.categoryId] ?? 0.0;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSizes.sm),
                    child: _BudgetProgressCard(
                      label: cat?.name ?? b.categoryId ?? 'Unknown',
                      budgeted: b.amount,
                      spent: spent,
                      iconName: cat?.iconName,
                      colorValue: cat?.colorValue,
                      onEdit: () => _showBudgetDialog(context, ref, b,
                          isCategory: true),
                      onDelete: () => ref
                          .read(budgetListProvider.notifier)
                          .deleteBudget(b.id),
                    ),
                  );
                }),
            ],
          );
        },
      ),
    );
  }

  void _showBudgetDialog(BuildContext context, WidgetRef ref, Budget? existing,
      {bool isCategory = false}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _BudgetFormSheet(
        existing: existing,
        isCategory: existing?.categoryId != null || isCategory,
      ),
    );
  }
}

class _BudgetProgressCard extends ConsumerWidget {
  final String label;
  final double budgeted;
  final double spent;
  final String? iconName;
  final int? colorValue;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _BudgetProgressCard({
    required this.label,
    required this.budgeted,
    required this.spent,
    this.iconName,
    this.colorValue,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs   = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final pct  = (spent / budgeted).clamp(0.0, 1.0);
    final barColor = pct < 0.8
        ? AppColors.success
        : pct < 1.0
            ? AppColors.warning
            : AppColors.error;

    final catColor = colorValue != null ? Color(colorValue!) : cs.primary;
    final catIcon = iconName != null
        ? CategoryConstants.iconFromKey(iconName!)
        : Icons.account_balance_wallet_rounded;

    return AppCard(
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: catColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                ),
                child: Icon(catIcon, color: catColor, size: 20),
              ),
              const Gap(AppSizes.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: text.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    Text(
                      '${spent.asCurrency} / ${budgeted.asCurrency}',
                      style: text.bodySmall
                          ?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (v) {
                  if (v == 'edit') onEdit();
                  if (v == 'delete') onDelete();
                },
                itemBuilder: (_) => [
                  PopupMenuItem(value: 'edit', child: Text(ref.tr('edit'))),
                  PopupMenuItem(value: 'delete', child: Text(ref.tr('delete'))),
                ],
              ),
            ],
          ),
          const Gap(AppSizes.sm),
          // Budget exceeded warning
          if (pct >= 1.0)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.sm, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              ),
              child: Text(ref.tr('budgetAlertOver'),
                  style: text.labelSmall
                      ?.copyWith(color: AppColors.error)),
            )
          else if (pct >= 0.8)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.sm, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              ),
              child: Text(ref.tr('budgetAlert80'),
                  style: text.labelSmall
                      ?.copyWith(color: AppColors.warning)),
            ),
          const Gap(AppSizes.xs),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radiusFull),
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: cs.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
              minHeight: 8,
            ),
          ),
          const Gap(AppSizes.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${(pct * 100).toStringAsFixed(0)}% ${ref.tr('used')}',
                  style:
                      text.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
              Text('${(budgeted - spent).asCurrency} ${ref.tr('remaining')}',
                  style:
                      text.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
            ],
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1);
  }
}

class _BudgetFormSheet extends ConsumerStatefulWidget {
  final Budget? existing;
  final bool isCategory;
  const _BudgetFormSheet({this.existing, required this.isCategory});

  @override
  ConsumerState<_BudgetFormSheet> createState() => _BudgetFormSheetState();
}

class _BudgetFormSheetState extends ConsumerState<_BudgetFormSheet> {
  final _amtCtrl = TextEditingController();
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      _amtCtrl.text = widget.existing!.amount.toStringAsFixed(2);
      _selectedCategoryId = widget.existing!.categoryId;
    }
  }

  @override
  void dispose() {
    _amtCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cats = ref.watch(categoryListProvider);

    return Padding(
      padding: EdgeInsets.fromLTRB(
          24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(ref.tr('setBudget'),
              style: text.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const Gap(AppSizes.lg),
          if (widget.isCategory)
            cats.when(
              loading: () =>
                  const CircularProgressIndicator(),
              error: (_, __) => const Text('Error'),
              data: (list) => DropdownButtonFormField<String>(
                initialValue: _selectedCategoryId,
                decoration: InputDecoration(labelText: ref.tr('category')),
                items: list
                    .map((c) => DropdownMenuItem(
                          value: c.id,
                          child: Text(c.name),
                        ))
                    .toList(),
                onChanged: (v) =>
                    setState(() => _selectedCategoryId = v),
              ),
            ),
          if (widget.isCategory) const Gap(AppSizes.md),
          TextFormField(
            controller: _amtCtrl,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: ref.tr('budgetAmount'),
              prefixText: '\$ ',
            ),
          ),
          const Gap(AppSizes.lg),
          ElevatedButton(
            onPressed: _save,
            child: Text(ref.tr('save')),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final amount = double.tryParse(_amtCtrl.text.replaceAll(',', ''));
    if (amount == null || amount <= 0) return;

    final now = DateTime.now();
    final budget = Budget(
      id: widget.existing?.id ?? const Uuid().v4(),
      categoryId:
          widget.isCategory ? _selectedCategoryId : null,
      amount: amount,
      month: now.month,
      year: now.year,
    );
    await ref.read(budgetListProvider.notifier).setBudget(budget);
    if (mounted) Navigator.pop(context);
  }
}
