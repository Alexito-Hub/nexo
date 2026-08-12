import 'package:flutter_test/flutter_test.dart';
import 'package:nexo/domain/course_status.dart';
import 'package:nexo/domain/models.dart';
import 'package:nexo/domain/unified_models.dart';

ReportCardCourse curso(
  String name, {
  required String state,
  String average = '',
}) => ReportCardCourse(
  enrollmentSubjectId: name,
  plan: '2020',
  code: '000',
  name: name,
  section: 'B1',
  rawAttendance: '90',
  rawAverage: average,
  state: state,
);

ScheduleClass clase(
  String subject, {
  int weekday = 1,
  String start = '08:00',
}) => ScheduleClass(
  id: '$subject-$start',
  nrc: '',
  subject: subject,
  modality: '',
  section: 'B1',
  level: '',
  campus: '',
  building: '',
  room: '',
  note: '',
  teacher: '',
  weekday: weekday,
  dayName: '',
  startTime: start,
  endTime: '09:30',
  typeCode: 'T',
);

void main() {
  group('cursos que terminan antes que el ciclo', () {
    test('un taller cerrado se distingue de los que siguen', () {
      // Caso real: a mitad de ciclo cierra el Taller V y el resto sigue.
      final boleta = [
        curso('TALLER V: DESARROLLO DE APPS I', state: 'Apr.', average: '16'),
        curso('PROGRAMACIÓN II', state: 'Dsp.', average: '13'),
      ];

      expect(boleta[0].isFinished, isTrue);
      expect(boleta[1].isFinished, isFalse);
      expect(finishedSubjects(boleta), {'TALLER V: DESARROLLO DE APPS I'});
    });

    test('sin nota todavía no se da por terminado', () {
      // Al empezar el periodo hay cursos sin estado y sin nota: darlos por
      // cerrados apagaría sus avisos el primer día de clases.
      expect(curso('ÁLGEBRA', state: '').isFinished, isFalse);
      expect(curso('ÁLGEBRA', state: 'Apr.').isFinished, isFalse);
      expect(finishedSubjects(null), isEmpty);
    });

    test('compara nombres pese a tildes y espacios de más', () {
      expect(normalizeSubject('  Programación   II '), 'PROGRAMACION II');
      expect(normalizeSubject('FÍSICA GENERAL'), 'FISICA GENERAL');
      expect(normalizeSubject('DISEÑO'), 'DISENO');
    });
  });

  group('recordatorios de clase', () {
    test('no recuerda las clases de un taller que ya cerró', () {
      final grupos = remindableGroups(
        classes: [
          clase('TALLER V: DESARROLLO DE APPS I'),
          clase('PROGRAMACIÓN II', start: '10:00'),
        ],
        weekday: 1,
        finished: {'TALLER V: DESARROLLO DE APPS I'},
      );

      expect(grupos.map((g) => g.subject), ['PROGRAMACIÓN II']);
    });

    test('ante la duda avisa: si el nombre no calza, no lo descarta', () {
      // Un aviso de más molesta; uno de menos te hace faltar a clase.
      final grupos = remindableGroups(
        classes: [clase('TALLER V - DESARROLLO DE APPS')],
        weekday: 1,
        finished: {'TALLER V: DESARROLLO DE APPS I'},
      );

      expect(grupos, hasLength(1));
    });

    test('sigue agrupando teoría y práctica en un solo aviso', () {
      final grupos = remindableGroups(
        classes: [
          clase('FÍSICA GENERAL', start: '09:15'),
          clase('FÍSICA GENERAL', start: '10:00'),
        ],
        weekday: 1,
      );

      expect(grupos, hasLength(1));
      expect(grupos.single.startTime, '09:15');
    });

    test('solo mira el día pedido', () {
      final grupos = remindableGroups(
        classes: [clase('ÁLGEBRA', weekday: 1), clase('FILOSOFÍA', weekday: 3)],
        weekday: 3,
      );

      expect(grupos.map((g) => g.subject), ['FILOSOFÍA']);
    });
  });
}
