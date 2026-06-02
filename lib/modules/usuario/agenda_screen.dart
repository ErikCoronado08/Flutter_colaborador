import 'package:flutter/material.dart';
import 'service_detail_screen.dart';

class AgendaScreen extends StatefulWidget {
  final bool standalone;

  const AgendaScreen({super.key, this.standalone = true});

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  DateTime selectedDate = DateTime(2026, 5, 19);

  final List<Map<String, String>> appointments = [
    {
      'name': 'María García',
      'service': 'Limpieza general',
      'time': '09:00 - 11:00',
      'location': 'Col. Roma Norte',
      'status': 'Confirmado',
    },
    {
      'name': 'Carlos López',
      'service': 'Plomería',
      'time': '14:00 - 16:00',
      'location': 'Col. Condesa',
      'status': 'Pendiente',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final body = SafeArea(
      child: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 80), // Espacio para el botón flotante
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildCalendarCard(),
                const SizedBox(height: 32),
                _buildDaySummary(),
                const SizedBox(height: 16),
                ...appointments.map(_buildAppointmentCard).toList(),
              ],
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
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Revisa y organiza tus servicios',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarCard() {
    final DateTime monthDate = DateTime(selectedDate.year, selectedDate.month);
    final int daysInMonth = DateTime(monthDate.year, monthDate.month + 1, 0).day;
    final int firstWeekday = DateTime(monthDate.year, monthDate.month, 1).weekday;
    final List<Widget> dayWidgets = [];

    for (int i = 1; i < firstWeekday; i++) {
      dayWidgets.add(const SizedBox());
    }

    for (int day = 1; day <= daysInMonth; day++) {
      final DateTime date = DateTime(monthDate.year, monthDate.month, day);
      final bool isSelected = selectedDate.day == day;
      dayWidgets.add(_buildDayTile(day, isSelected, date));
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _calendarNavButton(Icons.arrow_back_ios_new, () {
                setState(() {
                  selectedDate = _moveMonth(-1);
                });
              }),
              Text(
                _formatMonthYear(monthDate),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
              ),
              _calendarNavButton(Icons.arrow_forward_ios, () {
                setState(() {
                  selectedDate = _moveMonth(1);
                });
              }),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              Text('Lun', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
              Text('Mar', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
              Text('Mié', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
              Text('Jue', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
              Text('Vie', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
              Text('Sáb', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
              Text('Dom', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 7,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: dayWidgets,
          ),
        ],
      ),
    );
  }

  Widget _calendarNavButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.black87, size: 16),
      ),
    );
  }

  Widget _buildDayTile(int day, bool selected, DateTime date) {
    return GestureDetector(
      onTap: () => setState(() {
        selectedDate = date;
      }),
      child: Container(
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE26112) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          '$day',
          style: TextStyle(
            color: selected ? Colors.white : Colors.black87,
            fontWeight: selected ? FontWeight.bold : FontWeight.w500,
            fontSize: 15,
          ),
        ),
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

  Widget _buildAppointmentCard(Map<String, String> appointment) {
    final bool confirmed = appointment['status'] == 'Confirmado';
    final Color statusColor = confirmed ? Colors.green : Colors.orange;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ServiceDetailScreen(
              clientName: appointment['name'] ?? '',
              serviceType: appointment['service'] ?? '',
              time: appointment['time'] ?? '',
              distance: appointment['location'] ?? '',
              status: appointment['status'] ?? '',
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
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
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
                        appointment['name'] ?? '',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        appointment['service'] ?? '',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    appointment['status'] ?? '',
                    style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildInfoChip(Icons.schedule, appointment['time'] ?? ''),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildInfoChip(Icons.location_on_outlined, appointment['location'] ?? ''),
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

  String _formatMonthYear(DateTime date) {
    return '${_monthName(date.month)} ${date.year}';
  }

  DateTime _moveMonth(int delta) {
    final int newMonth = selectedDate.month + delta;
    final int yearAdjustment = (newMonth <= 0 ? -1 : (newMonth > 12 ? 1 : 0));
    final int normalizedMonth = ((newMonth - 1) % 12 + 12) % 12 + 1;
    final int newYear = selectedDate.year + yearAdjustment;
    final int lastDayOfMonth = DateTime(newYear, normalizedMonth + 1, 0).day;
    final int newDay = selectedDate.day.clamp(1, lastDayOfMonth);
    return DateTime(newYear, normalizedMonth, newDay);
  }

  String _monthName(int month) {
    const names = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
    ];
    return names[month - 1];
  }
}