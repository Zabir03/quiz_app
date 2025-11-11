import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:math'; // Imported for the random quiz feature

// --- MODELS ---
// Defines the data structure for a single multiple-choice question
class Question {
  final String text;
  final List<String> options;
  final int correctAnswerIndex;

  const Question({
    required this.text,
    required this.options,
    required this.correctAnswerIndex,
  });
}

// Defines the data structure for a quiz topic
class QuizTopic {
  final String id;
  final String name;
  final IconData icon;
  final List<Question> questions;

  const QuizTopic({
    required this.id,
    required this.name,
    required this.icon,
    required this.questions,
  });
}

// --- DATA (EXPANDED) ---
// Mock data for the quiz topics.
final List<QuizTopic> quizTopics = [
  QuizTopic(
    id: "cpp",
    name: "C++",
    icon: Icons.code,
    questions: [
      Question(
        text: "What is the size of an `int` in C++?",
        options: ["2 bytes", "4 bytes", "Depends on the compiler/architecture", "8 bytes"],
        correctAnswerIndex: 2,
      ),
      Question(
        text: "Which of the following correctly declares a pointer to an integer?",
        options: ["int *p;", "int p*;", "p<int>;", "pointer int p;"],
        correctAnswerIndex: 0,
      ),
      Question(
        text: "What is 'cout' in C++?",
        options: ["A class", "An object", "A function", "A header file"],
        correctAnswerIndex: 1,
      ),
      Question(
        text: "What is the purpose of the `virtual` keyword?",
        options: ["To create a virtual machine", "To enable dynamic polymorphism", "To declare a variable", "To make a function obsolete"],
        correctAnswerIndex: 1,
      ),
      Question(
        text: "What is a 'reference' in C++?",
        options: ["A copy of a variable", "A pointer to a variable", "An alias for an existing variable", "A variable that holds a memory address"],
        correctAnswerIndex: 2,
      ),
      Question(
        text: "What is a constructor in C++?",
        options: ["A function to destroy an object", "A special method to initialize an object", "A method to copy an object", "A type of loop"],
        correctAnswerIndex: 1,
      ),
      Question(
        text: "Which C++ keyword is used to handle exceptions?",
        options: ["try/catch", "if/else", "do/while", "throw/except"],
        correctAnswerIndex: 0,
      ),
    ],
  ),
  QuizTopic(
    id: "oop",
    name: "OOP Concepts",
    icon: Icons.layers,
    questions: [
      Question(
        text: "Which of the following is NOT a pillar of OOP?",
        options: ["Encapsulation", "Inheritance", "Polymorphism", "Compilation"],
        correctAnswerIndex: 3,
      ),
      Question(
        text: "What is 'Encapsulation'?",
        options: ["Hiding complexity", "Bundling data and methods", "Creating child classes", "Reusing code"],
        correctAnswerIndex: 1,
      ),
      Question(
        text: "Which concept allows a class to have multiple methods with the same name but different parameters?",
        options: ["Method Overriding", "Method Overloading", "Inheritance", "Abstraction"],
        correctAnswerIndex: 1,
      ),
      Question(
        text: "What is 'Abstraction' in OOP?",
        options: ["Hiding the implementation details", "Creating a new class from an existing one", "The ability to take many forms", "Bundling data and methods"],
        correctAnswerIndex: 0,
      ),
      Question(
        text: "Method Overriding is an example of...?",
        options: ["Static Polymorphism", "Runtime Polymorphism", "Encapsulation", "Abstraction"],
        correctAnswerIndex: 1,
      ),
    ],
  ),
  QuizTopic(
    id: "dsa",
    name: "Data Structures",
    icon: Icons.account_tree,
    questions: [
      Question(
        text: "Which data structure uses LIFO (Last-In, First-Out)?",
        options: ["Queue", "Stack", "Array", "Linked List"],
        correctAnswerIndex: 1,
      ),
      Question(
        text: "What is the time complexity of searching in a balanced Binary Search Tree (BST)?",
        options: ["O(n)", "O(log n)", "O(n^2)", "O(1)"],
        correctAnswerIndex: 1,
      ),
      Question(
        text: "Which data structure is ideal for implementing a priority queue?",
        options: ["Stack", "Linked List", "Heap", "Array"],
        correctAnswerIndex: 2,
      ),
      Question(
        text: "What does 'FIFO' stand for?",
        options: ["First-In, First-Out", "Fast-In, Fast-Out", "First-Input, First-Output", "False-In, True-Out"],
        correctAnswerIndex: 0,
      ),
      Question(
        text: "What data structure is used to represent a network or connections?",
        options: ["Tree", "Array", "Graph", "Stack"],
        correctAnswerIndex: 2,
      ),
      Question(
        text: "What is the main advantage of a Hash Table?",
        options: ["Guaranteed O(1) time complexity", "Fast average-case insertion, deletion, and search", "Data is always sorted", "Uses very little memory"],
        correctAnswerIndex: 1,
      ),
    ],
  ),
  QuizTopic(
    id: "algorithms",
    name: "Algorithms",
    icon: Icons.mediation,
    questions: [
      Question(
        text: "Which sorting algorithm has the worst-case time complexity of O(n^2)?",
        options: ["Merge Sort", "Quick Sort (with bad pivot)", "Bubble Sort", "Both 2 and 3"],
        correctAnswerIndex: 3,
      ),
      Question(
        text: "What is Dijkstra's algorithm used for?",
        options: ["Sorting", "Searching", "Finding the shortest path", "Graph traversal"],
        correctAnswerIndex: 2,
      ),
      Question(
        text: "What is a 'greedy' algorithm?",
        options: ["An algorithm that uses a lot of memory", "An algorithm that makes the locally optimal choice at each step", "An algorithm that is very slow", "An algorithm that always finds the best solution"],
        correctAnswerIndex: 1,
      ),
      Question(
        text: "What does Big O notation (O(n)) represent?",
        options: ["The best-case time complexity", "The exact time taken", "The average-case time complexity", "The upper bound (worst-case) time complexity"],
        correctAnswerIndex: 3,
      ),
      Question(
        text: "Merge Sort is an example of which algorithm paradigm?",
        options: ["Greedy", "Dynamic Programming", "Divide and Conquer", "Brute Force"],
        correctAnswerIndex: 2,
      ),
    ],
  ),
];

