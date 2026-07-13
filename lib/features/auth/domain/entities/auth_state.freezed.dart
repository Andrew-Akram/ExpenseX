// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AuthAppState {

 bool get isPinSetup; bool get isAuthenticated; bool get isBiometricEnabled; bool get isBiometricAvailable; bool get isSplashFinished; bool get isOnboardingCompleted; bool get isFirebaseLoggedIn;
/// Create a copy of AuthAppState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthAppStateCopyWith<AuthAppState> get copyWith => _$AuthAppStateCopyWithImpl<AuthAppState>(this as AuthAppState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthAppState&&(identical(other.isPinSetup, isPinSetup) || other.isPinSetup == isPinSetup)&&(identical(other.isAuthenticated, isAuthenticated) || other.isAuthenticated == isAuthenticated)&&(identical(other.isBiometricEnabled, isBiometricEnabled) || other.isBiometricEnabled == isBiometricEnabled)&&(identical(other.isBiometricAvailable, isBiometricAvailable) || other.isBiometricAvailable == isBiometricAvailable)&&(identical(other.isSplashFinished, isSplashFinished) || other.isSplashFinished == isSplashFinished)&&(identical(other.isOnboardingCompleted, isOnboardingCompleted) || other.isOnboardingCompleted == isOnboardingCompleted)&&(identical(other.isFirebaseLoggedIn, isFirebaseLoggedIn) || other.isFirebaseLoggedIn == isFirebaseLoggedIn));
}


@override
int get hashCode => Object.hash(runtimeType,isPinSetup,isAuthenticated,isBiometricEnabled,isBiometricAvailable,isSplashFinished,isOnboardingCompleted,isFirebaseLoggedIn);

@override
String toString() {
  return 'AuthAppState(isPinSetup: $isPinSetup, isAuthenticated: $isAuthenticated, isBiometricEnabled: $isBiometricEnabled, isBiometricAvailable: $isBiometricAvailable, isSplashFinished: $isSplashFinished, isOnboardingCompleted: $isOnboardingCompleted, isFirebaseLoggedIn: $isFirebaseLoggedIn)';
}


}

/// @nodoc
abstract mixin class $AuthAppStateCopyWith<$Res>  {
  factory $AuthAppStateCopyWith(AuthAppState value, $Res Function(AuthAppState) _then) = _$AuthAppStateCopyWithImpl;
@useResult
$Res call({
 bool isPinSetup, bool isAuthenticated, bool isBiometricEnabled, bool isBiometricAvailable, bool isSplashFinished, bool isOnboardingCompleted, bool isFirebaseLoggedIn
});




}
/// @nodoc
class _$AuthAppStateCopyWithImpl<$Res>
    implements $AuthAppStateCopyWith<$Res> {
  _$AuthAppStateCopyWithImpl(this._self, this._then);

  final AuthAppState _self;
  final $Res Function(AuthAppState) _then;

/// Create a copy of AuthAppState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isPinSetup = null,Object? isAuthenticated = null,Object? isBiometricEnabled = null,Object? isBiometricAvailable = null,Object? isSplashFinished = null,Object? isOnboardingCompleted = null,Object? isFirebaseLoggedIn = null,}) {
  return _then(_self.copyWith(
isPinSetup: null == isPinSetup ? _self.isPinSetup : isPinSetup // ignore: cast_nullable_to_non_nullable
as bool,isAuthenticated: null == isAuthenticated ? _self.isAuthenticated : isAuthenticated // ignore: cast_nullable_to_non_nullable
as bool,isBiometricEnabled: null == isBiometricEnabled ? _self.isBiometricEnabled : isBiometricEnabled // ignore: cast_nullable_to_non_nullable
as bool,isBiometricAvailable: null == isBiometricAvailable ? _self.isBiometricAvailable : isBiometricAvailable // ignore: cast_nullable_to_non_nullable
as bool,isSplashFinished: null == isSplashFinished ? _self.isSplashFinished : isSplashFinished // ignore: cast_nullable_to_non_nullable
as bool,isOnboardingCompleted: null == isOnboardingCompleted ? _self.isOnboardingCompleted : isOnboardingCompleted // ignore: cast_nullable_to_non_nullable
as bool,isFirebaseLoggedIn: null == isFirebaseLoggedIn ? _self.isFirebaseLoggedIn : isFirebaseLoggedIn // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [AuthAppState].
extension AuthAppStatePatterns on AuthAppState {


@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuthAppState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuthAppState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}


@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuthAppState value)  $default,){
final _that = this;
switch (_that) {
case _AuthAppState():
return $default(_that);}
}


@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuthAppState value)?  $default,){
final _that = this;
switch (_that) {
case _AuthAppState() when $default != null:
return $default(_that);case _:
  return null;

}
}


@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isPinSetup,  bool isAuthenticated,  bool isBiometricEnabled,  bool isBiometricAvailable,  bool isSplashFinished,  bool isOnboardingCompleted,  bool isFirebaseLoggedIn)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuthAppState() when $default != null:
return $default(_that.isPinSetup,_that.isAuthenticated,_that.isBiometricEnabled,_that.isBiometricAvailable,_that.isSplashFinished,_that.isOnboardingCompleted,_that.isFirebaseLoggedIn);case _:
  return orElse();

}
}


@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isPinSetup,  bool isAuthenticated,  bool isBiometricEnabled,  bool isBiometricAvailable,  bool isSplashFinished,  bool isOnboardingCompleted,  bool isFirebaseLoggedIn)  $default,) {final _that = this;
switch (_that) {
case _AuthAppState():
return $default(_that.isPinSetup,_that.isAuthenticated,_that.isBiometricEnabled,_that.isBiometricAvailable,_that.isSplashFinished,_that.isOnboardingCompleted,_that.isFirebaseLoggedIn);}
}


