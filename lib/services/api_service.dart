import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  // IP centralizada de la API
  static const String baseUrl = "http://192.168.0.130:8000/api"; 

  // ======================================
  // MÉTODOS DE ROXANA (Operaciones y Chat)
  // ======================================
  static Future<List<dynamic>> obtenerSolicitudes() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/operaciones/solicitudes"));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> respuestaSrv = jsonDecode(response.body);
        if (respuestaSrv['ok'] == true && respuestaSrv['data'] != null) {
          return respuestaSrv['data'] as List<dynamic>;
        }
      }
      return [];
    } catch (e) {
      print("Error obteniendo solicitudes: $e");
      return [];
    }
  }

  static Future<bool> aceptarServicio(String servicioId) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/operaciones/aceptar-servicio"),
        headers: {"Content-Type": "application/json", "Accept": "application/json"},
        body: jsonEncode({"servicio_id": servicioId.trim()}),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Error al conectar con la API aceptar-servicio: $e");
      return false;
    }
  }

  static Future<List<dynamic>> obtenerChat(String servicioId) async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/chat/$servicioId"));
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      }
      return [];
    } catch (e) {
      print("Error obteniendo el chat: $e");
      return [];
    }
  }

  static Future<bool> enviarMensaje(String servicioId, String mensaje) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/chat/$servicioId"),
        headers: {"Content-Type": "application/json", "Accept": "application/json"},
        body: jsonEncode({"remitente": "colaborador", "mensaje": mensaje, "contenido": mensaje}),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Error crítico en la petición HTTP: $e");
      return false;
    }
  }

  static Future<void> actualizarUbicacion(String colabId, double lat, double lng) async {
    try {
      await http.patch(
        Uri.parse("$baseUrl/operaciones/ubicacion"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"colaborador_id": colabId, "lat": lat, "lng": lng}),
      );
    } catch (e) {
      print("Error al actualizar ubicación: $e");
    }
  }

  static Future<bool> finalizarServicio(String servicioId) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/operaciones/finalizar-servicio"),
        headers: {"Content-Type": "application/json", "Accept": "application/json"},
        body: jsonEncode({"servicio_id": servicioId.trim()}),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Error al conectar con la API finalizar-servicio: $e");
      return false;
    }
  }

  // ======================================
  // MÉTODOS DE EDUAR (Usuario, Perfil y Agenda)
  // ======================================
  static Future<Map<String, dynamic>?> obtenerPerfil() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/usuario/perfil'));
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
      final uri = Uri.parse('$baseUrl/usuario/foto');
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
        Uri.parse('$baseUrl/usuario/especialidades'),
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
        Uri.parse('$baseUrl/usuario/retiro'),
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
      final response = await http.post(Uri.parse('$baseUrl/usuario/logout'));
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
      final response = await http.get(Uri.parse('$baseUrl/usuario/estadisticas'));
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
      final response = await http.get(Uri.parse('$baseUrl/usuario/agenda'));
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
      final response = await http.get(Uri.parse('$baseUrl/usuario/notificaciones'));
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