import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../services/api_service.dart'; 
import '../operaciones/service_detail_screen.dart';
import '../operaciones/chat_screen.dart';

class AgendaScreen extends StatefulWidget {
  final bool standalone;
  const AgendaScreen({super.key, this.standalone = true});

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  DateTime selectedDate = DateTime.now();
  DateTime focusedDay = DateTime.now();
  
  List<dynamic> allAppointments = [];
  List<dynamic> filteredAppointments = [];
  List<dynamic> solicitudesPendientes = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    _fetchAgendaBackend(); 
  }

  Future<void> _fetchAgendaBackend() async {
    setState(() => cargando = true);
    final datosAgenda = await ApiService.obtenerAgendaCompleta();
    
    setState(() {
      if (datosAgenda != null) {
        allAppointments = datosAgenda['agendas'] ?? [];
        solicitudesPendientes = datosAgenda['solicitudes'] ?? [];
        _filtrarPorDia(selectedDate);
      }
      cargando = false;
    });
  }

  void _filtrarPorDia(DateTime dia) {
    final fechaStr = "${dia.year}-${dia.month.toString().padLeft(2, '0')}-${dia.day.toString().padLeft(2, '0')}";
    setState(() {
      filteredAppointments = allAppointments.where((app) => app['fecha'] == fechaStr).toList();
    });
  }

  // --- BANDEJA DE SOLICITUDES DE CLIENTES ---
  void _mostrarBandejaSolicitudes() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Solicitudes de Clientes', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              if (solicitudesPendientes.isEmpty)
                const Center(child: Text('No tienes solicitudes nuevas por el momento.', style: TextStyle(color: Colors.grey))),
              ...solicitudesPendientes.map((sol) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
                  elevation: 0,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFFE26112).withOpacity(0.1),
                      child: const Icon(Icons.person, color: Color(0xFFE26112)),
                    ),
                    title: Text(sol['cliente'] ?? 'Cliente Nuevo', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(sol['servicio'] ?? 'Servicio', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.redAccent),
                          onPressed: () async {
                            Navigator.pop(context);
                            bool exito = await ApiService.rechazarSolicitud(sol['id'].toString());
                            if (exito) _fetchAgendaBackend();
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.check_circle, color: Colors.green, size: 30),
                          onPressed: () {
                            Navigator.pop(context);
                            _mostrarDialogoAgendarSolicitud(sol); // <-- Pasamos directamente a agendar la solicitud
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        );
      }
    );
  }

  // --- AGENDAR LA SOLICITUD (FLUJO PERFECTO) ---
  void _mostrarDialogoAgendarSolicitud(Map<String, dynamic> solicitud) async {
    TimeOfDay horaSeleccionada = const TimeOfDay(hour: 10, minute: 0);
    DateTime fechaElegida = selectedDate;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Agendar Servicio', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          content: StatefulBuilder(
            builder: (context, setStateModal) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Cliente: ${solicitud['cliente']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 4),
                  Text('Servicio: ${solicitud['servicio']}', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Fecha: ${fechaElegida.day}/${fechaElegida.month}/${fechaElegida.year}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      TextButton(
                        onPressed: () async {
                          final date = await showDatePicker(context: context, initialDate: fechaElegida, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
                          if (date != null) setStateModal(() => fechaElegida = date);
                        },
                        child: const Text('Elegir', style: TextStyle(color: Color(0xFFE26112))),
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Hora: ${horaSeleccionada.format(context)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      TextButton(
                        onPressed: () async {
                          final time = await showTimePicker(context: context, initialTime: horaSeleccionada);
                          if (time != null) setStateModal(() => horaSeleccionada = time);
                        },
                        child: const Text('Elegir', style: TextStyle(color: Color(0xFFE26112))),
                      )
                    ],
                  )
                ],
              );
            },
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar', style: TextStyle(color: Colors.grey))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE26112)),
              onPressed: () async {
                Navigator.pop(context); // Cierra el modal
                
                showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));

                // Formato exacto que espera Laravel
                final fechaStr = "${fechaElegida.year}-${fechaElegida.month.toString().padLeft(2, '0')}-${fechaElegida.day.toString().padLeft(2, '0')}";
                final horaStr = "${horaSeleccionada.hour.toString().padLeft(2, '0')}:${horaSeleccionada.minute.toString().padLeft(2, '0')}:00";

                // Armamos el payload tomando los datos reales de la solicitud
                final payload = {
                  'servicio_socio_id': solicitud['servicio_socio_id'].toString(),
                  'cliente_id': solicitud['cliente_id'],
                  'solicitud_servicio_id': solicitud['id'],
                  'fecha': fechaStr,
                  'hora': horaStr,
                };

                bool exito = await ApiService.agendarSolicitud(payload);
                if (mounted) Navigator.pop(context); // Quitar loader de progreso

                if (exito && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cita agendada correctamente'), backgroundColor: Colors.green));
                  _fetchAgendaBackend(); // Refresca el calendario
                  
                  // Llevamos al usuario directamente a la pantalla de CHAT como lo pediste
                  Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(
                    clienteId: solicitud['cliente_id'].toString(), 
                    nombreCliente: solicitud['cliente'] ?? 'Cliente'
                  )));
                } else if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al agendar la cita'), backgroundColor: Colors.red));
                }
              },
              child: const Text('Confirmar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: widget.standalone ? AppBar(title: const Text('Mi Agenda', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)), backgroundColor: Colors.white, elevation: 0) : null,
      
      // Botón flotante modificado: Ahora abre la bandeja de notificaciones
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _mostrarBandejaSolicitudes,
        backgroundColor: const Color(0xFFE26112),
        icon: const Icon(Icons.notifications_active, color: Colors.white),
        label: Text(
          'Solicitudes (${solicitudesPendientes.length})', 
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
        ),
      ),
      
      body: RefreshIndicator(
        onRefresh: _fetchAgendaBackend,
        color: const Color(0xFFE26112),
        child: cargando
            ? const Center(child: CircularProgressIndicator(color: Color(0xFFE26112)))
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
                    child: TableCalendar(
                      firstDay: DateTime.utc(2024, 1, 1),
                      lastDay: DateTime.utc(2030, 12, 31),
                      focusedDay: focusedDay,
                      selectedDayPredicate: (day) => isSameDay(selectedDate, day),
                      calendarFormat: CalendarFormat.month,
                      onDaySelected: (selectedDay, focusedDayValue) {
                        setState(() {
                          selectedDate = selectedDay;
                          focusedDay = focusedDayValue;
                        });
                        _filtrarPorDia(selectedDay);
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Citas del ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  if (filteredAppointments.isEmpty)
                    const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('No hay servicios agendados para esta fecha.', style: TextStyle(color: Colors.grey))))
                  else
                    ...filteredAppointments.map((app) => _buildAppointmentCard(app)).toList(),
                  const SizedBox(height: 60), // Espacio extra para que el botón flotante no tape
                ],
              ),
      ),
    );
  }

  Widget _buildAppointmentCard(dynamic appointment) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: () {
          // Al hacer clic abre la línea de tiempo
          Navigator.push(context, MaterialPageRoute(builder: (_) => ServiceDetailScreen(agendaData: appointment))).then((_) => _fetchAgendaBackend());
        },
        leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFFE26112).withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.schedule, color: Color(0xFFE26112))),
        title: Text(appointment['cliente'] ?? 'Cliente', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(appointment['servicio'] ?? 'Servicio', style: const TextStyle(fontSize: 12)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(appointment['hora'] ?? '00:00', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 4),
            Text((appointment['estado'] ?? 'Programada').toUpperCase(), style: const TextStyle(color: Color(0xFFE26112), fontSize: 9, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}