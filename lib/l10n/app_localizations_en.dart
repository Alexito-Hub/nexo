// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get tabHome => 'Home';

  @override
  String get tabSchedule => 'Schedule';

  @override
  String get tabGrades => 'Grades';

  @override
  String get tabPayments => 'Payments';

  @override
  String get tabTeacher => 'Teacher';

  @override
  String get tabCourses => 'Courses';

  @override
  String get tabProfile => 'Profile';

  @override
  String get titleHome => 'Home';

  @override
  String get titleSchedule => 'Schedule';

  @override
  String get titleGrades => 'Grades';

  @override
  String get titlePayments => 'Payments';

  @override
  String get titleProfile => 'Profile';

  @override
  String get titleTeacher => 'Teacher';

  @override
  String get titleCourses => 'My courses';

  @override
  String get subtitleCourses => 'Subjects you teach';

  @override
  String get titleAbout => 'About Nexo';

  @override
  String get titleTerms => 'Terms & Privacy';

  @override
  String get titleDeveloper => 'Developer';

  @override
  String get titleChangePassword => 'Change password';

  @override
  String get titleNotifications => 'Notifications';

  @override
  String get subtitlePayments => 'Fees, charges and history';

  @override
  String get subtitleTeacher => 'Your courses and students';

  @override
  String get language => 'Language';

  @override
  String get timeFormat => 'Time format';

  @override
  String get hours24 => '24-hour';

  @override
  String get hours12 => '12-hour';

  @override
  String get actionLogout => 'Sign out';

  @override
  String get actionAccept => 'Accept';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionRetry => 'Retry';

  @override
  String get actionClose => 'Close';

  @override
  String get actionCopy => 'Copy';

  @override
  String get scheduleDetailTitle => 'Class details';

  @override
  String get detailSchedule => 'Schedule';

  @override
  String get detailLocation => 'Location';

  @override
  String get detailRoom => 'Room';

  @override
  String get detailPavilion => 'Building';

  @override
  String weekdayFull(String day) {
    String _temp0 = intl.Intl.selectLogic(day, {
      'mon': 'Monday',
      'tue': 'Tuesday',
      'wed': 'Wednesday',
      'thu': 'Thursday',
      'fri': 'Friday',
      'sat': 'Saturday',
      'sun': 'Sunday',
      'other': '—',
    });
    return '$_temp0';
  }

  @override
  String weekdayShort(String day) {
    String _temp0 = intl.Intl.selectLogic(day, {
      'mon': 'Mon',
      'tue': 'Tue',
      'wed': 'Wed',
      'thu': 'Thu',
      'fri': 'Fri',
      'sat': 'Sat',
      'sun': 'Sun',
      'other': '—',
    });
    return '$_temp0';
  }

  @override
  String monthShort(String month) {
    String _temp0 = intl.Intl.selectLogic(month, {
      'jan': 'Jan',
      'feb': 'Feb',
      'mar': 'Mar',
      'apr': 'Apr',
      'may': 'May',
      'jun': 'Jun',
      'jul': 'Jul',
      'aug': 'Aug',
      'sep': 'Sep',
      'oct': 'Oct',
      'nov': 'Nov',
      'dec': 'Dec',
      'other': '—',
    });
    return '$_temp0';
  }

  @override
  String timeGreeting(String period) {
    String _temp0 = intl.Intl.selectLogic(period, {
      'morning': 'Good morning',
      'afternoon': 'Good afternoon',
      'evening': 'Good evening',
      'other': 'Hello',
    });
    return '$_temp0';
  }

  @override
  String get detailBuilding => 'Building';

  @override
  String get detailCampus => 'Campus';

  @override
  String get detailTeacher => 'Teacher';

  @override
  String get detailSessions => 'Sessions';

  @override
  String get detailNotes => 'Notes';

  @override
  String get detailNrc => 'NRC';

  @override
  String get detailSection => 'Sec.';

  @override
  String get detailLevel => 'Level';

  @override
  String get detailToday => 'TODAY';

  @override
  String detailDuration(int minutes) {
    return 'Total duration: $minutes minutes';
  }

  @override
  String get tabTeams => 'Teams';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsPalette => 'Palette';

  @override
  String get settingsSystem => 'System';

  @override
  String get settingsSystemDesc => 'Follow your device light/dark mode';

  @override
  String get settingsActive => 'Active';

  @override
  String get settingsNotificationsSubtitle => 'Reminders and alerts';

  @override
  String get notificationsIntro =>
      'Get alerts for your classes, payments, and grades. Customize what arrives and how early.';

  @override
  String get notificationsClassesTitle => 'Classes';

  @override
  String get notificationsClassesSubtitle => 'Alert before each class';

  @override
  String get notificationsPaymentsTitle => 'Payments';

  @override
  String get notificationsPaymentsSubtitle => 'Alert before each due date';

  @override
  String get notificationsNotifyMe => 'Notify me';

  @override
  String notificationsPaymentHour(String hour) {
    return 'Alert time: $hour:00';
  }

  @override
  String get notificationsGradesTitle => 'Grades';

  @override
  String get notificationsGradesSubtitle => 'Alert when a new grade is posted';

  @override
  String get notificationsEnableTitle => 'Enable notifications';

  @override
  String get notificationsEnabledLabel => 'Enabled';

  @override
  String get notificationsDisabledLabel => 'Disabled';

  @override
  String get notificationsInfoNote =>
      'Classes and payments are scheduled on your device. Grades are detected when you open the app and sync.';

  @override
  String get homeTodayTitle => 'Today';

  @override
  String get homeScheduleLoadError => 'Couldn\'t load the schedule';

  @override
  String get homeSeeFullWeek => 'See full week';

  @override
  String get homePendingPaymentsTitle => 'Pending payments';

  @override
  String get homePaymentsLoadError => 'Couldn\'t load payments';

  @override
  String get homeSeeAllPayments => 'See all payments';

  @override
  String get schedulePeriodActive => 'Active term';

  @override
  String schedulePeriodActiveCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Active term · $count classes',
      one: 'Active term · $count class',
      zero: 'Active term',
    );
    return '$_temp0';
  }

  @override
  String get scheduleErrorTitle => 'Error';

  @override
  String get scheduleLoadError => 'Couldn\'t load the schedule';

  @override
  String get scheduleNoClassesTitle => 'No classes';

  @override
  String get scheduleNoClassesSubtitle => 'No classes recorded';

  @override
  String get scheduleToggleWeek => 'Week';

  @override
  String get scheduleToggleList => 'List';

  @override
  String get scheduleNoClassesScheduled => 'No classes scheduled';

  @override
  String get gradesTitle => 'Grades';

  @override
  String get gradesSubtitleNoPeriod => 'Grade report';

  @override
  String gradesSubtitleUnits(String period) {
    return 'By units · $period';
  }

  @override
  String gradesSubtitlePartials(String period) {
    return 'By partials · $period';
  }

  @override
  String get gradesSelectPeriod => 'Select a term';

  @override
  String get gradesSubjects => 'Subjects';

  @override
  String get gradesLoadError => 'Couldn\'t load the report card';

  @override
  String get gradesNoNotesTitle => 'No grades for this term';

  @override
  String get gradesNoNotesSubtitleNewModel =>
      'Unit report applies from 2026-1.';

  @override
  String gradesSubjectsWithPeriod(String period) {
    return 'Subjects · $period';
  }

  @override
  String gradesCoursesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count courses',
      one: '$count course',
    );
    return '$_temp0';
  }

  @override
  String get teamsSubtitle => 'Your classes and assignments from Microsoft 365';

  @override
  String get teamsDisconnect => 'Disconnect';

  @override
  String get teamsMySubjects => 'My subjects';

  @override
  String get teamsAssignments => 'Assignments';

  @override
  String get teamsLoadError => 'Couldn\'t load';

  @override
  String get teamsConnectTitle => 'Connect your Microsoft account';

  @override
  String get teamsConnectSubtitle =>
      'To see your Teams classes and assignments';

  @override
  String get teamsConnectBody =>
      'Sign in with your institutional Microsoft 365 account. We\'ll give you a code to confirm in the browser.';

  @override
  String get teamsConnectButton => 'Connect with Microsoft';

  @override
  String get teamsDeviceCodeGenerating => 'Generating code…';

  @override
  String get teamsDeviceCodeConfirmTitle => 'Confirm in the browser';

  @override
  String get teamsDeviceCodeConfirmSubtitle =>
      'Waiting for you to authorize the app…';

  @override
  String get teamsDeviceCodeStep1Prefix => 'Open ';

  @override
  String get teamsCopyLink => 'Copy link';

  @override
  String get teamsLinkCopied => 'Link copied';

  @override
  String get teamsDeviceCodeStep2Label => 'Enter this code:';

  @override
  String get teamsDeviceCodeAutoRefresh =>
      'This will update automatically when you\'re done.';

  @override
  String get teamsCodeCopied => 'Code copied';

  @override
  String get actionShow => 'Show';

  @override
  String get actionHide => 'Hide';

  @override
  String get actionSkip => 'Skip';

  @override
  String get actionNext => 'Next';

  @override
  String get validationRequired => 'Required';

  @override
  String get changePasswordSuccess => 'Password updated successfully.';

  @override
  String get changePasswordHeader => 'Set your new password';

  @override
  String get changePasswordSubheader =>
      'It will apply to all institutional services that use your UPLA account.';

  @override
  String get changePasswordCurrentLabel => 'Current password';

  @override
  String get changePasswordNewLabel => 'New password';

  @override
  String get changePasswordRepeatLabel => 'Repeat new password';

  @override
  String changePasswordMinChars(int min) {
    return 'Minimum $min characters';
  }

  @override
  String get changePasswordMustBeDifferent =>
      'Must be different from the current one';

  @override
  String get changePasswordNoMatch => 'Does not match';

  @override
  String get changePasswordUpdateButton => 'Update password';

  @override
  String get loginWelcomeBack => 'Welcome back';

  @override
  String get loginIntro =>
      'Sign in with your institutional account. We\'ll keep your session so you don\'t have to log in again.';

  @override
  String get loginUserLabel => 'Code or DNI';

  @override
  String get loginUserRequired => 'Enter your user';

  @override
  String get loginPasswordLabel => 'Password';

  @override
  String get loginPasswordRequired => 'Enter your password';

  @override
  String get loginCapsLockOn => 'Caps Lock is on';

  @override
  String get loginSubmit => 'Sign in';

  @override
  String get loginDeviceOnly =>
      'Your credentials are stored only on this device';

  @override
  String get loginBrandTagline => 'Your UPLA academic life,\nin one place.';

  @override
  String get loginFeatureSchedule => 'Schedule and next class at a glance';

  @override
  String get loginFeaturePayments => 'Payments, due dates, and alerts';

  @override
  String get loginFeatureGrades => 'Grades and academic progress';

  @override
  String get loginFeatureWidgets => 'Widgets on your home screen';

  @override
  String get onboardingTitleWelcome => 'Welcome to Nexo';

  @override
  String get onboardingBodyWelcome =>
      'Your UPLA academic life reimagined: clear, fast, and always with you.';

  @override
  String get onboardingTitleSchedule => 'Smart schedule';

  @override
  String get onboardingBodySchedule =>
      'Today\'s classes and the next class with a countdown. Theory and practice in one view.';

  @override
  String get onboardingTitlePayments => 'Payments without surprises';

  @override
  String get onboardingBodyPayments =>
      'Pending and overdue fees, charges, and history. You\'ll know how much and when to pay.';

  @override
  String get onboardingTitleWidgets => 'Widgets on your screen';

  @override
  String get onboardingBodyWidgets =>
      'Add Android home screen widgets: next class, payments, and your average at a glance.';

  @override
  String get onboardingStart => 'Get started';

  @override
  String get wifiTitle => 'Institutional Wi-Fi';

  @override
  String get wifiSubtitle => 'Same institutional UPLA account';

  @override
  String get wifiUserLabel => 'USER';

  @override
  String get wifiPasswordLabel => 'PASSWORD';

  @override
  String get wifiUserCopied => 'User copied';

  @override
  String get wifiPasswordCopied => 'Password copied';

  @override
  String get actionSave => 'Save';

  @override
  String get actionCodeCopied => 'Code copied';

  @override
  String get profileSettingsSubtitle =>
      'Appearance, language, time and notifications';

  @override
  String get profileChangePasswordSubtitle =>
      'For your institutional UPLA account';

  @override
  String profileAboutSubtitle(String version) {
    return 'Version $version';
  }

  @override
  String get logoutConfirmTitle => 'Sign out';

  @override
  String get logoutConfirmBody => 'Do you want to sign out of your account?';

  @override
  String get docenteChangeDate => 'Change';

  @override
  String get docenteSaveAttendance => 'Save attendance';

  @override
  String get docenteAttendanceSaved => 'Attendance saved';

  @override
  String docenteAttendanceError(String error) {
    return 'Error: $error';
  }

  @override
  String get docenteGradeLabel => 'Grade (0 - 20)';

  @override
  String get docenteGradeEnter => 'Enter a grade';

  @override
  String get docenteGradeInvalidNumber => 'Invalid number';

  @override
  String get docenteGradeRange => 'Between 0 and 20';

  @override
  String get termsHeaderPre => 'Before you start';

  @override
  String get termsHeaderTitle => 'Terms of use and privacy';

  @override
  String get termsHeaderSubtitle =>
      'Read them carefully and accept to continue.';

  @override
  String get termsAcceptNote => 'By continuing you accept these terms.';

  @override
  String get termsAcceptButton => 'Accept and continue';

  @override
  String get termsBrandTitle => 'Welcome to Nexo';

  @override
  String get termsBrandBody =>
      'Privacy first. Here we tell you what stays on your device and what leaves it.';

  @override
  String get termsItemWhatTitle => 'What is Nexo';

  @override
  String get termsItemWhatBody =>
      'An independent, unofficial app created by and for students that reorganizes your UPLA academic information more clearly. It is not affiliated with or endorsed by UPLA.';

  @override
  String get termsItemPrivacyTitle => 'Your data and privacy';

  @override
  String get termsItemPrivacyBody =>
      'Your credentials and academic data are stored only on your device, and requests go straight to UPLA services, just like the official portal. The only exception is the Students section, which does go through a Nexo server: we explain it right below.';

  @override
  String get termsItemSecurityTitle => 'Security';

  @override
  String get termsItemSecurityBody =>
      'Local storage is not encrypted at the system level, so use Nexo only on devices you trust. The session with the Nexo server lives in memory and is lost when you close the app. You can sign out to wipe credentials and cache at any time.';

  @override
  String get termsItemResponsibleTitle => 'Responsible use';

  @override
  String get termsItemResponsibleBody =>
      'Use your own credentials and access only the information that belongs to you or that you have been authorized to see. This is an educational, personal-use project: use it in line with your university\'s rules.';

  @override
  String get termsItemDisclaimerTitle => 'No guarantees';

  @override
  String get termsItemDisclaimerBody =>
      'The service is provided \"as is\", without warranties. For official procedures, always consult the institutional portal.';

  @override
  String get aboutFeatureAllInOneTitle => 'Your university in one place';

  @override
  String get aboutFeatureAllInOneBody =>
      'Profile, schedule, grades, payments, and upcoming tasks without jumping between SIGMA, Intranet, and other portals.';

  @override
  String get aboutFeatureMultiplatformTitle => 'Multiplatform';

  @override
  String get aboutFeatureMultiplatformBody =>
      'Same experience on Android, iOS, Web, and desktop, with a single Flutter codebase.';

  @override
  String get aboutFeaturePrivacyTitle => 'Privacy first';

  @override
  String get aboutFeaturePrivacyBody =>
      'Your credentials are stored only on your device. Requests go directly to UPLA services, without intermediate servers.';

  @override
  String get aboutFeatureNoSdkTitle => 'No third-party SDKs';

  @override
  String get aboutFeatureNoSdkBody =>
      'Authentication and networking built by hand on standard HTTP, to control errors and keep it lightweight.';

  @override
  String get aboutFooterDisclaimer =>
      'Nexo is an independent, unofficial project, created by and for students. It is not affiliated with or endorsed by UPLA.';

  @override
  String aboutHeroSubtitle(String version) {
    return 'UPLA client · v$version';
  }

  @override
  String get aboutDetailsTitle => 'Details';

  @override
  String get aboutDetailsVersionLabel => 'Version';

  @override
  String get aboutDetailsBuildLabel => 'Build';

  @override
  String get aboutDetailsPlatformsLabel => 'Platforms';

  @override
  String get aboutDetailsPlatformsValue => 'Android · iOS · Web · Desktop';

  @override
  String get aboutDetailsTechLabel => 'Technology';

  @override
  String get aboutDetailsTechValue => 'Flutter';

  @override
  String get developerGithubCopied => 'GitHub link copied';

  @override
  String get developerSubtitle => 'Who created Nexo';

  @override
  String get developerRole => 'Independent developer · UPLA student';

  @override
  String get supportTitle => 'Technical Support';

  @override
  String get supportHeroBadge => 'SUPPORT 24/7';

  @override
  String get supportHeroTitle => 'Having any issues?';

  @override
  String get supportHeroBody =>
      'We\'re here to help. If you experience app crashes, connection issues or data errors, contact us directly via WhatsApp or email.';

  @override
  String get supportChannelsTitle => 'Support Channels';

  @override
  String get supportChannelWhatsApp => 'WhatsApp';

  @override
  String get supportChannelEmail => 'Email';

  @override
  String get supportInfoNote =>
      'Pressing the support channel will open the corresponding application. Otherwise, the contact details will be copied to your clipboard.';

  @override
  String get supportWhatsAppMessage =>
      'Hi, I have an issue with the Nexo application';

  @override
  String get supportWhatsAppCopied => 'Support WhatsApp number copied';

  @override
  String get supportEmailSubject => 'Support Nexo App';

  @override
  String get supportEmailBody =>
      'Hi, I have an issue with the Nexo application:';

  @override
  String get supportEmailCopied => 'Support email copied';

  @override
  String get supportContactButton => 'Contact Technical Support';

  @override
  String get docenteLabel => 'TEACHER';

  @override
  String get docenteCodeLabel => 'Teacher code';

  @override
  String get docenteMetricCursos => 'Courses';

  @override
  String get docenteMetricAlumnos => 'Students';

  @override
  String get docenteMetricPeriodo => 'Term';

  @override
  String get docenteNoClassesToday => 'No classes to teach today';

  @override
  String get docenteToday => 'Today';

  @override
  String docenteClassCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count classes',
      one: '$count class',
    );
    return '$_temp0';
  }

  @override
  String get docenteTypeTeoria => 'THEO';

  @override
  String get docenteTypePractica => 'PRAC';

  @override
  String get docenteLoadingClasses => 'Loading classes...';

  @override
  String docenteSessionsWeeklyCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sessions this week',
      one: '1 session this week',
    );
    return 'My classes · $_temp0';
  }

  @override
  String get docenteNoClassesRegistered => 'You have no registered classes';

  @override
  String docenteCourseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count courses',
      one: '$count course',
    );
    return '$_temp0';
  }

  @override
  String docenteCoursesCountPlural(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count subjects',
      one: '$count subject',
    );
    return '$_temp0';
  }

  @override
  String docenteMetricAlumnosCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count students',
      one: '$count student',
    );
    return '$_temp0';
  }

  @override
  String get docenteLoadCoursesError => 'Could not load courses';

  @override
  String get docenteNoCoursesPeriod => 'No assigned courses in this term';

  @override
  String get docenteTabAlumnos => 'Students';

  @override
  String get docenteTabAsistencia => 'Attendance';

  @override
  String get docenteTabNotas => 'Grades';

  @override
  String get docenteNoCode => 'No code';

  @override
  String docenteSectionPeriod(String seccion, String periodo) {
    return 'Section $seccion · $periodo';
  }

  @override
  String get docenteNoAlumnosRegistered => 'No registered students';

  @override
  String docenteAsisPercent(String percent) {
    return '$percent% attend.';
  }

  @override
  String get docenteAttendancePresentShort => 'Pres.';

  @override
  String get docenteAttendanceTardanzaShort => 'Late';

  @override
  String get docenteAttendanceFaltaShort => 'Abs.';

  @override
  String get docenteNoAlumnosInCourse => 'No students in this course';

  @override
  String docenteAprobadosCount(String aprobados, String total) {
    return '$aprobados of $total passed';
  }

  @override
  String get docenteTapToEdit => 'Tap to edit →';

  @override
  String get docentePromedioParcial => 'PARTIAL AVERAGE';

  @override
  String docenteCoursePercentGraded(String percent) {
    return '$percent% of the course\nalready graded';
  }

  @override
  String get docenteEvalPending => 'PENDING';

  @override
  String get docenteNoAttendanceRecords => 'No attendance records.';

  @override
  String get docenteAttendanceLabel => 'ATTENDANCE';

  @override
  String docenteSessionsRegisteredCount(String presentes, String total) {
    return '$presentes of $total\nsessions recorded';
  }

  @override
  String get docenteAttendancePresent => 'Present';

  @override
  String get docenteAttendanceTardanza => 'Late';

  @override
  String get docenteAttendanceFalta => 'Absent';

  @override
  String get docenteAttendanceJustificada => 'Excused';

  @override
  String get docenteInfoTitle => 'Teacher information';

  @override
  String get docenteInfoFieldNombres => 'First Names';

  @override
  String get docenteInfoFieldApellidos => 'Last Names';

  @override
  String get docenteInfoFieldFacultad => 'Faculty';

  @override
  String get docenteInfoFieldEspecialidad => 'Specialty';

  @override
  String get docenteSupportSubtitle => 'Contact via WhatsApp or Email';

  @override
  String get connectivityStatusTitle => 'Connection Status';

  @override
  String get connectivityDiagnosticsSubtitle => 'Real-time diagnostics';

  @override
  String get connectivityInternet => 'Internet Connection';

  @override
  String get connectivitySigma => 'SIGMA Server';

  @override
  String get connectivityIntranet => 'INTRANET Server';

  @override
  String get connectivityBackupNote =>
      'Local backup data will be used automatically when there is no connection to the servers.';

  @override
  String get connectivityOnline => 'Online';

  @override
  String get connectivityOffline => 'Offline';

  @override
  String get connectivityDegraded => 'Degraded';

  @override
  String get connectivityConnected => 'Connected';

  @override
  String get connectivityDisconnected => 'Disconnected';

  @override
  String get homeVerifyConnectivity => 'Verify Connection Status';

  @override
  String get homeMetricPromedio => 'GPA';

  @override
  String get homeMetricPromedioCiclo => 'Term GPA';

  @override
  String get homeMetricPromedioAcumulado => 'Cumulative';

  @override
  String get homeMetricCreditos => 'Credits';

  @override
  String get homeMetricClasesHoy => 'Classes today';

  @override
  String get homeMetricPorPagar => 'To pay';

  @override
  String get gradesDetailLoadError => 'Couldn\'t load detail';

  @override
  String get gradesSustitutorio => 'Substitute exam';

  @override
  String get gradesNoUnitsYetTitle => 'No units graded yet';

  @override
  String get gradesNoUnitsYetSubtitle => 'Grades will appear when published.';

  @override
  String get gradesEvidenciaConocimiento => 'Evidence of knowledge';

  @override
  String get gradesEvidenciaDesempeno => 'Evidence of performance';

  @override
  String get gradesEvidenciaProducto => 'Evidence of product';

  @override
  String get gradesPromedioAcumulado => 'Cumulative GPA';

  @override
  String get gradesNoCreditsData => 'No credit data';

  @override
  String get gradesNoHistoryYet => 'No history yet';

  @override
  String get gradesEvolutionByPeriod => 'Evolution by term';

  @override
  String get statusInProcess => 'IN PROGRESS';

  @override
  String get paymentsFilterAll => 'All';

  @override
  String get paymentsNoneInPeriod => 'No payments in this period';

  @override
  String homeMoreClassesToday(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+ $count more classes today',
      one: '+ 1 more class today',
    );
    return '$_temp0';
  }

  @override
  String get statusApproved => 'PASSED';

  @override
  String get statusFailed => 'FAILED';

  @override
  String get gradesPromedioLabel => 'Average';

  @override
  String get gradesParcial1 => 'Partial 1';

  @override
  String get gradesParcial2 => 'Partial 2';

  @override
  String get gradesPromedioParcial1 => 'Partial 1 Average';

  @override
  String get gradesPromedioParcial2 => 'Partial 2 Average';

  @override
  String get gradesPromedioFinal => 'Final Average';

  @override
  String get gradesPrimerParcial => 'First partial';

  @override
  String get gradesSegundoParcial => 'Second partial';

  @override
  String get gradesPromedioPracticas => 'Practical average';

  @override
  String get gradesTrabajoInvestigacion => 'Research paper';

  @override
  String get gradesExamenParcial => 'Partial exam';

  @override
  String get gradesExamenComplementario => 'Complementary exam';

  @override
  String get paymentsDownloadSchedulePdf => 'Download schedule (PDF)';

  @override
  String get paymentsTabPending => 'Pending';

  @override
  String get paymentsTabOverdue => 'Overdue';

  @override
  String get paymentsTabFees => 'Fees';

  @override
  String get paymentsUpToDateTitle => 'You are up to date!';

  @override
  String get paymentsUpToDateSubtitle => 'You have no upcoming fees.';

  @override
  String get paymentsNoOverdueTitle => 'No overdue fees';

  @override
  String get paymentsNoOverdueSubtitle => 'Great, you have no past due fees.';

  @override
  String get paymentVenceHoy => 'DUE TODAY';

  @override
  String get paymentVenceManana => 'Due tomorrow';

  @override
  String get paymentVenceMananaCaps => 'DUE TOMORROW';

  @override
  String get paymentsNoFeesRegistered => 'No fees registered';

  @override
  String get paymentsNoHistoryRegistered => 'No payments registered';

  @override
  String get paymentDetailCuota => 'Fee Detail';

  @override
  String get paymentDetailTasa => 'Charge Detail';

  @override
  String get paymentDetailPago => 'Payment Detail';

  @override
  String get paymentDetailTasaAdministrativa => 'Administrative Fee';

  @override
  String get paymentDetailImporteBase => 'Base Amount';

  @override
  String get paymentDetailFechaVencimiento => 'Due Date';

  @override
  String get paymentDetailImportePagado => 'Amount Paid';

  @override
  String get paymentDetailFechaPago => 'Payment Date';

  @override
  String get paymentDetailHoraPago => 'Payment Time';

  @override
  String get paymentDetailPeriodoAcademico => 'Academic Period';

  @override
  String get paymentDetailLugarPago => 'Payment Location';

  @override
  String get paymentDetailDescripcionOperacion => 'Operation Description';

  @override
  String get paymentDetailInformacionDetallada => 'Detailed Information';

  @override
  String get profileDownloadEnrollmentPdf => 'Enrollment Certificate (PDF)';

  @override
  String get profileStudentCode => 'Student code';

  @override
  String get profileCareer => 'Career';

  @override
  String get profileFaculty => 'Faculty';

  @override
  String get profileCampus => 'Campus';

  @override
  String get profileMode => 'Mode';

  @override
  String get profileStudyPlan => 'Study plan';

  @override
  String get profileLevel => 'Level';

  @override
  String get profileLastEnrollment => 'Last enrollment';

  @override
  String get profileStatus => 'Status';

  @override
  String get profileStatusNotEnrolled => 'Not enrolled';

  @override
  String get profileStatusEnrolled => 'Enrolled';

  @override
  String get profileAcademicInfo => 'Academic info';

  @override
  String get teamsCopyCode => 'Copy code';

  @override
  String get teamsUnderConstruction => 'Under construction';

  @override
  String get teamsSoonAvailable => 'Soon available';

  @override
  String get teamsWorkingOnSection => 'We are working on this section';

  @override
  String get teamsComeBackLater => 'Come back later.';

  @override
  String get pdfExportLoadConstanciaError => 'Could not load certificate.';

  @override
  String get pdfExportLoadCronogramaError => 'Could not load payment schedule.';

  @override
  String gradesCreditsSummary(String aprobados, String total) {
    return '$aprobados of $total credits';
  }

  @override
  String gradesCreditsApprovedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count credits approved',
      one: '1 credit approved',
    );
    return '$_temp0';
  }

  @override
  String gradesRank(String rank) {
    return ' · Rank $rank';
  }

  @override
  String get gradesSummary => 'Summary';

  @override
  String gradesPractice(String index) {
    return 'Practice $index';
  }

  @override
  String get gradesProyecto => 'Project';

  @override
  String get gradesPromedioTiPy => 'Average RP + PJ';

  @override
  String get paymentsTabHistory => 'History';

  @override
  String get paymentsLoadError => 'Couldn\'t load';

  @override
  String paymentDaysOverdue(String days) {
    return 'OVERDUE $days d. ago';
  }

  @override
  String paymentDaysLeft(String days) {
    return 'In $days days';
  }

  @override
  String paymentMora(String currency, String amount) {
    return 'Late fee $currency $amount';
  }

  @override
  String paymentVenceEl(String date) {
    return 'Due on $date';
  }

  @override
  String get paymentStatusPaid => 'PAID';

  @override
  String paymentDateOfPayment(String date) {
    return 'Payment Date: $date';
  }

  @override
  String get paymentMoraLabel => 'Late fee';

  @override
  String get paymentDetailObservacion => 'Note';

  @override
  String get paymentDetailConcepto => 'Concept';

  @override
  String get paymentDetailImporte => 'Amount';

  @override
  String get paymentDetailComprobante => 'Receipt';

  @override
  String get paymentDetailOperacion => 'Transaction';

  @override
  String get setupTitle => 'Welcome to Nexo UPLA!';

  @override
  String get setupSubtitle =>
      'We have detected that you are running the application outside the official installation directory.';

  @override
  String get setupBtnInstall => 'Install on my Computer';

  @override
  String get setupBtnPortable => 'Run in Portable Mode';

  @override
  String get setupPortableDesc =>
      'Portable mode will not create shortcuts or register the app in Windows.';

  @override
  String get setupProgressCopied => 'Copying program files...';

  @override
  String get setupProgressShortcuts => 'Creating shortcuts...';

  @override
  String get setupProgressRegister => 'Registering in Windows...';

  @override
  String get setupProgressDone => 'Installation completed successfully!';

  @override
  String get setupSuccessTitle => 'Installation Successful!';

  @override
  String get setupSuccessDesc =>
      'Nexo UPLA has been successfully installed and registered.';

  @override
  String get setupBtnStart => 'Start Application';

  @override
  String get setupErrorTitle => 'Installation Error';

  @override
  String get setupBtnRetry => 'Retry';

  @override
  String get setupBtnExit => 'Exit';

  @override
  String get setupCustomization => 'Customization';

  @override
  String get setupTermsAccept =>
      'I have read and accept the terms of use and privacy policy';

  @override
  String get setupTermsRequired => 'You must accept the terms to continue';

  @override
  String get setupOptionDesktop => 'Create desktop shortcut';

  @override
  String get setupOptionStartMenu => 'Create Start Menu entry';

  @override
  String get setupOptionAutoStart => 'Start Nexo with Windows';

  @override
  String get setupOptionAutoStartDesc =>
      'It will open automatically when you sign in';

  @override
  String get setupProgressAutoStart => 'Setting up auto-start...';

  @override
  String get setupBtnBack => 'Back';

  @override
  String get setupBtnNext => 'Next';

  @override
  String get setupBtnInstallNow => 'Install';

  @override
  String get updTitle => 'Updates';

  @override
  String get updInstalledVersion => 'Installed version';

  @override
  String get updStatusChecking => 'Checking…';

  @override
  String get updStatusAvailable => 'Available';

  @override
  String get updStatusUpToDate => 'Up to date';

  @override
  String get updStatusUnknown => 'Not checked';

  @override
  String get updCheck => 'Check for updates';

  @override
  String get updInstallNow => 'Install now';

  @override
  String get updDownloadInstall => 'Download and install';

  @override
  String updAvailableLine(String version) {
    return 'Nexo $version is available.';
  }

  @override
  String get updSnackUpToDate => 'You already have the latest version.';

  @override
  String updSnackAvailable(String version) {
    return 'New version $version available.';
  }

  @override
  String get updSnackCheckFailed =>
      'Couldn\'t check. Please check your connection.';

  @override
  String get updSnackInstallFailed => 'Couldn\'t start the installation.';

  @override
  String get updBannerReadyTitle => 'Update ready to install';

  @override
  String get updBannerAvailableTitle => 'Update available';

  @override
  String updBannerReadyBody(String version) {
    return 'Tap to install Nexo $version.';
  }

  @override
  String updBannerAvailableBody(String version) {
    return 'Tap to download Nexo $version.';
  }

  @override
  String get updDismiss => 'Dismiss';

  @override
  String get assignmentNoDate => 'No due date';

  @override
  String get assignmentOverdue => 'Overdue';

  @override
  String get assignmentDueToday => 'Due today';

  @override
  String get assignmentDueTomorrow => 'Due tomorrow';

  @override
  String assignmentDueInDays(int days) {
    return 'In $days days';
  }

  @override
  String get assignmentEmpty => 'No pending assignments.';

  @override
  String get widgetNoPendingDebts => 'No pending debts';

  @override
  String get widgetUpToDate => '✓ Up to date';

  @override
  String widgetOverdue(int d) {
    return 'Overdue by $d d';
  }

  @override
  String get widgetDueToday => 'Due today';

  @override
  String widgetDueIn(int d, String date) {
    return 'Due in $d d ($date)';
  }

  @override
  String notifStartsIn(int minutes) {
    return 'Starts in $minutes minutes';
  }

  @override
  String get notifDueToday => 'due today';

  @override
  String get notifDueTomorrow => 'due tomorrow';

  @override
  String notifDueInDays(int days) {
    return 'due in $days days';
  }

  @override
  String get notifClassesReminder => 'Classes reminder';

  @override
  String notifPendingPayment(String when) {
    return 'Pending payment — $when';
  }

  @override
  String get notifPaymentsReminder => 'Payments reminder';

  @override
  String get prefSameDay => 'Same day';

  @override
  String get prefOneDayBefore => '1 day before';

  @override
  String prefDaysBefore(int d) {
    return '$d days before';
  }

  @override
  String get prefOneHourBefore => '1 hour before';

  @override
  String get prefTwoHoursBefore => '2 hours before';

  @override
  String prefMinBefore(int m) {
    return '$m min before';
  }

  @override
  String get classOngoing => 'ONGOING';

  @override
  String get homeNoClassesToday => 'No classes today';

  @override
  String get homeNextClassTitle => 'NEXT CLASS';

  @override
  String homeNextClassTomorrowDay(String day) {
    return 'Tomorrow · $day';
  }

  @override
  String get homeNextClassNow => 'Now';

  @override
  String homeNextClassInMin(int m) {
    return 'In $m min';
  }

  @override
  String homeNextClassInHours(int h) {
    return 'In ${h}h';
  }

  @override
  String homeNextClassInHoursMin(int h, int m) {
    return 'In ${h}h ${m}min';
  }

  @override
  String homePendingPaymentsOverdueCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count overdue',
      one: '$count overdue',
    );
    return '$_temp0';
  }

  @override
  String get widgetTeamsTitle => 'My subjects';

  @override
  String get widgetTeamsSubtitle => 'Teams groups';

  @override
  String get widgetTeamsEmpty => 'No subjects in Teams';

  @override
  String get widgetAssignmentsTitle => 'Assignments';

  @override
  String get widgetAssignmentsSubtitle => 'Nearing deadline';

  @override
  String get whatsappBannerTitle => 'Join Nexo\'s channel';

  @override
  String get whatsappBannerDesc =>
      'Follow the WhatsApp channel to learn about news, improvements, and important notices about Nexo.';

  @override
  String get whatsappBannerFollow => 'Follow channel';

  @override
  String get whatsappBannerLater => 'Not now';

  @override
  String homePendingPaymentsMore(int count) {
    return '+ $count more fees';
  }

  @override
  String get termsItemRightsTitle => 'Your rights';

  @override
  String get termsItemRightsBody =>
      'You can ask what information about you is on the Nexo server, correct or delete it, and request the log of who looked at your record. You can also give up your directory access whenever you want. Write to us from the support section to exercise these rights or ask anything about how your data is handled.';

  @override
  String get tabDirectory => 'Students';

  @override
  String get directoryTitle => 'Students';

  @override
  String get directorySubtitle => 'Institutional directory';

  @override
  String directoryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count students',
      one: '1 student',
      zero: 'No students',
    );
    return '$_temp0';
  }

  @override
  String get directorySearchHint => 'Search by name or code';

  @override
  String get directoryFilterSchool => 'Program';

  @override
  String get directoryAllSchools => 'All programs';

  @override
  String directoryCycle(String n) {
    return 'Term $n';
  }

  @override
  String directoryCredits(String aprobados, String total) {
    return '$aprobados/$total credits';
  }

  @override
  String get directoryNoResults => 'No results';

  @override
  String get directoryNoResultsHint => 'Try another name, code or filter.';

  @override
  String directoryEndOfList(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count students in total',
      one: '1 student in total',
    );
    return '$_temp0';
  }

  @override
  String get directoryManageAccess => 'Manage access';

  @override
  String get directoryDeniedTitle => 'No directory access';

  @override
  String get directoryDeniedHint =>
      'Your account is not authorized. Ask a system administrator.';

  @override
  String get directoryUnavailableTitle => 'Could not connect';

  @override
  String get directoryUnavailableHint => 'Check your connection and try again.';

  @override
  String get directoryRecordTitle => 'Student record';

  @override
  String get directoryTabSummary => 'Overview';

  @override
  String get directoryTabGrades => 'Grades';

  @override
  String get directoryTabSchedule => 'Schedule';

  @override
  String get directoryTabPayments => 'Payments';

  @override
  String get directoryAverageShort => 'Average';

  @override
  String get directoryEmptyModule => 'Nothing to show.';

  @override
  String get directoryRecordMissing => 'Record not found';

  @override
  String get directoryRecordMissingHint =>
      'That code is no longer in the directory.';

  @override
  String get directoryStatAverage => 'Average';

  @override
  String get directoryStatCredits => 'Credits passed';

  @override
  String get directoryPersonalData => 'Student details';

  @override
  String get directoryFieldCode => 'Code';

  @override
  String get directoryFieldEmail => 'Email';

  @override
  String get directoryFieldPhone => 'Phone';

  @override
  String get directoryFieldFaculty => 'Faculty';

  @override
  String get directoryFieldSchool => 'Program';

  @override
  String get directoryFieldPlan => 'Curriculum';

  @override
  String get directoryFieldEntry => 'Enrolled';

  @override
  String get directoryFieldStatus => 'Standing';

  @override
  String get directoryProgressByTerm => 'Average per term';

  @override
  String directoryCourseCredits(String value) {
    return '$value credits';
  }

  @override
  String directoryAttendance(String value) {
    return 'Attendance $value%';
  }

  @override
  String get directoryNoUnits => 'No breakdown by unit.';

  @override
  String get directoryPaymentsOverdue => 'Overdue';

  @override
  String get directoryPaymentsPending => 'Pending';

  @override
  String get directoryAccessExplainer =>
      'Directory access is granted per code. System administrators are configured on the server and cannot be changed from here.';

  @override
  String get directoryAdmins => 'System administrators';

  @override
  String get directoryAdminsHint => 'They always have access and can grant it.';

  @override
  String directoryGrantsActive(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'With access · $count',
      one: 'With access · 1',
      zero: 'With access',
    );
    return '$_temp0';
  }

  @override
  String get directoryGrantsRevoked => 'Access revoked';

  @override
  String get directoryNoGrants => 'You have not authorized anyone yet.';

  @override
  String get directoryGrantAdd => 'Grant access';

  @override
  String get directoryGrantCodeLabel => 'Code or ID';

  @override
  String get directoryGrantCodeHelp => 'As it appears on the intranet.';

  @override
  String get directoryGrantConfirm => 'Grant';

  @override
  String get directoryGrantFailed => 'Could not change the access.';

  @override
  String directoryGrantedBy(String code) {
    return 'Granted by $code';
  }

  @override
  String get directoryGrant => 'Grant';

  @override
  String get directoryRevoke => 'Revoke';

  @override
  String get directoryAdminOnlyTitle => 'Administrators only';

  @override
  String get directoryAdminOnlyHint =>
      'Granting access is reserved for system administrators.';

  @override
  String get termsHeaderUpdatedPre => 'Something changed';

  @override
  String get termsUpdatedNotice =>
      'We updated these terms because Nexo now includes the Students section, which uses its own server and may show other people\'s data. Please read them again before continuing.';

  @override
  String get termsItemDirectoryTitle => 'The Students section';

  @override
  String get termsItemDirectoryBody =>
      'It is a directory only authorized accounts can enter, and it shows up in the app only if yours is one of them. To check that, your username and password travel once to the Nexo server, which verifies them against SIGMA and does not store them; from then on a temporary session is used. Every time you open a student record, your code, the date and whose record you opened are logged.';

  @override
  String get termsItemThirdPartyTitle => 'Other people\'s data';

  @override
  String get termsItemThirdPartyBody =>
      'If you have directory access you will be seeing other people\'s information. Use it only for what you were authorized to: do not download, copy, share or publish it. Peru\'s Personal Data Protection Act (Law 29733) applies to you too, and access can be revoked at any time.';

  @override
  String get termsItemDemoDataTitle => 'Demo data';

  @override
  String get termsItemDemoDataBody =>
      'Until there is institutional authorization to query the real directory, the Students section shows generated test data: people who do not exist. When it is replaced with real data we will update these terms and ask you to accept them again.';

  @override
  String get termsItemMicrosoftTitle => 'Microsoft account (optional)';

  @override
  String get termsItemMicrosoftBody =>
      'If you connect your institutional Microsoft account, Nexo reads your Teams classes and assignments to show them in the app. The connection is optional, you authorize it yourself in the browser, and you can disconnect it whenever you want.';

  @override
  String get termsItemDeviceTitle => 'What stays on your device';

  @override
  String get termsItemDeviceBody =>
      'Nexo keeps a local copy of your schedule, grades and payments so it works offline, and schedules notifications and widgets on the device itself. All of it is wiped when you sign out.';

  @override
  String get termsItemChangesTitle => 'Changes to these terms';

  @override
  String get termsItemChangesBody =>
      'If something important changes in how your data is handled, we will update these terms and show them to you again before you keep using the app. You can reread them any time from Profile, under Terms & Privacy.';

  @override
  String termsVersionLine(String version, String date) {
    return 'Version $version · Updated on $date';
  }

  @override
  String get directoryClearFilters => 'Clear filters';

  @override
  String get directoryFieldCycle => 'Term';

  @override
  String get directoryCumulativeAverage => 'Cumulative average';

  @override
  String get directoryApprovedCourses => 'Courses passed';

  @override
  String directoryCoursesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count courses',
      one: '1 course',
    );
    return '$_temp0';
  }

  @override
  String directoryOverdueCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count overdue',
      one: '1 overdue',
    );
    return '$_temp0';
  }

  @override
  String get guardianEntry => 'I\'m a parent or guardian';

  @override
  String get guardianTitle => 'Guardian access';

  @override
  String get guardianHeadline => 'Check your child\'s record';

  @override
  String get guardianIntro =>
      'Sign in with your ID number and the PIN you were given. No university account needed.';

  @override
  String get guardianDniLabel => 'ID number';

  @override
  String get guardianDniInvalid => 'Enter the 8 digits of your ID';

  @override
  String get guardianPinLabel => 'PIN';

  @override
  String get guardianPinHelp => 'The 6 digits the university gave you';

  @override
  String get guardianPinInvalid => 'The PIN has 6 digits';

  @override
  String get guardianEnter => 'Enter';

  @override
  String get guardianBadCredentials =>
      'Wrong ID or PIN. Check them and try again.';

  @override
  String get guardianLocked =>
      'Too many failed attempts. Wait a few minutes before trying again.';

  @override
  String get guardianUnavailable =>
      'Could not connect. Check your connection and try again.';

  @override
  String get guardianAuditNotice => 'Every lookup is logged.';

  @override
  String get guardianPickTitle => 'Who do you want to see?';

  @override
  String get guardianNoStudents => 'No student is linked to your ID yet.';

  @override
  String get guardianSignOut => 'Sign out';
}
