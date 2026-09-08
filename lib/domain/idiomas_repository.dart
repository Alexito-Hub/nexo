import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nexo/core/errors.dart';
import 'package:nexo/domain/idiomas_models.dart';

/// Resultado del intento de login en el portal de Idiomas.
enum IdiomasLoginResult { success, invalidCredentials, networkError }

class IdiomasRepository {
  IdiomasRepository({required http.Client client}) : _client = client;
  final http.Client _client;
  String? _token;

  /// Inicia sesión en el portal de Idiomas.
  /// Diferencia credenciales inválidas de error de red.
  Future<IdiomasLoginResult> login(String username, String password) async {
    try {
      final res = await _client
          .post(
            Uri.parse('https://services.upla.edu.pe/Login'),
            headers: {
              'Content-Type': 'application/json',
              'User-Agent': 'NexoApp/1.0',
            },
            body: jsonEncode({'codigo': username, 'contraseña': password}),
          )
          .timeout(const Duration(seconds: 15));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data != null && data['rpta'] == 'Correcto') {
          _token = data['token'];
          return IdiomasLoginResult.success;
        }
        // El servidor respondió pero las credenciales no son válidas.
        return IdiomasLoginResult.invalidCredentials;
      }
      if (res.statusCode >= 500) {
        return IdiomasLoginResult.networkError;
      }
      return IdiomasLoginResult.invalidCredentials;
    } catch (e) {
      return IdiomasLoginResult.networkError;
    }
  }

  /// Obtiene los cursos matriculados de Idiomas.
  /// Lanza [NetworkException] ante fallos de red en vez de devolver `[]`.
  Future<List<IdiomasCourse>> getMatricula(String username) async {
    if (_token == null) {
      throw const NetworkException('Token de Idiomas no disponible.');
    }

    try {
      final res = await _client
          .get(
            Uri.parse(
              'https://apidiomas.upla.edu.pe/Matricula/ListarMisAsignaturasMatriculadas/$username',
            ),
            headers: {
              'Authorization': 'Bearer $_token',
              'User-Agent': 'NexoApp/1.0',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (res.statusCode == 401) {
        _token = null;
        throw const NetworkException('Sesión de Idiomas expirada.');
      }
      if (res.statusCode >= 500) {
        throw ServerException(
          'API de Idiomas no disponible (${res.statusCode})',
          status: res.statusCode,
        );
      }
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data != null && data['resultado'] != null) {
          final list = data['resultado'] as List;
          return list.map((e) => IdiomasCourse.fromJson(e)).toList();
        }
      }
      // Respuesta 200 sin datos = genuinamente sin matrícula.
      return [];
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException(
        'Error de red al obtener matrícula de Idiomas: $e',
      );
    }
  }

  /// Obtiene las notas de un curso específico por su ID de detalle de matrícula.
  /// Lanza [NetworkException] ante fallos de red en vez de devolver `[]`.
  Future<List<dynamic>> getNotas(int detMatriculaId) async {
    if (_token == null) {
      throw const NetworkException('Token de Idiomas no disponible.');
    }

    try {
      final res = await _client
          .get(
            Uri.parse(
              'https://apidiomas.upla.edu.pe/Nota/NotasInglesXDetMatriculaId/$detMatriculaId',
            ),
            headers: {
              'Authorization': 'Bearer $_token',
              'User-Agent': 'NexoApp/1.0',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (res.statusCode == 401) {
        _token = null;
        throw const NetworkException('Sesión de Idiomas expirada.');
      }
      if (res.statusCode >= 500) {
        throw ServerException(
          'API de Idiomas no disponible (${res.statusCode})',
          status: res.statusCode,
        );
      }
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data != null && data['resultado'] != null) {
          return data['resultado'] as List<dynamic>;
        }
      }
      return [];
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Error de red al obtener notas de Idiomas: $e');
    }
  }
}
