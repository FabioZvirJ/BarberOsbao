// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'barber.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Barber {

 String get id; String get name; String get avatarUrl; double get rating; List<String> get specialties; String get bio; List<String> get availableDays;// "YYYY-MM-DD"
 List<String> get availableHours;// "HH:MM"
 double get commissionRate; String get status;
/// Create a copy of Barber
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BarberCopyWith<Barber> get copyWith => _$BarberCopyWithImpl<Barber>(this as Barber, _$identity);

  /// Serializes this Barber to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Barber&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.rating, rating) || other.rating == rating)&&const DeepCollectionEquality().equals(other.specialties, specialties)&&(identical(other.bio, bio) || other.bio == bio)&&const DeepCollectionEquality().equals(other.availableDays, availableDays)&&const DeepCollectionEquality().equals(other.availableHours, availableHours)&&(identical(other.commissionRate, commissionRate) || other.commissionRate == commissionRate)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,avatarUrl,rating,const DeepCollectionEquality().hash(specialties),bio,const DeepCollectionEquality().hash(availableDays),const DeepCollectionEquality().hash(availableHours),commissionRate,status);

@override
String toString() {
  return 'Barber(id: $id, name: $name, avatarUrl: $avatarUrl, rating: $rating, specialties: $specialties, bio: $bio, availableDays: $availableDays, availableHours: $availableHours, commissionRate: $commissionRate, status: $status)';
}


}

/// @nodoc
abstract mixin class $BarberCopyWith<$Res>  {
  factory $BarberCopyWith(Barber value, $Res Function(Barber) _then) = _$BarberCopyWithImpl;
@useResult
$Res call({
 String id, String name, String avatarUrl, double rating, List<String> specialties, String bio, List<String> availableDays, List<String> availableHours, double commissionRate, String status
});




}
/// @nodoc
class _$BarberCopyWithImpl<$Res>
    implements $BarberCopyWith<$Res> {
  _$BarberCopyWithImpl(this._self, this._then);

  final Barber _self;
  final $Res Function(Barber) _then;

/// Create a copy of Barber
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? avatarUrl = null,Object? rating = null,Object? specialties = null,Object? bio = null,Object? availableDays = null,Object? availableHours = null,Object? commissionRate = null,Object? status = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: null == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double,specialties: null == specialties ? _self.specialties : specialties // ignore: cast_nullable_to_non_nullable
as List<String>,bio: null == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String,availableDays: null == availableDays ? _self.availableDays : availableDays // ignore: cast_nullable_to_non_nullable
as List<String>,availableHours: null == availableHours ? _self.availableHours : availableHours // ignore: cast_nullable_to_non_nullable
as List<String>,commissionRate: null == commissionRate ? _self.commissionRate : commissionRate // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Barber].
extension BarberPatterns on Barber {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Barber value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Barber() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Barber value)  $default,){
final _that = this;
switch (_that) {
case _Barber():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Barber value)?  $default,){
final _that = this;
switch (_that) {
case _Barber() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String avatarUrl,  double rating,  List<String> specialties,  String bio,  List<String> availableDays,  List<String> availableHours,  double commissionRate,  String status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Barber() when $default != null:
return $default(_that.id,_that.name,_that.avatarUrl,_that.rating,_that.specialties,_that.bio,_that.availableDays,_that.availableHours,_that.commissionRate,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String avatarUrl,  double rating,  List<String> specialties,  String bio,  List<String> availableDays,  List<String> availableHours,  double commissionRate,  String status)  $default,) {final _that = this;
switch (_that) {
case _Barber():
return $default(_that.id,_that.name,_that.avatarUrl,_that.rating,_that.specialties,_that.bio,_that.availableDays,_that.availableHours,_that.commissionRate,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String avatarUrl,  double rating,  List<String> specialties,  String bio,  List<String> availableDays,  List<String> availableHours,  double commissionRate,  String status)?  $default,) {final _that = this;
switch (_that) {
case _Barber() when $default != null:
return $default(_that.id,_that.name,_that.avatarUrl,_that.rating,_that.specialties,_that.bio,_that.availableDays,_that.availableHours,_that.commissionRate,_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Barber implements Barber {
  const _Barber({required this.id, required this.name, required this.avatarUrl, required this.rating, required final  List<String> specialties, required this.bio, required final  List<String> availableDays, required final  List<String> availableHours, this.commissionRate = 0.3, this.status = 'active'}): _specialties = specialties,_availableDays = availableDays,_availableHours = availableHours;
  factory _Barber.fromJson(Map<String, dynamic> json) => _$BarberFromJson(json);

@override final  String id;
@override final  String name;
@override final  String avatarUrl;
@override final  double rating;
 final  List<String> _specialties;
@override List<String> get specialties {
  if (_specialties is EqualUnmodifiableListView) return _specialties;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_specialties);
}

@override final  String bio;
 final  List<String> _availableDays;
@override List<String> get availableDays {
  if (_availableDays is EqualUnmodifiableListView) return _availableDays;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_availableDays);
}

// "YYYY-MM-DD"
 final  List<String> _availableHours;
// "YYYY-MM-DD"
@override List<String> get availableHours {
  if (_availableHours is EqualUnmodifiableListView) return _availableHours;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_availableHours);
}

// "HH:MM"
@override@JsonKey() final  double commissionRate;
@override@JsonKey() final  String status;

/// Create a copy of Barber
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BarberCopyWith<_Barber> get copyWith => __$BarberCopyWithImpl<_Barber>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BarberToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Barber&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.rating, rating) || other.rating == rating)&&const DeepCollectionEquality().equals(other._specialties, _specialties)&&(identical(other.bio, bio) || other.bio == bio)&&const DeepCollectionEquality().equals(other._availableDays, _availableDays)&&const DeepCollectionEquality().equals(other._availableHours, _availableHours)&&(identical(other.commissionRate, commissionRate) || other.commissionRate == commissionRate)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,avatarUrl,rating,const DeepCollectionEquality().hash(_specialties),bio,const DeepCollectionEquality().hash(_availableDays),const DeepCollectionEquality().hash(_availableHours),commissionRate,status);

