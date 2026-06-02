import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'finanzas/billetera_view.dart';
import 'usuario/home_screen.dart';
import 'operaciones/solicitudes_screen.dart';
import 'usuario/agenda_screen.dart';
import 'usuario/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // Lista de pantallas ahora apuntando a los módulos organizados
  final List<Widget> _screens = [
    const HomeScreen(),                    // 0: Inicio (Eduar)
    const SolicitudesScreen(),             // 1: Solicitudes (Roxana)
    const AgendaScreen(standalone: false), // 2: Agenda (Eduar)
    const BilleteraView(),                 // 3: Wallet (Erick)
    const ProfileScreen(embed: true),      // 4: Perfil (Eduar)
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