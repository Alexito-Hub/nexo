import 'package:nexo/domain/models.dart';
import 'package:nexo/domain/unified_models.dart';

/// Cursos que terminan antes que el ciclo.
///
/// Muchos talleres duran medio semestre: el Taller V cierra a mitad de ciclo y
/// arranca el Taller VI. No hace falta modelar el calendario de cada facultad
/// para detectarlo, porque la boleta ya lo dice curso por curso: mientras un
/// curso está en marcha su estado empieza por `Dsp.`, y al cerrar pasa a
/// `Apr.`/`Des.` aunque el resto del periodo siga abierto.

/// Nombre comparable entre el horario y la boleta: mayúsculas, sin tildes y
/// sin espacios de más. Los dos sistemas escriben el mismo curso con distinta
/// puntuación y acentuación.
String normalizeSubject(String raw) {
  const acentos = {
    'Á': 'A',
    'À': 'A',
    'Ä': 'A',
    'Â': 'A',
    'É': 'E',
    'È': 'E',
    'Ë': 'E',
    'Ê': 'E',
    'Í': 'I',
    'Ì': 'I',
    'Ï': 'I',
    'Î': 'I',
    'Ó': 'O',
    'Ò': 'O',
    'Ö': 'O',
    'Ô': 'O',
    'Ú': 'U',
    'Ù': 'U',
    'Ü': 'U',
    'Û': 'U',
    'Ñ': 'N',
  };
  var s = raw.toUpperCase();
  acentos.forEach((con, sin) => s = s.replaceAll(con, sin));
  return s.replaceAll(RegExp(r'\s+'), ' ').trim();
}

extension CourseCompletion on ReportCardCourse {
  /// El curso ya cerró: la boleta dejó de marcarlo en proceso y tiene nota.
  ///
  /// Se exigen las dos cosas. Al empezar el periodo hay cursos sin estado y
  /// sin nota todavía, y darlos por terminados apagaría sus recordatorios el
  /// primer día de clases.
  bool get isFinished => !inProgress && vigesimalAverage != null;
}

/// Asignaturas del periodo que ya cerraron, listas para comparar con el
/// horario.
Set<String> finishedSubjects(List<ReportCardCourse>? courses) {
  if (courses == null) return const {};
  return courses
      .where((c) => c.isFinished)
      .map((c) => normalizeSubject(c.name))
      .where((n) => n.isNotEmpty)
      .toSet();
}

/// Bloques de clase de un día que todavía merecen recordatorio.
///
/// Ante la duda, avisa. Un aviso de más molesta; uno de menos te hace faltar a
/// clase, así que solo se descarta cuando el nombre coincide exactamente tras
/// normalizar.
List<ScheduleClassGroup> remindableGroups({
  required List<ScheduleClass> classes,
  required int weekday,
  Set<String> finished = const {},
}) {
  final delDia = classes.where((c) => c.weekday == weekday).toList();
  final grupos = ScheduleClassGroup.groupBy(delDia);
  if (finished.isEmpty) return grupos;
  return grupos
      .where((g) => !finished.contains(normalizeSubject(g.subject)))
      .toList();
}
