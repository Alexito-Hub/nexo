import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexo/core/config.dart';
import 'package:nexo/core/storage.dart';
import 'package:nexo/features/legal/terms_screen.dart';
import 'package:nexo/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _app(Widget home) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  locale: const Locale('es'),
  home: home,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('aceptación versionada', () {
    test('quien aceptó la versión vieja tiene que volver a aceptar', () async {
      // Antes solo existía el booleano.
      SharedPreferences.setMockInitialValues({'nexo.acceptedTerms': true});
      final storage = await AppStorage.init();

      expect(storage.acceptedTermsVersion, 1);
      expect(storage.acceptedTerms, isFalse);
    });

    test('aceptar guarda la versión actual', () async {
      SharedPreferences.setMockInitialValues({});
      final storage = await AppStorage.init();

      expect(storage.acceptedTerms, isFalse);
      await storage.setAcceptedTerms(true);

      expect(storage.acceptedTermsVersion, LegalTerms.version);
      expect(storage.acceptedTerms, isTrue);
    });
  });

  testWidgets('los términos cubren Microsoft, el dispositivo y los cambios', (
    tester,
  ) async {
    await tester.pumpWidget(_app(const TermsScreen()));
    await tester.pumpAndSettle();

    // La lista es larga: hay que bajar hasta cada bloque para comprobarlo.
    for (final title in [
      'Cuenta de Microsoft',
      'Lo que queda en tu dispositivo',
      'Cambios en estos términos',
      'Versión ${LegalTerms.version}',
    ]) {
      await tester.scrollUntilVisible(
        find.textContaining(title),
        250,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.textContaining(title), findsOneWidget);
    }
  });

  testWidgets('no prometen nada sobre servidores propios ni datos ajenos', (
    tester,
  ) async {
    // La app volvió a no hablar con ningún servidor de Nexo: los términos no
    // deben describir un apartado que ya no existe.
    await tester.pumpWidget(_app(const TermsScreen()));
    await tester.pumpAndSettle();

    for (final gone in [
      'El apartado Estudiantes',
      'Datos de otras personas',
      'Datos de demostración',
      'servidor de Nexo',
    ]) {
      expect(find.textContaining(gone), findsNothing, reason: gone);
    }
  });

  testWidgets('a quien ya aceptó se le avisa de que cambiaron', (tester) async {
    await tester.pumpWidget(_app(TermsScreen(isUpdate: true, onAccept: () {})));
    await tester.pumpAndSettle();

    expect(find.text('Cambiamos algo'), findsOneWidget);
    expect(find.textContaining('Actualizamos estos términos'), findsOneWidget);
  });
}
