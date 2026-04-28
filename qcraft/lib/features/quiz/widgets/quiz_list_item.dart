import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qcraft/core/enums/bloom_taxonomy_level.dart';
import 'package:qcraft/core/model/quiz_model.dart';
import 'package:qcraft/features/quiz/screens/quiz_loading_screen.dart';
import 'package:qcraft/features/quiz/widgets/quiz_info_sheet.dart';

class QuizListTile extends StatelessWidget {
  final QuizModel quiz;

  const QuizListTile({super.key, required this.quiz});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        quiz.title ?? "No title",
        style: TextStyle(overflow: TextOverflow.ellipsis),
        maxLines: 2,
      ),
      subtitle: Row(
        children: [
          QuizChip(
            getDifficultyLabel(quiz.difficulty!).toUpperCase(),
          ),
          QuizChip(
            "${quiz.questions!.length} questions".toUpperCase(),
          ),
          if (quiz.duration != null)
            QuizChip(
              "${quiz.duration} mins".toUpperCase(),
            ),
        ]
            .map(
              (child) => Padding(
                padding: EdgeInsetsGeometry.only(right: 8.0),
                child: child,
              ),
            )
            .toList(),
      ),
      trailing: IconButton.filled(
        onPressed: () {},
        icon: Icon(
          getBloomCupertinoIcon(getBloomLevel(quiz.difficulty!)),
          color: Colors.white,
          size: 30,
        ),
        style: IconButton.styleFrom(
            backgroundColor: getBloomColor(getBloomLevel(quiz.difficulty!))),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 0),
      onTap: () => Navigator.push(
        context,
        CupertinoSheetRoute(
          builder: (context) => QuizInfoSheet(
            quiz: quiz,
            actionButton: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => QuizLoadingScreen(
                    quiz.id!,
                  ),
                ),
              );
            },
            actionText: "Generate",
          ),
        ),
      ),
    );
  }
}

class QuizChip extends StatelessWidget {
  final String text;

  const QuizChip(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      margin: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.shade300,
        ),
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
            fontSize: 10,
            fontFamily: "Proxima-Nova",
            fontWeight: FontWeight.w600,
            color: Colors.grey,
            letterSpacing: 1.1),
      ),
    );
  }
}