@override
String toString() {
  return 'Barber(id: $id, name: $name, avatarUrl: $avatarUrl, rating: $rating, specialties: $specialties, bio: $bio, availableDays: $availableDays, availableHours: $availableHours, commissionRate: $commissionRate, status: $status)';
}


}

/// @nodoc
abstract mixin class _$BarberCopyWith<$Res> implements $BarberCopyWith<$Res> {
  factory _$BarberCopyWith(_Barber value, $Res Function(_Barber) _then) = __$BarberCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String avatarUrl, double rating, List<String> specialties, String bio, List<String> availableDays, List<String> availableHours, double commissionRate, String status
});




}
/// @nodoc
class __$BarberCopyWithImpl<$Res>
    implements _$BarberCopyWith<$Res> {
  __$BarberCopyWithImpl(this._self, this._then);

  final _Barber _self;
  final $Res Function(_Barber) _then;

/// Create a copy of Barber
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? avatarUrl = null,Object? rating = null,Object? specialties = null,Object? bio = null,Object? availableDays = null,Object? availableHours = null,Object? commissionRate = null,Object? status = null,}) {
  return _then(_Barber(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: null == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double,specialties: null == specialties ? _self._specialties : specialties // ignore: cast_nullable_to_non_nullable
as List<String>,bio: null == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String,availableDays: null == availableDays ? _self._availableDays : availableDays // ignore: cast_nullable_to_non_nullable
as List<String>,availableHours: null == availableHours ? _self._availableHours : availableHours // ignore: cast_nullable_to_non_nullable
as List<String>,commissionRate: null == commissionRate ? _self.commissionRate : commissionRate // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
