import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/localization/app_lang.dart';

/// Full-screen or inline error state with retry option.
class AppErrorWidget extends ConsumerWidget {
  final String? message;
  final VoidCallback? onRetry;

  const AppErrorWidget({super.key, this.message, this.onRetry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs   = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: cs.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.error_outline_rounded,
                  size: 40, color: cs.error),
            ),
            const Gap(AppSizes.lg),
            Text(
              ref.tr('somethingWrong'),
              style: text.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const Gap(AppSizes.sm),
            Text(
              message ?? ref.tr('tryAgain'),
              style: text.bodySmall
                  ?.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const Gap(AppSizes.lg),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(ref.tr('retry')),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
