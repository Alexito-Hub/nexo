import 'package:flutter/foundation.dart';
import 'package:nexo/core/errors.dart';
import 'package:nexo/data/connectivity_service.dart';
import 'package:nexo/data/session.dart';

class ErrorHandler {
  final ConnectivityService connectivity;
  final SessionService session;
  ErrorHandler({required this.connectivity, required this.session});
  Future<T> withFallback<T>({
    required Future<T> Function() remote,
    required Future<T?> Function() cached,
    required String operationName,
  }) async {
    try {
      if (!connectivity.hasInternet) {
        // Preferimos caché si existe, pero NO bloqueamos el intento remoto:
        // connectivity_plus da falsos negativos en desktop, y un token vencido
        // no implica falta de red. Si no hay caché, igual intentamos la red.
        final cachedResult = await cached();
        if (cachedResult != null) {
          debugPrint('ErrorHandler: offline flag for $operationName → cache');
          return cachedResult;
        }
        debugPrint(
          'ErrorHandler: offline flag for $operationName but no cache → intento remoto igualmente',
        );
      }
      return await _remoteWithRetry(remote, operationName);
    } on SessionExpiredException {
      // El logout ya lo disparó ApiClient (onUnauthorized) como fuente única.
      // Aquí NO cerramos sesión otra vez: solo intentamos mostrar el caché
      // durante la transición a la pantalla de login.
      debugPrint('ErrorHandler: session expired in $operationName.');
      final cachedResult = await cached();
      if (cachedResult != null) return cachedResult;
      rethrow;
    } on AuthUnavailableException catch (e) {
      // Transitorio: no se pudo verificar la sesión (servidor de auth caído).
      // Conservamos la sesión y caemos al caché.
      debugPrint(
        'ErrorHandler: auth unavailable in $operationName: $e. Trying cache.',
      );
      final cachedResult = await cached();
      if (cachedResult != null) return cachedResult;
      rethrow;
    } on UnauthorizedException catch (e) {
      debugPrint(
        'ErrorHandler: Forbidden (403) in $operationName: $e. Keeping session, trying cache.',
      );
      final cachedResult = await cached();
      if (cachedResult != null) return cachedResult;
      rethrow;
    } on NetworkException catch (e) {
      debugPrint(
        'ErrorHandler: Network exception in $operationName: $e. Trying cache.',
      );
      final cachedResult = await cached();
      if (cachedResult != null) return cachedResult;
      rethrow;
    } on TimeoutException catch (e) {
      debugPrint('ErrorHandler: Timeout in $operationName: $e. Trying cache.');
      final cachedResult = await cached();
      if (cachedResult != null) return cachedResult;
      rethrow;
    } on ServerException catch (e) {
      debugPrint(
        'ErrorHandler: Server exception in $operationName: $e. Trying cache.',
      );
      final cachedResult = await cached();
      if (cachedResult != null) return cachedResult;
      rethrow;
    } on DataParsingException catch (e) {
      debugPrint(
        'ErrorHandler: Data parsing exception in $operationName: $e. Trying cache.',
      );
      final cachedResult = await cached();
      if (cachedResult != null) return cachedResult;
      rethrow;
    } catch (e) {
      debugPrint(
        'ErrorHandler: Exception in $operationName: $e. Trying cache.',
      );
      try {
        final cachedResult = await cached();
        if (cachedResult != null) return cachedResult;
      } catch (cacheErr) {
        debugPrint(
          'ErrorHandler: Failed to read from cache for $operationName: $cacheErr',
        );
      }
      rethrow;
    }
  }

  /// Ejecuta la operación remota con 1 reintento y backoff corto ante fallos
  /// TRANSITORIOS (red, timeout, 5xx, auth no disponible). Los servidores de
  /// UPLA suelen fallar el primer hit tras inactividad ("arranque en frío");
  /// un único reintento recupera la mayoría de esos casos sin molestar al
  /// usuario. Los errores no transitorios (4xx, credenciales inválidas, parseo)
  /// se propagan de inmediato.
  Future<T> _remoteWithRetry<T>(
    Future<T> Function() remote,
    String operationName,
  ) async {
    const maxAttempts = 2;
    var attempt = 0;
    while (true) {
      attempt++;
      try {
        return await remote();
      } on NetworkException {
        if (attempt >= maxAttempts) rethrow;
      } on TimeoutException {
        if (attempt >= maxAttempts) rethrow;
      } on AuthUnavailableException {
        if (attempt >= maxAttempts) rethrow;
      } on ServerException catch (e) {
        // Solo 5xx es transitorio; el resto (p.ej. respuesta no-JSON 200) no.
        if (attempt >= maxAttempts || e.status < 500) rethrow;
      }
      final backoff = Duration(milliseconds: 500 * attempt);
      debugPrint(
        'ErrorHandler: retry $attempt for $operationName in ${backoff.inMilliseconds}ms',
      );
      await Future<void>.delayed(backoff);
    }
  }
}
