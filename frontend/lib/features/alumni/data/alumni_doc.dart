import 'package:freezed_annotation/freezed_annotation.dart';
import '../../auth/data/user_doc.dart';

part 'alumni_doc.freezed.dart';
part 'alumni_doc.g.dart';

@freezed
abstract class AlumniDoc with _$AlumniDoc {
  const factory AlumniDoc({
    required String uid,
    required int graduationYear,
    required String currentCompany,
    required String jobTitle,
    required String location,
    required String linkedinUrl,
    @Default(false) bool isOpenForMentorship,
    @Default(false) bool verifiedByHod,
    @DateTimeConverter() required DateTime createdAt,
  }) = _AlumniDoc;

  factory AlumniDoc.fromJson(Map<String, dynamic> json) => _$AlumniDocFromJson(json);
}
