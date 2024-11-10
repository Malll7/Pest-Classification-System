// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addTodoItem(String userId, String title) {
    return _db.collection('users').doc(userId).collection('todos').add({
      'title': title,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteTodoItem(String userId, String itemId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('todos')
        .doc(itemId)
        .delete();
  }

  Stream<List<Map<String, dynamic>>> getTodoList(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('todos')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {'id': doc.id, 'title': doc['title']})
            .toList());
  }

  Future<String?> getUsername(String userId) async {
    try {
      DocumentSnapshot userDoc =
          await _db.collection('users').doc(userId).get();
      return userDoc['username'];
    } catch (e) {
      print('Error fetching username: $e');
      return null;
    }
  }

  Future<void> updateUsername(String userId, String newUsername) async {
    try {
      await _db.collection('users').doc(userId).update({
        'username': newUsername,
      });
    } catch (e) {
      print('Error updating username: $e');
    }
  }

  Future<void> saveFeedback(String userId, String feedback) {
    return _db.collection('feedback').add({
      'userId': userId,
      'feedback': feedback,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
