import 'dart:convert';
import 'package:http/http.dart' as http;

class FinanzasService {
  // URL local para probar el backend en la red del equipo
  final String baseUrl = 'http://192.168.0.172:8000/api';

  // ---> INICIO INTEGRACIÓN HTTP <---
  Future<Map<String, dynamic>> obtenerSaldoUsuario(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/saldo/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer TU_TOKEN_JWT_AQUI',
        },
      );

      if (response.statusCode == 200) {
        // Retorna los datos reales de la base de datos
        return json.decode(response.body);
      } else {
        throw Exception('Error al cargar la información financiera');
      }
    } catch (e) {
      // MOCK DE SEGURIDAD: Mientras construyen el backend, devolvemos 
      // estos datos estáticos para que tu aplicación no se rompa al probarla.
      return {
        'saldoDisponible': 1254890.50,
        'saldoTransito': 450.00,
      };
    }
  }

  Future<bool> solicitarRetiro(double monto, String cuentaId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/retiro'),
        body: json.encode({'monto': monto, 'cuenta_id': cuentaId}),
        headers: {'Content-Type': 'application/json'},
      );
      return response.statusCode == 200;
    } catch (e) {
      return false; 
    }
  }
  // ---> FIN INTEGRACIÓN HTTP <---
}