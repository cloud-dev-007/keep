import 'package:flutter/cupertino.dart';
import 'package:qcraft/features/quiz/widgets/quiz_list_item.dart';

import '../../../core/model/quiz_model.dart';

class QuizListView extends StatelessWidget {
  final List<QuizModel> quizzes;

  const QuizListView({super.key, required this.quizzes});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: quizzes.length,
      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 12),
      itemBuilder: (BuildContext context, int index) {
        final quiz = quizzes[index];
        return QuizListTile(
          quiz: quiz,
        );
      },
    );
  }
}
