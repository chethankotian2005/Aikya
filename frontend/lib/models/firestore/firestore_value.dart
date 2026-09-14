import 'package:cloud_firestore/cloud_firestore.dart';

/// Reads a date that may be stored as a Timestamp (current writes), an ISO
/// string (older writes) or still pending as a server timestamp (null).
DateTime? toDateTime(Object? value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  return null;
}

List<String> toStringList(Object? value) =>
    value is List ? value.whereType<String>().toList() : const [];
