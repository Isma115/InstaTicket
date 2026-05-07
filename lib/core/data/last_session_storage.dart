// region Lógica Backend Frontend: persistencia local de la ultima sesion
import 'package:shared_preferences/shared_preferences.dart';

class LastSessionCredentials {
  const LastSessionCredentials({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;
}

class LastSessionStorage {
  LastSessionStorage._();

  static final LastSessionStorage instance = LastSessionStorage._();

  static const String _emailKey = 'last_session_email';
  static const String _passwordKey = 'last_session_password';

  Future<LastSessionCredentials?> read() async {
    final preferences = await SharedPreferences.getInstance();
    final email = preferences.getString(_emailKey)?.trim() ?? '';
    final password = preferences.getString(_passwordKey) ?? '';

    if (email.isEmpty || password.isEmpty) {
      return null;
    }

    return LastSessionCredentials(
      email: email,
      password: password,
    );
  }

  Future<void> save({
    required String email,
    required String password,
  }) async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.setString(_emailKey, email.trim().toLowerCase());
    await preferences.setString(_passwordKey, password);
  }

  Future<void> clear() async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.remove(_emailKey);
    await preferences.remove(_passwordKey);
  }
}
// endregion
