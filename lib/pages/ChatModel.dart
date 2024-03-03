import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatModel {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  User? get currentUser => FirebaseAuth.instance.currentUser;

  Stream<QuerySnapshot> getMessagesStream(String chatSessionId) {
    return firestore
        .collection('chat_sessions')
        .doc(chatSessionId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> sendMessage(String chatSessionId, String messageContent) async {
    if (messageContent.isEmpty) return;

    try {
      // Send the message
      await firestore
          .collection('chat_sessions')
          .doc(chatSessionId)
          .collection('messages')
          .add({
        'senderId': currentUser!.uid,
        'content': messageContent,
        'timestamp': Timestamp.now(),
      });

      // Prepare the lastMessage content, trimming to the first 30 characters if necessary
      String lastMessagePreview = messageContent.length > 30
          ? messageContent.substring(0, 30)
          : messageContent;

      // Update the lastMessage field in the chat session document
      await firestore.collection('chat_sessions').doc(chatSessionId).update({
        'lastMessage': lastMessagePreview,
        'lastMessageAt': Timestamp
            .now(), // Optionally update a timestamp for sorting or display
      });
    } catch (e) {
      print("Error in sendMessage: $e");
    }
  }

  Future<Map<String, dynamic>?> getSessionDetails(String chatSessionId) async {
    try {
      DocumentSnapshot sessionDoc =
          await firestore.collection('chat_sessions').doc(chatSessionId).get();
      if (sessionDoc.exists) {
        return sessionDoc.data() as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      print("Error in getSessionDetails: $e");
      return null;
    }
  }
}
