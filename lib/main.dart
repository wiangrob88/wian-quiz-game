import 'package:flutter/material.dart';

flutter config --enable-web
flutter devices

void main() => runApp(const ImageQuizApp());

class ImageQuizApp extends StatelessWidget {
  const ImageQuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Quiz',
      home: const LanguagePage(),
    );
  }
}

// ---------------- TRANSLATIONS ----------------
const supportedLanguages = ['English', 'Afrikaans', 'Zulu'];

const translations = {
  'English': {
    'menu_title': 'Image Quiz Menu',
    'welcome': 'Welcome to Image Quiz!',
    'instruction': 'Tap Start to begin the quiz.\nIdentify the correct image!',
    'start': 'Start Game',
    'next': 'Next',
    'retry': 'Retry',
    'back': 'Back to Menu',
    'finished': 'Quiz Finished!',
    'score': 'Score',
    'correct': 'Correct!',
    'wrong': 'Wrong!',
  },
  'Afrikaans': {
    'menu_title': 'Beeldvasvra Kieslys',
    'welcome': 'Welkom by Beeldvasvra!',
    'instruction': 'Tik Begin om te begin.\nIdentifiseer die regte prent!',
    'start': 'Begin Speletjie',
    'next': 'Volgende',
    'retry': 'Probeer Weer',
    'back': 'Terug na Kieslys',
    'finished': 'Vasvra Klaar!',
    'score': 'Punte',
    'correct': 'Reg!',
    'wrong': 'Verkeerd!',
  },
  'Zulu': {
    'menu_title': 'Imenyu Yombuzo Wezithombe',
    'welcome': 'Wamukelekile kuMbuzo Wezithombe!',
    'instruction': 'Cofa Qala ukuze uqale.\nKhetha isithombe esifanele!',
    'start': 'Qala Umdlalo',
    'next': 'Okulandelayo',
    'retry': 'Phinda',
    'back': 'Buyela Kumenyu',
    'finished': 'Umbuzo usuqediwe!',
    'score': 'Amaphuzu',
    'correct': 'Kulungile!',
    'wrong': 'Akulungile!',
  },
};

String tr(String lang, String key) {
  // Try the requested language, then English, then a placeholder
  return translations[lang]?[key] ??
         translations['English']?[key] ??
         '[$key]';
}

// ---------------- LANGUAGE PAGE ----------------
class LanguagePage extends StatelessWidget {
  const LanguagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose Language')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: supportedLanguages.map((lang) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MenuPage(selectedLanguage: lang),
                    ),
                  );
                },
                child: Text(lang),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ---------------- MENU PAGE ----------------
class MenuPage extends StatelessWidget {
  final String selectedLanguage;
  const MenuPage({super.key, required this.selectedLanguage});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tr(selectedLanguage, 'menu_title'))),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(tr(selectedLanguage, 'welcome'),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Text(tr(selectedLanguage, 'instruction'),
                textAlign: TextAlign.center),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        QuizPage(selectedLanguage: selectedLanguage),
                  ),
                );
              },
              child: Text(tr(selectedLanguage, 'start')),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- QUESTION MODEL ----------------
class Question {
  final Map<String, String> localizedText;
  final List<String> imagePaths;
  final int correctIndex;

  Question(this.localizedText, this.imagePaths, this.correctIndex);

  String getText(String lang) =>
      localizedText[lang] ?? localizedText['English']!;
}

// ---------------- QUIZ PAGE ----------------
class QuizPage extends StatefulWidget {
  final String selectedLanguage;
  const QuizPage({super.key, required this.selectedLanguage});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  late final List<Question> questions = [
    Question({
      'English': 'Choose the Apple!',
      'Afrikaans': 'Kies die Appel!',
      'Zulu': 'Khetha i-Apple!',
    }, [
      'assets/images/apple.jpg',
      'assets/images/banana.jpg',
      'assets/images/orange.jpg',
      'assets/images/grape.jpg',
    ], 0),
    Question({
      'English': 'Choose the Banana!',
      'Afrikaans': 'Kies die Piesang!',
      'Zulu': 'Khetha iBanana!',
    }, [
      'assets/images/grape.jpg',
      'assets/images/banana.jpg',
      'assets/images/orange.jpg',
      'assets/images/apple.jpg',
    ], 1),
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

    if (currentQuestion >= questions.length) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('${tr(lang, 'finished')}\n${tr(lang, 'score')}: $score/${questions.length}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: retryQuiz, child: Text(tr(lang, 'retry'))),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text(tr(lang, 'back')),
              ),
            ],
          ),
        ),
      );
    }

    final question = questions[currentQuestion];

    return Scaffold(
      appBar: AppBar(title: Text(tr(lang, 'quiz_title'))),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(question.getText(lang),
                style: const TextStyle(fontSize: 20),
                textAlign: TextAlign.center),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                itemCount: question.imagePaths.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1,
                ),
                itemBuilder: (context, index) {
                  final isSelected = selectedIndex == index;
                  final isCorrect = index == question.correctIndex;
                  Color borderColor = Colors.transparent;
                  if (showResult && isSelected) {
                    borderColor = isCorrect ? Colors.green : Colors.red;
                  }
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: showResult ? null : () => checkAnswer(index),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: borderColor, width: 4),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Image.asset(question.imagePaths[index],
                            fit: BoxFit.cover),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (showResult) ...[
              const SizedBox(height: 20),
              Text(
                selectedIndex == question.correctIndex
                    ? tr(lang, 'correct')
                    : tr(lang, 'wrong'),
                style: TextStyle(
                  fontSize: 18,
                  color: selectedIndex == question.correctIndex
                      ? Colors.green
                      : Colors.red,
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: nextQuestion,
                child: Text(tr(lang, 'next')),
              ),
            ]
          ],
        ),
      ),
    );
  }


}
