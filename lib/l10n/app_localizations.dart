import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_qu.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('qu'),
  ];

  /// Etiqueta de la pestaña Inicio
  ///
  /// In es, this message translates to:
  /// **'Inicio'**
  String get tabHome;

  /// Etiqueta de la pestaña Horario
  ///
  /// In es, this message translates to:
  /// **'Horario'**
  String get tabSchedule;

  /// Etiqueta de la pestaña Notas
  ///
  /// In es, this message translates to:
  /// **'Notas'**
  String get tabGrades;

  /// Etiqueta de la pestaña Pagos
  ///
  /// In es, this message translates to:
  /// **'Pagos'**
  String get tabPayments;

  /// Etiqueta de la pestaña Docente
  ///
  /// In es, this message translates to:
  /// **'Docente'**
  String get tabTeacher;

  /// Etiqueta de la pestaña Cursos del docente
  ///
  /// In es, this message translates to:
  /// **'Cursos'**
  String get tabCourses;

  /// Etiqueta de la pestaña Perfil
  ///
  /// In es, this message translates to:
  /// **'Perfil'**
  String get tabProfile;

  /// No description provided for @titleHome.
  ///
  /// In es, this message translates to:
  /// **'Inicio'**
  String get titleHome;

  /// No description provided for @titleSchedule.
  ///
  /// In es, this message translates to:
  /// **'Horario'**
  String get titleSchedule;

  /// No description provided for @titleGrades.
  ///
  /// In es, this message translates to:
  /// **'Notas'**
  String get titleGrades;

  /// No description provided for @titlePayments.
  ///
  /// In es, this message translates to:
  /// **'Pagos'**
  String get titlePayments;

  /// No description provided for @titleProfile.
  ///
  /// In es, this message translates to:
  /// **'Perfil'**
  String get titleProfile;

  /// No description provided for @titleTeacher.
  ///
  /// In es, this message translates to:
  /// **'Docente'**
  String get titleTeacher;

  /// No description provided for @titleCourses.
  ///
  /// In es, this message translates to:
  /// **'Mis cursos'**
  String get titleCourses;

  /// No description provided for @subtitleCourses.
  ///
  /// In es, this message translates to:
  /// **'Asignaturas que dictas'**
  String get subtitleCourses;

  /// No description provided for @titleAbout.
  ///
  /// In es, this message translates to:
  /// **'Acerca de Nexo'**
  String get titleAbout;

  /// No description provided for @titleTerms.
  ///
  /// In es, this message translates to:
  /// **'Términos y privacidad'**
  String get titleTerms;

  /// No description provided for @titleDeveloper.
  ///
  /// In es, this message translates to:
  /// **'Desarrollador'**
  String get titleDeveloper;

  /// No description provided for @titleChangePassword.
  ///
  /// In es, this message translates to:
  /// **'Cambiar contraseña'**
  String get titleChangePassword;

  /// No description provided for @titleNotifications.
  ///
  /// In es, this message translates to:
  /// **'Notificaciones'**
  String get titleNotifications;

  /// No description provided for @subtitlePayments.
  ///
  /// In es, this message translates to:
  /// **'Cuotas, tasas e historial'**
  String get subtitlePayments;

  /// No description provided for @subtitleTeacher.
  ///
  /// In es, this message translates to:
  /// **'Tus cursos y estudiantes'**
  String get subtitleTeacher;

  /// No description provided for @language.
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get language;

  /// No description provided for @timeFormat.
  ///
  /// In es, this message translates to:
  /// **'Formato de hora'**
  String get timeFormat;

  /// No description provided for @hours24.
  ///
  /// In es, this message translates to:
  /// **'24 horas'**
  String get hours24;

  /// No description provided for @hours12.
  ///
  /// In es, this message translates to:
  /// **'12 horas'**
  String get hours12;

  /// No description provided for @actionLogout.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get actionLogout;

  /// No description provided for @actionAccept.
  ///
  /// In es, this message translates to:
  /// **'Aceptar'**
  String get actionAccept;

  /// No description provided for @actionCancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get actionCancel;

  /// No description provided for @actionRetry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get actionRetry;

  /// No description provided for @actionClose.
  ///
  /// In es, this message translates to:
  /// **'Cerrar'**
  String get actionClose;

  /// No description provided for @actionCopy.
  ///
  /// In es, this message translates to:
  /// **'Copiar'**
  String get actionCopy;

  /// AppBar del detalle de una clase
  ///
  /// In es, this message translates to:
  /// **'Detalle de la clase'**
  String get scheduleDetailTitle;

  /// No description provided for @detailSchedule.
  ///
  /// In es, this message translates to:
  /// **'Horario'**
  String get detailSchedule;

  /// No description provided for @detailLocation.
  ///
  /// In es, this message translates to:
  /// **'Ubicación'**
  String get detailLocation;

  /// No description provided for @detailRoom.
  ///
  /// In es, this message translates to:
  /// **'Aula'**
  String get detailRoom;

  /// No description provided for @detailPavilion.
  ///
  /// In es, this message translates to:
  /// **'Pabellón'**
  String get detailPavilion;

  /// No description provided for @weekdayFull.
  ///
  /// In es, this message translates to:
  /// **'{day, select, mon{Lunes} tue{Martes} wed{Miércoles} thu{Jueves} fri{Viernes} sat{Sábado} sun{Domingo} other{—}}'**
  String weekdayFull(String day);

  /// No description provided for @weekdayShort.
  ///
  /// In es, this message translates to:
  /// **'{day, select, mon{Lun} tue{Mar} wed{Mié} thu{Jue} fri{Vie} sat{Sáb} sun{Dom} other{—}}'**
  String weekdayShort(String day);

  /// No description provided for @monthShort.
  ///
  /// In es, this message translates to:
  /// **'{month, select, jan{Ene} feb{Feb} mar{Mar} apr{Abr} may{May} jun{Jun} jul{Jul} aug{Ago} sep{Sep} oct{Oct} nov{Nov} dec{Dic} other{—}}'**
  String monthShort(String month);

  /// No description provided for @timeGreeting.
  ///
  /// In es, this message translates to:
  /// **'{period, select, morning{Buenos días} afternoon{Buenas tardes} evening{Buenas noches} other{Hola}}'**
  String timeGreeting(String period);

  /// No description provided for @detailBuilding.
  ///
  /// In es, this message translates to:
  /// **'Local'**
  String get detailBuilding;

  /// No description provided for @detailCampus.
  ///
  /// In es, this message translates to:
  /// **'Sede'**
  String get detailCampus;

  /// No description provided for @detailTeacher.
  ///
  /// In es, this message translates to:
  /// **'Docente'**
  String get detailTeacher;

  /// No description provided for @detailSessions.
  ///
  /// In es, this message translates to:
  /// **'Sesiones'**
  String get detailSessions;

  /// No description provided for @detailNotes.
  ///
  /// In es, this message translates to:
  /// **'Observaciones'**
  String get detailNotes;

  /// No description provided for @detailNrc.
  ///
  /// In es, this message translates to:
  /// **'NRC'**
  String get detailNrc;

  /// No description provided for @detailSection.
  ///
  /// In es, this message translates to:
  /// **'Sec.'**
  String get detailSection;

  /// No description provided for @detailLevel.
  ///
  /// In es, this message translates to:
  /// **'Nivel'**
  String get detailLevel;

  /// No description provided for @detailToday.
  ///
  /// In es, this message translates to:
  /// **'HOY'**
  String get detailToday;

  /// Duración acumulada de la clase
  ///
  /// In es, this message translates to:
  /// **'Duración total: {minutes} minutos'**
  String detailDuration(int minutes);

  /// No description provided for @tabTeams.
  ///
  /// In es, this message translates to:
  /// **'Teams'**
  String get tabTeams;

  /// No description provided for @settingsTitle.
  ///
  /// In es, this message translates to:
  /// **'Configuración'**
  String get settingsTitle;

  /// No description provided for @settingsAppearance.
  ///
  /// In es, this message translates to:
  /// **'Apariencia'**
  String get settingsAppearance;

  /// No description provided for @settingsPalette.
  ///
  /// In es, this message translates to:
  /// **'Paleta'**
  String get settingsPalette;

  /// No description provided for @settingsSystem.
  ///
  /// In es, this message translates to:
  /// **'Sistema'**
  String get settingsSystem;

  /// No description provided for @settingsSystemDesc.
  ///
  /// In es, this message translates to:
  /// **'Sigue el modo claro/oscuro de tu dispositivo'**
  String get settingsSystemDesc;

  /// No description provided for @settingsActive.
  ///
  /// In es, this message translates to:
  /// **'Activa'**
  String get settingsActive;

  /// No description provided for @settingsNotificationsSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Recordatorios y alertas'**
  String get settingsNotificationsSubtitle;

  /// No description provided for @notificationsIntro.
  ///
  /// In es, this message translates to:
  /// **'Recibe avisos de tus clases, pagos y notas. Personaliza qué llega y con cuánta anticipación.'**
  String get notificationsIntro;

  /// No description provided for @notificationsClassesTitle.
  ///
  /// In es, this message translates to:
  /// **'Clases'**
  String get notificationsClassesTitle;

  /// No description provided for @notificationsClassesSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Aviso antes de cada clase'**
  String get notificationsClassesSubtitle;

  /// No description provided for @notificationsPaymentsTitle.
  ///
  /// In es, this message translates to:
  /// **'Pagos'**
  String get notificationsPaymentsTitle;

  /// No description provided for @notificationsPaymentsSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Aviso antes de cada vencimiento'**
  String get notificationsPaymentsSubtitle;

  /// No description provided for @notificationsNotifyMe.
  ///
  /// In es, this message translates to:
  /// **'Avisarme'**
  String get notificationsNotifyMe;

  /// No description provided for @notificationsPaymentHour.
  ///
  /// In es, this message translates to:
  /// **'Hora del aviso: {hour}:00'**
  String notificationsPaymentHour(String hour);

  /// No description provided for @notificationsGradesTitle.
  ///
  /// In es, this message translates to:
  /// **'Notas'**
  String get notificationsGradesTitle;

  /// No description provided for @notificationsGradesSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Aviso cuando se publique una nota nueva'**
  String get notificationsGradesSubtitle;

  /// No description provided for @notificationsEnableTitle.
  ///
  /// In es, this message translates to:
  /// **'Habilitar notificaciones'**
  String get notificationsEnableTitle;

  /// No description provided for @notificationsEnabledLabel.
  ///
  /// In es, this message translates to:
  /// **'Activadas'**
  String get notificationsEnabledLabel;

  /// No description provided for @notificationsDisabledLabel.
  ///
  /// In es, this message translates to:
  /// **'Desactivadas'**
  String get notificationsDisabledLabel;

  /// No description provided for @notificationsInfoNote.
  ///
  /// In es, this message translates to:
  /// **'Las clases y pagos se programan en tu dispositivo. Las notas se detectan al abrir la app y sincronizar.'**
  String get notificationsInfoNote;

  /// No description provided for @homeTodayTitle.
  ///
  /// In es, this message translates to:
  /// **'Hoy'**
  String get homeTodayTitle;

  /// No description provided for @homeScheduleLoadError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo cargar el horario'**
  String get homeScheduleLoadError;

  /// No description provided for @homeSeeFullWeek.
  ///
  /// In es, this message translates to:
  /// **'Ver semana completa'**
  String get homeSeeFullWeek;

  /// No description provided for @homePendingPaymentsTitle.
  ///
  /// In es, this message translates to:
  /// **'Pagos pendientes'**
  String get homePendingPaymentsTitle;

  /// No description provided for @homePaymentsLoadError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo cargar los pagos'**
  String get homePaymentsLoadError;

  /// No description provided for @homeSeeAllPayments.
  ///
  /// In es, this message translates to:
  /// **'Ver todos los pagos'**
  String get homeSeeAllPayments;

  /// No description provided for @schedulePeriodActive.
  ///
  /// In es, this message translates to:
  /// **'Periodo activo'**
  String get schedulePeriodActive;

  /// No description provided for @schedulePeriodActiveCount.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =0{Periodo activo} =1{Periodo activo · {count} clase} other{Periodo activo · {count} clases}}'**
  String schedulePeriodActiveCount(int count);

  /// No description provided for @scheduleErrorTitle.
  ///
  /// In es, this message translates to:
  /// **'Error'**
  String get scheduleErrorTitle;

  /// No description provided for @scheduleLoadError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo cargar el horario'**
  String get scheduleLoadError;

  /// No description provided for @scheduleNoClassesTitle.
  ///
  /// In es, this message translates to:
  /// **'Sin clases'**
  String get scheduleNoClassesTitle;

  /// No description provided for @scheduleNoClassesSubtitle.
  ///
  /// In es, this message translates to:
  /// **'No hay clases registradas'**
  String get scheduleNoClassesSubtitle;

  /// No description provided for @scheduleToggleWeek.
  ///
  /// In es, this message translates to:
  /// **'Semana'**
  String get scheduleToggleWeek;

  /// No description provided for @scheduleToggleList.
  ///
  /// In es, this message translates to:
  /// **'Lista'**
  String get scheduleToggleList;

  /// No description provided for @scheduleNoClassesScheduled.
  ///
  /// In es, this message translates to:
  /// **'Sin clases programadas'**
  String get scheduleNoClassesScheduled;

  /// No description provided for @gradesTitle.
  ///
  /// In es, this message translates to:
  /// **'Notas'**
  String get gradesTitle;

  /// No description provided for @gradesSubtitleNoPeriod.
  ///
  /// In es, this message translates to:
  /// **'Boleta de notas'**
  String get gradesSubtitleNoPeriod;

  /// No description provided for @gradesSubtitleUnits.
  ///
  /// In es, this message translates to:
  /// **'Por unidades · {period}'**
  String gradesSubtitleUnits(String period);

  /// No description provided for @gradesSubtitlePartials.
  ///
  /// In es, this message translates to:
  /// **'Por parciales · {period}'**
  String gradesSubtitlePartials(String period);

  /// No description provided for @gradesSelectPeriod.
  ///
  /// In es, this message translates to:
  /// **'Selecciona un periodo'**
  String get gradesSelectPeriod;

  /// No description provided for @gradesSubjects.
  ///
  /// In es, this message translates to:
  /// **'Asignaturas'**
  String get gradesSubjects;

  /// No description provided for @gradesLoadError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo cargar la boleta'**
  String get gradesLoadError;

  /// No description provided for @gradesNoNotesTitle.
  ///
  /// In es, this message translates to:
  /// **'Sin notas en este periodo'**
  String get gradesNoNotesTitle;

  /// No description provided for @gradesNoNotesSubtitleNewModel.
  ///
  /// In es, this message translates to:
  /// **'La boleta por unidades aplica desde 2026-1.'**
  String get gradesNoNotesSubtitleNewModel;

  /// No description provided for @gradesSubjectsWithPeriod.
  ///
  /// In es, this message translates to:
  /// **'Asignaturas · {period}'**
  String gradesSubjectsWithPeriod(String period);

  /// No description provided for @gradesCoursesCount.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{{count} curso} other{{count} cursos}}'**
  String gradesCoursesCount(int count);

  /// No description provided for @teamsSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Tus asignaturas y tareas de Microsoft 365'**
  String get teamsSubtitle;

  /// No description provided for @teamsDisconnect.
  ///
  /// In es, this message translates to:
  /// **'Desconectar'**
  String get teamsDisconnect;

  /// No description provided for @teamsMySubjects.
  ///
  /// In es, this message translates to:
  /// **'Mis asignaturas'**
  String get teamsMySubjects;

  /// No description provided for @teamsAssignments.
  ///
  /// In es, this message translates to:
  /// **'Tareas'**
  String get teamsAssignments;

  /// No description provided for @teamsLoadError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo cargar'**
  String get teamsLoadError;

  /// No description provided for @teamsConnectTitle.
  ///
  /// In es, this message translates to:
  /// **'Conecta tu cuenta de Microsoft'**
  String get teamsConnectTitle;

  /// No description provided for @teamsConnectSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Para ver tus clases y tareas de Teams'**
  String get teamsConnectSubtitle;

  /// No description provided for @teamsConnectBody.
  ///
  /// In es, this message translates to:
  /// **'Inicia sesión con tu cuenta institucional de Microsoft 365. Te daremos un código para confirmarlo en el navegador.'**
  String get teamsConnectBody;

  /// No description provided for @teamsConnectButton.
  ///
  /// In es, this message translates to:
  /// **'Conectar con Microsoft'**
  String get teamsConnectButton;

  /// No description provided for @teamsDeviceCodeGenerating.
  ///
  /// In es, this message translates to:
  /// **'Generando código…'**
  String get teamsDeviceCodeGenerating;

  /// No description provided for @teamsDeviceCodeConfirmTitle.
  ///
  /// In es, this message translates to:
  /// **'Confirma en el navegador'**
  String get teamsDeviceCodeConfirmTitle;

  /// No description provided for @teamsDeviceCodeConfirmSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Esperando que autorices la app…'**
  String get teamsDeviceCodeConfirmSubtitle;

  /// No description provided for @teamsDeviceCodeStep1Prefix.
  ///
  /// In es, this message translates to:
  /// **'Abre '**
  String get teamsDeviceCodeStep1Prefix;

  /// No description provided for @teamsCopyLink.
  ///
  /// In es, this message translates to:
  /// **'Copiar enlace'**
  String get teamsCopyLink;

  /// No description provided for @teamsLinkCopied.
  ///
  /// In es, this message translates to:
  /// **'Enlace copiado'**
  String get teamsLinkCopied;

  /// No description provided for @teamsDeviceCodeStep2Label.
  ///
  /// In es, this message translates to:
  /// **'Introduce este código:'**
  String get teamsDeviceCodeStep2Label;

  /// No description provided for @teamsDeviceCodeAutoRefresh.
  ///
  /// In es, this message translates to:
  /// **'Esto se actualizará solo cuando termines.'**
  String get teamsDeviceCodeAutoRefresh;

  /// No description provided for @teamsCodeCopied.
  ///
  /// In es, this message translates to:
  /// **'Código copiado'**
  String get teamsCodeCopied;

  /// No description provided for @actionShow.
  ///
  /// In es, this message translates to:
  /// **'Mostrar'**
  String get actionShow;

  /// No description provided for @actionHide.
  ///
  /// In es, this message translates to:
  /// **'Ocultar'**
  String get actionHide;

  /// No description provided for @actionSkip.
  ///
  /// In es, this message translates to:
  /// **'Saltar'**
  String get actionSkip;

  /// No description provided for @actionNext.
  ///
  /// In es, this message translates to:
  /// **'Siguiente'**
  String get actionNext;

  /// No description provided for @validationRequired.
  ///
  /// In es, this message translates to:
  /// **'Requerido'**
  String get validationRequired;

  /// No description provided for @changePasswordSuccess.
  ///
  /// In es, this message translates to:
  /// **'Contraseña actualizada correctamente.'**
  String get changePasswordSuccess;

  /// No description provided for @changePasswordHeader.
  ///
  /// In es, this message translates to:
  /// **'Define tu nueva contraseña'**
  String get changePasswordHeader;

  /// No description provided for @changePasswordSubheader.
  ///
  /// In es, this message translates to:
  /// **'Se aplicará en todos los servicios institucionales que usen tu cuenta UPLA.'**
  String get changePasswordSubheader;

  /// No description provided for @changePasswordCurrentLabel.
  ///
  /// In es, this message translates to:
  /// **'Contraseña actual'**
  String get changePasswordCurrentLabel;

  /// No description provided for @changePasswordNewLabel.
  ///
  /// In es, this message translates to:
  /// **'Nueva contraseña'**
  String get changePasswordNewLabel;

  /// No description provided for @changePasswordRepeatLabel.
  ///
  /// In es, this message translates to:
  /// **'Repetir nueva contraseña'**
  String get changePasswordRepeatLabel;

  /// No description provided for @changePasswordMinChars.
  ///
  /// In es, this message translates to:
  /// **'Mínimo {min} caracteres'**
  String changePasswordMinChars(int min);

  /// No description provided for @changePasswordMustBeDifferent.
  ///
  /// In es, this message translates to:
  /// **'Debe ser distinta a la actual'**
  String get changePasswordMustBeDifferent;

  /// No description provided for @changePasswordNoMatch.
  ///
  /// In es, this message translates to:
  /// **'No coincide'**
  String get changePasswordNoMatch;

  /// No description provided for @changePasswordUpdateButton.
  ///
  /// In es, this message translates to:
  /// **'Actualizar contraseña'**
  String get changePasswordUpdateButton;

  /// No description provided for @loginWelcomeBack.
  ///
  /// In es, this message translates to:
  /// **'Bienvenido de nuevo'**
  String get loginWelcomeBack;

  /// No description provided for @loginIntro.
  ///
  /// In es, this message translates to:
  /// **'Inicia sesión con tu cuenta institucional. Guardaremos tu sesión para que no tengas que volver a entrar.'**
  String get loginIntro;

  /// No description provided for @loginUserLabel.
  ///
  /// In es, this message translates to:
  /// **'Código o DNI'**
  String get loginUserLabel;

  /// No description provided for @loginUserRequired.
  ///
  /// In es, this message translates to:
  /// **'Ingresa tu usuario'**
  String get loginUserRequired;

  /// No description provided for @loginPasswordLabel.
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get loginPasswordLabel;

  /// No description provided for @loginPasswordRequired.
  ///
  /// In es, this message translates to:
  /// **'Ingresa tu contraseña'**
  String get loginPasswordRequired;

  /// No description provided for @loginCapsLockOn.
  ///
  /// In es, this message translates to:
  /// **'Bloq Mayús está activado'**
  String get loginCapsLockOn;

  /// No description provided for @loginSubmit.
  ///
  /// In es, this message translates to:
  /// **'Iniciar sesión'**
  String get loginSubmit;

  /// No description provided for @loginDeviceOnly.
  ///
  /// In es, this message translates to:
  /// **'Tus credenciales se guardan solo en este dispositivo'**
  String get loginDeviceOnly;

  /// No description provided for @loginBrandTagline.
  ///
  /// In es, this message translates to:
  /// **'Tu vida académica UPLA,\nen un solo lugar.'**
  String get loginBrandTagline;

  /// No description provided for @loginFeatureSchedule.
  ///
  /// In es, this message translates to:
  /// **'Horario y próxima clase al instante'**
  String get loginFeatureSchedule;

  /// No description provided for @loginFeaturePayments.
  ///
  /// In es, this message translates to:
  /// **'Pagos, vencimientos y alertas'**
  String get loginFeaturePayments;

  /// No description provided for @loginFeatureGrades.
  ///
  /// In es, this message translates to:
  /// **'Notas y progreso académico'**
  String get loginFeatureGrades;

  /// No description provided for @loginFeatureWidgets.
  ///
  /// In es, this message translates to:
  /// **'Widgets en tu pantalla de inicio'**
  String get loginFeatureWidgets;

  /// No description provided for @onboardingTitleWelcome.
  ///
  /// In es, this message translates to:
  /// **'Bienvenido a Nexo'**
  String get onboardingTitleWelcome;

  /// No description provided for @onboardingBodyWelcome.
  ///
  /// In es, this message translates to:
  /// **'Tu vida académica UPLA reimaginada: clara, rápida y siempre contigo.'**
  String get onboardingBodyWelcome;

  /// No description provided for @onboardingTitleSchedule.
  ///
  /// In es, this message translates to:
  /// **'Horario inteligente'**
  String get onboardingTitleSchedule;

  /// No description provided for @onboardingBodySchedule.
  ///
  /// In es, this message translates to:
  /// **'Tus clases de hoy y la próxima clase con cuenta regresiva. Teoría y práctica del mismo curso, unidas.'**
  String get onboardingBodySchedule;

  /// No description provided for @onboardingTitlePayments.
  ///
  /// In es, this message translates to:
  /// **'Pagos sin sorpresas'**
  String get onboardingTitlePayments;

  /// No description provided for @onboardingBodyPayments.
  ///
  /// In es, this message translates to:
  /// **'Cuotas pendientes, vencidas, tasas e historial. Sabrás cuánto y cuándo pagar sin entrar al portal.'**
  String get onboardingBodyPayments;

  /// No description provided for @onboardingTitleWidgets.
  ///
  /// In es, this message translates to:
  /// **'Widgets en tu pantalla'**
  String get onboardingTitleWidgets;

  /// No description provided for @onboardingBodyWidgets.
  ///
  /// In es, this message translates to:
  /// **'Agrega widgets a la pantalla de inicio de Android: próxima clase, pagos y tu promedio, de un vistazo.'**
  String get onboardingBodyWidgets;

  /// No description provided for @onboardingStart.
  ///
  /// In es, this message translates to:
  /// **'Empezar'**
  String get onboardingStart;

  /// No description provided for @wifiTitle.
  ///
  /// In es, this message translates to:
  /// **'Wi-Fi institucional'**
  String get wifiTitle;

  /// No description provided for @wifiSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Misma cuenta institucional UPLA'**
  String get wifiSubtitle;

  /// No description provided for @wifiUserLabel.
  ///
  /// In es, this message translates to:
  /// **'USUARIO'**
  String get wifiUserLabel;

  /// No description provided for @wifiPasswordLabel.
  ///
  /// In es, this message translates to:
  /// **'CONTRASEÑA'**
  String get wifiPasswordLabel;

  /// No description provided for @wifiUserCopied.
  ///
  /// In es, this message translates to:
  /// **'Usuario copiado'**
  String get wifiUserCopied;

  /// No description provided for @wifiPasswordCopied.
  ///
  /// In es, this message translates to:
  /// **'Contraseña copiada'**
  String get wifiPasswordCopied;

  /// No description provided for @actionSave.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get actionSave;

  /// No description provided for @actionCodeCopied.
  ///
  /// In es, this message translates to:
  /// **'Código copiado'**
  String get actionCodeCopied;

  /// No description provided for @profileSettingsSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Apariencia, idioma, hora y notificaciones'**
  String get profileSettingsSubtitle;

  /// No description provided for @profileChangePasswordSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Para tu cuenta institucional UPLA'**
  String get profileChangePasswordSubtitle;

  /// No description provided for @profileAboutSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Versión {version}'**
  String profileAboutSubtitle(String version);

  /// No description provided for @logoutConfirmTitle.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get logoutConfirmTitle;

  /// No description provided for @logoutConfirmBody.
  ///
  /// In es, this message translates to:
  /// **'¿Quieres salir de tu cuenta?'**
  String get logoutConfirmBody;

  /// No description provided for @docenteChangeDate.
  ///
  /// In es, this message translates to:
  /// **'Cambiar'**
  String get docenteChangeDate;

  /// No description provided for @docenteSaveAttendance.
  ///
  /// In es, this message translates to:
  /// **'Guardar asistencia'**
  String get docenteSaveAttendance;

  /// No description provided for @docenteAttendanceSaved.
  ///
  /// In es, this message translates to:
  /// **'Asistencia guardada'**
  String get docenteAttendanceSaved;

  /// No description provided for @docenteAttendanceError.
  ///
  /// In es, this message translates to:
  /// **'Error: {error}'**
  String docenteAttendanceError(String error);

  /// No description provided for @docenteGradeLabel.
  ///
  /// In es, this message translates to:
  /// **'Nota (0 - 20)'**
  String get docenteGradeLabel;

  /// No description provided for @docenteGradeEnter.
  ///
  /// In es, this message translates to:
  /// **'Ingresa una nota'**
  String get docenteGradeEnter;

  /// No description provided for @docenteGradeInvalidNumber.
  ///
  /// In es, this message translates to:
  /// **'Número inválido'**
  String get docenteGradeInvalidNumber;

  /// No description provided for @docenteGradeRange.
  ///
  /// In es, this message translates to:
  /// **'Entre 0 y 20'**
  String get docenteGradeRange;

  /// No description provided for @termsHeaderPre.
  ///
  /// In es, this message translates to:
  /// **'Antes de empezar'**
  String get termsHeaderPre;

  /// No description provided for @termsHeaderTitle.
  ///
  /// In es, this message translates to:
  /// **'Términos de uso y privacidad'**
  String get termsHeaderTitle;

  /// No description provided for @termsHeaderSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Léelos con calma y acéptalos para continuar.'**
  String get termsHeaderSubtitle;

  /// No description provided for @termsAcceptNote.
  ///
  /// In es, this message translates to:
  /// **'Al continuar aceptas estos términos.'**
  String get termsAcceptNote;

  /// No description provided for @termsAcceptButton.
  ///
  /// In es, this message translates to:
  /// **'Aceptar y continuar'**
  String get termsAcceptButton;

  /// No description provided for @termsBrandTitle.
  ///
  /// In es, this message translates to:
  /// **'Bienvenido a Nexo'**
  String get termsBrandTitle;

  /// No description provided for @termsBrandBody.
  ///
  /// In es, this message translates to:
  /// **'Privacidad primero. Aquí te decimos qué se queda en tu dispositivo y qué sale de él.'**
  String get termsBrandBody;

  /// No description provided for @termsItemWhatTitle.
  ///
  /// In es, this message translates to:
  /// **'Qué es Nexo'**
  String get termsItemWhatTitle;

  /// No description provided for @termsItemWhatBody.
  ///
  /// In es, this message translates to:
  /// **'Aplicación independiente y no oficial, creada por y para estudiantes, que reorganiza tu información académica de la UPLA de forma más clara. No está afiliada ni respaldada por la UPLA.'**
  String get termsItemWhatBody;

  /// No description provided for @termsItemPrivacyTitle.
  ///
  /// In es, this message translates to:
  /// **'Tus datos y privacidad'**
  String get termsItemPrivacyTitle;

  /// No description provided for @termsItemPrivacyBody.
  ///
  /// In es, this message translates to:
  /// **'Tus credenciales y tus datos académicos se guardan solo en tu dispositivo, y las consultas van directamente a los servicios de la UPLA, igual que el portal oficial. La única excepción es el apartado Estudiantes, que sí pasa por un servidor propio de Nexo: te lo explicamos en el punto siguiente.'**
  String get termsItemPrivacyBody;

  /// No description provided for @termsItemSecurityTitle.
  ///
  /// In es, this message translates to:
  /// **'Seguridad'**
  String get termsItemSecurityTitle;

  /// No description provided for @termsItemSecurityBody.
  ///
  /// In es, this message translates to:
  /// **'El almacenamiento local no está cifrado a nivel del sistema, así que usa Nexo solo en dispositivos de tu confianza. La sesión con el servidor de Nexo vive en memoria y se pierde al cerrar la app. Puedes cerrar sesión para borrar credenciales y caché en cualquier momento.'**
  String get termsItemSecurityBody;

  /// No description provided for @termsItemResponsibleTitle.
  ///
  /// In es, this message translates to:
  /// **'Uso responsable'**
  String get termsItemResponsibleTitle;

  /// No description provided for @termsItemResponsibleBody.
  ///
  /// In es, this message translates to:
  /// **'Usa tus propias credenciales y accede únicamente a la información que te corresponde o que te haya sido autorizada. Es un proyecto educativo y de uso personal: úsalo conforme a los reglamentos de tu universidad.'**
  String get termsItemResponsibleBody;

  /// No description provided for @termsItemDisclaimerTitle.
  ///
  /// In es, this message translates to:
  /// **'Sin garantías'**
  String get termsItemDisclaimerTitle;

  /// No description provided for @termsItemDisclaimerBody.
  ///
  /// In es, this message translates to:
  /// **'El servicio se ofrece \"tal cual\", sin garantías. Para trámites oficiales consulta siempre el portal institucional.'**
  String get termsItemDisclaimerBody;

  /// No description provided for @aboutFeatureAllInOneTitle.
  ///
  /// In es, this message translates to:
  /// **'Tu universidad en un solo lugar'**
  String get aboutFeatureAllInOneTitle;

  /// No description provided for @aboutFeatureAllInOneBody.
  ///
  /// In es, this message translates to:
  /// **'Perfil, horario, notas, pagos y próximas tareas, sin saltar entre SIGMA, Intranet y otros portales.'**
  String get aboutFeatureAllInOneBody;

  /// No description provided for @aboutFeatureMultiplatformTitle.
  ///
  /// In es, this message translates to:
  /// **'Multiplataforma'**
  String get aboutFeatureMultiplatformTitle;

  /// No description provided for @aboutFeatureMultiplatformBody.
  ///
  /// In es, this message translates to:
  /// **'Misma experiencia en Android, iOS, Web y escritorio, con una sola base de código en Flutter.'**
  String get aboutFeatureMultiplatformBody;

  /// No description provided for @aboutFeaturePrivacyTitle.
  ///
  /// In es, this message translates to:
  /// **'Privacidad primero'**
  String get aboutFeaturePrivacyTitle;

  /// No description provided for @aboutFeaturePrivacyBody.
  ///
  /// In es, this message translates to:
  /// **'Tus credenciales se guardan solo en tu dispositivo. Las peticiones van directo a los servicios de la UPLA, sin servidores intermedios.'**
  String get aboutFeaturePrivacyBody;

  /// No description provided for @aboutFeatureNoSdkTitle.
  ///
  /// In es, this message translates to:
  /// **'Sin SDKs de terceros'**
  String get aboutFeatureNoSdkTitle;

  /// No description provided for @aboutFeatureNoSdkBody.
  ///
  /// In es, this message translates to:
  /// **'Autenticación y red implementadas a mano sobre HTTP estándar, para controlar errores y mantenerlo ligero.'**
  String get aboutFeatureNoSdkBody;

  /// No description provided for @aboutFooterDisclaimer.
  ///
  /// In es, this message translates to:
  /// **'Nexo es un proyecto independiente y no oficial, creado por y para estudiantes. No está afiliado ni respaldado por la UPLA.'**
  String get aboutFooterDisclaimer;

  /// No description provided for @aboutHeroSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Cliente UPLA · v{version}'**
  String aboutHeroSubtitle(String version);

  /// No description provided for @aboutDetailsTitle.
  ///
  /// In es, this message translates to:
  /// **'Detalles'**
  String get aboutDetailsTitle;

  /// No description provided for @aboutDetailsVersionLabel.
  ///
  /// In es, this message translates to:
  /// **'Versión'**
  String get aboutDetailsVersionLabel;

  /// No description provided for @aboutDetailsBuildLabel.
  ///
  /// In es, this message translates to:
  /// **'Build'**
  String get aboutDetailsBuildLabel;

  /// No description provided for @aboutDetailsPlatformsLabel.
  ///
  /// In es, this message translates to:
  /// **'Plataformas'**
  String get aboutDetailsPlatformsLabel;

  /// No description provided for @aboutDetailsPlatformsValue.
  ///
  /// In es, this message translates to:
  /// **'Android · iOS · Web · Escritorio'**
  String get aboutDetailsPlatformsValue;

  /// No description provided for @aboutDetailsTechLabel.
  ///
  /// In es, this message translates to:
  /// **'Tecnología'**
  String get aboutDetailsTechLabel;

  /// No description provided for @aboutDetailsTechValue.
  ///
  /// In es, this message translates to:
  /// **'Flutter'**
  String get aboutDetailsTechValue;

  /// No description provided for @developerGithubCopied.
  ///
  /// In es, this message translates to:
  /// **'Enlace de GitHub copiado'**
  String get developerGithubCopied;

  /// No description provided for @developerSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Quién creó Nexo'**
  String get developerSubtitle;

  /// No description provided for @developerRole.
  ///
  /// In es, this message translates to:
  /// **'Desarrollador independiente · Estudiante UPLA'**
  String get developerRole;

  /// No description provided for @supportTitle.
  ///
  /// In es, this message translates to:
  /// **'Soporte Técnico'**
  String get supportTitle;

  /// No description provided for @supportHeroBadge.
  ///
  /// In es, this message translates to:
  /// **'SOPORTE 24/7'**
  String get supportHeroBadge;

  /// No description provided for @supportHeroTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Tienes algún problema?'**
  String get supportHeroTitle;

  /// No description provided for @supportHeroBody.
  ///
  /// In es, this message translates to:
  /// **'Estamos aquí para ayudarte. Si experimentas fallas en la app, problemas de conexión o errores en los datos, contáctanos directamente por WhatsApp o correo electrónico.'**
  String get supportHeroBody;

  /// No description provided for @supportChannelsTitle.
  ///
  /// In es, this message translates to:
  /// **'Canales de Atención'**
  String get supportChannelsTitle;

  /// No description provided for @supportChannelWhatsApp.
  ///
  /// In es, this message translates to:
  /// **'WhatsApp'**
  String get supportChannelWhatsApp;

  /// No description provided for @supportChannelEmail.
  ///
  /// In es, this message translates to:
  /// **'Correo Electrónico'**
  String get supportChannelEmail;

  /// No description provided for @supportInfoNote.
  ///
  /// In es, this message translates to:
  /// **'Al presionar el canal de atención, se abrirá la aplicación correspondiente. De lo contrario, los datos de contacto se copiarán a tu portapapeles.'**
  String get supportInfoNote;

  /// No description provided for @supportWhatsAppMessage.
  ///
  /// In es, this message translates to:
  /// **'Hola, tengo un problema con la aplicación Nexo'**
  String get supportWhatsAppMessage;

  /// No description provided for @supportWhatsAppCopied.
  ///
  /// In es, this message translates to:
  /// **'Número de WhatsApp de Soporte copiado'**
  String get supportWhatsAppCopied;

  /// No description provided for @supportEmailSubject.
  ///
  /// In es, this message translates to:
  /// **'Soporte Nexo App'**
  String get supportEmailSubject;

  /// No description provided for @supportEmailBody.
  ///
  /// In es, this message translates to:
  /// **'Hola, tengo un problema con la aplicación Nexo:'**
  String get supportEmailBody;

  /// No description provided for @supportEmailCopied.
  ///
  /// In es, this message translates to:
  /// **'Correo electrónico de Soporte copiado'**
  String get supportEmailCopied;

  /// No description provided for @supportContactButton.
  ///
  /// In es, this message translates to:
  /// **'Contactar Soporte Técnico'**
  String get supportContactButton;

  /// No description provided for @docenteLabel.
  ///
  /// In es, this message translates to:
  /// **'DOCENTE'**
  String get docenteLabel;

  /// No description provided for @docenteCodeLabel.
  ///
  /// In es, this message translates to:
  /// **'Código de docente'**
  String get docenteCodeLabel;

  /// No description provided for @docenteMetricCursos.
  ///
  /// In es, this message translates to:
  /// **'Cursos'**
  String get docenteMetricCursos;

  /// No description provided for @docenteMetricAlumnos.
  ///
  /// In es, this message translates to:
  /// **'Alumnos'**
  String get docenteMetricAlumnos;

  /// No description provided for @docenteMetricPeriodo.
  ///
  /// In es, this message translates to:
  /// **'Periodo'**
  String get docenteMetricPeriodo;

  /// No description provided for @docenteNoClassesToday.
  ///
  /// In es, this message translates to:
  /// **'No dictas hoy'**
  String get docenteNoClassesToday;

  /// No description provided for @docenteToday.
  ///
  /// In es, this message translates to:
  /// **'Hoy'**
  String get docenteToday;

  /// No description provided for @docenteClassCount.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{{count} clase} other{{count} clases}}'**
  String docenteClassCount(int count);

  /// No description provided for @docenteTypeTeoria.
  ///
  /// In es, this message translates to:
  /// **'TEO'**
  String get docenteTypeTeoria;

  /// No description provided for @docenteTypePractica.
  ///
  /// In es, this message translates to:
  /// **'PRÁC'**
  String get docenteTypePractica;

  /// No description provided for @docenteLoadingClasses.
  ///
  /// In es, this message translates to:
  /// **'Cargando clases...'**
  String get docenteLoadingClasses;

  /// No description provided for @docenteSessionsWeeklyCount.
  ///
  /// In es, this message translates to:
  /// **'Mis clases · {count, plural, =1{1 sesión esta semana} other{{count} sesiones esta semana}}'**
  String docenteSessionsWeeklyCount(int count);

  /// No description provided for @docenteNoClassesRegistered.
  ///
  /// In es, this message translates to:
  /// **'No tienes clases registradas'**
  String get docenteNoClassesRegistered;

  /// No description provided for @docenteCourseCount.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{{count} curso} other{{count} cursos}}'**
  String docenteCourseCount(int count);

  /// No description provided for @docenteCoursesCountPlural.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{{count} asignatura} other{{count} asignaturas}}'**
  String docenteCoursesCountPlural(int count);

  /// No description provided for @docenteMetricAlumnosCount.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{{count} alumno} other{{count} alumnos}}'**
  String docenteMetricAlumnosCount(int count);

  /// No description provided for @docenteLoadCoursesError.
  ///
  /// In es, this message translates to:
  /// **'No se pudieron cargar los cursos'**
  String get docenteLoadCoursesError;

  /// No description provided for @docenteNoCoursesPeriod.
  ///
  /// In es, this message translates to:
  /// **'Sin cursos asignados en este periodo'**
  String get docenteNoCoursesPeriod;

  /// No description provided for @docenteTabAlumnos.
  ///
  /// In es, this message translates to:
  /// **'Alumnos'**
  String get docenteTabAlumnos;

  /// No description provided for @docenteTabAsistencia.
  ///
  /// In es, this message translates to:
  /// **'Asistencia'**
  String get docenteTabAsistencia;

  /// No description provided for @docenteTabNotas.
  ///
  /// In es, this message translates to:
  /// **'Notas'**
  String get docenteTabNotas;

  /// No description provided for @docenteNoCode.
  ///
  /// In es, this message translates to:
  /// **'Sin código'**
  String get docenteNoCode;

  /// No description provided for @docenteSectionPeriod.
  ///
  /// In es, this message translates to:
  /// **'Sección {seccion} · {periodo}'**
  String docenteSectionPeriod(String seccion, String periodo);

  /// No description provided for @docenteNoAlumnosRegistered.
  ///
  /// In es, this message translates to:
  /// **'Sin alumnos registrados'**
  String get docenteNoAlumnosRegistered;

  /// No description provided for @docenteAsisPercent.
  ///
  /// In es, this message translates to:
  /// **'{percent}% asist.'**
  String docenteAsisPercent(String percent);

  /// No description provided for @docenteAttendancePresentShort.
  ///
  /// In es, this message translates to:
  /// **'Pres.'**
  String get docenteAttendancePresentShort;

  /// No description provided for @docenteAttendanceTardanzaShort.
  ///
  /// In es, this message translates to:
  /// **'Tard.'**
  String get docenteAttendanceTardanzaShort;

  /// No description provided for @docenteAttendanceFaltaShort.
  ///
  /// In es, this message translates to:
  /// **'Falta'**
  String get docenteAttendanceFaltaShort;

  /// No description provided for @docenteNoAlumnosInCourse.
  ///
  /// In es, this message translates to:
  /// **'Sin alumnos en este curso'**
  String get docenteNoAlumnosInCourse;

  /// No description provided for @docenteAprobadosCount.
  ///
  /// In es, this message translates to:
  /// **'{aprobados} de {total} aprobados'**
  String docenteAprobadosCount(String aprobados, String total);

  /// No description provided for @docenteTapToEdit.
  ///
  /// In es, this message translates to:
  /// **'Toca para editar →'**
  String get docenteTapToEdit;

  /// No description provided for @docentePromedioParcial.
  ///
  /// In es, this message translates to:
  /// **'PROMEDIO PARCIAL'**
  String get docentePromedioParcial;

  /// No description provided for @docenteCoursePercentGraded.
  ///
  /// In es, this message translates to:
  /// **'{percent}% del curso\nya calificado'**
  String docenteCoursePercentGraded(String percent);

  /// No description provided for @docenteEvalPending.
  ///
  /// In es, this message translates to:
  /// **'PENDIENTE'**
  String get docenteEvalPending;

  /// No description provided for @docenteNoAttendanceRecords.
  ///
  /// In es, this message translates to:
  /// **'Sin registros de asistencia.'**
  String get docenteNoAttendanceRecords;

  /// No description provided for @docenteAttendanceLabel.
  ///
  /// In es, this message translates to:
  /// **'ASISTENCIA'**
  String get docenteAttendanceLabel;

  /// No description provided for @docenteSessionsRegisteredCount.
  ///
  /// In es, this message translates to:
  /// **'{presentes} de {total}\nsesiones registradas'**
  String docenteSessionsRegisteredCount(String presentes, String total);

  /// No description provided for @docenteAttendancePresent.
  ///
  /// In es, this message translates to:
  /// **'Presente'**
  String get docenteAttendancePresent;

  /// No description provided for @docenteAttendanceTardanza.
  ///
  /// In es, this message translates to:
  /// **'Tardanza'**
  String get docenteAttendanceTardanza;

  /// No description provided for @docenteAttendanceFalta.
  ///
  /// In es, this message translates to:
  /// **'Falta'**
  String get docenteAttendanceFalta;

  /// No description provided for @docenteAttendanceJustificada.
  ///
  /// In es, this message translates to:
  /// **'Justificada'**
  String get docenteAttendanceJustificada;

  /// No description provided for @docenteInfoTitle.
  ///
  /// In es, this message translates to:
  /// **'Información del docente'**
  String get docenteInfoTitle;

  /// No description provided for @docenteInfoFieldNombres.
  ///
  /// In es, this message translates to:
  /// **'Nombres'**
  String get docenteInfoFieldNombres;

  /// No description provided for @docenteInfoFieldApellidos.
  ///
  /// In es, this message translates to:
  /// **'Apellidos'**
  String get docenteInfoFieldApellidos;

  /// No description provided for @docenteInfoFieldFacultad.
  ///
  /// In es, this message translates to:
  /// **'Facultad'**
  String get docenteInfoFieldFacultad;

  /// No description provided for @docenteInfoFieldEspecialidad.
  ///
  /// In es, this message translates to:
  /// **'Especialidad'**
  String get docenteInfoFieldEspecialidad;

  /// No description provided for @docenteSupportSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Contactar por WhatsApp o Correo'**
  String get docenteSupportSubtitle;

  /// No description provided for @connectivityStatusTitle.
  ///
  /// In es, this message translates to:
  /// **'Estado de Conexión'**
  String get connectivityStatusTitle;

  /// No description provided for @connectivityDiagnosticsSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Diagnóstico en tiempo real'**
  String get connectivityDiagnosticsSubtitle;

  /// No description provided for @connectivityInternet.
  ///
  /// In es, this message translates to:
  /// **'Conexión a Internet'**
  String get connectivityInternet;

  /// No description provided for @connectivitySigma.
  ///
  /// In es, this message translates to:
  /// **'Servidor SIGMA'**
  String get connectivitySigma;

  /// No description provided for @connectivityIntranet.
  ///
  /// In es, this message translates to:
  /// **'Servidor INTRANET'**
  String get connectivityIntranet;

  /// No description provided for @connectivityBackupNote.
  ///
  /// In es, this message translates to:
  /// **'Los datos locales de respaldo se usarán automáticamente cuando no haya conexión con los servidores.'**
  String get connectivityBackupNote;

  /// No description provided for @connectivityOnline.
  ///
  /// In es, this message translates to:
  /// **'En línea'**
  String get connectivityOnline;

  /// No description provided for @connectivityOffline.
  ///
  /// In es, this message translates to:
  /// **'Caído'**
  String get connectivityOffline;

  /// No description provided for @connectivityDegraded.
  ///
  /// In es, this message translates to:
  /// **'Inestable'**
  String get connectivityDegraded;

  /// No description provided for @connectivityConnected.
  ///
  /// In es, this message translates to:
  /// **'Conectado'**
  String get connectivityConnected;

  /// No description provided for @connectivityDisconnected.
  ///
  /// In es, this message translates to:
  /// **'Desconectado'**
  String get connectivityDisconnected;

  /// No description provided for @homeVerifyConnectivity.
  ///
  /// In es, this message translates to:
  /// **'Verificar Estado de Conexión'**
  String get homeVerifyConnectivity;

  /// No description provided for @homeMetricPromedio.
  ///
  /// In es, this message translates to:
  /// **'Promedio'**
  String get homeMetricPromedio;

  /// No description provided for @homeMetricPromedioCiclo.
  ///
  /// In es, this message translates to:
  /// **'Prom. ciclo'**
  String get homeMetricPromedioCiclo;

  /// No description provided for @homeMetricPromedioAcumulado.
  ///
  /// In es, this message translates to:
  /// **'Prom. acum.'**
  String get homeMetricPromedioAcumulado;

  /// No description provided for @homeMetricCreditos.
  ///
  /// In es, this message translates to:
  /// **'Créditos'**
  String get homeMetricCreditos;

  /// No description provided for @homeMetricClasesHoy.
  ///
  /// In es, this message translates to:
  /// **'Clases hoy'**
  String get homeMetricClasesHoy;

  /// No description provided for @homeMetricPorPagar.
  ///
  /// In es, this message translates to:
  /// **'Por pagar'**
  String get homeMetricPorPagar;

  /// No description provided for @gradesDetailLoadError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo cargar el detalle'**
  String get gradesDetailLoadError;

  /// No description provided for @gradesSustitutorio.
  ///
  /// In es, this message translates to:
  /// **'Examen sustitutorio'**
  String get gradesSustitutorio;

  /// No description provided for @gradesNoUnitsYetTitle.
  ///
  /// In es, this message translates to:
  /// **'Aún sin unidades calificadas'**
  String get gradesNoUnitsYetTitle;

  /// No description provided for @gradesNoUnitsYetSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Las notas aparecerán al publicarse.'**
  String get gradesNoUnitsYetSubtitle;

  /// No description provided for @gradesEvidenciaConocimiento.
  ///
  /// In es, this message translates to:
  /// **'Evidencia de conocimiento'**
  String get gradesEvidenciaConocimiento;

  /// No description provided for @gradesEvidenciaDesempeno.
  ///
  /// In es, this message translates to:
  /// **'Evidencia de desempeño'**
  String get gradesEvidenciaDesempeno;

  /// No description provided for @gradesEvidenciaProducto.
  ///
  /// In es, this message translates to:
  /// **'Evidencia de producto'**
  String get gradesEvidenciaProducto;

  /// No description provided for @gradesPromedioAcumulado.
  ///
  /// In es, this message translates to:
  /// **'Promedio acumulado'**
  String get gradesPromedioAcumulado;

  /// No description provided for @gradesNoCreditsData.
  ///
  /// In es, this message translates to:
  /// **'Sin datos de créditos'**
  String get gradesNoCreditsData;

  /// No description provided for @gradesNoHistoryYet.
  ///
  /// In es, this message translates to:
  /// **'Sin historial aún'**
  String get gradesNoHistoryYet;

  /// No description provided for @gradesEvolutionByPeriod.
  ///
  /// In es, this message translates to:
  /// **'Evolución por periodo'**
  String get gradesEvolutionByPeriod;

  /// No description provided for @statusInProcess.
  ///
  /// In es, this message translates to:
  /// **'EN PROCESO'**
  String get statusInProcess;

  /// No description provided for @paymentsFilterAll.
  ///
  /// In es, this message translates to:
  /// **'Todos'**
  String get paymentsFilterAll;

  /// No description provided for @paymentsNoneInPeriod.
  ///
  /// In es, this message translates to:
  /// **'Sin pagos en este periodo'**
  String get paymentsNoneInPeriod;

  /// No description provided for @homeMoreClassesToday.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{+ 1 clase más hoy} other{+ {count} clases más hoy}}'**
  String homeMoreClassesToday(int count);

  /// No description provided for @statusApproved.
  ///
  /// In es, this message translates to:
  /// **'APROBADO'**
  String get statusApproved;

  /// No description provided for @statusFailed.
  ///
  /// In es, this message translates to:
  /// **'DESAPROBADO'**
  String get statusFailed;

  /// No description provided for @gradesPromedioLabel.
  ///
  /// In es, this message translates to:
  /// **'Promedio'**
  String get gradesPromedioLabel;

  /// No description provided for @gradesParcial1.
  ///
  /// In es, this message translates to:
  /// **'Parcial 1'**
  String get gradesParcial1;

  /// No description provided for @gradesParcial2.
  ///
  /// In es, this message translates to:
  /// **'Parcial 2'**
  String get gradesParcial2;

  /// No description provided for @gradesPromedioParcial1.
  ///
  /// In es, this message translates to:
  /// **'Promedio parcial 1'**
  String get gradesPromedioParcial1;

  /// No description provided for @gradesPromedioParcial2.
  ///
  /// In es, this message translates to:
  /// **'Promedio parcial 2'**
  String get gradesPromedioParcial2;

  /// No description provided for @gradesPromedioFinal.
  ///
  /// In es, this message translates to:
  /// **'Promedio final'**
  String get gradesPromedioFinal;

  /// No description provided for @gradesPrimerParcial.
  ///
  /// In es, this message translates to:
  /// **'Primer parcial'**
  String get gradesPrimerParcial;

  /// No description provided for @gradesSegundoParcial.
  ///
  /// In es, this message translates to:
  /// **'Segundo parcial'**
  String get gradesSegundoParcial;

  /// No description provided for @gradesPromedioPracticas.
  ///
  /// In es, this message translates to:
  /// **'Promedio de prácticas'**
  String get gradesPromedioPracticas;

  /// No description provided for @gradesTrabajoInvestigacion.
  ///
  /// In es, this message translates to:
  /// **'Trabajo de investigación'**
  String get gradesTrabajoInvestigacion;

  /// No description provided for @gradesExamenParcial.
  ///
  /// In es, this message translates to:
  /// **'Examen parcial'**
  String get gradesExamenParcial;

  /// No description provided for @gradesExamenComplementario.
  ///
  /// In es, this message translates to:
  /// **'Examen complementario'**
  String get gradesExamenComplementario;

  /// No description provided for @paymentsDownloadSchedulePdf.
  ///
  /// In es, this message translates to:
  /// **'Descargar cronograma (PDF)'**
  String get paymentsDownloadSchedulePdf;

  /// No description provided for @paymentsTabPending.
  ///
  /// In es, this message translates to:
  /// **'Pendientes'**
  String get paymentsTabPending;

  /// No description provided for @paymentsTabOverdue.
  ///
  /// In es, this message translates to:
  /// **'Vencidas'**
  String get paymentsTabOverdue;

  /// No description provided for @paymentsTabFees.
  ///
  /// In es, this message translates to:
  /// **'Tasas'**
  String get paymentsTabFees;

  /// No description provided for @paymentsUpToDateTitle.
  ///
  /// In es, this message translates to:
  /// **'¡Estás al día!'**
  String get paymentsUpToDateTitle;

  /// No description provided for @paymentsUpToDateSubtitle.
  ///
  /// In es, this message translates to:
  /// **'No tienes cuotas próximas a vencer.'**
  String get paymentsUpToDateSubtitle;

  /// No description provided for @paymentsNoOverdueTitle.
  ///
  /// In es, this message translates to:
  /// **'Sin cuotas vencidas'**
  String get paymentsNoOverdueTitle;

  /// No description provided for @paymentsNoOverdueSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Genial, no tienes cuotas con vencimiento pasado.'**
  String get paymentsNoOverdueSubtitle;

  /// No description provided for @paymentVenceHoy.
  ///
  /// In es, this message translates to:
  /// **'VENCE HOY'**
  String get paymentVenceHoy;

  /// No description provided for @paymentVenceManana.
  ///
  /// In es, this message translates to:
  /// **'Vence mañana'**
  String get paymentVenceManana;

  /// No description provided for @paymentVenceMananaCaps.
  ///
  /// In es, this message translates to:
  /// **'VENCE MAÑANA'**
  String get paymentVenceMananaCaps;

  /// No description provided for @paymentsNoFeesRegistered.
  ///
  /// In es, this message translates to:
  /// **'Sin tasas registradas'**
  String get paymentsNoFeesRegistered;

  /// No description provided for @paymentsNoHistoryRegistered.
  ///
  /// In es, this message translates to:
  /// **'Sin pagos registrados'**
  String get paymentsNoHistoryRegistered;

  /// No description provided for @paymentDetailCuota.
  ///
  /// In es, this message translates to:
  /// **'Detalle de Cuota'**
  String get paymentDetailCuota;

  /// No description provided for @paymentDetailTasa.
  ///
  /// In es, this message translates to:
  /// **'Detalle de Tasa'**
  String get paymentDetailTasa;

  /// No description provided for @paymentDetailPago.
  ///
  /// In es, this message translates to:
  /// **'Detalle de Pago'**
  String get paymentDetailPago;

  /// No description provided for @paymentDetailTasaAdministrativa.
  ///
  /// In es, this message translates to:
  /// **'Tasa Administrativa'**
  String get paymentDetailTasaAdministrativa;

  /// No description provided for @paymentDetailImporteBase.
  ///
  /// In es, this message translates to:
  /// **'Importe Base'**
  String get paymentDetailImporteBase;

  /// No description provided for @paymentDetailFechaVencimiento.
  ///
  /// In es, this message translates to:
  /// **'Fecha de Vencimiento'**
  String get paymentDetailFechaVencimiento;

  /// No description provided for @paymentDetailImportePagado.
  ///
  /// In es, this message translates to:
  /// **'Importe Pagado'**
  String get paymentDetailImportePagado;

  /// No description provided for @paymentDetailFechaPago.
  ///
  /// In es, this message translates to:
  /// **'Fecha de Pago'**
  String get paymentDetailFechaPago;

  /// No description provided for @paymentDetailHoraPago.
  ///
  /// In es, this message translates to:
  /// **'Hora de Pago'**
  String get paymentDetailHoraPago;

  /// No description provided for @paymentDetailPeriodoAcademico.
  ///
  /// In es, this message translates to:
  /// **'Periodo Académico'**
  String get paymentDetailPeriodoAcademico;

  /// No description provided for @paymentDetailLugarPago.
  ///
  /// In es, this message translates to:
  /// **'Lugar de Pago'**
  String get paymentDetailLugarPago;

  /// No description provided for @paymentDetailDescripcionOperacion.
  ///
  /// In es, this message translates to:
  /// **'Descripción de Operación'**
  String get paymentDetailDescripcionOperacion;

  /// No description provided for @paymentDetailInformacionDetallada.
  ///
  /// In es, this message translates to:
  /// **'Información Detallada'**
  String get paymentDetailInformacionDetallada;

  /// No description provided for @profileDownloadEnrollmentPdf.
  ///
  /// In es, this message translates to:
  /// **'Constancia de matrícula (PDF)'**
  String get profileDownloadEnrollmentPdf;

  /// No description provided for @profileStudentCode.
  ///
  /// In es, this message translates to:
  /// **'Código de estudiante'**
  String get profileStudentCode;

  /// No description provided for @profileCareer.
  ///
  /// In es, this message translates to:
  /// **'Carrera'**
  String get profileCareer;

  /// No description provided for @profileFaculty.
  ///
  /// In es, this message translates to:
  /// **'Facultad'**
  String get profileFaculty;

  /// No description provided for @profileCampus.
  ///
  /// In es, this message translates to:
  /// **'Sede'**
  String get profileCampus;

  /// No description provided for @profileMode.
  ///
  /// In es, this message translates to:
  /// **'Modalidad'**
  String get profileMode;

  /// No description provided for @profileStudyPlan.
  ///
  /// In es, this message translates to:
  /// **'Plan de estudios'**
  String get profileStudyPlan;

  /// No description provided for @profileLevel.
  ///
  /// In es, this message translates to:
  /// **'Nivel'**
  String get profileLevel;

  /// No description provided for @profileLastEnrollment.
  ///
  /// In es, this message translates to:
  /// **'Última matrícula'**
  String get profileLastEnrollment;

  /// No description provided for @profileStatus.
  ///
  /// In es, this message translates to:
  /// **'Estado'**
  String get profileStatus;

  /// No description provided for @profileStatusNotEnrolled.
  ///
  /// In es, this message translates to:
  /// **'No matriculado'**
  String get profileStatusNotEnrolled;

  /// No description provided for @profileStatusEnrolled.
  ///
  /// In es, this message translates to:
  /// **'Matriculado'**
  String get profileStatusEnrolled;

  /// No description provided for @profileAcademicInfo.
  ///
  /// In es, this message translates to:
  /// **'Información académica'**
  String get profileAcademicInfo;

  /// No description provided for @teamsCopyCode.
  ///
  /// In es, this message translates to:
  /// **'Copiar código'**
  String get teamsCopyCode;

  /// No description provided for @teamsUnderConstruction.
  ///
  /// In es, this message translates to:
  /// **'En construcción'**
  String get teamsUnderConstruction;

  /// No description provided for @teamsSoonAvailable.
  ///
  /// In es, this message translates to:
  /// **'Pronto disponible'**
  String get teamsSoonAvailable;

  /// No description provided for @teamsWorkingOnSection.
  ///
  /// In es, this message translates to:
  /// **'Estamos trabajando en esta sección'**
  String get teamsWorkingOnSection;

  /// No description provided for @teamsComeBackLater.
  ///
  /// In es, this message translates to:
  /// **'Vuelve más adelante.'**
  String get teamsComeBackLater;

  /// No description provided for @pdfExportLoadConstanciaError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo cargar la constancia.'**
  String get pdfExportLoadConstanciaError;

  /// No description provided for @pdfExportLoadCronogramaError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo cargar el cronograma.'**
  String get pdfExportLoadCronogramaError;

  /// No description provided for @gradesCreditsSummary.
  ///
  /// In es, this message translates to:
  /// **'{aprobados} de {total} créditos'**
  String gradesCreditsSummary(String aprobados, String total);

  /// No description provided for @gradesCreditsApprovedCount.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 crédito aprobado} other{{count} créditos aprobados}}'**
  String gradesCreditsApprovedCount(int count);

  /// No description provided for @gradesRank.
  ///
  /// In es, this message translates to:
  /// **' · Puesto {rank}'**
  String gradesRank(String rank);

  /// No description provided for @gradesSummary.
  ///
  /// In es, this message translates to:
  /// **'Resumen'**
  String get gradesSummary;

  /// No description provided for @gradesPractice.
  ///
  /// In es, this message translates to:
  /// **'Práctica {index}'**
  String gradesPractice(String index);

  /// No description provided for @gradesProyecto.
  ///
  /// In es, this message translates to:
  /// **'Proyecto'**
  String get gradesProyecto;

  /// No description provided for @gradesPromedioTiPy.
  ///
  /// In es, this message translates to:
  /// **'Promedio TI + PY'**
  String get gradesPromedioTiPy;

  /// No description provided for @paymentsTabHistory.
  ///
  /// In es, this message translates to:
  /// **'Historial'**
  String get paymentsTabHistory;

  /// No description provided for @paymentsLoadError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo cargar'**
  String get paymentsLoadError;

  /// No description provided for @paymentDaysOverdue.
  ///
  /// In es, this message translates to:
  /// **'VENCIDA hace {days} d.'**
  String paymentDaysOverdue(String days);

  /// No description provided for @paymentDaysLeft.
  ///
  /// In es, this message translates to:
  /// **'En {days} días'**
  String paymentDaysLeft(String days);

  /// No description provided for @paymentMora.
  ///
  /// In es, this message translates to:
  /// **'Mora {currency} {amount}'**
  String paymentMora(String currency, String amount);

  /// No description provided for @paymentVenceEl.
  ///
  /// In es, this message translates to:
  /// **'Vence el {date}'**
  String paymentVenceEl(String date);

  /// No description provided for @paymentStatusPaid.
  ///
  /// In es, this message translates to:
  /// **'PAGADO'**
  String get paymentStatusPaid;

  /// No description provided for @paymentDateOfPayment.
  ///
  /// In es, this message translates to:
  /// **'Fecha de Pago: {date}'**
  String paymentDateOfPayment(String date);

  /// No description provided for @paymentMoraLabel.
  ///
  /// In es, this message translates to:
  /// **'Mora'**
  String get paymentMoraLabel;

  /// No description provided for @paymentDetailObservacion.
  ///
  /// In es, this message translates to:
  /// **'Observación'**
  String get paymentDetailObservacion;

  /// No description provided for @paymentDetailConcepto.
  ///
  /// In es, this message translates to:
  /// **'Concepto'**
  String get paymentDetailConcepto;

  /// No description provided for @paymentDetailImporte.
  ///
  /// In es, this message translates to:
  /// **'Importe'**
  String get paymentDetailImporte;

  /// No description provided for @paymentDetailComprobante.
  ///
  /// In es, this message translates to:
  /// **'Comprobante'**
  String get paymentDetailComprobante;

  /// No description provided for @paymentDetailOperacion.
  ///
  /// In es, this message translates to:
  /// **'Operación'**
  String get paymentDetailOperacion;

  /// No description provided for @setupTitle.
  ///
  /// In es, this message translates to:
  /// **'¡Bienvenido a Nexo UPLA!'**
  String get setupTitle;

  /// No description provided for @setupSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Hemos detectado que estás ejecutando la aplicación fuera del directorio de instalación oficial.'**
  String get setupSubtitle;

  /// No description provided for @setupBtnInstall.
  ///
  /// In es, this message translates to:
  /// **'Instalar en mi Computadora'**
  String get setupBtnInstall;

  /// No description provided for @setupBtnPortable.
  ///
  /// In es, this message translates to:
  /// **'Ejecutar en Modo Portable'**
  String get setupBtnPortable;

  /// No description provided for @setupPortableDesc.
  ///
  /// In es, this message translates to:
  /// **'El modo portable no creará accesos directos ni registrará la app en Windows.'**
  String get setupPortableDesc;

  /// No description provided for @setupProgressCopied.
  ///
  /// In es, this message translates to:
  /// **'Copiando archivos de programa...'**
  String get setupProgressCopied;

  /// No description provided for @setupProgressShortcuts.
  ///
  /// In es, this message translates to:
  /// **'Creando accesos directos...'**
  String get setupProgressShortcuts;

  /// No description provided for @setupProgressRegister.
  ///
  /// In es, this message translates to:
  /// **'Registrando en Windows...'**
  String get setupProgressRegister;

  /// No description provided for @setupProgressDone.
  ///
  /// In es, this message translates to:
  /// **'¡Instalación completada exitosamente!'**
  String get setupProgressDone;

  /// No description provided for @setupSuccessTitle.
  ///
  /// In es, this message translates to:
  /// **'¡Instalación Exitosa!'**
  String get setupSuccessTitle;

  /// No description provided for @setupSuccessDesc.
  ///
  /// In es, this message translates to:
  /// **'Nexo UPLA ha sido instalado y registrado correctamente.'**
  String get setupSuccessDesc;

  /// No description provided for @setupBtnStart.
  ///
  /// In es, this message translates to:
  /// **'Iniciar Aplicación'**
  String get setupBtnStart;

  /// No description provided for @setupErrorTitle.
  ///
  /// In es, this message translates to:
  /// **'Error de Instalación'**
  String get setupErrorTitle;

  /// No description provided for @setupBtnRetry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get setupBtnRetry;

  /// No description provided for @setupBtnExit.
  ///
  /// In es, this message translates to:
  /// **'Salir'**
  String get setupBtnExit;

  /// No description provided for @setupCustomization.
  ///
  /// In es, this message translates to:
  /// **'Personalización'**
  String get setupCustomization;

  /// No description provided for @setupTermsAccept.
  ///
  /// In es, this message translates to:
  /// **'He leído y acepto los términos de uso y privacidad'**
  String get setupTermsAccept;

  /// No description provided for @setupTermsRequired.
  ///
  /// In es, this message translates to:
  /// **'Debes aceptar los términos para continuar'**
  String get setupTermsRequired;

  /// No description provided for @setupOptionDesktop.
  ///
  /// In es, this message translates to:
  /// **'Crear acceso directo en el Escritorio'**
  String get setupOptionDesktop;

  /// No description provided for @setupOptionStartMenu.
  ///
  /// In es, this message translates to:
  /// **'Crear acceso en el Menú Inicio'**
  String get setupOptionStartMenu;

  /// No description provided for @setupOptionAutoStart.
  ///
  /// In es, this message translates to:
  /// **'Iniciar Nexo con Windows'**
  String get setupOptionAutoStart;

  /// No description provided for @setupOptionAutoStartDesc.
  ///
  /// In es, this message translates to:
  /// **'Se abrirá automáticamente al iniciar sesión'**
  String get setupOptionAutoStartDesc;

  /// No description provided for @setupProgressAutoStart.
  ///
  /// In es, this message translates to:
  /// **'Configurando inicio automático...'**
  String get setupProgressAutoStart;

  /// No description provided for @setupBtnBack.
  ///
  /// In es, this message translates to:
  /// **'Atrás'**
  String get setupBtnBack;

  /// No description provided for @setupBtnNext.
  ///
  /// In es, this message translates to:
  /// **'Siguiente'**
  String get setupBtnNext;

  /// No description provided for @setupBtnInstallNow.
  ///
  /// In es, this message translates to:
  /// **'Instalar'**
  String get setupBtnInstallNow;

  /// No description provided for @updTitle.
  ///
  /// In es, this message translates to:
  /// **'Actualizaciones'**
  String get updTitle;

  /// No description provided for @updInstalledVersion.
  ///
  /// In es, this message translates to:
  /// **'Versión instalada'**
  String get updInstalledVersion;

  /// No description provided for @updStatusChecking.
  ///
  /// In es, this message translates to:
  /// **'Buscando…'**
  String get updStatusChecking;

  /// No description provided for @updStatusAvailable.
  ///
  /// In es, this message translates to:
  /// **'Disponible'**
  String get updStatusAvailable;

  /// No description provided for @updStatusUpToDate.
  ///
  /// In es, this message translates to:
  /// **'Al día'**
  String get updStatusUpToDate;

  /// No description provided for @updStatusUnknown.
  ///
  /// In es, this message translates to:
  /// **'Sin verificar'**
  String get updStatusUnknown;

  /// No description provided for @updCheck.
  ///
  /// In es, this message translates to:
  /// **'Buscar actualizaciones'**
  String get updCheck;

  /// No description provided for @updInstallNow.
  ///
  /// In es, this message translates to:
  /// **'Instalar ahora'**
  String get updInstallNow;

  /// No description provided for @updDownloadInstall.
  ///
  /// In es, this message translates to:
  /// **'Descargar e instalar'**
  String get updDownloadInstall;

  /// No description provided for @updAvailableLine.
  ///
  /// In es, this message translates to:
  /// **'Nexo {version} está disponible.'**
  String updAvailableLine(String version);

  /// No description provided for @updSnackUpToDate.
  ///
  /// In es, this message translates to:
  /// **'Ya tienes la última versión.'**
  String get updSnackUpToDate;

  /// No description provided for @updSnackAvailable.
  ///
  /// In es, this message translates to:
  /// **'Nueva versión {version} disponible.'**
  String updSnackAvailable(String version);

  /// No description provided for @updSnackCheckFailed.
  ///
  /// In es, this message translates to:
  /// **'No se pudo verificar. Revisa tu conexión.'**
  String get updSnackCheckFailed;

  /// No description provided for @updSnackInstallFailed.
  ///
  /// In es, this message translates to:
  /// **'No se pudo iniciar la instalación.'**
  String get updSnackInstallFailed;

  /// No description provided for @updBannerReadyTitle.
  ///
  /// In es, this message translates to:
  /// **'Actualización lista para instalar'**
  String get updBannerReadyTitle;

  /// No description provided for @updBannerAvailableTitle.
  ///
  /// In es, this message translates to:
  /// **'Actualización disponible'**
  String get updBannerAvailableTitle;

  /// No description provided for @updBannerReadyBody.
  ///
  /// In es, this message translates to:
  /// **'Toca para instalar Nexo {version}.'**
  String updBannerReadyBody(String version);

  /// No description provided for @updBannerAvailableBody.
  ///
  /// In es, this message translates to:
  /// **'Toca para descargar Nexo {version}.'**
  String updBannerAvailableBody(String version);

  /// No description provided for @updDismiss.
  ///
  /// In es, this message translates to:
  /// **'Descartar'**
  String get updDismiss;

  /// No description provided for @assignmentNoDate.
  ///
  /// In es, this message translates to:
  /// **'Sin fecha de entrega'**
  String get assignmentNoDate;

  /// No description provided for @assignmentOverdue.
  ///
  /// In es, this message translates to:
  /// **'Venció'**
  String get assignmentOverdue;

  /// No description provided for @assignmentDueToday.
  ///
  /// In es, this message translates to:
  /// **'Vence hoy'**
  String get assignmentDueToday;

  /// No description provided for @assignmentDueTomorrow.
  ///
  /// In es, this message translates to:
  /// **'Vence mañana'**
  String get assignmentDueTomorrow;

  /// No description provided for @assignmentDueInDays.
  ///
  /// In es, this message translates to:
  /// **'En {days} días'**
  String assignmentDueInDays(int days);

  /// No description provided for @assignmentEmpty.
  ///
  /// In es, this message translates to:
  /// **'No tienes asignaciones pendientes.'**
  String get assignmentEmpty;

  /// No description provided for @widgetNoPendingDebts.
  ///
  /// In es, this message translates to:
  /// **'Sin deudas pendientes'**
  String get widgetNoPendingDebts;

  /// No description provided for @widgetUpToDate.
  ///
  /// In es, this message translates to:
  /// **'✓ Al día'**
  String get widgetUpToDate;

  /// No description provided for @widgetOverdue.
  ///
  /// In es, this message translates to:
  /// **'Vencida hace {d} d'**
  String widgetOverdue(int d);

  /// No description provided for @widgetDueToday.
  ///
  /// In es, this message translates to:
  /// **'Vence hoy'**
  String get widgetDueToday;

  /// No description provided for @widgetDueIn.
  ///
  /// In es, this message translates to:
  /// **'Vence en {d} d ({date})'**
  String widgetDueIn(int d, String date);

  /// No description provided for @notifStartsIn.
  ///
  /// In es, this message translates to:
  /// **'Empieza en {minutes} minutos'**
  String notifStartsIn(int minutes);

  /// No description provided for @notifDueToday.
  ///
  /// In es, this message translates to:
  /// **'vence hoy'**
  String get notifDueToday;

  /// No description provided for @notifDueTomorrow.
  ///
  /// In es, this message translates to:
  /// **'vence mañana'**
  String get notifDueTomorrow;

  /// No description provided for @notifDueInDays.
  ///
  /// In es, this message translates to:
  /// **'vence en {days} días'**
  String notifDueInDays(int days);

  /// No description provided for @notifClassesReminder.
  ///
  /// In es, this message translates to:
  /// **'Recordatorio de clases'**
  String get notifClassesReminder;

  /// No description provided for @notifPendingPayment.
  ///
  /// In es, this message translates to:
  /// **'Pago pendiente — {when}'**
  String notifPendingPayment(String when);

  /// No description provided for @notifPaymentsReminder.
  ///
  /// In es, this message translates to:
  /// **'Recordatorio de pagos'**
  String get notifPaymentsReminder;

  /// No description provided for @prefSameDay.
  ///
  /// In es, this message translates to:
  /// **'El mismo día'**
  String get prefSameDay;

  /// No description provided for @prefOneDayBefore.
  ///
  /// In es, this message translates to:
  /// **'1 día antes'**
  String get prefOneDayBefore;

  /// No description provided for @prefDaysBefore.
  ///
  /// In es, this message translates to:
  /// **'{d} días antes'**
  String prefDaysBefore(int d);

  /// No description provided for @prefOneHourBefore.
  ///
  /// In es, this message translates to:
  /// **'1 hora antes'**
  String get prefOneHourBefore;

  /// No description provided for @prefTwoHoursBefore.
  ///
  /// In es, this message translates to:
  /// **'2 horas antes'**
  String get prefTwoHoursBefore;

  /// No description provided for @prefMinBefore.
  ///
  /// In es, this message translates to:
  /// **'{m} min antes'**
  String prefMinBefore(int m);

  /// No description provided for @classOngoing.
  ///
  /// In es, this message translates to:
  /// **'EN CURSO'**
  String get classOngoing;

  /// No description provided for @homeNoClassesToday.
  ///
  /// In es, this message translates to:
  /// **'Sin clases hoy'**
  String get homeNoClassesToday;

  /// No description provided for @homeNextClassTitle.
  ///
  /// In es, this message translates to:
  /// **'PRÓXIMA CLASE'**
  String get homeNextClassTitle;

  /// No description provided for @homeNextClassTomorrowDay.
  ///
  /// In es, this message translates to:
  /// **'Mañana · {day}'**
  String homeNextClassTomorrowDay(String day);

  /// No description provided for @homeNextClassNow.
  ///
  /// In es, this message translates to:
  /// **'Ahora'**
  String get homeNextClassNow;

  /// No description provided for @homeNextClassInMin.
  ///
  /// In es, this message translates to:
  /// **'En {m} min'**
  String homeNextClassInMin(int m);

  /// No description provided for @homeNextClassInHours.
  ///
  /// In es, this message translates to:
  /// **'En {h}h'**
  String homeNextClassInHours(int h);

  /// No description provided for @homeNextClassInHoursMin.
  ///
  /// In es, this message translates to:
  /// **'En {h}h {m}min'**
  String homeNextClassInHoursMin(int h, int m);

  /// No description provided for @homePendingPaymentsOverdueCount.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{{count} vencida} other{{count} vencidas}}'**
  String homePendingPaymentsOverdueCount(int count);

  /// No description provided for @widgetTeamsTitle.
  ///
  /// In es, this message translates to:
  /// **'Mis asignaturas'**
  String get widgetTeamsTitle;

  /// No description provided for @widgetTeamsSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Grupos de Teams'**
  String get widgetTeamsSubtitle;

  /// No description provided for @widgetTeamsEmpty.
  ///
  /// In es, this message translates to:
  /// **'No hay asignaturas en Teams'**
  String get widgetTeamsEmpty;

  /// No description provided for @widgetAssignmentsTitle.
  ///
  /// In es, this message translates to:
  /// **'Tareas'**
  String get widgetAssignmentsTitle;

  /// No description provided for @widgetAssignmentsSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Próximas a vencer'**
  String get widgetAssignmentsSubtitle;

  /// No description provided for @whatsappBannerTitle.
  ///
  /// In es, this message translates to:
  /// **'Únete al canal de Nexo'**
  String get whatsappBannerTitle;

  /// No description provided for @whatsappBannerDesc.
  ///
  /// In es, this message translates to:
  /// **'Sigue el canal de WhatsApp para enterarte de novedades, mejoras y avisos importantes sobre Nexo.'**
  String get whatsappBannerDesc;

  /// No description provided for @whatsappBannerFollow.
  ///
  /// In es, this message translates to:
  /// **'Seguir canal'**
  String get whatsappBannerFollow;

  /// No description provided for @whatsappBannerLater.
  ///
  /// In es, this message translates to:
  /// **'Ahora no'**
  String get whatsappBannerLater;

  /// No description provided for @homePendingPaymentsMore.
  ///
  /// In es, this message translates to:
  /// **'+ {count} cuotas más'**
  String homePendingPaymentsMore(int count);

  /// No description provided for @termsItemRightsTitle.
  ///
  /// In es, this message translates to:
  /// **'Tus derechos'**
  String get termsItemRightsTitle;

  /// No description provided for @termsItemRightsBody.
  ///
  /// In es, this message translates to:
  /// **'Puedes pedirnos qué información tuya hay en el servidor de Nexo, corregirla o eliminarla, y solicitar el registro de quién consultó tu ficha. También puedes renunciar a tu acceso al directorio cuando quieras. Escríbenos desde la sección de soporte para ejercer estos derechos o resolver cualquier duda sobre el tratamiento de tus datos.'**
  String get termsItemRightsBody;

  /// No description provided for @tabDirectory.
  ///
  /// In es, this message translates to:
  /// **'Estudiantes'**
  String get tabDirectory;

  /// No description provided for @directoryTitle.
  ///
  /// In es, this message translates to:
  /// **'Estudiantes'**
  String get directoryTitle;

  /// No description provided for @directorySubtitle.
  ///
  /// In es, this message translates to:
  /// **'Directorio institucional'**
  String get directorySubtitle;

  /// No description provided for @directoryCount.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =0{Sin estudiantes} =1{1 estudiante} other{{count} estudiantes}}'**
  String directoryCount(int count);

  /// No description provided for @directorySearchHint.
  ///
  /// In es, this message translates to:
  /// **'Buscar por nombre o código'**
  String get directorySearchHint;

  /// No description provided for @directoryFilterSchool.
  ///
  /// In es, this message translates to:
  /// **'Escuela'**
  String get directoryFilterSchool;

  /// No description provided for @directoryAllSchools.
  ///
  /// In es, this message translates to:
  /// **'Todas las escuelas'**
  String get directoryAllSchools;

  /// No description provided for @directoryCycle.
  ///
  /// In es, this message translates to:
  /// **'Ciclo {n}'**
  String directoryCycle(String n);

  /// No description provided for @directoryCredits.
  ///
  /// In es, this message translates to:
  /// **'{aprobados}/{total} créditos'**
  String directoryCredits(String aprobados, String total);

  /// No description provided for @directoryNoResults.
  ///
  /// In es, this message translates to:
  /// **'Sin resultados'**
  String get directoryNoResults;

  /// No description provided for @directoryNoResultsHint.
  ///
  /// In es, this message translates to:
  /// **'Prueba con otro nombre, código o filtro.'**
  String get directoryNoResultsHint;

  /// No description provided for @directoryEndOfList.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 estudiante en total} other{{count} estudiantes en total}}'**
  String directoryEndOfList(int count);

  /// No description provided for @directoryManageAccess.
  ///
  /// In es, this message translates to:
  /// **'Gestionar acceso'**
  String get directoryManageAccess;

  /// No description provided for @directoryDeniedTitle.
  ///
  /// In es, this message translates to:
  /// **'Sin acceso al directorio'**
  String get directoryDeniedTitle;

  /// No description provided for @directoryDeniedHint.
  ///
  /// In es, this message translates to:
  /// **'Tu cuenta no está autorizada. Pídeselo a un administrador del sistema.'**
  String get directoryDeniedHint;

  /// No description provided for @directoryUnavailableTitle.
  ///
  /// In es, this message translates to:
  /// **'No se pudo conectar'**
  String get directoryUnavailableTitle;

  /// No description provided for @directoryUnavailableHint.
  ///
  /// In es, this message translates to:
  /// **'Revisa tu conexión e inténtalo de nuevo.'**
  String get directoryUnavailableHint;

  /// No description provided for @directoryRecordTitle.
  ///
  /// In es, this message translates to:
  /// **'Ficha del estudiante'**
  String get directoryRecordTitle;

  /// No description provided for @directoryTabSummary.
  ///
  /// In es, this message translates to:
  /// **'Resumen'**
  String get directoryTabSummary;

  /// No description provided for @directoryTabGrades.
  ///
  /// In es, this message translates to:
  /// **'Notas'**
  String get directoryTabGrades;

  /// No description provided for @directoryTabSchedule.
  ///
  /// In es, this message translates to:
  /// **'Horario'**
  String get directoryTabSchedule;

  /// No description provided for @directoryTabPayments.
  ///
  /// In es, this message translates to:
  /// **'Pagos'**
  String get directoryTabPayments;

  /// No description provided for @directoryAverageShort.
  ///
  /// In es, this message translates to:
  /// **'Promedio'**
  String get directoryAverageShort;

  /// No description provided for @directoryEmptyModule.
  ///
  /// In es, this message translates to:
  /// **'Sin datos que mostrar.'**
  String get directoryEmptyModule;

  /// No description provided for @directoryRecordMissing.
  ///
  /// In es, this message translates to:
  /// **'Ficha no encontrada'**
  String get directoryRecordMissing;

  /// No description provided for @directoryRecordMissingHint.
  ///
  /// In es, this message translates to:
  /// **'Ese código ya no está en el directorio.'**
  String get directoryRecordMissingHint;

  /// No description provided for @directoryStatAverage.
  ///
  /// In es, this message translates to:
  /// **'Promedio'**
  String get directoryStatAverage;

  /// No description provided for @directoryStatCredits.
  ///
  /// In es, this message translates to:
  /// **'Créditos aprobados'**
  String get directoryStatCredits;

  /// No description provided for @directoryPersonalData.
  ///
  /// In es, this message translates to:
  /// **'Datos del estudiante'**
  String get directoryPersonalData;

  /// No description provided for @directoryFieldCode.
  ///
  /// In es, this message translates to:
  /// **'Código'**
  String get directoryFieldCode;

  /// No description provided for @directoryFieldEmail.
  ///
  /// In es, this message translates to:
  /// **'Correo'**
  String get directoryFieldEmail;

  /// No description provided for @directoryFieldPhone.
  ///
  /// In es, this message translates to:
  /// **'Teléfono'**
  String get directoryFieldPhone;

  /// No description provided for @directoryFieldFaculty.
  ///
  /// In es, this message translates to:
  /// **'Facultad'**
  String get directoryFieldFaculty;

  /// No description provided for @directoryFieldSchool.
  ///
  /// In es, this message translates to:
  /// **'Escuela'**
  String get directoryFieldSchool;

  /// No description provided for @directoryFieldPlan.
  ///
  /// In es, this message translates to:
  /// **'Plan'**
  String get directoryFieldPlan;

  /// No description provided for @directoryFieldEntry.
  ///
  /// In es, this message translates to:
  /// **'Ingreso'**
  String get directoryFieldEntry;

  /// No description provided for @directoryFieldStatus.
  ///
  /// In es, this message translates to:
  /// **'Condición'**
  String get directoryFieldStatus;

  /// No description provided for @directoryProgressByTerm.
  ///
  /// In es, this message translates to:
  /// **'Promedio por ciclo'**
  String get directoryProgressByTerm;

  /// No description provided for @directoryCourseCredits.
  ///
  /// In es, this message translates to:
  /// **'{value} créditos'**
  String directoryCourseCredits(String value);

  /// No description provided for @directoryAttendance.
  ///
  /// In es, this message translates to:
  /// **'Asistencia {value}%'**
  String directoryAttendance(String value);

  /// No description provided for @directoryNoUnits.
  ///
  /// In es, this message translates to:
  /// **'Sin desglose por unidades.'**
  String get directoryNoUnits;

  /// No description provided for @directoryPaymentsOverdue.
  ///
  /// In es, this message translates to:
  /// **'Vencidas'**
  String get directoryPaymentsOverdue;

  /// No description provided for @directoryPaymentsPending.
  ///
  /// In es, this message translates to:
  /// **'Pendientes'**
  String get directoryPaymentsPending;

  /// No description provided for @directoryAccessExplainer.
  ///
  /// In es, this message translates to:
  /// **'El acceso al directorio se concede por código. Los administradores del sistema se configuran en el servidor y no se pueden cambiar desde aquí.'**
  String get directoryAccessExplainer;

  /// No description provided for @directoryAdmins.
  ///
  /// In es, this message translates to:
  /// **'Administradores del sistema'**
  String get directoryAdmins;

  /// No description provided for @directoryAdminsHint.
  ///
  /// In es, this message translates to:
  /// **'Pueden entrar siempre y repartir el acceso.'**
  String get directoryAdminsHint;

  /// No description provided for @directoryGrantsActive.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =0{Con acceso} =1{Con acceso · 1} other{Con acceso · {count}}}'**
  String directoryGrantsActive(int count);

  /// No description provided for @directoryGrantsRevoked.
  ///
  /// In es, this message translates to:
  /// **'Acceso revocado'**
  String get directoryGrantsRevoked;

  /// No description provided for @directoryNoGrants.
  ///
  /// In es, this message translates to:
  /// **'Todavía no autorizaste a nadie.'**
  String get directoryNoGrants;

  /// No description provided for @directoryGrantAdd.
  ///
  /// In es, this message translates to:
  /// **'Dar acceso'**
  String get directoryGrantAdd;

  /// No description provided for @directoryGrantCodeLabel.
  ///
  /// In es, this message translates to:
  /// **'Código o DNI'**
  String get directoryGrantCodeLabel;

  /// No description provided for @directoryGrantCodeHelp.
  ///
  /// In es, this message translates to:
  /// **'Tal como aparece en la Intranet.'**
  String get directoryGrantCodeHelp;

  /// No description provided for @directoryGrantConfirm.
  ///
  /// In es, this message translates to:
  /// **'Conceder'**
  String get directoryGrantConfirm;

  /// No description provided for @directoryGrantFailed.
  ///
  /// In es, this message translates to:
  /// **'No se pudo cambiar el acceso.'**
  String get directoryGrantFailed;

  /// No description provided for @directoryGrantedBy.
  ///
  /// In es, this message translates to:
  /// **'Concedido por {code}'**
  String directoryGrantedBy(String code);

  /// No description provided for @directoryGrant.
  ///
  /// In es, this message translates to:
  /// **'Dar acceso'**
  String get directoryGrant;

  /// No description provided for @directoryRevoke.
  ///
  /// In es, this message translates to:
  /// **'Revocar'**
  String get directoryRevoke;

  /// No description provided for @directoryAdminOnlyTitle.
  ///
  /// In es, this message translates to:
  /// **'Solo administradores'**
  String get directoryAdminOnlyTitle;

  /// No description provided for @directoryAdminOnlyHint.
  ///
  /// In es, this message translates to:
  /// **'Repartir el acceso está reservado a los administradores del sistema.'**
  String get directoryAdminOnlyHint;

  /// No description provided for @termsHeaderUpdatedPre.
  ///
  /// In es, this message translates to:
  /// **'Cambiamos algo'**
  String get termsHeaderUpdatedPre;

  /// No description provided for @termsUpdatedNotice.
  ///
  /// In es, this message translates to:
  /// **'Actualizamos estos términos porque Nexo ahora incluye el apartado Estudiantes, que usa un servidor propio y puede mostrar datos de otras personas. Léelos de nuevo antes de continuar.'**
  String get termsUpdatedNotice;

  /// No description provided for @termsItemDirectoryTitle.
  ///
  /// In es, this message translates to:
  /// **'El apartado Estudiantes'**
  String get termsItemDirectoryTitle;

  /// No description provided for @termsItemDirectoryBody.
  ///
  /// In es, this message translates to:
  /// **'Es un directorio al que solo entran las cuentas autorizadas, y aparece en la app únicamente si la tuya lo está. Para comprobarlo, tu usuario y tu contraseña viajan una sola vez al servidor de Nexo, que los verifica contra SIGMA y no los guarda; a partir de ahí se usa una sesión temporal. Cada vez que abres la ficha de un estudiante queda registrado tu código, la fecha y a quién consultaste.'**
  String get termsItemDirectoryBody;

  /// No description provided for @termsItemThirdPartyTitle.
  ///
  /// In es, this message translates to:
  /// **'Datos de otras personas'**
  String get termsItemThirdPartyTitle;

  /// No description provided for @termsItemThirdPartyBody.
  ///
  /// In es, this message translates to:
  /// **'Si tienes acceso al directorio estarás viendo información de terceros. Úsala solo para aquello que te fue autorizado: no la descargues, copies, compartas ni publiques. La Ley 29733 de Protección de Datos Personales también te alcanza a ti, y el acceso puede revocarse en cualquier momento.'**
  String get termsItemThirdPartyBody;

  /// No description provided for @termsItemDemoDataTitle.
  ///
  /// In es, this message translates to:
  /// **'Datos de demostración'**
  String get termsItemDemoDataTitle;

  /// No description provided for @termsItemDemoDataBody.
  ///
  /// In es, this message translates to:
  /// **'Mientras no exista autorización institucional para consultar el directorio real, el apartado Estudiantes muestra datos generados para pruebas: personas que no existen. Cuando se sustituyan por datos reales actualizaremos estos términos y te pediremos aceptarlos otra vez.'**
  String get termsItemDemoDataBody;

  /// No description provided for @termsItemMicrosoftTitle.
  ///
  /// In es, this message translates to:
  /// **'Cuenta de Microsoft (opcional)'**
  String get termsItemMicrosoftTitle;

  /// No description provided for @termsItemMicrosoftBody.
  ///
  /// In es, this message translates to:
  /// **'Si conectas tu cuenta institucional de Microsoft, Nexo lee tus clases y tareas de Teams para mostrarlas en la app. La conexión es opcional, la autorizas tú desde el navegador y puedes desconectarla cuando quieras.'**
  String get termsItemMicrosoftBody;

  /// No description provided for @termsItemDeviceTitle.
  ///
  /// In es, this message translates to:
  /// **'Lo que queda en tu dispositivo'**
  String get termsItemDeviceTitle;

  /// No description provided for @termsItemDeviceBody.
  ///
  /// In es, this message translates to:
  /// **'Nexo guarda una copia local de tu horario, tus notas y tus pagos para funcionar sin conexión, y programa las notificaciones y los widgets en el propio dispositivo. Todo eso se borra al cerrar sesión.'**
  String get termsItemDeviceBody;

  /// No description provided for @termsItemChangesTitle.
  ///
  /// In es, this message translates to:
  /// **'Cambios en estos términos'**
  String get termsItemChangesTitle;

  /// No description provided for @termsItemChangesBody.
  ///
  /// In es, this message translates to:
  /// **'Si cambia algo importante en cómo se tratan tus datos, actualizaremos estos términos y volveremos a mostrártelos antes de que sigas usando la app. Puedes releerlos cuando quieras desde Perfil, en Términos y privacidad.'**
  String get termsItemChangesBody;

  /// No description provided for @termsVersionLine.
  ///
  /// In es, this message translates to:
  /// **'Versión {version} · Actualizado el {date}'**
  String termsVersionLine(String version, String date);

  /// No description provided for @directoryClearFilters.
  ///
  /// In es, this message translates to:
  /// **'Limpiar filtros'**
  String get directoryClearFilters;

  /// No description provided for @directoryFieldCycle.
  ///
  /// In es, this message translates to:
  /// **'Ciclo'**
  String get directoryFieldCycle;

  /// No description provided for @directoryCumulativeAverage.
  ///
  /// In es, this message translates to:
  /// **'Promedio acumulado'**
  String get directoryCumulativeAverage;

  /// No description provided for @directoryApprovedCourses.
  ///
  /// In es, this message translates to:
  /// **'Cursos aprobados'**
  String get directoryApprovedCourses;

  /// No description provided for @directoryCoursesCount.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 curso} other{{count} cursos}}'**
  String directoryCoursesCount(int count);

  /// No description provided for @directoryOverdueCount.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 vencida} other{{count} vencidas}}'**
  String directoryOverdueCount(int count);

  /// No description provided for @guardianEntry.
  ///
  /// In es, this message translates to:
  /// **'Soy padre, madre o apoderado'**
  String get guardianEntry;

  /// No description provided for @guardianTitle.
  ///
  /// In es, this message translates to:
  /// **'Acceso de apoderado'**
  String get guardianTitle;

  /// No description provided for @guardianHeadline.
  ///
  /// In es, this message translates to:
  /// **'Consulta la ficha de tu hijo'**
  String get guardianHeadline;

  /// No description provided for @guardianIntro.
  ///
  /// In es, this message translates to:
  /// **'Ingresa con tu DNI y el PIN que te entregaron. No necesitas cuenta de la universidad.'**
  String get guardianIntro;

  /// No description provided for @guardianDniLabel.
  ///
  /// In es, this message translates to:
  /// **'DNI'**
  String get guardianDniLabel;

  /// No description provided for @guardianDniInvalid.
  ///
  /// In es, this message translates to:
  /// **'Ingresa los 8 dígitos de tu DNI'**
  String get guardianDniInvalid;

  /// No description provided for @guardianPinLabel.
  ///
  /// In es, this message translates to:
  /// **'PIN'**
  String get guardianPinLabel;

  /// No description provided for @guardianPinHelp.
  ///
  /// In es, this message translates to:
  /// **'Los 6 dígitos que te dio la universidad'**
  String get guardianPinHelp;

  /// No description provided for @guardianPinInvalid.
  ///
  /// In es, this message translates to:
  /// **'El PIN tiene 6 dígitos'**
  String get guardianPinInvalid;

  /// No description provided for @guardianEnter.
  ///
  /// In es, this message translates to:
  /// **'Entrar'**
  String get guardianEnter;

  /// No description provided for @guardianBadCredentials.
  ///
  /// In es, this message translates to:
  /// **'DNI o PIN incorrectos. Revísalos e inténtalo de nuevo.'**
  String get guardianBadCredentials;

  /// No description provided for @guardianLocked.
  ///
  /// In es, this message translates to:
  /// **'Demasiados intentos fallidos. Espera unos minutos antes de volver a probar.'**
  String get guardianLocked;

  /// No description provided for @guardianUnavailable.
  ///
  /// In es, this message translates to:
  /// **'No se pudo conectar. Revisa tu conexión e inténtalo de nuevo.'**
  String get guardianUnavailable;

  /// No description provided for @guardianAuditNotice.
  ///
  /// In es, this message translates to:
  /// **'Cada consulta queda registrada.'**
  String get guardianAuditNotice;

  /// No description provided for @guardianPickTitle.
  ///
  /// In es, this message translates to:
  /// **'¿A quién quieres ver?'**
  String get guardianPickTitle;

  /// No description provided for @guardianNoStudents.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay ningún estudiante vinculado a tu DNI.'**
  String get guardianNoStudents;

  /// No description provided for @guardianSignOut.
  ///
  /// In es, this message translates to:
  /// **'Salir'**
  String get guardianSignOut;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'qu'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'qu':
      return AppLocalizationsQu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
