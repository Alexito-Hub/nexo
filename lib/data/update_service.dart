import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:nexo/core/config.dart';
import 'package:nexo/core/storage.dart';
import 'package:nexo/data/notification_service.dart';

enum UpdateState { unsupported, unknown, upToDate, available, ready }

class UpdateStatus {
  const UpdateStatus({required this.state, this.latestVersion, this.apkPath});
  final UpdateState state;
  final String? latestVersion;
  final String? apkPath;
}

class UpdateService extends ChangeNotifier {
  UpdateService({http.Client? httpClient, NotificationService? notifications})
    : _http = httpClient ?? http.Client(),
      _notifications = notifications ?? NotificationService.instance {
    instance = this;
  }
  static UpdateService? instance;
  final http.Client _http;
  final NotificationService _notifications;
  Future<void>? _downloadInFlight;
  bool _busy = false;
  bool get isBusy => _busy;
  void _setBusy(bool v) {
    if (_busy == v) return;
    _busy = v;
    notifyListeners();
  }

  bool get isSupported => _isSupported;
  bool get _isSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.windows);
  Future<void> bootstrap() async {
    if (!_isSupported) return;
    await _cleanupIfAlreadyInstalled();
    unawaited(_runCheckAndDownload(force: false));
  }

  Future<UpdateStatus> checkNow() async {
    if (!_isSupported)
      return const UpdateStatus(state: UpdateState.unsupported);
    _setBusy(true);
    try {
      await _notifications.requestPermission();
      await _runCheckAndDownload(force: true);
      return currentStatus();
    } finally {
      _setBusy(false);
    }
  }

  UpdateStatus currentStatus() {
    if (!_isSupported)
      return const UpdateStatus(state: UpdateState.unsupported);
    final s = AppStorage.instance;
    final latest = s.updLatestVer;
    if (latest == null) return const UpdateStatus(state: UpdateState.unknown);
    if (!_isNewer(latest, AppConfig.appVersion)) {
      return const UpdateStatus(state: UpdateState.upToDate);
    }
    final downloaded = s.updDownloadedVer;
    final path = s.updApkPath;
    if (downloaded == latest && path != null && File(path).existsSync()) {
      return UpdateStatus(
        state: UpdateState.ready,
        latestVersion: latest,
        apkPath: path,
      );
    }
    return UpdateStatus(state: UpdateState.available, latestVersion: latest);
  }

  Future<bool> installDownloaded() async {
    if (!_isSupported) return false;
    _setBusy(true);
    try {
      var status = currentStatus();
      if (status.state == UpdateState.available) {
        await _downloadOnce();
        status = currentStatus();
        notifyListeners();
      }
      if (status.state != UpdateState.ready || status.apkPath == null) {
        return false;
      }
      try {
        final res = await OpenFilex.open(status.apkPath!);
        return res.type == ResultType.done;
      } catch (e) {
        debugPrint('[UpdateService] install failed: $e');
        return false;
      }
    } finally {
      _setBusy(false);
    }
  }

  Future<void> _runCheckAndDownload({required bool force}) async {
    try {
      final s = AppStorage.instance;
      final now = DateTime.now().millisecondsSinceEpoch;
      if (!force) {
        final last = s.updLastCheckMs ?? 0;
        if (now - last < UpdateConfig.checkInterval.inMilliseconds) {
          if (currentStatus().state == UpdateState.available) {
            unawaited(_downloadOnce());
          }
          return;
        }
      }
      await s.setUpdLastCheckMs(now);
      final release = await _fetchLatestRelease();
      if (release == null) return;
      final version = release.version;
      final asset = release.apkAsset;
      if (asset == null) return;
      await s.setUpdLatest(version: version, url: asset.url, size: asset.size);
      if (!_isNewer(version, AppConfig.appVersion)) return;
      await _downloadOnce();
      final fresh = currentStatus();
      if (fresh.state == UpdateState.ready) {
        await _notifications.showUpdateReady(version);
      } else if (fresh.state == UpdateState.available) {
        await _notifications.showUpdateAvailable(version);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('[UpdateService] check failed: $e');
    }
  }

  Future<void> _downloadOnce() {
    return _downloadInFlight ??= () async {
      try {
        await _doDownload();
      } finally {
        _downloadInFlight = null;
      }
    }();
  }

  Future<void> _doDownload() async {
    final s = AppStorage.instance;
    final version = s.updLatestVer;
    final url = s.updApkUrl;
    final size = s.updApkSize;
    if (version == null || url == null) return;
    final existingPath = s.updApkPath;
    if (s.updDownloadedVer == version && existingPath != null) {
      final f = File(existingPath);
      if (await f.exists()) {
        final len = await f.length();
        if (size == null || len == size) return;
        await _safeDelete(f);
        await s.clearUpdDownloaded();
      }
    }
    final dir = await _apkDir();
    final ext = _extensionFromUrl(url) ?? '.apk';
    final dest = File(p.join(dir.path, 'nexo-$version$ext'));
    final part = File('${dest.path}.part');
    final req = http.Request('GET', Uri.parse(url));
    final res = await _http.send(req);
    if (res.statusCode != 200) {
      throw HttpException(
        'GET $url devolvió ${res.statusCode}',
        uri: Uri.parse(url),
      );
    }
    if (await part.exists()) await _safeDelete(part);
    final sink = part.openWrite();
    try {
      await res.stream.pipe(sink);
    } finally {
      await sink.close();
    }
    if (size != null) {
      final len = await part.length();
      if (len != size) {
        await _safeDelete(part);
        throw const FileSystemException(
          'Descarga incompleta — tamaño no coincide con el release.',
        );
      }
    }
    if (await dest.exists()) await _safeDelete(dest);
    await part.rename(dest.path);
    await s.setUpdDownloaded(version, dest.path);
    await _purgeStaleApks(dir, keep: dest.path);
  }

  Future<void> _cleanupIfAlreadyInstalled() async {
    final s = AppStorage.instance;
    final downloaded = s.updDownloadedVer;
    if (downloaded == null) return;
    if (!_isNewer(downloaded, AppConfig.appVersion) &&
        downloaded != AppConfig.appVersion) {}
    if (_isNewer(AppConfig.appVersion, downloaded) ||
        AppConfig.appVersion == downloaded) {
      final path = s.updApkPath;
      if (path != null) await _safeDelete(File(path));
      await s.clearUpdDownloaded();
      final latest = s.updLatestVer;
      if (latest != null && !_isNewer(latest, AppConfig.appVersion)) {
        await s.clearUpdLatest();
      }
    }
  }

  Future<void> _purgeStaleApks(Directory dir, {required String keep}) async {
    try {
      await for (final f in dir.list()) {
        final isArtifact =
            f.path.endsWith('.apk') ||
            f.path.endsWith('.zip') ||
            f.path.endsWith('.exe') ||
            f.path.endsWith('.msix');
        if (f is File && f.path != keep && isArtifact) {
          await _safeDelete(f);
        }
      }
    } catch (_) {}
  }

  static String? _extensionFromUrl(String url) {
    final segs = Uri.parse(url).pathSegments;
    final name = segs.isNotEmpty ? segs.last : '';
    final dot = name.lastIndexOf('.');
    if (dot <= 0) return null;
    return name.substring(dot);
  }

  Future<void> _safeDelete(FileSystemEntity f) async {
    try {
      await f.delete();
    } catch (_) {}
  }

  Future<Directory> _apkDir() async {
    final Directory base;
    if (defaultTargetPlatform == TargetPlatform.android) {
      base =
          await getExternalStorageDirectory() ??
          await getApplicationSupportDirectory();
    } else {
      base = await getApplicationSupportDirectory();
    }
    final dir = Directory(p.join(base.path, 'updates'));
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  Future<_GhRelease?> _fetchLatestRelease() async {
    final res = await _http
        .get(
          Uri.parse(UpdateConfig.latestReleaseApi),
          headers: const {
            'Accept': 'application/vnd.github+json',
            'X-GitHub-Api-Version': '2022-11-28',
          },
        )
        .timeout(const Duration(seconds: 15));
    if (res.statusCode != 200) {
      debugPrint('[UpdateService] GitHub API ${res.statusCode}: ${res.body}');
      return null;
    }
    final json = jsonDecode(res.body) as Map<String, dynamic>;
    final tag = (json['tag_name'] as String?)?.trim();
    if (tag == null || tag.isEmpty) return null;
    final version = _stripVPrefix(tag);
    final assets = (json['assets'] as List?) ?? const [];
    final isWindows = defaultTargetPlatform == TargetPlatform.windows;
    _GhAsset? chosen;
    for (final a in assets.whereType<Map<String, dynamic>>()) {
      // La API de GitHub nombra este campo "name" (no "nombre"): con la clave
      // equivocada ningún asset coincidía y el updater nunca veía versiones.
      final name = a['name'] as String? ?? '';
      final matches = isWindows
          ? UpdateConfig.isWindowsAsset(name)
          : UpdateConfig.isApkAsset(name);
      if (!matches) continue;
      final url = a['browser_download_url'] as String?;
      final size = (a['size'] as num?)?.toInt();
      if (url == null || size == null) continue;
      final asset = _GhAsset(url: url, size: size, name: name);
      if (!isWindows && UpdateConfig.isUniversalApk(name)) {
        chosen = asset;
        break;
      }
      chosen ??= asset;
    }
    return _GhRelease(version: version, apkAsset: chosen);
  }

  static String _stripVPrefix(String s) {
    final t = s.trim();
    if (t.isNotEmpty && (t[0] == 'v' || t[0] == 'V')) return t.substring(1);
    return t;
  }

  static bool _isNewer(String a, String b) {
    final pa = _parseVersion(a);
    final pb = _parseVersion(b);
    if (pa == null || pb == null) return a.compareTo(b) > 0;
    for (var i = 0; i < 3; i++) {
      if (pa[i] != pb[i]) return pa[i] > pb[i];
    }
    return false;
  }

  static List<int>? _parseVersion(String s) {
    final core = s.split('+').first.split('-').first;
    final parts = core.split('.');
    if (parts.length < 2) return null;
    final out = <int>[];
    for (var i = 0; i < 3; i++) {
      final raw = i < parts.length ? parts[i] : '0';
      final n = int.tryParse(raw);
      if (n == null) return null;
      out.add(n);
    }
    return out;
  }
}

class _GhRelease {
  _GhRelease({required this.version, required this.apkAsset});
  final String version;
  final _GhAsset? apkAsset;
}

class _GhAsset {
  _GhAsset({required this.url, required this.size, required this.name});
  final String url;
  final int size;
  final String name;
}
