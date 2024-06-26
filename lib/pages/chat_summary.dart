import 'package:cloud_firestore/cloud_firestore.dart';

class ChatSessionSummary {
  String sessionId;
  String buyerName;
  String productName;
  String lastMessage;
  DateTime lastMessageAt;
  String productImageUrl;
  String productId;
  String sellerId;

  ChatSessionSummary({
    required this.sessionId,
    required this.buyerName,
    required this.productName,
    required this.lastMessage,
    required this.lastMessageAt,
    required this.productImageUrl,
    required this.productId,
    required this.sellerId
  });

  // Factory constructor to create a ChatSessionSummary from a Firestore DocumentSnapshot
  factory ChatSessionSummary.fromDocument(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return ChatSessionSummary(
      sessionId: doc.id,
      buyerName: data['buyerName'] ?? 'Unknown',
      productName: data['productName'] ?? 'No Product Name',
      lastMessage: data['lastMessage'] ?? 'No messages yet',
      lastMessageAt: (data['lastMessageAt'] as Timestamp).toDate(),
      productImageUrl: data['productImageUrl'] ?? '',
      productId: data['productId'] ?? '',
      sellerId: data['sellerId'] ?? ''
    );
  }
}
