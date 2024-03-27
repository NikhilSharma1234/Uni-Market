import 'package:cloud_firestore/cloud_firestore.dart';
import 'inbox_controller.dart';

class InboxModel {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<ChatSessionSummary>> getChatSummaries(String userEmail) {
    return _firestore
        .collection('chat_sessions')
        .where('participantIds', arrayContains: userEmail)
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            // Ensure 'deletedByUsers' is treated as an empty list if null
            .where((doc) => !((doc.data()['deletedByUsers'] as List? ?? [])
                .contains(userEmail)))
            // Check that 'lastMessage' is not empty
            .where((doc) =>
                (doc.data()['lastMessage'] as String?)?.isNotEmpty ?? false)
            .map((doc) => ChatSessionSummary.fromDocument(doc))
            .toList());
  }

  Future<void> markChatSessionAsDeleted(
      String sessionId, String userEmail) async {
    DocumentReference sessionRef =
        _firestore.collection('chat_sessions').doc(sessionId);
    await sessionRef.update({
      'deletedByUsers': FieldValue.arrayUnion([userEmail]),
    });
  }
}
