// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bill.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Bill {

 String get id; String get name; double get amount; DateTime get dueDate; String get categoryId; String get walletId; bool get isPaid; bool get isSubscription; RecurringInterval get cycle; int get reminderDaysBefore; String? get note; DateTime? get paidDate; DateTime? get updatedAt;
/// Create a copy of Bill
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BillCopyWith<Bill> get copyWith => _$BillCopyWithImpl<Bill>(this as Bill, _$identity);

  /// Serializes this Bill to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Bill&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.walletId, walletId) || other.walletId == walletId)&&(identical(other.isPaid, isPaid) || other.isPaid == isPaid)&&(identical(other.isSubscription, isSubscription) || other.isSubscription == isSubscription)&&(identical(other.cycle, cycle) || other.cycle == cycle)&&(identical(other.reminderDaysBefore, reminderDaysBefore) || other.reminderDaysBefore == reminderDaysBefore)&&(identical(other.note, note) || other.note == note)&&(identical(other.paidDate, paidDate) || other.paidDate == paidDate)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,amount,dueDate,categoryId,walletId,isPaid,isSubscription,cycle,reminderDaysBefore,note,paidDate,updatedAt);

@override
String toString() {
  return 'Bill(id: $id, name: $name, amount: $amount, dueDate: $dueDate, categoryId: $categoryId, walletId: $walletId, isPaid: $isPaid, isSubscription: $isSubscription, cycle: $cycle, reminderDaysBefore: $reminderDaysBefore, note: $note, paidDate: $paidDate, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $BillCopyWith<$Res>  {
  factory $BillCopyWith(Bill value, $Res Function(Bill) _then) = _$BillCopyWithImpl;
@useResult
$Res call({
 String id, String name, double amount, DateTime dueDate, String categoryId, String walletId, bool isPaid, bool isSubscription, RecurringInterval cycle, int reminderDaysBefore, String? note, DateTime? paidDate, DateTime? updatedAt
});




}
/// @nodoc
class _$BillCopyWithImpl<$Res>
    implements $BillCopyWith<$Res> {
  _$BillCopyWithImpl(this._self, this._then);

  final Bill _self;
  final $Res Function(Bill) _then;

/// Create a copy of Bill
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? amount = null,Object? dueDate = null,Object? categoryId = null,Object? walletId = null,Object? isPaid = null,Object? isSubscription = null,Object? cycle = null,Object? reminderDaysBefore = null,Object? note = freezed,Object? paidDate = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,dueDate: null == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,walletId: null == walletId ? _self.walletId : walletId // ignore: cast_nullable_to_non_nullable
as String,isPaid: null == isPaid ? _self.isPaid : isPaid // ignore: cast_nullable_to_non_nullable
as bool,isSubscription: null == isSubscription ? _self.isSubscription : isSubscription // ignore: cast_nullable_to_non_nullable
as bool,cycle: null == cycle ? _self.cycle : cycle // ignore: cast_nullable_to_non_nullable
as RecurringInterval,reminderDaysBefore: null == reminderDaysBefore ? _self.reminderDaysBefore : reminderDaysBefore // ignore: cast_nullable_to_non_nullable
as int,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,paidDate: freezed == paidDate ? _self.paidDate : paidDate // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Bill].
extension BillPatterns on Bill {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Bill value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Bill() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Bill value)  $default,){
final _that = this;
switch (_that) {
case _Bill():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Bill value)?  $default,){
final _that = this;
switch (_that) {
case _Bill() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  double amount,  DateTime dueDate,  String categoryId,  String walletId,  bool isPaid,  bool isSubscription,  RecurringInterval cycle,  int reminderDaysBefore,  String? note,  DateTime? paidDate,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Bill() when $default != null:
return $default(_that.id,_that.name,_that.amount,_that.dueDate,_that.categoryId,_that.walletId,_that.isPaid,_that.isSubscription,_that.cycle,_that.reminderDaysBefore,_that.note,_that.paidDate,_that.updatedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  double amount,  DateTime dueDate,  String categoryId,  String walletId,  bool isPaid,  bool isSubscription,  RecurringInterval cycle,  int reminderDaysBefore,  String? note,  DateTime? paidDate,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Bill():
return $default(_that.id,_that.name,_that.amount,_that.dueDate,_that.categoryId,_that.walletId,_that.isPaid,_that.isSubscription,_that.cycle,_that.reminderDaysBefore,_that.note,_that.paidDate,_that.updatedAt);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  double amount,  DateTime dueDate,  String categoryId,  String walletId,  bool isPaid,  bool isSubscription,  RecurringInterval cycle,  int reminderDaysBefore,  String? note,  DateTime? paidDate,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Bill() when $default != null:
return $default(_that.id,_that.name,_that.amount,_that.dueDate,_that.categoryId,_that.walletId,_that.isPaid,_that.isSubscription,_that.cycle,_that.reminderDaysBefore,_that.note,_that.paidDate,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Bill implements Bill {
  const _Bill({required this.id, required this.name, required this.amount, required this.dueDate, required this.categoryId, this.walletId = 'default_wallet', this.isPaid = false, this.isSubscription = false, this.cycle = RecurringInterval.monthly, this.reminderDaysBefore = 3, this.note, this.paidDate, this.updatedAt});
  factory _Bill.fromJson(Map<String, dynamic> json) => _$BillFromJson(json);

@override final  String id;
@override final  String name;
@override final  double amount;
@override final  DateTime dueDate;
@override final  String categoryId;
@override@JsonKey() final  String walletId;
@override@JsonKey() final  bool isPaid;
@override@JsonKey() final  bool isSubscription;
@override@JsonKey() final  RecurringInterval cycle;
@override@JsonKey() final  int reminderDaysBefore;
@override final  String? note;
@override final  DateTime? paidDate;
@override final  DateTime? updatedAt;

/// Create a copy of Bill
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BillCopyWith<_Bill> get copyWith => __$BillCopyWithImpl<_Bill>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BillToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Bill&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.walletId, walletId) || other.walletId == walletId)&&(identical(other.isPaid, isPaid) || other.isPaid == isPaid)&&(identical(other.isSubscription, isSubscription) || other.isSubscription == isSubscription)&&(identical(other.cycle, cycle) || other.cycle == cycle)&&(identical(other.reminderDaysBefore, reminderDaysBefore) || other.reminderDaysBefore == reminderDaysBefore)&&(identical(other.note, note) || other.note == note)&&(identical(other.paidDate, paidDate) || other.paidDate == paidDate)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,amount,dueDate,categoryId,walletId,isPaid,isSubscription,cycle,reminderDaysBefore,note,paidDate,updatedAt);

@override
String toString() {
  return 'Bill(id: $id, name: $name, amount: $amount, dueDate: $dueDate, categoryId: $categoryId, walletId: $walletId, isPaid: $isPaid, isSubscription: $isSubscription, cycle: $cycle, reminderDaysBefore: $reminderDaysBefore, note: $note, paidDate: $paidDate, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$BillCopyWith<$Res> implements $BillCopyWith<$Res> {
  factory _$BillCopyWith(_Bill value, $Res Function(_Bill) _then) = __$BillCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, double amount, DateTime dueDate, String categoryId, String walletId, bool isPaid, bool isSubscription, RecurringInterval cycle, int reminderDaysBefore, String? note, DateTime? paidDate, DateTime? updatedAt
});




}
/// @nodoc
class __$BillCopyWithImpl<$Res>
    implements _$BillCopyWith<$Res> {
  __$BillCopyWithImpl(this._self, this._then);

  final _Bill _self;
  final $Res Function(_Bill) _then;

/// Create a copy of Bill
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? amount = null,Object? dueDate = null,Object? categoryId = null,Object? walletId = null,Object? isPaid = null,Object? isSubscription = null,Object? cycle = null,Object? reminderDaysBefore = null,Object? note = freezed,Object? paidDate = freezed,Object? updatedAt = freezed,}) {
  return _then(_Bill(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,dueDate: null == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as DateTime,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,walletId: null == walletId ? _self.walletId : walletId // ignore: cast_nullable_to_non_nullable
as String,isPaid: null == isPaid ? _self.isPaid : isPaid // ignore: cast_nullable_to_non_nullable
as bool,isSubscription: null == isSubscription ? _self.isSubscription : isSubscription // ignore: cast_nullable_to_non_nullable
as bool,cycle: null == cycle ? _self.cycle : cycle // ignore: cast_nullable_to_non_nullable
as RecurringInterval,reminderDaysBefore: null == reminderDaysBefore ? _self.reminderDaysBefore : reminderDaysBefore // ignore: cast_nullable_to_non_nullable
as int,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,paidDate: freezed == paidDate ? _self.paidDate : paidDate // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
