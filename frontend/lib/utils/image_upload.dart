import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

/// Uploads a picked image and returns its download URL.
///
/// Uses bytes rather than `putFile` so it also works in the Flutter web
/// build, and always sets an image content type (storage.rules require it).
Future<String> uploadImage(XFile file, String path) async {
  final bytes = await file.readAsBytes();
  final ref = FirebaseStorage.instance.ref(path);
  await ref.putData(bytes, SettableMetadata(contentType: file.mimeType ?? _guessImageType(file.name)));
  return ref.getDownloadURL();
}

/// A collision-safe file name for per-user upload folders.
String uniqueImageName(XFile file) {
  final safe = file.name.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
  return '${DateTime.now().millisecondsSinceEpoch}_$safe';
}

String _guessImageType(String name) {
  final lower = name.toLowerCase();
  if (lower.endsWith('.png')) return 'image/png';
  if (lower.endsWith('.webp')) return 'image/webp';
  if (lower.endsWith('.gif')) return 'image/gif';
  return 'image/jpeg';
}
