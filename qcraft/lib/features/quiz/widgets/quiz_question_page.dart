import 'package:flutter/material.dart';
import 'package:qcraft/core/model/question_attempt_model.dart';
import 'package:qcraft/core/model/quiz_model.dart';
import 'package:qcraft/features/quiz/widgets/option_selector.dart';

class QuizQuestionPage extends StatefulWidget {
  final QuizModel quiz;
  final Function(QuestionAttemptModel attempt) onUpdate;
  final int index;

  const QuizQuestionPage(
      {super.key,
      required this.index,
      required this.quiz,
      required this.onUpdate});

  @override
  State<QuizQuestionPage> createState() => _QuizQuestionPageState();
}

class _QuizQuestionPageState extends State<QuizQuestionPage>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final question = widget.quiz.questions![widget.index];
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Question ${widget.index + 1} of ${widget.quiz.questions!.length}",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            question.question!,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(
            height: 12.0,
          ),
          if ((question.options ?? []).isNotEmpty)
            OptionSelector(
                options: question.options!,
                onSelected: (option) {
                  widget.onUpdate(QuestionAttemptModel(
                      questionId: question.id!,
                      value: option.value!,
                      correct: option.isAnswer));
                })
          else
            TextField(
              autofocus: true,
              onChanged: (answer) {
                widget.onUpdate(QuestionAttemptModel(
                    questionId: question.id!, value: answer));
              },
              maxLines: 10,
              decoration: InputDecoration(hintText: "Type your answer here..."),
            ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
