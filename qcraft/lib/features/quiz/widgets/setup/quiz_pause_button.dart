import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qcraft/core/constants/app_colors.dart';
import 'package:qcraft/features/quiz/bloc/quiz_bloc.dart';
import 'package:qcraft/features/quiz/bloc/quiz_event.dart';

import '../../../../injection_container.dart';
import '../../bloc/quiz_state.dart';

class QuizPauseButton extends StatefulWidget {
  const QuizPauseButton({super.key});

  @override
  State<QuizPauseButton> createState() => _QuizPauseButtonState();
}

class _QuizPauseButtonState extends State<QuizPauseButton> {
  bool isPaused = false;

  @override
  void initState() {
    sl<QuizBloc>().add(ToggleTimer(isPaused));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<QuizBloc>(),
      child: BlocListener<QuizBloc, QuizState>(
        listener: (stateA, stateB) {
          if (stateB is QuizPaused) {
            setState(() {
              isPaused = stateB.isPaused;
            });
          }
        },
        child: IconButton(
          onPressed: () {
            sl<QuizBloc>().add(ToggleTimer(!isPaused));
          },
          icon: Icon(
            isPaused
                ? CupertinoIcons.play_arrow_solid
                : CupertinoIcons.pause_fill,
            size: 30,
            color: Colors.blueAccent,
          ),
        ),
      ),
    );
  }
}
