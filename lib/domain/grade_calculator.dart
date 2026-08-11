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
  }) => promedioPonderado(
    courses.map((c) => ((gradeOf ?? (c) => c.average)(c), c.credit)),
  );

  static double? promedioPonderadoLegacy(List<CourseGrade> courses) =>
      promedioPonderado(courses.map((c) => (c.currentGradeNum, c.credit)));

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
