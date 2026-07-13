import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_ce/hive.dart';
import 'package:local_auth/local_auth.dart';

class AuthLocalDataSource {
  static const _storage = FlutterSecureStorage();
  final _localAuth = LocalAuthentication();

  String get _userId => FirebaseAuth.instance.currentUser?.uid ?? 'guest';

  String get _pinKey => 'app_pin_$_userId';
  String get _biometricKey => 'biometric_enabled_$_userId';

  String _hashPin(String pin) {
    final bytes = utf8.encode('expensex_salt_$pin');
    return sha256.convert(bytes).toString();
  }

  Future<bool> isPinSetup() async {
    final pin = await _storage.read(key: _pinKey);
    return pin != null && pin.isNotEmpty;
  }

  Future<void> setupPin(String pin) async {
    await _storage.write(key: _pinKey, value: _hashPin(pin));
  }

  Future<bool> verifyPin(String pin) async {
    final stored = await _storage.read(key: _pinKey);
    if (stored == null) return false;

    // Check if the stored PIN is a 64-character SHA-256 hash.
    // If not, it is a legacy plaintext PIN. Migrate it to the hashed format.
    if (stored.length != 64) {
      final isMatch = stored == pin;
      if (isMatch) {
        // Automatically migrate to secure hash
        await setupPin(pin);
      }
      return isMatch;
    }

    return stored == _hashPin(pin);
  }

  Future<void> clearPin() async {
    await _storage.delete(key: _pinKey);
  }

  Future<bool> isBiometricEnabled() async {
    final box = Hive.box('settings');
    return box.get(_biometricKey, defaultValue: false) as bool;
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    final box = Hive.box('settings');
    await box.put(_biometricKey, enabled);
  }

  Future<bool> isBiometricAvailable() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return canCheck && isDeviceSupported;
    } catch (_) {
      return false;
    }
  }

  Future<bool> authenticateWithBiometric() async {
    try {
      return await _localAuth.authenticate(
        localizedReason: 'Authenticate to access Smart Expense Tracker',
        authMessages: const [],
      );
    } catch (_) {
      return false;
    }
  }
}
