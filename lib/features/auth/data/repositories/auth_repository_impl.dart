import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource _ds;
  final fb.FirebaseAuth _firebaseAuth = fb.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  AuthRepositoryImpl(this._ds);

  @override
  Future<bool> isPinSetup() => _ds.isPinSetup();

  @override
  Future<void> setupPin(String pin) => _ds.setupPin(pin);

  @override
  Future<bool> verifyPin(String pin) => _ds.verifyPin(pin);

  @override
  Future<void> clearPin() => _ds.clearPin();

  @override
  Future<bool> isBiometricEnabled() => _ds.isBiometricEnabled();

  @override
  Future<void> setBiometricEnabled(bool enabled) =>
      _ds.setBiometricEnabled(enabled);

  @override
  Future<bool> isBiometricAvailable() => _ds.isBiometricAvailable();

  @override
  Future<bool> authenticateWithBiometric() =>
      _ds.authenticateWithBiometric();

  // ── Firebase Auth Implementation ───────────────────────────────────────────

  @override
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<void> signUpWithEmailAndPassword(String email, String password,
      {String? fullName}) async {
    final cred = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (fullName != null && fullName.trim().isNotEmpty) {
      await cred.user?.updateDisplayName(fullName.trim());
    }
  }

  @override
  Future<void> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw fb.FirebaseAuthException(
        code: 'ERROR_ABORTED_BY_USER',
        message: 'Sign in aborted by user',
      );
    }
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final fb.AuthCredential credential = fb.GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    await _firebaseAuth.signInWithCredential(credential);
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await _googleSignIn.signOut();
  }

  @override
  bool isUserLoggedIn() {
    try {
      return _firebaseAuth.currentUser != null;
    } catch (_) {
      return false;
    }
  }

  @override
  String? get currentUserEmail {
    try {
      return _firebaseAuth.currentUser?.email;
    } catch (_) {
      return null;
    }
  }

  @override
  String? get currentUserDisplayName {
    try {
      return _firebaseAuth.currentUser?.displayName;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> updateDisplayName(String name) async {
    await _firebaseAuth.currentUser?.updateDisplayName(name);
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    await _firebaseAuth.currentUser?.updatePassword(newPassword);
  }

  @override
  DateTime? get currentUserCreationTime {
    try {
      return _firebaseAuth.currentUser?.metadata.creationTime;
    } catch (_) {
      return null;
    }
  }
}
