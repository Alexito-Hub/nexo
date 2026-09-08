import 'package:nexo/domain/models.dart';
import 'package:nexo/domain/passing_rule.dart';

enum ProjectionStatus {
  /// No hay unidades o no hay ninguna nota todavía: no se puede proyectar.
  sinDatos,

  /// Ya no queda nada por rendir.
  cerrado,

  /// Lo que falta ya no puede bajarte del aprobado.
  yaAprobado,

  /// Se necesita una nota concreta y está dentro de lo posible.
  alcanzable,

  /// Ni con 20 en todo lo que queda se llega.
  imposible,
}

/// Cuánto necesitas sacar en lo que te queda.
///
/// El promedio del curso es la media de las unidades ponderada por su peso
/// (ver `CourseGradeDetail.computedAverage`). Esto es esa misma cuenta al
/// revés: se conoce lo ya obtenido y se despeja la nota que falta.
///
///     promedio = (Σ obtenido·peso + nota·pesoPendiente) / pesoTotal
///     nota     = (objetivo·pesoTotal − Σ obtenido·peso) / pesoPendiente
///
/// Se apoya en los pesos reales cuando todas las unidades los traen. Si a
/// alguna le falta el peso —pasa con datos viejos de la Intranet— cuenta
/// todas por igual, que es lo mismo que hace el promedio mostrado; así la
/// proyección nunca contradice a la nota que el estudiante está viendo.
class GradeProjection {
  const GradeProjection._({
    required this.graded,
    required this.pending,
    required this.obtainedWeighted,
    required this.totalWeight,
    required this.weightsAreReal,
  });

  /// Unidades ya calificadas.
  final List<UnitGrades> graded;

  /// Unidades que faltan por rendir, en el orden en que aparecen.
  final List<UnitGrades> pending;

  /// Σ (nota × peso) de lo ya calificado.
  final double obtainedWeighted;

  /// Σ peso de todas las unidades, calificadas o no.
  final double totalWeight;

  /// `false` cuando hubo que repartir el peso por igual.
  final bool weightsAreReal;

  factory GradeProjection.of(CourseGradeDetail detail) {
    final units = detail.units;
    final todasConPeso = units.every((u) => (u.weight ?? 0) > 0);
    double weightOf(UnitGrades u) => todasConPeso ? u.weight! : 1;

    final graded = <UnitGrades>[];
    final pending = <UnitGrades>[];
    var obtained = 0.0;
    var total = 0.0;

    for (final u in units) {
      final w = weightOf(u);
      total += w;
      final nota = u.average;
      if (nota == null) {
        pending.add(u);
      } else {
        graded.add(u);
        obtained += nota * w;
      }
    }

    return GradeProjection._(
      graded: graded,
      pending: pending,
      obtainedWeighted: obtained,
      totalWeight: total,
      weightsAreReal: todasConPeso,
    );
  }

  double get pendingWeight => totalWeight - gradedWeight;

  double get gradedWeight {
    if (graded.isEmpty) return 0;
    if (!weightsAreReal) return graded.length.toDouble();
    return graded.fold<double>(0, (a, u) => a + (u.weight ?? 0));
  }

  bool get hasPending => pending.isNotEmpty;

  /// Promedio actual contando solo lo rendido, igual que muestra la boleta.
  double? get currentAverage {
    if (graded.isEmpty || gradedWeight <= 0) return null;
    return obtainedWeighted / gradedWeight;
  }

  /// Nota que hay que sacar en **cada una** de las unidades que faltan para
  /// terminar con [target] de promedio. `null` si no hay nada pendiente.
  ///
  /// Puede salir negativa (ya está asegurado) o mayor que 20 (ya no alcanza);
  /// interpretarlo es cosa de [statusFor], que para eso está.
  double? requiredUniform(double target) {
    if (!hasPending || pendingWeight <= 0) return null;
    return (target * totalWeight - obtainedWeighted) / pendingWeight;
  }

  /// Igual, pero dando por hechas algunas notas.
  ///
  /// Sirve para la pregunta de verdad: «si en el reto de la unidad 4 saco 15,
  /// ¿cuánto necesito en la integral?». Las unidades de [assumed] se tratan
  /// como si ya estuvieran puestas y el resultado es lo que hace falta en las
  /// demás. `null` si con eso ya no queda nada pendiente.
  double? requiredAssuming(Map<String, double> assumed, double target) {
    var obtained = obtainedWeighted;
    var restante = 0.0;

    for (final u in pending) {
      final w = weightsAreReal ? (u.weight ?? 0) : 1;
      final supuesta = assumed[u.name];
      if (supuesta != null) {
        obtained += supuesta * w;
      } else {
        restante += w;
      }
    }

    if (restante <= 0) return null;
    return (target * totalWeight - obtained) / restante;
  }

  ProjectionStatus statusFor(double target) {
    if (totalWeight <= 0 || (graded.isEmpty && pending.isEmpty)) {
      return ProjectionStatus.sinDatos;
    }
    if (!hasPending) return ProjectionStatus.cerrado;
    if (graded.isEmpty) return ProjectionStatus.sinDatos;

    final necesaria = requiredUniform(target);
    if (necesaria == null) return ProjectionStatus.sinDatos;
    if (necesaria <= 0) return ProjectionStatus.yaAprobado;
    if (necesaria > 20) return ProjectionStatus.imposible;
    return ProjectionStatus.alcanzable;
  }

  /// Nota práctica: las evidencias se califican en enteros, así que si la
  /// cuenta dice 12.3 hay que sacar 13. Redondear hacia abajo mentiría.
  static int? practical(double? exact) {
    if (exact == null) return null;
    final ceil = exact.ceil();
    return ceil.clamp(0, 20);
  }
}

extension CourseProjection on CourseGradeDetail {
  GradeProjection get projection => GradeProjection.of(this);

  /// Proyección contra la regla de aprobación vigente.
  ProjectionStatus get passingStatus =>
      projection.statusFor(PassingRule.current.threshold);
}
