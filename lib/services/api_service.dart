import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Asegúrate de usar la IP de tu máquina si pruebas en celular físico, o localhost/10.0.2.2 según tu entorno
  static const String baseUrl = "http://192.168.0.57:8000/api"; 

  // ======================================
  // 1. OBTENER SOLICITUDES DISPONIBLES
  // ======================================
  static Future<List<dynamic>> obtenerSolicitudes() async {
    try {
      // Coincide con: Route::get('/operaciones/solicitudes')
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

 // ======================================
  // ACEPTAR SERVICIO
  // ======================================
  static Future<bool> aceptarServicio(String servicioId) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/operaciones/aceptar-servicio"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json"
        },
        body: jsonEncode({
          "servicio_id": servicioId.trim(),
        }),
      );

      print("--- DEPURACIÓN ACEPTAR SERVICIO ---");
      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Error al conectar con la API aceptar-servicio: $e");
      return false;
    }
  }
  // ======================================
  // 3. OBTENER HISTORIAL DE CHAT
  // ======================================
  static Future<List<dynamic>> obtenerChat(String servicioId) async {
    try {
      // Coincide con: Route::get('/chat/{servicio_id}')
      final response = await http.get(Uri.parse("$baseUrl/chat/$servicioId"));

      print("RESPUESTA OBTENER CHAT: ${response.body}");

      if (response.statusCode == 200) {
        // Si el controlador devuelve el arreglo directo []
        return jsonDecode(response.body) as List<dynamic>;
      }
      return [];
    } catch (e) {
      print("Error obteniendo el chat: $e");
      return [];
    }
  }

  // ======================================
  // ENVIAR MENSAJE AL CHAT (VERSIÓN DEPURACIÓN)
  // ======================================
  static Future<bool> enviarMensaje(String servicioId, String mensaje) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/chat/$servicioId"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json" // Obliga a Laravel a responder en JSON en lugar de HTML si hay error
        },
        body: jsonEncode({
          "remitente": "colaborador",
          "mensaje": mensaje,
          "contenido": mensaje
        }),
      );

      print("--- DEPURACIÓN CHAT ---");
      print("Código de Estado: ${response.statusCode}");
      print("Cuerpo de Respuesta: ${response.body}");

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Error crítico en la petición HTTP: $e");
      return false;
    }
  }
  // ======================================
  // ACTUALIZAR UBICACIÓN DEL REPARTIDOR
  // ======================================
  static Future<void> actualizarUbicacion(String colabId, double lat, double lng) async {
    try {
      await http.patch(
        Uri.parse("$baseUrl/operaciones/ubicacion"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "colaborador_id": colabId,
          "lat": lat,
          "lng": lng,
        }),
      );
    } catch (e) {
      print("Error al actualizar ubicación: $e");
    }
  }

  // ======================================
  // FINALIZAR TRABAJO REAL EN MONGODB
  // ======================================
  static Future<bool> finalizarServicio(String servicioId) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/operaciones/finalizar-servicio"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json"
        },
        body: jsonEncode({
          "servicio_id": servicioId.trim()
        }),
      );

      print("--- DEPURACIÓN FINALIZAR SERVICIO ---");
      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Error al conectar con la API finalizar-servicio: $e");
      return false;
    }
  }
  }
