import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/analytics/presentation/screens/analytics_screen.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/auth_gate_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/pin_entry_screen.dart';
import '../../features/auth/presentation/screens/pin_setup_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/budget/presentation/screens/budget_screen.dart';
import '../../features/categories/presentation/screens/add_edit_category_screen.dart';
import '../../features/categories/presentation/screens/categories_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/expenses/domain/entities/expense.dart';
import '../../features/expenses/presentation/screens/add_edit_expense_screen.dart';
import '../../features/expenses/presentation/screens/expense_detail_screen.dart';
import '../../features/expenses/presentation/screens/expense_list_screen.dart';
import '../../features/export/presentation/screens/export_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/settings/presentation/screens/profile_screen.dart';
import '../../shared/widgets/scaffold_with_nav_bar.dart';

// New Features Screens
import '../../features/wallets/domain/entities/wallet.dart';
import '../../features/wallets/presentation/screens/wallets_screen.dart';
import '../../features/wallets/presentation/screens/add_edit_wallet_screen.dart';
import '../../features/wallets/presentation/screens/transfer_screen.dart';
import '../../features/savings/presentation/screens/savings_screen.dart';
import '../../features/savings/presentation/screens/add_edit_goal_screen.dart';
import '../../features/bills/presentation/screens/bills_screen.dart';
import '../../features/bills/presentation/screens/add_edit_bill_screen.dart';
import '../../features/notifications/presentation/screens/notification_screen.dart';

// Route path constants
class AppRoutes {
  static const String root         = '/';
  static const String onboarding   = '/onboarding';
  static const String login        = '/login';
  static const String signup       = '/signup';
  static const String pinSetup     = '/auth/setup';
  static const String pinEntry     = '/auth/pin';
  static const String dashboard    = '/dashboard';
  static const String expenses     = '/expenses';
  static const String addExpense   = '/expenses/add';
  static const String analytics    = '/analytics';
  static const String profile      = '/profile';
  static const String settings     = '/profile/settings';
  static const String exportData   = '/profile/settings/export';

  // Dashboard sub-routes
  static const String categories   = '/dashboard/categories';
  static const String addCategory  = '/dashboard/categories/add';
  static const String savings      = '/dashboard/savings';
  static const String bills        = '/dashboard/bills';

  // Expenses sub-routes
  static const String wallets      = '/expenses/wallets';
  static const String budget       = '/expenses/budget';
}

