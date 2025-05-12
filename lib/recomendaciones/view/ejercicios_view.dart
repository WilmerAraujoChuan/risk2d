import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class EjerciciosScreen extends StatefulWidget {
  const EjerciciosScreen({super.key});

  @override
  _EjerciciosScreenState createState() => _EjerciciosScreenState();
}

class _EjerciciosScreenState extends State<EjerciciosScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  String _rutinaEjercicios = '';
  bool _isLoading = true;
  bool _hasError = false;
  double _progress = 0.0;
  String _currentStatus = "Analizando tus respuestas...";

  @override
  void initState() {
    super.initState();
    _loadRutinaEjercicios();
  }

  Future<void> _loadRutinaEjercicios() async {
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

      _updateProgress(0.5, "Generando rutina de ejercicios...");
      await Future.delayed(const Duration(milliseconds: 500));

      final prompt = '''
Contexto del usuario (${data['nivelRiesgo']}):
${construirPerfilUsuario(preguntas)}

Genera una rutina de ejercicios personalizada siguiendo ESTRICTAMENTE ESTE FORMATO:

## Lunes
• Ejercicio 1: [Descripción]
• Ejercicio 2: [Descripción]
• Ejercicio 3: [Descripción]

## Martes
• Ejercicio 1: [Descripción]
• Ejercicio 2: [Descripción]
• Ejercicio 3: [Descripción]

## Miércoles
• Ejercicio 1: [Descripción]
• Ejercicio 2: [Descripción]
• Ejercicio 3: [Descripción]

## Jueves
• Ejercicio 1: [Descripción]
• Ejercicio 2: [Descripción]
• Ejercicio 3: [Descripción]

## Viernes
• Ejercicio 1: [Descripción]
• Ejercicio 2: [Descripción]
• Ejercicio 3: [Descripción]

## Sábado
• Ejercicio 1: [Descripción]
• Ejercicio 2: [Descripción]
• Ejercicio 3: [Descripción]

## Domingo
• Ejercicio 1: [Descripción]
• Ejercicio 2: [Descripción]
• Ejercicio 3: [Descripción]

NO INCLUIR:
- Encabezados diferentes a los especificados
- Texto fuera de las secciones
- Viñetas diferentes a "•"
''';

      _updateProgress(0.7, "Generando con IA...");
      final model = GenerativeModel(
        model: 'gemini-2.0-flash',
        apiKey: 'AIzaSyAV13FIkcL91rLpj2Yswj-WLq9mpDF7ERQ',
        generationConfig: GenerationConfig(
          maxOutputTokens: 2000,
          temperature: 0.3,
          topP: 0.95,
        ),
        systemInstruction: Content.text('''
Eres un experto en fitness que genera rutinas de ejercicios personalizadas.
Formato requerido:
1. Usar exactamente 7 secciones para cada día de la semana
2. Cada sección debe contener 3 viñetas usando el carácter "•"
3. No usar markdown excepto los encabezados ##
4. Incluir descripciones relevantes para cada ejercicio
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
          _rutinaEjercicios =
              response.text ?? 'No se generó la rutina de ejercicios';
          _isLoading = false;
        });
        debugPrint('Respuesta cruda de Gemini:');
        debugPrint(_rutinaEjercicios); // Verificar estructura real
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
        title: const Text('Rutinas de Ejercicios Personalizadas'),
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
              onPressed: _loadRutinaEjercicios,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    return _buildRutinaContent();
  }

  Widget _buildRutinaContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection('Lunes', _rutinaEjercicios),
          _buildSection('Martes', _rutinaEjercicios),
          _buildSection('Miércoles', _rutinaEjercicios),
          _buildSection('Jueves', _rutinaEjercicios),
          _buildSection('Viernes', _rutinaEjercicios),
          _buildSection('Sábado', _rutinaEjercicios),
          _buildSection('Domingo', _rutinaEjercicios),
          _buildDisclaimer(),
        ],
      ),
    );
  }

  Widget _buildDisclaimer() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Text(
        'Esta rutina es personalizada según tus respuestas y debe '
        'ser validada por un profesional de fitness.',
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
              Icon(Icons.fitness_center, color: Colors.blue, size: 28),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue,
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

  String _extractSectionContent(String sectionTitle, String fullText) {
    try {
      final escapedTitle = RegExp.escape(sectionTitle.trim());
      final pattern = RegExp(
        r'##\s*' + escapedTitle + r'\s*\n([\s\S]*?)(?=##\s*|$)',
        caseSensitive: false,
        dotAll: true,
      );

      final match = pattern.firstMatch(fullText);

      if (match == null || match.group(1)?.trim().isEmpty == true) {
        return 'Próximamente más opciones';
      }

      return match
          .group(1)!
          .trim()
          .replaceAll(RegExp(r'^\s*•\s*', multiLine: true), '◦ ')
          .replaceAll(RegExp(r'\n{2,}'), '\n');
    } catch (e) {
      return 'Rutina en desarrollo';
    }
  }
}
