// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: (json['id'] as num).toInt(),
  email: json['email'] as String,
  username: json['username'] as String,
  password: json['password'] as String?,
  name: json['name'] as String?,
  avatarUrl: json['avatarUrl'] as String?,
  createdAt:
      json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
  updatedAt:
      json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
  lastLogin:
      json['lastLogin'] == null
          ? null
          : DateTime.parse(json['lastLogin'] as String),
  roles: User._roleFromJson(json['role']),
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'username': instance.username,
  'password': instance.password,
  'name': instance.name,
  'avatarUrl': instance.avatarUrl,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'lastLogin': instance.lastLogin?.toIso8601String(),
  'role': User._roleToJson(instance.roles),
};
