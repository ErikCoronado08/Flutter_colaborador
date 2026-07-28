import 'dart:convert';
import 'dart:io'; 
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrlWeb = 'https://jobhub.utptics.com/api/colaborador';

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '923305570744-pvm4f5u07ht0pne9egs0d78boqt21lp6.apps.googleusercontent.com',
    scopes: ['email', 'profile'],
  );

  Future<void> _guardarToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Future<String?> obtenerToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrlWeb/login'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );
      final data = json.decode(response.body);
      
      if (response.statusCode == 200) {
        String? token = data['token'] ?? data['access_token'] ?? (data['data'] != null ? data['data']['token'] : null);
        if (token != null) await _guardarToken(token);
        return {'success': true, 'message': data['message'] ?? 'Login exitoso'};
      }
      return {'success': false, 'message': data['message'] ?? 'Credenciales incorrectas'};
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión'};
    }
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrlWeb/registro'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: json.encode(userData),
      );
      final data = json.decode(response.body);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'message': data['message'] ?? 'Registro exitoso'};
      }
      return {'success': false, 'message': data['message'] ?? 'Error al registrar'};
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión'};
    }
  }

  Future<Map<String, dynamic>> loginGoogle(String idToken) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrlWeb/auth/google'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: json.encode({'id_token': idToken}),
      );
      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        String? token = data['token'] ?? (data['data'] != null ? data['data']['token'] : null);
        if (token != null) await _guardarToken(token);
        return {'success': true, 'message': data['message'] ?? 'Autenticado correctamente'};
      }
      return {'success': false, 'message': data['message'] ?? 'Error al autenticar'};
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión'};
    }
  }

  Future<Map<String, dynamic>> verificarStatus() async {
    try {
      final token = await obtenerToken();
      final response = await http.get(
        Uri.parse('$baseUrlWeb/mi-dashboard-colaborador'),
        headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        bool documentosCompletos = (data['documentos'] as List).isNotEmpty; 
        return {
          'success': true, 
          'data': {
            'documentos_completos': documentosCompletos,
            'estado_general_perfil': data['perfil']['estado'] ?? 'pendiente'
          }
        };
      }
      return {'success': false, 'message': 'Error al verificar estatus'};
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión'};
    }
  }

  // --- CORRECCIÓN EN LOS NOMBRES DE LOS CAMPOS ---
  Future<Map<String, dynamic>> subirDocumentos({
    required File ine,
    required File comprobante,
    required File fotoPerfil,
    required File antecedentes,
  }) async {
    try {
      final token = await obtenerToken();
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrlWeb/subir-documentos')); 
      
      request.headers.addAll({'Accept': 'application/json', 'Authorization': 'Bearer $token'});

      // Los nombres 'domicilio' y 'foto' deben ser EXACTAMENTE estos para que Laravel los acepte
      request.files.add(await http.MultipartFile.fromPath('ine', ine.path));
      request.files.add(await http.MultipartFile.fromPath('domicilio', comprobante.path)); 
      request.files.add(await http.MultipartFile.fromPath('foto', fotoPerfil.path));       
      request.files.add(await http.MultipartFile.fromPath('antecedentes', antecedentes.path));

      var response = await request.send();
      return response.statusCode == 200 
          ? {'success': true, 'message': 'Documentos subidos'}
          : {'success': false, 'message': 'Error al subir documentos'};
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión'};
    }
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await _googleSignIn.disconnect();
    } catch (e) {
      print("Error al cerrar sesión: $e");
    }
  }
}