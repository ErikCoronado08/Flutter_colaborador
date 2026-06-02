import 'package:flutter/material.dart';

// Importaciones exactas basadas en tu estructura actual
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

void main() {
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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFE26112)),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => Login(),
        '/register': (context) => Register(),
        '/documents': (context) => Documents(),
        '/': (context) => MainScreen(),
        '/liquidacion': (context) => DetalleLiquidacionView(),
        '/historial_transito': (context) => HistorialTransitoView(),
        '/historial': (context) => HistorialServiciosView(),
        '/mensajes': (context) => MessagesScreen(),
        '/chat': (context) => ChatScreen(),
        '/agenda': (context) => AgendaScreen(standalone: true),
        '/detalle_servicio': (context) => ServiceDetailScreen(
              clientName: '', serviceType: '', time: '', distance: '', status: '',
            ),
      },
    );
  }
}