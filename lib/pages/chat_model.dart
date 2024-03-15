import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

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
      if (kDebugMode) {
        print("Error in sendMessage: $e");
      }
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
      if (kDebugMode) {
        print("Error in getSessionDetails: $e");
      }
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> fetchLocationsBasedOnSession(String chatSessionId) async {
  List<Map<String, dynamic>> locations = [];

  try {
    final sessionDetails = await getSessionDetails(chatSessionId);
    if (sessionDetails == null) return [];

    final productId = sessionDetails['productId'];
    final itemDoc = await firestore.collection('items').doc(productId).get();
    if (!itemDoc.exists) return [];

    final marketplaceId = itemDoc.data()!['marketplaceId'];
    final marketplaceDoc = await firestore.collection('marketplace').doc(marketplaceId).get();
    if (!marketplaceDoc.exists) return [];

    final List<dynamic> schoolIds = marketplaceDoc.data()!['schoolIds'];

    for (var schoolId in schoolIds) {
      final schoolDoc = await firestore.collection('schools').doc(schoolId).get();
      if (!schoolDoc.exists) continue;

      final data = schoolDoc.data();
      if (data != null) {
        locations.add({
          'schoolName': data['name'],
          'locationName': data['locationName'],
          'address': data['address'],
        });
      }
    }
  } catch (e) {
    if (kDebugMode) {
      print("Error in fetchLocationsBasedOnSession: $e");
    }
  }

  return locations;
}


Future<void> sendLocationMessage(String chatSessionId, String locationName, String schoolName, String address) async {
  try {
    String messageContent = "$locationName at $schoolName"; // Format the content
    await firestore.collection('chat_sessions').doc(chatSessionId).collection('messages').add({
      'senderId': currentUser!.uid,
      'type': 'location', // New field to denote the message type
      'content': messageContent, // The formatted message content
      'locationName': locationName, // Store the locationName
      'schoolName': schoolName, // Store the schoolName
      'address': address, // Store the address
      'timestamp': Timestamp.now(),
    });

    // Optionally, update the last message preview and time in the chat session
    await firestore.collection('chat_sessions').doc(chatSessionId).update({
      'lastMessage': messageContent,
      'lastMessageAt': Timestamp.now(),
    });
  } catch (e) {
    if (kDebugMode) {
      print("Error in sendLocationMessage: $e");
    }
  }
}





}
