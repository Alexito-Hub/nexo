// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Quechua (`qu`).
class AppLocalizationsQu extends AppLocalizations {
  AppLocalizationsQu([String locale = 'qu']) : super(locale);

  @override
  String get tabHome => 'Wasi';

  @override
  String get tabSchedule => 'Pacha';

  @override
  String get tabGrades => 'Yupana';

  @override
  String get tabPayments => 'Qullqi';

  @override
  String get tabTeacher => 'Yachachiq';

  @override
  String get tabCourses => 'Yachay';

  @override
  String get tabProfile => 'Runa';

  @override
  String get titleHome => 'Wasi';

  @override
  String get titleSchedule => 'Pacha';

  @override
  String get titleGrades => 'Yupana';

  @override
  String get titlePayments => 'Qullqi';

  @override
  String get titleProfile => 'Runa';

  @override
  String get titleTeacher => 'Yachachiq';

  @override
  String get titleCourses => 'Kursukuna';

  @override
  String get subtitleCourses => 'Tukuy kursukunayki';

  @override
  String get titleAbout => 'Manta';

  @override
  String get titleTerms => 'Kamachiykuna';

  @override
  String get titleDeveloper => 'Ruwaq';

  @override
  String get titleChangePassword => 'Kichanata wakinchay';

  @override
  String get titleNotifications => 'Willakuykuna';

  @override
  String get subtitlePayments => 'Qullqi qunakuna';

  @override
  String get subtitleTeacher => 'Yachakuqniykikuna';

  @override
  String get language => 'Simi';

  @override
  String get timeFormat => 'Pachap rikuchinan';

  @override
  String get hours24 => '24 pacha';

  @override
  String get hours12 => '12 pacha';

  @override
  String get actionLogout => 'Lluqsiy';

  @override
  String get actionAccept => 'Arí';

  @override
  String get actionCancel => 'Mana';

  @override
  String get actionRetry => 'Kutipay';

  @override
  String get actionClose => 'Wichqay';

  @override
  String get actionCopy => 'Kipipay';

  @override
  String get scheduleDetailTitle => 'Sut\'inchanakuna';

  @override
  String get detailSchedule => 'Pachakuna';

  @override
  String get detailLocation => 'Maypi';

  @override
  String get detailRoom => 'Wasi';

  @override
  String get detailPavilion => 'Pabellón';

  @override
  String weekdayFull(String day) {
    String _temp0 = intl.Intl.selectLogic(day, {
      'mon': 'Killachaw',
      'tue': 'Atipachaw',
      'wed': 'Quyllurchaw',
      'thu': 'Chaskachaw',
      'fri': 'Illapachaw',
      'sat': 'Kuychichaw',
      'sun': 'Intichaw',
      'other': '—',
    });
    return '$_temp0';
  }

  @override
  String weekdayShort(String day) {
    String _temp0 = intl.Intl.selectLogic(day, {
      'mon': 'Kil',
      'tue': 'Ati',
      'wed': 'Quy',
      'thu': 'Cha',
      'fri': 'Illa',
      'sat': 'Kuy',
      'sun': 'Inti',
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
      'morning': 'Allin punchaw',
      'afternoon': 'Allin sukha',
      'evening': 'Allin tuta',
      'other': 'Rimaykullayki',
    });
    return '$_temp0';
  }

  @override
  String get detailBuilding => 'Wasi';

  @override
  String get detailCampus => 'Kancha';

  @override
  String get detailTeacher => 'Yachachiq';

  @override
  String get detailSessions => 'Tinkuykuna';

  @override
  String get detailNotes => 'Qillqakuna';

  @override
  String get detailNrc => 'NRC';

  @override
  String get detailSection => 'Sec.';

  @override
  String get detailLevel => 'Nivel';

  @override
  String get detailToday => 'Kunan';

