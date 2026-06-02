import 'package:flutter/material.dart';
import '../../widgets/custom_textfield.dart'; // Ajusta la ruta a donde guardes los widgets de Gadiel
import '../../widgets/custom_button.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  String? selectedGender;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
          child: Column(
            children: [
              /// LOGO
              Center(
                child: Column(
                  children: [
                    Image.asset('assets/images/logo.png', width: 90),
                    const SizedBox(height: 14),
                    const Text(
                      "CONECTANDO OPORTUNIDADES",
                      style: TextStyle(color: Color(0xFFE26112), fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),

              /// CARD PRINCIPAL
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: const Color(0xFFE8E8E8)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 20, offset: const Offset(0, 8)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Text("Crea tu cuenta", style: TextStyle(color: Color(0xFF111111), fontSize: 30, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 8),
                    const Center(
                      child: Text("Paso 1 de 2: Información personal", style: TextStyle(color: Color(0xFF666666), fontSize: 15)),
                    ),
                    const SizedBox(height: 25),

                    /// PROGRESO
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: const LinearProgressIndicator(
                        value: 0.5,
                        minHeight: 8,
                        backgroundColor: Color(0xFFE5E5E5),
                        color: Color(0xFFE26112),
                      ),
                    ),
                    const SizedBox(height: 25),

                    const CustomTextField(hint: "Ingresa tu nombre completo", icon: Icons.person),
                    const SizedBox(height: 16),
                    const CustomTextField(hint: "Ingresa tu correo electrónico", icon: Icons.email_outlined),
                    const SizedBox(height: 16),
                    const CustomTextField(hint: "Ingresa tu número de teléfono", icon: Icons.phone),
                    const SizedBox(height: 16),
                    const CustomTextField(hint: "Selecciona tu fecha de nacimiento", icon: Icons.calendar_today),
                    const SizedBox(height: 16),
                    const CustomTextField(hint: "Ingresa tu dirección", icon: Icons.location_on),
                    const SizedBox(height: 16),

                    // DROPDOWN
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 3))],
                      ),
                      child: DropdownButtonFormField<String>(
                        value: selectedGender,
                        dropdownColor: Colors.white,
                        style: const TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.w500),
                        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFFE26112), size: 28),
                        decoration: InputDecoration(
                          labelText: "Género",
                          labelStyle: const TextStyle(color: Color(0xFF777777)),
                          hintText: "Selecciona tu género",
                          hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
                          prefixIcon: const Icon(Icons.people_outline, color: Color(0xFFE26112)),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1.5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: Color(0xFFE26112), width: 2),
                          ),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        items: const [
                          DropdownMenuItem(value: "Masculino", child: Text("Masculino")),
                          DropdownMenuItem(value: "Femenino", child: Text("Femenino")),
                          DropdownMenuItem(value: "Otro", child: Text("Otro")),
                        ],
                        onChanged: (value) => setState(() => selectedGender = value),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const CustomTextField(hint: "Cuéntanos sobre tu experiencia laboral", icon: Icons.work),
                    const SizedBox(height: 28),

                    /// BOTON
                    CustomButton(
                      text: "CONTINUAR A DOCUMENTACIÓN",
                      onTap: () => Navigator.pushNamed(context, '/documents'),
                    ),
                    const SizedBox(height: 20),

                    /// LOGIN
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("¿Ya tienes cuenta? ", style: TextStyle(color: Color(0xFF777777))),
                        GestureDetector(
                          onTap: () => Navigator.pushReplacementNamed(context, '/login'),
                          child: const Text("Iniciar sesión", style: TextStyle(color: Color(0xFFE26112), fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}