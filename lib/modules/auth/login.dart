import 'package:flutter/material.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  BoxShadow(
                    color: Colors.black.withOpacity(.05),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  /// LOGO
                  Image.asset('assets/images/logo.png', width: 120),
                  const SizedBox(height: 25),

                  /// TITULO
                  const Text(
                    "Iniciar sesión",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF111111)),
                  ),
                  const SizedBox(height: 10),
                  
                  // Línea decorativa con el Naranja JobHub
                  Container(
                    width: 60, height: 3,
                    decoration: BoxDecoration(color: const Color(0xFFE26112), borderRadius: BorderRadius.circular(50)),
                  ),
                  const SizedBox(height: 35),

                  /// CORREO
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Correo o teléfono", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Color(0xFF444444))),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    cursorColor: const Color(0xFFE26112),
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      hintText: "Ingresa tu correo o teléfono",
                      hintStyle: const TextStyle(color: Color(0xFFB4B4B4)),
                      prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF999999)),
                      filled: true,
                      fillColor: Colors.white,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFDADADA)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE26112), width: 1.8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),

                  /// PASSWORD
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Contraseña", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Color(0xFF444444))),
                  ),
                  const SizedBox(height: 10),
                  TextField(
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
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFDADADA)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE26112), width: 1.8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {},
                      child: const Text("¿Olvidaste tu contraseña?", style: TextStyle(color: Color(0xFFE26112), fontWeight: FontWeight.w500)),
                    ),
                  ),
                  const SizedBox(height: 25),

                  /// BOTON LOGIN
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      // 👇 AQUÍ CONECTAMOS EL INICIO DE SESIÓN A TU MENÚ PRINCIPAL
                      onPressed: () => Navigator.pushReplacementNamed(context, '/'),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: const Color(0xFFE26112),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
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

                  /// DIVIDER
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey.shade300)),
                      const Padding(padding: EdgeInsets.symmetric(horizontal: 15), child: Text("o", style: TextStyle(color: Color(0xFF777777)))),
                      Expanded(child: Divider(color: Colors.grey.shade300)),
                    ],
                  ),
                  const SizedBox(height: 25),

                  /// GOOGLE
                  Container(
                    width: double.infinity,
                    height: 55,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFDADADA)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('assets/images/google.png', width: 22, height: 22),
                        const SizedBox(width: 12),
                        const Text("Continuar con Google", style: TextStyle(color: Color(0xFF222222), fontWeight: FontWeight.w500, fontSize: 15)),
                      ],
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
    );
  }
}