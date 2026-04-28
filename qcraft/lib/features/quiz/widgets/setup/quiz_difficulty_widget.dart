import 'package:flutter/cupertino.dart';
import 'package:qcraft/features/quiz/widgets/setup/quiz_setup_widget.dart';

import '../../../../core/enums/bloom_taxonomy_level.dart';

class QuizDifficultyWidget extends StatefulWidget {
  final Function(int difficulty) onUpdate;

  const QuizDifficultyWidget({super.key, required this.onUpdate});

  @override
  State<QuizDifficultyWidget> createState() => _QuizDifficultyWidgetState();
}

class _QuizDifficultyWidgetState extends State<QuizDifficultyWidget> {
  late String difficulty;
  int currentStep = 4;

  void updateDifficulty(int value) {
    difficulty = getDifficultyLabel(value);
  }

  @override
  void initState() {
    updateDifficulty(currentStep);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return QuizSetupWidget(
        leading: "QUIZ DIFFICULTY",
        trailing: difficulty.toUpperCase(),
        child: QuizDifficultySlider(
          onUpdate: (value) {
            setState(() {
              updateDifficulty(value);
            });
            widget.onUpdate(value);
          },
          currentStep: currentStep,
        ));
  }
}

class QuizDifficultySlider extends StatefulWidget {
  final Function(int difficulty) onUpdate;
  final int currentStep;

  const QuizDifficultySlider(
      {super.key, required this.onUpdate, required this.currentStep});

  @override
  State<QuizDifficultySlider> createState() => _QuizDifficultySliderState();
}

class _QuizDifficultySliderState extends State<QuizDifficultySlider> {
  late int step;

  @override
  void initState() {
    step = widget.currentStep;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 50.0,
        child: LayoutBuilder(builder: (context, constraints) {
          return GestureDetector(
            onPanUpdate: (event) {
              final position = event.localPosition.dx / constraints.maxWidth;

              setState(() {
                step = (position * 10).ceil();
                if (step > 10) step = 10;
                if (step < 1) step = 1;
              });

              widget.onUpdate(step);
            },
            onPanDown: (event) {
              final position = event.localPosition.dx / constraints.maxWidth;

              setState(() {
                step = (position * 10).ceil();
                if (step > 10) step = 10;
                if (step < 1) step = 1;
              });

              widget.onUpdate(step);
            },
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        CupertinoColors.systemGreen,
                        CupertinoColors.systemYellow,
                        CupertinoColors.systemRed,
                      ],
                      stops: [
                        0.0,
                        0.3,
                        0.7,
                      ],
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(
                      9,
                      (index) => Container(
                        width: 1,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    color: CupertinoColors.systemGrey.withOpacity(0.6),
                    width: constraints.maxWidth * (1 - (step / 10)),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
