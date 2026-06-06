import 'package:flutter/material.dart';
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
                value: 0.0, // Barra vacía al iniciar
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
                            const CustomTextField(hint: "Ingresa tu nombre completo", icon: Icons.person),
                            const SizedBox(height: 16),
                            const CustomTextField(hint: "Ingresa tu correo electrónico", icon: Icons.email_outlined),
                            const SizedBox(height: 16),
                            const CustomTextField(hint: "Ingresa tu número de teléfono", icon: Icons.phone),
                            const SizedBox(height: 16),
                            InkWell(
                              onTap: () => _selectDate(context),
                              child: IgnorePointer(
                                child: CustomTextField(hint: dateHint, icon: Icons.calendar_today),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const CustomTextField(hint: "Ingresa tu dirección", icon: Icons.location_on),
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
                            const CustomTextField(hint: "Cuéntanos sobre tu experiencia laboral", icon: Icons.work),
                            const SizedBox(height: 28),
                            CustomButton(
                              text: "CONTINUAR A DOCUMENTACIÓN",
                              onTap: () async {
                                setState(() => _estaCargando = true);
                                await Future.delayed(const Duration(seconds: 2));
                                setState(() => _estaCargando = false);
                                if (mounted) Navigator.pushNamed(context, '/documents');
                              },
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