import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/app_date_utils.dart';
import '../../../analytics/presentation/providers/analytics_provider.dart';
import '../../../../shared/widgets/app_card.dart';

class MiniBarChart extends ConsumerWidget {
  const MiniBarChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final daily = ref.watch(dailyTotals7Provider);

    return AppCard(
      padding: const EdgeInsets.all(AppSizes.cardPadding),
      child: SizedBox(
        height: AppSizes.chartHeight,
        child: daily.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) =>
              const Center(child: Text('No data')),
          data: (map) {
            final now = DateTime.now();
            final days = List.generate(
              7,
              (i) => DateTime(
                  now.year, now.month, now.day - (6 - i)),
            );
            final maxVal = days
                .map((d) => map[d] ?? 0.0)
                .fold(0.0, (a, b) => a > b ? a : b);
            final groups = days.asMap().entries.map((entry) {
              final d = entry.value;
              final val = map[d] ?? 0.0;
              return BarChartGroupData(
                x: entry.key,
                barRods: [
                  BarChartRodData(
                    toY: val,
                    width: 22,
                    borderRadius:
                        BorderRadius.circular(AppSizes.radiusSm),
                    gradient: val > 0
                        ? AppColors.primaryGradient
                        : null,
                    color: val > 0 ? null : cs.surfaceContainerHighest,
                  ),
                ],
              );
            }).toList();

            return BarChart(
              BarChartData(
                maxY: maxVal * 1.3 + 1,
                barGroups: groups,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) =>
                      FlLine(color: cs.outlineVariant.withOpacity(0.3)),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (val, _) {
                        final d = days[val.toInt()];
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            AppDateUtils.formatWeekday(d),
                            style: TextStyle(
                              fontSize: 10,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (_, __, rod, ___) => BarTooltipItem(
                      '\$${rod.toY.toStringAsFixed(2)}',
                      TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
