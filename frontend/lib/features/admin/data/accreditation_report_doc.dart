import 'package:freezed_annotation/freezed_annotation.dart';
import '../../auth/data/user_doc.dart';

part 'accreditation_report_doc.freezed.dart';
part 'accreditation_report_doc.g.dart';

@freezed
abstract class AccreditationReportDoc with _$AccreditationReportDoc {
  const factory AccreditationReportDoc({
    required String id,
    required String semesterLabel,
    required String compiledBy,
    required List<String> includedEventIds,
    required String pdfUrl,
    @DateTimeConverter() required DateTime generatedAt,
  }) = _AccreditationReportDoc;

  factory AccreditationReportDoc.fromJson(Map<String, dynamic> json) => _$AccreditationReportDocFromJson(json);
}
