import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DiabetesRiskQuestionnaire extends StatefulWidget {
  const DiabetesRiskQuestionnaire({super.key});

  @override
  _DiabetesRiskQuestionnaireState createState() =>
      _DiabetesRiskQuestionnaireState();
}

class _DiabetesRiskQuestionnaireState extends State<DiabetesRiskQuestionnaire> {
  int _currentPage = 0;
  int _totalScore = 0;
  late DateTime _startTime;
  Duration _duration = Duration.zero;
  final PageController _pageController = PageController();
  List<Map<String, dynamic>> _respuestas = [];

  final List<Question> _questions = [
    Question(
      text: "1. Edad",
      answers: [
        Answer(text: "Menos de 40 años", points: 0),
        Answer(text: "40-49 años", points: 1),
        Answer(text: "50-59 años", points: 2),
        Answer(text: "60 años o más", points: 3),
      ],
    ),
    Question(
      text: "2. Índice de Masa Corporal (IMC)",
      answers: [
        Answer(text: "Menos de 25 kg/m²", points: 0),
        Answer(text: "25-30 kg/m²", points: 1),
        Answer(text: "Más de 30 kg/m²", points: 3),
      ],
    ),
    Question(
      text: "3. Perímetro de cintura (medido a la altura del ombligo)",
      answers: [
        Answer(text: "Menos de 80 cm", points: 0),
        Answer(text: "80-88 cm", points: 3),
        Answer(text: "Más de 88 cm", points: 4),
      ],
    ),
    Question(
      text: "4. ¿Realiza al menos 30 minutos de actividad física diaria?",
      answers: [Answer(text: "Sí", points: 0), Answer(text: "No", points: 2)],
    ),
    Question(
      text: "5. ¿Consume frutas y verduras todos los días?",
      answers: [Answer(text: "Sí", points: 0), Answer(text: "No", points: 1)],
    ),
    Question(
      text: "6. ¿Toma medicamentos para la presión arterial?",
      answers: [Answer(text: "No", points: 0), Answer(text: "Sí", points: 2)],
    ),
    Question(
      text: "7. ¿Le han encontrado niveles altos de glucosa en sangre?",
      answers: [Answer(text: "No", points: 0), Answer(text: "Sí", points: 5)],
    ),
    Question(
      text: "8. ¿Tiene familiares con diabetes tipo 1 o 2?",
      answers: [
        Answer(text: "No", points: 0),
        Answer(text: "Abuelos, tíos, primos", points: 3),
        Answer(text: "Padres, hermanos o hijos", points: 5),
      ],
    ),
    Question(
      text: "9. ¿Ha tenido diabetes gestacional en algún embarazo?",
      answers: [Answer(text: "No", points: 0), Answer(text: "Sí", points: 3)],
    ),
    Question(
      text: "10. ¿Le han diagnosticado síndrome de ovario poliquístico (SOP)?",
      answers: [Answer(text: "No", points: 0), Answer(text: "Sí", points: 2)],
    ),
    Question(
      text: "11. ¿Con qué frecuencia consume bebidas alcohólicas?",
      answers: [
        Answer(text: "Nunca", points: 0),
        Answer(text: "Ocasionalmente (menos de 1 vez/semana)", points: 1),
        Answer(text: "Regularmente (1+ veces/semana)", points: 2),
        Answer(text: "Frecuentemente (diariamente)", points: 3),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _respuestas = List.generate(_questions.length, (index) => {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          children: [
            _buildProgressIndicator(),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _questions.length,
                itemBuilder: (context, index) {
                  return _buildQuestionPage(_questions[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        "Evaluación de Riesgo de Diabetes Tipo 2",
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      centerTitle: true,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Column(
        children: [
          LinearProgressIndicator(
            value: (_currentPage + 1) / _questions.length,
            minHeight: 8,
            borderRadius: BorderRadius.circular(10),
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Pregunta ${_currentPage + 1} de ${_questions.length}',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionPage(Question question) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              question.text,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          const SizedBox(height: 25),
          Expanded(
            child: ListView.separated(
              itemCount: question.answers.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                return _buildAnswerTile(question.answers[index]);
              },
            ),
          ),
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildAnswerTile(Answer answer) {
    return Material(
      borderRadius: BorderRadius.circular(10),
      color: Colors.white,
      elevation: 1,
      child: RadioListTile<int>(
        title: Text(
          answer.text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        value: answer.points,
        groupValue: null,
        toggleable: true,
        activeColor: Theme.of(context).primaryColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        tileColor: Colors.white,
        selectedTileColor: Theme.of(context).primaryColor.withOpacity(0.1),
        onChanged: (value) {
          setState(() {
            _totalScore += value!;
            _respuestas[_currentPage] = {
              'pregunta': _questions[_currentPage].text,
              'respuesta': answer.text,
              'puntos': answer.points,
            };
            _handleNavigation();
          });
        },
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentPage > 0)
            OutlinedButton.icon(
              icon: const Icon(Icons.arrow_back_rounded, size: 20),
              label: const Text("Atrás"),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey[700],
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 15,
                ),
                side: BorderSide(color: Colors.grey[300]!),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: _previousQuestion,
            ),
          if (_currentPage < _questions.length - 1)
            ElevatedButton.icon(
              icon: const Icon(Icons.arrow_forward_rounded, size: 20),
              label: const Text("Siguiente"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 15,
                ),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: _nextQuestion,
            ),
          if (_currentPage == _questions.length - 1)
            ElevatedButton.icon(
              icon: const Icon(Icons.task_alt_rounded),
              label: const Text("Ver Resultados"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: _showResults,
            ),
        ],
      ),
    );
  }

  void _handleNavigation() {
    if (_currentPage < _questions.length - 1) {
      _nextQuestion();
    } else {
      _showResults();
    }
  }

  void _nextQuestion() {
    if (_currentPage < _questions.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentPage++);
    }
  }

  void _previousQuestion() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentPage--);
    }
  }

  void _showResults() {
    final endTime = DateTime.now();
    _duration = endTime.difference(_startTime);
    final user = FirebaseAuth.instance.currentUser;

    try {
      FirebaseFirestore.instance.collection('cuestionarios').add({
        'userId': user?.uid,
        'fecha': FieldValue.serverTimestamp(),
        'duracionSegundos': _duration.inSeconds,
        'puntajeTotal': _totalScore,
        'preguntas': _respuestas,
        'nivelRiesgo': _calculateRisk(),
      });
    } catch (e) {
      print('Error guardando cuestionario: $e');
    }

    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              padding: const EdgeInsets.all(25),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.medical_services_rounded,
                    size: 50,
                    color: _getRiskColor(),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _calculateRisk(),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: _getRiskColor(),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 15),
                  Text(
                    "Puntuación total: $_totalScore",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Tiempo de respuesta: ${_formatDuration(_duration)}",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _getRiskColor(),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: const Text("Entendido"),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes minutos $seconds segundos";
  }

  String _calculateRisk() {
    if (_totalScore <= 10) return "Bajo riesgo de diabetes tipo 2";
    if (_totalScore <= 20) return "Riesgo moderado de diabetes tipo 2";
    return "Alto riesgo de diabetes tipo 2\nConsulte a un especialista";
  }

  Color _getRiskColor() {
    if (_totalScore <= 10) return Colors.green;
    if (_totalScore <= 20) return Colors.orange;
    return Colors.red;
  }
}

class Question {
  final String text;
  final List<Answer> answers;

  Question({required this.text, required this.answers});
}

class Answer {
  final String text;
  final int points;

  Answer({required this.text, required this.points});
}
