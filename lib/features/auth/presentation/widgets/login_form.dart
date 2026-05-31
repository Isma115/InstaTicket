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
    return InputDecoration(
      hintText: hintText,
      prefixIcon: Icon(prefixIcon),
      suffixIcon: suffixIcon,
      hintStyle: const TextStyle(
        color: Color(0xFFB0B7C3),
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
                color: const Color(0xFFEFF4FF),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: const Color(0xFF2457F5).withOpacity(0.08),
                    blurRadius: 22,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.lock_person_outlined,
                size: 58,
                color: Color(0xFF2F7DF6),
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
                color: const Color(0xFF102A63),
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
                color: const Color(0xFF7A8496),
              ),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'Correo electrónico',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: const Color(0xFF30436A),
            ),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: widget.emailController,
            keyboardType: TextInputType.emailAddress,
            enabled: !widget.isSubmitting,
            decoration: _buildDecoration(
              hintText: 'ejemplo@empresa.com',
              prefixIcon: Icons.mail_outline,
            ),
            validator: _validateEmail,
          ),
          const SizedBox(height: 20),
          Text(
            'Contraseña',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: const Color(0xFF30436A),
            ),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: widget.passwordController,
            obscureText: _obscurePassword,
            enabled: !widget.isSubmitting,
            decoration: _buildDecoration(
              hintText: 'Introduce tu contraseña',
              prefixIcon: Icons.lock_outline,
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
                backgroundColor: const Color(0xFF2F7DF6),
                foregroundColor: Colors.white,
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
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: Colors.white,
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

  if (text.length < 6) {
    return 'La contraseña debe tener al menos 6 caracteres.';
  }

  return null;
}
// endregion
