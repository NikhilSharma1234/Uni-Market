import 'package:flutter/material.dart';
import 'ChatModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatController {
  final ChatModel _chatModel = ChatModel();
  final TextEditingController messageController = TextEditingController();


  Stream<QuerySnapshot> getMessageStream(String chatSessionId) {
    return _chatModel.getMessagesStream(chatSessionId);
  }

  Future<void> sendMessage(String chatSessionId) async {
    await _chatModel.sendMessage(chatSessionId, messageController.text.trim());
    messageController.clear();
  }

  Future<Map<String, dynamic>?> fetchChatSessionDetails(String chatSessionId) async {
  return await _chatModel.getSessionDetails(chatSessionId);
}
  
  // If you need to expose _chatModel, provide a public getter
  ChatModel get chatModel => _chatModel;

  
}
