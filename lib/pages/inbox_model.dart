import 'package:cloud_firestore/cloud_firestore.dart';
import 'inbox_controller.dart'; // This should contain the definition for ChatSessionSummary.

class InboxModel {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<ChatSessionSummary>> getChatSummaries(String userEmail) {
    return _firestore
        .collection('chat_sessions')
        .where('participantIds', arrayContains: userEmail)
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
          return ChatSessionSummary.fromDocument(doc);
        }).toList());
  }
}
