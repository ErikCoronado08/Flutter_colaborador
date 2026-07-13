import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../operaciones/service_detail_screen.dart';
import '../../services/api_service.dart'; // Importa el ApiService

class AgendaScreen extends StatefulWidget {
  final bool standalone;

  const AgendaScreen({super.key, this.standalone = true});

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  // Ajustado a las fechas actuales de desarrollo en 2026
  DateTime selectedDate = DateTime(2026, 7, 6);
  DateTime focusedDay = DateTime(2026, 7, 6);
  
  // Variables de control de estado del Backend
  List<dynamic> appointments = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    _fetchAgendaBackend(); // Carga inicial
  }

  // Método para obtener la agenda desde MongoDB
  Future<void> _fetchAgendaBackend() async {
    setState(() => cargando = true);
    final datosAgenda = await ApiService.obtenerAgenda();
    setState(() {
      if (datosAgenda != null) {
        appointments = datosAgenda;
      }
      cargando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final body = SafeArea(
      child: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _fetchAgendaBackend, // Deslizar para recargar
            color: const Color(0xFFE26112),
            child: cargando
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFE26112)))
                : SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 80),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 24),
                        _buildCalendarCard(),
                        const SizedBox(height: 32),
                        _buildDaySummary(),
                        const SizedBox(height: 16),
                        if (appointments.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 40),
                            child: Center(child: Text('No hay servicios en la agenda', style: TextStyle(color: Colors.grey))),
                          )
                        else
                          ...appointments.map((app) => _buildAppointmentCard(app as Map<String, dynamic>)).toList(),
                      ],
                    ),
                  ),
          ),
          
          // Botón Flotante de Agregar Cita
          Positioned(
            bottom: 20,
            right: 16,
            child: FloatingActionButton(
              onPressed: _showAddAppointmentDialog,
              backgroundColor: const Color(0xFFE26112),
              elevation: 4,
              child: const Icon(Icons.add, color: Colors.white, size: 28),
            ),
          )
        ],
      ),
    );

    return widget.standalone
        ? Scaffold(
            backgroundColor: const Color(0xFFF8F9FA),
            appBar: AppBar(
              title: const Text('Agenda', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16)),
              backgroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
              iconTheme: const IconThemeData(color: Colors.black87),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: body,
          )
        : Scaffold(backgroundColor: const Color(0xFFF8F9FA), body: body);
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mi Calendario',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 4),
        Text(
          'Revisa y organiza tus servicios',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildCalendarCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          TableCalendar(
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
            },
            onPageChanged: (focusedDayValue) {
              setState(() {
                focusedDay = focusedDayValue;
              });
            },
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
            ),
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(color: const Color(0xFFE26112).withValues(alpha: 0.2), shape: BoxShape.circle),
              selectedDecoration: const BoxDecoration(color: Color(0xFFE26112), shape: BoxShape.circle),
              selectedTextStyle: const TextStyle(color: Colors.white),
              todayTextStyle: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
              outsideDaysVisible: false,
            ),
            daysOfWeekHeight: 32,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('EEEE, d MMMM', 'es_MX').format(selectedDate),
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87),
              ),
              Text(
                '${appointments.length} servicios',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDaySummary() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '${selectedDate.day} de ${_monthName(selectedDate.month)}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(12)),
          child: Text(
            '${appointments.length} servicios',
            style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildAppointmentCard(Map<String, dynamic> appointment) {
    // Mapeo flexible para soportar tanto llaves mock anteriores como las de MongoDB
    final String cliente = appointment['name'] ?? appointment['cliente'] ?? 'Cliente';
    final String servicio = appointment['service'] ?? appointment['tipo'] ?? 'Servicio';
    final String horario = appointment['time'] ?? appointment['hora'] ?? 'Por definir';
    final String ubicacion = appointment['location'] ?? appointment['distancia'] ?? 'Ubicación remota';
    final String estado = appointment['status'] ?? appointment['estado'] ?? 'Pendiente';

    final bool confirmed = estado.toLowerCase() == 'confirmado';
    final Color statusColor = confirmed ? Colors.green : Colors.orange;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ServiceDetailScreen(
              clientName: cliente,
              serviceType: servicio,
              time: horario,
              distance: ubicacion,
              status: estado,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cliente,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        servicio,
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    estado,
                    style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildInfoChip(Icons.schedule, horario),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildInfoChip(Icons.location_on_outlined, ubicacion),
                ),
              ],
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade600),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddAppointmentDialog() {
    final nameController = TextEditingController();
    final serviceController = TextEditingController();
    final timeController = TextEditingController();
    final locationController = TextEditingController();
    String status = 'Pendiente';

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Agregar Cita', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nombre del Cliente')),
                const SizedBox(height: 8),
                TextField(controller: serviceController, decoration: const InputDecoration(labelText: 'Tipo de Servicio')),
                const SizedBox(height: 8),
                TextField(controller: timeController, decoration: const InputDecoration(labelText: 'Horario (Ej. 10:00 - 12:00)')),
                const SizedBox(height: 8),
                TextField(controller: locationController, decoration: const InputDecoration(labelText: 'Ubicación (Colonia)')),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: status,
                  decoration: InputDecoration(
                    labelText: 'Estado',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Pendiente', child: Text('Pendiente')),
                    DropdownMenuItem(value: 'Confirmado', child: Text('Confirmado')),
                  ],
                  onChanged: (value) {
                    if (value != null) status = value;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE26112),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                final name = nameController.text.trim();
                final service = serviceController.text.trim();
                final time = timeController.text.trim();
                final location = locationController.text.trim();

                if (name.isEmpty || service.isEmpty || time.isEmpty || location.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor completa todos los campos.')));
                  return;
                }

                setState(() {
                  appointments.add({
                    'name': name,
                    'service': service,
                    'time': time,
                    'location': location,
                    'status': status,
                  });
                });
                Navigator.pop(context);
              },
              child: const Text('Guardar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  String _monthName(int month) {
    const names = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
    ];
    return names[month - 1];
  }
}