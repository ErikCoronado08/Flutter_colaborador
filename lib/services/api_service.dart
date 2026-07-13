import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://192.168.0.172:8000/api/usuario';

  static Future<Map<String, dynamic>?> obtenerPerfil() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/perfil'));
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }
      print('Error obtenerPerfil status: ${response.statusCode} ${response.body}');
    } catch (e) {
      print('Error al obtener perfil: $e');
    }
    return null;
  }

  static Future<Map<String, dynamic>?> obtenerPerfilUsuario() async {
    return obtenerPerfil();
  }

  static Future<bool> actualizarFotoPerfil(File imagen) async {
    try {
      final uri = Uri.parse('$baseUrl/foto');
      final request = http.MultipartRequest('POST', uri);
      request.files.add(await http.MultipartFile.fromPath('foto', imagen.path));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200) {
        return true;
      }
      print('Error actualizarFotoPerfil status: ${response.statusCode} ${response.body}');
    } catch (e) {
      print('Error al actualizar foto: $e');
    }
    return false;
  }

  static Future<bool> actualizarEspecialidades(List<String> especialidades) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/especialidades'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'especialidades': especialidades}),
      );
      if (response.statusCode == 200) {
        return true;
      }
      print('Error actualizarEspecialidades status: ${response.statusCode} ${response.body}');
    } catch (e) {
      print('Error al actualizar especialidades: $e');
    }
    return false;
  }

  static Future<bool> solicitarRetiro() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/retiro'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'monto': 0}),
      );
      if (response.statusCode == 200) {
        return true;
      }
      print('Error solicitarRetiro status: ${response.statusCode} ${response.body}');
    } catch (e) {
      print('Error al solicitar retiro: $e');
    }
    return false;
  }

  static Future<bool> logout() async {
    try {
      final response = await http.post(Uri.parse('$baseUrl/logout'));
      if (response.statusCode == 200) {
        return true;
      }
      print('Error logout status: ${response.statusCode} ${response.body}');
    } catch (e) {
      print('Error al cerrar sesión: $e');
    }
    return false;
  }

  static Future<Map<String, dynamic>?> obtenerEstadisticas() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/estadisticas'));
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }
      print('Error obtenerEstadisticas status: ${response.statusCode} ${response.body}');
    } catch (e) {
      print('Error al obtener estadísticas: $e');
    }
    return null;
  }

  static Future<List<dynamic>?> obtenerAgenda() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/agenda'));
      if (response.statusCode == 200) {
        return json.decode(response.body) as List<dynamic>;
      }
      print('Error obtenerAgenda status: ${response.statusCode} ${response.body}');
    } catch (e) {
      print('Error al obtener agenda: $e');
    }
    return null;
  }

  static Future<List<dynamic>?> obtenerChats() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/notificaciones'));
      if (response.statusCode == 200) {
        return json.decode(response.body) as List<dynamic>;
      }
      print('Error obtenerChats status: ${response.statusCode} ${response.body}');
    } catch (e) {
      print('Error al obtener chats: $e');
    }
    return null;
  }
}
