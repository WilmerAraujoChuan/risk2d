import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class HistorialScreen extends StatelessWidget {
  const HistorialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Historial de Evaluaciones',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('cuestionarios')
                .where('userId', isEqualTo: user?.uid)
                .orderBy('fecha', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.assessment_outlined,
                    size: 50,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'No hay evaluaciones registradas',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 16),
            itemCount: snapshot.data!.docs.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;

              final fecha =
                  data['fecha'] != null
                      ? (data['fecha'] as Timestamp).toDate()
                      : DateTime.now();
              final nivelRiesgo = data['nivelRiesgo'] as String;
              final puntaje = data['puntajeTotal'] as int;
              final duracion = data['duracionSegundos'] as int;

              return _buildHistorialItem(
                fecha: fecha,
                nivelRiesgo: nivelRiesgo,
                puntaje: puntaje,
                duracion: duracion,
                context: context,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildHistorialItem({
    required DateTime fecha,
    required String nivelRiesgo,
    required int puntaje,
    required int duracion,
    required BuildContext context,
  }) {
    final color = _getRiskColor(nivelRiesgo);
    final formattedTime =
        '${duracion ~/ 60}:${(duracion % 60).toString().padLeft(2, '0')}';

    return Material(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('dd MMM yyyy').format(fecha),
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color.withOpacity(0.3)),
                  ),
                  child: Text(
                    nivelRiesgo.split(' ')[0],
                    style: TextStyle(
                      color: color,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildMetricItem(
                  icon: Icons.bar_chart_rounded,
                  color: color,
                  value: '$puntaje Puntos',
                ),
                const SizedBox(width: 20),
                _buildMetricItem(
                  icon: Icons.timer_outlined,
                  color: Colors.blueGrey,
                  value: formattedTime,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem({
    required IconData icon,
    required Color color,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(
            color: Colors.grey[800],
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Color _getRiskColor(String nivelRiesgo) {
    if (nivelRiesgo.contains('Bajo')) return Colors.green;
    if (nivelRiesgo.contains('moderado')) return Colors.orange;
    return Colors.red;
  }
}
