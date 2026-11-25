import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class RecuperarPassword extends StatefulWidget {
  const RecuperarPassword({super.key});

  @override
  State<RecuperarPassword> createState() => _RecuperarPasswordState();
}

class _RecuperarPasswordState extends State<RecuperarPassword> {
  bool _estaCargando = false;
  final TextEditingController _emailController = TextEditingController();
  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _enviarEnlaceRecuperacion() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingresa tu correo electrónico'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _estaCargando = true);
    
    // Llamada al backend para enviar el correo (implementado abajo en AuthService)
    final resultado = await _authService.recuperarPassword(email);
    
    if (mounted) {
      setState(() => _estaCargando = false);
      
      if (resultado['success']) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Row(
                children: [
                  Icon(Icons.mark_email_read, color: Color(0xFFE26112), size: 28),
                  SizedBox(width: 10),
                  Text('Correo Enviado', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
              content: Text(
                'Hemos enviado un enlace de recuperación a $email. Revisa tu bandeja de entrada o la carpeta de spam para restablecer tu contraseña.',
                style: const TextStyle(color: Colors.black87, height: 1.4),
              ),
              actions: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE26112)),
                  onPressed: () {
                    Navigator.pop(context); // Cierra el modal
                    Navigator.pop(context); // Regresa a la pantalla de Login
                  },
                  child: const Text('Entendido', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(resultado['message']), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF444444)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFDF0E9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.lock_reset, color: Color(0xFFE26112), size: 40),
                      ),
                      const SizedBox(height: 25),
                      const Text("Recuperar contraseña", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF111111))),
                      const SizedBox(height: 15),
                      const Text(
                        "Ingresa el correo electrónico asociado a tu cuenta de colaborador y te enviaremos un enlace para restablecerla.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Color(0xFF666666), height: 1.4),
                      ),
                      const SizedBox(height: 35),

                      const Align(alignment: Alignment.centerLeft, child: Text("Correo electrónico", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Color(0xFF444444)))),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        cursorColor: const Color(0xFFE26112),
                        style: const TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          hintText: "tu@correo.com",
                          hintStyle: const TextStyle(color: Color(0xFFB4B4B4)),
                          prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF999999)),
                          filled: true,
                          fillColor: Colors.white,
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFDADADA))),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE26112), width: 1.8)),
                        ),
                      ),
                      const SizedBox(height: 35),

                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _enviarEnlaceRecuperacion,
                          style: ElevatedButton.styleFrom(elevation: 0, backgroundColor: const Color(0xFFE26112), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                          child: const Text("Enviar enlace", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          if (_estaCargando)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFFE26112), strokeWidth: 4),
              ),
            ),
        ],
      ),
    );
  }
}