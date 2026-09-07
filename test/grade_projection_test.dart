import 'package:flutter_test/flutter_test.dart';
import 'package:nexo/domain/grade_projection.dart';
import 'package:nexo/domain/models.dart';
import 'package:nexo/domain/passing_rule.dart';
import 'package:nexo/domain/unified_models.dart';

UnitGrades unit(String name, {required double weight, double? average}) =>
    UnitGrades(
      name: name,
      rawWeight: '$weight',
      evidences: const [],
      rawAverage: average == null ? '' : '$average',
    );

CourseGradeDetail course(List<UnitGrades> units) => CourseGradeDetail(
  units: units,
  rawSubstitute: '',
  rawFinalAverage: '',
  state: '',
);

Term term(int year, int number) => Term(
  id: '$year$number',
  label: '$year-$number',
  year: year,
  number: number,
  isActive: false,
);

void main() {
  setUp(() {
    PassingRule.stricterConfirmed = false;
    PassingRule.current = PassingRule.standard;
  });

  group('regla de aprobación', () {
    test('por defecto aprueba con 11, y el 10.5 redondea a favor', () {
      const r = PassingRule.standard;
      expect(r.minimumGrade, 11);
      expect(r.threshold, 10.5);
      expect(r.passes(10.5), isTrue);
      expect(r.passes(10.49), isFalse);
      expect(r.passes(null), isFalse);
    });

    test('la regla estricta sube el umbral a 12.5', () {
      expect(PassingRule.stricter.minimumGrade, 13);
      expect(PassingRule.stricter.threshold, 12.5);
      expect(PassingRule.stricter.passes(12), isFalse);
      expect(PassingRule.stricter.passes(13), isTrue);
    });

    test('mientras no se confirme, nadie se ve afectado', () {
      // Un ingresante de 2026-1: con la regla sin confirmar sigue con 11.
      expect(PassingRule.forEntry(year: 2026, term: 1), PassingRule.standard);
    });

    test('confirmada, solo alcanza a quien ingresó desde 2026-1', () {
      PassingRule.stricterConfirmed = true;

      expect(PassingRule.forEntry(year: 2026, term: 1), PassingRule.stricter);
      expect(PassingRule.forEntry(year: 2026, term: 2), PassingRule.stricter);
      expect(PassingRule.forEntry(year: 2025, term: 2), PassingRule.standard);
      expect(
        PassingRule.forEntry(year: null, term: null),
        PassingRule.standard,
      );
    });

    test('la cohorte es el periodo más antiguo, no el actual', () {
      PassingRule.stricterConfirmed = true;

      // Estudiante que empezó en 2024 y hoy cursa 2026-1: regla vieja.
      final veterano = [term(2026, 1), term(2024, 2), term(2025, 1)];
      expect(PassingRule.forTerms(veterano), PassingRule.standard);

      // Ingresante de 2026-1: regla nueva.
      expect(PassingRule.forTerms([term(2026, 1)]), PassingRule.stricter);
      expect(PassingRule.forTerms([]), PassingRule.standard);
      expect(PassingRule.forTerms(null), PassingRule.standard);
    });
  });

  group('proyección de notas', () {
    // Cuatro unidades de 20 % y una integral de 20 %.
    CourseGradeDetail conTresRendidas(double u1, double u2, double u3) =>
        course([
          unit('UNIDAD 1', weight: 20, average: u1),
          unit('UNIDAD 2', weight: 20, average: u2),
          unit('UNIDAD 3', weight: 20, average: u3),
          unit('UNIDAD 4', weight: 20),
          unit('INTEGRAL', weight: 20),
        ]);

    test('dice cuánto hace falta en cada unidad que queda', () {
      final p = GradeProjection.of(conTresRendidas(10, 10, 10));

      // (10.5·100 − 30·10) / 40 = 11.25
      expect(p.requiredUniform(10.5), closeTo(11.25, 0.001));
      expect(GradeProjection.practical(p.requiredUniform(10.5)), 12);
      expect(p.statusFor(10.5), ProjectionStatus.alcanzable);
    });

    test('el promedio actual solo cuenta lo rendido', () {
      final p = GradeProjection.of(conTresRendidas(12, 14, 16));
      expect(p.currentAverage, closeTo(14, 0.001));
      expect(p.pendingWeight, 40);
    });

    test('si ya está asegurado, lo dice en vez de pedir una nota', () {
      final p = GradeProjection.of(conTresRendidas(20, 20, 20));
      // Con 60 puntos de 100 ya supera el 10.5 pase lo que pase.
      expect(p.requiredUniform(10.5)! <= 0, isTrue);
      expect(p.statusFor(10.5), ProjectionStatus.yaAprobado);
    });

    test('cuando ya no alcanza, no inventa un número posible', () {
      final p = GradeProjection.of(conTresRendidas(2, 2, 2));
      // (10.5·100 − 12) / 40 = 25.75 → imposible
      expect(p.requiredUniform(10.5)!, greaterThan(20));
      expect(p.statusFor(10.5), ProjectionStatus.imposible);
    });

    test('responde a «si saco X en la unidad 4, cuánto en la integral»', () {
      final p = GradeProjection.of(conTresRendidas(10, 10, 10));

      // Lo rendido suma 10·20·3 = 600 de un total de 100 de peso.
      // Con 15 en la unidad 4: (10.5·100 − 600 − 300) / 20 = 7.5.
      expect(p.requiredAssuming({'UNIDAD 4': 15}, 10.5), closeTo(7.5, 0.001));
      // Subir la unidad 4 baja lo que hace falta en la integral.
      expect(p.requiredAssuming({'UNIDAD 4': 20}, 10.5), closeTo(2.5, 0.001));
    });

    test('sigue el umbral de la cohorte, no un 11 fijo', () {
      // Con 18 en las tres primeras ya no puede bajar del 10.5 pase lo que
      // pase: 18·60 = 1080, y el aprobado exige 1050 de 100 de peso.
      final detalle = conTresRendidas(18, 18, 18);
      final p = GradeProjection.of(detalle);

      PassingRule.current = PassingRule.standard;
      expect(detalle.passingStatus, ProjectionStatus.yaAprobado);

      // Con 13 de mínimo esas mismas notas ya no aseguran nada: hace falta
      // (12.5·100 − 1080) / 40 = 4.25 en lo que queda.
      PassingRule.current = PassingRule.stricter;
      expect(
        p.requiredUniform(PassingRule.stricter.threshold),
        closeTo(4.25, 0.001),
      );
      expect(detalle.passingStatus, ProjectionStatus.alcanzable);
    });

    test('sin pesos reparte por igual en vez de rendirse', () {
      final detalle = course([
        unit('UNIDAD 1', weight: 0, average: 8),
        unit('UNIDAD 2', weight: 0, average: 12),
        unit('UNIDAD 3', weight: 0),
      ]);
      final p = GradeProjection.of(detalle);

      expect(p.weightsAreReal, isFalse);
      expect(p.currentAverage, closeTo(10, 0.001));
      // (10.5·3 − 20) / 1 = 11.5
      expect(p.requiredUniform(10.5), closeTo(11.5, 0.001));
    });

    test('un curso cerrado no proyecta nada', () {
      final detalle = course([
        unit('UNIDAD 1', weight: 50, average: 14),
        unit('UNIDAD 2', weight: 50, average: 16),
      ]);
      final p = GradeProjection.of(detalle);

      expect(p.hasPending, isFalse);
      expect(p.requiredUniform(10.5), isNull);
      expect(p.statusFor(10.5), ProjectionStatus.cerrado);
    });

    test('sin ninguna nota todavía no se proyecta', () {
      final detalle = course([
        unit('UNIDAD 1', weight: 50),
        unit('UNIDAD 2', weight: 50),
      ]);
      expect(
        GradeProjection.of(detalle).statusFor(10.5),
        ProjectionStatus.sinDatos,
      );
      expect(
        GradeProjection.of(course([])).statusFor(10.5),
        ProjectionStatus.sinDatos,
      );
    });

    test('la nota práctica redondea hacia arriba y no pasa de 20', () {
      expect(GradeProjection.practical(12.3), 13);
      expect(GradeProjection.practical(12.0), 12);
      expect(GradeProjection.practical(25), 20);
      expect(GradeProjection.practical(null), isNull);
    });
  });
}
