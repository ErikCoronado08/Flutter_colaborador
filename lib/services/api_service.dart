import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrlWeb = "https://jobhub.utptics.com/api/colaborador"; 

  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ======================================
  // 1. SOLICITUDES Y OPERACIONES (Web)
  // ======================================
  static Future<List<dynamic>> obtenerSolicitudes() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse("$baseUrlWeb/mi-agenda"), headers: headers);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['solicitudes'] != null) return data['solicitudes'] as List<dynamic>;
      }
    } catch (e) { 
      print("Error obteniendo solicitudes: $e"); 
    }
    return [];
  }

  static Future<bool> agendarSolicitud(Map<String, dynamic> payload) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse("$baseUrlWeb/mi-agenda"),
        headers: headers,
        body: jsonEncode(payload),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Error al agendar: $e");
      return false;
    }
  }

  static Future<bool> rechazarSolicitud(String solicitudId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse("$baseUrlWeb/mi-agenda/rechazar"),
        headers: headers,
        body: jsonEncode({"solicitud_id": solicitudId}),
      );
      return response.statusCode == 200;
    } catch (e) { return false; }
  }

  static Future<bool> cambiarEstadoOperativo(String id, String estado) async {
    try {
      final headers = await _getHeaders();
      final response = await http.patch(
        Uri.parse("$baseUrlWeb/operaciones/estado/$id"),
        headers: headers,
        body: jsonEncode({"estado": estado}),
      );
      return response.statusCode == 200;
    } catch (e) { return false; }
  }

  static Future<Map<String, dynamic>> subirEvidencia(String servicioId, File imagen) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrlWeb/operaciones/subir-evidencia'));
      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });
      
      request.fields['servicio_id'] = servicioId;
      request.files.add(await http.MultipartFile.fromPath('evidencia', imagen.path));
      
      var response = await request.send();
      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Evidencia subida correctamente'};
      }
      return {'success': false, 'message': 'Error al procesar el cobro'};
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión'};
    }
  }

  // 💡 NUEVO: Función para enviar un reporte a la BD
  static Future<bool> enviarReporte(Map<String, dynamic> payload) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse("$baseUrlWeb/operaciones/reporte"),
        headers: headers,
        body: jsonEncode(payload),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  // ======================================
  // 2. CHAT / MENSAJES (Web)
  // ======================================
  static Future<List<dynamic>?> obtenerConversaciones() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse('$baseUrlWeb/conversaciones'), headers: headers);
      if (response.statusCode == 200) return jsonDecode(response.body) as List<dynamic>;
    } catch (e) {}
    return null;
  }

  static Future<List<dynamic>> obtenerChat(String clienteId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse("$baseUrlWeb/mensajes/$clienteId"), headers: headers);
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      }
    } catch (e) {}
    return [];
  }

  static Future<bool> enviarMensaje(String clienteId, String mensaje) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse("$baseUrlWeb/mensajes"),
        headers: headers,
        body: jsonEncode({"cliente_id": clienteId, "contenido": mensaje}),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) { return false; }
  }

  static Future<bool> enviarImagenChat(String clienteId, File imagen) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrlWeb/mensajes'));
      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });
      
      request.fields['cliente_id'] = clienteId;
      request.files.add(await http.MultipartFile.fromPath('imagen', imagen.path));
      
      var response = await request.send();
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Error enviando imagen al chat: $e");
      return false;
    }
  }

  // ======================================
  // 3. DASHBOARD, PERFIL Y AYUDA (Web)
  // ======================================
  static Future<Map<String, dynamic>?> obtenerDashboard() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse('$baseUrlWeb/mi-dashboard-colaborador'), headers: headers);
      if (response.statusCode == 200) return jsonDecode(response.body);
    } catch (e) {}
    return null;
  }

  static Future<Map<String, dynamic>?> obtenerPerfilUsuario() async {
    final dash = await obtenerDashboard();
    return dash != null ? dash['perfil'] : null;
  }

  static Future<Map<String, dynamic>?> obtenerEstadisticas() async {
    final dash = await obtenerDashboard();
    return dash != null ? dash['estadisticas'] : null;
  }

  static Future<bool> actualizarFotoPerfil(File imagen) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      var request = http.MultipartRequest('POST', Uri.parse('$baseUrlWeb/actualizar-perfil'));
      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });
      
      request.files.add(await http.MultipartFile.fromPath('foto_perfil', imagen.path));

      var response = await request.send();
      return response.statusCode == 200;
    } catch (e) {
      print('Error al actualizar foto: $e');
    }
    return false;
  }

  // 💡 NUEVO: Traer información de la tabla de Centro de Ayuda
  static Future<List<dynamic>> obtenerCentroAyuda() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse('$baseUrlWeb/centro-ayuda'), headers: headers);
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      }
    } catch (e) {
      print("Error obteniendo centro de ayuda: $e");
    }
    return [];
  }

  // ======================================
  // 4. AGENDA (Web)
  // ======================================
  static Future<Map<String, dynamic>?> obtenerAgendaCompleta() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse('$baseUrlWeb/mi-agenda'), headers: headers);
      if (response.statusCode == 200) return jsonDecode(response.body);
    } catch (e) {}
    return null;
  }

  // ======================================
  // 5. MIS SERVICIOS (Web)
  // ======================================
  static Future<List<dynamic>> obtenerMisServicios() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse('$baseUrlWeb/mis-servicios'), headers: headers);
      if (response.statusCode == 200) return jsonDecode(response.body);
    } catch (e) {}
    return [];
  }

  static Future<List<dynamic>> obtenerCatalogoServicios() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse('$baseUrlWeb/catalogo-servicios'), headers: headers);
      if (response.statusCode == 200) return jsonDecode(response.body);
    } catch (e) {}
    return [];
  }

  static Future<bool> crearServicio(Map<String, dynamic> data) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(Uri.parse('$baseUrlWeb/mis-servicios'), headers: headers, body: jsonEncode(data));
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> eliminarServicio(String id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(Uri.parse('$baseUrlWeb/mis-servicios/$id'), headers: headers);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}