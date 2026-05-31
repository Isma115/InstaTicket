// region Componentes Página Autenticación: imports
import 'package:flutter/material.dart';

import '../../../../core/data/last_session_storage.dart';
import '../../../../core/data/remote_auth_repository.dart';
import '../../../../core/models/auth_user.dart';
import '../../../home/presentation/pages/role_home_page.dart';
import '../widgets/login_form.dart';
// endregion

// region Lógica Página Autenticación: estado y control de formularios
class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final RemoteAuthRepository _repository = RemoteAuthRepository.instance;
  final LastSessionStorage _lastSessionStorage = LastSessionStorage.instance;

  final GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();
  final TextEditingController _loginEmailController = TextEditingController();
  final TextEditingController _loginPasswordController =
      TextEditingController();
  bool _isRestoringSession = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _restoreLastSession();
  }

  @override
  void dispose() {
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    super.dispose();
  }

  Future<void> _restoreLastSession() async {
    final rememberedSession = await _lastSessionStorage.read();

    if (!mounted) {
      return;
    }

    if (rememberedSession == null) {
      setState(() {
        _isRestoringSession = false;
      });
      return;
    }

    _loginEmailController.text = rememberedSession.email;
    _loginPasswordController.text = rememberedSession.password;

    try {
      final user = await _repository.login(
        email: rememberedSession.email,
        password: rememberedSession.password,
      );

      if (!mounted) {
        return;
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }

        _openHome(
          user.copyWith(
            password: rememberedSession.password,
          ),
        ).then((_) {
          if (!mounted) {
            return;
          }

          setState(() {
            _isRestoringSession = false;
          });
        });
      });
    } catch (_) {
      await _lastSessionStorage.clear();

      if (!mounted) {
        return;
      }

      _loginEmailController.clear();
      _loginPasswordController.clear();

      setState(() {
        _isRestoringSession = false;
      });
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).colorScheme.secondary,
      ),
    );
  }

  Future<void> _openHome(AuthUser user) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RoleHomePage(user: user),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (_isSubmitting) {
      return;
    }

    final isValid = _loginFormKey.currentState?.validate() ?? false;

    if (!isValid) {
      return;
    }

    final email = _loginEmailController.text.trim().toLowerCase();
    final password = _loginPasswordController.text;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final user = await _repository.login(
        email: email,
        password: password,
      );

      final authenticatedUser = user.copyWith(password: password);

      await _lastSessionStorage.save(
        email: authenticatedUser.email,
        password: authenticatedUser.password,
      );

      if (!mounted) {
        return;
      }

      _showMessage('Sesión iniciada como ${authenticatedUser.role.label}.');
      await _openHome(authenticatedUser);
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showMessage(error.toString(), isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
  // endregion

  // region Componentes Página Autenticación: vista principal
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0C1612) : const Color(0xFFEFF2EC),
        ),
        child: SafeArea(
          child: _isRestoringSession
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: Card(
                        color: colorScheme.surfaceContainerLow,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(28, 30, 28, 34),
                          child: LoginForm(
                            formKey: _loginFormKey,
                            emailController: _loginEmailController,
                            passwordController: _loginPasswordController,
                            onSubmit: () {
                              _handleLogin();
                            },
                            isSubmitting: _isSubmitting,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
  // endregion
}