// --- SERVICES (UPDATED) ---
// Service to handle saving and retrieving high scores and overall stats.
class ScoreService {
  // --- High Score Logic ---

  /// Saves the high score for a specific topic.
  /// Returns `true` if a new high score was set, `false` otherwise.
  static Future<bool> saveHighScore(String topicId, int score) async {
    final prefs = await SharedPreferences.getInstance();
    final currentHighScore = await getHighScore(topicId);
    if (score > currentHighScore) {
      await prefs.setInt('highScore_$topicId', score);
      return true; // New high score!
    }
    return false; // Not a new high score.
  }

  /// Retrieves the high score for a specific topic.
  static Future<int> getHighScore(String topicId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('highScore_$topicId') ?? 0;
  }

  // --- Overall Stats Logic (NEW) ---

  /// Saves the result of a completed quiz to track overall stats.
  static Future<void> saveQuizResult(String topicId, int score, int totalQuestions) async {
    final prefs = await SharedPreferences.getInstance();

    // Update total quizzes taken
    final int totalQuizzes = (prefs.getInt('stats_totalQuizzes') ?? 0) + 1;
    await prefs.setInt('stats_totalQuizzes', totalQuizzes);

    // Update total score
    final int totalScore = (prefs.getInt('stats_totalScore') ?? 0) + score;
    await prefs.setInt('stats_totalScore', totalScore);

    // Update total questions
    final int totalAttempted = (prefs.getInt('stats_totalAttempted') ?? 0) + totalQuestions;
    await prefs.setInt('stats_totalAttempted', totalAttempted);

    // Update mastered topics
    if (score == totalQuestions) {
      final mastered = (prefs.getStringList('stats_masteredTopics') ?? []).toSet();
      mastered.add(topicId);
      await prefs.setStringList('stats_masteredTopics', mastered.toList());
    }
  }

  /// Retrieves the calculated overall stats.
  static Future<Map<String, dynamic>> getOverallStats() async {
    final prefs = await SharedPreferences.getInstance();

    final int totalQuizzes = prefs.getInt('stats_totalQuizzes') ?? 0;
    final int totalScore = prefs.getInt('stats_totalScore') ?? 0;
    final int totalAttempted = prefs.getInt('stats_totalAttempted') ?? 0;
    final int topicsMastered = (prefs.getStringList('stats_masteredTopics') ?? []).length;

    double averagePercentage = 0.0;
    if (totalAttempted > 0) {
      averagePercentage = (totalScore / totalAttempted) * 100;
    }

    return {
      'totalQuizzes': totalQuizzes,
      'averagePercentage': averagePercentage,
      'topicsMastered': topicsMastered,
    };
  }
}

// --- PROVIDERS ---
// Manages the app's theme (light/dark mode)
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}

// --- MAIN ENTRY POINT ---
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const QuizApp(),
    ),
  );
}

// --- APP ROOT ---
class QuizApp extends StatelessWidget {
  const QuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Flutter Quiz App',
      debugShowCheckedModeBanner: false, // Hides the debug banner
      // Define light theme
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // Define dark theme
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      themeMode: themeProvider.themeMode,
      // Define named routes for navigation
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/quiz': (context) => const QuizScreen(),
        '/results': (context) => const ResultsScreen(),
      },
    );
  }
}

