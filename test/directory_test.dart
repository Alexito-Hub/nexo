import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexo/data/api_client.dart';
import 'package:nexo/data/backend_client.dart';
import 'package:nexo/data/directory_service.dart';
import 'package:nexo/data/session.dart';
import 'package:nexo/data/sigma_repository.dart';
import 'package:nexo/features/directory/directory_screen.dart';
import 'package:nexo/features/directory/student_record_screen.dart';
import 'package:nexo/l10n/app_localizations.dart';

/// Cliente de mentira: las pantallas del directorio no deben saber de dónde
/// salen los datos, así que se les inyecta uno sin red.
class _StubClient extends BackendClient {
  _StubClient({this.page, this.record});
  final DirectoryPage? page;
  final StudentRecord? record;

  @override
  Future<DirectoryPage> students({
    String? query,
    String? school,
    int? cycle,
    int page = 1,
    int limit = 25,
  }) async =>
      this.page ??
      const DirectoryPage(students: [], total: 0, page: 1, pages: 1);

  @override
  Future<List<String>> schools() async => const ['Ingeniería de Sistemas'];

  @override
  Future<StudentRecord> student(String codigo) async =>
      record ?? (throw const BackendException('no_encontrado'));
}

DirectoryService _service(BackendClient client) {
  final api = ApiClient();
  return DirectoryService(
    session: SessionService(apiClient: api, repo: SigmaRepository(api)),
    client: client,
  );
}

Widget _app(Widget home) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  locale: const Locale('es'),
  home: Scaffold(body: home),
);

/// Baja hasta encontrar el texto: las fichas son largas y en una ventana de
/// prueba casi todo queda debajo del pliegue.
Future<void> _scrollTo(WidgetTester tester, String text) async {
  await tester.scrollUntilVisible(
    find.textContaining(text),
    250,
    scrollable: find.byType(Scrollable).first,
  );
}

void main() {
  testWidgets('el directorio lista estudiantes con su promedio', (
    tester,
  ) async {
    final client = _StubClient(
      page: const DirectoryPage(
        students: [
          StudentSummary(
            code: 'U02001A',
            firstName: 'Ana Lucia',
            lastName: 'Ramirez Soto',
            school: 'Ingeniería de Sistemas',
            cycle: 4,
            status: 'regular',
            average: 15.4,
            creditsApproved: 60,
            creditsTotal: 80,
          ),
          StudentSummary(
            code: 'U02002B',
            firstName: 'Beto',
            lastName: 'Huaman Castro',
            cycle: 2,
            status: 'observado',
            average: 9.2,
          ),
          // Sin promedio compartido: se muestra guion, no un cero.
          StudentSummary(
            code: 'U02003C',
            firstName: 'Cira',
            lastName: 'Paz Rojas',
          ),
        ],
        total: 3,
        page: 1,
        pages: 1,
      ),
    );

    await tester.pumpWidget(_app(DirectoryScreen(directory: _service(client))));
    await tester.pumpAndSettle();

    expect(find.text('Ramirez Soto, Ana Lucia'), findsOneWidget);
    expect(find.text('15.40'), findsOneWidget);
    expect(find.text('9.20'), findsOneWidget);
    expect(find.text('—'), findsOneWidget);
    expect(find.text('3 estudiantes'), findsOneWidget);
  });

  testWidgets('en escritorio la lista se reparte en dos columnas', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1600, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final client = _StubClient(
      page: const DirectoryPage(
        students: [
          StudentSummary(
            code: 'U02001A',
            firstName: 'Ana',
            lastName: 'Ramirez Soto',
            average: 15.4,
          ),
          StudentSummary(
            code: 'U02002B',
            firstName: 'Beto',
            lastName: 'Huaman Castro',
            average: 12.0,
          ),
        ],
        total: 2,
        page: 1,
        pages: 1,
      ),
    );

    await tester.pumpWidget(_app(DirectoryScreen(directory: _service(client))));
    await tester.pumpAndSettle();

    // Misma altura = misma fila. En móvil quedarían una debajo de la otra.
    final first = tester.getTopLeft(find.text('Ramirez Soto, Ana'));
    final second = tester.getTopLeft(find.text('Huaman Castro, Beto'));
    expect(first.dy, second.dy);
    expect(first.dx, lessThan(second.dx));
  });

  testWidgets('la ficha ordena los datos en bloques, sin pestañas', (
    tester,
  ) async {
    final client = _StubClient(
      record: const StudentRecord(
        code: 'U02001A',
        firstName: 'Ana Lucia',
        lastName: 'Ramirez Soto',
        school: 'Ingeniería de Sistemas',
        cycle: 4,
        status: 'regular',
        average: 15.4,
        creditsApproved: 60,
        creditsTotal: 80,
        email: 'ana.ramirez@upla.edu.pe',
        modules: {
          'notas': {
            'cursos': [
              {
                'nombre': 'PROGRAMACIÓN II',
                'seccion': 'B1',
                'promedio': 17.0,
                'estado': 'Apr.',
                'detalle': {
                  'unidades': [
                    {'nombre': 'UNIDAD 1', 'promedio': 17.0},
                  ],
                },
              },
            ],
          },
          'pagos': {
            'vencidas': [
              {
                'descripcion': 'CUOTA 05',
                'moneda': 'S/.',
                'total': 124.13,
                'vencimiento': '28-07-2026',
              },
            ],
            'pendientes': [],
          },
        },
      ),
    );

    await tester.pumpWidget(
      _app(StudentRecordScreen(fetch: client.student, code: 'U02001A')),
    );
    await tester.pumpAndSettle();

    // La cabecera resume lo mismo que el perfil propio.
    expect(find.text('Ramirez Soto, Ana Lucia'), findsOneWidget);
    expect(find.text('15.40'), findsOneWidget);
    expect(find.text('60/80'), findsOneWidget);

    await _scrollTo(tester, 'ana.ramirez@upla.edu.pe');
    expect(find.text('ana.ramirez@upla.edu.pe'), findsOneWidget);

    await _scrollTo(tester, 'PROGRAMACIÓN II');
    expect(find.text('PROGRAMACIÓN II'), findsOneWidget);

    await _scrollTo(tester, 'CUOTA 05');
    expect(find.text('CUOTA 05'), findsOneWidget);

    // El horario no vino en la ficha: se dice que no hay nada, no se finge.
    await _scrollTo(tester, 'Sin datos que mostrar.');
    expect(find.text('Sin datos que mostrar.'), findsWidgets);
  });
}
