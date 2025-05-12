import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:risk2d/auth/view/login_screen.dart';
import 'package:risk2d/common/colors.dart';
import 'package:risk2d/home/view/historial_screen.dart';
import 'package:risk2d/home/view/home_screen.dart';
import 'package:risk2d/home/view/recomendaciones_screen.dart';

class OpcionesView extends StatefulWidget {
  const OpcionesView({super.key});

  @override
  State<OpcionesView> createState() => _OpcionesViewState();
}

class _OpcionesViewState extends State<OpcionesView> {
  int _selectedIndex = 0;
  final List<Widget> _screens = const [
    HomeContent(),
    HistorialScreen(),
    RecomendacionesScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      // Manejo de errores
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al cerrar sesión: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut, // Llama a la función de cierre de sesión
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: _buildCustomNavBar(),
    );
  }

  Widget _buildCustomNavBar() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Inicio',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_outlined),
              activeIcon: Icon(Icons.history),
              label: 'Historial',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.recommend_outlined),
              activeIcon: Icon(Icons.recommend),
              label: 'Recomendaciones',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          elevation: 10,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
