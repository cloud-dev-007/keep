// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quiz_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuizModel _$QuizModelFromJson(Map<String, dynamic> json) => QuizModel(
      id: json['id'] as num?,
      title: json['title'] as String?,
      difficulty: json['difficulty'] as num?,
      duration: json['duration'] as num?,
      noOfQuestions: json['noOfQuestions'] as num?,
      type: $enumDecodeNullable(_$QuizTypeEnumMap, json['type']),
      isAdaptive: json['isAdaptive'] as bool?,
      questions: (json['questions'] as List<dynamic>?)
          ?.map((e) => QuestionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      documents: (json['documents'] as List<dynamic>?)
          ?.map((e) => DocumentModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$QuizModelToJson(QuizModel instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'difficulty': instance.difficulty,
      'duration': instance.duration,
      'noOfQuestions': instance.noOfQuestions,
      'type': _$QuizTypeEnumMap[instance.type],
      'isAdaptive': instance.isAdaptive,
      'questions': instance.questions,
      'documents': instance.documents,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

const _$QuizTypeEnumMap = {
  QuizType.mcq: 'MCQ',
  QuizType.theory: 'Theory',
  QuizType.fillInTheBlank: 'FillInTheBlank',
  QuizType.trueFalse: 'TrueFalse',
  QuizType.any: 'Any',
};
