import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/finanzas_service.dart';

class HistorialTransitoView extends StatefulWidget {
  const HistorialTransitoView({super.key});

  @override
  State<HistorialTransitoView> createState() => _HistorialTransitoViewState();
}

class _HistorialTransitoViewState extends State<HistorialTransitoView> {
  final FinanzasService _service = FinanzasService();
  List<dynamic> _transitos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    try {
      final datos = await _service.obtenerTransitos();
      setState(() {
        _transitos = datos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF4D2214)),
        title: const Text('Dinero en Tránsito', style: TextStyle(color: Color(0xFF4D2214), fontWeight: FontWeight.bold, fontSize: 16)),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFFE26112)))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.orange.shade100)),
                  child: Row(
                    children: [
                      Icon(Icons.shield_outlined, color: Colors.orange.shade800),
                      const SizedBox(width: 12),
                      const Expanded(child: Text('Tus fondos se liberan 24 horas después de que el cliente confirme.', style: TextStyle(fontSize: 12, color: Color(0xFF4D2214)))),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Movimientos pendientes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 16),
                ..._transitos.map((item) => _buildTransitoCard(item)).toList(),
              ],
            ),
          ),
    );
  }

  Widget _buildTransitoCard(dynamic item) {
    final formatoMoneda = NumberFormat.currency(locale: 'es_MX', symbol: '\$');
    final formatoHora = DateFormat('dd MMM, HH:mm', 'es');
    
    final montoFormateado = formatoMoneda.format(double.parse(item['monto'].toString()));
    final fechaLibera = formatoHora.format(DateTime.parse(item['fecha_liberacion']));

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
              Text(montoFormateado, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFE26112))),
            ],
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Estado: Retenido', style: TextStyle(color: Colors.grey, fontSize: 12)),
              Text('Se libera: $fechaLibera', style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}