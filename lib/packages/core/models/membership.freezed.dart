// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'membership.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Membership {

 String get id; String get userId; String get planId; String get planName; String get startDate; String get endDate; String get status;// 'active', 'inactive', 'expired'
 List<String> get remainingBenefits; int get discountsUsed; String get nextRenewalDate;
/// Create a copy of Membership
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MembershipCopyWith<Membership> get copyWith => _$MembershipCopyWithImpl<Membership>(this as Membership, _$identity);

  /// Serializes this Membership to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Membership&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.planId, planId) || other.planId == planId)&&(identical(other.planName, planName) || other.planName == planName)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.remainingBenefits, remainingBenefits)&&(identical(other.discountsUsed, discountsUsed) || other.discountsUsed == discountsUsed)&&(identical(other.nextRenewalDate, nextRenewalDate) || other.nextRenewalDate == nextRenewalDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,planId,planName,startDate,endDate,status,const DeepCollectionEquality().hash(remainingBenefits),discountsUsed,nextRenewalDate);

@override
String toString() {
  return 'Membership(id: $id, userId: $userId, planId: $planId, planName: $planName, startDate: $startDate, endDate: $endDate, status: $status, remainingBenefits: $remainingBenefits, discountsUsed: $discountsUsed, nextRenewalDate: $nextRenewalDate)';
}


}

/// @nodoc
abstract mixin class $MembershipCopyWith<$Res>  {
  factory $MembershipCopyWith(Membership value, $Res Function(Membership) _then) = _$MembershipCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String planId, String planName, String startDate, String endDate, String status, List<String> remainingBenefits, int discountsUsed, String nextRenewalDate
});




}
/// @nodoc
class _$MembershipCopyWithImpl<$Res>
    implements $MembershipCopyWith<$Res> {
  _$MembershipCopyWithImpl(this._self, this._then);

  final Membership _self;
  final $Res Function(Membership) _then;

/// Create a copy of Membership
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? planId = null,Object? planName = null,Object? startDate = null,Object? endDate = null,Object? status = null,Object? remainingBenefits = null,Object? discountsUsed = null,Object? nextRenewalDate = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,planId: null == planId ? _self.planId : planId // ignore: cast_nullable_to_non_nullable
as String,planName: null == planName ? _self.planName : planName // ignore: cast_nullable_to_non_nullable
as String,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as String,endDate: null == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,remainingBenefits: null == remainingBenefits ? _self.remainingBenefits : remainingBenefits // ignore: cast_nullable_to_non_nullable
as List<String>,discountsUsed: null == discountsUsed ? _self.discountsUsed : discountsUsed // ignore: cast_nullable_to_non_nullable
as int,nextRenewalDate: null == nextRenewalDate ? _self.nextRenewalDate : nextRenewalDate // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Membership].
extension MembershipPatterns on Membership {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Membership value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Membership() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Membership value)  $default,){
final _that = this;
switch (_that) {
case _Membership():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Membership value)?  $default,){
final _that = this;
switch (_that) {
case _Membership() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String planId,  String planName,  String startDate,  String endDate,  String status,  List<String> remainingBenefits,  int discountsUsed,  String nextRenewalDate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Membership() when $default != null:
return $default(_that.id,_that.userId,_that.planId,_that.planName,_that.startDate,_that.endDate,_that.status,_that.remainingBenefits,_that.discountsUsed,_that.nextRenewalDate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String planId,  String planName,  String startDate,  String endDate,  String status,  List<String> remainingBenefits,  int discountsUsed,  String nextRenewalDate)  $default,) {final _that = this;
switch (_that) {
case _Membership():
return $default(_that.id,_that.userId,_that.planId,_that.planName,_that.startDate,_that.endDate,_that.status,_that.remainingBenefits,_that.discountsUsed,_that.nextRenewalDate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String planId,  String planName,  String startDate,  String endDate,  String status,  List<String> remainingBenefits,  int discountsUsed,  String nextRenewalDate)?  $default,) {final _that = this;
switch (_that) {
case _Membership() when $default != null:
return $default(_that.id,_that.userId,_that.planId,_that.planName,_that.startDate,_that.endDate,_that.status,_that.remainingBenefits,_that.discountsUsed,_that.nextRenewalDate);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Membership implements Membership {
  const _Membership({required this.id, required this.userId, required this.planId, required this.planName, required this.startDate, required this.endDate, required this.status, required final  List<String> remainingBenefits, required this.discountsUsed, required this.nextRenewalDate}): _remainingBenefits = remainingBenefits;
  factory _Membership.fromJson(Map<String, dynamic> json) => _$MembershipFromJson(json);

@override final  String id;
@override final  String userId;
@override final  String planId;
@override final  String planName;
@override final  String startDate;
@override final  String endDate;
@override final  String status;
// 'active', 'inactive', 'expired'
 final  List<String> _remainingBenefits;
// 'active', 'inactive', 'expired'
@override List<String> get remainingBenefits {
  if (_remainingBenefits is EqualUnmodifiableListView) return _remainingBenefits;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_remainingBenefits);
}

@override final  int discountsUsed;
@override final  String nextRenewalDate;

/// Create a copy of Membership
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MembershipCopyWith<_Membership> get copyWith => __$MembershipCopyWithImpl<_Membership>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MembershipToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Membership&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.planId, planId) || other.planId == planId)&&(identical(other.planName, planName) || other.planName == planName)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._remainingBenefits, _remainingBenefits)&&(identical(other.discountsUsed, discountsUsed) || other.discountsUsed == discountsUsed)&&(identical(other.nextRenewalDate, nextRenewalDate) || other.nextRenewalDate == nextRenewalDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,planId,planName,startDate,endDate,status,const DeepCollectionEquality().hash(_remainingBenefits),discountsUsed,nextRenewalDate);

@override
String toString() {
  return 'Membership(id: $id, userId: $userId, planId: $planId, planName: $planName, startDate: $startDate, endDate: $endDate, status: $status, remainingBenefits: $remainingBenefits, discountsUsed: $discountsUsed, nextRenewalDate: $nextRenewalDate)';
}


}

/// @nodoc
abstract mixin class _$MembershipCopyWith<$Res> implements $MembershipCopyWith<$Res> {
  factory _$MembershipCopyWith(_Membership value, $Res Function(_Membership) _then) = __$MembershipCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String planId, String planName, String startDate, String endDate, String status, List<String> remainingBenefits, int discountsUsed, String nextRenewalDate
});




}
/// @nodoc
class __$MembershipCopyWithImpl<$Res>
    implements _$MembershipCopyWith<$Res> {
  __$MembershipCopyWithImpl(this._self, this._then);

  final _Membership _self;
  final $Res Function(_Membership) _then;

/// Create a copy of Membership
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? planId = null,Object? planName = null,Object? startDate = null,Object? endDate = null,Object? status = null,Object? remainingBenefits = null,Object? discountsUsed = null,Object? nextRenewalDate = null,}) {
  return _then(_Membership(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,planId: null == planId ? _self.planId : planId // ignore: cast_nullable_to_non_nullable
as String,planName: null == planName ? _self.planName : planName // ignore: cast_nullable_to_non_nullable
as String,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as String,endDate: null == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,remainingBenefits: null == remainingBenefits ? _self._remainingBenefits : remainingBenefits // ignore: cast_nullable_to_non_nullable
as List<String>,discountsUsed: null == discountsUsed ? _self.discountsUsed : discountsUsed // ignore: cast_nullable_to_non_nullable
as int,nextRenewalDate: null == nextRenewalDate ? _self.nextRenewalDate : nextRenewalDate // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
