import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:risk2d/cuestionario/view/diabetes_risk_questionnarie.dart';

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final user = FirebaseAuth.instance.currentUser;

    return FutureBuilder<DocumentSnapshot>(
      future:
          FirebaseFirestore.instance
              .collection('usuarios')
              .doc(user?.uid)
              .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Theme.of(context).primaryColor,
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
          return _buildErrorWidget();
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>;
        final nombre = _getFormattedName(userData);

        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: 30,
            vertical: screenHeight * 0.05,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildWelcomeHeader(nombre, context),
              _buildLogoSection(context),
              _buildStartButton(context),
              _buildDecoratedFooter(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, color: Colors.red[400], size: 50),
            const SizedBox(height: 15),
            Text(
              'Error cargando datos',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getFormattedName(Map<String, dynamic> userData) {
    final nombres = userData['nombres']?.toString().split(' ') ?? [];
    final apellidos = userData['apellidos']?.toString().split(' ') ?? [];

    return '${nombres.isNotEmpty ? nombres[0] : ''} ${apellidos.isNotEmpty ? apellidos[0] : ''}';
  }

  Widget _buildWelcomeHeader(String nombre, BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.waving_hand_rounded, color: Colors.amber[600], size: 28),
            const SizedBox(width: 10),
            Text(
              'Bienvenido/a a',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w300,
                color: Colors.grey[600],
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'RISK2D',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 25),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 25),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 12,
                spreadRadius: 3,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.person_pin_circle_rounded,
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                nombre,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLogoSection(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                Theme.of(context).primaryColor.withOpacity(0.1),
                Colors.transparent,
              ],
              stops: const [0.1, 1.0],
            ),
          ),
        ),
        Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.5,
            maxHeight: MediaQuery.of(context).size.height * 0.25,
          ),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).primaryColor.withOpacity(0.2),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Image.asset(
            'assets/app/logo.png',
            fit: BoxFit.cover,
            errorBuilder:
                (context, error, stackTrace) => Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.psychology_rounded,
                    size: 80,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildStartButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.assignment_outlined, size: 24),
        label: const Text(
          'INICIAR EVALUACIÓN',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.1,
          ),
        ),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 25),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 3,
          shadowColor: Theme.of(context).primaryColor.withOpacity(0.3),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const DiabetesRiskQuestionnaire()),
          );
        },
      ),
    );
  }

  Widget _buildDecoratedFooter() {
    return Padding(
      padding: const EdgeInsets.only(top: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          3,
          (index) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Icon(Icons.circle_rounded, size: 8, color: Colors.grey[400]),
          ),
        ),
      ),
    );
  }
}
