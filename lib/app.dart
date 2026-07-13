import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/settings/presentation/providers/settings_provider.dart';
import 'features/notifications/presentation/providers/notification_provider.dart';

class SmartExpenseTrackerApp extends ConsumerWidget {
  const SmartExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final locale    = ref.watch(localeProvider);
    final router    = ref.watch(routerProvider);

    // Trigger notification checks on every app startup
    ref.watch(checkAndGenerateNotificationsProvider);

    return Listener(
      // Reset the inactivity timer on every user touch — prevents the PIN
      // from locking the screen while the user is actively using the app.
      onPointerDown: (_) {
        ref.read(authStateProvider.notifier).userActivityDetected();
      },
      child: MaterialApp.router(
        title: 'Smart Expense Tracker',
        debugShowCheckedModeBanner: false,
        // ── Localisation ──────────────────────────────────────────────────────
        locale: locale,
        supportedLocales: const [Locale('en'), Locale('ar')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        // ── Theme ─────────────────────────────────────────────────────────────
        theme:      AppTheme.lightTheme(locale),
        darkTheme:  AppTheme.darkTheme(locale),
        themeMode:  themeMode,
        routerConfig: router,
      ),
    );
  }
}
