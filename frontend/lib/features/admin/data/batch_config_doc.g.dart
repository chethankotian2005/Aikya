// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'batch_config_doc.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BatchConfigDoc _$BatchConfigDocFromJson(Map<String, dynamic> json) =>
    _BatchConfigDoc(
      yearOfStudy: (json['yearOfStudy'] as num?)?.toInt() ?? 1,
      label: json['label'] as String? ?? '',
      graduated: json['graduated'] as bool? ?? false,
    );

Map<String, dynamic> _$BatchConfigDocToJson(_BatchConfigDoc instance) =>
    <String, dynamic>{
      'yearOfStudy': instance.yearOfStudy,
      'label': instance.label,
      'graduated': instance.graduated,
    };
