class ChatSessionSummary {
  String sessionId;
  String buyerName;
  String productName;  // Add this field
  String lastMessage;
  DateTime lastMessageAt;

  ChatSessionSummary({
    required this.sessionId,
    required this.buyerName,
    required this.productName,  // Update constructor
    required this.lastMessage,
    required this.lastMessageAt,
  });
}
