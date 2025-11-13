import 'package:flutter/material.dart';

class AppGradients extends ThemeExtension<AppGradients> {
  final Gradient? background;
  const AppGradients({this.background});

  @override
  AppGradients copyWith({Gradient? background}) {
    return AppGradients(background: background ?? this.background);
  }

  @override
  ThemeExtension<AppGradients> lerp(ThemeExtension<AppGradients>? other, double t) {
    if (other is! AppGradients) return this;
    // Simple lerp: pick other when t > 0.5; customize if needed
    return t > 0.5 ? other : this;
  }
}

class GradientScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget? body;

  const GradientScaffold({super.key, this.appBar, this.body});

  @override
  Widget build(BuildContext context) {
    final gradients = Theme.of(context).extension<AppGradients>();
    final gradient = gradients?.background ??
        const LinearGradient(
          colors: [Colors.purple, Colors.orange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );

    return Scaffold(
      appBar: appBar,
      body: Container(
        decoration: BoxDecoration(gradient: gradient),
        child: body,
      ),
    );
  }
}


class MCQuestion {
  final Map<String, String> localizedText;
  final List<String> options;
  final int correctIndex;

  MCQuestion(this.localizedText, this.options, this.correctIndex);

  String getText(String lang) =>
      localizedText[lang] ?? localizedText['English']!;
}

class MultipleChoiceQuizPage extends StatefulWidget {
  final String selectedLanguage;
  const MultipleChoiceQuizPage({super.key, required this.selectedLanguage});

  @override
  State<MultipleChoiceQuizPage> createState() => _MultipleChoiceQuizPageState();
}

class _MultipleChoiceQuizPageState extends State<MultipleChoiceQuizPage> {
  late final List<MCQuestion> questions = [
    MCQuestion({
      'English': 'What is the capital of France?',
      'Afrikaans': 'Wat is die hoofstad van Frankryk?',
      'Zulu': 'Iyiphi inhlokodolobha yaseFrance?',
    }, ['Berlin', 'Paris', 'Rome'], 1),
    MCQuestion({
      'English': 'Which planet is known as the Red Planet?',
      'Afrikaans': 'Watter planeet staan bekend as die Rooi Planeet?',
      'Zulu': 'Iyiphi iplanethi eyaziwa ngokuthi iPlanethi Ebomvu?',
    }, ['Mars', 'Venus', 'Jupiter'], 0),
  ];

  int currentQuestion = 0;
  int score = 0;
  bool showResult = false;
  int? selectedIndex;

  void checkAnswer(int index) {
    setState(() {
      selectedIndex = index;
      if (index == questions[currentQuestion].correctIndex) score++;
      showResult = true;
    });
  }

  void nextQuestion() {
    setState(() {
      currentQuestion++;
      selectedIndex = null;
      showResult = false;
    });
  }

  void retryQuiz() {
    setState(() {
      currentQuestion = 0;
      score = 0;
      selectedIndex = null;
      showResult = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.selectedLanguage;

    // If you want to hard-limit to 2 rounds, slice questions or check currentQuestion >= 2
    final int totalRounds = 2;
    final bool finished = currentQuestion >= totalRounds;

    if (finished) {
      return GradientScaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Quiz Finished!\nScore: $score/$totalRounds',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: retryQuiz,
                child: const Text('Retry'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Back to Menu'),
              ),
            ],
          ),
        ),
      );
    }

    final question = questions[currentQuestion];
    return GradientScaffold(
      appBar: AppBar(title: const Text('Multiple Choice Quiz')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              question.getText(lang),
              style: const TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ...question.options.asMap().entries.map((entry) {
              final idx = entry.key;
              final option = entry.value;

              final isCorrect = idx == question.correctIndex;
              final isSelected = selectedIndex == idx;

              Color? bgColor;
              if (showResult && isSelected) {
                bgColor = isCorrect ? Colors.green : Colors.red;
              }

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: bgColor,
                  ),
                  onPressed: showResult ? null : () => checkAnswer(idx),
                  child: Text(option),
                ),
              );
            }),
            const SizedBox(height: 12),
            if (showResult)
              ElevatedButton(
                onPressed: nextQuestion,
                child: const Text('Next'),
              ),
          ],
        ),
      ),
    );
  }
}
