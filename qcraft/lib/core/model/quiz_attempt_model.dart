import 'package:json_annotation/json_annotation.dart';
import 'package:qcraft/core/model/question_attempt_model.dart';

part 'quiz_attempt_model.g.dart';

@JsonSerializable(explicitToJson: true)
class QuizAttemptModel {
  final num? quizId;
  final num? id;
  final List<QuestionAttemptModel>? attempts;
  final double? accuracy;
  num? timeTaken;
  final num? difficulty;
  final String? analysis;
  final List<String>? weakTopics;

  QuizAttemptModel({
    this.quizId,
    this.id,
    this.attempts,
    this.accuracy,
    this.timeTaken,
    this.analysis,
    this.weakTopics,
    this.difficulty,
  });

  factory QuizAttemptModel.fromJson(Map<String, dynamic> json) =>
      _$QuizAttemptModelFromJson(json);

  Map<String, dynamic> toJson() => _$QuizAttemptModelToJson(this);
}
