import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String hint;
  final IconData icon;
  final bool obscure;
  // 1. Agregamos la variable para el controlador
  final TextEditingController? controller; 

  const CustomTextField({
    super.key,
    required this.hint,
    required this.icon,
    this.obscure = false,
    // 2. Lo pedimos en el constructor
    this.controller, 
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      // 3. Se lo asignamos al TextField nativo
      controller: controller, 
      obscureText: obscure,

      style: const TextStyle(
        color: Colors.black,
        fontSize: 15,
      ),

      cursorColor: const Color(0xFFC86428),

      decoration: InputDecoration(
        hintText: hint,

        hintStyle: const TextStyle(
          color: Color(0xFF888888),
          fontSize: 14,
        ),

        prefixIcon: Icon(
          icon,
          color: const Color(0xFFC86428),
        ),

        filled: true,
        fillColor: Colors.white,

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFFE0E0E0),
            width: 1.2,
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFFC86428),
            width: 2,
          ),
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFFE0E0E0),
          ),
        ),
      ),
    );
  }
}