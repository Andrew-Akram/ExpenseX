// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'expense_filter.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ExpenseFilter {

// ── Text search (title, note, tags, merchant) ──────────────────────────
 String? get searchQuery;// ── Category & wallet ─────────────────────────────────────────────────
 String? get categoryId; String? get walletId;// ── Transaction type ──────────────────────────────────────────────────
 TransactionType? get type;// ── Date range ────────────────────────────────────────────────────────
 DateTime? get dateFrom; DateTime? get dateTo;// ── Amount range ──────────────────────────────────────────────────────
 double? get amountMin; double? get amountMax;// ── Receipt filter ────────────────────────────────────────────────────
 bool? get hasReceipt;// ── Sort order ────────────────────────────────────────────────────────
 SortOrder get sortOrder;
/// Create a copy of ExpenseFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExpenseFilterCopyWith<ExpenseFilter> get copyWith => _$ExpenseFilterCopyWithImpl<ExpenseFilter>(this as ExpenseFilter, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExpenseFilter&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.walletId, walletId) || other.walletId == walletId)&&(identical(other.type, type) || other.type == type)&&(identical(other.dateFrom, dateFrom) || other.dateFrom == dateFrom)&&(identical(other.dateTo, dateTo) || other.dateTo == dateTo)&&(identical(other.amountMin, amountMin) || other.amountMin == amountMin)&&(identical(other.amountMax, amountMax) || other.amountMax == amountMax)&&(identical(other.hasReceipt, hasReceipt) || other.hasReceipt == hasReceipt)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder));
}


@override
int get hashCode => Object.hash(runtimeType,searchQuery,categoryId,walletId,type,dateFrom,dateTo,amountMin,amountMax,hasReceipt,sortOrder);

@override
String toString() {
  return 'ExpenseFilter(searchQuery: $searchQuery, categoryId: $categoryId, walletId: $walletId, type: $type, dateFrom: $dateFrom, dateTo: $dateTo, amountMin: $amountMin, amountMax: $amountMax, hasReceipt: $hasReceipt, sortOrder: $sortOrder)';
}


}

/// @nodoc
abstract mixin class $ExpenseFilterCopyWith<$Res>  {
  factory $ExpenseFilterCopyWith(ExpenseFilter value, $Res Function(ExpenseFilter) _then) = _$ExpenseFilterCopyWithImpl;
@useResult
$Res call({
 String? searchQuery, String? categoryId, String? walletId, TransactionType? type, DateTime? dateFrom, DateTime? dateTo, double? amountMin, double? amountMax, bool? hasReceipt, SortOrder sortOrder
});




}
/// @nodoc
class _$ExpenseFilterCopyWithImpl<$Res>
    implements $ExpenseFilterCopyWith<$Res> {
  _$ExpenseFilterCopyWithImpl(this._self, this._then);

  final ExpenseFilter _self;
  final $Res Function(ExpenseFilter) _then;

/// Create a copy of ExpenseFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? searchQuery = freezed,Object? categoryId = freezed,Object? walletId = freezed,Object? type = freezed,Object? dateFrom = freezed,Object? dateTo = freezed,Object? amountMin = freezed,Object? amountMax = freezed,Object? hasReceipt = freezed,Object? sortOrder = null,}) {
  return _then(_self.copyWith(
searchQuery: freezed == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,walletId: freezed == walletId ? _self.walletId : walletId // ignore: cast_nullable_to_non_nullable
as String?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TransactionType?,dateFrom: freezed == dateFrom ? _self.dateFrom : dateFrom // ignore: cast_nullable_to_non_nullable
as DateTime?,dateTo: freezed == dateTo ? _self.dateTo : dateTo // ignore: cast_nullable_to_non_nullable
as DateTime?,amountMin: freezed == amountMin ? _self.amountMin : amountMin // ignore: cast_nullable_to_non_nullable
as double?,amountMax: freezed == amountMax ? _self.amountMax : amountMax // ignore: cast_nullable_to_non_nullable
as double?,hasReceipt: freezed == hasReceipt ? _self.hasReceipt : hasReceipt // ignore: cast_nullable_to_non_nullable
as bool?,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as SortOrder,
  ));
}

}


/// Adds pattern-matching-related methods to [ExpenseFilter].
extension ExpenseFilterPatterns on ExpenseFilter {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExpenseFilter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExpenseFilter() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExpenseFilter value)  $default,){
final _that = this;
switch (_that) {
case _ExpenseFilter():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExpenseFilter value)?  $default,){
final _that = this;
switch (_that) {
case _ExpenseFilter() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? searchQuery,  String? categoryId,  String? walletId,  TransactionType? type,  DateTime? dateFrom,  DateTime? dateTo,  double? amountMin,  double? amountMax,  bool? hasReceipt,  SortOrder sortOrder)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExpenseFilter() when $default != null:
return $default(_that.searchQuery,_that.categoryId,_that.walletId,_that.type,_that.dateFrom,_that.dateTo,_that.amountMin,_that.amountMax,_that.hasReceipt,_that.sortOrder);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? searchQuery,  String? categoryId,  String? walletId,  TransactionType? type,  DateTime? dateFrom,  DateTime? dateTo,  double? amountMin,  double? amountMax,  bool? hasReceipt,  SortOrder sortOrder)  $default,) {final _that = this;
switch (_that) {
case _ExpenseFilter():
return $default(_that.searchQuery,_that.categoryId,_that.walletId,_that.type,_that.dateFrom,_that.dateTo,_that.amountMin,_that.amountMax,_that.hasReceipt,_that.sortOrder);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? searchQuery,  String? categoryId,  String? walletId,  TransactionType? type,  DateTime? dateFrom,  DateTime? dateTo,  double? amountMin,  double? amountMax,  bool? hasReceipt,  SortOrder sortOrder)?  $default,) {final _that = this;
switch (_that) {
case _ExpenseFilter() when $default != null:
return $default(_that.searchQuery,_that.categoryId,_that.walletId,_that.type,_that.dateFrom,_that.dateTo,_that.amountMin,_that.amountMax,_that.hasReceipt,_that.sortOrder);case _:
  return null;

}
}

}

