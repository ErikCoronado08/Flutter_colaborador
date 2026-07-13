import 'dart:convert';
import 'package:http/http.dart' as http;

class FinanzasService {

  final String baseUrl = 'http://192.168.0.130:8000/api/finanzas';

  Future<Map<String, dynamic>> obtenerSaldoUsuario() async {
    final response = await http.get(Uri.parse('$baseUrl/saldo'), headers: {'Accept': 'application/json'});
    if (response.statusCode == 200) return json.decode(response.body)['data'];
    throw Exception('Error al cargar saldo');
  }

  Future<List<dynamic>> obtenerHistorial() async {
    final response = await http.get(Uri.parse('$baseUrl/historial-servicios'), headers: {'Accept': 'application/json'});
    if (response.statusCode == 200) return json.decode(response.body)['data'];
    throw Exception('Error al cargar historial');
  }

  Future<List<dynamic>> obtenerTransitos() async {
    final response = await http.get(Uri.parse('$baseUrl/transitos'), headers: {'Accept': 'application/json'});
    if (response.statusCode == 200) return json.decode(response.body)['data'];
    throw Exception('Error al cargar tránsitos');
  }

  Future<Map<String, dynamic>> obtenerDetalle(String folio) async {
    final response = await http.get(Uri.parse('$baseUrl/detalle/$folio'), headers: {'Accept': 'application/json'});
    if (response.statusCode == 200) return json.decode(response.body)['data'];
    throw Exception('Error al cargar detalle');
  }

  Future<bool> solicitarRetiro(double monto, String cuentaId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/solicitar-retiro'),
        body: json.encode({'monto': monto, 'cuenta_id': cuentaId}),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      );
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }
}