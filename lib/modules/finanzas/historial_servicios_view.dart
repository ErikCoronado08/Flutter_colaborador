import 'package:flutter/material.dart';

class HistorialServiciosView extends StatefulWidget {
  const HistorialServiciosView({super.key});

  @override
  State<HistorialServiciosView> createState() => _HistorialServiciosViewState();
}

class _HistorialServiciosViewState extends State<HistorialServiciosView> {
  final List<Map<String, dynamic>> _todosLosServicios = [
    {'cliente': 'María González López', 'folio': '20033', 'fecha': '12 May • 14:30', 'monto': '\$320.00', 'rating': 5, 'estado': 'Completado'},
    {'cliente': 'Juan Carlos Pérez', 'folio': '20034', 'fecha': '14 May • 10:15', 'monto': '\$150.00', 'rating': 4, 'estado': 'Completado'},
    {'cliente': 'Roberto Gómez', 'folio': '20035', 'fecha': '15 May • 09:00', 'monto': '\$850.00', 'rating': 0, 'estado': 'Cancelado'},
    {'cliente': 'Ana Sofía Martínez', 'folio': '20036', 'fecha': '18 May • 16:45', 'monto': '\$420.00', 'rating': 5, 'estado': 'Completado'},
    {'cliente': 'Luis Hernández', 'folio': '20037', 'fecha': '20 May • 11:20', 'monto': '\$600.00', 'rating': 0, 'estado': 'En proceso'},
  ];

  List<Map<String, dynamic>> _serviciosFiltrados = [];

  @override
  void initState() {
    super.initState();
    _serviciosFiltrados = List.from(_todosLosServicios);
  }

  void _filtrarServicios(String query) {
    setState(() {
      _serviciosFiltrados = _todosLosServicios.where((s) => 
        s['cliente'].toLowerCase().contains(query.toLowerCase()) || 
        s['folio'].contains(query)
      ).toList();
    });
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            _buildSearchBar(),
            const SizedBox(height: 16),
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

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
      child: TextField(
        onChanged: _filtrarServicios,
        decoration: const InputDecoration(
          hintText: 'Buscar cliente o folio...',
          prefixIcon: Icon(Icons.search, color: Color(0xFFE26112)),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> item) {
    // 👆 RECUPERAMOS LA NAVEGACIÓN A LIQUIDACIÓN
    return InkWell(
      onTap: () => Navigator.pushNamed(context, '/liquidacion'),
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
                  Text('Folio: ${item['folio']} • ${item['fecha']}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(item['monto'], style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFE26112))),
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