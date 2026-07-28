import 'package:flutter/material.dart';
import '../../services/api_service.dart'; 
import 'aceptado_screen.dart'; 

class SolicitudesScreen extends StatefulWidget {
  const SolicitudesScreen({super.key});

  @override
  State<SolicitudesScreen> createState() => _SolicitudesScreenState();
}

class _SolicitudesScreenState extends State<SolicitudesScreen> {
  List<dynamic> _solicitudes = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarSolicitudesDesdeAPI();
  }

  Future<void> _cargarSolicitudesDesdeAPI() async {
    setState(() => _cargando = true);
    final datos = await ApiService.obtenerSolicitudes();
    setState(() {
      _solicitudes = datos;
      _cargando = false;
    });
  }

  // Abre un selector de fecha y hora para agendar el servicio antes de aceptarlo
  Future<void> _mostrarDialogoAgendar(BuildContext context, Map<String, dynamic> solicitud) async {
    final DateTime? fechaSeleccionada = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
      builder: (context, child) => Theme(data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: Color(0xFFE26112))), child: child!),
    );

    if (fechaSeleccionada == null) return;

    if (!context.mounted) return;
    
    final TimeOfDay? horaSeleccionada = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 10, minute: 0),
      builder: (context, child) => Theme(data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: Color(0xFFE26112))), child: child!),
    );

    if (horaSeleccionada == null) return;

    _procesarAceptacion(solicitud, fechaSeleccionada, horaSeleccionada);
  }

  Future<void> _procesarAceptacion(Map<String, dynamic> solicitud, DateTime fecha, TimeOfDay hora) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: Color(0xFFE26112))),
    );

    // Formateamos para que Laravel lo reciba correctamente
    final String fechaFormateada = "${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}";
    final String horaFormateada = "${hora.hour.toString().padLeft(2, '0')}:${hora.minute.toString().padLeft(2, '0')}:00";

    final payload = {
      'solicitud_servicio_id': solicitud['id'],
      'cliente_id': solicitud['cliente_id'],
      'servicio_socio_id': solicitud['servicio_socio_id'],
      'fecha': fechaFormateada,
      'hora': horaFormateada,
    };

    bool guardadoExitoso = await ApiService.agendarSolicitud(payload);

    if (mounted) {
      Navigator.pop(context); // Quitar loader

      if (guardadoExitoso) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AceptadoScreen(trabajo: solicitud, miRating: 5.0),
          ),
        ).then((_) => _cargarSolicitudesDesdeAPI());
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hubo un error al agendar la solicitud. Intenta de nuevo.'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Solicitudes de Clientes', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          IconButton(icon: const Icon(Icons.refresh, color: Color(0xFFE26112)), onPressed: _cargarSolicitudesDesdeAPI)
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFE26112)))
          : _solicitudes.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _cargarSolicitudesDesdeAPI,
                  color: const Color(0xFFE26112),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _solicitudes.length,
                    itemBuilder: (context, index) {
                      final solicitud = _solicitudes[index] as Map<String, dynamic>;
                      
                      // Extraemos los datos provenientes de AgendaColaboradorController@index
                      final cliente = solicitud['cliente'] ?? 'Cliente Nuevo';
                      final servicio = solicitud['servicio'] ?? 'Servicio Solicitado';
                      final fechaSolicitud = solicitud['fecha_solicitud'] ?? '';
                      final iniciales = cliente.substring(0, 1).toUpperCase();

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey.shade200),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: const Color(0xFFE26112).withOpacity(0.1),
                                  child: Text(iniciales, style: const TextStyle(color: Color(0xFFE26112), fontWeight: FontWeight.bold)),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(cliente, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                                      Text(fechaSolicitud, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
                                  child: const Text('Nueva', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 11)),
                                )
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(servicio, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF444444))),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFE26112),
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                onPressed: () => _mostrarDialogoAgendar(context, solicitud),
                                child: const Text('ACEPTAR Y AGENDAR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text('Sin solicitudes nuevas', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 8),
            Text(
              'Por el momento no tienes clientes esperando. Te notificaremos cuando alguien requiera tus servicios.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}