// --- SCREENS ---

// 1. Home Screen (Topic Selection) - UPDATED
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final random = Random(); // For the random quiz button

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Quiz App'),
        actions: [
          // Theme toggle switch
          Switch.adaptive(
            value: themeProvider.isDarkMode,
            onChanged: (value) {
              themeProvider.toggleTheme(value);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Welcome Message ---
            Text(
              'Welcome, Quiz Taker!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ready to test your knowledge?',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
            ),
            const SizedBox(height: 24),

            // --- NEW: Statistics Card ---
            const StatisticsCard(),
            const SizedBox(height: 24),

            // --- Random Quiz Button ---
            ElevatedButton.icon(
              icon: const Icon(Icons.shuffle),
              label: const Text('Start a Random Quiz'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
              ),
              onPressed: () {
                // Get a random topic and start the quiz
                final randomTopic = quizTopics[random.nextInt(quizTopics.length)];
                Navigator.pushNamed(context, '/quiz', arguments: randomTopic);
              },
            ),
            const SizedBox(height: 24),

            // --- Topic Grid ---
            Text(
              'All Topics',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                childAspectRatio: 0.9,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: quizTopics.length,
              itemBuilder: (context, index) {
                final topic = quizTopics[index];
                return TopicCard(topic: topic);
              },
            ),
          ],
        ),
      ),
    );
  }
}

