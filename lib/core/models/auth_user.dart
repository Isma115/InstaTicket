// #region Autenticacion | Funcionalidad | Modelo de usuario autenticado
import 'user_role.dart';

class AuthUser {
  const AuthUser({
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    this.lastName,
    this.photoUrl,
    this.twoFactorEnabled = false,
  });

  final String name;
  final String? lastName;
  final String email;
  final String password;
  final UserRole role;
  final String? photoUrl;
  final bool twoFactorEnabled;

  String get displayName {
    final normalizedLastName = lastName?.trim() ?? '';

    if (normalizedLastName.isEmpty) {
      return name.trim();
    }

    return '${name.trim()} $normalizedLastName';
  }

  AuthUser copyWith({
    String? name,
    String? lastName,
    String? email,
    String? password,
    UserRole? role,
    String? photoUrl,
    bool? twoFactorEnabled,
  }) {
    return AuthUser(
      name: name ?? this.name,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      password: password ?? this.password,
      role: role ?? this.role,
      photoUrl: photoUrl ?? this.photoUrl,
      twoFactorEnabled: twoFactorEnabled ?? this.twoFactorEnabled,
    );
  }
}
// #endregion
