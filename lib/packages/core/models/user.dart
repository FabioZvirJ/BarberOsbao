import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
abstract class User with _$User {
  const factory User({
    required String id,
    required String name,
    required String email,
    required String phone,
    required String avatarUrl,
    required String theme, // 'dark' or 'light'
    required String language, // 'pt-BR' or 'en'
    required bool emailNotifications,
    required bool pushNotifications,
    required bool whatsappNotifications,
    @Default('client') String role,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
