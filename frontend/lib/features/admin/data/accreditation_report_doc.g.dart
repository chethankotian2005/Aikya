// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'accreditation_report_doc.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AccreditationReportDoc _$AccreditationReportDocFromJson(
  Map<String, dynamic> json,
) => _AccreditationReportDoc(
  id: json['id'] as String,
  semesterLabel: json['semesterLabel'] as String,
  compiledBy: json['compiledBy'] as String,
  includedEventIds: (json['includedEventIds'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  pdfUrl: json['pdfUrl'] as String,
  generatedAt: const DateTimeConverter().fromJson(json['generatedAt']),
);

Map<String, dynamic> _$AccreditationReportDocToJson(
  _AccreditationReportDoc instance,
) => <String, dynamic>{
  'id': instance.id,
  'semesterLabel': instance.semesterLabel,
  'compiledBy': instance.compiledBy,
  'includedEventIds': instance.includedEventIds,
  'pdfUrl': instance.pdfUrl,
  'generatedAt': const DateTimeConverter().toJson(instance.generatedAt),
};
