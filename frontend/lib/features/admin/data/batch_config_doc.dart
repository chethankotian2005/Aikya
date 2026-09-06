import 'package:freezed_annotation/freezed_annotation.dart';

part 'batch_config_doc.freezed.dart';
part 'batch_config_doc.g.dart';

@freezed
class BatchConfigDoc with _$BatchConfigDoc {
  const factory BatchConfigDoc({
    @Default(1) int yearOfStudy,
    @Default('') String label,
    @Default(false) bool graduated,
  }) = _BatchConfigDoc;

  const BatchConfigDoc._();

  factory BatchConfigDoc.fromJson(Map<String, dynamic> json) => _$BatchConfigDocFromJson(json);
}
