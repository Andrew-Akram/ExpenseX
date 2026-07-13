/// Core enums for the Smart Expense Tracker.
/// Stored as string names in Hive to maintain schema flexibility.

// ── Transaction Type ──────────────────────────────────────────────────────────
enum TransactionType {
  income,
  expense,
  transfer;

  String get label {
    switch (this) {
      case TransactionType.income:   return 'Income';
      case TransactionType.expense:  return 'Expense';
      case TransactionType.transfer: return 'Transfer';
    }
  }

  static TransactionType fromString(String? v) =>
      TransactionType.values.firstWhere(
        (e) => e.name == v,
        orElse: () => TransactionType.expense,
      );
}

// ── Wallet Type ───────────────────────────────────────────────────────────────
enum WalletType {
  cash,
  bank,
  visa,
  mastercard,
  vodafoneCash,
  instapay,
  other;

  String get label {
    switch (this) {
      case WalletType.cash:         return 'Cash';
      case WalletType.bank:         return 'Bank Account';
      case WalletType.visa:         return 'Visa';
      case WalletType.mastercard:   return 'Mastercard';
      case WalletType.vodafoneCash: return 'Vodafone Cash';
      case WalletType.instapay:     return 'InstaPay';
      case WalletType.other:        return 'Other';
    }
  }

  static WalletType fromString(String? v) =>
      WalletType.values.firstWhere(
        (e) => e.name == v,
        orElse: () => WalletType.cash,
      );
}

// ── Recurring Interval ────────────────────────────────────────────────────────
enum RecurringInterval {
  none,
  daily,
  weekly,
  monthly,
  yearly;

  String get label {
    switch (this) {
      case RecurringInterval.none:    return 'None';
      case RecurringInterval.daily:   return 'Daily';
      case RecurringInterval.weekly:  return 'Weekly';
      case RecurringInterval.monthly: return 'Monthly';
      case RecurringInterval.yearly:  return 'Yearly';
    }
  }

  static RecurringInterval fromString(String? v) =>
      RecurringInterval.values.firstWhere(
        (e) => e.name == v,
        orElse: () => RecurringInterval.none,
      );
}

// ── Budget Period ─────────────────────────────────────────────────────────────
enum BudgetPeriod {
  monthly,
  weekly;

  String get label {
    switch (this) {
      case BudgetPeriod.monthly: return 'Monthly';
      case BudgetPeriod.weekly:  return 'Weekly';
    }
  }

  static BudgetPeriod fromString(String? v) =>
      BudgetPeriod.values.firstWhere(
        (e) => e.name == v,
        orElse: () => BudgetPeriod.monthly,
      );
}

// ── Notification Type ─────────────────────────────────────────────────────────
enum NotificationType {
  budgetExceeded,
  upcomingBill,
  savingsGoalCompleted,
  weeklySummary,
  monthlySummary,
  inactiveReminder,
  general;

  String get label {
    switch (this) {
      case NotificationType.budgetExceeded:       return 'Budget Exceeded';
      case NotificationType.upcomingBill:         return 'Upcoming Bill';
      case NotificationType.savingsGoalCompleted: return 'Goal Completed';
      case NotificationType.weeklySummary:        return 'Weekly Summary';
      case NotificationType.monthlySummary:       return 'Monthly Summary';
      case NotificationType.inactiveReminder:     return 'Reminder';
      case NotificationType.general:              return 'Notification';
    }
  }

  static NotificationType fromString(String? v) =>
      NotificationType.values.firstWhere(
        (e) => e.name == v,
        orElse: () => NotificationType.general,
      );
}
