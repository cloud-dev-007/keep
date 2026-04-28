// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quiz_attempt_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuizAttemptModel _$QuizAttemptModelFromJson(Map<String, dynamic> json) =>
    QuizAttemptModel(
      quizId: json['quizId'] as num?,
      id: json['id'] as num?,
      attempts: (json['attempts'] as List<dynamic>?)
          ?.map((e) => QuestionAttemptModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      accuracy: (json['accuracy'] as num?)?.toDouble(),
      timeTaken: json['timeTaken'] as num?,
      analysis: json['analysis'] as String?,
      weakTopics: (json['weakTopics'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      difficulty: json['difficulty'] as num?,
    );

Map<String, dynamic> _$QuizAttemptModelToJson(QuizAttemptModel instance) =>
    <String, dynamic>{
      'quizId': instance.quizId,
      'id': instance.id,
      'attempts': instance.attempts?.map((e) => e.toJson()).toList(),
      'accuracy': instance.accuracy,
      'timeTaken': instance.timeTaken,
      'difficulty': instance.difficulty,
      'analysis': instance.analysis,
      'weakTopics': instance.weakTopics,
    };
