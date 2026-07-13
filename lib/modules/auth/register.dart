import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../widgets/custom_textfield.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/loading_overlay.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  bool _estaCargando = false;
  String? selectedGender;
  DateTime? _birthDate;

  // Controladores
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController(); // <- Nuevo
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.year,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFE26112),
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _birthDate) {
      setState(() {
        _birthDate = picked;
      });
    }
  }

  Future<void> _procesarRegistro() async {
    final nombre = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final phone = _phoneController.text.trim();

    if (nombre.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nombre, correo y contraseña son obligatorios'), backgroundColor: Colors.red)
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La contraseña debe tener al menos 6 caracteres'), backgroundColor: Colors.red)
      );
      return;
    }

    setState(() => _estaCargando = true);

    try {
      final response = await http.post(
        Uri.parse('http://192.168.0.38:8000/api/register'), 
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: json.encode({
          'name': nombre,
          'email': email,
          'password': password,
          'gender': selectedGender
        }),
      );

      final data = json.decode(response.body);
      setState(() => _estaCargando = false);

      if (response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message']), backgroundColor: Colors.green)
          );
          Navigator.pushNamed(context, '/documents'); 
        }
      } else {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Error al registrar'), backgroundColor: Colors.red)
        );
      }
    } catch (e) {
      setState(() => _estaCargando = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de conexión: $e'), backgroundColor: Colors.red)
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String dateHint = _birthDate == null
        ? "Selecciona tu fecha de nacimiento"
        : "${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}";

    return LoadingOverlay(
      isLoading: _estaCargando,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F6F8),
        body: SafeArea(
          child: Column(
            children: [
              LinearProgressIndicator(
                value: 0.0,
                backgroundColor: Colors.grey.shade200,
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFE26112)),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
                  child: Column(
                    children: [
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
                            
                            CustomTextField(hint: "Ingresa tu nombre completo", icon: Icons.person, controller: _nameController),
                            const SizedBox(height: 16),
                            CustomTextField(hint: "Ingresa tu correo electrónico", icon: Icons.email_outlined, controller: _emailController),
                            const SizedBox(height: 16),
                            
                            // <- AQUÍ ESTÁ EL CAMPO DE CONTRASEÑA NUEVO
                            CustomTextField(hint: "Crea tu contraseña", icon: Icons.lock_outline, obscure: true, controller: _passwordController),
                            const SizedBox(height: 16),
                            
                            CustomTextField(hint: "Ingresa tu número de teléfono", icon: Icons.phone, controller: _phoneController),
                            const SizedBox(height: 16),
                            InkWell(
                              onTap: () => _selectDate(context),
                              child: IgnorePointer(
                                child: CustomTextField(hint: dateHint, icon: Icons.calendar_today),
                              ),
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(hint: "Ingresa tu dirección", icon: Icons.location_on, controller: _addressController),
                            const SizedBox(height: 16),
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
                            CustomTextField(hint: "Cuéntanos sobre tu experiencia laboral", icon: Icons.work, controller: _experienceController),
                            const SizedBox(height: 28),
                            
                            CustomButton(
                              text: "CONTINUAR A DOCUMENTACIÓN",
                              onTap: _procesarRegistro, 
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}