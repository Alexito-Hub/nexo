import 'package:nexo/domain/unified_models.dart';

class IdiomasCourse {
  final String estNombres;
  final String estPaterno;
  final String estMaterno;
  final String asigId;
  final String asignatura;
  final String dias;
  final String horaInicio;
  final String horaFin;
  final String aula;
  final String aulaNombre;
  final int detMatriculaId;
  final String modalidad;
  final String idiomaNombre;
  final String seccion;
  final int anio;
  final int mes;
  final String tipoEstudio;
  final String turno;
  final int capacidad;
  final int cantidad;
  final String fechRegistro;
  final num promedio;

  IdiomasCourse({
    required this.estNombres,
    required this.estPaterno,
    required this.estMaterno,
    required this.asigId,
    required this.asignatura,
    required this.dias,
    required this.horaInicio,
    required this.horaFin,
    required this.aula,
    required this.aulaNombre,
    required this.detMatriculaId,
    required this.modalidad,
    required this.idiomaNombre,
    required this.seccion,
    required this.anio,
    required this.mes,
    required this.tipoEstudio,
    required this.turno,
    required this.capacidad,
    required this.cantidad,
    required this.fechRegistro,
    required this.promedio,
  });

  factory IdiomasCourse.fromJson(Map<String, dynamic> json) {
    return IdiomasCourse(
      estNombres: json['estNombres'] ?? '',
      estPaterno: json['estPaterno'] ?? '',
      estMaterno: json['estMaterno'] ?? '',
      asigId: json['asigId'] ?? '',
      asignatura: json['asignatura'] ?? '',
      dias: json['dias'] ?? '',
      horaInicio: json['horaInicio'] ?? '',
      horaFin: json['horaFin'] ?? '',
      aula: json['aula'] ?? '',
      aulaNombre: json['aulaNombre'] ?? '',
      detMatriculaId: json['detMatriculaId'] ?? 0,
      modalidad: json['modalidad'] ?? '',
      idiomaNombre: json['idiomaNombre'] ?? '',
      seccion: json['seccion'] ?? '',
      anio: json['anio'] ?? 0,
      mes: json['mes'] ?? 0,
      tipoEstudio: json['tipoEstudio'] ?? '',
      turno: json['turno'] ?? '',
      capacidad: json['capacidad'] ?? 0,
      cantidad: json['cantidad'] ?? 0,
      fechRegistro: json['fechRegistro'] ?? '',
      promedio: json['promedio'] ?? 0,
    );
  }

  /// Convierte los días "LU-MA-MI-JU-VI" en múltiples instancias de ScheduleClass
  List<ScheduleClass> toScheduleClasses() {
    final classes = <ScheduleClass>[];
    
    // No parse to int needed, ScheduleClass expects strings for startTime and endTime.

    final List<String> dayTokens = dias.split('-');
    final Map<String, int> dayMap = {
      'LU': 1,
      'MA': 2,
      'MI': 3,
      'JU': 4,
      'VI': 5,
      'SA': 6,
      'DO': 7,
    };

    for (final token in dayTokens) {
      final t = token.trim().toUpperCase();
      if (dayMap.containsKey(t)) {
        classes.add(ScheduleClass(
          id: asigId,
          nrc: '',
          subject: asignatura,
          modality: modalidad,
          section: seccion,
          level: '',
          campus: modalidad.toUpperCase() == 'VIRTUAL' ? 'VIRTUAL' : 'PRESENCIAL',
          building: modalidad.toUpperCase() == 'VIRTUAL' ? '' : 'Centro de Idiomas',
          room: aula,
          note: '$tipoEstudio · $turno',
          teacher: 'Centro de Idiomas',
          weekday: dayMap[t]!,
          dayName: token.trim(),
          startTime: horaInicio,
          endTime: horaFin,
          typeCode: 'I',
        ));
      }
    }
    return classes;
  }
}
