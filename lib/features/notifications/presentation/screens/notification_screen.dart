import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/enums/app_enums.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../domain/entities/app_notification.dart';
import '../providers/notification_provider.dart';
import '../../../../core/localization/app_lang.dart';

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final notificationsAsync = ref.watch(notificationListProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
      appBar: AppBar(
        title: Text(ref.tr('notifications'), style: const TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : const Color(0xFF14102B),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(notificationListProvider.notifier).markAllRead();
            },
            child: Text(ref.tr('markAllRead')),
          ),
          const Gap(8),
        ],
      ),
      body: SafeArea(
        child: notificationsAsync.when(
          loading: () => const ShimmerLoading(),
          error: (err, _) => Center(child: Text('${ref.tr('errorPrefix')}: $err')),
          data: (notifications) {
            if (notifications.isEmpty) {
              return EmptyStateWidget(
                icon: Icons.notifications_none_rounded,
                title: ref.tr('allCaughtUp'),
                subtitle: ref.tr('noNotifications'),
                actionLabel: ref.tr('goBack'),
                onAction: () => context.pop(),
              );
            }

            // Group notifications into Today, Yesterday, Earlier
            final now = DateTime.now();
            final today = <AppNotification>[];
            final yesterday = <AppNotification>[];
            final earlier = <AppNotification>[];

            for (final n in notifications) {
              final diff = now.difference(n.date).inDays;
              if (diff == 0 && n.date.day == now.day) {
                today.add(n);
              } else if (diff <= 1 && n.date.day == now.subtract(const Duration(days: 1)).day) {
                yesterday.add(n);
              } else {
                earlier.add(n);
              }
            }

            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.pagePadding),
              children: [
                if (today.isNotEmpty) ...[
                  _buildSectionHeader(ref.tr('today').toUpperCase(), isDark),
                  const Gap(8),
                  ...today.asMap().entries.map((e) => _buildNotificationTile(e.value, isDark, e.key, ref)),
                  const Gap(16),
                ],
                if (yesterday.isNotEmpty) ...[
                  _buildSectionHeader(ref.tr('yesterday').toUpperCase(), isDark),
                  const Gap(8),
                  ...yesterday.asMap().entries.map((e) => _buildNotificationTile(e.value, isDark, e.key, ref)),
                  const Gap(16),
                ],
                if (earlier.isNotEmpty) ...[
                  _buildSectionHeader(ref.tr('earlier').toUpperCase(), isDark),
                  const Gap(8),
                  ...earlier.asMap().entries.map((e) => _buildNotificationTile(e.value, isDark, e.key, ref)),
                  const Gap(16),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white60 : Colors.black45,
        letterSpacing: 1,
      ),
    );
  }

  Widget _buildNotificationTile(AppNotification notification, bool isDark, int index, WidgetRef ref) {
    final color = _getTypeColor(notification.type);
    final icon = _getTypeIcon(notification.type);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () {
            ref.read(notificationListProvider.notifier).markRead(notification.id);
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? Colors.white10 : Colors.black.withOpacity(0.04),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                const Gap(14),

                // Body
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              _localizedTitle(notification, ref),
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: notification.isRead ? FontWeight.w600 : FontWeight.w800,
                                color: isDark ? Colors.white : const Color(0xFF14102B),
                              ),
                            ),
                          ),
                          if (!notification.isRead)
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const Gap(4),
                      Text(
                        _localizedBody(notification, ref),
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                      const Gap(6),
                      Text(
                        '${notification.date.hour}:${notification.date.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate(delay: (index * 30).ms).fadeIn(duration: 180.ms);
  }

  Color _getTypeColor(NotificationType type) {
    switch (type) {
      case NotificationType.budgetExceeded:       return AppColors.error;
      case NotificationType.upcomingBill:         return AppColors.warning;
      case NotificationType.savingsGoalCompleted: return AppColors.success;
      case NotificationType.weeklySummary:
      case NotificationType.monthlySummary:       return AppColors.info;
      case NotificationType.inactiveReminder:     return Colors.purple;
      case NotificationType.general:              return Colors.grey;
    }
  }

  IconData _getTypeIcon(NotificationType type) {
    switch (type) {
      case NotificationType.budgetExceeded:       return Icons.warning_rounded;
      case NotificationType.upcomingBill:         return Icons.receipt_long_rounded;
      case NotificationType.savingsGoalCompleted: return Icons.emoji_events_rounded;
      case NotificationType.weeklySummary:
      case NotificationType.monthlySummary:       return Icons.analytics_rounded;
      case NotificationType.inactiveReminder:     return Icons.notifications_active_rounded;
      case NotificationType.general:              return Icons.notifications_rounded;
    }
  }

  String _localizedTitle(AppNotification n, WidgetRef ref) {
    switch (n.type) {
      case NotificationType.inactiveReminder:
        return ref.tr('notifInactiveTitle');
      case NotificationType.budgetExceeded:
        final isExceeded = n.extra?['isExceeded'] as bool? ?? true;
        return isExceeded ? ref.tr('notifBudgetExceededTitle') : ref.tr('notifBudgetAlertTitle');
      case NotificationType.upcomingBill:
        final billName = n.extra?['billName'] as String?;
        return billName != null ? '${ref.tr('notifBillTitle')}: $billName' : ref.tr('notifBillTitle');
      case NotificationType.savingsGoalCompleted:
        return ref.tr('notifGoalTitle');
      default:
        return n.title;
    }
  }

  String _localizedBody(AppNotification n, WidgetRef ref) {
    switch (n.type) {
      case NotificationType.inactiveReminder:
        return ref.tr('notifInactiveBody');
      case NotificationType.budgetExceeded:
        final isExceeded = n.extra?['isExceeded'] as bool? ?? true;
        return isExceeded ? ref.tr('notifBudgetExceededBody') : ref.tr('notifBudgetAlertBody');
      case NotificationType.upcomingBill:
        final daysLeft = n.extra?['daysLeft'] as int?;
        final billAmount = n.extra?['billAmount'] as double?;
        if (daysLeft != null && billAmount != null) {
          return '${ref.tr('notifBillDue')} $daysLeft ${ref.tr('notifDaysLeft')}';
        }
        return n.body;
      case NotificationType.savingsGoalCompleted:
        final goalName = n.extra?['goalName'] as String?;
        if (goalName != null) {
          return '${ref.tr('notifGoalCompletedBody')} ($goalName)';
        }
        return ref.tr('notifGoalCompletedBody');
      default:
        return n.body;
    }
  }
}
