// region Componentes Página Autenticación: formulario de inicio de sesión
import 'package:flutter/material.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.onSubmit,
    super.key,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.alternate_email),
            ),
            validator: _validateEmail,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Contraseña',
              prefixIcon: Icon(Icons.lock_outline),
            ),
            validator: _validatePassword,
            onFieldSubmitted: (_) => onSubmit(),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onSubmit,
              icon: const Icon(Icons.login),
              label: const Text('Iniciar sesion'),
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
