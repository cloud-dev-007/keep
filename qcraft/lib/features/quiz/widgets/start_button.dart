import 'package:flutter/material.dart';
import 'package:qcraft/features/quiz/screens/quiz_screen.dart';

import '../../../core/constants/app_text_sizes.dart';
import '../../../core/model/quiz_model.dart';

class StartButton extends StatefulWidget {
  final QuizModel quiz;

  const StartButton(
    this.quiz, {
    super.key,
  });

  @override
  State<StartButton> createState() => _StartButtonState();
}

class _StartButtonState extends State<StartButton> {
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => QuizScreen(widget.quiz),
        ),
      ),
      style: TextButton.styleFrom(
        minimumSize: Size(double.infinity, 48),
        padding: EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
      child: Text(
        "Start Quiz",
        style: TextStyle(
            color: Colors.white,
            fontSize: AppTextSizes.body,
            fontWeight: FontWeight.w600),
      ),
    );
  }
}
