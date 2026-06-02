import 'package:flutter/material.dart';

class HistorialTransitoView extends StatelessWidget {
  const HistorialTransitoView({super.key});

  @override
  Widget build(BuildContext context) {
    // Simulamos transacciones en proceso
    final List<Map<String, dynamic>> transitos = [
      {'servicio': 'Plomería - Jorge Torres', 'monto': '\$450.00', 'fecha': '28 May 2026', 'libera': '29 May, 14:32'},
      {'servicio': 'Electricidad - Mariana Ríos', 'monto': '\$800.00', 'fecha': '24 May 2026', 'libera': '25 May, 09:15'},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF4D2214)),
        title: const Text(
          'Dinero en Tránsito',
          style: TextStyle(color: Color(0xFF4D2214), fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Panel de información de seguridad
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.orange.shade100),
              ),
              child: Row(
                children: [
                  Icon(Icons.shield_outlined, color: Colors.orange.shade800),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Tus fondos se liberan 24 horas después de que el cliente confirme el servicio.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF4D2214)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Movimientos pendientes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            
            ...transitos.map((item) => _buildTransitoCard(item)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTransitoCard(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(item['servicio'], style: const TextStyle(fontWeight: FontWeight.bold))),
              Text(item['monto'], style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFE26112))),
            ],
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Fecha: ${item['fecha']}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
              Text('Se libera: ${item['libera']}', style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}