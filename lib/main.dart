import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart'; 

// Importaciones de módulos
import 'modules/main_screen.dart'; 
import 'modules/finanzas/billetera_view.dart';
import 'modules/finanzas/detalle_liquidacion_view.dart';
import 'modules/finanzas/historial_servicios_view.dart';
import 'modules/auth/login.dart';
import 'modules/auth/register.dart';
import 'modules/auth/documents.dart';
import 'modules/usuario/agenda_screen.dart';
import 'modules/usuario/messages_screen.dart';
import 'modules/operaciones/service_detail_screen.dart';
import 'modules/operaciones/solicitudes_screen.dart'; // <-- NUEVA RUTA PARA NOTIFICACIONES

// Importación del servicio de notificaciones
import 'services/notification_service.dart';

// 1. LLAVE GLOBAL DE NAVEGACIÓN (Fuera de las clases)
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async { 
  WidgetsFlutterBinding.ensureInitialized();
  
  await initializeDateFormatting('es', null); 

  // 2. INICIALIZAR EL SERVICIO DE NOTIFICACIONES
  await NotificationService().init(navigatorKey);

  runApp(const JobHubApp());
}

class JobHubApp extends StatelessWidget {
  const JobHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // 3. ASIGNAR LA LLAVE AL MATERIAL APP
      navigatorKey: navigatorKey,
      title: 'JobHub Colaborador',
      debugShowCheckedModeBanner: false,
      
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFFE26112),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE26112),
          primary: const Color(0xFFE26112),
        ),
      ),
      
      initialRoute: '/login',
      
      routes: {
        '/login': (context) => const Login(),
        '/register': (context) => const Register(),
        '/documents': (context) => const Documents(),
        '/': (context) => const MainScreen(),
        '/billetera': (context) => const BilleteraView(),
        '/liquidacion': (context) => const DetalleLiquidacionView(),
        '/historial': (context) => const HistorialServiciosView(),
        '/mensajes': (context) => const MessagesScreen(),
        '/agenda': (context) => const AgendaScreen(standalone: true),
        '/detalle_servicio': (context) => const ServiceDetailScreen(agendaData: {}),
        '/solicitudes': (context) => const SolicitudesScreen(), // <-- AÑADIDA PARA QUE NAVEGUE AL TOCAR LA NOTIFICACIÓN
      },
    );
  }
}