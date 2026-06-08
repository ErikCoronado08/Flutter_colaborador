import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart'; // <--- AGREGADO PARA EL IDIOMA DE LA AGENDA

// Importaciones de módulos
import 'modules/main_screen.dart'; 
import 'modules/finanzas/billetera_view.dart';
import 'modules/finanzas/detalle_liquidacion_view.dart';
import 'modules/finanzas/historial_transito_view.dart';
import 'modules/finanzas/historial_servicios_view.dart';
import 'modules/auth/login.dart';
import 'modules/auth/register.dart';
import 'modules/auth/documents.dart';
import 'modules/usuario/agenda_screen.dart';
import 'modules/usuario/messages_screen.dart';
import 'modules/operaciones/chat_screen.dart';
import 'modules/operaciones/service_detail_screen.dart';

void main() async { // <--- CAMBIADO A ASYNC
  // Aseguramos la inicialización de los bindings de Flutter
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializamos el formato de fechas para la agenda (es = español)
  await initializeDateFormatting('es', null); // <--- AGREGADO

  runApp(const JobHubApp());
}

class JobHubApp extends StatelessWidget {
  const JobHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      
      // Ruta inicial
      initialRoute: '/login',
      
      // Definición de rutas
      routes: {
        '/login': (context) => const Login(),
        '/register': (context) => const Register(),
        '/documents': (context) => const Documents(),
        '/': (context) => const MainScreen(),
        '/billetera': (context) => const BilleteraView(),
        '/liquidacion': (context) => const DetalleLiquidacionView(),
        '/historial_transito': (context) => const HistorialTransitoView(),
        '/historial': (context) => const HistorialServiciosView(),
        '/mensajes': (context) => const MessagesScreen(),
        '/chat': (context) => const ChatScreen(),
        '/agenda': (context) => const AgendaScreen(standalone: true),
        '/detalle_servicio': (context) => const ServiceDetailScreen(
              clientName: 'N/A', 
              serviceType: 'N/A', 
              time: 'N/A', 
              distance: 'N/A', 
              status: 'N/A',
            ),
      },
    );
  }
}