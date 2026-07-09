// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Review _$ReviewFromJson(Map<String, dynamic> json) => _Review(
  id: json['id'] as String,
  scheduleId: json['scheduleId'] as String,
  userId: json['userId'] as String,
  userName: json['userName'] as String,
  barberId: json['barberId'] as String,
  rating: (json['rating'] as num).toInt(),
  comment: json['comment'] as String,
  createdAt: json['createdAt'] as String,
);

Map<String, dynamic> _$ReviewToJson(_Review instance) => <String, dynamic>{
  'id': instance.id,
  'scheduleId': instance.scheduleId,
  'userId': instance.userId,
  'userName': instance.userName,
  'barberId': instance.barberId,
  'rating': instance.rating,
  'comment': instance.comment,
  'createdAt': instance.createdAt,
};
