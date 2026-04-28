import 'package:json_annotation/json_annotation.dart';

part 'option_model.g.dart';

@JsonSerializable()
class OptionModel {
  final num? id;
  final String? value;
  final bool? isAnswer;

  const OptionModel({
    this.id,
    this.value,
    this.isAnswer,
  });

  factory OptionModel.fromJson(Map<String, dynamic> json) =>
      _$OptionModelFromJson(json);

  Map<String, dynamic> toJson() => _$OptionModelToJson(this);
}
