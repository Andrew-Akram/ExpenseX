import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/extensions/num_extensions.dart';
import '../../../analytics/presentation/providers/analytics_provider.dart';
import '../../../budget/presentation/providers/budget_provider.dart';
import '../../../../shared/widgets/app_card.dart';

class TotalMonthCard extends ConsumerWidget {
  const TotalMonthCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final total = ref.watch(monthlyTotalProvider);
    final budget = ref.watch(currentMonthBudgetProvider);
    final todayTotal = ref.watch(todayTotalProvider);

    return GradientCard(
      gradient: AppColors.primaryGradient,
      padding: const EdgeInsets.all(AppSizes.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                ),
                child: Row(
                  children: [
                    Text(
                      'Primary Wallet',
                      style: text.bodySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 16),
                  ],
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
                onPressed: () {},
              ),
            ],
          ),
          const Gap(AppSizes.md),
          Text(
            'Total Expenses',
            style: text.bodySmall?.copyWith(color: Colors.white.withValues(alpha: 0.7)),
          ),
          const Gap(4),
          Row(
            children: [
              total.when(
                loading: () => const _PlaceholderText(),
                error: (_, __) => const Text('--', style: TextStyle(fontSize: 28, color: Colors.white)),
                data: (amount) => Text(
                  amount.asCurrency,
                  style: text.headlineLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Gap(8),
              const Icon(Icons.visibility_rounded, color: Colors.white70, size: 20),
            ],
          ),
          const Gap(AppSizes.lg),
          Divider(color: Colors.white.withValues(alpha: 0.15), height: 1),
          const Gap(AppSizes.md),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.arrow_upward_rounded, color: Colors.greenAccent, size: 14),
                        const Gap(4),
                        Text(
                          'Monthly Budget',
                          style: text.labelSmall?.copyWith(color: Colors.white70),
                        ),
                      ],
                    ),
                    const Gap(4),
                    budget.when(
                      loading: () => const Text('...', style: TextStyle(color: Colors.white)),
                      error: (_, __) => const Text('--', style: TextStyle(color: Colors.white)),
                      data: (b) => Text(
                        b?.amount.asCurrency ?? 'No Limit',
                        style: text.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 32,
                width: 1,
                color: Colors.white.withValues(alpha: 0.15),
              ),
              const Gap(AppSizes.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.arrow_downward_rounded, color: Colors.redAccent, size: 14),
                        const Gap(4),
                        Text(
                          'Spent Today',
                          style: text.labelSmall?.copyWith(color: Colors.white70),
                        ),
                      ],
                    ),
                    const Gap(4),
                    todayTotal.when(
                      loading: () => const Text('...', style: TextStyle(color: Colors.white)),
                      error: (_, __) => const Text('--', style: TextStyle(color: Colors.white)),
                      data: (amount) => Text(
                        amount.asCurrency,
                        style: text.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PlaceholderText extends StatelessWidget {
  const _PlaceholderText();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
      ),
    );
  }
}
