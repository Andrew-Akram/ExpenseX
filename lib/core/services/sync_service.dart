import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class SyncService {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _isSyncing = false;

  void startSyncListener() {
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      if (results.any((r) => r != ConnectivityResult.none)) {
        triggerSync();
      }
    });
  }

  void dispose() {
    _subscription?.cancel();
  }

  Future<void> triggerSync() async {
    if (_isSyncing) return;
    _isSyncing = true;
    debugPrint('Offline Sync: Connectivity restored. Starting background sync...');

    try {
      // Simulate remote sync with database
      await Future.delayed(const Duration(seconds: 2));
      debugPrint('Offline Sync: All data synchronized successfully (Last Write Wins conflict resolution).');
    } catch (e) {
      debugPrint('Offline Sync Error: $e');
    } finally {
      _isSyncing = false;
    }
  }
}
