import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../theme/app_colors.dart';
import '../operaciones/service_detail_screen.dart';
import '../../services/api_service.dart'; // Asegúrate de importar tu servicio nuevo

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool disponible = true;
  bool cargando = true;
  late SharedPreferences _prefs;
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  // Variables para guardar los datos reales del Backend NoSQL
  String nombreUsuario = 'Cargando...';
  String gananciasHoy = '0';
  String serviciosCompletados = '0';
  List<dynamic> proximosServicios = [];

  @override
  void initState() {
    super.initState();
    _initializePreferences();
    _initializeNotifications();
    _cargarDatosBackend(); // Llamada inicial a la API
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

  // Método unificado de carga asíncrona
  Future<void> _cargarDatosBackend() async {
    setState(() => cargando = true);

    final perfil = await ApiService.obtenerPerfil();
    final estadisticas = await ApiService.obtenerEstadisticas();
    final agenda = await ApiService.obtenerAgenda();

    setState(() {
      if (perfil != null) {
        nombreUsuario = perfil['name'] ?? 'Colaborador';
      }
      if (estadisticas != null) {
        // Formatear o extraer los datos numéricos de MongoDB
        gananciasHoy = estadisticas['ingresos_generados']?.toString() ?? '0';
        serviciosCompletados = estadisticas['servicios_completados']?.toString() ?? '0';
      }
      if (agenda != null) {
        proximosServicios = agenda;
      }
      cargando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _cargarDatosBackend, // Permite arrastrar hacia abajo para actualizar
          child: cargando 
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
              : _buildDashboard(context),
        ),
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
        if (proximosServicios.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(child: Text('No tienes servicios pendientes', style: TextStyle(color: AppColors.textSecondary))),
          )
        else
          ...proximosServicios.map((service) => _buildUpcomingServiceCard(service, context)),
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
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Bienvenido de nuevo', style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Text(
                '¡Hola, $nombreUsuario!', 
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                overflow: TextOverflow.ellipsis,
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
          BoxShadow(color: const Color(0xFFFF5B22).withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Ganancias Históricas', style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500)),
              Icon(Icons.trending_up, color: Colors.white.withValues(alpha: 0.8), size: 20),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('\$$gananciasHoy', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
              const SizedBox(width: 6),
              const Padding(
                padding: EdgeInsets.only(bottom: 6),
                child: Text('MXN', style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(height: 1, color: Colors.white.withValues(alpha: 0.2)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total completados', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text('$serviciosCompletados servicios', style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              Container(width: 1, height: 30, color: Colors.white.withValues(alpha: 0.2)),
              const SizedBox(width: 20),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tipo de Cuenta', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text('Premium', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
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
          _buildSingleMetric(Icons.calendar_today, proximosServicios.length.toString(), 'Agendados'),
          Container(width: 1, height: 40, color: Colors.grey.shade200),
          _buildSingleMetric(Icons.star_border, '4.8', 'Calificación'),
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

  Widget _buildUpcomingServiceCard(dynamic service, BuildContext context) {
    // Adaptación a la estructura que regresa tu tabla 'servicios' en Mongo
    final String cliente = service['cliente'] ?? service['name'] ?? 'Cliente';
    final String tipoServicio = service['tipo'] ?? service['service'] ?? 'Servicio';
    final String hora = service['hora'] ?? service['time'] ?? 'Por definir';
    final String distancia = service['distancia'] ?? service['distance'] ?? '0.0 km';
    final String estado = service['estado'] ?? service['status'] ?? 'Pendiente';
    final String iniciales = cliente.isNotEmpty ? cliente.substring(0, 2).toUpperCase() : 'SR';

    final bool confirmed = estado.toLowerCase() == 'confirmado' || estado.toLowerCase() == 'activo';
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ServiceDetailScreen(
              clientName: cliente,
              serviceType: tipoServicio,
              time: hora,
              distance: distancia,
              status: estado,
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
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
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
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: service['avatarUrl'] ?? 'https://picsum.photos/seed/$iniciales/100',
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      errorWidget: (context, url, error) => Text(iniciales, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(cliente, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      const SizedBox(height: 4),
                      Text(tipoServicio, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: confirmed ? AppColors.success.withValues(alpha: 0.1) : AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    estado,
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
                Text(hora, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
                const Spacer(), 
                Icon(Icons.location_on_outlined, size: 18, color: Colors.grey.shade400),
                const SizedBox(width: 6),
                Text(distancia, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}