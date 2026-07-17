import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nexo/core/config.dart';
import 'package:nexo/core/errors.dart';

class ApiEnvelope<T> {
  final bool success;
  final String? mensaje;
  final int? code;
  final T? data;
  const ApiEnvelope({
    required this.success,
    this.mensaje,
    this.code,
    this.data,
  });
  factory ApiEnvelope.fromJson(
    Map<String, dynamic> json,
    T Function(Object? raw) decode,
  ) {
    return ApiEnvelope(
      success: _envBool(json['success']),
      mensaje: json['mensaje']?.toString(),
      code: _envInt(json['codigo']),
      data: json.containsKey('data') ? decode(json['data']) : null,
    );
  }
}

bool _envBool(Object? v) {
  if (v is bool) return v;
  if (v is num) return v != 0;
  if (v is String) {
    final t = v.trim().toLowerCase();
    return t == 'true' || t == '1' || t == 's' || t == 'si';
  }
  return false;
}

int? _envInt(Object? v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v);
  return null;
}

/// Resultado de un intento de re-autenticación. Permite distinguir un fallo
/// transitorio del servidor de auth (conservar sesión) de un rechazo real de
/// credenciales (cerrar sesión).
enum ReauthOutcome {
  /// Se obtuvo token/sesión nuevos: reintentar la petición original.
  refreshed,

  /// El servidor rechazó las credenciales: terminar la sesión (logout).
  invalidCredentials,

  /// El servidor de auth no respondió / falló de forma transitoria: NO cerrar
  /// sesión; degradar con gracia (caché + reintento).
  unavailable,
}

class ApiClient {
  ApiClient({http.Client? transport}) : _http = transport ?? http.Client();
  final http.Client _http;
  String? _token;
  void Function()? onUnauthorized;
  Future<ReauthOutcome> Function()? reauthenticate;
  String? get token => _token;
  void setToken(String? value) => _token = value;
  Future<ApiEnvelope<T>> get<T>(
    String path, {
    Map<String, String>? query,
    bool authorize = true,
    required T Function(Object? raw) decode,
  }) =>
      _send<T>('GET', path, query: query, authorize: authorize, decode: decode);
  Future<ApiEnvelope<T>> post<T>(
    String path, {
    Object? body,
    bool authorize = true,
    required T Function(Object? raw) decode,
  }) =>
      _send<T>('POST', path, body: body, authorize: authorize, decode: decode);
  Future<ApiEnvelope<T>> _send<T>(
    String method,
    String path, {
    Map<String, String>? query,
    Object? body,
    bool authorize = true,
    required T Function(Object? raw) decode,
    bool isRetry = false,
  }) async {
    final uri = _buildUri(path, query);
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json; charset=utf-8',
      'User-Agent': AppConfig.userAgent,
    };
    if (authorize && _token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    http.Response res;
    try {
      final req = http.Request(method, uri)..headers.addAll(headers);
      if (body != null) {
        req.body = jsonEncode(body);
      }
      final streamed = await _http.send(req).timeout(AppConfig.httpTimeout);
      res = await http.Response.fromStream(streamed);
    } on TimeoutException {
      throw const TimeoutException('El servidor no respondió a tiempo.');
    } catch (e) {
      throw NetworkException('Error de red: $e');
    }
    Map<String, dynamic>? payload;
    final bodyText = utf8.decode(res.bodyBytes, allowMalformed: true);
    final trimmedHead = bodyText.trimLeft();
    final isHtml =
        res.statusCode < 400 &&
        (trimmedHead.startsWith('<!doctype') ||
            trimmedHead.startsWith('<!DOCTYPE') ||
            trimmedHead.startsWith('<html'));
    if (isHtml) {
      // SIGMA devuelve la página HTML de login cuando la sesión murió. Para una
      // petición autorizada esto es la MISMA condición que un 401: se maneja de
      // forma unificada (antes 401 y HTML se trataban distinto — ver ④).
      if (authorize) {
        return _handleAuthChallenge<T>(
          method,
          path,
          query: query,
          body: body,
          authorize: authorize,
          decode: decode,
          isRetry: isRetry,
          expiredMessage: 'Sesión expirada.',
        );
      }
      throw ServerException(
        'El servicio no está disponible temporalmente.',
        status: res.statusCode,
      );
    }
    try {
      final parsed = jsonDecode(bodyText);
      if (parsed is Map<String, dynamic>) payload = parsed;
    } catch (_) {}
    if (res.statusCode == 401) {
      return _handleAuthChallenge<T>(
        method,
        path,
        query: query,
        body: body,
        authorize: authorize,
        decode: decode,
        isRetry: isRetry,
        expiredMessage: payload?['mensaje'] as String? ?? 'Sesión expirada.',
      );
    }
    if (res.statusCode == 403) {
      throw UnauthorizedException(
        payload?['mensaje'] as String? ?? 'Acceso denegado.',
      );
    }
    if (res.statusCode >= 500) {
      throw ServerException(
        payload?['mensaje'] as String? ?? 'Error del servidor',
        status: res.statusCode,
      );
    }
    if (res.statusCode >= 400) {
      throw BadRequestException(
        payload?['mensaje'] as String? ?? 'Petición rechazada',
        status: res.statusCode,
        payload: payload,
      );
    }
    if (payload == null) {
      return ApiEnvelope<T>(success: true, data: decode(null));
    }
    return ApiEnvelope<T>.fromJson(payload, decode);
  }

  /// Punto ÚNICO de decisión ante un reto de autenticación (401 o página HTML
  /// de login en una petición autorizada). Distingue tres desenlaces:
  ///   - refreshed          → reintenta la petición con el token nuevo.
  ///   - unavailable        → transitorio: NO cierra sesión; lanza
  ///                          AuthUnavailableException para que el ErrorHandler
  ///                          caiga al caché y reintente.
  ///   - invalidCredentials → cierra sesión (única condición que hace logout).
  Future<ApiEnvelope<T>> _handleAuthChallenge<T>(
    String method,
    String path, {
    Map<String, String>? query,
    Object? body,
    required bool authorize,
    required T Function(Object? raw) decode,
    required bool isRetry,
    required String expiredMessage,
  }) async {
    if (authorize && !isRetry && reauthenticate != null) {
      final outcome = await reauthenticate!();
      switch (outcome) {
        case ReauthOutcome.refreshed:
          return _send<T>(
            method,
            path,
            query: query,
            body: body,
            authorize: authorize,
            decode: decode,
            isRetry: true,
          );
        case ReauthOutcome.unavailable:
          throw const AuthUnavailableException();
        case ReauthOutcome.invalidCredentials:
          break; // cae al logout de abajo
      }
    }
    // Credenciales confirmadas inválidas (o no hay forma de reautenticar).
    if (authorize) onUnauthorized?.call();
    throw SessionExpiredException(expiredMessage);
  }

  Uri _buildUri(String path, Map<String, String>? query) {
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    final base = Uri.parse('${AppConfig.apiBaseUrl}/$cleanPath');
    if (query == null || query.isEmpty) return base;
    return base.replace(queryParameters: {...base.queryParameters, ...query});
  }

  void close() => _http.close();
}
