import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nexo/core/config.dart';

class AppStorage {
  AppStorage._(this._prefs);
  static AppStorage? _instance;
  final SharedPreferences _prefs;
  static Future<AppStorage> init() async {
    _instance ??= AppStorage._(await SharedPreferences.getInstance());
    return _instance!;
  }

  static AppStorage get instance {
    final i = _instance;
    if (i == null) {
      throw StateError('AppStorage no inicializado — llama init() antes.');
    }
    return i;
  }

  static const _kToken = 'nexo.token';
  static const _kUser = 'nexo.user';
  static const _kTheme = 'nexo.themeMode';
  static const _kCredUser = 'nexo.cred.user';
  static const _kCredPass = 'nexo.cred.pass';
  static const _kCachePrefix = 'nexo.cache.';
  static const _kTerms = 'nexo.acceptedTerms';
  static const _kTermsVersion = 'nexo.acceptedTermsVersion';
  static const _kOnboard = 'nexo.seenOnboarding';
  static const _kNotifPrefs = 'nexo.notifPrefs';
  static const _kGradeSnap = 'nexo.gradeSnapshot';
  static const _kMsSession = 'nexo.ms.session';
  static const _kLocale = 'nexo.locale';
  static const _kUse24h = 'nexo.use24h';
  static const _kRunPortable = 'nexo.runPortable';
  static const _kWhatsappInvite = 'nexo.seenWhatsappInvite';
  static const _kFestivityDecor = 'nexo.festivityDecor';
  static const _kIntranetCookies = 'nexo.intranet.cookies';
  static const _kIntranetUser = 'nexo.intranet.user';
  static const _kUpdLastCheckMs = 'nexo.upd.lastCheckMs';
  static const _kUpdLatestVer = 'nexo.upd.latestVer';
  static const _kUpdApkUrl = 'nexo.upd.apkUrl';
  static const _kUpdApkSize = 'nexo.upd.apkSize';
  static const _kUpdDownloadedVer = 'nexo.upd.downloadedVer';
  static const _kUpdApkPath = 'nexo.upd.apkPath';
  static const _kDashboardConfig = 'nexo.dashboardConfig';
  String? get notifPrefsJson => _prefs.getString(_kNotifPrefs);
  Future<void> setNotifPrefsJson(String value) =>
      _prefs.setString(_kNotifPrefs, value);
  String? get gradeSnapshot => _prefs.getString(_kGradeSnap);
  Future<void> setGradeSnapshot(String value) =>
      _prefs.setString(_kGradeSnap, value);
  String? get dashboardConfigJson => _prefs.getString(_kDashboardConfig);
  Future<void> setDashboardConfigJson(String value) =>
      _prefs.setString(_kDashboardConfig, value);

  String? get msSessionJson => _prefs.getString(_kMsSession);
  Future<void> setMsSessionJson(String? value) async {
    if (value == null) {
      await _prefs.remove(_kMsSession);
    } else {
      await _prefs.setString(_kMsSession, value);
    }
  }

  /// Aceptados **estos** términos, no unos cualesquiera: si sube
  /// `LegalTerms.version` la aceptación anterior deja de valer y se vuelven a
  /// mostrar.
  bool get acceptedTerms => acceptedTermsVersion >= LegalTerms.version;

  int get acceptedTermsVersion {
    final stored = _prefs.getInt(_kTermsVersion);
    if (stored != null) return stored;
    // Antes solo se guardaba un booleano: quien ya había aceptado cuenta como
    // que aceptó la primera versión.
    return (_prefs.getBool(_kTerms) ?? false) ? 1 : 0;
  }

  Future<void> setAcceptedTerms(bool v) async {
    await _prefs.setBool(_kTerms, v);
    await _prefs.setInt(_kTermsVersion, v ? LegalTerms.version : 0);
  }

  bool get seenOnboarding => _prefs.getBool(_kOnboard) ?? false;
  Future<void> setSeenOnboarding(bool v) => _prefs.setBool(_kOnboard, v);
  bool get runPortable => _prefs.getBool(_kRunPortable) ?? false;
  Future<void> setRunPortable(bool v) => _prefs.setBool(_kRunPortable, v);
  bool get seenWhatsappInvite => _prefs.getBool(_kWhatsappInvite) ?? false;
  Future<void> setSeenWhatsappInvite(bool v) =>
      _prefs.setBool(_kWhatsappInvite, v);
  bool get festivityDecor => _prefs.getBool(_kFestivityDecor) ?? true;
  Future<void> setFestivityDecor(bool v) => _prefs.setBool(_kFestivityDecor, v);
  String? get intranetCookies => _prefs.getString(_kIntranetCookies);
  String? get intranetUser => _prefs.getString(_kIntranetUser);
  Future<void> setIntranetSession(String? cookies, String? user) async {
    if (cookies == null || user == null) {
      await _prefs.remove(_kIntranetCookies);
      await _prefs.remove(_kIntranetUser);
    } else {
      await _prefs.setString(_kIntranetCookies, cookies);
      await _prefs.setString(_kIntranetUser, user);
    }
  }

