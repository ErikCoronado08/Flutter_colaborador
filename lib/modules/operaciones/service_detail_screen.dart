import 'package:flutter/material.dart';

class ServiceDetailScreen extends StatelessWidget {
  final String clientName;
  final String serviceType;
  final String time;
  final String distance;
  final String status;

  const ServiceDetailScreen({
    super.key,
    required this.clientName,
    required this.serviceType,
    required this.time,
    required this.distance,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text('Detalle del servicio', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tarjeta principal de detalles
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(clientName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 6),
                  Text(serviceType, style: const TextStyle(color: Color(0xFFE26112), fontWeight: FontWeight.w600)),
                  const SizedBox(height: 20),
                  
                  // Fila de información rápida con estilo Chip
                  Row(
                    children: [
                      _buildInfoChip(Icons.schedule, time),
                      const SizedBox(width: 12),
                      _buildInfoChip(Icons.location_on_outlined, distance),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Estado con estilo badge
                  Row(
                    children: [
                      const Text('Estado: ', style: TextStyle(color: Colors.grey, fontSize: 14)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: status == 'Confirmado' ? Colors.green.shade50 : Colors.orange.shade50, borderRadius: BorderRadius.circular(8)),
                        child: Text(status, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: status == 'Confirmado' ? Colors.green.shade700 : Colors.orange.shade800)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            const Text('Notas del servicio', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
              child: const Text(
                'Revisa la instalación y confirma la seguridad eléctrica. Lleva contigo las herramientas básicas y verifica el equipo antes de empezar.',
                style: TextStyle(color: Colors.black54, height: 1.5),
              ),
            ),
            
            const Spacer(),
            
            // Botón de acción principal
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Servicio marcado como completado')),
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE26112),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('MARCAR COMO COMPLETADO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade600),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}