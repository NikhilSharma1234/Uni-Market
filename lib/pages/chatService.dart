import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? currentUser = FirebaseAuth.instance.currentUser;

  Future<String?> getUserEmail(String productId) async {
    try {
      DocumentSnapshot productSnapshot =
          await _firestore.collection('items').doc(productId).get();

      if (!productSnapshot.exists) {
        print("Error: No product found with the provided ID: $productId");
        return null;
      }
      return productSnapshot['sellerId'];
    } catch (e) {
      print("Error fetching seller email: $e");
      return null;
    }
  }

  Future<String?> getProductName(String productId) async {
    try {
      DocumentSnapshot productSnapshot =
          await _firestore.collection('items').doc(productId).get();

      if (!productSnapshot.exists) {
        print("Error: No product found with the provided ID: $productId");
        return null;
      }
      return productSnapshot['name'];
    } catch (e) {
      print("Error fetching product name: $e");
      return null;
    }
  }

  Future<String?> getBuyerName(String email) async {
    try {
      DocumentSnapshot userSnapshot =
          await _firestore.collection('users').doc(email).get();

      if (!userSnapshot.exists) {
        print("Error: No user found with the provided email: $email");
        return null;
      }
      return userSnapshot['name'];
    } catch (e) {
      print("Error fetching user name: $e");
      return null;
    }
  }

  Future<String?> createChatSession(String productId) async {
    if (currentUser == null || currentUser!.email == null) {
      print("Error: Current user is null or has no email");
      return null;
    }

    String? receiverEmail = await getUserEmail(productId);
    if (receiverEmail == null) {
      print("Error: Could not find seller's email for product ID: $productId");
      return null;
    }

    String senderEmail = currentUser!.email!;
    String? buyerName = await getBuyerName(senderEmail);
    String? productName = await getProductName(productId);

    List<String> participantIds = [senderEmail, receiverEmail];
    participantIds.sort();
    String participantIdsKey = participantIds.join(':');

    final QuerySnapshot existingChatSessionQuery = await _firestore
        .collection('chat_sessions')
        .where('participantIdsKey', isEqualTo: participantIdsKey)
        .where('productId', isEqualTo: productId)
        .limit(1)
        .get();

    if (existingChatSessionQuery.docs.isNotEmpty) {
      return existingChatSessionQuery.docs.first.id;
    }

    DocumentReference chatSessionRef =
        await _firestore.collection('chat_sessions').add({
      'productName': productName,
      'buyerName': buyerName,
      'participantIds': participantIds,
      'productId': productId,
      'createdAt': Timestamp.now(),
      'lastMessage': '',
      'lastMessageAt': Timestamp.now(),
    });

    // Update the 'chats' field in both the sender's and receiver's user documents with the new session ID
    await _firestore.collection('users').doc(senderEmail).update({
      'chats': FieldValue.arrayUnion([chatSessionRef.id]),
    }).catchError((e) => print("Error updating sender's chat list: $e"));

    await _firestore.collection('users').doc(receiverEmail).update({
      'chats': FieldValue.arrayUnion([chatSessionRef.id]),
    }).catchError((e) => print("Error updating receiver's chat list: $e"));

    return chatSessionRef.id;
  }
}
