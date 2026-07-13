import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/num_extensions.dart';
import '../../../analytics/presentation/providers/analytics_provider.dart';
import '../../../categories/presentation/providers/category_provider.dart';
import '../providers/dashboard_provider.dart';
import '../../../../shared/widgets/app_card.dart';

class TodaySpendCard extends ConsumerWidget {
  const TodaySpendCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs   = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final today = ref.watch(todayTotalProvider);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                ),
                child: Icon(Icons.today_rounded,
                    size: AppSizes.iconSm, color: cs.primary),
              ),
              const Gap(AppSizes.sm),
              Text(AppStrings.today,
                  style: text.labelMedium
                      ?.copyWith(color: cs.onSurfaceVariant)),
            ],
          ),
          const Gap(AppSizes.sm),
          today.when(
            loading: () =>
                const CircularProgressIndicator.adaptive(),
            error: (_, __) =>
                const Text('--'),
            data: (amount) => Text(
              amount.asCurrency,
              style: text.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class TopCategoryCard extends ConsumerWidget {
  const TopCategoryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs   = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final top  = ref.watch(topCategoryProvider);
    final cats = ref.watch(categoryListProvider);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFBE0B).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                ),
                child: const Icon(Icons.emoji_events_rounded,
                    size: AppSizes.iconSm, color: Color(0xFFFFBE0B)),
              ),
              const Gap(AppSizes.sm),
              Text(AppStrings.topCategory,
                  style: text.labelMedium
                      ?.copyWith(color: cs.onSurfaceVariant)),
            ],
          ),
          const Gap(AppSizes.sm),
          top.when(
            loading: () =>
                const CircularProgressIndicator.adaptive(),
            error: (_, __) => const Text('--'),
            data: (entry) {
              if (entry == null) {
                return Text('None yet',
                    style: text.bodySmall
                        ?.copyWith(color: cs.onSurfaceVariant));
              }
              final catName = cats.maybeWhen(
                data: (list) =>
                    list
                        .where((c) => c.id == entry.key)
                        .firstOrNull
                        ?.name ??
                    entry.key,
                orElse: () => entry.key,
              );
              return Text(
                catName,
                style:
                    text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              );
            },
          ),
        ],
      ),
    );
  }
}
