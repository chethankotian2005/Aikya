import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

/// Provides the RenderApiService instance.
final renderApiServiceProvider = Provider<RenderApiService>((ref) {
  return RenderApiService();
});

class RenderApiService {
  // TODO: Replace with your actual Render backend URL
  static const String baseUrl = 'https://aikya-backend.onrender.com/api';

  Future<Map<String, String>> _getHeaders() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('Not authenticated. Cannot call Render API.');
    }
    
    // Force refresh to get the latest custom claims if any, though our backend
    // reads the role directly from Firestore anyway.
    final token = await user.getIdToken();
    
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// POST /api/generate-report
  Future<String> generateReport({
    required String brief,
    String? eventId,
    bool includeAttendance = false,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/generate-report'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'brief': brief,
        'eventId': eventId,
        'includeAttendance': includeAttendance,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['markdown'] as String;
    } else {
      throw Exception('Failed to generate report: ${response.body}');
    }
  }

  /// POST /api/compile-accreditation
  Future<String> compileAccreditation({
    required String semesterLabel,
    required List<String> eventIds,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/compile-accreditation'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'semesterLabel': semesterLabel,
        'eventIds': eventIds,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['pdfUrl'] as String;
    } else {
      throw Exception('Failed to compile accreditation: ${response.body}');
    }
  }

  /// POST /api/analyze-sentiment
  Future<Map<String, dynamic>> analyzeSentiment({
    required String eventId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/analyze-sentiment'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'eventId': eventId,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to analyze sentiment: ${response.body}');
    }
  }
}
