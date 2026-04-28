// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'question_attempt_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuestionAttemptModel _$QuestionAttemptModelFromJson(
        Map<String, dynamic> json) =>
    QuestionAttemptModel(
      questionId: json['questionId'] as num?,
      value: json['value'] as String?,
      correct: json['correct'] as bool?,
    );

Map<String, dynamic> _$QuestionAttemptModelToJson(
        QuestionAttemptModel instance) =>
    <String, dynamic>{
      'questionId': instance.questionId,
      'value': instance.value,
      'correct': instance.correct,
    };