/// @nodoc


class _ExpenseFilter implements ExpenseFilter {
  const _ExpenseFilter({this.searchQuery, this.categoryId, this.walletId, this.type, this.dateFrom, this.dateTo, this.amountMin, this.amountMax, this.hasReceipt, this.sortOrder = SortOrder.dateDesc});
  

// ── Text search (title, note, tags, merchant) ──────────────────────────
@override final  String? searchQuery;
// ── Category & wallet ─────────────────────────────────────────────────
@override final  String? categoryId;
@override final  String? walletId;
// ── Transaction type ──────────────────────────────────────────────────
@override final  TransactionType? type;
// ── Date range ────────────────────────────────────────────────────────
@override final  DateTime? dateFrom;
@override final  DateTime? dateTo;
// ── Amount range ──────────────────────────────────────────────────────
@override final  double? amountMin;
@override final  double? amountMax;
// ── Receipt filter ────────────────────────────────────────────────────
@override final  bool? hasReceipt;
// ── Sort order ────────────────────────────────────────────────────────
@override@JsonKey() final  SortOrder sortOrder;

/// Create a copy of ExpenseFilter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExpenseFilterCopyWith<_ExpenseFilter> get copyWith => __$ExpenseFilterCopyWithImpl<_ExpenseFilter>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExpenseFilter&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.walletId, walletId) || other.walletId == walletId)&&(identical(other.type, type) || other.type == type)&&(identical(other.dateFrom, dateFrom) || other.dateFrom == dateFrom)&&(identical(other.dateTo, dateTo) || other.dateTo == dateTo)&&(identical(other.amountMin, amountMin) || other.amountMin == amountMin)&&(identical(other.amountMax, amountMax) || other.amountMax == amountMax)&&(identical(other.hasReceipt, hasReceipt) || other.hasReceipt == hasReceipt)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder));
}


@override
int get hashCode => Object.hash(runtimeType,searchQuery,categoryId,walletId,type,dateFrom,dateTo,amountMin,amountMax,hasReceipt,sortOrder);

@override
String toString() {
  return 'ExpenseFilter(searchQuery: $searchQuery, categoryId: $categoryId, walletId: $walletId, type: $type, dateFrom: $dateFrom, dateTo: $dateTo, amountMin: $amountMin, amountMax: $amountMax, hasReceipt: $hasReceipt, sortOrder: $sortOrder)';
}


}

/// @nodoc
abstract mixin class _$ExpenseFilterCopyWith<$Res> implements $ExpenseFilterCopyWith<$Res> {
  factory _$ExpenseFilterCopyWith(_ExpenseFilter value, $Res Function(_ExpenseFilter) _then) = __$ExpenseFilterCopyWithImpl;
@override @useResult
$Res call({
 String? searchQuery, String? categoryId, String? walletId, TransactionType? type, DateTime? dateFrom, DateTime? dateTo, double? amountMin, double? amountMax, bool? hasReceipt, SortOrder sortOrder
});




}
/// @nodoc
class __$ExpenseFilterCopyWithImpl<$Res>
    implements _$ExpenseFilterCopyWith<$Res> {
  __$ExpenseFilterCopyWithImpl(this._self, this._then);

  final _ExpenseFilter _self;
  final $Res Function(_ExpenseFilter) _then;

/// Create a copy of ExpenseFilter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? searchQuery = freezed,Object? categoryId = freezed,Object? walletId = freezed,Object? type = freezed,Object? dateFrom = freezed,Object? dateTo = freezed,Object? amountMin = freezed,Object? amountMax = freezed,Object? hasReceipt = freezed,Object? sortOrder = null,}) {
  return _then(_ExpenseFilter(
searchQuery: freezed == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,walletId: freezed == walletId ? _self.walletId : walletId // ignore: cast_nullable_to_non_nullable
as String?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TransactionType?,dateFrom: freezed == dateFrom ? _self.dateFrom : dateFrom // ignore: cast_nullable_to_non_nullable
as DateTime?,dateTo: freezed == dateTo ? _self.dateTo : dateTo // ignore: cast_nullable_to_non_nullable
as DateTime?,amountMin: freezed == amountMin ? _self.amountMin : amountMin // ignore: cast_nullable_to_non_nullable
as double?,amountMax: freezed == amountMax ? _self.amountMax : amountMax // ignore: cast_nullable_to_non_nullable
as double?,hasReceipt: freezed == hasReceipt ? _self.hasReceipt : hasReceipt // ignore: cast_nullable_to_non_nullable
as bool?,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as SortOrder,
  ));
}


}

// dart format on
