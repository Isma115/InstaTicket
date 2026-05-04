// region Componentes Aplicación: configuración base de MaterialApp
import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../features/auth/presentation/pages/auth_page.dart';

class InstaTicketApp extends StatelessWidget {
  const InstaTicketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'InstaTicket',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(),
      home: const AuthPage(),
    );
  }
}
// endregion