// ── Router Notifier ─────────────────────────────────────────────────────────
// Listens to AuthAppState changes and triggers GoRouter redirect re-evaluation
class RouterNotifier extends ChangeNotifier {
  RouterNotifier(Ref ref) {
    ref.listen(
      authStateProvider,
      (_, __) => notifyListeners(),
    );
  }
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

final routerProvider = Provider<GoRouter>((ref) {
  final refreshListenable = ref.watch(routerNotifierProvider);

  return GoRouter(
    initialLocation: AppRoutes.root,
    refreshListenable: refreshListenable,
    redirect: (context, state) {
      final authState         = ref.read(authStateProvider);
      final isSplashFinished  = authState.isSplashFinished;
      final isOnboarding      = authState.isOnboardingCompleted;
      final isFirebaseLoggedIn= authState.isFirebaseLoggedIn;
      final isPinSetup        = authState.isPinSetup;
      final isAuthenticated   = authState.isAuthenticated;
      final loc               = state.uri.toString();

      // 1. Splash screen phase
      if (!isSplashFinished) return AppRoutes.root;

      // 2. Onboarding phase
      if (!isOnboarding) {
        if (loc != AppRoutes.onboarding) return AppRoutes.onboarding;
        return null;
      }

      // 3. Login/Signup phase
      if (!isFirebaseLoggedIn) {
        if (loc != AppRoutes.login && loc != AppRoutes.signup) return AppRoutes.login;
        return null;
      }

      // 4. Local PIN authentication phase
      if (!isPinSetup) {
        if (loc != AppRoutes.pinSetup) return AppRoutes.pinSetup;
        return null;
      }

      if (!isAuthenticated) {
        if (loc != AppRoutes.pinEntry) return AppRoutes.pinEntry;
        return null;
      }

      // 5. Authenticated - prevent access to login/signup/pin setups
      if (loc == AppRoutes.login  ||
          loc == AppRoutes.signup ||
          loc == AppRoutes.onboarding ||
          loc == AppRoutes.pinEntry   ||
          loc == AppRoutes.pinSetup   ||
          loc == AppRoutes.root) {
        return AppRoutes.dashboard;
      }

      return null;
    },
    routes: [
      // Splash/Gate route
      GoRoute(path: AppRoutes.root, builder: (_, __) => const AuthGateScreen()),

      // Onboarding & Auth screens
      GoRoute(path: AppRoutes.onboarding, builder: (_, __) => const OnboardingScreen()),
      GoRoute(path: AppRoutes.login,      builder: (_, __) => const LoginScreen()),
      GoRoute(path: AppRoutes.signup,     builder: (_, __) => const SignupScreen()),
      GoRoute(path: AppRoutes.pinSetup,   builder: (_, __) => const PinSetupScreen()),
      GoRoute(path: AppRoutes.pinEntry,   builder: (_, __) => const PinEntryScreen()),

      // Notifications Center (Full screen)
      GoRoute(path: '/notifications',     builder: (_, __) => const NotificationScreen()),

      // Main shell with bottom nav
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => ScaffoldWithNavBar(navigationShell: shell),
        branches: [
          // ── Dashboard Branch ─────────────────────────────────────────────
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.dashboard,
              builder: (_, __) => const DashboardScreen(),
              routes: [
                // Categories (moved from settings)
                GoRoute(
                  path: 'categories',
                  builder: (_, __) => const CategoriesScreen(),
                  routes: [
                    GoRoute(path: 'add', builder: (_, __) => const AddEditCategoryScreen()),
                    GoRoute(
                      path: ':id/edit',
                      builder: (context, state) =>
                          AddEditCategoryScreen(categoryId: state.pathParameters['id']),
                    ),
                  ],
                ),
                // Savings Goals (moved from settings)
                GoRoute(
                  path: 'savings',
                  builder: (_, __) => const SavingsScreen(),
                  routes: [
                    GoRoute(path: 'add', builder: (_, __) => const AddEditGoalScreen()),
                  ],
                ),
                // Bills & Subscriptions (moved from settings)
                GoRoute(
                  path: 'bills',
                  builder: (context, state) {
                    final tabStr = state.uri.queryParameters['tab'];
                    final tab = tabStr != null ? int.tryParse(tabStr) ?? 0 : 0;
                    return BillsScreen(initialTab: tab);
                  },
                  routes: [
                    GoRoute(path: 'add', builder: (_, __) => const AddEditBillScreen()),
                  ],
                ),
              ],
            ),
          ]),

          // ── Expenses / Transactions Branch ────────────────────────────────
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.expenses,
              builder: (_, __) => const ExpenseListScreen(),
              routes: [
                GoRoute(
                  path: 'add',
                  builder: (_, __) => const AddEditExpenseScreen(),
                ),
                // ── Named routes MUST come before ':id' so they aren't swallowed ──
                // Wallets (moved from settings)
                GoRoute(
                  path: 'wallets',
                  builder: (_, __) => const WalletsScreen(),
                  routes: [
                    GoRoute(path: 'add',      builder: (_, __) => const AddEditWalletScreen()),
                    GoRoute(path: 'transfer', builder: (_, __) => const TransferScreen()),
                    GoRoute(
                      path: ':id/edit',
                      builder: (context, state) {
                        final wallet = state.extra as Wallet?;
                        return AddEditWalletScreen(wallet: wallet);
                      },
                    ),
                  ],
                ),
                // Budget (moved from settings)
                GoRoute(
                  path: 'budget',
                  builder: (_, __) => const BudgetScreen(),
                ),
                // ── Parametric route LAST so it doesn't shadow named routes ──
                GoRoute(
                  path: ':id',
                  builder: (context, state) {
                    final expense = state.extra as Expense?;
                    return ExpenseDetailScreen(expense: expense);
                  },
                  routes: [
                    GoRoute(
                      path: 'edit',
                      builder: (context, state) {
                        final expense = state.extra as Expense?;
                        return AddEditExpenseScreen(expense: expense);
                      },
                    ),
                  ],
                ),
              ],

            ),
          ]),

          // ── Analytics Branch ──────────────────────────────────────────────
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.analytics,
              builder: (_, __) => const AnalyticsScreen(),
            ),
          ]),

          // ── Profile Branch ────────────────────────────────────────────────
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.profile,
              builder: (_, __) => const ProfileScreen(),
              routes: [
                GoRoute(
                  path: 'settings',
                  builder: (_, __) => const SettingsScreen(),
                  routes: [
                    GoRoute(path: 'export', builder: (_, __) => const ExportScreen()),
                  ],
                ),
              ],
            ),
          ]),
        ],
      ),
    ],
  );
});
