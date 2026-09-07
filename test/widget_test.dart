import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexo/domain/models.dart';
import 'package:nexo/domain/unified_models.dart';
import 'package:nexo/features/legal/support_screen.dart';
import 'package:nexo/l10n/app_localizations.dart';
import 'package:nexo/shared/util/formatters.dart';

void main() {
  test('Payment.daysUntilDue calcula días correctamente', () {
    final p = Payment.fromSigmaJson({
      'descripcion': 'CUOTA 02',
      'fechaVencimiento': '20-05-2026',
      'tipoMoneda': 'S/.',
      'importe': 522.5,
      'mora': 0,
      'subtotal': 522.5,
      'observacion': '',
    });
    final now = DateTime(2026, 5, 14);
    expect(p.daysUntilDue(now), 6);
  });

  test('ScheduleClass decodifica campos clave', () {
    final c = ScheduleClass.fromSigmaJson({
      'id': '331131',
      'asignatura': 'ANTROPOLOGÍA',
      'idDia': 4,
      'horaInicio': '13:45',
      'horaFin': '15:15',
      'aula': 'I 304',
      'teacher': 'MEZA VARGAS ZENAIDA',
      'idTipo': 'T',
    });
    expect(c.subject, 'ANTROPOLOGÍA');
    expect(c.typeName, 'Teoría');
    expect(c.weekday, 4);
  });

  test('CourseGrade parsea ambos parciales con su capitalización real', () {
    // Caso real de SIGMA: campos en minúscula para el firstTerm parcial
    // y prefijo "_2" + Nta capitalizado para el secondTerm.
    final n = CourseGrade.fromJson({
      'codigo': '331126',
      'asignatura': 'INVESTIGACIÓN FORMATIVA',
      'seccion': 'A1',
      'ciclo': '02',
      'credito': '3.000',
      'asistencia': '100',
      'mtr_Anio': '2025',
      'mtr_Periodo': '2',
      'pF1': '09',
      'pF2': '13',
      'pf': '11',
      'pfp': '11',
      'puesto': '43/62',
      'tipoAsignatura': 'TN',
      'complementario': '--',
      'cc': 'True',
      // Primer parcial — campos lowercase "nta"
      'p1': '15   ',
      'p2': '12   ',
      'p3': '15   ',
      'p4': '     ',
      'ntaP1': '14.00',
      'ntaTI1': '15   ',
      'ntaPY1': '     ',
      'ntaPromTiPy': '14.50',
      'ntaParcial1': '3    ',
      // Segundo parcial — prefijo "_2" + Nta capital
      '_2P1': '13   ',
      '_2P2': '14   ',
      '_2P3': '     ',
      '_2P4': '     ',
      '_2NtaP1': '13.50',
      '_2NtaTI1': '12   ',
      '_2NtaPY1': '     ',
      '_2NtaPromTiPy': '12.75',
      '_2NtaParcial1': '13   ',
    });
    expect(n.currentGradeNum, 11);
    expect(n.currentGradeText, '11.00');
    expect(n.isApproved, true);
    expect(n.asistenciaPct, 100);
    expect(n.pF1, '09');
    expect(n.pF2, '13');

    expect(n.firstTerm.practices, ['15', '12', '15', '']);
    expect(n.firstTerm.practicesAverage, '14.00');
    expect(n.firstTerm.researchWork, '15');
    expect(n.firstTerm.researchProjectAverage, '14.50');
    expect(n.firstTerm.exam, '3');

    expect(n.secondTerm.practices, ['13', '14', '', '']);
    expect(n.secondTerm.practicesAverage, '13.50');
    expect(n.secondTerm.exam, '13');
    expect(n.secondTerm.isEmpty, false);
  });

  test('formatGrade y RecordCourse manejan decimales', () {
    expect(formatGrade('14.00'), '14.00');
    expect(formatGrade('14.50'), '14.50');
    expect(formatGrade('15'), '15.00');
    expect(formatGrade('  '), '—');
    expect(formatGrade('--'), '—');
    expect(parseGrade('14,5'), 14.5);

    final c = RecordCourse.fromRow([
      'INGENIERÍA', 'INGENIERÍA DE SISTEMAS Y COMPUTACIÓN', '2022',
      'CONCLUIDO', 'TN', '1', '33111A', 'METODOLOGÍA', '2', '0',
      '33111A', ' ', '14.00', ' ', '1', 'Jul 13 2025', 'ALESSANDRO',
    ]);
    expect(c.name, 'METODOLOGÍA');
    expect(c.grade, 14.0);
    expect(c.notaText, '14.00');
    expect(c.isApproved, true);
    expect(c.isFinished, true);
  });

  test('ReportCardCourse parsea la fila real (modelo nuevo 2026-1)', () {
    final b = ReportCardCourse.fromRow([
      '72AF4D09-553C-4E2D-BF80-203D0F381292', '2022', '02', '2',
      '332123', 'ALGEBRA LINEAL', 'A1', '100', '2.8000', '3', 'Dsp.',
    ]);
    expect(b.enrollmentSubjectId, '72AF4D09-553C-4E2D-BF80-203D0F381292');
    expect(b.code, '332123');
    expect(b.name, 'ALGEBRA LINEAL');
    expect(b.section, 'A1');
    expect(b.attendance, 100);
    expect(b.average, 2.8);
    expect(b.promedioText, '2.80');
    expect(b.inProgress, true);
  });

  test('CourseGradeDetail agrupa units/evidences/promedios', () {
    const id = 'F7AADDA4-A1B3-4D53-8131-3A70A2C42057';
    final det = CourseGradeDetail.fromRows([
      ['210131', id, '12', '121', 'UNIDAD 1', '20.00', '11',
        'EVIDENCIA DE CONOCIMIENTO', '100.00', '15.00', ' ', 'tbl1'],
      ['210168', id, '12', '121', 'UNIDAD 1', '20.00', '12',
        'EVIDENCIA DE DESEMPEÑO', '100.00', '14.00', ' ', 'tbl1'],
      ['210205', id, '12', '121', 'UNIDAD 1', '20.00', '13',
        'EVIDENCIA DE PRODUCTO', '100.00', '14.00', ' ', 'tbl1'],
      [' ', id, '12', '121', 'UNIDAD 1', '20.00', '11',
        'EVIDENCIA DE CONOCIMIENTO', '100.00', '15.00', ' ', 'tbl2'],
      [' ', id, '12', '121', 'UNIDAD 1', '20.00', ' ', ' ', ' ',
        '14.33', ' ', 'tbl3'],
      [' ', id, ' ', ' ', ' ', ' ', ' ', ' ', ' ', '14.00', ' ', 'tbl4'],
      [' ', id, ' ', ' ', 'SUSTITUTORIO', ' ', ' ', ' ', ' ', ' ', ' ',
        'tbl5'],
      [' ', id, ' ', ' ', ' ', ' ', ' ', ' ', ' ', '3.00', 'Dsp.', 'tbl6'],
    ]);
    expect(det.units.length, 1);
    final u = det.units.first;
    expect(u.name, 'UNIDAD 1');
    expect(u.weight, 20.0);
    expect(u.evidences.length, 3);
    expect(u.evidences.first.type, 'EVIDENCIA DE CONOCIMIENTO');
    expect(u.evidences.first.notaText, '15.00');
    expect(u.promedioText, '14.33');
    expect(det.finalAverageText, '3.00');
    expect(det.state, 'Dsp.');
    expect(det.hasSubstitute, false);
    // Promedio real del curso desde las unidades (sin el redondeo del server)
    expect(det.computedAverage, closeTo(14.33, 0.01));
  });

  test('Fmt.parseAula y Fmt.formatAula procesan correctamente "I 302" y otros formatos', () {
    final parsed = Fmt.parseAula('I 302');
    expect(parsed['pabellon'], 'I');
    expect(parsed['aula'], '302');

    final parsedSingle = Fmt.parseAula('Virtual');
    expect(parsedSingle['pabellon'], null);
    expect(parsedSingle['aula'], 'Virtual');

    final parsedEmpty = Fmt.parseAula('   ');
    expect(parsedEmpty['pabellon'], null);
    expect(parsedEmpty['aula'], null);

    final parsedLab = Fmt.parseAula('LABORATORIO DE COMPUTO 4');
    expect(parsedLab['pabellon'], null);
    expect(parsedLab['aula'], 'LABORATORIO DE COMPUTO 4');

    expect(Fmt.formatAula('I 302'), 'Pab. I - Aula 302');
    expect(Fmt.formatAula('LABORATORIO DE COMPUTO 4'), 'LABORATORIO DE COMPUTO 4');
    expect(Fmt.formatAula('Virtual'), 'Virtual');
    expect(Fmt.formatAula(''), '—');
  });

  testWidgets('SupportScreen renders and handles tapping contact options safely', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale('es'),
        home: SupportScreen(),
      ),
    );

    expect(find.text('Soporte Técnico'), findsOneWidget);
    expect(find.text('¿Tienes algún problema?'), findsOneWidget);
    expect(find.text('WhatsApp'), findsOneWidget);
    expect(find.text('Correo Electrónico'), findsOneWidget);

    // Tap WhatsApp option
    await tester.tap(find.text('WhatsApp'));
    await tester.pumpAndSettle();

    // Tap Email option
    await tester.tap(find.text('Correo Electrónico'));
    await tester.pumpAndSettle();

    // Since we're in a widget test and url_launcher is not mocked,
    // they should fail gracefully via the try-catch block and copy the text
    // to the clipboard, rather than throwing uncaught PlatformExceptions.
  });
}
