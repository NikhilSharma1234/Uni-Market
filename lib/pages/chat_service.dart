import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:uni_market/data_models/current_user.dart';
import 'package:uni_market/data_store.dart' as data_store;

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CurrentUser currentUser = data_store.user;

  Future<String?> getUserEmail(String productId) async {
    try {
      DocumentSnapshot productSnapshot =
          await _firestore.collection('items').doc(productId).get();

      if (!productSnapshot.exists) {
        if (kDebugMode) {
          print("Error: No product found with the provided ID: $productId");
        }
        return null;
      }
      return productSnapshot['sellerId'];
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching seller email: $e");
      }
      return null;
    }
  }

  Future<String?> getProductName(String productId) async {
    try {
      DocumentSnapshot productSnapshot =
          await _firestore.collection('items').doc(productId).get();

      if (!productSnapshot.exists) {
        if (kDebugMode) {
          print("Error: No product found with the provided ID: $productId");
        }
        return null;
      }
      return productSnapshot['name'];
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching product name: $e");
      }
      return null;
    }
  }

  Future<String?> getBuyerName(String email) async {
    try {
      DocumentSnapshot userSnapshot =
          await _firestore.collection('users').doc(email).get();

      if (!userSnapshot.exists) {
        if (kDebugMode) {
          print("Error: No user found with the provided email: $email");
        }
        return null;
      }
      return userSnapshot['name'];
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching user name: $e");
      }
      return null;
    }
  }

  Future<String?> createChatSession(String productId) async {
    if (currentUser.email == "") {
      if (kDebugMode) {
        print("Error: Current user is null or has no email");
      }
      return null;
    }

    String? receiverEmail = await getUserEmail(productId);
    if (receiverEmail == null) {
      if (kDebugMode) {
        print(
            "Error: Could not find seller's email for product ID: $productId");
      }
      return null;
    }

    String senderEmail = currentUser.email;

    // Prevent creating a chat session with oneself
    //Commented out the if statement to allow for testing
    if (senderEmail == receiverEmail) {
      if (kDebugMode) {
        print("Error: Seller and buyer emails are the same");
      }
      return null;
    }

    String? buyerName = await getBuyerName(senderEmail);
    String? productName = await getProductName(productId);

    // Generate composite key
    List<String> participantIds = [senderEmail, receiverEmail];
    List<String> participantIdsSorted = participantIds..sort();
    participantIdsSorted.sort();
    String participantIdsKey = participantIds.join(':');

    // Check for existing session
    final QuerySnapshot existingChatSessionQuery = await _firestore
        .collection('chat_sessions')
        .where('participantIdsKey', isEqualTo: participantIdsKey)
        .where('productId', isEqualTo: productId)
        .limit(1)
        .get();

    // if (existingChatSessionQuery.docs.isNotEmpty) {
    //   return existingChatSessionQuery.docs.first.id;
    // }

    for (var doc in existingChatSessionQuery.docs) {
      var data =
          doc.data() as Map<String, dynamic>; // Cast to Map<String, dynamic>
      var deletedByUsers = data['deletedByUsers'] as List<dynamic>? ?? [];

      //if deletedByUsers is empty, return the chat session ID
      if (deletedByUsers.isEmpty) {
        print("Chat session already exists");
        print(doc.id);
        return doc.id;
      }
    }

    // Create a new chat session if none exists
    DocumentReference chatSessionRef =
        await _firestore.collection('chat_sessions').add({
      'participantIdsKey': participantIdsKey, // Store the composite key
      'productName': productName,
      'buyerName': buyerName,
      'participantIds': participantIds,
      'productId': productId,
      'createdAt': Timestamp.now(),
      'lastMessage': '',
      'lastMessageAt': Timestamp.now(),
      "deletedByUsers": []
    });

    return chatSessionRef.id;
  }
}
