// region Componentes Página Autenticación: formulario de inicio de sesión
import 'package:flutter/material.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.onSubmit,
    this.isSubmitting = false,
    super.key,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onSubmit;
  final bool isSubmitting;

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  bool _obscurePassword = true;

  InputDecoration _buildDecoration({
    required String hintText,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return InputDecoration(
      hintText: hintText,
      prefixIcon: Icon(prefixIcon),
      suffixIcon: suffixIcon,
      hintStyle: TextStyle(
        color: colorScheme.onSurfaceVariant.withOpacity(0.72),
        fontSize: 16,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 20,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Align(
            child: Container(
              width: 122,
              height: 122,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.primaryContainer.withOpacity(
                  isDark ? 0.52 : 0.78,
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: colorScheme.primary.withOpacity(
                      isDark ? 0.28 : 0.12,
                    ),
                    blurRadius: 22,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(
                Icons.verified_user_outlined,
                size: 58,
                color: colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Align(
            child: Text(
              'Iniciar sesión',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Align(
            child: Text(
              'Accede con tu cuenta para\nentrar al panel principal.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.55,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'Correo electrónico',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: widget.emailController,
            keyboardType: TextInputType.emailAddress,
            enabled: !widget.isSubmitting,
            decoration: _buildDecoration(
              hintText: 'ejemplo@empresa.com',
              prefixIcon: Icons.alternate_email_rounded,
            ),
            validator: _validateEmail,
          ),
          const SizedBox(height: 20),
          Text(
            'Contraseña',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: widget.passwordController,
            obscureText: _obscurePassword,
            enabled: !widget.isSubmitting,
            decoration: _buildDecoration(
              hintText: 'Introduce tu contraseña',
              prefixIcon: Icons.password_rounded,
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
            ),
            validator: _validatePassword,
            onFieldSubmitted: (_) => widget.onSubmit(),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: widget.isSubmitting ? null : widget.onSubmit,
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: widget.isSubmitting
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: colorScheme.onPrimary,
                      ),
                    )
                  : const Text('Entrar al panel'),
            ),
          ),
        ],
      ),
    );
  }
}
// endregion

// region Lógica Página Autenticación: validaciones de inicio de sesión
String? _validateEmail(String? value) {
  final text = value?.trim() ?? '';

  if (text.isEmpty) {
    return 'Introduce un email.';
  }

  if (!text.contains('@')) {
    return 'Introduce un email valido.';
  }

  return null;
}

String? _validatePassword(String? value) {
  final text = value ?? '';

  if (text.isEmpty) {
    return 'Introduce una contraseña.';
  }

  return null;
}
// endregion
