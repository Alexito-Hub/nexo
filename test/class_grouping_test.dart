import 'package:flutter_test/flutter_test.dart';
import 'package:nexo/domain/unified_models.dart';

ScheduleClass session(
  String subject, {
  required int weekday,
  required String start,
  required String end,
  String type = 'T',
}) => ScheduleClass(
  id: '$subject-$weekday-$start',
  subject: subject,
  weekday: weekday,
  dayName: '',
  startTime: start,
  endTime: end,
  typeCode: type,
  section: 'A1',
  room: 'I 302',
  building: '',
  campus: '',
  teacher: '',
  nrc: '',
  level: '',
  modality: '',
  note: '',
);

void main() {
  group('agrupación de clases (regresión: doble notificación)', () {
    test('teoría y práctica del mismo día son un solo bloque', () {
      // Es el caso real del horario: FÍSICA GENERAL de 9:15 a 10:00 (teoría)
      // y de 10:00 a 11:30 (práctica). Antes se programaba un aviso por cada
      // una y llegaban dos notificaciones casi seguidas del mismo curso.
      final grupos = ScheduleClassGroup.groupBy([
        session('FÍSICA GENERAL', weekday: 1, start: '09:15', end: '10:00'),
        session(
          'FÍSICA GENERAL',
          weekday: 1,
          start: '10:00',
          end: '11:30',
          type: 'P',
        ),
      ]);

      expect(grupos, hasLength(1));
      expect(grupos.single.sessions, hasLength(2));
      // El aviso sale a la hora en que empieza el bloque, no de cada sesión.
      expect(grupos.single.startTime, '09:15');
      expect(grupos.single.endTime, '11:30');
    });

    test('la misma asignatura en días distintos sí son bloques distintos', () {
      final grupos = ScheduleClassGroup.groupBy([
        session('ÁLGEBRA', weekday: 1, start: '08:00', end: '09:30'),
        session('ÁLGEBRA', weekday: 3, start: '08:00', end: '09:30'),
      ]);

      expect(grupos, hasLength(2));
    });

    test('asignaturas distintas a la misma hora no se mezclan', () {
      final grupos = ScheduleClassGroup.groupBy([
        session('ÁLGEBRA', weekday: 2, start: '08:00', end: '09:30'),
        session('FILOSOFÍA', weekday: 2, start: '08:00', end: '09:30'),
      ]);

      expect(grupos, hasLength(2));
    });

    test('las sesiones quedan ordenadas por hora de inicio', () {
      final grupos = ScheduleClassGroup.groupBy([
        session('TALLER', weekday: 4, start: '15:00', end: '16:30', type: 'P'),
        session('TALLER', weekday: 4, start: '13:00', end: '15:00'),
      ]);

      expect(grupos.single.startTime, '13:00');
      expect(grupos.single.sessions.first.startTime, '13:00');
    });
  });
}
