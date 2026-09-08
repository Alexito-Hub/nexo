import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nexo/domain/idiomas_models.dart';

class IdiomasRepository {
  String? _token;

  /// Inicia sesión en el portal de Idiomas.
  Future<bool> login(String username, String password) async {
    try {
      final res = await http.post(
        Uri.parse('https://services.upla.edu.pe/Login'),
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': 'NexoApp/1.0',
        },
        body: jsonEncode({
          'codigo': username,
          'contraseña': password,
        }),
      ).timeout(const Duration(seconds: 15));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data != null && data['rpta'] == 'Correcto') {
          _token = data['token'];
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Obtiene los cursos matriculados de Idiomas.
  Future<List<IdiomasCourse>> getMatricula(String username) async {
    if (_token == null) return [];

    try {
      final res = await http.get(
        Uri.parse('https://apidiomas.upla.edu.pe/Matricula/ListarMisAsignaturasMatriculadas/$username'),
        headers: {
          'Authorization': 'Bearer $_token',
          'User-Agent': 'NexoApp/1.0',
        },
      ).timeout(const Duration(seconds: 15));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data != null && data['resultado'] != null) {
          final list = data['resultado'] as List;
          return list.map((e) => IdiomasCourse.fromJson(e)).toList();
        }
      }
    } catch (e) {
      // Ignorar
    }
    return [];
  }

  /// Obtiene las notas de un curso específico por su ID de detalle de matrícula.
  Future<List<dynamic>> getNotas(int detMatriculaId) async {
    if (_token == null) return [];

    try {
      final res = await http.get(
        Uri.parse('https://apidiomas.upla.edu.pe/Nota/NotasInglesXDetMatriculaId/$detMatriculaId'),
        headers: {
          'Authorization': 'Bearer $_token',
          'User-Agent': 'NexoApp/1.0',
        },
      ).timeout(const Duration(seconds: 15));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data != null && data['resultado'] != null) {
          return data['resultado'] as List<dynamic>;
        }
      }
    } catch (e) {
      // Ignorar
    }
    return [];
  }
}
