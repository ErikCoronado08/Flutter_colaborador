import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const CustomButton({
    super.key,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed: onTap,

        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: const Color(0xFFC86428),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),

          padding: const EdgeInsets.symmetric(
            vertical: 16,
          ),
        ),

        child: Text(
          text,

          textAlign: TextAlign.center,

          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: .5,
          ),
        ),
      ),
    );
  }
}