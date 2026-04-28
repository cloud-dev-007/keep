import 'package:json_annotation/json_annotation.dart';
import 'package:qcraft/core/model/quiz_model.dart';

import 'option_model.dart';

part 'question_model.g.dart';

@JsonSerializable()
class QuestionModel {
  final int? id;
  final String? type;
  final String? question;
  final List<OptionModel>? options;

  const QuestionModel({
    this.id,
    this.type,
    this.question,
    this.options,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) =>
      _$QuestionModelFromJson(json);

  Map<String, dynamic> toJson() => _$QuestionModelToJson(this);
}