@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isPinSetup,  bool isAuthenticated,  bool isBiometricEnabled,  bool isBiometricAvailable,  bool isSplashFinished,  bool isOnboardingCompleted,  bool isFirebaseLoggedIn)?  $default,) {final _that = this;
switch (_that) {
case _AuthAppState() when $default != null:
return $default(_that.isPinSetup,_that.isAuthenticated,_that.isBiometricEnabled,_that.isBiometricAvailable,_that.isSplashFinished,_that.isOnboardingCompleted,_that.isFirebaseLoggedIn);case _:
  return null;

}
}

}

/// @nodoc


class _AuthAppState implements AuthAppState {
  const _AuthAppState({this.isPinSetup = false, this.isAuthenticated = false, this.isBiometricEnabled = false, this.isBiometricAvailable = false, this.isSplashFinished = false, this.isOnboardingCompleted = false, this.isFirebaseLoggedIn = false});
  

@override@JsonKey() final  bool isPinSetup;
@override@JsonKey() final  bool isAuthenticated;
@override@JsonKey() final  bool isBiometricEnabled;
@override@JsonKey() final  bool isBiometricAvailable;
@override@JsonKey() final  bool isSplashFinished;
@override@JsonKey() final  bool isOnboardingCompleted;
@override@JsonKey() final  bool isFirebaseLoggedIn;

/// Create a copy of AuthAppState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuthAppStateCopyWith<_AuthAppState> get copyWith => __$AuthAppStateCopyWithImpl<_AuthAppState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuthAppState&&(identical(other.isPinSetup, isPinSetup) || other.isPinSetup == isPinSetup)&&(identical(other.isAuthenticated, isAuthenticated) || other.isAuthenticated == isAuthenticated)&&(identical(other.isBiometricEnabled, isBiometricEnabled) || other.isBiometricEnabled == isBiometricEnabled)&&(identical(other.isBiometricAvailable, isBiometricAvailable) || other.isBiometricAvailable == isBiometricAvailable)&&(identical(other.isSplashFinished, isSplashFinished) || other.isSplashFinished == isSplashFinished)&&(identical(other.isOnboardingCompleted, isOnboardingCompleted) || other.isOnboardingCompleted == isOnboardingCompleted)&&(identical(other.isFirebaseLoggedIn, isFirebaseLoggedIn) || other.isFirebaseLoggedIn == isFirebaseLoggedIn));
}


@override
int get hashCode => Object.hash(runtimeType,isPinSetup,isAuthenticated,isBiometricEnabled,isBiometricAvailable,isSplashFinished,isOnboardingCompleted,isFirebaseLoggedIn);

@override
String toString() {
  return 'AuthAppState(isPinSetup: $isPinSetup, isAuthenticated: $isAuthenticated, isBiometricEnabled: $isBiometricEnabled, isBiometricAvailable: $isBiometricAvailable, isSplashFinished: $isSplashFinished, isOnboardingCompleted: $isOnboardingCompleted, isFirebaseLoggedIn: $isFirebaseLoggedIn)';
}


}

/// @nodoc
abstract mixin class _$AuthAppStateCopyWith<$Res> implements $AuthAppStateCopyWith<$Res> {
  factory _$AuthAppStateCopyWith(_AuthAppState value, $Res Function(_AuthAppState) _then) = __$AuthAppStateCopyWithImpl;
@override @useResult
$Res call({
 bool isPinSetup, bool isAuthenticated, bool isBiometricEnabled, bool isBiometricAvailable, bool isSplashFinished, bool isOnboardingCompleted, bool isFirebaseLoggedIn
});




}
/// @nodoc
class __$AuthAppStateCopyWithImpl<$Res>
    implements _$AuthAppStateCopyWith<$Res> {
  __$AuthAppStateCopyWithImpl(this._self, this._then);

  final _AuthAppState _self;
  final $Res Function(_AuthAppState) _then;

/// Create a copy of AuthAppState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isPinSetup = null,Object? isAuthenticated = null,Object? isBiometricEnabled = null,Object? isBiometricAvailable = null,Object? isSplashFinished = null,Object? isOnboardingCompleted = null,Object? isFirebaseLoggedIn = null,}) {
  return _then(_AuthAppState(
isPinSetup: null == isPinSetup ? _self.isPinSetup : isPinSetup // ignore: cast_nullable_to_non_nullable
as bool,isAuthenticated: null == isAuthenticated ? _self.isAuthenticated : isAuthenticated // ignore: cast_nullable_to_non_nullable
as bool,isBiometricEnabled: null == isBiometricEnabled ? _self.isBiometricEnabled : isBiometricEnabled // ignore: cast_nullable_to_non_nullable
as bool,isBiometricAvailable: null == isBiometricAvailable ? _self.isBiometricAvailable : isBiometricAvailable // ignore: cast_nullable_to_non_nullable
as bool,isSplashFinished: null == isSplashFinished ? _self.isSplashFinished : isSplashFinished // ignore: cast_nullable_to_non_nullable
as bool,isOnboardingCompleted: null == isOnboardingCompleted ? _self.isOnboardingCompleted : isOnboardingCompleted // ignore: cast_nullable_to_non_nullable
as bool,isFirebaseLoggedIn: null == isFirebaseLoggedIn ? _self.isFirebaseLoggedIn : isFirebaseLoggedIn // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
