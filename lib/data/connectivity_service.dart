import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:nexo/core/config.dart';

enum ServerStatus { online, offline, degraded }

class ConnectivityService extends ChangeNotifier {
  ConnectivityService({Connectivity? connectivity, http.Client? httpClient})
    : _connectivity = connectivity ?? Connectivity(),
      _httpClient = httpClient ?? http.Client();
  final Connectivity _connectivity;
  final http.Client _httpClient;
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  Timer? _timer;
  bool _hasInternet = false;
  ServerStatus _sigmaStatus = ServerStatus.offline;
  ServerStatus _intranetStatus = ServerStatus.offline;
  ServerStatus _idiomasAuthStatus = ServerStatus.offline;
  ServerStatus _idiomasApiStatus = ServerStatus.offline;

  /// Completer que se resuelve cuando el primer health-check termina.
  /// Permite a `AppShell` esperar antes de disparar `loadHomeEssentials`,
  /// evitando que `ErrorHandler` vea `hasInternet = false` prematuramente.
  final Completer<void> _firstCheckCompleter = Completer<void>();

  /// Future que se resuelve al completar el primer chequeo de conectividad.
  Future<void> get firstCheckDone => _firstCheckCompleter.future;

  /// `true` una vez que el primer health-check haya terminado.
  bool get firstCheckCompleted => _firstCheckCompleter.isCompleted;

  bool get hasInternet => _hasInternet;
  ServerStatus get sigmaStatus => _sigmaStatus;
  ServerStatus get intranetStatus => _intranetStatus;
  ServerStatus get idiomasAuthStatus => _idiomasAuthStatus;
  ServerStatus get idiomasApiStatus => _idiomasApiStatus;
  bool get isFullyOnline =>
      _hasInternet &&
      _sigmaStatus == ServerStatus.online &&
      _intranetStatus == ServerStatus.online;
  bool get isSigmaOnline => _hasInternet && _sigmaStatus == ServerStatus.online;
  bool _isChecking = false;
  bool get isChecking => _isChecking;
  Future<void> start() async {
    await _subscription?.cancel();
    _timer?.cancel();
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      _handleConnectivityChange(results);
    });
    final initialResults = await _connectivity.checkConnectivity();
    await _handleConnectivityChange(initialResults);
    if (!_firstCheckCompleter.isCompleted) {
      _firstCheckCompleter.complete();
    }
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (_hasInternet) {
        _healthCheck();
      }
    });
  }

  Future<void> checkNow() async {
    if (_isChecking) return;
    _isChecking = true;
    notifyListeners();
    try {
      final results = await _connectivity.checkConnectivity();
      _hasInternet =
          results.isNotEmpty && !results.contains(ConnectivityResult.none);
      await _healthCheck();
    } finally {
      _isChecking = false;
      notifyListeners();
    }
  }

  Future<void> _handleConnectivityChange(
    List<ConnectivityResult> results,
  ) async {
    final hasNet =
        results.isNotEmpty && !results.contains(ConnectivityResult.none);
    _hasInternet = hasNet;
    await _healthCheck();
  }

  Future<void> _healthCheck() async {
    final sigmaFuture = _pingServer(Uri.parse(AppConfig.apiBaseUrl));
    final intranetFuture = _pingServer(
      Uri.parse('https://intranet.upla.edu.pe'),
    );
    final idiomasAuthFuture = _pingServer(
      Uri.parse('https://services.upla.edu.pe'),
    );
    final idiomasApiFuture = _pingServer(
      Uri.parse('https://apidiomas.upla.edu.pe'),
    );
    final results = await Future.wait([
      sigmaFuture,
      intranetFuture,
      idiomasAuthFuture,
      idiomasApiFuture,
    ]);
    _sigmaStatus = results[0];
    _intranetStatus = results[1];
    _idiomasAuthStatus = results[2];
    _idiomasApiStatus = results[3];

    if (results.any((s) => s != ServerStatus.offline)) {
      _hasInternet = true;
    }
    notifyListeners();
  }

  Future<ServerStatus> _pingServer(Uri uri) async {
    final stopwatch = Stopwatch()..start();
    const browserUa =
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
        '(KHTML, like Gecko) Chrome/130.0 Safari/537.36';
    try {
      final response = await _httpClient
          .get(uri, headers: const {'User-Agent': browserUa})
          .timeout(const Duration(seconds: 6));
      stopwatch.stop();
      if (response.statusCode >= 500) return ServerStatus.offline;
      if (stopwatch.elapsedMilliseconds > 3000) return ServerStatus.degraded;
      return ServerStatus.online;
    } catch (_) {
      return ServerStatus.offline;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _timer?.cancel();
    _httpClient.close();
    super.dispose();
  }
}
