import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../../../core/constants/app_colors.dart';
import '../../../../core/enums/app_enums.dart';
import '../../../../core/extensions/num_extensions.dart';
import '../../../../core/localization/app_lang.dart';
import '../../../analytics/presentation/providers/analytics_provider.dart';
import '../../../categories/presentation/providers/category_provider.dart';
import '../../../settings/presentation/providers/settings_provider.dart';

// ── Period selector state ─────────────────────────────────────────────────────
enum _Period { weekly, monthly, yearly }

// ─────────────────────────────────────────────────────────────────────────────
class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});
  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  _Period _period = _Period.monthly;

  void _selectPeriod(_Period p) {
    if (p == _period) return;
    setState(() => _period = p);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: _AnalyticsHeader(
              isDark: isDark,
              period: _period,
              onSelect: _selectPeriod,
            ),
          ),
          SliverToBoxAdapter(child: _AnalyticsBody(isDark: isDark)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HEADER
// ─────────────────────────────────────────────────────────────────────────────
class _AnalyticsHeader extends ConsumerWidget {
  final bool isDark;
  final _Period period;
  final ValueChanged<_Period> onSelect;
  const _AnalyticsHeader({
    required this.isDark,
    required this.period,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    String t(String key) => ref.tr(key);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
            const Color(0xFF241A57).withOpacity(0.55),
            AppColors.surfaceDark,
          ]
              : [
            const Color(0xFFC3B9FF),
            const Color(0xFFEDEBFF),
            AppColors.surface,
          ],
          stops: isDark ? const [0.0, 1.0] : const [0.0, 0.55, 1.0],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    t('navAnalytics'),
                    style: text.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF14102B),
                      fontSize: 26,
                      letterSpacing: -0.6,
                    ),
                  ).animate().fadeIn(duration: 350.ms).slideX(begin: -0.03, end: 0),
                  Row(
                    children: [
                      _LegendDot(color: AppColors.primary, label: t('income')),
                      const Gap(14),
                      _LegendDot(
                        color: const Color(0xFF7FD99A),
                        label: t('expense'),
                      ),
                    ],
                  ).animate().fadeIn(duration: 350.ms, delay: 60.ms),
                ],
              ),
              const Gap(22),
              _PeriodSegmentedControl(period: period, onSelect: onSelect)
                  .animate()
                  .fadeIn(duration: 350.ms, delay: 90.ms)
                  .slideY(begin: 0.1, end: 0, curve: Curves.easeOut),
              const Gap(20),
              _ChartCard(isDark: isDark, period: period)
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 130.ms)
                  .slideY(begin: 0.06, end: 0, curve: Curves.easeOut),
              const Gap(20),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Body cards
