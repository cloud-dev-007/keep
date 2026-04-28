import 'package:json_annotation/json_annotation.dart';

enum QuizType {
  @JsonValue("MCQ")
  mcq("Multiple Choice"),
  @JsonValue("Theory")
  theory("Theory"),
  @JsonValue("FillInTheBlank")
  fillInTheBlank("Fill in the Blanks"),
  @JsonValue("TrueFalse")
  trueFalse("True/False"),
  @JsonValue("Any")
  any("Any");

  final String name;

  const QuizType(this.name);
}
