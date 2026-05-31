// region Lógica Backend Frontend: repositorio mock de autenticación
import 'dart:collection';

import '../models/auth_user.dart';
import '../models/user_role.dart';

class MockAuthRepository {
  MockAuthRepository._();

  static final MockAuthRepository instance = MockAuthRepository._();

  final List<AuthUser> _users = <AuthUser>[
    const AuthUser(
      name: 'Laura',
      lastName: 'Soporte',
      email: 'tecnico@test.com',
      password: '1234',
      role: UserRole.tecnico,
      photoUrl: 'https://i.pravatar.cc/300?img=32',
      twoFactorEnabled: true,
    ),
    const AuthUser(
      name: 'Mario',
      lastName: 'Admin',
      email: 'admin@test.com',
      password: '1234',
      role: UserRole.admin,
      photoUrl: 'https://i.pravatar.cc/300?img=53',
      twoFactorEnabled: true,
    ),
    const AuthUser(
      name: 'Clara',
      lastName: 'Cliente',
      email: 'cliente@test.com',
      password: '1234',
      role: UserRole.cliente,
      photoUrl: 'https://i.pravatar.cc/300?img=47',
    ),
  ];

  UnmodifiableListView<AuthUser> get demoUsers =>
      UnmodifiableListView<AuthUser>(_users);

  AuthUser? login({
    required String email,
    required String password,
  }) {
    final normalizedEmail = email.trim().toLowerCase();

    for (final user in _users) {
      final matchesEmail = user.email.toLowerCase() == normalizedEmail;
      final matchesPassword = user.password == password;

      if (matchesEmail && matchesPassword) {
        return user;
      }
    }

    return null;
  }

  AuthUser register({
    required String name,
    required String email,
    required String password,
  }) {
    final normalizedEmail = email.trim().toLowerCase();
    final alreadyExists = _users.any(
      (user) => user.email.toLowerCase() == normalizedEmail,
    );

    if (alreadyExists) {
      throw StateError('Ya existe un usuario registrado con ese email.');
    }

    final user = AuthUser(
      name: name.trim(),
      email: normalizedEmail,
      password: password,
      role: UserRole.cliente,
    );

    _users.add(user);
    return user;
  }
}
// endregion
