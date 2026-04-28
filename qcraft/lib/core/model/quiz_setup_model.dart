import 'package:json_annotation/json_annotation.dart';
import 'package:qcraft/core/enums/quiz_type.dart';

part 'quiz_setup_model.g.dart';

@JsonSerializable()
class QuizSetupModel {
  List<num>? documentIds;
  num? questions;
  num? difficulty;
  num? duration;
  QuizType? type;

  QuizSetupModel({
    this.documentIds,
    this.questions,
    this.difficulty,
    this.duration,
    this.type,
  });

  void update(
      {List<int>? documentIds,
      num? questions,
      double? difficulty,
      double? duration,
      QuizType? type}) {
    if (documentIds != null) this.documentIds = documentIds;
    if (questions != null) this.questions = questions;
    if (difficulty != null) this.difficulty = difficulty;
    if (duration != null) this.duration = duration;
    if (type != null) this.type = type;
  }

  factory QuizSetupModel.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$QuizSetupModelFromJson(json);

  Map<String, dynamic> toJson() => _$QuizSetupModelToJson(this);
}