// 2. Quiz Screen (Question & Answers)
class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestionIndex = 0;
  int _score = 0;
  int? _selectedOptionIndex;
  bool _isAnswered = false;

  void _handleAnswer(int selectedIndex, QuizTopic topic) {
    if (_isAnswered) return;

    final question = topic.questions[_currentQuestionIndex];
    setState(() {
      _isAnswered = true;
      _selectedOptionIndex = selectedIndex;
      if (selectedIndex == question.correctAnswerIndex) {
        _score++;
      }
    });

    // Wait for 1.5 seconds before moving to the next question or results
    Future.delayed(const Duration(milliseconds: 1500), () async {
      if (_currentQuestionIndex < topic.questions.length - 1) {
        // More questions available
        setState(() {
          _currentQuestionIndex++;
          _selectedOptionIndex = null; // Reset selection
          _isAnswered = false;
        });
      } else {
        // End of the quiz
        // Save overall stats and high score
        await ScoreService.saveQuizResult(topic.id, _score, topic.questions.length);
        final bool isNewHighScore = await ScoreService.saveHighScore(topic.id, _score);
        final bool isTopicMastered = _score == topic.questions.length;

        // Navigate to results screen, passing the results
        if (mounted) { // Check if the widget is still in the tree
          Navigator.pushReplacementNamed(
            context,
            '/results',
            arguments: {
              'score': _score,
              'totalQuestions': topic.questions.length,
              'topic': topic,
              'isNewHighScore': isNewHighScore, // NEW
              'isTopicMastered': isTopicMastered, // NEW
            },
          );
        }
      }
    });
  }

  // Determines the color for an option based on its state
  Color _getColorForOption(Question question, int optionIndex) {
    if (!_isAnswered) {
      // Not yet answered
      return _selectedOptionIndex == optionIndex
          ? Theme.of(context).colorScheme.primaryContainer
          : Theme.of(context).colorScheme.surfaceVariant;
    }

    // Answered
    if (optionIndex == question.correctAnswerIndex) {
      // This is the correct answer
      return Colors.green.withOpacity(0.3);
    } else if (_selectedOptionIndex == optionIndex) {
      // This is the (wrong) selected answer
      return Colors.red.withOpacity(0.3);
    } else {
      // This is another wrong, unselected option
      return Theme.of(context).colorScheme.surfaceVariant;
    }
  }

  // Determines the icon for an option based on its state
  Icon? _getIconForOption(Question question, int optionIndex) {
    if (!_isAnswered) {
      return null;
    }

    if (optionIndex == question.correctAnswerIndex) {
      return const Icon(Icons.check_circle, color: Colors.green);
    } else if (_selectedOptionIndex == optionIndex) {
      return const Icon(Icons.cancel, color: Colors.red);
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Retrieve the topic passed from the HomeScreen
    final topic = ModalRoute.of(context)!.settings.arguments as QuizTopic;
    final question = topic.questions[_currentQuestionIndex];
    final progress = (_currentQuestionIndex + 1) / topic.questions.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(topic.name),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          // Progress bar
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
            valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Question counter
            Text(
              'Question ${_currentQuestionIndex + 1} of ${topic.questions.length}',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            // Question text
            Text(
              question.text,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            // Options list
            ...List.generate(question.options.length, (index) {
              return OptionCard(
                optionText: question.options[index],
                color: _getColorForOption(question, index),
                icon: _getIconForOption(question, index),
                onTap: () => _handleAnswer(index, topic),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// 3. Results Screen (UPDATED)
class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Retrieve the arguments passed from the QuizScreen
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final int score = args['score'];
    final int totalQuestions = args['totalQuestions'];
    final QuizTopic topic = args['topic'];
    final bool isNewHighScore = args['isNewHighScore'] ?? false;
    final bool isTopicMastered = args['isTopicMastered'] ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Results'),
        automaticallyImplyLeading: false, // Remove back button
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Quiz Complete!',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 20),
              
              // --- NEW: Badges ---
              if (isTopicMastered)
                const ResultBadge(
                  text: '🏆 Topic Mastered!',
                  color: Colors.amber,
                ),
              if (!isTopicMastered && isNewHighScore)
                const ResultBadge(
                  text: '🎉 New High Score!',
                  color: Colors.green,
                ),

              const SizedBox(height: 20),
              Text(
                'Your Score',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text(
                '$score / $totalQuestions',
                style: Theme.of(context)
                    .textTheme
                    .displayLarge
                    ?.copyWith(color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(height: 20),
              // Use a FutureBuilder to display the high score
              FutureBuilder<int>(
                future: ScoreService.getHighScore(topic.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  final highScore = snapshot.data ?? 0;
                  return Text(
                    'High Score: $highScore',
                    style: Theme.of(context).textTheme.titleMedium,
                  );
                },
              ),
              const SizedBox(height: 40),
              // 'Play Again' button
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Play Again'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () {
                  // Go back to the quiz screen for the same topic
                  Navigator.pushReplacementNamed(
                    context,
                    '/quiz',
                    arguments: topic,
                  );
                },
              ),
              const SizedBox(height: 10),
              // 'Go Home' button
              TextButton.icon(
                icon: const Icon(Icons.home),
                label: const Text('Back to Home'),
                style: TextButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () {
                  // Go back to the home screen
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- WIDGETS ---

// NEW: Widget for the Statistics Card on the Home Screen
class StatisticsCard extends StatelessWidget {
  const StatisticsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<Map<String, dynamic>>(
          future: ScoreService.getOverallStats(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text('Error loading stats'));
            }

            final stats = snapshot.data ?? {};
            final int totalQuizzes = stats['totalQuizzes'] ?? 0;
            final double avgPercentage = stats['averagePercentage'] ?? 0.0;
            final int topicsMastered = stats['topicsMastered'] ?? 0;

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                StatItem(
                  icon: Icons.done_all,
                  value: totalQuizzes.toString(),
                  label: 'Quizzes Taken',
                ),
                StatItem(
                  icon: Icons.trending_up,
                  value: '${avgPercentage.toStringAsFixed(0)}%',
                  label: 'Average Score',
                ),
                StatItem(
                  icon: Icons.star,
                  value: topicsMastered.toString(),
                  label: 'Topics Mastered',
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// NEW: Helper widget for an item in the StatisticsCard
class StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const StatItem({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 28, color: Theme.of(context).colorScheme.onPrimaryContainer),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
      ],
    );
  }
}

// NEW: Helper widget for the badges on the ResultsScreen
class ResultBadge extends StatelessWidget {
  final String text;
  final Color color;
  const ResultBadge({super.key, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 2),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}

// Custom widget for the topic selection cards on the Home Screen
class TopicCard extends StatelessWidget {
  final QuizTopic topic;

  const TopicCard({super.key, required this.topic});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: InkWell(
        onTap: () {
          // Navigate to the quiz screen for the selected topic
          Navigator.pushNamed(context, '/quiz', arguments: topic);
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                topic.icon,
                size: 40,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 10),
              Text(
                topic.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(), // Pushes the score to the bottom
              
              // --- High Score Display ---
              FutureBuilder<int>(
                future: ScoreService.getHighScore(topic.id),
                builder: (context, snapshot) {
                  Widget scoreDisplay;
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    scoreDisplay = const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    );
                  } else if (snapshot.hasError) {
                    scoreDisplay = const Icon(Icons.error_outline, size: 20, color: Colors.red);
                  } else {
                    final highScore = snapshot.data ?? 0;
                    final totalQuestions = topic.questions.length;
                    scoreDisplay = Text(
                      'Best: $highScore / $totalQuestions',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                    );
                  }
                  // Sized box to prevent layout shift
                  return SizedBox(height: 20, child: Center(child: scoreDisplay));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom widget for the answer options on the Quiz Screen
class OptionCard extends StatelessWidget {
  final String optionText;
  final Color color;
  final Icon? icon;
  final VoidCallback onTap;

  const OptionCard({
    super.key,
    required this.optionText,
    required this.color,
    this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: ListTile(
            title: Text(optionText),
            trailing: icon,
          ),
        ),
      ),
    );
  }
}