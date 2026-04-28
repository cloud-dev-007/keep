import 'package:flutter/material.dart';
import 'package:qcraft/core/model/quiz_model.dart';
import 'package:qcraft/features/quiz/widgets/countdown_widget.dart';
import 'package:qcraft/features/quiz/widgets/setup/quiz_pause_button.dart';

class QuizAppBar extends StatelessWidget implements PreferredSizeWidget {
  final QuizModel quiz;
  final Function(int) onUpdate;

  const QuizAppBar(this.quiz, {super.key, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: CountdownWidget(
        initialDuration: quiz.duration == null
            ? null
            : Duration(minutes: quiz.duration!.toInt()),
        onUpdate: onUpdate,
      ),
      actions: [QuizPauseButton()],
    );
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => AppBar().preferredSize;
}
