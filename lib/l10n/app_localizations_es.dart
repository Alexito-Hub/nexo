// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get tabHome => 'Inicio';

  @override
  String get tabSchedule => 'Horario';

  @override
  String get tabGrades => 'Notas';

  @override
  String get tabPayments => 'Pagos';

  @override
  String get tabTeacher => 'Docente';

  @override
  String get tabCourses => 'Cursos';

  @override
  String get tabProfile => 'Perfil';

  @override
  String get titleHome => 'Inicio';

  @override
  String get titleSchedule => 'Horario';

  @override
  String get titleGrades => 'Notas';

  @override
  String get titlePayments => 'Pagos';

  @override
  String get titleProfile => 'Perfil';

  @override
  String get titleTeacher => 'Docente';

  @override
  String get titleCourses => 'Mis cursos';

  @override
  String get subtitleCourses => 'Asignaturas que dictas';

  @override
  String get titleAbout => 'Acerca de Nexo';

  @override
  String get titleTerms => 'Términos y privacidad';

  @override
  String get titleDeveloper => 'Desarrollador';

  @override
  String get titleChangePassword => 'Cambiar contraseña';

  @override
  String get titleNotifications => 'Notificaciones';

  @override
  String get subtitlePayments => 'Cuotas, tasas e historial';

  @override
  String get subtitleTeacher => 'Tus cursos y estudiantes';

  @override
  String get language => 'Idioma';

  @override
  String get timeFormat => 'Formato de hora';

  @override
  String get hours24 => '24 horas';

  @override
  String get hours12 => '12 horas';

  @override
  String get actionLogout => 'Cerrar sesión';

  @override
  String get actionAccept => 'Aceptar';

  @override
  String get actionCancel => 'Cancelar';

  @override
  String get actionRetry => 'Reintentar';

  @override
  String get actionClose => 'Cerrar';

  @override
  String get actionCopy => 'Copiar';

  @override
  String get scheduleDetailTitle => 'Detalle de la clase';

  @override
  String get detailSchedule => 'Horario';

  @override
  String get detailLocation => 'Ubicación';

  @override
  String get detailRoom => 'Aula';

  @override
  String get detailPavilion => 'Pabellón';

  @override
  String weekdayFull(String day) {
    String _temp0 = intl.Intl.selectLogic(day, {
      'mon': 'Lunes',
      'tue': 'Martes',
      'wed': 'Miércoles',
      'thu': 'Jueves',
      'fri': 'Viernes',
      'sat': 'Sábado',
      'sun': 'Domingo',
      'other': '—',
    });
    return '$_temp0';
  }

  @override
  String weekdayShort(String day) {
    String _temp0 = intl.Intl.selectLogic(day, {
      'mon': 'Lun',
      'tue': 'Mar',
      'wed': 'Mié',
      'thu': 'Jue',
      'fri': 'Vie',
      'sat': 'Sáb',
      'sun': 'Dom',
      'other': '—',
    });
    return '$_temp0';
  }

  @override
  String monthShort(String month) {
    String _temp0 = intl.Intl.selectLogic(month, {
      'jan': 'Ene',
      'feb': 'Feb',
      'mar': 'Mar',
      'apr': 'Abr',
      'may': 'May',
      'jun': 'Jun',
      'jul': 'Jul',
      'aug': 'Ago',
      'sep': 'Sep',
      'oct': 'Oct',
      'nov': 'Nov',
      'dec': 'Dic',
      'other': '—',
    });
    return '$_temp0';
  }

  @override
  String timeGreeting(String period) {
    String _temp0 = intl.Intl.selectLogic(period, {
      'morning': 'Buenos días',
      'afternoon': 'Buenas tardes',
      'evening': 'Buenas noches',
      'other': 'Hola',
    });
    return '$_temp0';
  }

  @override
  String get detailBuilding => 'Local';

  @override
  String get detailCampus => 'Sede';

  @override
  String get detailTeacher => 'Docente';

  @override
  String get detailSessions => 'Sesiones';

  @override
  String get detailNotes => 'Observaciones';

  @override
  String get detailNrc => 'NRC';

  @override
  String get detailSection => 'Sec.';

  @override
  String get detailLevel => 'Nivel';

  @override
  String get detailToday => 'HOY';

  @override
  String detailDuration(int minutes) {
    return 'Duración total: $minutes minutos';
  }

  @override
  String get settingsTitle => 'Configuración';

  @override
  String get settingsAppearance => 'Apariencia';

  @override
  String get settingsPalette => 'Paleta';

  @override
  String get settingsSystem => 'Sistema';

  @override
  String get settingsSystemDesc =>
      'Sigue el modo claro/oscuro de tu dispositivo';

  @override
  String get settingsActive => 'Activa';

  @override
  String get settingsNotificationsSubtitle => 'Recordatorios y alertas';

  @override
  String get notificationsIntro =>
      'Recibe avisos de tus clases, pagos y notas. Personaliza qué llega y con cuánta anticipación.';

  @override
  String get notificationsClassesTitle => 'Clases';

  @override
  String get notificationsClassesSubtitle => 'Aviso antes de cada clase';

  @override
  String get notificationsPaymentsTitle => 'Pagos';

  @override
  String get notificationsPaymentsSubtitle => 'Aviso antes de cada vencimiento';

  @override
  String get notificationsNotifyMe => 'Avisarme';

  @override
  String notificationsPaymentHour(String hour) {
    return 'Hora del aviso: $hour:00';
  }

  @override
  String get notificationsGradesTitle => 'Notas';

  @override
  String get notificationsGradesSubtitle =>
      'Aviso cuando se publique una nota nueva';

  @override
  String get notificationsEnableTitle => 'Habilitar notificaciones';

  @override
  String get notificationsEnabledLabel => 'Activadas';

  @override
  String get notificationsDisabledLabel => 'Desactivadas';

  @override
  String get notificationsInfoNote =>
      'Las clases y pagos se programan en tu dispositivo. Las notas se detectan al abrir la app y sincronizar.';

  @override
  String get homeTodayTitle => 'Hoy';

  @override
  String get homeScheduleLoadError => 'No se pudo cargar el horario';

  @override
  String get homeSeeFullWeek => 'Ver semana completa';

  @override
  String get homePendingPaymentsTitle => 'Pagos pendientes';

  @override
  String get homePaymentsLoadError => 'No se pudo cargar los pagos';

  @override
  String get homeSeeAllPayments => 'Ver todos los pagos';

  @override
  String get schedulePeriodActive => 'Periodo activo';

  @override
  String schedulePeriodActiveCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Periodo activo · $count clases',
      one: 'Periodo activo · $count clase',
      zero: 'Periodo activo',
    );
    return '$_temp0';
  }

  @override
  String get scheduleErrorTitle => 'Error';

  @override
  String get scheduleLoadError => 'No se pudo cargar el horario';

  @override
  String get scheduleNoClassesTitle => 'Sin clases';

  @override
  String get scheduleNoClassesSubtitle => 'No hay clases registradas';

  @override
  String get scheduleToggleWeek => 'Semana';

  @override
  String get scheduleToggleList => 'Lista';

  @override
  String get scheduleNoClassesScheduled => 'Sin clases programadas';

  @override
  String get gradesTitle => 'Notas';

  @override
  String get gradesSubtitleNoPeriod => 'Boleta de notas';

  @override
  String gradesSubtitleUnits(String period) {
    return 'Por unidades · $period';
  }

  @override
  String gradesSubtitlePartials(String period) {
    return 'Por parciales · $period';
  }

  @override
  String get gradesSelectPeriod => 'Selecciona un periodo';

  @override
  String get gradesSubjects => 'Asignaturas';

  @override
  String get gradesLoadError => 'No se pudo cargar la boleta';

  @override
  String get gradesNoNotesTitle => 'Sin notas en este periodo';

  @override
  String get gradesNoNotesSubtitleNewModel =>
      'La boleta por unidades aplica desde 2026-1.';

  @override
  String gradesSubjectsWithPeriod(String period) {
    return 'Asignaturas · $period';
  }

  @override
  String gradesCoursesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cursos',
      one: '$count curso',
    );
    return '$_temp0';
  }

  @override
  String get actionShow => 'Mostrar';

  @override
  String get actionHide => 'Ocultar';

  @override
  String get actionSkip => 'Saltar';

  @override
  String get actionNext => 'Siguiente';

  @override
  String get validationRequired => 'Requerido';

  @override
  String get changePasswordSuccess => 'Contraseña actualizada correctamente.';

  @override
  String get changePasswordHeader => 'Define tu nueva contraseña';

  @override
  String get changePasswordSubheader =>
      'Se aplicará en todos los servicios institucionales que usen tu cuenta UPLA.';

  @override
  String get changePasswordCurrentLabel => 'Contraseña actual';

  @override
  String get changePasswordNewLabel => 'Nueva contraseña';

  @override
  String get changePasswordRepeatLabel => 'Repetir nueva contraseña';

  @override
  String changePasswordMinChars(int min) {
    return 'Mínimo $min caracteres';
  }

  @override
  String get changePasswordMustBeDifferent => 'Debe ser distinta a la actual';

  @override
  String get changePasswordNoMatch => 'No coincide';

  @override
  String get changePasswordUpdateButton => 'Actualizar contraseña';

  @override
  String get loginWelcomeBack => 'Bienvenido de nuevo';

  @override
  String get loginIntro =>
      'Inicia sesión con tu cuenta institucional. Guardaremos tu sesión para que no tengas que volver a entrar.';

  @override
  String get loginUserLabel => 'Código o DNI';

  @override
  String get loginUserRequired => 'Ingresa tu usuario';

  @override
  String get loginPasswordLabel => 'Contraseña';

  @override
  String get loginPasswordRequired => 'Ingresa tu contraseña';

  @override
  String get loginCapsLockOn => 'Bloq Mayús está activado';

  @override
  String get loginSubmit => 'Iniciar sesión';

  @override
  String get loginDeviceOnly =>
      'Tus credenciales se guardan solo en este dispositivo';

  @override
  String get loginBrandTagline => 'Tu vida académica UPLA,\nen un solo lugar.';

  @override
  String get loginFeatureSchedule => 'Horario y próxima clase al instante';

  @override
  String get loginFeaturePayments => 'Pagos, vencimientos y alertas';

  @override
  String get loginFeatureGrades => 'Notas y progreso académico';

  @override
  String get loginFeatureWidgets => 'Widgets en tu pantalla de inicio';

  @override
  String get onboardingTitleWelcome => 'Bienvenido a Nexo';

  @override
  String get onboardingBodyWelcome =>
      'Tu vida académica UPLA reimaginada: clara, rápida y siempre contigo.';

  @override
  String get onboardingTitleSchedule => 'Horario inteligente';

  @override
  String get onboardingBodySchedule =>
      'Tus clases de hoy y la próxima clase con cuenta regresiva. Teoría y práctica del mismo curso, unidas.';

  @override
  String get onboardingTitlePayments => 'Pagos sin sorpresas';

  @override
  String get onboardingBodyPayments =>
      'Cuotas pendientes, vencidas, tasas e historial. Sabrás cuánto y cuándo pagar sin entrar al portal.';

  @override
  String get onboardingTitleWidgets => 'Widgets en tu pantalla';

  @override
  String get onboardingBodyWidgets =>
      'Agrega widgets a la pantalla de inicio de Android: próxima clase, pagos y tu promedio, de un vistazo.';

  @override
  String get onboardingStart => 'Empezar';

  @override
  String get wifiTitle => 'Wi-Fi institucional';

  @override
  String get wifiSubtitle => 'Misma cuenta institucional UPLA';

  @override
  String get wifiUserLabel => 'USUARIO';

  @override
  String get wifiPasswordLabel => 'CONTRASEÑA';

  @override
  String get wifiUserCopied => 'Usuario copiado';

  @override
  String get wifiPasswordCopied => 'Contraseña copiada';

  @override
  String get actionSave => 'Guardar';

  @override
  String get actionCodeCopied => 'Código copiado';

  @override
  String get profileSettingsSubtitle =>
      'Apariencia, idioma, hora y notificaciones';

  @override
  String get profileChangePasswordSubtitle =>
      'Para tu cuenta institucional UPLA';

  @override
  String profileAboutSubtitle(String version) {
    return 'Versión $version';
  }

  @override
  String get logoutConfirmTitle => 'Cerrar sesión';

  @override
  String get logoutConfirmBody => '¿Quieres salir de tu cuenta?';

  @override
  String get docenteChangeDate => 'Cambiar';

  @override
  String get docenteSaveAttendance => 'Guardar asistencia';

  @override
  String get docenteAttendanceSaved => 'Asistencia guardada';

  @override
  String docenteAttendanceError(String error) {
    return 'Error: $error';
  }

  @override
  String get docenteGradeLabel => 'Nota (0 - 20)';

  @override
  String get docenteGradeEnter => 'Ingresa una nota';

  @override
  String get docenteGradeInvalidNumber => 'Número inválido';

  @override
  String get docenteGradeRange => 'Entre 0 y 20';

  @override
  String get termsHeaderPre => 'Antes de empezar';

  @override
  String get termsHeaderTitle => 'Términos de uso y privacidad';

  @override
  String get termsHeaderSubtitle =>
      'Léelos con calma y acéptalos para continuar.';

  @override
  String get termsAcceptNote => 'Al continuar aceptas estos términos.';

  @override
  String get termsAcceptButton => 'Aceptar y continuar';

  @override
  String get termsBrandTitle => 'Bienvenido a Nexo';

  @override
  String get termsBrandBody =>
      'Privacidad primero. Aquí te decimos qué se queda en tu dispositivo y qué sale de él.';

  @override
  String get termsItemWhatTitle => 'Qué es Nexo';

  @override
  String get termsItemWhatBody =>
      'Aplicación independiente y no oficial, creada por y para estudiantes, que reorganiza tu información académica de la UPLA de forma más clara. No está afiliada ni respaldada por la UPLA.';

  @override
  String get termsItemPrivacyTitle => 'Tus datos y privacidad';

  @override
  String get termsItemPrivacyBody =>
      'Tus credenciales y tus datos académicos se guardan únicamente en tu dispositivo. Nexo no envía tu información a servidores propios ni a terceros: las peticiones van directamente a los servicios de la UPLA, igual que el portal oficial.';

  @override
  String get termsItemSecurityTitle => 'Seguridad';

  @override
  String get termsItemSecurityBody =>
      'El almacenamiento local no está cifrado a nivel del sistema, así que usa Nexo solo en dispositivos de tu confianza. Puedes cerrar sesión para borrar credenciales y caché en cualquier momento.';

  @override
  String get termsItemResponsibleTitle => 'Uso responsable';

  @override
  String get termsItemResponsibleBody =>
      'Accede solo a tu propia información y con tus propias credenciales. Es un proyecto educativo y de uso personal: úsalo conforme a los reglamentos de tu universidad.';

  @override
  String get termsItemDisclaimerTitle => 'Sin garantías';

  @override
  String get termsItemDisclaimerBody =>
      'El servicio se ofrece \"tal cual\", sin garantías. Para trámites oficiales consulta siempre el portal institucional.';

  @override
  String get aboutFeatureAllInOneTitle => 'Tu universidad en un solo lugar';

  @override
  String get aboutFeatureAllInOneBody =>
      'Perfil, horario, notas, pagos y próximas tareas, sin saltar entre SIGMA, Intranet y otros portales.';

  @override
  String get aboutFeatureMultiplatformTitle => 'Multiplataforma';

  @override
  String get aboutFeatureMultiplatformBody =>
      'Misma experiencia en Android, iOS, Web y escritorio, con una sola base de código en Flutter.';

  @override
  String get aboutFeaturePrivacyTitle => 'Privacidad primero';

  @override
  String get aboutFeaturePrivacyBody =>
      'Tus credenciales se guardan solo en tu dispositivo. Las peticiones van directo a los servicios de la UPLA, sin servidores intermedios.';

  @override
  String get aboutFeatureNoSdkTitle => 'Sin SDKs de terceros';

  @override
  String get aboutFeatureNoSdkBody =>
      'Autenticación y red implementadas a mano sobre HTTP estándar, para controlar errores y mantenerlo ligero.';

  @override
  String get aboutFooterDisclaimer =>
      'Nexo es un proyecto independiente y no oficial, creado por y para estudiantes. No está afiliado ni respaldado por la UPLA.';

  @override
  String aboutHeroSubtitle(String version) {
    return 'Cliente UPLA · v$version';
  }

  @override
  String get aboutDetailsTitle => 'Detalles';

  @override
  String get aboutDetailsVersionLabel => 'Versión';

  @override
  String get aboutDetailsBuildLabel => 'Build';

  @override
  String get aboutDetailsPlatformsLabel => 'Plataformas';

  @override
  String get aboutDetailsPlatformsValue => 'Android · iOS · Web · Escritorio';

  @override
  String get aboutDetailsTechLabel => 'Tecnología';

  @override
  String get aboutDetailsTechValue => 'Flutter';

  @override
  String get developerGithubCopied => 'Enlace de GitHub copiado';

  @override
  String get developerSubtitle => 'Quién creó Nexo';

  @override
  String get developerRole => 'Desarrollador independiente · Estudiante UPLA';

  @override
  String get supportTitle => 'Soporte Técnico';

  @override
  String get supportHeroBadge => 'SOPORTE 24/7';

  @override
  String get supportHeroTitle => '¿Tienes algún problema?';

  @override
  String get supportHeroBody =>
      'Estamos aquí para ayudarte. Si experimentas fallas en la app, problemas de conexión o errores en los datos, contáctanos directamente por WhatsApp o correo electrónico.';

  @override
  String get supportChannelsTitle => 'Canales de Atención';

  @override
  String get supportChannelWhatsApp => 'WhatsApp';

  @override
  String get supportChannelEmail => 'Correo Electrónico';

  @override
  String get supportInfoNote =>
      'Al presionar el canal de atención, se abrirá la aplicación correspondiente. De lo contrario, los datos de contacto se copiarán a tu portapapeles.';

  @override
  String get supportWhatsAppMessage =>
      'Hola, tengo un problema con la aplicación Nexo';

  @override
  String get supportWhatsAppCopied => 'Número de WhatsApp de Soporte copiado';

  @override
  String get supportEmailSubject => 'Soporte Nexo App';

  @override
  String get supportEmailBody =>
      'Hola, tengo un problema con la aplicación Nexo:';

  @override
  String get supportEmailCopied => 'Correo electrónico de Soporte copiado';

  @override
  String get supportContactButton => 'Contactar Soporte Técnico';

  @override
  String get docenteLabel => 'DOCENTE';

  @override
  String get docenteCodeLabel => 'Código de docente';

  @override
  String get docenteMetricCursos => 'Cursos';

  @override
  String get docenteMetricAlumnos => 'Alumnos';

  @override
  String get docenteMetricPeriodo => 'Periodo';

  @override
  String get docenteNoClassesToday => 'No dictas hoy';

  @override
  String get docenteToday => 'Hoy';

  @override
  String docenteClassCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count clases',
      one: '$count clase',
    );
    return '$_temp0';
  }

  @override
  String get docenteTypeTeoria => 'TEO';

  @override
  String get docenteTypePractica => 'PRÁC';

  @override
  String get docenteLoadingClasses => 'Cargando clases...';

  @override
  String docenteSessionsWeeklyCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sesiones esta semana',
      one: '1 sesión esta semana',
    );
    return 'Mis clases · $_temp0';
  }

  @override
  String get docenteNoClassesRegistered => 'No tienes clases registradas';

  @override
  String docenteCourseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cursos',
      one: '$count curso',
    );
    return '$_temp0';
  }

  @override
  String docenteCoursesCountPlural(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count asignaturas',
      one: '$count asignatura',
    );
    return '$_temp0';
  }

  @override
  String docenteMetricAlumnosCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count alumnos',
      one: '$count alumno',
    );
    return '$_temp0';
  }

  @override
  String get docenteLoadCoursesError => 'No se pudieron cargar los cursos';

  @override
  String get docenteNoCoursesPeriod => 'Sin cursos asignados en este periodo';

  @override
  String get docenteTabAlumnos => 'Alumnos';

  @override
  String get docenteTabAsistencia => 'Asistencia';

  @override
  String get docenteTabNotas => 'Notas';

  @override
  String get docenteNoCode => 'Sin código';

  @override
  String docenteSectionPeriod(String seccion, String periodo) {
    return 'Sección $seccion · $periodo';
  }

  @override
  String get docenteNoAlumnosRegistered => 'Sin alumnos registrados';

  @override
  String docenteAsisPercent(String percent) {
    return '$percent% asist.';
  }

  @override
  String get docenteAttendancePresentShort => 'Pres.';

  @override
  String get docenteAttendanceTardanzaShort => 'Tard.';

  @override
  String get docenteAttendanceFaltaShort => 'Falta';

  @override
  String get docenteNoAlumnosInCourse => 'Sin alumnos en este curso';

  @override
  String docenteAprobadosCount(String aprobados, String total) {
    return '$aprobados de $total aprobados';
  }

  @override
  String get docenteTapToEdit => 'Toca para editar →';

  @override
  String get docentePromedioParcial => 'PROMEDIO PARCIAL';

  @override
  String docenteCoursePercentGraded(String percent) {
    return '$percent% del curso\nya calificado';
  }

  @override
  String get docenteEvalPending => 'PENDIENTE';

  @override
  String get docenteNoAttendanceRecords => 'Sin registros de asistencia.';

  @override
  String get docenteAttendanceLabel => 'ASISTENCIA';

  @override
  String docenteSessionsRegisteredCount(String presentes, String total) {
    return '$presentes de $total\nsesiones registradas';
  }

  @override
  String get docenteAttendancePresent => 'Presente';

  @override
  String get docenteAttendanceTardanza => 'Tardanza';

  @override
  String get docenteAttendanceFalta => 'Falta';

  @override
  String get docenteAttendanceJustificada => 'Justificada';

  @override
  String get docenteInfoTitle => 'Información del docente';

  @override
  String get docenteInfoFieldNombres => 'Nombres';

  @override
  String get docenteInfoFieldApellidos => 'Apellidos';

  @override
  String get docenteInfoFieldFacultad => 'Facultad';

  @override
  String get docenteInfoFieldEspecialidad => 'Especialidad';

  @override
  String get docenteSupportSubtitle => 'Contactar por WhatsApp o Correo';

  @override
  String get connectivityStatusTitle => 'Estado de Conexión';

  @override
  String get connectivityDiagnosticsSubtitle => 'Diagnóstico en tiempo real';

  @override
  String get connectivityInternet => 'Conexión a Internet';

  @override
  String get connectivitySigma => 'Servidor SIGMA';

  @override
  String get connectivityIntranet => 'Servidor INTRANET';

  @override
  String get connectivityBackupNote =>
      'Los datos locales de respaldo se usarán automáticamente cuando no haya conexión con los servidores.';

  @override
  String get connectivityOnline => 'En línea';

  @override
  String get connectivityOffline => 'Caído';

  @override
  String get connectivityDegraded => 'Inestable';

  @override
  String get connectivityConnected => 'Conectado';

  @override
  String get connectivityDisconnected => 'Desconectado';

  @override
  String get homeVerifyConnectivity => 'Verificar Estado de Conexión';

  @override
  String get homeMetricPromedio => 'Promedio';

  @override
  String get homeMetricPromedioCiclo => 'Prom. ciclo';

  @override
  String get homeMetricPromedioAcumulado => 'Prom. acum.';

  @override
  String get homeMetricCreditos => 'Créditos';

  @override
  String get homeMetricClasesHoy => 'Clases hoy';

  @override
  String get homeMetricPorPagar => 'Por pagar';

  @override
  String get gradesDetailLoadError => 'No se pudo cargar el detalle';

  @override
  String get gradesSustitutorio => 'Examen sustitutorio';

  @override
  String get gradesNoUnitsYetTitle => 'Aún sin unidades calificadas';

  @override
  String get gradesNoUnitsYetSubtitle => 'Las notas aparecerán al publicarse.';

  @override
  String get gradesEvidenciaConocimiento => 'Evidencia de conocimiento';

  @override
  String get gradesEvidenciaDesempeno => 'Evidencia de desempeño';

  @override
  String get gradesEvidenciaProducto => 'Evidencia de producto';

  @override
  String get gradesPromedioAcumulado => 'Promedio acumulado';

  @override
  String get gradesNoCreditsData => 'Sin datos de créditos';

  @override
  String get gradesNoHistoryYet => 'Sin historial aún';

  @override
  String get gradesEvolutionByPeriod => 'Evolución por periodo';

  @override
  String get statusInProcess => 'EN PROCESO';

  @override
  String get paymentsFilterAll => 'Todos';

  @override
  String get paymentsNoneInPeriod => 'Sin pagos en este periodo';

  @override
  String homeMoreClassesToday(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+ $count clases más hoy',
      one: '+ 1 clase más hoy',
    );
    return '$_temp0';
  }

  @override
  String get statusApproved => 'APROBADO';

  @override
  String get statusFailed => 'DESAPROBADO';

  @override
  String get gradesPromedioLabel => 'Promedio';

  @override
  String get gradesParcial1 => 'Parcial 1';

  @override
  String get gradesParcial2 => 'Parcial 2';

  @override
  String get gradesPromedioParcial1 => 'Promedio parcial 1';

  @override
  String get gradesPromedioParcial2 => 'Promedio parcial 2';

  @override
  String get gradesPromedioFinal => 'Promedio final';

  @override
  String get gradesPrimerParcial => 'Primer parcial';

  @override
  String get gradesSegundoParcial => 'Segundo parcial';

  @override
  String get gradesPromedioPracticas => 'Promedio de prácticas';

  @override
  String get gradesTrabajoInvestigacion => 'Trabajo de investigación';

  @override
  String get gradesExamenParcial => 'Examen parcial';

  @override
  String get gradesExamenComplementario => 'Examen complementario';

  @override
  String get paymentsDownloadSchedulePdf => 'Descargar cronograma (PDF)';

  @override
  String get paymentsTabPending => 'Pendientes';

  @override
  String get paymentsTabOverdue => 'Vencidas';

  @override
  String get paymentsTabFees => 'Tasas';

  @override
  String get paymentsUpToDateTitle => '¡Estás al día!';

  @override
  String get paymentsUpToDateSubtitle => 'No tienes cuotas próximas a vencer.';

  @override
  String get paymentsNoOverdueTitle => 'Sin cuotas vencidas';

  @override
  String get paymentsNoOverdueSubtitle =>
      'Genial, no tienes cuotas con vencimiento pasado.';

  @override
  String get paymentVenceHoy => 'VENCE HOY';

  @override
  String get paymentVenceManana => 'Vence mañana';

  @override
  String get paymentVenceMananaCaps => 'VENCE MAÑANA';

  @override
  String get paymentsNoFeesRegistered => 'Sin tasas registradas';

  @override
  String get paymentsNoHistoryRegistered => 'Sin pagos registrados';

  @override
  String get paymentDetailCuota => 'Detalle de Cuota';

  @override
  String get paymentDetailTasa => 'Detalle de Tasa';

  @override
  String get paymentDetailPago => 'Detalle de Pago';

  @override
  String get paymentDetailTasaAdministrativa => 'Tasa Administrativa';

  @override
  String get paymentDetailImporteBase => 'Importe Base';

  @override
  String get paymentDetailFechaVencimiento => 'Fecha de Vencimiento';

  @override
  String get paymentDetailImportePagado => 'Importe Pagado';

  @override
  String get paymentDetailFechaPago => 'Fecha de Pago';

  @override
  String get paymentDetailHoraPago => 'Hora de Pago';

  @override
  String get paymentDetailPeriodoAcademico => 'Periodo Académico';

  @override
  String get paymentDetailLugarPago => 'Lugar de Pago';

  @override
  String get paymentDetailDescripcionOperacion => 'Descripción de Operación';

  @override
  String get paymentDetailInformacionDetallada => 'Información Detallada';

  @override
  String get profileDownloadEnrollmentPdf => 'Constancia de matrícula (PDF)';

  @override
  String get profileStudentCode => 'Código de estudiante';

  @override
  String get profileCareer => 'Carrera';

  @override
  String get profileFaculty => 'Facultad';

  @override
  String get profileCampus => 'Sede';

  @override
  String get profileMode => 'Modalidad';

  @override
  String get profileStudyPlan => 'Plan de estudios';

  @override
  String get profileLevel => 'Nivel';

  @override
  String get profileLastEnrollment => 'Última matrícula';

  @override
  String get profileStatus => 'Estado';

  @override
  String get profileStatusNotEnrolled => 'No matriculado';

  @override
  String get profileStatusEnrolled => 'Matriculado';

  @override
  String get profileAcademicInfo => 'Información académica';

  @override
  String get pdfExportLoadConstanciaError => 'No se pudo cargar la constancia.';

  @override
  String get pdfExportLoadCronogramaError => 'No se pudo cargar el cronograma.';

  @override
  String gradesCreditsSummary(String aprobados, String total) {
    return '$aprobados de $total créditos';
  }

  @override
  String gradesCreditsApprovedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count créditos aprobados',
      one: '1 crédito aprobado',
    );
    return '$_temp0';
  }

  @override
  String gradesRank(String rank) {
    return ' · Puesto $rank';
  }

  @override
  String get gradesSummary => 'Resumen';

  @override
  String gradesPractice(String index) {
    return 'Práctica $index';
  }

  @override
  String get gradesProyecto => 'Proyecto';

  @override
  String get gradesPromedioTiPy => 'Promedio TI + PY';

  @override
  String get paymentsTabHistory => 'Historial';

  @override
  String get paymentsLoadError => 'No se pudo cargar';

  @override
  String paymentDaysOverdue(String days) {
    return 'VENCIDA hace $days d.';
  }

  @override
  String paymentDaysLeft(String days) {
    return 'En $days días';
  }

  @override
  String paymentMora(String currency, String amount) {
    return 'Mora $currency $amount';
  }

  @override
  String paymentVenceEl(String date) {
    return 'Vence el $date';
  }

  @override
  String get paymentStatusPaid => 'PAGADO';

  @override
  String paymentDateOfPayment(String date) {
    return 'Fecha de Pago: $date';
  }

  @override
  String get paymentMoraLabel => 'Mora';

  @override
  String get paymentDetailObservacion => 'Observación';

  @override
  String get paymentDetailConcepto => 'Concepto';

  @override
  String get paymentDetailImporte => 'Importe';

  @override
  String get paymentDetailComprobante => 'Comprobante';

  @override
  String get paymentDetailOperacion => 'Operación';

  @override
  String get setupTitle => '¡Bienvenido a Nexo UPLA!';

  @override
  String get setupSubtitle =>
      'Hemos detectado que estás ejecutando la aplicación fuera del directorio de instalación oficial.';

  @override
  String get setupBtnInstall => 'Instalar en mi Computadora';

  @override
  String get setupBtnPortable => 'Ejecutar en Modo Portable';

  @override
  String get setupPortableDesc =>
      'El modo portable no creará accesos directos ni registrará la app en Windows.';

  @override
  String get setupProgressCopied => 'Copiando archivos de programa...';

  @override
  String get setupProgressShortcuts => 'Creando accesos directos...';

  @override
  String get setupProgressRegister => 'Registrando en Windows...';

  @override
  String get setupProgressDone => '¡Instalación completada exitosamente!';

  @override
  String get setupSuccessTitle => '¡Instalación Exitosa!';

  @override
  String get setupSuccessDesc =>
      'Nexo UPLA ha sido instalado y registrado correctamente.';

  @override
  String get setupBtnStart => 'Iniciar Aplicación';

  @override
  String get setupErrorTitle => 'Error de Instalación';

  @override
  String get setupBtnRetry => 'Reintentar';

  @override
  String get setupBtnExit => 'Salir';

  @override
  String get setupCustomization => 'Personalización';

  @override
  String get setupTermsAccept =>
      'He leído y acepto los términos de uso y privacidad';

  @override
  String get setupTermsRequired => 'Debes aceptar los términos para continuar';

  @override
  String get setupOptionDesktop => 'Crear acceso directo en el Escritorio';

  @override
  String get setupOptionStartMenu => 'Crear acceso en el Menú Inicio';

  @override
  String get setupOptionAutoStart => 'Iniciar Nexo con Windows';

  @override
  String get setupOptionAutoStartDesc =>
      'Se abrirá automáticamente al iniciar sesión';

  @override
  String get setupProgressAutoStart => 'Configurando inicio automático...';

  @override
  String get setupBtnBack => 'Atrás';

  @override
  String get setupBtnNext => 'Siguiente';

  @override
  String get setupBtnInstallNow => 'Instalar';

  @override
  String get updTitle => 'Actualizaciones';

  @override
  String get updInstalledVersion => 'Versión instalada';

  @override
  String get updStatusChecking => 'Buscando…';

  @override
  String get updStatusAvailable => 'Disponible';

  @override
  String get updStatusUpToDate => 'Al día';

  @override
  String get updStatusUnknown => 'Sin verificar';

  @override
  String get updCheck => 'Buscar actualizaciones';

  @override
  String get updInstallNow => 'Instalar ahora';

  @override
  String get updDownloadInstall => 'Descargar e instalar';

  @override
  String updAvailableLine(String version) {
    return 'Nexo $version está disponible.';
  }

  @override
  String get updSnackUpToDate => 'Ya tienes la última versión.';

  @override
  String updSnackAvailable(String version) {
    return 'Nueva versión $version disponible.';
  }

  @override
  String get updSnackCheckFailed => 'No se pudo verificar. Revisa tu conexión.';

  @override
  String get updSnackInstallFailed => 'No se pudo iniciar la instalación.';

  @override
  String get updBannerReadyTitle => 'Actualización lista para instalar';

  @override
  String get updBannerAvailableTitle => 'Actualización disponible';

  @override
  String updBannerReadyBody(String version) {
    return 'Toca para instalar Nexo $version.';
  }

  @override
  String updBannerAvailableBody(String version) {
    return 'Toca para descargar Nexo $version.';
  }

  @override
  String get updDismiss => 'Descartar';

  @override
  String get assignmentNoDate => 'Sin fecha de entrega';

  @override
  String get assignmentOverdue => 'Venció';

  @override
  String get assignmentDueToday => 'Vence hoy';

  @override
  String get assignmentDueTomorrow => 'Vence mañana';

  @override
  String assignmentDueInDays(int days) {
    return 'En $days días';
  }

  @override
  String get assignmentEmpty => 'No tienes asignaciones pendientes.';

  @override
  String get widgetNoPendingDebts => 'Sin deudas pendientes';

  @override
  String get widgetUpToDate => '✓ Al día';

  @override
  String widgetOverdue(int d) {
    return 'Vencida hace $d d';
  }

  @override
  String get widgetDueToday => 'Vence hoy';

  @override
  String widgetDueIn(int d, String date) {
    return 'Vence en $d d ($date)';
  }

  @override
  String notifStartsIn(int minutes) {
    return 'Empieza en $minutes minutos';
  }

  @override
  String get notifDueToday => 'vence hoy';

  @override
  String get notifDueTomorrow => 'vence mañana';

  @override
  String notifDueInDays(int days) {
    return 'vence en $days días';
  }

  @override
  String get notifClassesReminder => 'Recordatorio de clases';

  @override
  String notifPendingPayment(String when) {
    return 'Pago pendiente — $when';
  }

  @override
  String get notifPaymentsReminder => 'Recordatorio de pagos';

  @override
  String get prefSameDay => 'El mismo día';

  @override
  String get prefOneDayBefore => '1 día antes';

  @override
  String prefDaysBefore(int d) {
    return '$d días antes';
  }

  @override
  String get prefOneHourBefore => '1 hora antes';

  @override
  String get prefTwoHoursBefore => '2 horas antes';

  @override
  String prefMinBefore(int m) {
    return '$m min antes';
  }

  @override
  String get classOngoing => 'EN CURSO';

  @override
  String get homeNoClassesToday => 'Sin clases hoy';

  @override
  String get homeNextClassTitle => 'PRÓXIMA CLASE';

  @override
  String homeNextClassTomorrowDay(String day) {
    return 'Mañana · $day';
  }

  @override
  String get homeNextClassNow => 'Ahora';

  @override
  String homeNextClassInMin(int m) {
    return 'En $m min';
  }

  @override
  String homeNextClassInHours(int h) {
    return 'En ${h}h';
  }

  @override
  String homeNextClassInHoursMin(int h, int m) {
    return 'En ${h}h ${m}min';
  }

  @override
  String homePendingPaymentsOverdueCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vencidas',
      one: '$count vencida',
    );
    return '$_temp0';
  }

  @override
  String get widgetAssignmentsTitle => 'Tareas';

  @override
  String get widgetAssignmentsSubtitle => 'Próximas a vencer';

  @override
  String get whatsappBannerTitle => 'Únete al canal de Nexo';

  @override
  String get whatsappBannerDesc =>
      'Sigue el canal de WhatsApp para enterarte de novedades, mejoras y avisos importantes sobre Nexo.';

  @override
  String get whatsappBannerFollow => 'Seguir canal';

  @override
  String get whatsappBannerLater => 'Ahora no';

  @override
  String homePendingPaymentsMore(int count) {
    return '+ $count cuotas más';
  }

  @override
  String get termsItemRightsTitle => 'Tus derechos';

  @override
  String get termsItemRightsBody =>
      'Tus datos están en tu dispositivo, así que los controlas tú: puedes revisarlos, actualizarlos desde la Intranet o borrarlos cerrando sesión. Escríbenos desde la sección de soporte para cualquier duda sobre el tratamiento de tus datos.';

  @override
  String get termsHeaderUpdatedPre => 'Cambiamos algo';

  @override
  String get termsUpdatedNotice =>
      'Actualizamos estos términos para explicar mejor qué se queda en tu dispositivo y cómo te avisaremos de futuros cambios. Léelos de nuevo antes de continuar.';

  @override
  String get termsItemDeviceTitle => 'Lo que queda en tu dispositivo';

  @override
  String get termsItemDeviceBody =>
      'Nexo guarda una copia local de tu horario, tus notas y tus pagos para funcionar sin conexión, y programa las notificaciones y los widgets en el propio dispositivo. Todo eso se borra al cerrar sesión.';

  @override
  String get termsItemChangesTitle => 'Cambios en estos términos';

  @override
  String get termsItemChangesBody =>
      'Si cambia algo importante en cómo se tratan tus datos, actualizaremos estos términos y volveremos a mostrártelos antes de que sigas usando la app. Puedes releerlos cuando quieras desde Perfil, en Términos y privacidad.';

  @override
  String termsVersionLine(String version, String date) {
    return 'Versión $version · Actualizado el $date';
  }
}
