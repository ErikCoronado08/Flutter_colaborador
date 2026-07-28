import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/finanzas_service.dart';

class HistorialServiciosView extends StatefulWidget {
  const HistorialServiciosView({super.key});

  @override
  State<HistorialServiciosView> createState() => _HistorialServiciosViewState();
}

class _HistorialServiciosViewState extends State<HistorialServiciosView> {
  final FinanzasService _service = FinanzasService();
  List<dynamic> _servicios = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    try {
      final datos = await _service.obtenerHistorial();
      setState(() {
        _servicios = datos;
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
        title: const Text('Historial Operativo', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.black87, size: 20), onPressed: () => Navigator.pop(context)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFE26112)))
          : _servicios.isEmpty
              ? const Center(child: Text("No tienes servicios completados aún.", style: TextStyle(color: Colors.grey)))
              : RefreshIndicator(
                  color: const Color(0xFFE26112),
                  onRefresh: _cargarDatos,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _servicios.length,
                    itemBuilder: (context, index) => _buildServiceCard(_servicios[index]),
                  ),
                ),
    );
  }

  Widget _buildServiceCard(dynamic item) {
    final formatoMoneda = NumberFormat.currency(locale: 'es_MX', symbol: '\$');
    final montoFormateado = formatoMoneda.format(double.parse(item['monto'].toString()));
    final folioExacto = item['folio'].toString(); 

    return InkWell(
      // Pasamos el parámetro como un Map
      onTap: () => Navigator.pushNamed(context, '/liquidacion', arguments: {'folio': folioExacto}),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14), 
              decoration: BoxDecoration(color: const Color(0xFFE26112).withOpacity(0.1), borderRadius: BorderRadius.circular(16)), 
              child: const Icon(Icons.receipt_long, color: Color(0xFFE26112), size: 28)
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['cliente'] ?? 'Cliente', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(item['servicio'] ?? 'Servicio', style: const TextStyle(fontSize: 13, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(6)),
                    child: Text('Folio: $folioExacto', style: TextStyle(fontSize: 10, color: Colors.grey.shade700, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(montoFormateado, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16)),
                const SizedBox(height: 6),
                Text(item['fecha'] ?? '', style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}