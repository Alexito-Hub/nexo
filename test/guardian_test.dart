import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexo/data/backend_client.dart';
import 'package:nexo/features/guardian/guardian_access_screen.dart';
import 'package:nexo/l10n/app_localizations.dart';

/// Backend de mentira para la puerta de apoderados.
class _StubClient extends BackendClient {
  _StubClient({this.roster = const [], this.error});
  final List<StudentSummary> roster;
  final BackendException? error;
  int logins = 0;
  String? lastDni;
  String? lastPin;

  @override
  Future<List<StudentSummary>> guardianLogin({
    required String dni,
    required String pin,
  }) async {
    logins++;
    lastDni = dni;
    lastPin = pin;
    if (error != null) throw error!;
    return roster;
  }
}

Widget _app(Widget home) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  locale: const Locale('es'),
  home: home,
);

Future<void> _fill(WidgetTester tester, String dni, String pin) async {
  await tester.enterText(find.byType(TextFormField).at(0), dni);
  await tester.enterText(find.byType(TextFormField).at(1), pin);
  await tester.tap(find.text('Entrar'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('no llama al backend con un DNI incompleto', (tester) async {
    final client = _StubClient();
    await tester.pumpWidget(_app(GuardianAccessScreen(client: client)));
    await tester.pumpAndSettle();

    await _fill(tester, '123', '123456');

    expect(client.logins, 0);
    expect(find.text('Ingresa los 8 dígitos de tu DNI'), findsOneWidget);
  });

  testWidgets('un PIN de menos de 6 dígitos tampoco sale', (tester) async {
    final client = _StubClient();
    await tester.pumpWidget(_app(GuardianAccessScreen(client: client)));
    await tester.pumpAndSettle();

    await _fill(tester, '44556677', '12');

    expect(client.logins, 0);
    expect(find.text('El PIN tiene 6 dígitos'), findsOneWidget);
  });

  testWidgets('con DNI y PIN válidos entra y consulta al backend', (
    tester,
  ) async {
    final client = _StubClient(
      roster: const [
        StudentSummary(
          code: 'U02001A',
          firstName: 'Ana Lucia',
          lastName: 'Ramirez Soto',
        ),
        StudentSummary(
          code: 'U02002B',
          firstName: 'Beto',
          lastName: 'Ramirez Soto',
        ),
      ],
    );
    await tester.pumpWidget(_app(GuardianAccessScreen(client: client)));
    await tester.pumpAndSettle();

    await _fill(tester, '44556677', '123456');

    expect(client.logins, 1);
    expect(client.lastDni, '44556677');
    expect(client.lastPin, '123456');

    // Con dos hijos se pregunta a quién quiere ver.
    expect(find.text('¿A quién quieres ver?'), findsOneWidget);
    expect(find.text('Ramirez Soto, Ana Lucia'), findsOneWidget);
  });

  testWidgets('el bloqueo por intentos se explica, no se disfraza', (
    tester,
  ) async {
    final client = _StubClient(
      error: const BackendException('acceso_bloqueado'),
    );
    await tester.pumpWidget(_app(GuardianAccessScreen(client: client)));
    await tester.pumpAndSettle();

    await _fill(tester, '44556677', '999999');

    expect(find.textContaining('Demasiados intentos'), findsOneWidget);
  });

  testWidgets('un PIN incorrecto no revela si el DNI existe', (tester) async {
    final client = _StubClient(
      error: const BackendException('credenciales_invalidas'),
    );
    await tester.pumpWidget(_app(GuardianAccessScreen(client: client)));
    await tester.pumpAndSettle();

    await _fill(tester, '44556677', '999999');

    expect(find.textContaining('DNI o PIN incorrectos'), findsOneWidget);
  });
}
