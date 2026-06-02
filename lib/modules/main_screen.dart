import 'package:flutter/material.dart';
import 'finanzas/views/billetera_view.dart';

// Importaciones de los demás módulos
import '../screens/home_screen.dart';
import '../screens/solicitudes_screen.dart'; // <-- La nueva integración estrella
import '../screens/agenda_screen.dart';
import '../screens/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // El arsenal completo de 5 pestañas para el trabajador
  final List<Widget> _screens = [
    const HomeScreen(),                         // 0: Inicio (Dashboard)
    const SolicitudesScreen(),                  // 1: Solicitudes (Buscar trabajo)
    const AgendaScreen(standalone: false),      // 2: Agenda (Calendario)
    const BilleteraView(),                      // 3: Wallet (Finanzas)
    const ProfileScreen(embed: true),           // 4: Perfil (Configuración)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, -2),
            )
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFFE26112), // Naranja JobHub
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Inicio',
            ),
            // Pestaña de Solicitudes con el Badge rojo de Roxana
            BottomNavigationBarItem(
              icon: Badge(
                label: Text('3', style: TextStyle(color: Colors.white, fontSize: 10)),
                backgroundColor: Colors.red,
                child: Icon(Icons.business_center_outlined),
              ),
              activeIcon: Badge(
                label: Text('3', style: TextStyle(color: Colors.white, fontSize: 10)),
                backgroundColor: Colors.red,
                child: Icon(Icons.business_center),
              ),
              label: 'Solicitudes',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined),
              activeIcon: Icon(Icons.calendar_today),
              label: 'Agenda',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet_outlined),
              activeIcon: Icon(Icons.account_balance_wallet),
              label: 'Wallet',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}