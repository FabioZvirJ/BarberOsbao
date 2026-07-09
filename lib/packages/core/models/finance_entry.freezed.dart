// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'finance_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FinanceEntry {

 String get id; String get type;// 'income' or 'expense'
 String get description; double get amount; String get category; String get date; String get paymentMethod; String get status;
/// Create a copy of FinanceEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FinanceEntryCopyWith<FinanceEntry> get copyWith => _$FinanceEntryCopyWithImpl<FinanceEntry>(this as FinanceEntry, _$identity);

  /// Serializes this FinanceEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FinanceEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.description, description) || other.description == description)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.category, category) || other.category == category)&&(identical(other.date, date) || other.date == date)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,description,amount,category,date,paymentMethod,status);

@override
String toString() {
  return 'FinanceEntry(id: $id, type: $type, description: $description, amount: $amount, category: $category, date: $date, paymentMethod: $paymentMethod, status: $status)';
}


}

/// @nodoc
abstract mixin class $FinanceEntryCopyWith<$Res>  {
  factory $FinanceEntryCopyWith(FinanceEntry value, $Res Function(FinanceEntry) _then) = _$FinanceEntryCopyWithImpl;
@useResult
$Res call({
 String id, String type, String description, double amount, String category, String date, String paymentMethod, String status
});




}
/// @nodoc
class _$FinanceEntryCopyWithImpl<$Res>
    implements $FinanceEntryCopyWith<$Res> {
  _$FinanceEntryCopyWithImpl(this._self, this._then);

  final FinanceEntry _self;
  final $Res Function(FinanceEntry) _then;

/// Create a copy of FinanceEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? description = null,Object? amount = null,Object? category = null,Object? date = null,Object? paymentMethod = null,Object? status = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,paymentMethod: null == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [FinanceEntry].
extension FinanceEntryPatterns on FinanceEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FinanceEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FinanceEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FinanceEntry value)  $default,){
final _that = this;
switch (_that) {
case _FinanceEntry():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FinanceEntry value)?  $default,){
final _that = this;
switch (_that) {
case _FinanceEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String type,  String description,  double amount,  String category,  String date,  String paymentMethod,  String status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FinanceEntry() when $default != null:
return $default(_that.id,_that.type,_that.description,_that.amount,_that.category,_that.date,_that.paymentMethod,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String type,  String description,  double amount,  String category,  String date,  String paymentMethod,  String status)  $default,) {final _that = this;
switch (_that) {
case _FinanceEntry():
return $default(_that.id,_that.type,_that.description,_that.amount,_that.category,_that.date,_that.paymentMethod,_that.status);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String type,  String description,  double amount,  String category,  String date,  String paymentMethod,  String status)?  $default,) {final _that = this;
switch (_that) {
case _FinanceEntry() when $default != null:
return $default(_that.id,_that.type,_that.description,_that.amount,_that.category,_that.date,_that.paymentMethod,_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FinanceEntry implements FinanceEntry {
  const _FinanceEntry({required this.id, required this.type, required this.description, required this.amount, required this.category, required this.date, required this.paymentMethod, required this.status});
  factory _FinanceEntry.fromJson(Map<String, dynamic> json) => _$FinanceEntryFromJson(json);

@override final  String id;
@override final  String type;
// 'income' or 'expense'
@override final  String description;
@override final  double amount;
@override final  String category;
@override final  String date;
@override final  String paymentMethod;
@override final  String status;

/// Create a copy of FinanceEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FinanceEntryCopyWith<_FinanceEntry> get copyWith => __$FinanceEntryCopyWithImpl<_FinanceEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FinanceEntryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FinanceEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.description, description) || other.description == description)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.category, category) || other.category == category)&&(identical(other.date, date) || other.date == date)&&(identical(other.paymentMethod, paymentMethod) || other.paymentMethod == paymentMethod)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,description,amount,category,date,paymentMethod,status);

@override
String toString() {
  return 'FinanceEntry(id: $id, type: $type, description: $description, amount: $amount, category: $category, date: $date, paymentMethod: $paymentMethod, status: $status)';
}


}

/// @nodoc
abstract mixin class _$FinanceEntryCopyWith<$Res> implements $FinanceEntryCopyWith<$Res> {
  factory _$FinanceEntryCopyWith(_FinanceEntry value, $Res Function(_FinanceEntry) _then) = __$FinanceEntryCopyWithImpl;
@override @useResult
$Res call({
 String id, String type, String description, double amount, String category, String date, String paymentMethod, String status
});




}
/// @nodoc
class __$FinanceEntryCopyWithImpl<$Res>
    implements _$FinanceEntryCopyWith<$Res> {
  __$FinanceEntryCopyWithImpl(this._self, this._then);

  final _FinanceEntry _self;
  final $Res Function(_FinanceEntry) _then;

/// Create a copy of FinanceEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? description = null,Object? amount = null,Object? category = null,Object? date = null,Object? paymentMethod = null,Object? status = null,}) {
  return _then(_FinanceEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,paymentMethod: null == paymentMethod ? _self.paymentMethod : paymentMethod // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
