import 'package:json_annotation/json_annotation.dart';

part 'document_model.g.dart';

@JsonSerializable()
class DocumentModel {
  final num? id;

  final String? title;

  final String? description;
  final String? fileName;
  final num? pageCount;
  final List<String>? topics;
  final String? formatType;
  final DateTime? createdAt;

  const DocumentModel({
    this.formatType,
    this.topics,
    this.id,
    this.title,
    this.fileName,
    this.description,
    this.createdAt,
    this.pageCount,
  });

  factory DocumentModel.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$DocumentModelFromJson(json);

  Map<String, dynamic> toJson() => _$DocumentModelToJson(this);
}
