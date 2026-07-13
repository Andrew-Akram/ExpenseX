import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';

import '../../../../core/di/providers.dart';
import '../../domain/entities/auth_state.dart';
import '../../domain/repositories/auth_repository.dart';

import '../../../categories/presentation/providers/category_provider.dart';
import '../../../expenses/presentation/providers/expense_provider.dart';
import '../../../budget/presentation/providers/budget_provider.dart';
import '../../../wallets/presentation/providers/wallet_provider.dart';
import '../../../savings/presentation/providers/savings_provider.dart';
import '../../../bills/presentation/providers/bill_provider.dart';
import '../../../notifications/presentation/providers/notification_provider.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../../analytics/presentation/providers/analytics_provider.dart';
import '../../../analytics/presentation/providers/ai_insights_provider.dart';
import '../../../dashboard/presentation/providers/dashboard_provider.dart';

// Firestore Seeding
import '../../../categories/data/datasources/category_firestore_datasource.dart';
import '../../../expenses/data/datasources/expense_firestore_datasource.dart';
import '../../../wallets/data/datasources/wallet_firestore_datasource.dart';


// ── Lock Policy Constants ─────────────────────────────────────────────────────
// Possible values for the 'pin_lock_policy' Hive key
class LockPolicy {
  static const String onLaunch     = 'launch';        // lock on startup only
  static const String inactivity5  = 'inactivity_5';  // 5 min idle
  static const String inactivity10 = 'inactivity_10'; // 10 min idle
  static const String inactivity15 = 'inactivity_15'; // 15 min idle
  static const String never        = 'never';          // never until sign out
}

// ── Auth State ─────────────────────────────────────────────────────────────────

final authStateProvider =
    NotifierProvider<AuthNotifier, AuthAppState>(AuthNotifier.new);

class AuthNotifier extends Notifier<AuthAppState> {
  AuthRepository get _repo => ref.read(authRepositoryProvider);
  Timer? _inactivityTimer;

  /// Current Firebase user UID, falls back to 'guest' before login.
  String get _userId => fb.FirebaseAuth.instance.currentUser?.uid ?? 'guest';

  /// Lock policy is stored per-user so accounts don't share settings.
  String get _lockPolicy =>
      Hive.box('settings').get('pin_lock_policy_$_userId', defaultValue: LockPolicy.onLaunch) as String;

  /// Returns the inactivity duration in minutes for the current policy.
  /// Returns null if the policy does not use a timer.
  int? get _inactivityMinutes {
    switch (_lockPolicy) {
      case LockPolicy.inactivity5:  return 5;
      case LockPolicy.inactivity10: return 10;
      case LockPolicy.inactivity15: return 15;
      default: return null;
    }
  }

  /// Seeds default data for this user in Firestore on first login.
  Future<void> _seedUserData() async {
    await CategoryFirestoreDataSource.seedDefaultCategories();
    // Do not seed default expenses so new accounts start empty.
    await WalletFirestoreDataSource.seedDefaultWallet();
  }

  @override
  AuthAppState build() {
    _init();
    return const AuthAppState();
  }

  Future<void> _init() async {
    final pinSetup           = await _repo.isPinSetup();
    final biometricEnabled   = await _repo.isBiometricEnabled();
    final biometricAvailable = await _repo.isBiometricAvailable();

    // Check remember_me status
    final box      = Hive.box('settings');
    final rememberMe = box.get('remember_me', defaultValue: true) as bool;
    if (!rememberMe && _repo.isUserLoggedIn()) {
      await _repo.signOut();
    }

    // Fetch onboarding status (Always false on startup to make onboarding always appear)
    const onboardingCompleted = false;

    // Listen to Firebase Auth state changes dynamically
    fb.FirebaseAuth.instance.authStateChanges().listen((fb.User? user) async {
      if (user != null) {
        final pinSetup = await _repo.isPinSetup();
        state = state.copyWith(
          isFirebaseLoggedIn: true,
          isPinSetup: pinSetup,
        );
      } else {
        state = state.copyWith(
          isFirebaseLoggedIn: false,
          isPinSetup: false,
          isAuthenticated: false,
        );
      }
    });

    // For 'never' policy: auto-authenticate the user (no PIN on launch)
    final policy = _lockPolicy;
    final autoAuth = policy == LockPolicy.never;

    state = state.copyWith(
      isPinSetup:            pinSetup,
      isBiometricEnabled:    biometricEnabled,
      isBiometricAvailable:  biometricAvailable,
      isOnboardingCompleted: onboardingCompleted,
      isFirebaseLoggedIn:    _repo.isUserLoggedIn(),
      isAuthenticated:       autoAuth,
    );
  }

  void finishSplash() {
    state = state.copyWith(isSplashFinished: true);
  }

  Future<void> completeOnboarding() async {
    final box = Hive.box('settings');
    await box.put('onboarding_completed', true);
    state = state.copyWith(isOnboardingCompleted: true);
  }

  Future<void> signUpWithEmail(String email, String password,
      {String? fullName}) async {
    await _repo.signUpWithEmailAndPassword(email, password, fullName: fullName);
    await _seedUserData();
    _invalidateDataProviders();
    state = state.copyWith(
      isFirebaseLoggedIn: true,
      isPinSetup: false,
      isAuthenticated: false,
    );
  }

  Future<void> signInWithEmail(String email, String password) async {
    await _repo.signInWithEmailAndPassword(email, password);
    await _seedUserData();
    _invalidateDataProviders();
    final pinSetup = await _repo.isPinSetup();
    state = state.copyWith(
      isFirebaseLoggedIn: true,
      isPinSetup: pinSetup,
      isAuthenticated: false,
    );
  }

