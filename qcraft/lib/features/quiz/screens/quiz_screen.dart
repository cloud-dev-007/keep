import 'package:flutter/material.dart';
import 'package:qcraft/core/model/question_attempt_model.dart';
import 'package:qcraft/core/model/quiz_attempt_model.dart';
import 'package:qcraft/features/quiz/widgets/quiz_app_bar.dart';
import 'package:qcraft/features/quiz/widgets/quiz_bottom_bar.dart';
import 'package:qcraft/features/quiz/widgets/quiz_question_view.dart';

import '../../../core/model/quiz_model.dart';

class QuizScreen extends StatefulWidget {
  final QuizModel quiz;

  const QuizScreen(this.quiz, {super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late PageController controller;
  late ValueNotifier<List<QuestionAttemptModel>> attempts;

  late QuizAttemptModel quizAttempt;

  @override
  void initState() {
    controller = PageController();

    attempts = ValueNotifier(widget.quiz.questions!
        .map(
          (question) => QuestionAttemptModel(
            questionId: question.id!,
            value: '',
            correct: null,
          ),
        )
        .toList());
    quizAttempt = QuizAttemptModel(
      quizId: widget.quiz.id!,
      attempts: attempts.value,
      difficulty: widget.quiz.difficulty!,
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: QuizAppBar(
        widget.quiz,
        onUpdate: (secondsSpent) {
          quizAttempt.timeTaken = secondsSpent;
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: QuizQuestionPageView(
                widget.quiz,
                controller: controller,
                onUpdate: (index, attempt) {
                  attempts.value[index] = attempt;
                },
              ),
            ),
            QuizBottomBar(
              controller: controller,
              quizAttempt: quizAttempt,
              quiz: widget.quiz,
              pagesCount: widget.quiz.questions!.length - 1,
            )
          ],
        ),
      ),
    );
  }
}
