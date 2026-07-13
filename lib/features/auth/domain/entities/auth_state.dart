import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_state.freezed.dart';

@freezed
sealed class AuthAppState with _$AuthAppState {
  const factory AuthAppState({
    @Default(false) bool isPinSetup,
    @Default(false) bool isAuthenticated,
    @Default(false) bool isBiometricEnabled,
    @Default(false) bool isBiometricAvailable,
    @Default(false) bool isSplashFinished,
    @Default(false) bool isOnboardingCompleted,
    @Default(false) bool isFirebaseLoggedIn,
  }) = _AuthAppState;
}
