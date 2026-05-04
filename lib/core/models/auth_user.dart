// region Lógica Backend Frontend: modelo de usuario autenticado
import 'user_role.dart';

class AuthUser {
  const AuthUser({
    required this.name,
    required this.email,
    required this.password,
    required this.role,
  });

  final String name;
  final String email;
  final String password;
  final UserRole role;
}
// endregion
