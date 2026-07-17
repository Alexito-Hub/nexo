sealed class ApiException implements Exception {
  final String message;
  const ApiException(this.message);
  @override
  String toString() => '$runtimeType: $message';
}

class NetworkException extends ApiException {
  const NetworkException(super.message);
}

class TimeoutException extends ApiException {
  const TimeoutException(super.message);
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException(super.message);
}

class SessionExpiredException extends UnauthorizedException {
  const SessionExpiredException([String? message])
    : super(message ?? 'La sesión ha expirado');
}

/// Las credenciales fueron rechazadas positivamente por el servidor de
/// autenticación. Es la ÚNICA condición que debe terminar la sesión (logout).
class InvalidCredentialsException extends ApiException {
  const InvalidCredentialsException([String? message])
    : super(message ?? 'Usuario o contraseña incorrectos.');
}

/// No se pudo (re)autenticar porque el servidor de auth estaba inaccesible,
/// lento o con error transitorio. NO debe hacer logout: se conserva la sesión
/// y el caché, y se degrada con gracia (reintento + datos locales).
class AuthUnavailableException extends ApiException {
  const AuthUnavailableException([String? message])
    : super(
        message ??
            'No se pudo verificar tu sesión en este momento. '
                'Mostrando datos guardados.',
      );
}

class DataParsingException implements Exception {
  final String model;
  final String? field;
  final dynamic rawData;
  final Object? innerError;
  const DataParsingException({
    required this.model,
    this.field,
    this.rawData,
    this.innerError,
  });
  @override
  String toString() =>
      'DataParsingException: Error al parsear el modelo $model'
      '${field != null ? " en el campo $field" : ""}. Error interno: $innerError';
}

class BadRequestException extends ApiException {
  final int status;
  final Map<String, dynamic>? payload;
  const BadRequestException(
    super.message, {
    required this.status,
    this.payload,
  });
}

class ServerException extends ApiException {
  final int status;
  const ServerException(super.message, {required this.status});
}

class AuthException extends ApiException {
  const AuthException(super.message);
}

String humanizeError(Object? error) {
  if (error == null) return 'Ocurrió un error desconocido.';
  final s = error.toString();
  if (s.contains('HandshakeException') ||
      s.contains('CERTIFICATE_VERIFY_FAILED') ||
      s.contains('unable to get local issuer') ||
      s.contains('SSL') ||
      s.contains('TLS')) {
    return 'No se pudo establecer una conexión segura con el servidor. '
        'Verifica que tu fecha y hora del dispositivo sean correctas. '
        'Si persiste, actualiza Nexo o reporta al área de TI.';
  }
  if (s.contains('SocketException') ||
      s.contains('No route to host') ||
      s.contains('Failed host lookup') ||
      s.contains('Network is unreachable')) {
    return 'Sin conexión. Revisa tu Wi-Fi o datos móviles.';
  }
  if (error is TimeoutException || s.contains('TimeoutException')) {
    return 'El servidor está tardando demasiado en responder. '
        'Intenta de nuevo en unos segundos.';
  }
  if (error is ServerException) {
    return 'El servidor reportó un error (${error.status}). '
        'No es algo que tú hiciste mal; reintenta más tarde.';
  }
  if (error is AuthUnavailableException) {
    return 'No se pudo verificar tu sesión (servidor no disponible). '
        'Mostrando datos guardados; reintenta en unos segundos.';
  }
  if (error is InvalidCredentialsException) {
    return error.message.isNotEmpty
        ? error.message
        : 'Usuario o contraseña incorrectos.';
  }
  if (error is UnauthorizedException) {
    return error.message.isNotEmpty
        ? error.message
        : 'Tu sesión expiró. Vuelve a iniciar sesión.';
  }
  if (error is AuthException) return error.message;
  if (error is BadRequestException) {
    return error.message.isNotEmpty
        ? error.message
        : 'La solicitud fue rechazada por el servidor.';
  }
  if (error is DataParsingException) {
    return 'Error al procesar los datos recibidos del servidor. Mostrando copia local.';
  }
  if (error is ApiException) {
    return error.message.isNotEmpty ? error.message : 'Error de comunicación.';
  }
  final clean = s.replaceFirst(RegExp(r'^Exception:\s*'), '');
  return clean.length > 220 ? '${clean.substring(0, 220)}…' : clean;
}
