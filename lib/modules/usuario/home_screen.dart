import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_colors.dart';
import '../operaciones/service_detail_screen.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool disponible = true;
  bool cargando = true;
  late SharedPreferences _prefs;

  String nombreUsuario = 'Cargando...';
  String gananciasHoy = '0';
  String serviciosCompletados = '0';
  String estadoVerificacion = 'aprobado'; 
  List<dynamic> proximosServicios = [];

  @override
  void initState() {
    super.initState();
    _initializePreferences();
    _cargarDatosBackend();
  }

  Future<void> _initializePreferences() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() => disponible = _prefs.getBool('disponible') ?? true);
  }

  Future<void> _cargarDatosBackend() async {
    setState(() => cargando = true);

    final data = await ApiService.obtenerDashboard();

    setState(() {
      if (data != null) {
        final perfil = data['perfil'];
        final estadisticas = data['estadisticas'];

        // ¡AQUÍ ESTÁ LA CORRECCIÓN CLAVE! Leemos 'nombre_completo'
        nombreUsuario = perfil != null ? (perfil['nombre_completo'] ?? 'Colaborador') : 'Colaborador';
        
        estadoVerificacion = perfil != null ? (perfil['estado'] ?? 'pendiente') : 'pendiente';
        
        if (estadisticas != null) {
          gananciasHoy = estadisticas['ingresos_mes']?.toString() ?? '0';
          serviciosCompletados = estadisticas['servicios_completados']?.toString() ?? '0';
        }

        proximosServicios = data['servicios_activos'] ?? [];
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
          onRefresh: _cargarDatosBackend,
          color: AppColors.primary,
          child: cargando 
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
              : (estadoVerificacion == 'pendiente' || estadoVerificacion == 'rechazado')
                  ? _buildEsperaAprobacion()
                  : _buildDashboard(context),
        ),
      ),
    );
  }

  Widget _buildEsperaAprobacion() {
    bool isRechazado = estadoVerificacion == 'rechazado';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(isRechazado ? Icons.cancel_outlined : Icons.hourglass_empty_outlined, size: 80, color: isRechazado ? Colors.red : Colors.amber.shade600),
          const SizedBox(height: 32),
          Text(isRechazado ? 'Solicitud Rechazada' : 'Perfil en Revisión', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          Text(isRechazado ? 'No cumples los requisitos.' : 'Estamos validando tus documentos.', textAlign: TextAlign.center),
          const SizedBox(height: 40),
          ElevatedButton.icon(
            onPressed: () async {
              await AuthService().logout();
              if (mounted) Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
            },
            icon: const Icon(Icons.logout, color: Colors.white),
            label: const Text('Salir', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          )
        ],
      ),
    );
  }

  Widget _buildDashboard(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildHeader(context),
        const SizedBox(height: 24),
        _buildEarningsCard(),
        const SizedBox(height: 32),
        const Text('Servicios en Curso', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        if (proximosServicios.isEmpty)
          const Center(child: Text('No tienes servicios pendientes'))
        else
          ...proximosServicios.map((s) => _buildServiceCard(s, context)),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(radius: 28, backgroundColor: AppColors.primary, child: Icon(Icons.person, color: Colors.white)),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Bienvenido', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              Text('¡Hola, $nombreUsuario!', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEarningsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Ganancias del Mes', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          Text('\$$gananciasHoy MXN', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Text('Total completados: $serviciosCompletados', style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildServiceCard(dynamic service, BuildContext context) {
    final cliente = service['cliente_nombre'] ?? 'Cliente';
    final servicio = service['servicio_nombre'] ?? 'Servicio';
    final estado = service['estado_operativo'] ?? 'Pendiente';

    return Card(
      child: ListTile(
        leading: const Icon(Icons.work, color: AppColors.primary),
        title: Text(cliente, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(servicio),
        trailing: Text(estado, style: const TextStyle(color: AppColors.primary)),
      ),
    );
  }
}