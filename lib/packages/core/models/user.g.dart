// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_User _$UserFromJson(Map<String, dynamic> json) => _User(
  id: json['id'] as String,
  name: json['name'] as String,
  email: json['email'] as String,
  phone: json['phone'] as String,
  avatarUrl: json['avatarUrl'] as String,
  theme: json['theme'] as String,
  language: json['language'] as String,
  emailNotifications: json['emailNotifications'] as bool,
  pushNotifications: json['pushNotifications'] as bool,
  whatsappNotifications: json['whatsappNotifications'] as bool,
  role: json['role'] as String? ?? 'client',
);

Map<String, dynamic> _$UserToJson(_User instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'email': instance.email,
  'phone': instance.phone,
  'avatarUrl': instance.avatarUrl,
  'theme': instance.theme,
  'language': instance.language,
  'emailNotifications': instance.emailNotifications,
  'pushNotifications': instance.pushNotifications,
  'whatsappNotifications': instance.whatsappNotifications,
  'role': instance.role,
};
