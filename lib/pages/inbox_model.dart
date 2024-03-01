// inbox_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'inbox_controller.dart';


class InboxModel {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<ChatSessionSummary>> getChatSummaries(String userEmail) {
    return _firestore.collection('users').doc(userEmail).snapshots().asyncMap((userDoc) async {
      List<String> chatSessionIds = List.from(userDoc.data()?['chats'] ?? []);
      List<ChatSessionSummary> summaries = [];

      for (String sessionId in chatSessionIds) {
        var chatSessionDoc = await _firestore.collection('chat_sessions').doc(sessionId).get();
        var data = chatSessionDoc.data() ?? {};

        // Create a ChatSessionSummary object, now including productName
        var summary = ChatSessionSummary(
          sessionId: sessionId,
          buyerName: data['buyerName'] ?? 'Unknown',
          productName: data['productName'] ?? 'No Product Name',  // Fetch and include productName
          lastMessage: data['lastMessage'] ?? 'No messages yet',
          lastMessageAt: (data['lastMessageAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
        summaries.add(summary);
      }

      // Sort summaries by 'lastMessageAt' in descending order
      summaries.sort((a, b) => b.lastMessageAt.compareTo(a.lastMessageAt));
      return summaries;
    });
  }
}
