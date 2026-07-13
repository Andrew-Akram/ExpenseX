import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/di/providers.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../../expenses/presentation/providers/expense_provider.dart';
import '../../../budget/presentation/providers/budget_provider.dart';
import '../../../savings/presentation/providers/savings_provider.dart';
import '../../../bills/presentation/providers/bill_provider.dart';
import '../../../../core/enums/app_enums.dart';

final notificationListProvider =
    AsyncNotifierProvider<NotificationNotifier, List<AppNotification>>(
  NotificationNotifier.new,
);

class NotificationNotifier extends AsyncNotifier<List<AppNotification>> {
  NotificationRepository get _repo => ref.read(notificationRepositoryProvider);

  @override
  Future<List<AppNotification>> build() => _repo.getNotifications();

  Future<void> addNotification(AppNotification n) async {
    await _repo.addNotification(n);
    ref.invalidateSelf();
  }

  Future<void> markRead(String id) async {
    await _repo.markAsRead(id);
    ref.invalidateSelf();
  }

  Future<void> markAllRead() async {
    await _repo.markAllAsRead();
    ref.invalidateSelf();
  }

  Future<void> clearOld() async {
    await _repo.clearOldNotifications();
    ref.invalidateSelf();
  }
}

final unreadCountProvider = FutureProvider<int>((ref) async {
  final list = await ref.watch(notificationListProvider.future);
  return list.where((n) => !n.isRead).length;
});

final checkAndGenerateNotificationsProvider = FutureProvider<void>((ref) async {
  final expenses = await ref.watch(expenseListProvider.future);
  final budgets = await ref.watch(budgetListProvider.future);
  final savings = await ref.watch(savingsGoalListProvider.future);
  final bills = await ref.watch(billListProvider.future);
  final notifications = await ref.watch(notificationListProvider.future);

  final notifier = ref.read(notificationListProvider.notifier);
  final now = DateTime.now();

  // Helper to check if a type was notified in the last 24 hours
  bool hasRecentlyNotified(NotificationType type, {String? targetId}) {
    return notifications.any((n) {
      if (n.type != type) return false;
      if (now.difference(n.date).inHours > 24) return false;
      if (targetId != null && n.extra?['targetId'] != targetId) return false;
      return true;
    });
  }

  // Rule A: Inactivity (no expenses in last 3 days)
  final lastExpense = expenses
      .where((e) => !e.isDeleted)
      .toList()
    ..sort((a, b) => b.date.compareTo(a.date));

  if (lastExpense.isEmpty || now.difference(lastExpense.first.date).inDays >= 3) {
    if (!hasRecentlyNotified(NotificationType.inactiveReminder)) {
      await notifier.addNotification(AppNotification(
        id: const Uuid().v4(),
        title: 'Track Your Expenses',
        body: "You haven't added any expenses in the last 3 days. Stay on top of your budget!",
        date: now,
        type: NotificationType.inactiveReminder,
      ));
    }
  }

  // Rule B: Budget limit (>80% used)
  for (final budget in budgets) {
    if (budget.categoryId != null) {
      final monthlySpent = expenses
          .where((e) =>
              e.categoryId == budget.categoryId &&
              e.date.month == now.month &&
              e.date.year == now.year &&
              e.type == TransactionType.expense &&
              !e.isDeleted)
          .fold(0.0, (sum, e) => sum + e.amount);

      if (monthlySpent >= budget.amount) {
        if (!hasRecentlyNotified(NotificationType.budgetExceeded, targetId: budget.id)) {
          await notifier.addNotification(AppNotification(
            id: const Uuid().v4(),
            title: 'Budget Exceeded!',
            body: 'You have exceeded your budget for category ID: ${budget.categoryId}.',
            date: now,
            type: NotificationType.budgetExceeded,
            extra: {
              'targetId': budget.id,
              'categoryId': budget.categoryId,
              'isExceeded': true,
            },
          ));
        }
      } else if (monthlySpent >= budget.amount * 0.8) {
        if (!hasRecentlyNotified(NotificationType.budgetExceeded, targetId: budget.id)) {
          await notifier.addNotification(AppNotification(
            id: const Uuid().v4(),
            title: 'Budget Alert',
            body: 'You have spent over 80% of your category budget.',
            date: now,
            type: NotificationType.budgetExceeded,
            extra: {
              'targetId': budget.id,
              'categoryId': budget.categoryId,
              'isExceeded': false,
            },
          ));
        }
      }
    }
  }

  // Rule C: Upcoming Bills (due in next 3 days)
  for (final bill in bills) {
    if (!bill.isPaid) {
      final daysLeft = bill.dueDate.difference(now).inDays;
      if (daysLeft >= 0 && daysLeft <= 3) {
        if (!hasRecentlyNotified(NotificationType.upcomingBill, targetId: bill.id)) {
          await notifier.addNotification(AppNotification(
            id: const Uuid().v4(),
            title: 'Upcoming Bill: ${bill.name}',
            body: 'Your bill of \$${bill.amount.toStringAsFixed(2)} is due in $daysLeft days.',
            date: now,
            type: NotificationType.upcomingBill,
            extra: {
              'targetId': bill.id,
              'billName': bill.name,
              'billAmount': bill.amount,
              'daysLeft': daysLeft,
            },
          ));
        }
      }
    }
  }

  // Rule D: Savings Goal Completed
  for (final goal in savings) {
    if (goal.isCompleted || goal.currentAmount >= goal.targetAmount) {
      if (!hasRecentlyNotified(NotificationType.savingsGoalCompleted, targetId: goal.id)) {
        await notifier.addNotification(AppNotification(
          id: const Uuid().v4(),
          title: 'Goal Achieved! 🏆',
          body: 'Congratulations! You reached your savings target for "${goal.name}".',
          date: now,
          type: NotificationType.savingsGoalCompleted,
          extra: {
            'targetId': goal.id,
            'goalName': goal.name,
          },
        ));
      }
    }
  }
});
