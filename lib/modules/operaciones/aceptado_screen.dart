import 'package:flutter/material.dart';
import 'mapa_servicio_screen.dart';
import 'chat_screen.dart';

class AceptadoScreen extends StatelessWidget {
  final Map<String, dynamic> trabajo;
  final double miRating;

  const AceptadoScreen({
    super.key,
    required this.trabajo,
    required this.miRating,
  });

  @override
  Widget build(BuildContext context) {
    final String idServicio = (trabajo['_id'] ?? trabajo['id'] ?? '').toString();
    final String nombreCliente = trabajo['cliente'] ?? trabajo['nombre'] ?? 'Cliente';
    final String categoriaTitulo = trabajo['titulo'] ?? trabajo['categoria'] ?? 'General';
    final String direccionServicio = trabajo['direccion'] ?? 'Dirección no especificada';
    final String precioServicio = trabajo['precio'] ?? '\$350.00 MXN';

    // Fallback de color dinámico para evitar llamadas nulas
    Color colorCategoria;
    switch (categoriaTitulo.toLowerCase()) {
      case 'plomería': case 'plomeria': colorCategoria = Colors.blue; break;
      case 'jardinería': case 'jardineria': colorCategoria = Colors.green; break;
      case 'electricidad': colorCategoria = Colors.amber.shade700; break;
      default: colorCategoria = Colors.purple;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.green.shade50, shape: BoxShape.circle),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.green.shade100, shape: BoxShape.circle),
                  child: Icon(Icons.check, color: Colors.green.shade600, size: 60),
                ),
              ),
              const SizedBox(height: 32),
              const Text('¡TRABAJO ASIGNADO!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              const SizedBox(height: 12),
              Text(
                'Tu alta calificación de $miRating ★ te otorgó prioridad absoluta sobre la orden de $nombreCliente.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, color: Colors.grey, height: 1.5),
              ),
              const SizedBox(height: 30),
              
              // BOTÓN DE CHAT INTEGRADO
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  side: const BorderSide(color: Color(0xFFE26112)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        servicioId: idServicio,
                        nombreCliente: nombreCliente,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.chat_bubble_outline, color: Color(0xFFE26112)),
                label: const Text('ABRIR CHAT CON EL CLIENTE', style: TextStyle(color: Color(0xFFE26112), fontWeight: FontWeight.bold)),
              ),
              
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 5))],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.work_outline, color: colorCategoria, size: 20),
                            const SizedBox(width: 8),
                            Text(categoriaTitulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                        Text(precioServicio, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16)),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Divider(height: 1),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_on_outlined, size: 18, color: Colors.grey),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            direccionServicio,
                            style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.4),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE26112),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MapaServicioScreen(trabajo: trabajo),
                      ),
                    );
                  },
                  icon: const Icon(Icons.directions_car, color: Colors.white, size: 20),
                  label: const Text('INICIAR RUTA AL EMPLEO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}