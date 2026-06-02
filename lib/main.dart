import 'package:flutter/material.dart';
import 'modules/main_screen.dart'; 
import 'modules/finanzas/views/detalle_liquidacion_view.dart';
import 'modules/finanzas/views/historial_transito_view.dart';
import 'modules/finanzas/views/historial_servicios_view.dart';

import 'screens/chat_screen.dart';
import 'screens/agenda_screen.dart';
import 'screens/service_detail_screen.dart';
import 'screens/messages_screen.dart';

// 👇 Importaciones de Auth de Gadiel
import 'screens/auth/login.dart';
import 'screens/auth/register.dart';
import 'screens/auth/documents.dart';

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
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE26112),
          secondary: const Color(0xFF4A1502),
        ),
      ),
      // 👇 AHORA LA APP INICIA EN EL LOGIN
      initialRoute: '/login',
      routes: {
        // --- RUTAS DE AUTH (Gadiel) ---
        '/login': (context) => const Login(),
        '/register': (context) => const Register(),
        '/documents': (context) => const Documents(),

        // --- NÚCLEO DE NAVEGACIÓN ---
        '/': (context) => const MainScreen(), 

        // --- RUTAS DE FINANZAS (Tuyas) ---
        '/liquidacion': (context) => const DetalleLiquidacionView(), 
        '/historial_transito': (context) => const HistorialTransitoView(),
        '/historial': (context) => const HistorialServiciosView(), 

        // --- RUTAS DE COLABORADORES ---
        '/mensajes': (context) => const MessagesScreen(), 
        '/chat': (context) => const ChatScreen(),
        '/agenda': (context) => const AgendaScreen(),
        '/detalle_servicio': (context) => const ServiceDetailScreen(
          clientName: '',
          serviceType: '',
          time: '',
          distance: '',
          status: '',
        ),
      },
    );
  }
}