// ─────────────────────────────────────────────────────────────────────────────
class _AnalyticsBody extends ConsumerWidget {
  final bool isDark;
  const _AnalyticsBody({required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SummaryRow(isDark: isDark)
              .animate()
              .fadeIn(duration: 350.ms, delay: 150.ms)
              .slideY(begin: 0.06, end: 0, curve: Curves.easeOut),
          const Gap(20),
          _DetailCard(isDark: isDark)
              .animate()
              .fadeIn(duration: 350.ms, delay: 190.ms)
              .slideY(begin: 0.05, end: 0, curve: Curves.easeOut),
          const Gap(20),
          _DonutCard(isDark: isDark)
              .animate()
              .fadeIn(duration: 400.ms, delay: 230.ms)
              .slideY(begin: 0.05, end: 0, curve: Curves.easeOut),
          const Gap(20),
          _CategoryBreakdown(isDark: isDark)
              .animate()
              .fadeIn(duration: 400.ms, delay: 270.ms)
              .slideY(begin: 0.05, end: 0, curve: Curves.easeOut),
          const Gap(20),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable premium card shell (color-tinted layered shadow, not flat gray)
// ─────────────────────────────────────────────────────────────────────────────
BoxDecoration _premiumCardDecoration({
  required bool isDark,
  double radius = 22,
  Color? tint,
}) {
  final glow = tint ?? AppColors.primary;
  return BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark
          ? [const Color(0xFF141414), const Color(0xFF101010)]
          : [Colors.white, const Color(0xFFFCFBFF)],
    ),
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(
      color: isDark ? Colors.white.withOpacity(0.06) : Colors.white,
      width: 1,
    ),
    boxShadow: [
      BoxShadow(
        color: glow.withOpacity(isDark ? 0.10 : 0.08),
        blurRadius: 40,
        spreadRadius: -12,
        offset: const Offset(0, 20),
      ),
      BoxShadow(
        color: Colors.black.withOpacity(isDark ? 0.35 : 0.045),
        blurRadius: 10,
        offset: const Offset(0, 3),
      ),
    ],
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Segmented period control
// ─────────────────────────────────────────────────────────────────────────────
class _PeriodSegmentedControl extends ConsumerWidget {
  final _Period period;
  final ValueChanged<_Period> onSelect;
  const _PeriodSegmentedControl({required this.period, required this.onSelect});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    const items = _Period.values;
    final labels = {
      _Period.weekly: ref.tr('weekly'),
      _Period.monthly: ref.tr('monthly'),
      _Period.yearly: ref.tr('yearly'),
    };
    final selectedIndex = items.indexOf(period);

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161616) : Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.07) : Colors.black.withOpacity(0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.25) : Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final segmentWidth = constraints.maxWidth / items.length;
          final double leftPos = isRtl
              ? segmentWidth * (items.length - 1 - selectedIndex)
              : segmentWidth * selectedIndex;

          return Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                left: leftPos,
                width: segmentWidth,
                top: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withOpacity(0.82),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.32),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: items.map((p) {
                  final selected = p == period;
                  return Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onSelect(p),
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          letterSpacing: -0.1,
                          color: selected
                              ? Colors.white
                              : (isDark ? Colors.white54 : Colors.black45),
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Text(labels[p]!),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Main dual-bar Chart Card
// ─────────────────────────────────────────────────────────────────────────────
class _ChartCard extends ConsumerWidget {
  final bool isDark;
  final _Period period;
  const _ChartCard({required this.isDark, required this.period});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final langCode = ref.watch(localeProvider).languageCode;
    final monthly = ref.watch(monthly12TotalsProvider);
    final monthlyIncome = ref.watch(monthly12IncomeTotalsProvider);
    final weekly = ref.watch(dailyTotals7Provider);
    final weeklyIncome = ref.watch(dailyIncome7Provider);

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 22, 22, 14),
      decoration: _premiumCardDecoration(isDark: isDark, radius: 26),
      child: SizedBox(
        height: 230,
        child: period == _Period.weekly
            ? weekly.when(
          loading: () => _chartLoading(),
          error: (_, __) => _chartError(ref),
          data: (expMap) => weeklyIncome.when(
            loading: () => _chartLoading(),
            error: (_, __) => _chartError(ref),
            data: (incMap) => _DualBarChart(
              isDark: isDark,
              labels: _last7DayLabels(langCode),
              incomeData: _weekly7RodData(incMap),
              expenseData: _weekly7RodData(expMap),
            ),
          ),
        )
            : monthly.when(
          loading: () => _chartLoading(),
          error: (_, __) => _chartError(ref),
          data: (expEntries) => monthlyIncome.when(
            loading: () => _chartLoading(),
            error: (_, __) => _chartError(ref),
            data: (incEntries) => _DualBarChart(
              isDark: isDark,
              labels: expEntries
                  .map((e) => DateFormat('MMM', langCode).format(e.key))
                  .toList(),
              incomeData: incEntries.map((e) => e.value).toList(),
              expenseData: expEntries.map((e) => e.value).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _chartLoading() => const Center(
    child: CircularProgressIndicator(
      color: AppColors.primary,
      strokeWidth: 2,
    ),
  );

  Widget _chartError(WidgetRef ref) => Center(
    child: Text(
      ref.tr('noData'),
      style: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
    ),
  );

  List<String> _last7DayLabels(String locale) {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final d = now.subtract(Duration(days: 6 - i));
      return DateFormat('E', locale).format(d);
    });
  }

  List<double> _weekly7RodData(Map<DateTime, double> map) {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final d = DateTime(now.year, now.month, now.day - (6 - i));
      return map[d] ?? 0.0;
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Dual grouped bar chart — same math/spacing logic, refreshed visuals
// ─────────────────────────────────────────────────────────────────────────────
class _DualBarChart extends StatelessWidget {
  final bool isDark;
  final List<String> labels;
  final List<double> incomeData;
  final List<double> expenseData;
  const _DualBarChart({
    required this.isDark,
    required this.labels,
    required this.incomeData,
    required this.expenseData,
  });

  @override
  Widget build(BuildContext context) {
    final count = math.min(labels.length, math.min(incomeData.length, expenseData.length));
    final allVals = [...incomeData.take(count), ...expenseData.take(count)];
    final maxValRaw = allVals.isEmpty ? 1.0 : allVals.reduce(math.max) * 1.3;
    final maxVal = maxValRaw <= 0.0 ? 10.0 : maxValRaw;

    final barWidth = count <= 7 ? 11.0 : (count <= 10 ? 8.0 : 6.0);
    final barsSpace = count <= 7 ? 4.0 : 2.5;
    final groupsSpace = count <= 7 ? 14.0 : (count <= 10 ? 8.0 : 5.0);

    final labelInterval = count > 9 ? 2 : 1;

    final y1 = (maxVal / 3).roundToDouble();
    final y2 = (maxVal * 2 / 3).roundToDouble();
    final y3 = maxVal.roundToDouble();
    final gridColor = isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.05);
    final labelColor = isDark ? Colors.white38 : Colors.black38;

    final incomeGradient = LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: [AppColors.primary.withOpacity(0.75), AppColors.primary],
    );
    final expenseGradient = const LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: [Color(0xFF5FC17F), Color(0xFF7FD99A)],
    );

    return BarChart(
      BarChartData(
        maxY: maxVal,
        alignment: BarChartAlignment.spaceEvenly,
        groupsSpace: groupsSpace,
        barGroups: List.generate(count, (i) {
          return BarChartGroupData(
            x: i,
            groupVertically: false,
            barsSpace: barsSpace,
            barRods: [
              BarChartRodData(
                toY: incomeData[i],
                width: barWidth,
                borderRadius: BorderRadius.circular(6),
                gradient: incomeGradient,
              ),
              BarChartRodData(
                toY: expenseData[i],
                width: barWidth,
                borderRadius: BorderRadius.circular(6),
                gradient: expenseGradient,
              ),
            ],
          );
        }),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxVal / 3,
          getDrawingHorizontalLine: (_) => FlLine(color: gridColor, strokeWidth: 1, dashArray: [4, 4]),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 44,
              interval: maxVal / 3,
              getTitlesWidget: (val, _) {
                String label;
                if (val == 0) {
                  label = '\$0';
                } else if (val.round() == y1.round()) {
                  label = '\$${y1.toInt()}';
                } else if (val.round() == y2.round()) {
                  label = '\$${y2.toInt()}';
                } else if (val.round() == y3.round()) {
                  label = '\$${y3.toInt()}';
                } else {
                  return const SizedBox.shrink();
                }
                return Text(
                  label,
                  style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600, color: labelColor),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 26,
              getTitlesWidget: (val, _) {
                final i = val.toInt();
                if (i < 0 || i >= labels.length) return const SizedBox.shrink();
                if (i % labelInterval != 0) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    labels[i],
                    style: TextStyle(
                      fontSize: 10,
                      color: labelColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => isDark ? const Color(0xFF1E1E1E) : Colors.white,
            tooltipBorder: BorderSide(
              color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06),
            ),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final isIncome = rodIndex == 0;
              return BarTooltipItem(
                '\$${rod.toY.toStringAsFixed(0)}',
                TextStyle(
                  color: isIncome ? AppColors.primary : const Color(0xFF4CAF50),
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}


class _SummaryRow extends ConsumerWidget {
  final bool isDark;
  const _SummaryRow({required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monthlyExpenses = ref.watch(monthlyTotalProvider);
    final monthlyIncome = ref.watch(monthlyIncomeTotalProvider);
    final prevExpenses = ref.watch(prevMonthExpensesTotalProvider);
    final prevIncome = ref.watch(prevMonthIncomeTotalProvider);
    String t(String key) => ref.tr(key);

    return Row(
      children: [
        Expanded(
          child: monthlyIncome.when(
            loading: () => _loadingTile(),
            error: (_, __) => _errorTile(ref),
            data: (income) => _SummaryTile(
              isDark: isDark,
              iconBg: AppColors.primary,
              icon: Icons.savings_rounded,
              amount: income.asCurrency,
              label: t('income'),
              prevValue: prevIncome.value,
              currentValue: income,
              positiveIsGood: true,
            ),
          ),
        ),
        const Gap(14),
        Expanded(
          child: monthlyExpenses.when(
            loading: () => _loadingTile(),
            error: (_, __) => _errorTile(ref),
            data: (expense) => _SummaryTile(
              isDark: isDark,
              iconBg: const Color(0xFF4CAF50),
              icon: Icons.receipt_long_rounded,
              amount: expense.asCurrency,
              label: t('expense'),
              prevValue: prevExpenses.value,
              currentValue: expense,
              positiveIsGood: false,
            ),
          ),
        ),
      ],
    );
  }

  Widget _loadingTile() => const SizedBox(
    height: 96,
    child: Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2)),
  );
  Widget _errorTile(WidgetRef ref) => SizedBox(
    height: 96,
    child: Center(
      child: Text(ref.tr('noData'), style: TextStyle(color: isDark ? Colors.white38 : Colors.black38)),
    ),
  );
}

class _SummaryTile extends StatelessWidget {
  final bool isDark;
  final Color iconBg;
  final IconData icon;
  final String amount;
  final String label;
  final double? prevValue;
  final double currentValue;
  final bool positiveIsGood;
  const _SummaryTile({
    required this.isDark,
    required this.iconBg,
    required this.icon,
    required this.amount,
    required this.label,
    required this.prevValue,
    required this.currentValue,
    required this.positiveIsGood,
  });

  @override
  Widget build(BuildContext context) {
    double? pctChange;
    if (prevValue != null && prevValue! > 0) {
      pctChange = ((currentValue - prevValue!) / prevValue!) * 100;
    }
    final isUp = (pctChange ?? 0) >= 0;
    final isGood = positiveIsGood ? isUp : !isUp;
    final trendColor = isGood ? const Color(0xFF4CAF50) : const Color(0xFFE17055);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: _premiumCardDecoration(isDark: isDark, radius: 20, tint: iconBg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [iconBg.withOpacity(0.22), iconBg.withOpacity(0.10)],
                  ),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: iconBg, size: 20),
              ),
              if (pctChange != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: trendColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isUp ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                        size: 11,
                        color: trendColor,
                      ),
                      const Gap(2),
                      Text(
                        '${pctChange.abs().toStringAsFixed(0)}%',
                        style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: trendColor),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const Gap(14),
          Text(
            amount,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
              color: isDark ? Colors.white : const Color(0xFF14102B),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const Gap(3),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white54 : Colors.black45,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Income & Expense detail rows
// ─────────────────────────────────────────────────────────────────────────────
class _DetailCard extends ConsumerWidget {
  final bool isDark;
  const _DetailCard({required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monthlyExpenses = ref.watch(monthlyTotalProvider);
    final monthlyIncome = ref.watch(monthlyIncomeTotalProvider);
    final prevExpenses = ref.watch(prevMonthExpensesTotalProvider);
    final prevIncome = ref.watch(prevMonthIncomeTotalProvider);
    String t(String key) => ref.tr(key);

    return Container(
      decoration: _premiumCardDecoration(isDark: isDark),
      child: Column(
        children: [
          monthlyIncome.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            error: (_, __) => const SizedBox.shrink(),
            data: (income) {
              final prevIncVal = prevIncome.value ?? 0.0;
              final diff = (income - prevIncVal).abs();
              final isMore = income >= prevIncVal;
              final subtitle = prevIncVal == 0
                  ? t('navAnalytics')
                  : '${diff.asCurrency} ${isMore ? t('moreLastMonth') : t('lessLastMonth')}';
              return _DetailRow(
                isDark: isDark,
                icon: Icons.savings_rounded,
                iconColor: AppColors.primary,
                title: t('income'),
                subtitle: subtitle,
                amount: income.asCurrency,
              );
            },
          ),
          Divider(
            height: 1,
            color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.05),
            indent: 16,
            endIndent: 16,
          ),
          monthlyExpenses.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            error: (_, __) => const SizedBox.shrink(),
            data: (expense) {
              final prevExpVal = prevExpenses.value ?? 0.0;
              final diff = (expense - prevExpVal).abs();
              final isMore = expense >= prevExpVal;
              final subtitle = prevExpVal == 0
                  ? t('navAnalytics')
                  : '${diff.asCurrency} ${isMore ? t('moreLastMonth') : t('lessLastMonth')}';
              return _DetailRow(
                isDark: isDark,
                icon: Icons.receipt_long_rounded,
                iconColor: const Color(0xFF4CAF50),
                title: t('expense'),
                subtitle: subtitle,
                amount: expense.asCurrency,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final bool isDark;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String amount;
  const _DetailRow({
    required this.isDark,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [iconColor.withOpacity(0.20), iconColor.withOpacity(0.10)],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14.5,
                    letterSpacing: -0.1,
                    color: isDark ? Colors.white : const Color(0xFF14102B),
                  ),
                ),
                const Gap(2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 11.5, color: isDark ? Colors.white38 : Colors.black38),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 14.5,
              letterSpacing: -0.2,
              color: isDark ? Colors.white : const Color(0xFF14102B),
            ),
          ),
          const Gap(6),
          Icon(
            Directionality.of(context) == TextDirection.rtl
                ? Icons.arrow_back_ios_new_rounded
                : Icons.arrow_forward_ios_rounded,
            size: 12,
            color: isDark ? Colors.white24 : Colors.black26,
          ),
        ],
      ),
    );
  }
}


class _DonutCard extends ConsumerWidget {
  final bool isDark;
  const _DonutCard({required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final langCode = ref.watch(localeProvider).languageCode;
    final monthlyExpenses = ref.watch(monthlyTotalProvider);
    final monthlyIncome = ref.watch(monthlyIncomeTotalProvider);
    final monthLabel = DateFormat('MMMM', langCode).format(DateTime.now());
    String t(String key) => ref.tr(key);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF211A4A), const Color(0xFF121212)]
              : [const Color(0xFFEEEBFF), Colors.white],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.07) : Colors.white,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(isDark ? 0.16 : 0.14),
            blurRadius: 44,
            spreadRadius: -14,
            offset: const Offset(0, 20),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: monthlyExpenses.when(
        loading: () => const SizedBox(
          height: 200,
          child: Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2)),
        ),
        error: (_, __) => const SizedBox.shrink(),
        data: (expense) => monthlyIncome.when(
          loading: () => const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2)),
          ),
          error: (_, __) => const SizedBox.shrink(),
          data: (income) {
            final expensePct = income > 0 ? (expense / income).clamp(0.0, 1.0) : 0.0;
            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${t('overview')} · $monthLabel',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.1,
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: (expensePct < 0.6 ? const Color(0xFF4CAF50) : Colors.orange)
                            .withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            expensePct < 0.6 ? Icons.trending_down_rounded : Icons.trending_up_rounded,
                            size: 13,
                            color: expensePct < 0.6 ? const Color(0xFF4CAF50) : Colors.orange,
                          ),
                          const Gap(3),
                          Text(
                            '${(expensePct * 100).toStringAsFixed(0)}% ${t('spent')}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: expensePct < 0.6 ? const Color(0xFF4CAF50) : Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Gap(24),
                SizedBox(
                  height: 190,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          sectionsSpace: 6,
                          centerSpaceRadius: 62,
                          startDegreeOffset: -90,
                          sections: [
                            PieChartSectionData(
                              value: expensePct,
                              color: AppColors.primary,
                              radius: 18,
                              showTitle: false,
                            ),
                            PieChartSectionData(
                              value: 1.0 - expensePct,
                              color: const Color(0xFF7FD99A),
                              radius: 18,
                              showTitle: false,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 108,
                        height: 108,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark ? const Color(0xFF181818) : Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: isDark ? Colors.black.withOpacity(0.4) : Colors.black.withOpacity(0.06),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              expense.asCurrency,
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w900,
                                color: isDark ? Colors.white : const Color(0xFF14102B),
                                letterSpacing: -0.5,
                              ),
                            ),
                            const Gap(2),
                            Text(
                              '${t('of')} ${income.asCurrency}',
                              style: TextStyle(
                                fontSize: 10.5,
                                color: isDark ? Colors.white54 : Colors.black45,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _LegendDot(
                      color: AppColors.primary,
                      label: '${t('expense')} ${(expensePct * 100).toStringAsFixed(0)}%',
                    ),
                    const Gap(20),
                    _LegendDot(
                      color: const Color(0xFF7FD99A),
                      label: '${t('income')} ${((1 - expensePct) * 100).toStringAsFixed(0)}%',
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Category breakdown list — with rank badges (visual only, same sorted data)
// ─────────────────────────────────────────────────────────────────────────────
class _CategoryBreakdown extends ConsumerWidget {
  final bool isDark;
  const _CategoryBreakdown({required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cats = ref.watch(categoryTotalsProvider);
    final catList = ref.watch(categoryListProvider);
    final text = Theme.of(context).textTheme;
    String t(String key) => ref.tr(key);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t('categoryBreakdown'),
          style: text.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            letterSpacing: -0.3,
            color: isDark ? Colors.white : const Color(0xFF14102B),
          ),
        ),
        const Gap(14),
        cats.when(
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2)),
          error: (_, __) => const SizedBox.shrink(),
          data: (totals) {
            if (totals.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 32),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.02),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  t('noExpensesThisMonth'),
                  style: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
                ),
              );
            }
            final catMap = catList.maybeWhen(
              data: (list) => {for (final c in list) c.id: c},
              orElse: () => <String, dynamic>{},
            );
            final total = totals.values.fold(0.0, (a, b) => a + b);
            final sorted = totals.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
            return Container(
              decoration: _premiumCardDecoration(isDark: isDark),
              child: Column(
                children: sorted.asMap().entries.map((entry) {
                  final i = entry.key;
                  final e = entry.value;
                  final cat = catMap[e.key];
                  final color = cat != null ? Color(cat.colorValue) : AppColors.primary;
                  final pct = total > 0 ? e.value / total : 0.0;
                  final isTop = i == 0;
                  return Column(
                    children: [
                      if (i > 0)
                        Divider(
                          height: 1,
                          color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.05),
                          indent: 16,
                          endIndent: 16,
                        ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 26,
                                  height: 26,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: isTop
                                        ? color.withOpacity(0.16)
                                        : (isDark
                                        ? Colors.white.withOpacity(0.05)
                                        : Colors.black.withOpacity(0.04)),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    '${i + 1}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: isTop ? color : (isDark ? Colors.white38 : Colors.black38),
                                    ),
                                  ),
                                ),
                                const Gap(10),
                                Container(
                                  width: 9,
                                  height: 9,
                                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                                ),
                                const Gap(8),
                                Expanded(
                                  child: Text(
                                    cat?.name ?? e.key,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      letterSpacing: -0.1,
                                      color: isDark ? Colors.white : const Color(0xFF14102B),
                                    ),
                                  ),
                                ),
                                Text(
                                  e.value.asCurrency,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                    letterSpacing: -0.1,
                                    color: isDark ? Colors.white : const Color(0xFF14102B),
                                  ),
                                ),
                                const Gap(6),
                                Text(
                                  '${(pct * 100).toStringAsFixed(0)}%',
                                  style: TextStyle(fontSize: 11, color: isDark ? Colors.white38 : Colors.black38),
                                ),
                              ],
                            ),
                            const Gap(9),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: pct,
                                minHeight: 5,
                                backgroundColor: isDark ? Colors.white10 : color.withOpacity(0.1),
                                valueColor: AlwaysStoppedAnimation<Color>(color),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            );
          },
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared legend dot
// ─────────────────────────────────────────────────────────────────────────────
class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const Gap(5),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white60 : Colors.black54,
          ),
        ),
      ],
    );
  }
}