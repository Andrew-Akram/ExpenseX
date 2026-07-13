import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import 'app.dart';
import 'firebase_options.dart';

// Hive is still used for device-local settings (theme, PIN, biometric, lock policy)
// All financial data is now stored in Firestore.

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialise Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }

  // Initialise Hive for device-local settings only
  await Hive.initFlutter();

  // Open the global settings box (theme, PIN, biometric, lock policy)
  final settingsBox = await Hive.openBox('settings');

  // Purge legacy local user/financial Hive data
  await _purgeLegacyHiveData(settingsBox);

  // Financial data seeding (categories, wallets, demo expenses) now happens
  // inside AuthNotifier._seedUserData() after sign-in via Firestore.

  runApp(const ProviderScope(child: SmartExpenseTrackerApp()));
}

/// One-time migration to remove legacy local accounts and financial data from previous versions.
/// Safely deletes only user-specific/financial Hive boxes (.hive & .lock files) while leaving the
/// settings box untouched.
Future<void> _purgeLegacyHiveData(Box settingsBox) async {
  try {
    final isPurged = settingsBox.get('hive_purge_done_v1', defaultValue: false) as bool;
    if (isPurged) {
      return;
    }

    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory(appDir.path);
    if (await dir.exists()) {
      final entities = dir.listSync();
      for (final entity in entities) {
        if (entity is File) {
          final fileName = entity.path.split(RegExp(r'[/\\]')).last;
          final isLegacyDataFile =
              fileName.startsWith('categories_') ||
              fileName.startsWith('expenses_') ||
              fileName.startsWith('budgets_') ||
              fileName.startsWith('wallets_') ||
              fileName.startsWith('savings_goals_') ||
              fileName.startsWith('bills_') ||
              fileName.startsWith('notifications_');
          final isHiveExtension = fileName.endsWith('.hive') || fileName.endsWith('.lock');

          if (isLegacyDataFile && isHiveExtension) {
            try {
              await entity.delete();
              debugPrint('Purged legacy Hive file: ${entity.path}');
            } catch (e) {
              debugPrint('Failed to delete legacy Hive file: ${entity.path}, error: $e');
            }
          }
        }
      }
    }

    await settingsBox.put('hive_purge_done_v1', true);
    debugPrint('One-time legacy Hive data purge completed.');
  } catch (e) {
    debugPrint('Error during legacy Hive data purge: $e');
  }
}

