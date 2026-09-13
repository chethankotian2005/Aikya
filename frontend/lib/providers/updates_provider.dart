import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/update_doc.dart';

final updatesStreamProvider = StreamProvider.autoDispose<List<UpdateDoc>>((ref) {
  return FirebaseFirestore.instance
      .collection('updates')
      .orderBy('createdAt', descending: true)
      .limit(20)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) => UpdateDoc.fromJson(doc.data())).toList();
  });
});
