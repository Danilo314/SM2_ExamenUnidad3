import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sos_mascotas/vista/auth/pantalla_login.dart';
import 'package:sos_mascotas/vistamodelo/auth/login_vm.dart';

void main() {
  testWidgets('PantallaLogin renderiza campos y botón Entrar', (WidgetTester tester) async {
    final vm = LoginVM();

    await tester.pumpWidget(
      ChangeNotifierProvider<LoginVM>.value(
        value: vm,
        child: const MaterialApp(
          home: PantallaLogin(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // ELEMENTOS DE LA PANTALLA
    expect(find.text('Iniciar Sesión'), findsOneWidget);
    expect(find.text('Correo electrónico'), findsOneWidget);
    expect(find.text('Contraseña'), findsOneWidget);

    // Hay dos campos de texto (correo + contraseña)
    expect(find.byType(TextFormField), findsNWidgets(2));

    // Botón con texto "Entrar" (funciona aunque sea ElevatedButton.icon)
    expect(find.text('Entrar'), findsOneWidget);
  });
}
