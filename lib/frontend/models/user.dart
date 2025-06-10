import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final int id;
  final String email;
  final String username;
  final String?
  password; // Nota: En producción, nunca deberías almacenar la contraseña en el cliente
  final String? name;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? lastLogin;

  @JsonKey(name: 'role', fromJson: _roleFromJson, toJson: _roleToJson)
  final List<String> roles;

  User({
    required this.id,
    required this.email,
    required this.username,
    required this.password,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    required this.lastLogin,
    required this.roles,
  });

  static List<String> _roleFromJson(dynamic value) {
    if (value is String) {
      return [value];
    } else if (value is List) {
      return List<String>.from(value);
    } else {
      return [];
    }
  }

  static dynamic _roleToJson(List<String> roles) =>
      roles.length == 1 ? roles[0] : roles;

  // Método copyWith para actualizaciones inmutables
  User copyWith({
    int? id,
    String? email,
    String? username,
    String? password,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLogin,
    List<String>? roles,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      password: password ?? this.password,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLogin: lastLogin ?? this.lastLogin,
      roles: roles ?? this.roles,
    );
  }

  // Métodos de serialización
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);

  @override
  String toString() {
    return 'User(id: $id, email: $email, username: $username)';
  }
}
