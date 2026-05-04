// region Componentes Página Autenticación: formulario de registro
import 'package:flutter/material.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.onSubmit,
    required this.onSwitchToLogin,
    super.key,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onSubmit;
  final VoidCallback onSwitchToLogin;

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptedTerms = false;
  bool _attemptedSubmit = false;

  @override
  void dispose() {
    _confirmPasswordController.dispose();
    super.dispose();
  }

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
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  const Icon(
                    Icons.person,
                    size: 62,
                    color: Color(0xFF3B82F6),
                  ),
                  Positioned(
                    right: 18,
                    bottom: 18,
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2F7DF6),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: const Icon(
                        Icons.add,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Align(
            child: Text(
              'Crear cuenta',
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
              'Completa los datos para\ncrear tu cuenta.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.55,
                color: const Color(0xFF7A8496),
              ),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'Nombre completo',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: const Color(0xFF30436A),
            ),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: widget.nameController,
            decoration: _buildDecoration(
              hintText: 'Ingresa tu nombre completo',
              prefixIcon: Icons.person_outline,
            ),
            validator: _validateName,
          ),
          const SizedBox(height: 20),
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
            decoration: _buildDecoration(
              hintText: 'Crea una contraseña',
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
          ),
          const SizedBox(height: 20),
          Text(
            'Confirmar contraseña',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: const Color(0xFF30436A),
            ),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            decoration: _buildDecoration(
              hintText: 'Confirma tu contraseña',
              prefixIcon: Icons.lock_outline,
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
            ),
            validator: (value) => _validateConfirmPassword(
              value,
              widget.passwordController.text,
            ),
            onFieldSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Checkbox(
                value: _acceptedTerms,
                onChanged: (value) {
                  setState(() {
                    _acceptedTerms = value ?? false;
                  });
                },
                side: const BorderSide(color: Color(0xFFBDC6D5)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF5E6573),
                        height: 1.45,
                      ),
                      children: <InlineSpan>[
                        TextSpan(text: 'Acepto los '),
                        TextSpan(
                          text: 'términos y condiciones',
                          style: TextStyle(
                            color: Color(0xFF2F7DF6),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(text: ' y la '),
                        TextSpan(
                          text: 'política de privacidad',
                          style: TextStyle(
                            color: Color(0xFF2F7DF6),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_attemptedSubmit && !_acceptedTerms)
            const Padding(
              padding: EdgeInsets.only(top: 4, left: 4),
              child: Text(
                'Debes aceptar los términos para continuar.',
                style: TextStyle(
                  color: Color(0xFFB3261E),
                  fontSize: 12,
                ),
              ),
            ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _submit,
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
              child: const Text('Registrarse'),
            ),
          ),
          const SizedBox(height: 26),
          Center(
            child: Wrap(
              spacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                Text(
                  '¿Ya tienes cuenta?',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFF30436A),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: widget.onSwitchToLogin,
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF2F7DF6),
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Inicia sesión',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _submit() {
    setState(() {
      _attemptedSubmit = true;
    });

    final isValid = widget.formKey.currentState?.validate() ?? false;

    if (!isValid) {
      return;
    }

    if (!_acceptedTerms) {
      setState(() {});
      return;
    }

    widget.onSubmit();
  }
}
// endregion

// region Lógica Página Autenticación: validaciones de registro
String? _validateName(String? value) {
  final text = value?.trim() ?? '';

  if (text.isEmpty) {
    return 'Introduce tu nombre.';
  }

  if (text.length < 3) {
    return 'El nombre debe tener al menos 3 caracteres.';
  }

  return null;
}

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

String? _validateConfirmPassword(String? value, String password) {
  final text = value ?? '';

  if (text.isEmpty) {
    return 'Confirma tu contraseña.';
  }

  if (text != password) {
    return 'Las contraseñas no coinciden.';
  }

  return null;
}
// endregion
