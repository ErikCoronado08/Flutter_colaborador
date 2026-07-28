import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FinanzasService {
  final String baseUrl = 'https://jobhub.utptics.com/api/colaborador';

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> obtenerBilletera() async {
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse('$baseUrl/billetera-finanzas'), headers: headers);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Error al cargar la billetera');
  }

  Future<bool> solicitarRetiro(double monto) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/billetera/retirar'),
        body: json.encode({'monto': monto}),
        headers: headers,
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<List<dynamic>> obtenerHistorial() async {
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse('$baseUrl/historial-servicios'), headers: headers);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['servicios'] ?? [];
    }
    throw Exception('Error al cargar historial');
  }

  // Ahora soporta buscar por 'id' o por 'folio'
  Future<Map<String, dynamic>> obtenerDetalle(Map<String, dynamic> params) async {
    final headers = await _getHeaders();
    String url = '$baseUrl/detalle-liquidacion?';
    
    if (params.containsKey('id')) {
      url += 'id=${params['id']}';
    } else if (params.containsKey('folio')) {
      url += 'folio=${params['folio']}';
    }

    final response = await http.get(Uri.parse(url), headers: headers);
    if (response.statusCode == 200) {
      return json.decode(response.body); 
    }
    throw Exception('Error al cargar detalle de liquidación');
  }

  // Nuevo método para descargar la factura en texto
  Future<String?> descargarFactura(String idFactura) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse('$baseUrl/detalle-liquidacion/descargar-pdf/$idFactura'), headers: headers);
      if (response.statusCode == 200) {
        return response.body;
      }
    } catch (e) {
      print("Error al descargar factura: $e");
    }
    return null;
  }
}