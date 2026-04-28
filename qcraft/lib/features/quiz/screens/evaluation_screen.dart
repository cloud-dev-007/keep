import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qcraft/core/model/quiz_attempt_model.dart';
import 'package:qcraft/core/model/quiz_model.dart';
import 'package:qcraft/core/model/quiz_setup_model.dart';
import 'package:qcraft/features/quiz/bloc/quiz_bloc.dart';
import 'package:qcraft/features/quiz/screens/quiz_home_screen.dart';

import '../../../injection_container.dart';
import '../bloc/quiz_event.dart';
import '../bloc/quiz_state.dart';

class EvaluationScreen extends StatelessWidget {
  final QuizAttemptModel evaluation;
  final QuizModel quiz;

  const EvaluationScreen(
      {super.key, required this.evaluation, required this.quiz});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<QuizBloc>.value(
      value: sl<QuizBloc>(),
      child: BlocListener<QuizBloc, QuizState>(
        listener: (stateA, stateB) {
          if (stateB is QuizGenerated) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => QuizHomeScreen(
                  stateB.quiz,
                ),
              ),
            );
          }

          if (stateB is QuizCreated) {
            sl<QuizBloc>().add(GenerateQuiz(stateB.id, attempt: evaluation));
          }
        },
        child: Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            title: const Text(
              "Quiz Evaluation",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            elevation: 0,
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quiz Title Card
                  QuizTitleCard(
                    evaluation: evaluation,
                    quiz: quiz,
                  ),
                  const SizedBox(height: 16),

                  // Performance Overview
                  PerformanceCard(evaluation: evaluation),
                  const SizedBox(height: 16),

                  // Question Breakdown
                  QuestionBreakdownCard(evaluation: evaluation),
                  const SizedBox(height: 16),

                  // Weak Topics
                  WeakTopicsCard(evaluation: evaluation),
                  const SizedBox(height: 16),

                  // AI Analysis
                  AnalysisCard(evaluation: evaluation),
                  const SizedBox(height: 24),
                  // Action Buttons
                  ActionButtons(
                    onPressed: () {
                      sl<QuizBloc>().add(CreateQuiz(
                        setupModel: QuizSetupModel(
                          documentIds:
                              quiz.documents?.map((doc) => doc.id!).toList(),
                          questions: quiz.noOfQuestions,
                          difficulty: 2,
                          duration: quiz.duration,
                          type: quiz.type,
                        ),
                      ));
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class QuizTitleCard extends StatelessWidget {
  final QuizAttemptModel evaluation;
  final QuizModel quiz;

  const QuizTitleCard(
      {super.key, required this.evaluation, required this.quiz});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              quiz.title!,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                InfoChip(
                  icon: Icons.quiz_outlined,
                  label: "${quiz.noOfQuestions} Questions",
                  color: Colors.blue,
                ),
                const SizedBox(width: 8),
                InfoChip(
                  icon: Icons.access_time,
                  label: "${evaluation.timeTaken} min",
                  color: Colors.orange,
                ),
                const SizedBox(width: 8),
                InfoChip(
                  icon: Icons.bar_chart,
                  label: "Level ${evaluation.difficulty}",
                  color: Colors.purple,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class PerformanceCard extends StatelessWidget {
  final QuizAttemptModel evaluation;

  const PerformanceCard({super.key, required this.evaluation});

  @override
  Widget build(BuildContext context) {
    final accuracy = evaluation.accuracy!;
    final correctAnswers =
        evaluation.attempts?.where((attempt) => attempt.correct!).length;
    final totalQuestions = evaluation.attempts!.length;

    Color accuracyColor;
    String performanceText;
    IconData performanceIcon;

    if (accuracy >= 80) {
      accuracyColor = Colors.green;
      performanceText = "Excellent";
      performanceIcon = Icons.emoji_events;
    } else if (accuracy >= 60) {
      accuracyColor = Colors.orange;
      performanceText = "Good";
      performanceIcon = Icons.thumb_up;
    } else {
      accuracyColor = Colors.red;
      performanceText = "Needs Improvement";
      performanceIcon = Icons.trending_up;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(performanceIcon, color: accuracyColor, size: 28),
                const SizedBox(width: 8),
                Text(
                  performanceText,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: accuracyColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                StatColumn(
                  title: "Score",
                  value: "$accuracy%",
                  color: accuracyColor,
                ),
                StatColumn(
                  title: "Correct",
                  value: "$correctAnswers/$totalQuestions",
                  color: Colors.green,
                ),
                StatColumn(
                  title: "Time",
                  value: "${evaluation.timeTaken}m",
                  color: Colors.blue,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class QuestionBreakdownCard extends StatelessWidget {
  final QuizAttemptModel evaluation;

  const QuestionBreakdownCard({super.key, required this.evaluation});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Question Breakdown",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            ...evaluation.attempts!.asMap().entries.map((entry) {
              final index = entry.key + 1;
              final attempt = entry.value;
              return QuestionItem(
                questionNumber: index,
                isCorrect: attempt.correct!,
              );
            }),
          ],
        ),
      ),
    );
  }
}

class QuestionItem extends StatelessWidget {
  final int questionNumber;
  final bool isCorrect;

  const QuestionItem({
    super.key,
    required this.questionNumber,
    required this.isCorrect,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isCorrect ? Colors.green.shade100 : Colors.red.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              isCorrect ? Icons.check : Icons.close,
              color: isCorrect ? Colors.green : Colors.red,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            "Question $questionNumber",
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            isCorrect ? "Correct" : "Incorrect",
            style: TextStyle(
              fontSize: 12,
              color: isCorrect ? Colors.green : Colors.red,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class WeakTopicsCard extends StatelessWidget {
  final QuizAttemptModel evaluation;

  const WeakTopicsCard({super.key, required this.evaluation});

  @override
  Widget build(BuildContext context) {
    if (evaluation.weakTopics!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.lightbulb_outline, color: Colors.amber, size: 20),
                SizedBox(width: 8),
                Text(
                  "Areas for Improvement",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: evaluation.weakTopics!.map((topic) {
                return WeakTopicChip(topic: topic);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class WeakTopicChip extends StatelessWidget {
  final String topic;

  const WeakTopicChip({super.key, required this.topic});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Text(
        topic,
        style: TextStyle(
          fontSize: 12,
          color: Colors.amber.shade800,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class AnalysisCard extends StatelessWidget {
  final QuizAttemptModel evaluation;

  const AnalysisCard({super.key, required this.evaluation});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.psychology, color: Colors.deepPurple, size: 20),
                SizedBox(width: 8),
                Text(
                  "AI Analysis & Recommendations",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              evaluation.analysis ?? "No Analysis",
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ActionButtons extends StatelessWidget {
  final VoidCallback? onPressed;

  const ActionButtons({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.home),
            label: const Text("Back to Home"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[200],
              foregroundColor: Colors.black87,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onPressed,
            icon: const Icon(Icons.refresh),
            label: const Text("Retake Quiz"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const InfoChip({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class StatColumn extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const StatColumn({
    super.key,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
