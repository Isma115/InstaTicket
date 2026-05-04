// region Componentes Página Autenticación: imports
import 'package:flutter/material.dart';

import '../../../../core/data/mock_auth_repository.dart';
import '../../../../core/models/auth_user.dart';
import '../../../home/presentation/pages/role_home_page.dart';
import '../widgets/login_form.dart';
import '../widgets/register_form.dart';
// endregion

// region Lógica Página Autenticación: estado y control de formularios
enum AuthMode {
  login,
  register,
}

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final MockAuthRepository _repository = MockAuthRepository.instance;

  final GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _registerFormKey = GlobalKey<FormState>();

  final TextEditingController _loginEmailController = TextEditingController();
  final TextEditingController _loginPasswordController =
      TextEditingController();
  final TextEditingController _registerNameController =
      TextEditingController();
  final TextEditingController _registerEmailController =
      TextEditingController();
  final TextEditingController _registerPasswordController =
      TextEditingController();

  AuthMode _mode = AuthMode.login;

  @override
  void dispose() {
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _registerNameController.dispose();
    _registerEmailController.dispose();
    _registerPasswordController.dispose();
    super.dispose();
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

  void _openHome(AuthUser user) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RoleHomePage(user: user),
      ),
    );
  }

  void _handleLogin() {
    final isValid = _loginFormKey.currentState?.validate() ?? false;

    if (!isValid) {
      return;
    }

    final user = _repository.login(
      email: _loginEmailController.text,
      password: _loginPasswordController.text,
    );

    if (user == null) {
      _showMessage('Credenciales incorrectas.', isError: true);
      return;
    }

    _showMessage('Sesion iniciada como ${user.role.label}.');
    _openHome(user);
  }

  void _handleRegister() {
    final isValid = _registerFormKey.currentState?.validate() ?? false;

    if (!isValid) {
      return;
    }

    try {
      final user = _repository.register(
        name: _registerNameController.text,
        email: _registerEmailController.text,
        password: _registerPasswordController.text,
      );

      _showMessage('Cuenta creada. Se ha iniciado sesion como cliente.');
      _openHome(user);
    } on StateError catch (error) {
      _showMessage(
        error.message.toString(),
        isError: true,
      );
    }
  }
  // endregion

  // region Componentes Página Autenticación: vista principal
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final useColumn = constraints.maxWidth < 960;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1120),
                  child: useColumn
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            _buildInfoPanel(context),
                            const SizedBox(height: 24),
                            _buildFormPanel(context),
                          ],
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              flex: 11,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 24),
                                child: _buildInfoPanel(context),
                              ),
                            ),
                            Expanded(
                              flex: 9,
                              child: _buildFormPanel(context),
                            ),
                          ],
                        ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
  // endregion
}

// region Componentes Página Autenticación: cabecera informativa
extension on _AuthPageState {
  Widget _buildInfoPanel(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: const Color(0xFFD9E1EC)),
          ),
          child: Text(
            'InstaTicket',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Acceso centralizado para soporte, administracion y clientes.',
          style: theme.textTheme.headlineMedium,
        ),
        const SizedBox(height: 16),
        Text(
          'Frontend Flutter con autenticacion simulada y separacion base de backend para evolucion futura.',
          style: theme.textTheme.bodyLarge,
        ),
        const SizedBox(height: 28),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: const <Widget>[
            _InfoMetric(
              title: '3 roles',
              subtitle: 'tecnico, admin y cliente',
              color: Color(0xFF2457F5),
            ),
            _InfoMetric(
              title: 'Registro',
              subtitle: 'nuevas cuentas como cliente',
              color: Color(0xFF00A884),
            ),
            _InfoMetric(
              title: 'Mock data',
              subtitle: 'credenciales listas para prueba',
              color: Color(0xFFFF8A3D),
            ),
          ],
        ),
        const SizedBox(height: 28),
        _buildDemoAccountsPanel(context),
      ],
    );
  }
}
// endregion

// region Componentes Página Autenticación: panel de cuentas demo
extension on _AuthPageState {
  Widget _buildDemoAccountsPanel(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Cuentas demo', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Cada rol tiene acceso a una vista privada distinta.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ..._repository.demoUsers.map(
              (user) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F9FC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFD9E1EC)),
                  ),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: <Widget>[
                      Chip(
                        label: Text(user.role.label),
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: Color(0xFFD9E1EC)),
                      ),
                      SelectableText(user.email),
                      SelectableText(user.password),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// endregion

// region Componentes Página Autenticación: panel de formulario
extension on _AuthPageState {
  Widget _buildFormPanel(BuildContext context) {
    final theme = Theme.of(context);

    if (_mode == AuthMode.register) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 30, 28, 34),
          child: RegisterForm(
            formKey: _registerFormKey,
            nameController: _registerNameController,
            emailController: _registerEmailController,
            passwordController: _registerPasswordController,
            onSubmit: _handleRegister,
            onSwitchToLogin: () {
              setState(() {
                _mode = AuthMode.login;
              });
            },
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              _mode == AuthMode.login ? 'Iniciar sesion' : 'Crear cuenta',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              _mode == AuthMode.login
                  ? 'Usa cualquiera de las cuentas demo o una cuenta registrada en esta sesion.'
                  : 'El registro crea una cuenta nueva con rol cliente.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            SegmentedButton<AuthMode>(
              segments: const <ButtonSegment<AuthMode>>[
                ButtonSegment<AuthMode>(
                  value: AuthMode.login,
                  icon: Icon(Icons.login),
                  label: Text('Entrar'),
                ),
                ButtonSegment<AuthMode>(
                  value: AuthMode.register,
                  icon: Icon(Icons.person_add_alt_1),
                  label: Text('Registro'),
                ),
              ],
              selected: <AuthMode>{_mode},
              onSelectionChanged: (selection) {
                setState(() {
                  _mode = selection.first;
                });
              },
            ),
            const SizedBox(height: 24),
            if (_mode == AuthMode.login)
              LoginForm(
                formKey: _loginFormKey,
                emailController: _loginEmailController,
                passwordController: _loginPasswordController,
                onSubmit: _handleLogin,
              )
            else
              const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
// endregion

// region Componentes Página Autenticación: componente auxiliar de métricas
class _InfoMetric extends StatelessWidget {
  const _InfoMetric({
    required this.title,
    required this.subtitle,
    required this.color,
  });

  final String title;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD9E1EC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 6),
          Text(subtitle, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}
// endregion
