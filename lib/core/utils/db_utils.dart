import 'package:hive_ce/hive.dart';

import '../../features/budget/data/models/budget_model.dart';
import '../../features/categories/data/models/category_model.dart';
import '../../features/expenses/data/models/expense_model.dart';
import '../../features/wallets/data/models/wallet_model.dart';
import '../../features/savings/data/models/savings_goal_model.dart';
import '../../features/bills/data/models/bill_model.dart';
import '../../features/notifications/data/models/notification_model.dart';

class DbUtils {
  DbUtils._();

  static Future<void> openUserBoxes(String uid) async {
    await Hive.openBox<CategoryModel>('categories_$uid');
    await Hive.openBox<ExpenseModel>('expenses_$uid');
    await Hive.openBox<BudgetModel>('budgets_$uid');
    await Hive.openBox<WalletModel>('wallets_$uid');
    await Hive.openBox<SavingsGoalModel>('savings_goals_$uid');
    await Hive.openBox<BillModel>('bills_$uid');
    await Hive.openBox<NotificationModel>('notifications_$uid');
  }
}
