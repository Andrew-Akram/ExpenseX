import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ── Theme Mode ────────────────────────────────────────────────────────────────

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  () => ThemeModeNotifier(),
);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final box = Hive.box('settings');
    final isDark = box.get('dark_mode', defaultValue: false) as bool;
    return isDark ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> toggle() async {
    final isDark = state == ThemeMode.dark;
    state = isDark ? ThemeMode.light : ThemeMode.dark;
    await Hive.box('settings').put('dark_mode', !isDark);
  }

  bool get isDark => state == ThemeMode.dark;
}

// ── Currency Symbol ───────────────────────────────────────────────────────────

final currencySymbolProvider = NotifierProvider<CurrencyNotifier, String>(
  () => CurrencyNotifier(),
);

class CurrencyNotifier extends Notifier<String> {
  @override
  String build() {
    return Hive.box('settings').get('currency', defaultValue: '\$') as String;
  }

  Future<void> setCurrency(String symbol) async {
    state = symbol;
    await Hive.box('settings').put('currency', symbol);
  }
}

// ── Locale / Language ────────────────────────────────────────────────────────

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(
  () => LocaleNotifier(),
);

class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    final box = Hive.box('settings');
    final code = box.get('language_code', defaultValue: 'en') as String;
    return Locale(code);
  }

  Future<void> setLocale(String languageCode) async {
    state = Locale(languageCode);
    await Hive.box('settings').put('language_code', languageCode);
  }
}

// ── Profile Photo Provider ───────────────────────────────────────────────────

class ProfilePhotoNotifier extends Notifier<String?> {
  String get _key => 'profile_photo_path_${FirebaseAuth.instance.currentUser?.uid ?? 'guest'}';

  @override
  String? build() {
    return Hive.box('settings').get(_key) as String?;
  }

  Future<void> setPath(String? path) async {
    state = path;
    if (path != null) {
      await Hive.box('settings').put(_key, path);
    } else {
      await Hive.box('settings').delete(_key);
    }
  }
}

final profilePhotoPathProvider =
    NotifierProvider<ProfilePhotoNotifier, String?>(ProfilePhotoNotifier.new);

