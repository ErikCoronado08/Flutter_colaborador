import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart'; 
import '../../widgets/loading_overlay.dart'; 
import '../../services/auth_service.dart'; // <--- Importación del nuevo servicio

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _estaCargando = false;
  
  // 1. Controladores para leer lo que el usuario escribe
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // 2. Instancia de Google Sign In
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '923305570744-pvm4f5u07ht0pne9egs0d78boqt21lp6.apps.googleusercontent.com',
    scopes: ['email', 'profile'],
  );

  // 3. Instancia de tu nuevo AuthService (Solo para Google)
  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- LOGIN TRADICIONAL (Se mantiene directo en la vista) ---
  Future<void> _procesarLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, ingresa tu correo y contraseña'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _estaCargando = true);
    
    try {
      final response = await http.post(
        Uri.parse('http://192.168.0.38:8000/api/login'), 
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      final data = json.decode(response.body);

      setState(() => _estaCargando = false);

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message'] ?? 'Inicio de sesión exitoso'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pushReplacementNamed(context, '/'); 
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message'] ?? 'Credenciales incorrectas'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _estaCargando = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error de conexión: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // --- LOGIN CON GOOGLE (Conectado a tu AuthService) ---
  Future<void> _handleGoogleSignIn() async {
    setState(() => _estaCargando = true);
    
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        setState(() => _estaCargando = false);
        return; 
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Usamos el servicio y le pasamos el token
      final resultado = await _authService.loginGoogle(googleAuth.idToken!);

      if (resultado['success']) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(resultado['message']),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pushReplacementNamed(context, '/');
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(resultado['message']),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _estaCargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _estaCargando,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 430),
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: const Color(0xFFE4E4E4)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 20, offset: const Offset(0, 8)),
                  ],
                ),
                child: Column(
                  children: [
                    Image.asset('assets/images/logo.png', width: 120),
                    const SizedBox(height: 25),
                    const Text("Iniciar sesión", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF111111))),
                    const SizedBox(height: 10),
                    Container(width: 60, height: 3, decoration: BoxDecoration(color: const Color(0xFFE26112), borderRadius: BorderRadius.circular(50))),
                    const SizedBox(height: 35),

                    const Align(alignment: Alignment.centerLeft, child: Text("Correo o teléfono", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Color(0xFF444444)))),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      cursorColor: const Color(0xFFE26112),
                      style: const TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        hintText: "Ingresa tu correo o teléfono",
                        hintStyle: const TextStyle(color: Color(0xFFB4B4B4)),
                        prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF999999)),
                        filled: true,
                        fillColor: Colors.white,
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFDADADA))),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE26112), width: 1.8)),
                      ),
                    ),
                    const SizedBox(height: 22),

                    const Align(alignment: Alignment.centerLeft, child: Text("Contraseña", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Color(0xFF444444)))),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      cursorColor: const Color(0xFFE26112),
                      style: const TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        hintText: "Ingresa tu contraseña",
                        hintStyle: const TextStyle(color: Color(0xFFB4B4B4)),
                        prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF999999)),
                        suffixIcon: const Icon(Icons.visibility_outlined, color: Color(0xFF999999)),
                        filled: true,
                        fillColor: Colors.white,
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFDADADA))),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE26112), width: 1.8)),
                      ),
                    ),
                    const SizedBox(height: 12),

                    Align(alignment: Alignment.centerRight, child: GestureDetector(onTap: () {}, child: const Text("¿Olvidaste tu contraseña?", style: TextStyle(color: Color(0xFFE26112), fontWeight: FontWeight.w500)))),
                    const SizedBox(height: 25),

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _procesarLogin,
                        style: ElevatedButton.styleFrom(elevation: 0, backgroundColor: const Color(0xFFE26112), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Iniciar sesión", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                            SizedBox(width: 10),
                            Icon(Icons.arrow_forward, color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.grey.shade300)),
                        const Padding(padding: EdgeInsets.symmetric(horizontal: 15), child: Text("o", style: TextStyle(color: Color(0xFF777777)))),
                        Expanded(child: Divider(color: Colors.grey.shade300)),
                      ],
                    ),
                    const SizedBox(height: 25),

                    InkWell(
                      onTap: _handleGoogleSignIn,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: double.infinity,
                        height: 55,
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFDADADA))),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset('assets/images/google.png', width: 22, height: 22),
                            const SizedBox(width: 12),
                            const Text("Continuar con Google", style: TextStyle(color: Color(0xFF222222), fontWeight: FontWeight.w500, fontSize: 15)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("¿No tienes cuenta? ", style: TextStyle(color: Color(0xFF666666))),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/register'),
                          child: const Text("Crear cuenta", style: TextStyle(color: Color(0xFFE26112), fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}