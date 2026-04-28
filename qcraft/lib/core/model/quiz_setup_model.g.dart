// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quiz_setup_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuizSetupModel _$QuizSetupModelFromJson(Map<String, dynamic> json) =>
    QuizSetupModel(
      documentIds: (json['documentIds'] as List<dynamic>?)
          ?.map((e) => e as num)
          .toList(),
      questions: json['questions'] as num?,
      difficulty: json['difficulty'] as num?,
      duration: json['duration'] as num?,
      type: $enumDecodeNullable(_$QuizTypeEnumMap, json['type']),
    );

Map<String, dynamic> _$QuizSetupModelToJson(QuizSetupModel instance) =>
    <String, dynamic>{
      'documentIds': instance.documentIds,
      'questions': instance.questions,
      'difficulty': instance.difficulty,
      'duration': instance.duration,
      'type': _$QuizTypeEnumMap[instance.type],
    };

const _$QuizTypeEnumMap = {
  QuizType.mcq: 'MCQ',
  QuizType.theory: 'Theory',
  QuizType.fillInTheBlank: 'FillInTheBlank',
  QuizType.trueFalse: 'TrueFalse',
  QuizType.any: 'Any',
};
