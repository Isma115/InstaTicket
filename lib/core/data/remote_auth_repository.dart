// #region Autenticacion | Funcionalidad | Repositorio remoto de autenticacion
import '../models/auth_user.dart';
import '../models/user_role.dart';
import 'api_client.dart';

class RemoteAuthRepository {
  RemoteAuthRepository._();

  static final RemoteAuthRepository instance = RemoteAuthRepository._();

  final ApiClient _client = ApiClient.instance;

  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    final payload = await _client.postJson(
      '/api/auth/login',
      body: <String, dynamic>{
        'email': email.trim().toLowerCase(),
        'password': password,
      },
    );

    final userMap = payload['user'];
    if (userMap is! Map<String, dynamic>) {
      throw const ApiException('Respuesta de login invalida.');
    }

    return _mapAuthUser(userMap);
  }

  UserRole _mapRole(String rawRole) {
    switch (rawRole.trim().toLowerCase()) {
      case 'tecnico':
        return UserRole.tecnico;
      case 'admin':
        return UserRole.admin;
      case 'cliente':
      default:
        return UserRole.cliente;
    }
  }

  AuthUser _mapAuthUser(Map<String, dynamic> json) {
    return AuthUser(
      name: json['name']?.toString().trim().isNotEmpty == true
          ? json['name'].toString().trim()
          : 'Usuario',
      lastName: json['lastName']?.toString().trim().isNotEmpty == true
          ? json['lastName'].toString().trim()
          : null,
      email: json['email']?.toString().trim().toLowerCase() ?? '',
      password: json['password']?.toString() ?? '',
      role: _mapRole(json['role']?.toString() ?? ''),
      photoUrl: json['photoUrl']?.toString().trim().isNotEmpty == true
          ? json['photoUrl'].toString().trim()
          : null,
      twoFactorEnabled: json['twoFactorEnabled'] == true,
    );
  }
}
// #endregion
