import 'dart:convert';
import 'dart:io'; 
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final String baseUrl = 'http://192.168.0.38:8000/api';

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '923305570744-pvm4f5u07ht0pne9egs0d78boqt21lp6.apps.googleusercontent.com',
    scopes: ['email', 'profile'],
  );

  Future<Map<String, dynamic>> loginGoogle(String idToken) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/google'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: json.encode({'id_token': idToken}),
      );
      final data = json.decode(response.body);
      return response.statusCode == 200 
          ? {'success': true, 'message': data['message'], 'data': data['data']}
          : {'success': false, 'message': data['message'] ?? 'Error al autenticar'};
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  Future<void> logout() async {
    try {
      await _googleSignIn.disconnect();
    } catch (e) {
      print("Error al cerrar sesión de Google: $e");
    }
  }

  Future<Map<String, dynamic>> logoutApi(String token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/logout'),
        headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
      );
      return response.statusCode == 200 
          ? {'success': true, 'message': 'Sesión cerrada en servidor'}
          : {'success': false, 'message': 'Error al cerrar sesión'};
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }


  Future<Map<String, dynamic>> subirDocumentos({
    required File ine,
    required File comprobante,
    required File fotoPerfil,
    required File antecedentes,
  }) async {
    try {
      if (!ine.existsSync() || !comprobante.existsSync() || !fotoPerfil.existsSync() || !antecedentes.existsSync()) {
        return {'success': false, 'message': 'Uno o más archivos no han sido encontrados'};
      }

      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/auth/subir-documentos'));
      
      // Cabecera para forzar respuesta JSON limpia
      request.headers.addAll({
        'Accept': 'application/json',
      });

      // Adjuntamos los archivos directamente
      request.files.add(await http.MultipartFile.fromPath('ine', ine.path));
      request.files.add(await http.MultipartFile.fromPath('comprobante', comprobante.path));
      request.files.add(await http.MultipartFile.fromPath('foto_perfil', fotoPerfil.path));
      request.files.add(await http.MultipartFile.fromPath('antecedentes', antecedentes.path));

      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      var result = json.decode(responseData);

      return response.statusCode == 200 
          ? {'success': true, 'message': 'Documentos subidos correctamente'}
          : {'success': false, 'message': result['message'] ?? 'Error al subir documentos'};
    } catch (e) {
      return {'success': false, 'message': 'Error al enviar archivos: $e'};
    }
  }
}