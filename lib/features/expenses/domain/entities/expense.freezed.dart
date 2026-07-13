// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'expense.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Expense {

 String get id; String get title; double get amount; String get categoryId; DateTime get date;// ── Pre-existing optional fields ───────────────────────────────────────
 String? get note;// ── New fields (all optional with defaults for backward compatibility) ─
 String get walletId; String? get toWalletId; TransactionType get type; String? get merchant; List<String> get tags; String? get receiptPath; bool get isRecurring; RecurringInterval get recurringInterval; DateTime? get lastGeneratedOccurrence; DateTime? get updatedAt; bool get isDeleted;
/// Create a copy of Expense
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExpenseCopyWith<Expense> get copyWith => _$ExpenseCopyWithImpl<Expense>(this as Expense, _$identity);

  /// Serializes this Expense to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Expense&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.date, date) || other.date == date)&&(identical(other.note, note) || other.note == note)&&(identical(other.walletId, walletId) || other.walletId == walletId)&&(identical(other.toWalletId, toWalletId) || other.toWalletId == toWalletId)&&(identical(other.type, type) || other.type == type)&&(identical(other.merchant, merchant) || other.merchant == merchant)&&const DeepCollectionEquality().equals(other.tags, tags)&&(identical(other.receiptPath, receiptPath) || other.receiptPath == receiptPath)&&(identical(other.isRecurring, isRecurring) || other.isRecurring == isRecurring)&&(identical(other.recurringInterval, recurringInterval) || other.recurringInterval == recurringInterval)&&(identical(other.lastGeneratedOccurrence, lastGeneratedOccurrence) || other.lastGeneratedOccurrence == lastGeneratedOccurrence)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,amount,categoryId,date,note,walletId,toWalletId,type,merchant,const DeepCollectionEquality().hash(tags),receiptPath,isRecurring,recurringInterval,lastGeneratedOccurrence,updatedAt,isDeleted);

@override
String toString() {
  return 'Expense(id: $id, title: $title, amount: $amount, categoryId: $categoryId, date: $date, note: $note, walletId: $walletId, toWalletId: $toWalletId, type: $type, merchant: $merchant, tags: $tags, receiptPath: $receiptPath, isRecurring: $isRecurring, recurringInterval: $recurringInterval, lastGeneratedOccurrence: $lastGeneratedOccurrence, updatedAt: $updatedAt, isDeleted: $isDeleted)';
}


}

