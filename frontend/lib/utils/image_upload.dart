import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../services/render_api_service.dart';

/// One of the folders the backend's Cloudinary upload endpoint accepts.
enum UploadFolder { profilePictures, eventBanners, memoryFrame, projectImages }

String _folderKey(UploadFolder folder) => switch (folder) {
      UploadFolder.profilePictures => 'profile_pictures',
      UploadFolder.eventBanners => 'event_banners',
      UploadFolder.memoryFrame => 'memory_frame',
      UploadFolder.projectImages => 'project_images',
    };

/// Uploads a picked image through the authenticated backend — which forwards
/// it to Cloudinary, since Firebase Storage now requires the Blaze plan —
/// and returns its secure URL.
Future<String> uploadImage(XFile file, UploadFolder folder) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) throw const ApiException(401, 'Please sign in again.');
  final token = await user.getIdToken();

  final uri = Uri.parse('${RenderApiService.baseUrl}/upload-image');
  final request = http.MultipartRequest('POST', uri)
    ..headers['Authorization'] = 'Bearer $token'
    ..fields['folder'] = _folderKey(folder)
    ..files.add(http.MultipartFile.fromBytes('file', await file.readAsBytes(), filename: file.name));

  final http.StreamedResponse streamed;
  try {
    streamed = await request.send().timeout(const Duration(seconds: 60));
  } on Exception {
    throw const ApiException(0, 'Could not reach the AIKYA server. Check your connection and try again.');
  }
  final response = await http.Response.fromStream(streamed);

  Map<String, dynamic> data = const {};
  try {
    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) data = decoded;
  } catch (_) {}

  if (response.statusCode < 200 || response.statusCode >= 300) {
    throw ApiException(response.statusCode, data['error'] as String? ?? 'Upload failed (${response.statusCode}).');
  }

  final url = data['secure_url'] as String?;
  if (url == null) throw const ApiException(0, 'Upload succeeded but no URL was returned.');
  return url;
}
