// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'appointment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Appointment {

 String get id; String get userId; String get barberId; String get barberName; String get barberAvatar; List<ServiceModel> get services; String get date;// "YYYY-MM-DD"
 String get time;// "HH:MM"
 double get totalValue; String get status;// 'pending', 'confirmed', 'completed', 'cancelled'
 String? get notes;
/// Create a copy of Appointment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppointmentCopyWith<Appointment> get copyWith => _$AppointmentCopyWithImpl<Appointment>(this as Appointment, _$identity);

  /// Serializes this Appointment to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Appointment&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.barberId, barberId) || other.barberId == barberId)&&(identical(other.barberName, barberName) || other.barberName == barberName)&&(identical(other.barberAvatar, barberAvatar) || other.barberAvatar == barberAvatar)&&const DeepCollectionEquality().equals(other.services, services)&&(identical(other.date, date) || other.date == date)&&(identical(other.time, time) || other.time == time)&&(identical(other.totalValue, totalValue) || other.totalValue == totalValue)&&(identical(other.status, status) || other.status == status)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,barberId,barberName,barberAvatar,const DeepCollectionEquality().hash(services),date,time,totalValue,status,notes);

@override
String toString() {
  return 'Appointment(id: $id, userId: $userId, barberId: $barberId, barberName: $barberName, barberAvatar: $barberAvatar, services: $services, date: $date, time: $time, totalValue: $totalValue, status: $status, notes: $notes)';
}


}

