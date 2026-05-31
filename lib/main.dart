// region Lógica Aplicación: punto de entrada principal
import 'package:flutter/material.dart';

import 'app/app.dart';
import 'core/data/theme_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThemePreferences.instance.load();
  runApp(const InstaTicketApp());
}
// endregion
