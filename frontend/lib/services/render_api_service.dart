import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

final renderApiServiceProvider = Provider<RenderApiService>((ref) {
  return RenderApiService();
});

class ApiException implements Exception {
  final int statusCode;
  final String message;

  const ApiException(this.statusCode, this.message);

  @override
  String toString() => message;
}

/// Client for the shared Render backend (spec §7). Every call carries the
/// caller's Firebase ID token; the backend re-checks the role server-side.
class RenderApiService {
  static const String baseUrl = String.fromEnvironment(
    'AIKYA_API_BASE_URL',
    defaultValue: 'https://aikya-backend-2t80.onrender.com/api',
  );

  // Render's free tier can take ~30s to wake up; Gemini calls add more.
  static const _timeout = Duration(seconds: 90);

  Future<Map<String, dynamic>> _send(String method, String path, Map<String, dynamic> body) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw const ApiException(401, 'Please sign in again.');

    final token = await user.getIdToken();
    final uri = Uri.parse('$baseUrl$path');
    final headers = {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
    final encoded = jsonEncode(body);

    final http.Response response;
    try {
      final request = method == 'PUT'
          ? http.put(uri, headers: headers, body: encoded)
          : http.post(uri, headers: headers, body: encoded);
      response = await request.timeout(_timeout);
    } on Exception {
      throw const ApiException(0, 'Could not reach the AIKYA server. Check your connection and try again.');
    }

    Map<String, dynamic> data = const {};
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) data = decoded;
    } catch (_) {}

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        response.statusCode,
        data['error'] as String? ?? 'Request failed (${response.statusCode}).',
      );
    }
    return data;
  }

  /// PUT /api/profile
  Future<void> updateProfile(Map<String, dynamic> profile) => _send('PUT', '/profile', profile);

  /// POST /api/messaging/updates — author details are filled in server-side.
  Future<void> postUpdate({required String content, DateTime? deadlineDate}) {
    return _send('POST', '/messaging/updates', {
      'content': content,
      if (deadlineDate != null) 'deadlineDate': deadlineDate.toIso8601String(),
    });
  }

  /// POST /api/messaging/events — a coordinator's event starts `pending`
  /// (and notifies the HOD); an HOD's event is auto-approved. Returns the
  /// new event's id and status.
  Future<Map<String, dynamic>> createEvent(Map<String, dynamic> event) =>
      _send('POST', '/messaging/events', event);

  /// POST /api/generate-report — returns the markdown plus a `pdfUrl` for
  /// the same report rendered onto the department's official letterhead.
  Future<(String markdown, String? pdfUrl)> generateReport({
    required String brief,
    String? eventId,
    bool includeAttendance = true,
    String? additionalContext,
  }) async {
    final data = await _send('POST', '/generate-report', {
      'brief': brief,
      'eventId': eventId,
      'includeAttendance': includeAttendance,
      'additionalContext': ?additionalContext,
    });
    return (data['markdown'] as String? ?? '', data['pdfUrl'] as String?);
  }

  /// POST /api/compile-accreditation — returns { reportId, pdfUrl, ... }.
  Future<Map<String, dynamic>> compileAccreditation({
    required String semesterLabel,
    required List<String> eventIds,
  }) {
    return _send('POST', '/compile-accreditation', {
      'semesterLabel': semesterLabel,
      'eventIds': eventIds,
    });
  }

  /// POST /api/sentiment-rollup — returns { distribution, percentages, ... }.
  Future<Map<String, dynamic>> sentimentRollup({required String eventId}) {
    return _send('POST', '/sentiment-rollup', {'eventId': eventId});
  }

  /// POST /api/messaging/attendance/{approve|reject}
  Future<void> reviewAttendance({required String requestId, required bool approve, String note = ''}) {
    return _send('POST', '/messaging/attendance/${approve ? 'approve' : 'reject'}', {
      'requestId': requestId,
      'note': note,
    });
  }

  /// POST /api/messaging/memory-frame/{approve|reject}
  Future<void> reviewMemoryFrame({required String memoryId, required bool approve, String note = ''}) {
    return _send('POST', '/messaging/memory-frame/${approve ? 'approve' : 'reject'}', {
      'memoryId': memoryId,
      'note': note,
    });
  }

  /// POST /api/messaging/event/{approve|reject}
  Future<void> reviewEvent({required String eventId, required bool approve, String note = ''}) {
    return _send('POST', '/messaging/event/${approve ? 'approve' : 'reject'}', {
      'eventId': eventId,
      'note': note,
    });
  }

  /// POST /api/admin/provision-staff — returns { results, errors }.
  Future<Map<String, dynamic>> provisionStaff(List<Map<String, dynamic>> staff) {
    return _send('POST', '/admin/provision-staff', {'staff': staff});
  }
}
