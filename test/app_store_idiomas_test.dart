import 'package:flutter_test/flutter_test.dart';
import 'package:nexo/data/app_store.dart';
import 'package:nexo/data/cache_manager.dart';
import 'package:nexo/core/error_handler.dart';
import 'package:nexo/data/connectivity_service.dart';
import 'package:nexo/data/sigma_repository.dart';
import 'package:nexo/domain/idiomas_models.dart';
import 'package:nexo/domain/unified_models.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:nexo/core/storage.dart';

class FakeSigmaRepository extends Fake implements SigmaRepository {}

class FakeCacheManager extends Fake implements CacheManager {}

class FakeErrorHandler extends Fake implements ErrorHandler {}

class FakeConnectivityService extends Fake implements ConnectivityService {}

void main() {
  group('AppStore Idiomas Integration', () {
    late AppStore store;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await AppStorage.init();
      store = AppStore(
        FakeSigmaRepository(),
        cache: FakeCacheManager(),
        errorHandler: FakeErrorHandler(),
        connectivity: FakeConnectivityService(),
      );
    });

    test('filtra cursos de idiomas vigentes (mes y año actual)', () {
      final now = DateTime.now();
      store.idiomasMatricula = AsyncValue.data([
        // Curso antiguo
        IdiomasCourse(
          estNombres: 'JUAN',
          estPaterno: 'PEREZ',
          estMaterno: 'G',
          asigId: 'ING001',
          asignatura: 'INGLES',
          dias: 'LU-MI',
          horaInicio: '08:00',
          horaFin: '09:30',
          aula: '101',
          aulaNombre: 'AULA',
          detMatriculaId: 1,
          modalidad: 'V',
          idiomaNombre: 'INGLES',
          seccion: 'A',
          anio: now.year - 1, // Año anterior
          mes: now.month,
          tipoEstudio: 'REGULAR',
          turno: 'MAÑANA',
          capacidad: 30,
          cantidad: 20,
          fechRegistro: '2025',
          promedio: 15,
        ),
        // Curso vigente
        IdiomasCourse(
          estNombres: 'JUAN',
          estPaterno: 'PEREZ',
          estMaterno: 'G',
          asigId: 'ING002',
          asignatura: 'INGLES II',
          dias: 'MA-JU',
          horaInicio: '10:00',
          horaFin: '11:30',
          aula: '102',
          aulaNombre: 'AULA',
          detMatriculaId: 2,
          modalidad: 'V',
          idiomaNombre: 'INGLES',
          seccion: 'A',
          anio: now.year,
          mes: now.month, // Mes y año actual
          tipoEstudio: 'REGULAR',
          turno: 'MAÑANA',
          capacidad: 30,
          cantidad: 20,
          fechRegistro: '2026',
          promedio: 16,
        ),
      ]);

      final vigentes = store.idiomasVigentes;
      expect(vigentes, hasLength(1));
      expect(vigentes.first.asigId, 'ING002');
    });

    test('combina _baseSchedule y cursos vigentes en schedule getter', () {
      final now = DateTime.now();

      // Simular que el horario base cargó 1 clase de SIGMA
      store.setBaseScheduleForTesting(
        AsyncValue.data([
          const ScheduleClass(
            id: 'SIGMA1',
            nrc: '123',
            subject: 'MATEMATICA',
            modality: 'P',
            section: 'A',
            level: '1',
            campus: 'HYO',
            building: 'PAB',
            room: '101',
            note: '',
            teacher: 'PROFE',
            weekday: 1,
            dayName: 'LUNES',
            startTime: '08:00',
            endTime: '09:30',
            typeCode: 'T',
          ),
        ]),
      );

      // Simular que cargaron idiomas (1 vigente, 1 antiguo)
      store.idiomasMatricula = AsyncValue.data([
        IdiomasCourse(
          estNombres: 'JUAN',
          estPaterno: 'P',
          estMaterno: 'G',
          asigId: 'ING_OLD',
          asignatura: 'INGLES VIEJO',
          dias: 'LU',
          horaInicio: '08:00',
          horaFin: '09:30',
          aula: '1',
          aulaNombre: '1',
          detMatriculaId: 1,
          modalidad: 'V',
          idiomaNombre: 'INGLES',
          seccion: 'A',
          anio: 2000, // Antiguo
          mes: 1,
          tipoEstudio: 'REGULAR',
          turno: 'MAÑANA',
          capacidad: 30,
          cantidad: 20,
          fechRegistro: '2000',
          promedio: 10,
        ),
        IdiomasCourse(
          estNombres: 'JUAN',
          estPaterno: 'P',
          estMaterno: 'G',
          asigId: 'ING_NEW',
          asignatura: 'INGLES NUEVO',
          dias: 'MA',
          horaInicio: '10:00',
          horaFin: '11:30',
          aula: '2',
          aulaNombre: '2',
          detMatriculaId: 2,
          modalidad: 'V',
          idiomaNombre: 'INGLES',
          seccion: 'A',
          anio: now.year, // Vigente
          mes: now.month,
          tipoEstudio: 'REGULAR',
          turno: 'MAÑANA',
          capacidad: 30,
          cantidad: 20,
          fechRegistro: '2026',
          promedio: 15,
        ),
      ]);

      // El getter `schedule` debe combinar el horario base con el curso vigente (y descartar el antiguo)
      final combined = store.schedule.value!;

      expect(combined, hasLength(2));
      expect(
        combined.any((c) => c.id == 'SIGMA1'),
        isTrue,
        reason: 'Mantiene horario base',
      );
      expect(
        combined.any((c) => c.subject == 'INGLES NUEVO'),
        isTrue,
        reason: 'Agrega curso vigente',
      );
      expect(
        combined.any((c) => c.subject == 'INGLES VIEJO'),
        isFalse,
        reason: 'Excluye curso caduco',
      );
    });
  });
}