/// @nodoc
abstract mixin class $AppointmentCopyWith<$Res>  {
  factory $AppointmentCopyWith(Appointment value, $Res Function(Appointment) _then) = _$AppointmentCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String barberId, String barberName, String barberAvatar, List<ServiceModel> services, String date, String time, double totalValue, String status, String? notes
});




}
/// @nodoc
class _$AppointmentCopyWithImpl<$Res>
    implements $AppointmentCopyWith<$Res> {
  _$AppointmentCopyWithImpl(this._self, this._then);

  final Appointment _self;
  final $Res Function(Appointment) _then;

/// Create a copy of Appointment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? barberId = null,Object? barberName = null,Object? barberAvatar = null,Object? services = null,Object? date = null,Object? time = null,Object? totalValue = null,Object? status = null,Object? notes = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,barberId: null == barberId ? _self.barberId : barberId // ignore: cast_nullable_to_non_nullable
as String,barberName: null == barberName ? _self.barberName : barberName // ignore: cast_nullable_to_non_nullable
as String,barberAvatar: null == barberAvatar ? _self.barberAvatar : barberAvatar // ignore: cast_nullable_to_non_nullable
as String,services: null == services ? _self.services : services // ignore: cast_nullable_to_non_nullable
as List<ServiceModel>,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,time: null == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as String,totalValue: null == totalValue ? _self.totalValue : totalValue // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Appointment].
extension AppointmentPatterns on Appointment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Appointment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Appointment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Appointment value)  $default,){
final _that = this;
switch (_that) {
case _Appointment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Appointment value)?  $default,){
final _that = this;
switch (_that) {
case _Appointment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String barberId,  String barberName,  String barberAvatar,  List<ServiceModel> services,  String date,  String time,  double totalValue,  String status,  String? notes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Appointment() when $default != null:
return $default(_that.id,_that.userId,_that.barberId,_that.barberName,_that.barberAvatar,_that.services,_that.date,_that.time,_that.totalValue,_that.status,_that.notes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String barberId,  String barberName,  String barberAvatar,  List<ServiceModel> services,  String date,  String time,  double totalValue,  String status,  String? notes)  $default,) {final _that = this;
switch (_that) {
case _Appointment():
return $default(_that.id,_that.userId,_that.barberId,_that.barberName,_that.barberAvatar,_that.services,_that.date,_that.time,_that.totalValue,_that.status,_that.notes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String barberId,  String barberName,  String barberAvatar,  List<ServiceModel> services,  String date,  String time,  double totalValue,  String status,  String? notes)?  $default,) {final _that = this;
switch (_that) {
case _Appointment() when $default != null:
return $default(_that.id,_that.userId,_that.barberId,_that.barberName,_that.barberAvatar,_that.services,_that.date,_that.time,_that.totalValue,_that.status,_that.notes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Appointment implements Appointment {
  const _Appointment({required this.id, required this.userId, required this.barberId, required this.barberName, required this.barberAvatar, required final  List<ServiceModel> services, required this.date, required this.time, required this.totalValue, required this.status, this.notes}): _services = services;
  factory _Appointment.fromJson(Map<String, dynamic> json) => _$AppointmentFromJson(json);

@override final  String id;
@override final  String userId;
@override final  String barberId;
@override final  String barberName;
@override final  String barberAvatar;
 final  List<ServiceModel> _services;
@override List<ServiceModel> get services {
  if (_services is EqualUnmodifiableListView) return _services;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_services);
}

@override final  String date;
// "YYYY-MM-DD"
@override final  String time;
// "HH:MM"
@override final  double totalValue;
@override final  String status;
// 'pending', 'confirmed', 'completed', 'cancelled'
@override final  String? notes;

/// Create a copy of Appointment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppointmentCopyWith<_Appointment> get copyWith => __$AppointmentCopyWithImpl<_Appointment>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AppointmentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Appointment&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.barberId, barberId) || other.barberId == barberId)&&(identical(other.barberName, barberName) || other.barberName == barberName)&&(identical(other.barberAvatar, barberAvatar) || other.barberAvatar == barberAvatar)&&const DeepCollectionEquality().equals(other._services, _services)&&(identical(other.date, date) || other.date == date)&&(identical(other.time, time) || other.time == time)&&(identical(other.totalValue, totalValue) || other.totalValue == totalValue)&&(identical(other.status, status) || other.status == status)&&(identical(other.notes, notes) || other.notes == notes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,barberId,barberName,barberAvatar,const DeepCollectionEquality().hash(_services),date,time,totalValue,status,notes);

@override
String toString() {
  return 'Appointment(id: $id, userId: $userId, barberId: $barberId, barberName: $barberName, barberAvatar: $barberAvatar, services: $services, date: $date, time: $time, totalValue: $totalValue, status: $status, notes: $notes)';
}


}

/// @nodoc
abstract mixin class _$AppointmentCopyWith<$Res> implements $AppointmentCopyWith<$Res> {
  factory _$AppointmentCopyWith(_Appointment value, $Res Function(_Appointment) _then) = __$AppointmentCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String barberId, String barberName, String barberAvatar, List<ServiceModel> services, String date, String time, double totalValue, String status, String? notes
});




}
/// @nodoc
class __$AppointmentCopyWithImpl<$Res>
    implements _$AppointmentCopyWith<$Res> {
  __$AppointmentCopyWithImpl(this._self, this._then);

  final _Appointment _self;
  final $Res Function(_Appointment) _then;

/// Create a copy of Appointment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? barberId = null,Object? barberName = null,Object? barberAvatar = null,Object? services = null,Object? date = null,Object? time = null,Object? totalValue = null,Object? status = null,Object? notes = freezed,}) {
  return _then(_Appointment(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,barberId: null == barberId ? _self.barberId : barberId // ignore: cast_nullable_to_non_nullable
as String,barberName: null == barberName ? _self.barberName : barberName // ignore: cast_nullable_to_non_nullable
as String,barberAvatar: null == barberAvatar ? _self.barberAvatar : barberAvatar // ignore: cast_nullable_to_non_nullable
as String,services: null == services ? _self._services : services // ignore: cast_nullable_to_non_nullable
as List<ServiceModel>,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,time: null == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as String,totalValue: null == totalValue ? _self.totalValue : totalValue // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
