import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexo/domain/models.dart';
import 'package:nexo/domain/passing_rule.dart';
import 'package:nexo/features/grades/projection_card.dart';
import 'package:nexo/l10n/app_localizations.dart';

UnitGrades unit(String name, {required double weight, double? average}) =>
    UnitGrades(
      name: name,
      rawWeight: '$weight',
      evidences: const [],
      rawAverage: average == null ? '' : '$average',
    );

CourseGradeDetail detail(List<UnitGrades> units) => CourseGradeDetail(
  units: units,
  rawSubstitute: '',
  rawFinalAverage: '',
  state: '',
);

/// Tres unidades rendidas con [nota] y dos por rendir, todas al 20 %.
CourseGradeDetail conNota(double nota) => detail([
  unit('UNIDAD 1', weight: 20, average: nota),
  unit('UNIDAD 2', weight: 20, average: nota),
  unit('UNIDAD 3', weight: 20, average: nota),
  unit('UNIDAD 4', weight: 20),
  unit('INTEGRAL', weight: 20),
]);

Future<void> pump(WidgetTester tester, CourseGradeDetail d) async {
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('es'),
      home: Scaffold(
        body: SingleChildScrollView(child: ProjectionCard(detail: d)),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    PassingRule.stricterConfirmed = false;
    PassingRule.current = PassingRule.standard;
  });

  testWidgets('dice la nota que falta y con qué mínimo la calcula', (
    tester,
  ) async {
    await pump(tester, conNota(10));

    expect(find.text('¿Cuánto necesitas?'), findsOneWidget);
    expect(find.text('Para aprobar con 11'), findsOneWidget);
    // Asumiendo 11 en la unidad 4: (10.5·100 − 600 − 220) / 20 = 11.5 → 12.
    expect(find.text('12'), findsOneWidget);
  });

  testWidgets('mover el deslizador cambia lo que hace falta después', (
    tester,
  ) async {
    await pump(tester, conNota(10));
    expect(find.byType(Slider), findsOneWidget);

    // Subir la nota supuesta de la unidad 4 baja la exigencia de la integral.
    await tester.drag(find.byType(Slider), const Offset(500, 0));
    await tester.pumpAndSettle();

    expect(find.text('Si en UNIDAD 4 sacas 20:'), findsOneWidget);
    // (10.5·100 − 600 − 400) / 20 = 2.5 → 3.
    expect(find.text('3'), findsOneWidget);
  });

  testWidgets('cuando ya está asegurado no pide ninguna nota', (tester) async {
    await pump(tester, conNota(20));

    expect(find.textContaining('Ya está aprobado'), findsOneWidget);
    expect(find.byType(Slider), findsNothing);
  });

  testWidgets('cuando ya no alcanza lo dice sin inventar un número', (
    tester,
  ) async {
    await pump(tester, conNota(2));

    expect(find.textContaining('Ni con 20'), findsOneWidget);
  });

  testWidgets('un curso cerrado no muestra la tarjeta', (tester) async {
    await pump(
      tester,
      detail([
        unit('UNIDAD 1', weight: 50, average: 14),
        unit('UNIDAD 2', weight: 50, average: 16),
      ]),
    );

    expect(find.text('¿Cuánto necesitas?'), findsNothing);
  });

  testWidgets('sigue la regla de la cohorte, no un 11 fijo', (tester) async {
    PassingRule.current = PassingRule.stricter;
    await pump(tester, conNota(10));

    expect(find.text('Para aprobar con 13'), findsOneWidget);
  });
}