/// @nodoc
abstract mixin class $ExpenseCopyWith<$Res>  {
  factory $ExpenseCopyWith(Expense value, $Res Function(Expense) _then) = _$ExpenseCopyWithImpl;
@useResult
$Res call({
 String id, String title, double amount, String categoryId, DateTime date, String? note, String walletId, String? toWalletId, TransactionType type, String? merchant, List<String> tags, String? receiptPath, bool isRecurring, RecurringInterval recurringInterval, DateTime? lastGeneratedOccurrence, DateTime? updatedAt, bool isDeleted
});




}
/// @nodoc
class _$ExpenseCopyWithImpl<$Res>
    implements $ExpenseCopyWith<$Res> {
  _$ExpenseCopyWithImpl(this._self, this._then);

  final Expense _self;
  final $Res Function(Expense) _then;

/// Create a copy of Expense
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? amount = null,Object? categoryId = null,Object? date = null,Object? note = freezed,Object? walletId = null,Object? toWalletId = freezed,Object? type = null,Object? merchant = freezed,Object? tags = null,Object? receiptPath = freezed,Object? isRecurring = null,Object? recurringInterval = null,Object? lastGeneratedOccurrence = freezed,Object? updatedAt = freezed,Object? isDeleted = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,walletId: null == walletId ? _self.walletId : walletId // ignore: cast_nullable_to_non_nullable
as String,toWalletId: freezed == toWalletId ? _self.toWalletId : toWalletId // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TransactionType,merchant: freezed == merchant ? _self.merchant : merchant // ignore: cast_nullable_to_non_nullable
as String?,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,receiptPath: freezed == receiptPath ? _self.receiptPath : receiptPath // ignore: cast_nullable_to_non_nullable
as String?,isRecurring: null == isRecurring ? _self.isRecurring : isRecurring // ignore: cast_nullable_to_non_nullable
as bool,recurringInterval: null == recurringInterval ? _self.recurringInterval : recurringInterval // ignore: cast_nullable_to_non_nullable
as RecurringInterval,lastGeneratedOccurrence: freezed == lastGeneratedOccurrence ? _self.lastGeneratedOccurrence : lastGeneratedOccurrence // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Expense].
extension ExpensePatterns on Expense {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Expense value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Expense() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Expense value)  $default,){
final _that = this;
switch (_that) {
case _Expense():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Expense value)?  $default,){
final _that = this;
switch (_that) {
case _Expense() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  double amount,  String categoryId,  DateTime date,  String? note,  String walletId,  String? toWalletId,  TransactionType type,  String? merchant,  List<String> tags,  String? receiptPath,  bool isRecurring,  RecurringInterval recurringInterval,  DateTime? lastGeneratedOccurrence,  DateTime? updatedAt,  bool isDeleted)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Expense() when $default != null:
return $default(_that.id,_that.title,_that.amount,_that.categoryId,_that.date,_that.note,_that.walletId,_that.toWalletId,_that.type,_that.merchant,_that.tags,_that.receiptPath,_that.isRecurring,_that.recurringInterval,_that.lastGeneratedOccurrence,_that.updatedAt,_that.isDeleted);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  double amount,  String categoryId,  DateTime date,  String? note,  String walletId,  String? toWalletId,  TransactionType type,  String? merchant,  List<String> tags,  String? receiptPath,  bool isRecurring,  RecurringInterval recurringInterval,  DateTime? lastGeneratedOccurrence,  DateTime? updatedAt,  bool isDeleted)  $default,) {final _that = this;
switch (_that) {
case _Expense():
return $default(_that.id,_that.title,_that.amount,_that.categoryId,_that.date,_that.note,_that.walletId,_that.toWalletId,_that.type,_that.merchant,_that.tags,_that.receiptPath,_that.isRecurring,_that.recurringInterval,_that.lastGeneratedOccurrence,_that.updatedAt,_that.isDeleted);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  double amount,  String categoryId,  DateTime date,  String? note,  String walletId,  String? toWalletId,  TransactionType type,  String? merchant,  List<String> tags,  String? receiptPath,  bool isRecurring,  RecurringInterval recurringInterval,  DateTime? lastGeneratedOccurrence,  DateTime? updatedAt,  bool isDeleted)?  $default,) {final _that = this;
switch (_that) {
case _Expense() when $default != null:
return $default(_that.id,_that.title,_that.amount,_that.categoryId,_that.date,_that.note,_that.walletId,_that.toWalletId,_that.type,_that.merchant,_that.tags,_that.receiptPath,_that.isRecurring,_that.recurringInterval,_that.lastGeneratedOccurrence,_that.updatedAt,_that.isDeleted);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Expense implements Expense {
  const _Expense({required this.id, required this.title, required this.amount, required this.categoryId, required this.date, this.note, this.walletId = 'default_wallet', this.toWalletId, this.type = TransactionType.expense, this.merchant, final  List<String> tags = const [], this.receiptPath, this.isRecurring = false, this.recurringInterval = RecurringInterval.none, this.lastGeneratedOccurrence, this.updatedAt, this.isDeleted = false}): _tags = tags;
  factory _Expense.fromJson(Map<String, dynamic> json) => _$ExpenseFromJson(json);

@override final  String id;
@override final  String title;
@override final  double amount;
@override final  String categoryId;
@override final  DateTime date;
// ── Pre-existing optional fields ───────────────────────────────────────
@override final  String? note;
// ── New fields (all optional with defaults for backward compatibility) ─
@override@JsonKey() final  String walletId;
@override final  String? toWalletId;
@override@JsonKey() final  TransactionType type;
@override final  String? merchant;
 final  List<String> _tags;
@override@JsonKey() List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

@override final  String? receiptPath;
@override@JsonKey() final  bool isRecurring;
@override@JsonKey() final  RecurringInterval recurringInterval;
@override final  DateTime? lastGeneratedOccurrence;
@override final  DateTime? updatedAt;
@override@JsonKey() final  bool isDeleted;

/// Create a copy of Expense
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExpenseCopyWith<_Expense> get copyWith => __$ExpenseCopyWithImpl<_Expense>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExpenseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Expense&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.date, date) || other.date == date)&&(identical(other.note, note) || other.note == note)&&(identical(other.walletId, walletId) || other.walletId == walletId)&&(identical(other.toWalletId, toWalletId) || other.toWalletId == toWalletId)&&(identical(other.type, type) || other.type == type)&&(identical(other.merchant, merchant) || other.merchant == merchant)&&const DeepCollectionEquality().equals(other._tags, _tags)&&(identical(other.receiptPath, receiptPath) || other.receiptPath == receiptPath)&&(identical(other.isRecurring, isRecurring) || other.isRecurring == isRecurring)&&(identical(other.recurringInterval, recurringInterval) || other.recurringInterval == recurringInterval)&&(identical(other.lastGeneratedOccurrence, lastGeneratedOccurrence) || other.lastGeneratedOccurrence == lastGeneratedOccurrence)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,amount,categoryId,date,note,walletId,toWalletId,type,merchant,const DeepCollectionEquality().hash(_tags),receiptPath,isRecurring,recurringInterval,lastGeneratedOccurrence,updatedAt,isDeleted);

