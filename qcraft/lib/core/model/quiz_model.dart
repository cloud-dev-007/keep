import 'package:json_annotation/json_annotation.dart';
import 'package:qcraft/core/model/document_model.dart';
import 'package:qcraft/core/model/question_model.dart';
import 'package:qcraft/core/enums/quiz_type.dart';

part 'quiz_model.g.dart';

@JsonSerializable()
class QuizModel {
  final num? id;
  final String? title;
  final num? difficulty;
  final num? duration;
  final num? noOfQuestions;
  final QuizType? type;
  final bool? isAdaptive;
  final List<QuestionModel>? questions;
  final List<DocumentModel>? documents;
  final DateTime? createdAt;

  const QuizModel({
    this.id,
    this.title,
    this.difficulty,
    this.duration,
    this.noOfQuestions,
    this.type,
    this.isAdaptive,
    this.questions,
    this.documents,
    this.createdAt,
  });

  factory QuizModel.fromJson(Map<String, dynamic> json) =>
      _$QuizModelFromJson(json);

  Map<String, dynamic> toJson() => _$QuizModelToJson(this);
}
