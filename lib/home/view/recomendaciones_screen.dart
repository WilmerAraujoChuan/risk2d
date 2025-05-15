import 'package:flutter/material.dart';
import 'package:risk2d/recomendaciones/view/ejercicios_view.dart';
import 'package:risk2d/recomendaciones/view/menu_semanal_view.dart';
import 'package:risk2d/recomendaciones/view/tecnicas_dietas_view.dart';

class RecomendacionesScreen extends StatelessWidget {
  const RecomendacionesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Recomendaciones Personalizadas',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 4,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final cardHeight = screenHeight * 0.22;
          final horizontalPadding = constraints.maxWidth * 0.05;

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: screenHeight * 0.02,
            ),
            child: Column(
              children: [
                _buildRecomendacionCard(
                  context: context,
                  image: 'assets/app/dietas.png',
                  title: 'Técnicas y Dietas',
                  subtitle: 'Guías nutricionales y hábitos saludables.',
                  icon: Icons.restaurant_menu_rounded,
                  color: Colors.teal,
                  cardHeight: cardHeight,
                  onTap: () => _navigateToDetail(context, 'dietas'),
                ),
                SizedBox(height: screenHeight * 0.025),
                _buildRecomendacionCard(
                  context: context,
                  image: 'assets/app/menu.jpg',
                  title: 'Menú Semanal',
                  subtitle: 'Planes de alimentación personalizados.',
                  icon: Icons.calendar_month_rounded,
                  color: Colors.orange,
                  cardHeight: cardHeight,
                  onTap: () => _navigateToDetail(context, 'menu'),
                ),
                SizedBox(height: screenHeight * 0.025),
                _buildRecomendacionCard(
                  context: context,
                  image: 'assets/app/ejercicios.jpg',
                  title: 'Ejercicios',
                  subtitle: 'Rutinas personalizadas a tu condición.',
                  icon: Icons.fitness_center_rounded,
                  color: Colors.blue,
                  cardHeight: cardHeight,
                  onTap: () => _navigateToDetail(context, 'ejercicios'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecomendacionCard({
    required BuildContext context,
    required String image,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required double cardHeight,
    required VoidCallback onTap,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 350;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: cardHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 12,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Stack(
              children: [
                Positioned.fill(
                  child: ShaderMask(
                    shaderCallback: (rect) {
                      return LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                        stops: [isSmallScreen ? 0.3 : 0.4, 1],
                      ).createShader(rect);
                    },
                    blendMode: BlendMode.darken,
                    child: Image.asset(
                      image,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.all(screenWidth * 0.05),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(screenWidth * 0.025),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.9),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          icon,
                          color: Colors.white,
                          size: screenWidth * 0.065,
                        ),
                      ),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: screenWidth * 0.045 + 8,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: screenWidth * 0.01),
                          Text(
                            subtitle,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: screenWidth * 0.025 + 8,
                              height: 1.4,
                              fontWeight: FontWeight.w400,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      SizedBox(height: screenWidth * 0.03),
                      Container(
                        width: screenWidth * 0.12,
                        height: screenWidth * 0.01,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToDetail(BuildContext context, String type) {
    switch (type) {
      case 'dietas':
        Navigator.push(context, MaterialPageRoute(builder: (_) => TecnicasDietasScreen()));
        break;
      case 'menu':
        Navigator.push(context, MaterialPageRoute(builder: (_) => MenuSemanalScreen()));
        break;
      case 'ejercicios':
        Navigator.push(context, MaterialPageRoute(builder: (_) => EjerciciosScreen()));
        break;
    }
  }
}
