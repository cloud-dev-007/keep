import 'package:flutter/material.dart';
import 'package:qcraft/core/model/question_attempt_model.dart';
import 'package:qcraft/core/model/quiz_model.dart';
import 'package:qcraft/features/quiz/bloc/quiz_event.dart';
import 'package:qcraft/features/quiz/widgets/quiz_question_page.dart';

import '../../../injection_container.dart';
import '../bloc/quiz_bloc.dart';

class QuizQuestionPageView extends StatelessWidget {
  final QuizModel quiz;
  final Function(int index, QuestionAttemptModel attempt) onUpdate;
  final PageController controller;

  const QuizQuestionPageView(
    this.quiz, {
    super.key,
    required this.controller,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadiusGeometry.circular(12),
      ),
      margin: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: PageView.builder(
        controller: controller,
        onPageChanged: (pageIndex) {
          sl<QuizBloc>().add(ChangePageIndex(pageIndex));
        },
        itemBuilder: (context, index) {
          return QuizQuestionPage(
            index: index,
            quiz: quiz,
            onUpdate: (attempt) {
              onUpdate(index, attempt);
            },
          );
        },
        itemCount: quiz.questions!.length,
      ),
    );
  }
}
