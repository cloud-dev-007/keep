import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qcraft/core/constants/app_colors.dart';
import 'package:qcraft/core/model/quiz_attempt_model.dart';
import 'package:qcraft/core/model/quiz_model.dart';
import 'package:qcraft/features/quiz/bloc/quiz_event.dart';
import 'package:qcraft/features/quiz/screens/evaluation_screen.dart';

import '../../../injection_container.dart';
import '../bloc/quiz_bloc.dart';
import '../bloc/quiz_state.dart';

class QuizBottomBar extends StatefulWidget {
  final PageController controller;
  final QuizAttemptModel quizAttempt;
  final QuizModel quiz;
  final int pagesCount;

  const QuizBottomBar(
      {super.key,
      required this.controller,
      required this.quizAttempt,
      required this.pagesCount,
      required this.quiz});

  @override
  State<QuizBottomBar> createState() => _QuizBottomBarState();
}

class _QuizBottomBarState extends State<QuizBottomBar> {
  int pageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<QuizBloc>.value(
      value: sl<QuizBloc>(),
      child: BlocListener<QuizBloc, QuizState>(
        listener: (stateA, stateB) {
          if (stateB is QuizPageChanged) {
            setState(() {
              pageIndex = stateB.index;
            });
          }
          if (stateB is QuizEvaluated) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EvaluationScreen(
                  evaluation: stateB.attempt,
                  quiz: widget.quiz,
                ),
              ),
            );
          }
        },
        child: Container(
          padding: EdgeInsetsGeometry.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: QuizBottomBarButton(
                  "Previous",
                  enabled: pageIndex > 0,
                  onTap: () {
                    widget.controller.animateToPage(pageIndex - 1,
                        duration: Duration(milliseconds: 300),
                        curve: Curves.fastEaseInToSlowEaseOut);
                  },
                ),
              ),
              Expanded(
                child: QuizBottomBarButton(
                  pageIndex >= widget.pagesCount ? "submit" : "Next",
                  enabled: true,
                  lastPage: pageIndex >= widget.pagesCount,
                  onSubmit: () => sl<QuizBloc>()
                    ..add(ToggleTimer(true))
                    ..add(
                      EvaluateQuiz(widget.quizAttempt),
                    ),
                  onTap: () {
                    widget.controller.animateToPage(pageIndex + 1,
                        duration: Duration(milliseconds: 300),
                        curve: Curves.fastEaseInToSlowEaseOut);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class QuizBottomBarButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  final VoidCallback? onSubmit;
  final bool enabled;
  final bool lastPage;

  const QuizBottomBarButton(this.text,
      {super.key,
      required this.onTap,
      required this.enabled,
      this.onSubmit,
      this.lastPage = false});

  @override
  State<QuizBottomBarButton> createState() => _QuizBottomBarButtonState();
}

class _QuizBottomBarButtonState extends State<QuizBottomBarButton> {
  VoidCallback? onTap() {
    return widget.enabled
        ? widget.lastPage
            ? widget.onSubmit
            : widget.onTap
        : null;
  }

  Color getButtonColor() {
    return widget.enabled
        ? widget.lastPage
            ? CupertinoColors.activeGreen.elevatedColor
            : AppColors.primary
        : Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: onTap(),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsetsGeometry.symmetric(vertical: 12.0),
          margin: EdgeInsetsGeometry.symmetric(horizontal: 8.0),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: getButtonColor(),
            borderRadius: BorderRadiusGeometry.circular(8.0),
          ),
          child: Text(widget.text.toUpperCase(),
              style: TextStyle(
                fontFamily: "Proxima-Nova",
                color: Colors.white.withOpacity(.9),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              )),
        ));
  }
}
