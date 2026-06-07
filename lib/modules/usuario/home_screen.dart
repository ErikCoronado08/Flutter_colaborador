import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../theme/app_colors.dart';
import '../operaciones/service_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool disponible = true;
  late SharedPreferences _prefs;
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializePreferences();
    _initializeNotifications();
  }

  Future<void> _initializePreferences() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      disponible = _prefs.getBool('disponible') ?? true;
    });
  }

  Future<void> _saveDisponibilidad(bool value) async {
    await _prefs.setBool('disponible', value);
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings();
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _notificationsPlugin.initialize(initSettings);
  }

  Future<void> _showReminderNotification() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'jobhub_reminder',
      'Recordatorios JobHub',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);
    await _notificationsPlugin.show(
      0,
      'Recordatorio de servicio',
      'Tienes servicios programados próximamente.',
      platformDetails,
    );
  }

  final List<Map<String, String>> upcomingServices = [
    {
      'initials': 'MG',
      'name': 'María García',
      'service': 'Limpieza general',
      'time': '10:00 AM',
      'distance': '2.5 km',
      'status': 'Confirmado',
      'avatarUrl': 'https://picsum.photos/seed/mg/100',
    },
    {
      'initials': 'CL',
      'name': 'Carlos López',
      'service': 'Plomería',
      'time': '5:30 PM',
      'distance': '8.1 km',
      'status': 'Pendiente',
      'avatarUrl': 'https://picsum.photos/seed/cl/100',
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      children: [
        _buildHeader(context),
        const SizedBox(height: 24),
        _buildAvailabilityToggle(),
        const SizedBox(height: 24),
        _buildEarningsCard(),
        const SizedBox(height: 20),
        _buildUnifiedMetrics(),
        const SizedBox(height: 32),
        _buildUpcomingHeader(),
        const SizedBox(height: 16),
        ...upcomingServices.map((service) => _buildUpcomingServiceCard(service, context)),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 28,
          backgroundColor: AppColors.primary,
          child: Icon(Icons.person, color: Colors.white, size: 26),
        ),
        const SizedBox(width: 16),
        // 👉 SOLUCIÓN OVERFLOW 1: Expanded envuelve los textos del header
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('Bienvenido de nuevo', style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
              SizedBox(height: 4),
              Text(
                '¡Hola, Eduardo!', 
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                overflow: TextOverflow.ellipsis, // Si el nombre es muy largo, pone "..."
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => Navigator.pushNamed(context, '/mensajes'),
          icon: const Icon(Icons.message_outlined, color: AppColors.textPrimary, size: 26),
        ),
        Stack(
          children: [
            IconButton(
              onPressed: () {
                _showReminderNotification();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Recordatorio enviado.')));
              },
              icon: const Icon(Icons.notifications_none, color: AppColors.textPrimary, size: 26),
            ),
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(color: AppColors.notification, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: const Text('3', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAvailabilityToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 👉 SOLUCIÓN OVERFLOW 2: Expanded envuelve el texto del switch
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: disponible ? AppColors.success : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    disponible ? 'Estás disponible para servicios' : 'Estás desconectado', 
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch(
            value: disponible,
            activeThumbColor: AppColors.surface,
            activeTrackColor: AppColors.success,
            inactiveTrackColor: const Color(0xFFD7D7DB),
            onChanged: (value) {
              setState(() => disponible = value);
              _saveDisponibilidad(value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFFF8C3B), Color(0xFFFF5B22)]),
        boxShadow: [
          BoxShadow(color: const Color(0xFFFF5B22).withValues(alpha: 77), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Ganancias de hoy', style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500)),
              Icon(Icons.trending_up, color: Colors.white.withValues(alpha: 204), size: 20),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: const [
              Text('\$2,450', style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
              SizedBox(width: 6),
              Padding(
                padding: EdgeInsets.only(bottom: 6),
                child: Text('MXN', style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(height: 1, color: Colors.white.withValues(alpha: 51)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Esta semana', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    SizedBox(height: 4),
                    Text('\$12,350 MXN', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              Container(width: 1, height: 30, color: Colors.white.withValues(alpha: 51)),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Servicios hoy', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    SizedBox(height: 4),
                    Text('5 completados', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUnifiedMetrics() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildSingleMetric(Icons.calendar_today, '8', 'Servicios'),
          Container(width: 1, height: 40, color: Colors.grey.shade200),
          _buildSingleMetric(Icons.access_time, '4.5h', 'Activo'),
          Container(width: 1, height: 40, color: Colors.grey.shade200),
          _buildSingleMetric(Icons.location_on_outlined, '12 km', 'Ruta'),
        ],
      ),
    );
  }

  Widget _buildSingleMetric(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 22),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      ],
    );
  }

  Widget _buildUpcomingHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Próximos servicios', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        InkWell(
          onTap: () {},
          child: const Text('Ver todos', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 14)),
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
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 5), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 26),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: service['avatarUrl'] ?? '',
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      errorWidget: (context, url, error) => Text(service['initials'] ?? '', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(service['name'] ?? '', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      const SizedBox(height: 4),
                      Text(service['service'] ?? '', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: confirmed ? AppColors.success.withValues(alpha: 26) : AppColors.warning.withValues(alpha: 26),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    service['status'] ?? '',
                    style: TextStyle(color: confirmed ? AppColors.success : AppColors.warning, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(height: 1),
            ),
            Row(
              children: [
                Icon(Icons.schedule, size: 18, color: Colors.grey.shade400),
                const SizedBox(width: 6),
                Text(service['time'] ?? '', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
                // 👉 SOLUCIÓN OVERFLOW 3: Usamos Spacer() para que empuje dinámicamente y no rompa pantallas chicas
                const Spacer(), 
                Icon(Icons.location_on_outlined, size: 18, color: Colors.grey.shade400),
                const SizedBox(width: 6),
                Text(service['distance'] ?? '', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}