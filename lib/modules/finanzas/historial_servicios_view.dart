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
  List<dynamic> _serviciosFiltrados = [];
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
        _serviciosFiltrados = datos;
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
        title: const Text('Historial', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.black87), onPressed: () => Navigator.pop(context)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFE26112)))
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _serviciosFiltrados.length,
                      itemBuilder: (context, index) => _buildServiceCard(_serviciosFiltrados[index]),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildServiceCard(dynamic item) {
    final formatoMoneda = NumberFormat.currency(locale: 'es_MX', symbol: '\$');
    final montoFormateado = formatoMoneda.format(double.parse(item['monto'].toString()));

    return InkWell(
      // AQUÍ ENVIAMOS EL ID REAL A LA SIGUIENTE PANTALLA
      onTap: () => Navigator.pushNamed(context, '/liquidacion', arguments: item['id_real']),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.receipt_long, color: Color(0xFFE26112))),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['cliente'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text('Folio: ${item['folio']}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(montoFormateado, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFE26112))),
                const SizedBox(height: 4),
                Text(item['estado'], style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: item['estado'] == 'Completado' ? Colors.green : Colors.red)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}