  String? get themeMode => _prefs.getString(_kTheme);
  Future<void> setThemeMode(String value) => _prefs.setString(_kTheme, value);
  String? get localeCode => _prefs.getString(_kLocale);
  Future<void> setLocaleCode(String value) => _prefs.setString(_kLocale, value);
  bool get use24h => _prefs.getBool(_kUse24h) ?? true;
  Future<void> setUse24h(bool value) => _prefs.setBool(_kUse24h, value);
  String? get token => _prefs.getString(_kToken);
  Future<void> setToken(String? value) async {
    if (value == null) {
      await _prefs.remove(_kToken);
    } else {
      await _prefs.setString(_kToken, value);
    }
  }

  String? get userJson => _prefs.getString(_kUser);
  Future<void> setUserJson(String? value) async {
    if (value == null) {
      await _prefs.remove(_kUser);
    } else {
      await _prefs.setString(_kUser, value);
    }
  }

  String? get credUser {
    final v = _prefs.getString(_kCredUser);
    if (v == null) return null;
    try {
      return utf8.decode(base64.decode(v));
    } catch (_) {
      return null;
    }
  }

  String? get credPass {
    final v = _prefs.getString(_kCredPass);
    if (v == null) return null;
    try {
      return utf8.decode(base64.decode(v));
    } catch (_) {
      return null;
    }
  }

  bool get hasCredentials =>
      (credUser?.isNotEmpty ?? false) && (credPass?.isNotEmpty ?? false);
  Future<void> setCredentials(String user, String pass) async {
    await _prefs.setString(_kCredUser, base64.encode(utf8.encode(user)));
    await _prefs.setString(_kCredPass, base64.encode(utf8.encode(pass)));
  }

  Future<void> clearCredentials() async {
    await _prefs.remove(_kCredUser);
    await _prefs.remove(_kCredPass);
  }

  Future<void> setCache(String key, Object data) async {
    final payload = jsonEncode({
      'ts': DateTime.now().millisecondsSinceEpoch,
      'data': data,
    });
    await _prefs.setString('$_kCachePrefix$key', payload);
  }

  Object? getCache(String key, {Duration? maxAge}) {
    final raw = _prefs.getString('$_kCachePrefix$key');
    if (raw == null) return null;
    try {
      final m = jsonDecode(raw) as Map<String, dynamic>;
      if (maxAge != null) {
        final ts = m['ts'] as int? ?? 0;
        final age = DateTime.now().millisecondsSinceEpoch - ts;
        if (age > maxAge.inMilliseconds) return null;
      }
      return m['data'];
    } catch (_) {
      return null;
    }
  }

  Future<void> clearCache() async {
    final keys = _prefs
        .getKeys()
        .where((k) => k.startsWith(_kCachePrefix))
        .toList();
    for (final k in keys) {
      await _prefs.remove(k);
    }
  }

  int? get updLastCheckMs => _prefs.getInt(_kUpdLastCheckMs);
  Future<void> setUpdLastCheckMs(int value) =>
      _prefs.setInt(_kUpdLastCheckMs, value);
  String? get updLatestVer => _prefs.getString(_kUpdLatestVer);
  String? get updApkUrl => _prefs.getString(_kUpdApkUrl);
  int? get updApkSize => _prefs.getInt(_kUpdApkSize);
  Future<void> setUpdLatest({
    required String version,
    required String url,
    required int size,
  }) async {
    await _prefs.setString(_kUpdLatestVer, version);
    await _prefs.setString(_kUpdApkUrl, url);
    await _prefs.setInt(_kUpdApkSize, size);
  }

  Future<void> clearUpdLatest() async {
    await _prefs.remove(_kUpdLatestVer);
    await _prefs.remove(_kUpdApkUrl);
    await _prefs.remove(_kUpdApkSize);
  }

  String? get updDownloadedVer => _prefs.getString(_kUpdDownloadedVer);
  String? get updApkPath => _prefs.getString(_kUpdApkPath);
  Future<void> setUpdDownloaded(String version, String path) async {
    await _prefs.setString(_kUpdDownloadedVer, version);
    await _prefs.setString(_kUpdApkPath, path);
  }

  Future<void> clearUpdDownloaded() async {
    await _prefs.remove(_kUpdDownloadedVer);
    await _prefs.remove(_kUpdApkPath);
  }

  Future<void> clear({bool keepCredentials = true}) async {
    await _prefs.remove(_kToken);
    await _prefs.remove(_kUser);
    await clearCache();
    if (!keepCredentials) await clearCredentials();
  }
}
