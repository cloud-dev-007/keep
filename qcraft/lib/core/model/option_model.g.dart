// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'option_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OptionModel _$OptionModelFromJson(Map<String, dynamic> json) => OptionModel(
      id: json['id'] as num?,
      value: json['value'] as String?,
      isAnswer: json['isAnswer'] as bool?,
    );

Map<String, dynamic> _$OptionModelToJson(OptionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'value': instance.value,
      'isAnswer': instance.isAnswer,
    };
