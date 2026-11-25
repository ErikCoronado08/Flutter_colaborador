import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_colors.dart';
import '../operaciones/service_detail_screen.dart';
import '../operaciones/solicitudes_screen.dart';
import 'centro_ayuda_screen.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../services/notification_service.dart';

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
  String saldoDisponible = '0.00';
  String dineroEnTransito = '0.00';
  String gananciasHistoricas = '0.00';
  String estadoVerificacion = 'aprobado';
  String? fotoPerfilUrl;
  int numeroSolicitudes = 0;

  Timer? _timerSolicitudes;
  int _ultimoConteo = 0;

  List<dynamic> proximosServicios = [];
  List<dynamic> transaccionesRecientes = [];

  @override
  void initState() {
    super.initState();
    _initializePreferences();
    _cargarDatosBackend();
    _iniciarEscuchaDeSolicitudes();
  }

  void _iniciarEscuchaDeSolicitudes() {
    _timerSolicitudes = Timer.periodic(const Duration(seconds: 15), (timer) async {
      final solicitudes = await ApiService.obtenerSolicitudes();

      if (solicitudes.length > _ultimoConteo) {
        NotificationService().mostrarNotificacion(
          id: 1,
          title: '¡Nueva solicitud de servicio!',
          body: 'Un cliente requiere tus servicios. Toca para revisar.',
          payload: 'nueva_solicitud',
        );
      }

      if (mounted) {
        setState(() {
          numeroSolicitudes = solicitudes.length;
          _ultimoConteo = solicitudes.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timerSolicitudes?.cancel();
    super.dispose();
  }

  Future<void> _initializePreferences() async {
    _prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => disponible = _prefs.getBool('disponible') ?? true);
  }

  Future<void> _cargarDatosBackend() async {
    setState(() => cargando = true);

    final data = await ApiService.obtenerDashboard();
    final solicitudes = await ApiService.obtenerSolicitudes();

    if (!mounted) return;
    setState(() {
      if (data != null) {
        final perfil = data['perfil'];

        if (perfil != null) {
          nombreUsuario = perfil['nombre_completo'] ?? 'Colaborador';
          estadoVerificacion = perfil['estado'] ?? 'pendiente';
          saldoDisponible = perfil['saldo_disponible']?.toString() ?? '0.00';
          dineroEnTransito = perfil['dinero_en_transito']?.toString() ?? '0.00';
          gananciasHistoricas = perfil['ganancias_historicas']?.toString() ?? '0.00';
          fotoPerfilUrl = perfil['foto_perfil_url']?.toString();
        }

        proximosServicios = data['servicios'] ?? [];
        transaccionesRecientes = data['transacciones'] ?? [];
      }

      numeroSolicitudes = solicitudes.length;
      _ultimoConteo = solicitudes.length;
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
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isRechazado ? Colors.red.shade50 : Colors.amber.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isRechazado ? Icons.gpp_bad_rounded : Icons.admin_panel_settings_rounded,
                size: 60,
                color: isRechazado ? Colors.red : Colors.amber.shade600,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isRechazado ? 'Perfil Rechazado' : 'Perfil en Revisión',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              isRechazado
                  ? 'Alguno de tus documentos no cumple con los requisitos. Por favor, revisa tu correo electrónico o tu portal web para corregirlo.'
                  : 'Tu expediente de seguridad está siendo validado por nuestro equipo. Te notificaremos cuando tu cuenta esté aprobada.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await AuthService().logout();
                  if (mounted) Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                },
                icon: const Icon(Icons.logout, color: Colors.white, size: 20),
                label: const Text('Cerrar sesión', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isRechazado ? Colors.red : AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboard(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildHeader(context),
        const SizedBox(height: 24),
        _buildBalanceCard(),
        const SizedBox(height: 16),
        _buildStatsRow(),
        const SizedBox(height: 32),

        _buildSectionTitle('Servicios en Curso', Icons.work_outline),
        const SizedBox(height: 12),
        if (proximosServicios.isEmpty)
          _buildEmptyState('No tienes servicios agendados por el momento.')
        else
          ...proximosServicios.map((s) => _buildServiceCard(s, context)),

        const SizedBox(height: 32),

        _buildSectionTitle('Transacciones Recientes', Icons.receipt_long_outlined),
        const SizedBox(height: 12),
        if (transaccionesRecientes.isEmpty)
          _buildEmptyState('No hay movimientos recientes.')
        else
          ...transaccionesRecientes.take(3).map((t) => _buildTransactionCard(t)),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    final String? avatarNormalizado = ApiService.normalizarUrl(fotoPerfilUrl);

    return Row(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: ClipOval(
            child: avatarNormalizado != null
                ? Image.network(
                    avatarNormalizado,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.person, color: AppColors.primary, size: 30),
                  )
                : const Icon(Icons.person, color: AppColors.primary, size: 30),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Bienvenido de vuelta,', style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500)),
              Text(nombreUsuario, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
            ],
          ),
        ),

        GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const CentroAyudaScreen()));
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
            child: const Icon(Icons.help_outline, color: Colors.black87),
          ),
        ),
        const SizedBox(width: 12),

        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SolicitudesScreen()),
            ).then((_) => _cargarDatosBackend());
          },
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
                child: const Icon(Icons.notifications_none, color: Colors.black87),
              ),
              if (numeroSolicitudes > 0)
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                    child: Text('$numeroSolicitudes', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.account_balance_wallet, color: Colors.white70, size: 20),
              SizedBox(width: 8),
              Text('Saldo Disponible', style: TextStyle(color: Colors.white70, fontSize: 15, fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 12),
          Text('\$$saldoDisponible MXN', style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: -1)),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, color: Colors.white, size: 16),
                    SizedBox(width: 8),
                    Text('Listo para retirar', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock_clock, color: Colors.white70, size: 16),
                    const SizedBox(width: 8),
                    Text('Retenido: \$$dineroEnTransito', style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade200)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.trending_up, color: Colors.green),
                const SizedBox(height: 12),
                const Text('Histórico', style: TextStyle(color: Colors.grey, fontSize: 13)),
                Text('\$$gananciasHistoricas', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade200)),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.star, color: Colors.amber),
                SizedBox(height: 12),
                Text('Calificación', style: TextStyle(color: Colors.grey, fontSize: 13)),
                Text('Ver Perfil', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.black87, size: 22),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade200, style: BorderStyle.solid)),
      child: Column(
        children: [
          Icon(Icons.inbox_outlined, size: 40, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildServiceCard(dynamic service, BuildContext context) {
    final estatus = service['estatus'] ?? 'Pendiente';
    final fecha = service['fecha'] ?? 'Sin fecha';
    final hora = service['hora_inicio'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade200)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
          child: const Icon(Icons.handyman, color: AppColors.primary),
        ),
        title: const Text('Servicio Agendado', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
        subtitle: Text('$fecha • $hora', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(20)),
          child: Text(estatus.toString().toUpperCase(), style: TextStyle(color: Colors.blue.shade700, fontSize: 10, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildTransactionCard(dynamic trx) {
    final monto = trx['monto']?.toString() ?? '0.00';
    final tipo = trx['tipo'] ?? 'Desconocido';
    final estado = trx['estado'] ?? 'pendiente';

    bool isIngreso = tipo.toString().toLowerCase() != 'retiro';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade200)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isIngreso ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(isIngreso ? Icons.arrow_downward : Icons.arrow_upward, color: isIngreso ? Colors.green : Colors.orange, size: 20),
        ),
        title: Text(tipo.toString().toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
        subtitle: Text(estado, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
        trailing: Text(
          '${isIngreso ? '+' : '-'}\$$monto',
          style: TextStyle(color: isIngreso ? Colors.green : Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}