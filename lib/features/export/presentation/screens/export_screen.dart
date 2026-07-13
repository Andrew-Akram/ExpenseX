import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../providers/export_provider.dart';
import '../../../../shared/widgets/app_card.dart';

class ExportScreen extends ConsumerWidget {
  const ExportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs     = Theme.of(context).colorScheme;
    final text   = Theme.of(context).textTheme;
    final export = ref.watch(exportProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.export)),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.pagePadding),
        children: [
          // Hero icon
          Center(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.file_download_rounded,
                  size: 48, color: Colors.white),
            ).animate().scale(curve: Curves.elasticOut),
          ),
          const Gap(AppSizes.lg),
          Text(
            'Export your expense report',
            style:
                text.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          const Gap(AppSizes.sm),
          Text(
            'All expenses are included in the report.',
            style:
                text.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          const Gap(AppSizes.xxl),

          // PDF card
          _ExportOptionCard(
            icon: Icons.picture_as_pdf_rounded,
            color: const Color(0xFFEF4444),
            title: AppStrings.exportPdf,
            subtitle: 'A formatted PDF report with table and totals',
            onTap: export.isLoading
                ? null
                : () => ref
                    .read(exportProvider.notifier)
                    .exportAndShare(ExportFormat.pdf),
          ),
          const Gap(AppSizes.md),

          // CSV card
          _ExportOptionCard(
            icon: Icons.table_chart_rounded,
            color: const Color(0xFF10B981),
            title: AppStrings.exportCsv,
            subtitle: 'Raw data in CSV format for spreadsheets',
            onTap: export.isLoading
                ? null
                : () => ref
                    .read(exportProvider.notifier)
                    .exportAndShare(ExportFormat.csv),
          ),
          const Gap(AppSizes.lg),

          // Loading / error state
          if (export.isLoading)
            const Column(
              children: [
                CircularProgressIndicator(),
                Gap(AppSizes.sm),
                Text(AppStrings.generating),
              ],
            ),
          if (export.hasError)
            Text(
              'Export failed: ${export.error}',
              style: TextStyle(color: cs.error),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }
}

class _ExportOptionCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _ExportOptionCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs   = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const Gap(AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: text.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700)),
                const Gap(2),
                Text(subtitle,
                    style: text.bodySmall
                        ?.copyWith(color: cs.onSurfaceVariant)),
              ],
            ),
          ),
          Icon(Icons.share_rounded, color: cs.primary),
        ],
      ),
    ).animate().fadeIn().slideX(begin: 0.1);
  }
}
