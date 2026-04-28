// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DocumentModel _$DocumentModelFromJson(Map<String, dynamic> json) =>
    DocumentModel(
      formatType: json['formatType'] as String?,
      topics:
          (json['topics'] as List<dynamic>?)?.map((e) => e as String).toList(),
      id: json['id'] as num?,
      title: json['title'] as String?,
      fileName: json['fileName'] as String?,
      description: json['description'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      pageCount: json['pageCount'] as num?,
    );

Map<String, dynamic> _$DocumentModelToJson(DocumentModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'fileName': instance.fileName,
      'pageCount': instance.pageCount,
      'topics': instance.topics,
      'formatType': instance.formatType,
      'createdAt': instance.createdAt?.toIso8601String(),
    };