  @override
  String detailDuration(int minutes) {
    return 'Unaynin';
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
  String get termsHeaderSubtitle => 'Lee y acepta para continuar.';

  @override
  String get termsAcceptNote => 'Al continuar aceptas estos términos.';

  @override
  String get termsAcceptButton => 'Aceptar y continuar';

  @override
  String get termsBrandTitle => 'Bienvenido a Nexo';

  @override
  String get termsBrandBody =>
      'Privacidad primero. Tus datos viven solo en tu dispositivo.';

  @override
  String get termsItemWhatTitle => 'Qué es Nexo';

  @override
  String get termsItemWhatBody =>
      'Aplicación independiente y no oficial, creada por y para estudiantes, que reorganiza tu información académica de la UPLA de forma más clara. No está afiliada ni respaldada por la UPLA.';

  @override
  String get termsItemPrivacyTitle => 'Tus datos y privacidad';

  @override
  String get termsItemPrivacyBody =>
      'Credencialniykikuna hinaspa yachay willakuyniykikunaqa dispositivoykipillam waqaychakun. Nexoqa manam servidorninman nitaq hukkunamanpas apachinchu: UPLA servicionkunamanmi chawpillanpi rin.';

  @override
  String get termsItemSecurityTitle => 'Seguridad';

  @override
  String get termsItemSecurityBody =>
      'El almacenamiento local no está cifrado a nivel de sistema. Úsala solo en dispositivos de tu confianza. Puedes cerrar sesión para borrar credenciales y caché en cualquier momento.';

  @override
  String get termsItemResponsibleTitle => 'Uso responsable';

  @override
  String get termsItemResponsibleBody =>
      'Accede solo a tu propia información con tus propias credenciales. Es un proyecto educativo / de hackathon de ingeniería inversa para uso personal. Úsala conforme a los reglamentos de tu universidad.';

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
  String get docenteLabel => 'YACHACHIQ';

  @override
  String get docenteCodeLabel => 'Yachachiq yupana';

  @override
  String get docenteMetricCursos => 'Yachaykuna';

  @override
  String get docenteMetricAlumnos => 'Yachakuqkuna';

  @override
  String get docenteMetricPeriodo => 'Periodo';

  @override
  String get docenteNoClassesToday => 'Mana kunan yachachinkichu';

  @override
  String get docenteToday => 'Kunan';

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
  String get docenteLoadingClasses => 'Clasesta qapichkan...';

  @override
  String docenteSessionsWeeklyCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sesiones esta semana',
      one: '1 sesión esta semana',
    );
    return 'Yachayniykuna · $_temp0';
  }

  @override
  String get docenteNoClassesRegistered =>
      'Mana yachachinayki qillqasqachu kachkan';

  @override
  String docenteCourseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count yachaykuna',
      one: '$count yachay',
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
      other: '$count yachakuqkuna',
      one: '$count yachakuq',
    );
    return '$_temp0';
  }

  @override
  String get docenteLoadCoursesError =>
      'Mana atikurqachu yachaykunata qapichiyta';

  @override
  String get docenteNoCoursesPeriod =>
      'Mana yachaykuna churapusqachu kay periodopi';

  @override
  String get docenteTabAlumnos => 'Yachakuqkuna';

  @override
  String get docenteTabAsistencia => 'Asistencia';

  @override
  String get docenteTabNotas => 'Yupana';

  @override
  String get docenteNoCode => 'Mana yupana';

  @override
  String docenteSectionPeriod(String seccion, String periodo) {
    return 'Sección $seccion · $periodo';
  }

  @override
  String get docenteNoAlumnosRegistered =>
      'Mana yachakuqkuna qillqasqachu kachkan';

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
  String get docenteNoAlumnosInCourse => 'Mana yachakuqkuna kay yachaypi';

  @override
  String docenteAprobadosCount(String aprobados, String total) {
    return '$aprobados de $total aprobados';
  }

  @override
  String get docenteTapToEdit => 'Llamiy llankapashanapaq →';

  @override
  String get docentePromedioParcial => 'PROMEDIO PARCIAL';

  @override
  String docenteCoursePercentGraded(String percent) {
    return '$percent% del curso\\ya calificado';
  }

  @override
  String get docenteEvalPending => 'PENDIENTE';

  @override
  String get docenteNoAttendanceRecords =>
      'Mana asistencia qillqasqa kachkanchu.';

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
  String get docenteInfoTitle => 'Yachachiq willakuy';

  @override
  String get docenteInfoFieldNombres => 'Sutikuna';

  @override
  String get docenteInfoFieldApellidos => 'Apellidokuna';

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
  String get homeVerifyConnectivity => 'Conexión allin kayninta rikukuy';

  @override
  String get homeMetricPromedio => 'Promedio';

  @override
  String get homeMetricPromedioCiclo => 'Prom. ciclo';

  @override
  String get homeMetricPromedioAcumulado => 'Prom. acum.';

  @override
  String get homeMetricCreditos => 'Créditos';

  @override
  String get homeMetricClasesHoy => 'Kunan yachaykuna';

  @override
  String get homeMetricPorPagar => 'Manu';

  @override
  String get gradesDetailLoadError => 'Mana atikurqachu qapichiyta';

  @override
  String get gradesSustitutorio => 'Sustitutorio';

  @override
  String get gradesNoUnitsYetTitle => 'Manaraq yupanayuq';

  @override
  String get gradesNoUnitsYetSubtitle => 'Lloqsimuspa rikukusunki.';

  @override
  String get gradesEvidenciaConocimiento => 'Yachay rikuchiy';

  @override
  String get gradesEvidenciaDesempeno => 'Desempeño rikuchiy';

  @override
  String get gradesEvidenciaProducto => 'Producto rikuchiy';

  @override
  String get gradesPromedioAcumulado => 'Promedio acumulado';

  @override
  String get gradesNoCreditsData => 'Mana créditos willakuy';

  @override
  String get gradesNoHistoryYet => 'Manaraq ñawpa willakuyniyuq';

  @override
  String get gradesEvolutionByPeriod => 'Evolución por periodo';

  @override
  String get statusInProcess => 'LLANKASHKAN';

  @override
  String get paymentsFilterAll => 'Llapan';

  @override
  String get paymentsNoneInPeriod => 'Mana pagokuna kay periodopi';

  @override
  String homeMoreClassesToday(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+ $count clases astawan kunan',
      one: '+ 1 clase astawan kunan',
    );
    return '$_temp0';
  }

  @override
  String get statusApproved => 'APROBADO';

  @override
  String get statusFailed => 'MANA APROBADO';

  @override
  String get gradesPromedioLabel => 'Promedio';

  @override
  String get gradesParcial1 => 'Parcial 1';

  @override
  String get gradesParcial2 => 'Parcial 2';

  @override
  String get gradesPromedioParcial1 => 'Parcial 1 promedio';

  @override
  String get gradesPromedioParcial2 => 'Parcial 2 promedio';

  @override
  String get gradesPromedioFinal => 'Promedio final';

  @override
  String get gradesPrimerParcial => 'Primer parcial';

  @override
  String get gradesSegundoParcial => 'Segundo parcial';

  @override
  String get gradesPromedioPracticas => 'Prácticas promedio';

  @override
  String get gradesTrabajoInvestigacion => 'Trabajo de investigación';

  @override
  String get gradesExamenParcial => 'Examen parcial';

  @override
  String get gradesExamenComplementario => 'Examen complementario';

  @override
  String get paymentsDownloadSchedulePdf => 'Cronograma uraykachiy (PDF)';

  @override
  String get paymentsTabPending => 'Manaraq pagasqa';

  @override
  String get paymentsTabOverdue => 'Pasasqa';

  @override
  String get paymentsTabFees => 'Tasas';

  @override
  String get paymentsUpToDateTitle => 'Allillan kachkanki!';

  @override
  String get paymentsUpToDateSubtitle => 'Mana cuotakuna kanchu.';

  @override
  String get paymentsNoOverdueTitle => 'Mana pasasqa cuotakuna';

  @override
  String get paymentsNoOverdueSubtitle =>
      'Kusa, mana pasasqa cuotakuna kanchu.';

  @override
  String get paymentVenceHoy => 'KUNAN VENCEN';

  @override
  String get paymentVenceManana => 'Paqarin vencen';

  @override
  String get paymentVenceMananaCaps => 'PAQARIN VENCEN';

  @override
  String get paymentsNoFeesRegistered => 'Mana tasas qillqasqachu';

  @override
  String get paymentsNoHistoryRegistered => 'Mana pagos qillqasqachu';

  @override
  String get paymentDetailCuota => 'Cuota willakuy';

  @override
  String get paymentDetailTasa => 'Tasa willakuy';

  @override
  String get paymentDetailPago => 'Pago willakuy';

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
  String get profileStudentCode => 'Yachakuq yupana';

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
  String get profileStatusNotEnrolled => 'Mana matriculado';

  @override
  String get profileStatusEnrolled => 'Matriculado';

  @override
  String get profileAcademicInfo => 'Yachay willakuy';

  @override
  String get pdfExportLoadConstanciaError =>
      'Mana constanciata qapichiyta atikunchu.';

  @override
  String get pdfExportLoadCronogramaError =>
      'Mana cronogramata qapichiyta atikunchu.';

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
  String get paymentsLoadError => 'Mana atikurqachu qapichiyta';

  @override
  String paymentDaysOverdue(String days) {
    return 'Pasasqa $days d.';
  }

  @override
  String paymentDaysLeft(String days) {
    return '$days punchawpi';
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
  String get setupTitle => '¡Allillam chayamunki Nexo UPLA-man!';

  @override
  String get setupSubtitle =>
      'Tariparkanchikmi kay llikachata hawamanta purichichkanki.';

  @override
  String get setupBtnInstall => 'Antañiqichaypi churanay';

  @override
  String get setupBtnPortable => 'Portable nisqapi purichiy';

  @override
  String get setupPortableDesc =>
      'Portable nisqaqa manam suyukunata paqarichinqachu ni Windows-man riqsichinqachu.';

  @override
  String get setupProgressCopied => 'Imakuna patachaypi churanayta copiaq...';

  @override
  String get setupProgressShortcuts => 'Sutikuna paqarichiq...';

  @override
  String get setupProgressRegister => 'Windows llikaman riqsichiy...';

  @override
  String get setupProgressDone => '¡Allillam churanay tukusqa!';

  @override
  String get setupSuccessTitle => '¡Tukusqa Churanay!';

  @override
  String get setupSuccessDesc =>
      'Nexo UPLA allillam antañiqichaypi churasqa kachkan.';

  @override
  String get setupBtnStart => 'Llikachata qallariy';

  @override
  String get setupErrorTitle => 'Churanaypi Pantay';

  @override
  String get setupBtnRetry => 'Musuqmanta ruray';

  @override
  String get setupBtnExit => 'Lluqsiy';

  @override
  String get setupCustomization => 'Kikinpaq ruray';

  @override
  String get setupTermsAccept => 'Ñawirini, arí nini kay kamachiykunata';

  @override
  String get setupTermsRequired =>
      'Kamachiykunata arí ninayki tiyan hinaruranaykiraq';

  @override
  String get setupOptionDesktop => 'Escritorio-pi ataqu churay';

  @override
  String get setupOptionStartMenu => 'Menú Inicio-pi churay';

  @override
  String get setupOptionAutoStart => 'Windows-wan Nexo qallariy';

  @override
  String get setupOptionAutoStartDesc =>
      'Kikillanmanta kichakamunqa sesión qallarispayki';

  @override
  String get setupProgressAutoStart => 'Kikillan qallariy churaq...';

  @override
  String get setupBtnBack => 'Ñawpa';

  @override
  String get setupBtnNext => 'Qatiq';

  @override
  String get setupBtnInstallNow => 'Churay';

  @override
  String get updTitle => 'Musuqyachiykuna';

  @override
  String get updInstalledVersion => 'Churasqa versión';

  @override
  String get updStatusChecking => 'Maskaspa…';

  @override
  String get updStatusAvailable => 'Kanmi';

  @override
  String get updStatusUpToDate => 'Musuqmi';

  @override
  String get updStatusUnknown => 'Mana qhawasqa';

  @override
  String get updCheck => 'Musuqyachiykuna maskay';

  @override
  String get updInstallNow => 'Kunan churay';

  @override
  String get updDownloadInstall => 'Uraqachiy hinaspa churay';

  @override
  String updAvailableLine(String version) {
    return 'Nexo $version kanmi.';
  }

  @override
  String get updSnackUpToDate => 'Qhipa versionniykiña kanmi.';

  @override
  String updSnackAvailable(String version) {
    return 'Musuq versión $version kanmi.';
  }

  @override
  String get updSnackCheckFailed =>
      'Mana qhawayta atikunchu. Tinkiyniykita qhaway.';

  @override
  String get updSnackInstallFailed => 'Mana churayta qallariyta atikunchu.';

  @override
  String get updBannerReadyTitle => 'Musuqyachiy churanapaq allinña';

  @override
  String get updBannerAvailableTitle => 'Musuqyachiy kanmi';

  @override
  String updBannerReadyBody(String version) {
    return 'Nexo $version churanaykipaq llamiy.';
  }

  @override
  String updBannerAvailableBody(String version) {
    return 'Nexo $version uraqachinaykipaq llamiy.';
  }

  @override
  String get updDismiss => 'Wikuy';

  @override
  String get assignmentNoDate => 'Mana kachkanchu';

  @override
  String get assignmentOverdue => 'Pasaq';

  @override
  String get assignmentDueToday => 'Kunan p\'unchaw';

  @override
  String get assignmentDueTomorrow => 'Paqarin p\'unchaw';

  @override
  String assignmentDueInDays(int days) {
    return '$days p\'unchawpi';
  }

  @override
  String get assignmentEmpty => 'Mana ruranayki kanchu.';

  @override
  String get widgetNoPendingDebts => 'Mana manu kanchu';

  @override
  String get widgetUpToDate => '✓ P\'unchawninpi';

  @override
  String widgetOverdue(int d) {
    return '$d p\'unchaw pasasqa';
  }

  @override
  String get widgetDueToday => 'Kunan p\'unchaw';

  @override
  String widgetDueIn(int d, String date) {
    return '$d p\'unchawpi ($date)';
  }

  @override
  String notifStartsIn(int minutes) {
    return '$minutes minutopi qallarin';
  }

  @override
  String get notifDueToday => 'kunan p\'unchaw';

  @override
  String get notifDueTomorrow => 'paqarin p\'unchaw';

  @override
  String notifDueInDays(int days) {
    return '$days p\'unchawpi';
  }

  @override
  String get notifClassesReminder => 'Yachaykuna yuyarichiy';

  @override
  String notifPendingPayment(String when) {
    return 'Qullqi quna — $when';
  }

  @override
  String get notifPaymentsReminder => 'Qullqi quna yuyarichiy';

  @override
  String get prefSameDay => 'Kikin p\'unchawpi';

  @override
  String get prefOneDayBefore => '1 p\'unchaw ñawpaqta';

  @override
  String prefDaysBefore(int d) {
    return '$d p\'unchaw ñawpaqta';
  }

  @override
  String get prefOneHourBefore => '1 pacha ñawpaqta';

  @override
  String get prefTwoHoursBefore => '2 pacha ñawpaqta';

  @override
  String prefMinBefore(int m) {
    return '$m min ñawpaqta';
  }

  @override
  String get classOngoing => 'QALLARISQA';

  @override
  String get homeNoClassesToday => 'Mana yachaykuna kanchu';

  @override
  String get homeNextClassTitle => 'QAMUQ YACHAY';

  @override
  String homeNextClassTomorrowDay(String day) {
    return 'Paqarin · $day';
  }

  @override
  String get homeNextClassNow => 'Kunan';

  @override
  String homeNextClassInMin(int m) {
    return '$m min ukhupi';
  }

  @override
  String homeNextClassInHours(int h) {
    return '${h}h ukhupi';
  }

  @override
  String homeNextClassInHoursMin(int h, int m) {
    return '${h}h ${m}min ukhupi';
  }

  @override
  String homePendingPaymentsOverdueCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pasasqa',
      one: '$count pasasqa',
    );
    return '$_temp0';
  }

  @override
  String get widgetAssignmentsTitle => 'Ruranakuna';

  @override
  String get widgetAssignmentsSubtitle => 'Pisi p\'unchawkunallañam puchun';

  @override
  String get whatsappBannerTitle => 'Nexo waqyayman hukllawakuy';

  @override
  String get whatsappBannerDesc =>
      'WhatsApp waqyayta qatiy Nexomanta musuq willakuykunata yachanaykipaq.';

  @override
  String get whatsappBannerFollow => 'Waqyayta qatiy';

  @override
  String get whatsappBannerLater => 'Kunanqa manam';

  @override
  String homePendingPaymentsMore(int count) {
    return '+ $count tasakuna';
  }

  @override
  String get termsItemRightsTitle => 'Derechoykikuna';

  @override
  String get termsItemRightsBody =>
      'Willasqaykikunata qawanki, allichanki utaq pichanki, hinaspa mayqin pachapipas Ajustespi permisoykita qichunki. Soporte sectionmanta qillqamuwayku.';

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
