import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:risk2d/core/api.dart';

class TecnicasDietasScreen extends StatefulWidget {
  const TecnicasDietasScreen({super.key});

  @override
  _TecnicasDietasScreenState createState() => _TecnicasDietasScreenState();
}

class _TecnicasDietasScreenState extends State<TecnicasDietasScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  String _recommendation = '';
  bool _isLoading = true;
  bool _hasError = false;
  double _progress = 0.0;
  String _currentStatus = "Analizando tus respuestas...";

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    try {
      _updateProgress(0.1, "Cargando datos del cuestionario...");

      final querySnapshot = await _firestore
          .collection('cuestionarios')
          .where('userId', isEqualTo: _auth.currentUser?.uid)
          .orderBy('fecha', descending: true)
          .limit(1)
          .get(const GetOptions(source: Source.server))
          .timeout(const Duration(seconds: 10));

      if (!mounted) return;
      _updateProgress(0.3, "Procesando tu perfil...");

      if (querySnapshot.docs.isEmpty) {
        _handleError("No se encontraron cuestionarios completos");
        return;
      }

      final data = querySnapshot.docs.first.data();
      final preguntas = data['preguntas'] as List<dynamic>;

      _updateProgress(0.5, "Personalizando recomendaciones...");
      await Future.delayed(const Duration(milliseconds: 500));

      final prompt = '''
Contexto del usuario (${data['nivelRiesgo']}):
${construirPerfilUsuario(preguntas)}

Genera recomendaciones SIGUIENDO ESTRICTAMENTE ESTE FORMATO:

## 🔰 Mantenimiento Preventivo
• [Recomendación 1]
• [Recomendación 2]
• [Recomendación 3]

## 🥦 Optimización Nutricional
• [Recomendación 1]
• [Recomendación 2]

## 🏋️ Rutina de Ejercicios
• [Recomendación 1]
• [Recomendación 2]

## 🛡️ Estrategias Preventivas
• [Recomendación 1]
• [Recomendación 2]

NO INCLUIR:
- Encabezados diferentes a los especificados
- Texto fuera de las secciones
- Viñetas diferentes a "•"
''';

      _updateProgress(0.7, "Generando con IA...");
      final model = GenerativeModel(
        model: 'gemini-2.0-flash',
        apiKey: GEMINI_API_KEY,
        generationConfig: GenerationConfig(
          maxOutputTokens: 2000,
          temperature: 0.3,
          topP: 0.95,
        ),
        systemInstruction: Content.text('''
Eres un experto en nutrición que genera respuestas CON ESTRUCTURA ESTRICTA.
Formato requerido:
1. Usar exactamente 4 secciones con los títulos especificados
2. Cada sección debe contener 2-3 viñetas usando el carácter "•"
3. No usar markdown excepto los encabezados ##
4. Incluir emojis relevantes en cada viñeta
'''),
      );

      final response = await model
          .generateContent([Content.text(prompt)])
          .timeout(const Duration(seconds: 25));

      if (!mounted) return;
      _updateProgress(1.0, "Análisis completo");

      await Future.delayed(const Duration(milliseconds: 300));

      if (mounted) {
        setState(() {
          _recommendation = response.text ?? 'No se generaron recomendaciones';
          _isLoading = false;
        });
        debugPrint('Respuesta cruda de Gemini:');
        debugPrint(_recommendation);
      }
    } catch (e) {
      _handleError("Error en el proceso: ${e.toString()}");
    }
  }

  String construirPerfilUsuario(List<dynamic> preguntas) {
    final perfil = StringBuffer();
    for (final pregunta in preguntas) {
      final textoPregunta = (pregunta as Map)['pregunta'].toString();
      final respuesta = pregunta['respuesta'].toString();
      final preguntaClave = textoPregunta.replaceAll(RegExp(r'^\d+\.\s*'), '');
      perfil.writeln('• $preguntaClave: $respuesta');
    }
    return perfil.toString();
  }

  void _updateProgress(double progress, String status) {
    if (mounted) {
      setState(() {
        _progress = progress;
        _currentStatus = status;
      });
    }
  }

  void _handleError(String message) {
    if (mounted) {
      setState(() {
        _hasError = true;
        _isLoading = false;
        _currentStatus = message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Técnicas y Guías Nutricionales'),
        centerTitle: true,
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LinearProgressIndicator(
              value: _progress,
              backgroundColor: Colors.grey[200],
              minHeight: 12,
              borderRadius: BorderRadius.circular(10),
            ),
            const SizedBox(height: 20),
            Text(
              _currentStatus,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 50, color: Colors.red[400]),
            const SizedBox(height: 20),
            Text(
              _currentStatus,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _loadRecommendations,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    return _buildRecommendationContent();
  }

  Widget _buildRecommendationContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection('🔰 Mantenimiento Preventivo', _recommendation),
          _buildSection('🥦 Optimización Nutricional', _recommendation),
          _buildSection('🏋️ Rutina de Ejercicios', _recommendation),
          _buildSection('🛡️ Estrategias Preventivas', _recommendation),
          _buildDisclaimer(),
        ],
      ),
    );
  }

  Widget _buildDisclaimer() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Text(
        'Estas recomendaciones son personalizadas según tus respuestas y deben '
        'ser validadas por un profesional de salud.',
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
          fontStyle: FontStyle.italic,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    final sectionContent = _extractSectionContent(title, content);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getSectionIcon(title),
                color: _getSectionColor(title),
                size: 28,
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: _getSectionColor(title),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            sectionContent,
            style: TextStyle(
              fontSize: 16,
              height: 1.5,
              color: Colors.grey[800],
            ),
            strutStyle: const StrutStyle(
              forceStrutHeight: true,
              height: 1.4,
              leading: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Color _getSectionColor(String title) {
    if (title.startsWith('🔰')) {
      return Colors.green;
    } else if (title.startsWith('🥦')) {
      return Colors.teal;
    } else if (title.startsWith('🏋️')) {
      return Colors.orange;
    } else if (title.startsWith('🛡️')) {
      return Colors.blue;
    } else {
      return Colors.purple;
    }
  }

  IconData _getSectionIcon(String title) {
    if (title.startsWith('🔰')) {
      return Icons.health_and_safety;
    } else if (title.startsWith('🥦')) {
      return Icons.nature;
    } else if (title.startsWith('🏋️')) {
      return Icons.fitness_center;
    } else if (title.startsWith('🛡️')) {
      return Icons.security;
    } else {
      return Icons.tips_and_updates;
    }
  }

  String _extractSectionContent(String sectionTitle, String fullText) {
    try {
      // Escape special regex characters in title for exact match
      final escapedTitle = RegExp.escape(sectionTitle.trim());

      // Use regex to extract content from ## <sectionTitle> until next ##
      final pattern = RegExp(
        r'##\s*' + escapedTitle + r'\s*\n([\s\S]*?)(?=##\s*|$)',
        caseSensitive: false,
        dotAll: true,
      );

      final match = pattern.firstMatch(fullText);

      if (match == null || match.group(1)?.trim().isEmpty == true) {
        return 'Próximamente más recomendaciones';
      }

      return match
          .group(1)!
          .trim()
          // Remove any bullet markers at line starts but keep the dot
          .replaceAll(RegExp(r'^\s*•\s*', multiLine: true), '◦ ')
          .replaceAll(RegExp(r'\n{2,}'), '\n');
    } catch (e) {
      return 'Recomendaciones en desarrollo';
    }
  }
}
