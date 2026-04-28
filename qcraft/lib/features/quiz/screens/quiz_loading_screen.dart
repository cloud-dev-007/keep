import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qcraft/core/constants/app_colors.dart';
import 'package:qcraft/features/quiz/bloc/quiz_bloc.dart';
import 'package:qcraft/features/quiz/bloc/quiz_event.dart';
import 'package:qcraft/features/quiz/bloc/quiz_state.dart';
import 'package:qcraft/features/quiz/screens/quiz_home_screen.dart';

import '../../../injection_container.dart';

class QuizLoadingScreen extends StatefulWidget {
  final num id;

  const QuizLoadingScreen(
    this.id, {
    super.key,
  });

  @override
  State<QuizLoadingScreen> createState() => _QuizLoadingScreenState();
}

class _QuizLoadingScreenState extends State<QuizLoadingScreen> {
  @override
  void initState() {
    sl<QuizBloc>().add(
      GenerateQuiz(widget.id),
    );
    super.initState();
  }

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
        },
        child: Scaffold(
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "quiz is generating ",
                    style: TextStyle(
                      fontFamily: "Proxima Nova",
                      fontSize: 16,
                    ),
                  ),
                  TimerWidget()
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: CircularProgressIndicator.adaptive(
                  backgroundColor: AppColors.primary,
                ),
              ),
              OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.circular(12))),
                child: Text("Cancel"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TimerWidget extends StatefulWidget {
  final Duration? time;

  const TimerWidget({
    super.key,
    this.time,
  });

  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  Timer? _timer;
  late Duration _remainingTime;

  @override
  void initState() {
    _remainingTime = Duration();
    _startStopwatch();

    super.initState();
  }

  String _formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits(duration.inMinutes);
    String seconds = twoDigits(duration.inSeconds % 60);
    return '$minutes:$seconds';
  }

  void _startStopwatch() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _remainingTime = Duration(seconds: _remainingTime.inSeconds + 1);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _formatTime(_remainingTime),
      style: TextStyle(
        fontFamily: "Proxima Nova",
        fontSize: 16,
      ),
    );
  }
}
