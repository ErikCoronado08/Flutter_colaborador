import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;

  const LoadingOverlay({
    super.key, 
    required this.isLoading, 
    required this.child
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child, // Aquí se dibuja tu pantalla normal
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.4), // Fondo oscuro semitransparente
            child: Center(
              // Aquí cargamos la animación que registramos en el Punto 1
              child: Lottie.asset('assets/animations/loading.json', width: 150),
            ),
          ),
      ],
    );
  }
}