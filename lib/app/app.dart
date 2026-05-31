// #region Aplicacion | Vista | Configuracion base de MaterialApp
import 'package:flutter/material.dart';

import '../core/data/theme_preferences.dart';
import '../core/theme/app_theme.dart';
import '../features/auth/presentation/pages/auth_page.dart';

class InstaTicketApp extends StatefulWidget {
  const InstaTicketApp({super.key});

  @override
  State<InstaTicketApp> createState() => _InstaTicketAppState();
}

class _InstaTicketAppState extends State<InstaTicketApp> {
  final ThemePreferences _themePrefs = ThemePreferences.instance;

  @override
  void initState() {
    super.initState();
    _themePrefs.load();
    _themePrefs.notifier.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    _themePrefs.notifier.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'InstaTicket',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.buildLight(),
      darkTheme: AppTheme.buildDark(),
      themeMode: _themePrefs.notifier.value,
      home: const AuthPage(),
    );
  }
}
// #endregion
