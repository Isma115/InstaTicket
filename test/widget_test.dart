// region Componentes Aplicación: prueba base de renderizado
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:instaticket_frontend/app/app.dart';

void main() {
  testWidgets('renders auth screen', (tester) async {
    await tester.pumpWidget(const InstaTicketApp());

    expect(find.text('InstaTicket'), findsOneWidget);
    expect(
      find.widgetWithText(FilledButton, 'Iniciar sesion'),
      findsOneWidget,
    );
  });
}
// endregion