  Future<void> signInWithGoogle() async {
    await _repo.signInWithGoogle();
    await _seedUserData();
    _invalidateDataProviders();
    final pinSetup = await _repo.isPinSetup();
    state = state.copyWith(
      isFirebaseLoggedIn: true,
      isPinSetup: pinSetup,
      isAuthenticated: false,
    );
  }

  Future<void> signOut() async {
    // 1. Sign out from Firebase (+ Google).
    //    We do NOT clear the user's Hive boxes — their data is preserved on
    //    this device and will be reloaded if they sign in again.
    await _repo.signOut();
    _inactivityTimer?.cancel();

    // 2. Invalidate providers so the next account starts with a fresh state.
    _invalidateDataProviders();

    // 3. Update auth state.
    state = state.copyWith(
      isFirebaseLoggedIn: false,
      isAuthenticated: false,
      isPinSetup: false,
    );
  }

  void _invalidateDataProviders() {
    ref.invalidate(profilePhotoPathProvider);
    ref.invalidate(categoryListProvider);
    ref.invalidate(expenseListProvider);
    ref.invalidate(budgetListProvider);
    ref.invalidate(walletListProvider);
    ref.invalidate(savingsGoalListProvider);
    ref.invalidate(billListProvider);
    ref.invalidate(notificationListProvider);

    // Invalidate sub/derived providers and dashboard/insights
    ref.invalidate(filteredExpensesProvider);
    ref.invalidate(currentMonthBudgetProvider);
    ref.invalidate(walletBalancesProvider);
    ref.invalidate(totalAssetsProvider);
    ref.invalidate(totalSavedAmountProvider);
    ref.invalidate(upcomingBillsProvider);
    ref.invalidate(unpaidBillsProvider);
    ref.invalidate(monthlyBillTotalProvider);
    ref.invalidate(unreadCountProvider);
    ref.invalidate(checkAndGenerateNotificationsProvider);
    ref.invalidate(monthlyTotalProvider);
    ref.invalidate(todayTotalProvider);
    ref.invalidate(categoryTotalsProvider);
    ref.invalidate(dailyTotals30Provider);
    ref.invalidate(dailyTotals7Provider);
    ref.invalidate(monthly12TotalsProvider);
    ref.invalidate(aiInsightsProvider);
    ref.invalidate(topCategoryProvider);
    ref.invalidate(recentExpensesProvider);
  }

  Future<bool> setupPin(String pin) async {
    await _repo.setupPin(pin);
    state = state.copyWith(isPinSetup: true, isAuthenticated: true);
    userActivityDetected();
    return true;
  }

  Future<bool> verifyPin(String pin) async {
    final ok = await _repo.verifyPin(pin);
    if (ok) {
      state = state.copyWith(isAuthenticated: true);
      userActivityDetected();
    }
    return ok;
  }

  Future<bool> authenticateBiometric() async {
    final ok = await _repo.authenticateWithBiometric();
    if (ok) {
      state = state.copyWith(isAuthenticated: true);
      userActivityDetected();
    }
    return ok;
  }

  Future<void> toggleBiometric(bool enabled) async {
    await _repo.setBiometricEnabled(enabled);
    state = state.copyWith(isBiometricEnabled: enabled);
  }

  Future<void> changePin(String newPin) async {
    await _repo.setupPin(newPin);
  }

  // ── Profile Updates ────────────────────────────────────────────────────────

  Future<void> updateDisplayName(String name) async {
    await _repo.updateDisplayName(name);
  }

  Future<void> updatePassword(String newPassword) async {
    await _repo.updatePassword(newPassword);
  }

  String? get currentDisplayName  => _repo.currentUserDisplayName;
  String? get currentEmail        => _repo.currentUserEmail;
  DateTime? get creationTime      => _repo.currentUserCreationTime;
  String get currentLockPolicy    => _lockPolicy;


  // ── Lock Policy ────────────────────────────────────────────────────────────

  void updateLockPolicy(String policy) {
    // Store lock policy under the current user's UID key
    Hive.box('settings').put('pin_lock_policy_$_userId', policy);
    if (policy == LockPolicy.never) {
      _inactivityTimer?.cancel();
      if (!state.isAuthenticated) {
        state = state.copyWith(isAuthenticated: true);
      }
    } else {
      userActivityDetected();
    }
  }

  // ── Activity Timer ─────────────────────────────────────────────────────────

  void userActivityDetected() {
    if (!state.isAuthenticated) return;
    _inactivityTimer?.cancel();

    final minutes = _inactivityMinutes;
    if (minutes != null) {
      _inactivityTimer = Timer(Duration(minutes: minutes), () {
        lock();
      });
    }
    // For 'launch' or 'never' policy: no timer needed
  }

  void stopInactivityTimer() {
    _inactivityTimer?.cancel();
  }

  void lock() {
    // Do not lock if policy is 'never'
    if (_lockPolicy == LockPolicy.never) return;
    _inactivityTimer?.cancel();
    state = state.copyWith(isAuthenticated: false);
  }

  /// Skip authentication (for testing/development fallback).
  void skipAuth() {
    assert(kDebugMode, 'skipAuth() must only be called in debug mode');
    if (!kDebugMode) return;
    state = state.copyWith(
      isOnboardingCompleted: true,
      isFirebaseLoggedIn:    true,
      isPinSetup:            false,
      isAuthenticated:       true,
    );
    userActivityDetected();
  }
}
