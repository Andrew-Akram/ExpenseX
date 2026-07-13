abstract class AuthRepository {
  Future<bool> isPinSetup();
  Future<void> setupPin(String pin);
  Future<bool> verifyPin(String pin);
  Future<void> clearPin();
  Future<bool> isBiometricEnabled();
  Future<void> setBiometricEnabled(bool enabled);
  Future<bool> isBiometricAvailable();
  Future<bool> authenticateWithBiometric();

  // ── Firebase Auth ──────────────────────────────────────────────────────────
  Future<void> signInWithEmailAndPassword(String email, String password);
  Future<void> signUpWithEmailAndPassword(String email, String password, {String? fullName});
  Future<void> signInWithGoogle();
  Future<void> signOut();
  bool isUserLoggedIn();
  String? get currentUserEmail;
  String? get currentUserDisplayName;

  // ── Profile ───────────────────────────────────────────────────────────────
  Future<void> updateDisplayName(String name);
  Future<void> updatePassword(String newPassword);
  DateTime? get currentUserCreationTime;
}
