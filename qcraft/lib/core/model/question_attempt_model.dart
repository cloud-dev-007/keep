import 'package:json_annotation/json_annotation.dart';

part 'question_attempt_model.g.dart';

@JsonSerializable()
class QuestionAttemptModel {
  final num? questionId;
  final String? value;
  final bool? correct;

  const QuestionAttemptModel({
    required this.questionId,
    required this.value,
    this.correct,
  });

  factory QuestionAttemptModel.fromJson(Map<String, dynamic> json) =>
      _$QuestionAttemptModelFromJson(json);

  Map<String, dynamic> toJson() => _$QuestionAttemptModelToJson(this);
}
