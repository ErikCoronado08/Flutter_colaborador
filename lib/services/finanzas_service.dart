import 'dart:convert';
import 'package:http/http.dart' as http;

class FinanzasService {
  // Aquí irá la URL de tu API cuando la desplieguen
  final String baseUrl = 'https://api.jobhub.com/v1/finanzas';

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