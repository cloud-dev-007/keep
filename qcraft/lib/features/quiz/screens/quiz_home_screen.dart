import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qcraft/core/enums/bloom_taxonomy_level.dart';
import 'package:qcraft/core/model/quiz_model.dart';
import 'package:qcraft/core/widgets/document_list_tile.dart';
import 'package:qcraft/core/widgets/subtitle_text.dart';
import 'package:qcraft/features/quiz/widgets/start_button.dart';

class QuizHomeScreen extends StatelessWidget {
  final QuizModel quiz;

  const QuizHomeScreen(
    this.quiz, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Quiz Home"),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsetsGeometry.symmetric(horizontal: 16, vertical: 20),
        child: SafeArea(
          bottom: true,
          top: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SubtitleText("title"),
              Text(
                quiz.title ?? "Title",
                style: TextStyle(
                    fontFamily: "Proxima Nova",
                    fontSize: 24,
                    fontWeight: FontWeight.w500),
              ),
              SizedBox(
                height: 12,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SubtitleText("difficulty"),
                  Text(
                    getDifficultyLabel(quiz.difficulty!),
                  ),
                ],
              ),
              Text(
                getBloomDescription(
                  getBloomLevel(quiz.difficulty!),
                ),
              ),
              SizedBox(
                height: 12,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SubtitleText("duration"),
                  Text(
                    quiz.duration == null ? "OFF" : "${quiz.duration} mins",
                  ),
                ],
              ),
              SizedBox(
                height: 12,
              ),
              SubtitleText("Questions"),
              Text("${quiz.noOfQuestions} Questions"),
              SizedBox(
                height: 12,
              ),
              SubtitleText("Type"),
              // Text(quiz.type!.name),
              SizedBox(
                height: 12,
              ),
              SubtitleText('document(s)'),
              DocumentListTile(
                documents: quiz.documents!,
              ),
              SizedBox(
                height: 12,
              ),
              StartButton(quiz)
            ],
          ),
        ),
      ),
    );
  }
}
