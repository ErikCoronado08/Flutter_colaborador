import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
// IMPORT ACTUALIZADO: Apuntando a la nueva carpeta de operaciones
import '../modules/operaciones/service_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool disponible = true;

  final List<Map<String, String>> upcomingServices = [
    {
      'initials': 'MG',
      'name': 'María García',
      'service': 'Limpieza general',
      'time': '10:00 AM',
      'distance': '2.5 km',
      'status': 'Confirmado',
    },
    {
      'initials': 'CL',
      'name': 'Carlos López',
      'service': 'Plomería',
      'time': '5:30 PM',
      'distance': '8.1 km',
      'status': 'Pendiente',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _buildDashboard(context),
      ),
    );
  }

  Widget _buildDashboard(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildHeaderCard(context),
        const SizedBox(height: 20),
        _buildEarningsCard(),
        const SizedBox(height: 18),
        _buildMetricRow(),
        const SizedBox(height: 24),
        _buildUpcomingHeader(context),
        const SizedBox(height: 12),
        ...upcomingServices.map((service) => _buildUpcomingServiceCard(service, context)),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.primary,
            child: Icon(Icons.person, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Bienvenido', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                SizedBox(height: 6),
                Text('¡Hola, Eduardo!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Text('Disponible', style: TextStyle(color: disponible ? AppColors.success : AppColors.textSecondary, fontWeight: FontWeight.w600)),
                  const SizedBox(width: 8),
                  Switch(
                    value: disponible,
                    activeColor: AppColors.surface,
                    activeTrackColor: AppColors.success,
                    inactiveTrackColor: const Color(0xFFD7D7DB),
                    onChanged: (value) => setState(() => disponible = value),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pushNamed(context, '/mensajes'),
                    icon: const Icon(Icons.message_outlined, color: AppColors.textPrimary),
                  ),
                  Stack(
                    children: [
                      IconButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No hay nuevas notificaciones.')));
                        },
                        icon: const Icon(Icons.notifications_none, color: AppColors.textPrimary),
                      ),
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: const BoxDecoration(color: AppColors.notification, shape: BoxShape.circle),
                          alignment: Alignment.center,
                          child: const Text('3', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFFF8C3B), Color(0xFFFF5B22)]),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Ganancias de hoy', style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: const [
              Text('\$2,450', style: TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.bold)),
              SizedBox(width: 8),
              Text('MXN', style: TextStyle(color: Colors.white70, fontSize: 18)),
            ],
          ),
          const SizedBox(height: 22),
          Container(height: 1, color: Colors.white24),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Esta semana', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    SizedBox(height: 6),
                    Text('\$12,350 MXN', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Servicios hoy', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    SizedBox(height: 6),
                    Text('5 completados', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow() {
    return Row(
      children: [
        Expanded(child: _buildMetricCard(Icons.calendar_today, '8', 'Servicios hoy')),
        const SizedBox(width: 10),
        Expanded(child: _buildMetricCard(Icons.access_time, '4.5h', 'Tiempo activo')),
        const SizedBox(width: 10),
        Expanded(child: _buildMetricCard(Icons.location_on, '12 km', 'Recorridos')),
      ],
    );
  }

  Widget _buildMetricCard(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 8))],
      ),
      child: Column(
        children: [
          Container(
            height: 36,
            width: 36,
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.14), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: AppColors.primary, size: 18),
          ),
          const SizedBox(height: 14),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildUpcomingHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Próximos servicios', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        TextButton(
          onPressed: () {},
          style: TextButton.styleFrom(foregroundColor: AppColors.primary),
          child: const Text('Ver todos'),
        ),
      ],
    );
  }

  Widget _buildUpcomingServiceCard(Map<String, String> service, BuildContext context) {
    final bool confirmed = service['status'] == 'Confirmado';
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ServiceDetailScreen(
              clientName: service['name'] ?? '',
              serviceType: service['service'] ?? '',
              time: service['time'] ?? '',
              distance: service['distance'] ?? '',
              status: service['status'] ?? '',
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 12, offset: const Offset(0, 8))],
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.primary.withOpacity(0.14),
                    child: Text(service['initials'] ?? '', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(service['name'] ?? '', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        const SizedBox(height: 4),
                        Text(service['service'] ?? '', style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: (confirmed ? AppColors.success : AppColors.warning).withOpacity(0.16),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      service['status'] ?? '',
                      style: TextStyle(color: confirmed ? AppColors.success : AppColors.warning, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.schedule, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Text(service['time'] ?? '', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  const SizedBox(width: 18),
                  const Icon(Icons.location_on, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Text(service['distance'] ?? '', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}