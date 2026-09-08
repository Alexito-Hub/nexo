import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:nexo/l10n/app_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'package:nexo/core/storage.dart';
import 'package:nexo/domain/course_status.dart';
import 'package:nexo/domain/notification_prefs.dart';
import 'package:nexo/domain/unified_models.dart';

class NotificationService extends ChangeNotifier {
  NotificationService._();
  static final NotificationService instance = NotificationService._();
  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;
  NotificationPrefs _prefs = const NotificationPrefs();
  NotificationPrefs get prefs => _prefs;
  bool get _supported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.linux ||
          defaultTargetPlatform == TargetPlatform.windows);
  bool get _supportsScheduling =>
      _supported && defaultTargetPlatform != TargetPlatform.windows;
  static const _idClassBase = 10000;
  static const _idPaymentBase = 20000;
  static const _idGradeBase = 30000;
  static const _idUpdate = 40001;
  static const _payloadUpdateInstall = 'nexo:update:install';
  Future<void> Function()? onInstallUpdateTap;
  AndroidScheduleMode _androidMode = AndroidScheduleMode.exactAllowWhileIdle;
  Future<void> init() async {
    final raw = AppStorage.instance.notifPrefsJson;
    if (raw != null) {
      try {
        _prefs = NotificationPrefs.fromJson(
          jsonDecode(raw) as Map<String, dynamic>,
        );
      } catch (_) {}
    }
    if (!_supported) return;
    try {
      tzdata.initializeTimeZones();
      final name = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(name));
    } catch (_) {}
    const android = AndroidInitializationSettings('@mipmap/launcher_icon');
    const ios = DarwinInitializationSettings();
    const macos = DarwinInitializationSettings();
    const linux = LinuxInitializationSettings(defaultActionName: 'Abrir');
    const windows = WindowsInitializationSettings(
      appName: 'Nexo UPLA',
      appUserModelId: 'pe.upla.nexo',
      guid: 'd2c4f88a-2d4b-4c0e-9e2c-3e7a4b9f1c10',
    );
    await _plugin.initialize(
      const InitializationSettings(
        android: android,
        iOS: ios,
        macOS: macos,
        linux: linux,
        windows: windows,
      ),
      onDidReceiveNotificationResponse: _onTap,
    );
    _ready = true;
  }

  void _onTap(NotificationResponse r) {
    if (r.payload == _payloadUpdateInstall) {
      final cb = onInstallUpdateTap;
      if (cb != null) unawaited(cb());
    }
  }

  Future<bool> requestPermission() async {
    if (!_supported || !_ready) return false;
    if (defaultTargetPlatform == TargetPlatform.android) {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      final granted = await android?.requestNotificationsPermission();
      await _ensureExactAlarms(request: true);
      return granted ?? false;
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final ios = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      final granted = await ios?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }
    if (defaultTargetPlatform == TargetPlatform.macOS) {
      final mac = _plugin
          .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin
          >();
      final granted = await mac?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }
    return true;
  }

  Future<void> _ensureExactAlarms({bool request = false}) async {
    if (!_supportsScheduling ||
        defaultTargetPlatform != TargetPlatform.android) {
      return;
    }
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android == null) return;
    var can = await android.canScheduleExactNotifications() ?? false;
    if (!can && request) {
      await android.requestExactAlarmsPermission();
      can = await android.canScheduleExactNotifications() ?? false;
    }
    _androidMode = can
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;
  }

  Future<bool> hasExactAlarmsPermission() async {
    if (defaultTargetPlatform != TargetPlatform.android) return true;
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android == null) return false;
    return await android.canScheduleExactNotifications() ?? false;
  }

  Future<void> requestExactAlarmsPermission() async {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android == null) return;
    await android.requestExactAlarmsPermission();
    await _ensureExactAlarms();
    notifyListeners();
  }

  Future<void> updatePrefs(
    NotificationPrefs prefs, {
    List<ScheduleClass>? clases,
    List<Payment>? installments,
  }) async {
    _prefs = prefs;
    await AppStorage.instance.setNotifPrefsJson(jsonEncode(prefs.toJson()));
    notifyListeners();
    if (prefs.enabled) await requestPermission();
    await reschedule(clases: clases, installments: installments);
  }

  AndroidNotificationDetails _androidDetails(String channelId, String name) =>
      AndroidNotificationDetails(
        channelId,
        name,
        importance: Importance.high,
        priority: Priority.high,
      );
  NotificationDetails _details(String channelId, String name) =>
      NotificationDetails(
        android: _androidDetails(channelId, name),
        iOS: const DarwinNotificationDetails(),
        macOS: const DarwinNotificationDetails(),
        linux: const LinuxNotificationDetails(),
        windows: const WindowsNotificationDetails(),
      );
  Timer? _rescheduleDebounce;

  Future<void> reschedule({
    List<ScheduleClass>? clases,
    List<Payment>? installments,
    Set<String> finishedSubjects = const {},
  }) async {
    if (!_supported || !_ready) return;
    _rescheduleDebounce?.cancel();
    _rescheduleDebounce = Timer(const Duration(milliseconds: 500), () async {
      if (_supportsScheduling) {
        await _plugin.cancelAll();
      }
      if (!_prefs.enabled) return;
      if (!_supportsScheduling) return;
      await _ensureExactAlarms();
      if (_prefs.classesEnabled && clases != null) {
        await _scheduleClasses(clases, finishedSubjects);
      }
      if (_prefs.paymentsEnabled && installments != null) {
        await _schedulePayments(installments);
      }
    });
  }

  Future<void> _scheduleClasses(
    List<ScheduleClass> clases,
    Set<String> finished,
  ) async {
    final now = tz.TZDateTime.now(tz.local);
    var id = _idClassBase;
    for (var offset = 0; offset < 7; offset++) {
      final day = now.add(Duration(days: offset));
      final weekday = day.weekday;
      // Por GRUPO, no por sesión: teoría y práctica de la misma asignatura el
      // mismo día son dos `ScheduleClass`, y avisar de cada una daba dos
      // notificaciones casi seguidas del mismo curso. Se avisa una vez, a la
      // hora en que empieza el bloque, y no se avisa de talleres ya cerrados.
      final grupos = remindableGroups(
        classes: clases,
        weekday: weekday,
        finished: finished,
      );
      for (final c in grupos) {
        final hm = c.startTime.split(':');
        if (hm.length < 2) continue;
        final h = int.tryParse(hm[0]);
        final m = int.tryParse(hm[1]);
        if (h == null || m == null) continue;
        final start = tz.TZDateTime(
          tz.local,
          day.year,
          day.month,
          day.day,
          h,
          m,
        );
        final when = start.subtract(Duration(minutes: _prefs.classLeadMinutes));
        if (when.isBefore(now)) continue;
        final l10n = lookupAppLocalizations(
          Locale(AppStorage.instance.localeCode ?? 'es'),
        );
        await _zoned(
          id++,
          c.subject,
          l10n.notifStartsIn(_prefs.classLeadMinutes),
          when,
          'classes',
          l10n.notifClassesReminder,
        );
      }
    }
  }

  Future<void> _schedulePayments(List<Payment> pagos) async {
    final now = tz.TZDateTime.now(tz.local);
    var id = _idPaymentBase;
    for (final c in pagos) {
      final due = c.dueDate;
      if (due == null) continue;
      for (final lead in _prefs.paymentLeadDays) {
        final day = due.subtract(Duration(days: lead));
        final when = tz.TZDateTime(
          tz.local,
          day.year,
          day.month,
          day.day,
          _prefs.paymentHour,
          0,
        );
        if (when.isBefore(now)) continue;
        final l10n = lookupAppLocalizations(
          Locale(AppStorage.instance.localeCode ?? 'es'),
        );
        final cuando = lead == 0
            ? l10n.notifDueToday
            : lead == 1
            ? l10n.notifDueTomorrow
            : l10n.notifDueInDays(lead);
        await _zoned(
          id++,
          l10n.notifPendingPayment(cuando),
          '${c.description}: ${c.currency} '
              '${c.total.toStringAsFixed(2)} (${c.dueDateRaw})',
          when,
          'payments',
          l10n.notifPaymentsReminder,
        );
      }
    }
  }

  Future<void> _zoned(
    int id,
    String title,
    String body,
    tz.TZDateTime when,
    String channelId,
    String channelName,
  ) async {
    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        when,
        _details(channelId, channelName),
        androidScheduleMode: _androidMode,
      );
    } catch (_) {
      if (_androidMode == AndroidScheduleMode.exactAllowWhileIdle) {
        _androidMode = AndroidScheduleMode.inexactAllowWhileIdle;
        try {
          await _plugin.zonedSchedule(
            id,
            title,
            body,
            when,
            _details(channelId, channelName),
            androidScheduleMode: _androidMode,
          );
        } catch (_) {}
      }
    }
  }

  Future<void> showGradeChanged(String course, String grade) async {
    if (!_supported || !_ready || !_prefs.enabled || !_prefs.gradesEnabled) {
      return;
    }
    await _plugin.show(
      _idGradeBase + (course.hashCode % 1000),
      'Nueva nota publicada',
      '$course: $grade',
      _details('grades', 'Notas'),
    );
  }

  Future<void> showUpdateAvailable(String version) async {
    if (!_supported || !_ready) return;
    await _plugin.show(
      _idUpdate,
      'Actualización disponible',
      'Nexo $version está disponible. Se descargará cuando haya conexión.',
      _details('actualizaciones', 'Actualizaciones'),
    );
  }

  Future<void> showUpdateReady(String version) async {
    if (!_supported || !_ready) return;
    await _plugin.show(
      _idUpdate,
      'Actualización lista para instalar',
      'Toca para instalar Nexo $version.',
      _details('actualizaciones', 'Actualizaciones'),
      payload: _payloadUpdateInstall,
    );
  }
}
