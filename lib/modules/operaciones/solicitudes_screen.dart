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

  // NUEVO FLUJO: Ver Detalles antes de aceptar
  void _mostrarDetallesYAgendar(BuildContext context, Map<String, dynamic> solicitud) {
    DateTime fechaSeleccionada = DateTime.now().add(const Duration(days: 1));
    TimeOfDay horaSeleccionada = const TimeOfDay(hour: 10, minute: 0);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                top: 24, left: 24, right: 24
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Detalles de la Solicitud', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Cliente: ${solicitud['cliente']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 8),
                        Text('Servicio Requerido: ${solicitud['servicio']}', style: TextStyle(color: Colors.grey.shade700)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  const Text('Propuesta de Agenda', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  
                  // Selector de Fecha
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.calendar_today, color: Color(0xFFE26112)),
                    title: const Text('Fecha asignada'),
                    subtitle: Text('${fechaSeleccionada.day}/${fechaSeleccionada.month}/${fechaSeleccionada.year}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    trailing: TextButton(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context, initialDate: fechaSeleccionada, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 60)),
                          builder: (context, child) => Theme(data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: Color(0xFFE26112))), child: child!),
                        );
                        if (date != null) setStateModal(() => fechaSeleccionada = date);
                      },
                      child: const Text('CAMBIAR', style: TextStyle(color: Color(0xFFE26112))),
                    ),
                  ),
                  
                  // Selector de Hora
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.access_time, color: Color(0xFFE26112)),
                    title: const Text('Hora asignada'),
                    subtitle: Text(horaSeleccionada.format(context), style: const TextStyle(fontWeight: FontWeight.bold)),
                    trailing: TextButton(
                      onPressed: () async {
                        final time = await showTimePicker(
                          context: context, initialTime: horaSeleccionada,
                          builder: (context, child) => Theme(data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: Color(0xFFE26112))), child: child!),
                        );
                        if (time != null) setStateModal(() => horaSeleccionada = time);
                      },
                      child: const Text('CAMBIAR', style: TextStyle(color: Color(0xFFE26112))),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                          child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _procesarAceptacion(solicitud, fechaSeleccionada, horaSeleccionada);
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE26112), elevation: 0, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                          child: const Text('Enviar Propuesta y Agendar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }
        );
      }
    );
  }

  Future<void> _procesarAceptacion(Map<String, dynamic> solicitud, DateTime fecha, TimeOfDay hora) async {
    showDialog(context: context, barrierDismissible: false, builder: (context) => const Center(child: CircularProgressIndicator(color: Color(0xFFE26112))));

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
        Navigator.push(context, MaterialPageRoute(builder: (context) => AceptadoScreen(trabajo: solicitud, miRating: 5.0)))
            .then((_) => _cargarSolicitudesDesdeAPI());
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Hubo un error al agendar la solicitud. Intenta de nuevo.'), backgroundColor: Colors.red));
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
        actions: [IconButton(icon: const Icon(Icons.refresh, color: Color(0xFFE26112)), onPressed: _cargarSolicitudesDesdeAPI)],
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
                      final cliente = solicitud['cliente'] ?? 'Cliente Nuevo';
                      final servicio = solicitud['servicio'] ?? 'Servicio Solicitado';
                      final fechaSolicitud = solicitud['fecha_solicitud'] ?? '';
                      final iniciales = cliente.substring(0, 1).toUpperCase();

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade200), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))]),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(backgroundColor: const Color(0xFFE26112).withOpacity(0.1), child: Text(iniciales, style: const TextStyle(color: Color(0xFFE26112), fontWeight: FontWeight.bold))),
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
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(servicio, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF444444))),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE26112), elevation: 0, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                                onPressed: () => _mostrarDetallesYAgendar(context, solicitud),
                                child: const Text('VER DETALLES', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
            Text('Por el momento no tienes clientes esperando. Te notificaremos cuando alguien requiera tus servicios.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade600, fontSize: 14, height: 1.5)),
          ],
        ),
      ),
    );
  }
}