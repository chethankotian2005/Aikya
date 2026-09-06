class UsnParseResult {
  final String usn;
  final String admissionYY;
  final String suffix;
  final String entryType;
  final int yearOfStudy;
  final String label;
  final bool isAlumni;

  UsnParseResult({
    required this.usn,
    required this.admissionYY,
    required this.suffix,
    required this.entryType,
    required this.yearOfStudy,
    required this.label,
    required this.isAlumni,
  });
}

class UsnParser {
  /// Duration of a standard B.E./B.Tech programme.
  static const int programmeDurationYears = 4;

  /// Parses USN and computes academic info (year of study, label, alumni status)
  /// directly from the admission year — no Firestore lookup needed.
  /// Returns null if the USN format is invalid.
  static UsnParseResult? parse(String? usn) {
    if (usn == null || usn.isEmpty) return null;

    final upperUsn = usn.trim().toUpperCase();
    final validUsnRegex = RegExp(r'^4MW(\d{2})AI(\d{3})$');
    final match = validUsnRegex.firstMatch(upperUsn);

    if (match == null) return null;

    final admissionYY = match.group(1)!;
    final suffix = match.group(2)!;
    final entryType = suffix.startsWith('4') ? 'lateral_diploma' : 'regular';

    // Compute academic year.
    // Academic year starts in August: before August → previous academic year.
    final now = DateTime.now();
    final currentAcademicYear = now.month >= 8 ? now.year : now.year - 1;

    // Admission year as full 4-digit year (20xx).
    final admissionYear = 2000 + int.parse(admissionYY);

    // Year of study: 1-indexed (1st, 2nd, 3rd, 4th).
    int yearOfStudy = currentAcademicYear - admissionYear + 1;

    // Determine status.
    final bool isAlumni = yearOfStudy > programmeDurationYears;

    // Cap year of study for alumni.
    if (isAlumni) yearOfStudy = programmeDurationYears;

    // Human-readable label.
    String label;
    if (isAlumni) {
      label = 'Alumni';
    } else {
      switch (yearOfStudy) {
        case 1:
          label = '1st Year';
          break;
        case 2:
          label = '2nd Year';
          break;
        case 3:
          label = '3rd Year';
          break;
        case 4:
          label = 'Final Year';
          break;
        default:
          label = 'Unknown';
      }
    }

    return UsnParseResult(
      usn: upperUsn,
      admissionYY: admissionYY,
      suffix: suffix,
      entryType: entryType,
      yearOfStudy: yearOfStudy,
      label: label,
      isAlumni: isAlumni,
    );
  }
}
