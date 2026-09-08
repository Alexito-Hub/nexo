import 'package:nexo/domain/models.dart';
import 'package:nexo/domain/unified_models.dart';
import 'package:nexo/domain/passing_rule.dart';

class GradeCalculator {
  GradeCalculator._();

  /// Umbral vigente. Ya no es constante: depende de la cohorte del
  /// estudiante (ver [PassingRule]).
  static double get notaAprobatoria => PassingRule.current.threshold;
  static double? promedioPonderado(Iterable<(double?, double)> notas) {
    double sumaPonderada = 0;
    double sumaCreditos = 0;
    for (final (grade, credit) in notas) {
      if (grade == null || credit <= 0) continue;
      sumaPonderada += grade * credit;
      sumaCreditos += credit;
    }
    if (sumaCreditos == 0) return null;
    return sumaPonderada / sumaCreditos;
  }

  static double? promedioPonderadoBoleta(
    List<ReportCardCourse> courses, {
    double? Function(ReportCardCourse)? gradeOf,
  }) {
    // La boleta actual asume que todos sus cursos pertenecen al ciclo solicitado,
    // pero por si acaso, solo sumamos los que tengan nota válida.
    return promedioPonderado(
      courses.map((c) => ((gradeOf ?? (c) => c.average)(c), c.credit)),
    );
  }

  static double? promedioPonderadoLegacy(
    List<CourseGrade> courses, {
    int? activeYear,
    int? activeNumber,
  }) {
    return promedioPonderado(
      courses.where((c) {
        if (activeYear != null && activeNumber != null) {
          return c.year == activeYear && c.periodNum == activeNumber;
        }
        return true;
      }).map((c) => (c.currentGradeNum, c.credit)),
    );
  }

  /// Promedio acumulado de respaldo usando un **promedio simple** de todos los
  /// promedios de ciclo. Matemáticamente esto no pondera por créditos, así
  /// que solo se usa como último recurso cuando falla la carga del resumen oficial.
  static double? promedioAcumulado(
    List<TermAverage> periodos, {
    int? activeYear,
    int? activeNumber,
  }) {
    final cerrados = periodos.where((p) {
      if (p.average == 0) return false;
      final esActivo =
          activeYear != null &&
          activeNumber != null &&
          p.year == activeYear &&
          p.number == activeNumber;
      return !esActivo;
    }).toList();
    if (cerrados.isEmpty) return null;
    final suma = cerrados.fold<double>(0, (a, b) => a + b.average);
    return suma / cerrados.length;
  }
}
