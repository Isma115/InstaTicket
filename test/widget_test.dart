// region Componentes Aplicación: prueba base de renderizado
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:instaticket_frontend/app/app.dart';

void main() {
  testWidgets('renders auth screen', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    await tester.pumpWidget(const InstaTicketApp());
    await tester.pumpAndSettle();

    expect(find.text('Iniciar sesión'), findsOneWidget);
    expect(
        find.widgetWithText(FilledButton, 'Entrar al panel'), findsOneWidget);
    expect(find.text('Crear cuenta'), findsNothing);
    expect(find.text('Cuentas demo'), findsNothing);
  });
}
// endregion