@override
String toString() {
  return 'Expense(id: $id, title: $title, amount: $amount, categoryId: $categoryId, date: $date, note: $note, walletId: $walletId, toWalletId: $toWalletId, type: $type, merchant: $merchant, tags: $tags, receiptPath: $receiptPath, isRecurring: $isRecurring, recurringInterval: $recurringInterval, lastGeneratedOccurrence: $lastGeneratedOccurrence, updatedAt: $updatedAt, isDeleted: $isDeleted)';
}


}

/// @nodoc
abstract mixin class _$ExpenseCopyWith<$Res> implements $ExpenseCopyWith<$Res> {
  factory _$ExpenseCopyWith(_Expense value, $Res Function(_Expense) _then) = __$ExpenseCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, double amount, String categoryId, DateTime date, String? note, String walletId, String? toWalletId, TransactionType type, String? merchant, List<String> tags, String? receiptPath, bool isRecurring, RecurringInterval recurringInterval, DateTime? lastGeneratedOccurrence, DateTime? updatedAt, bool isDeleted
});




}
/// @nodoc
class __$ExpenseCopyWithImpl<$Res>
    implements _$ExpenseCopyWith<$Res> {
  __$ExpenseCopyWithImpl(this._self, this._then);

  final _Expense _self;
  final $Res Function(_Expense) _then;

/// Create a copy of Expense
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? amount = null,Object? categoryId = null,Object? date = null,Object? note = freezed,Object? walletId = null,Object? toWalletId = freezed,Object? type = null,Object? merchant = freezed,Object? tags = null,Object? receiptPath = freezed,Object? isRecurring = null,Object? recurringInterval = null,Object? lastGeneratedOccurrence = freezed,Object? updatedAt = freezed,Object? isDeleted = null,}) {
  return _then(_Expense(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,walletId: null == walletId ? _self.walletId : walletId // ignore: cast_nullable_to_non_nullable
as String,toWalletId: freezed == toWalletId ? _self.toWalletId : toWalletId // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TransactionType,merchant: freezed == merchant ? _self.merchant : merchant // ignore: cast_nullable_to_non_nullable
as String?,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,receiptPath: freezed == receiptPath ? _self.receiptPath : receiptPath // ignore: cast_nullable_to_non_nullable
as String?,isRecurring: null == isRecurring ? _self.isRecurring : isRecurring // ignore: cast_nullable_to_non_nullable
as bool,recurringInterval: null == recurringInterval ? _self.recurringInterval : recurringInterval // ignore: cast_nullable_to_non_nullable
as RecurringInterval,lastGeneratedOccurrence: freezed == lastGeneratedOccurrence ? _self.lastGeneratedOccurrence : lastGeneratedOccurrence // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
