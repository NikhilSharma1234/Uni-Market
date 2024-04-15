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
      await firestore
          .collection('chat_sessions')
          .doc(chatSessionId)
          .collection('messages')
          .add({
        'senderId': currentUser!.uid,
        'content': messageContent,
        'timestamp': Timestamp.now(),
      });

      String lastMessagePreview = messageContent.length > 30
          ? messageContent.substring(0, 30)
          : messageContent;

      await firestore.collection('chat_sessions').doc(chatSessionId).update({
        'lastMessage': lastMessagePreview,
        'lastMessageAt': Timestamp.now(),
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

  Future<List<Map<String, dynamic>>> fetchLocationsBasedOnSession(
      String chatSessionId) async {
    List<Map<String, dynamic>> locations = [];

    try {
      final sessionDetails = await getSessionDetails(chatSessionId);
      if (sessionDetails == null) return [];

      final productId = sessionDetails['productId'];
      final itemDoc = await firestore.collection('items').doc(productId).get();
      if (!itemDoc.exists) return [];

      final marketplaceId = itemDoc.data()!['marketplaceId'];
      final marketplaceDoc =
          await firestore.collection('marketplace').doc(marketplaceId).get();
      if (!marketplaceDoc.exists) return [];

      final List<dynamic> schoolIds = marketplaceDoc.data()!['schoolIds'];

      for (var schoolId in schoolIds) {
        final schoolDoc =
            await firestore.collection('schools').doc(schoolId).get();
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

  Future<void> sendLocationMessage(String chatSessionId, String locationName,
      String schoolName, String address) async {
    try {
      String userName = await getCurrentUserName();

      String messageContent =
          "$userName SUGEESTED -- $locationName at $schoolName to be the trade location";

      await firestore
          .collection('chat_sessions')
          .doc(chatSessionId)
          .collection('messages')
          .add({
        'senderId': currentUser!.uid,
        'type': 'location',
        'content': messageContent,
        'locationName': locationName,
        'schoolName': schoolName,
        'address': address,
        'timestamp': Timestamp.now(),
      });

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

  Future<void> sendVenmoLink(String chatSessionId) async {
    try {
      String userName = await getCurrentUserName();
      String venmoId = await getVenmoId();

      String messageContent = "$userName SHARED -- Venmo Id: $venmoId";

      await firestore
          .collection('chat_sessions')
          .doc(chatSessionId)
          .collection('messages')
          .add({
        'senderId': currentUser!.uid,
        'type': 'venmo',
        'content': messageContent,
        'url': 'https://www.venmo.com/$venmoId',
        'timestamp': Timestamp.now(),
      });

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

  Future<String> getVenmoId() async {
    String userEmail = currentUser?.email ?? "";
    if (userEmail.isEmpty) {
      return "Unknown User";
    }

    try {
      DocumentSnapshot userDoc =
          await firestore.collection('users').doc(userEmail).get();
      if (userDoc.exists) {
        Map<String, dynamic> userData =
            userDoc.data() as Map<String, dynamic>? ?? {};
        return userData['venmoId'] ?? "Venmo Id not set by user";
      } else {
        return "User Not Found";
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching user name: $e");
      }
      return "Error";
    }
  }

  Future<String> getCurrentUserName() async {
    String userEmail = currentUser?.email ?? "";
    if (userEmail.isEmpty) {
      return "Unknown User";
    }

    try {
      DocumentSnapshot userDoc =
          await firestore.collection('users').doc(userEmail).get();
      if (userDoc.exists) {
        Map<String, dynamic> userData =
            userDoc.data() as Map<String, dynamic>? ?? {};
        return userData['name'] ?? "No Name";
      } else {
        return "User Not Found";
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching user name: $e");
      }
      return "Error";
    }
  }

  Stream<bool> getDeletedByUsersStream(String chatSessionId) {
    return firestore
        .collection('chat_sessions')
        .doc(chatSessionId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) {
        return true; // Assume can't send messages if session doesn't exist
      }
      final data = snapshot.data();
      final deletedByUsers = List.from(data?['deletedByUsers'] ?? []);
      return deletedByUsers.isEmpty; // Can send messages if array is empty
    });
  }
}
