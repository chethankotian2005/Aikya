import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/update_doc.dart';

/// Latest faculty "Post Update" items for the Home feed.
final updatesStreamProvider = StreamProvider.autoDispose<List<UpdateDoc>>((ref) {
  return FirebaseFirestore.instance
      .collection('updates')
      .orderBy('createdAt', descending: true)
      .limit(20)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) {
            try {
              return UpdateDoc.fromJson({...doc.data(), 'id': doc.id});
            } catch (e) {
              debugPrint('Skipping malformed update ${doc.id}: $e');
              return null;
            }
          })
          .whereType<UpdateDoc>()
          .toList());
});
