import 'package:flutter/material.dart';
import 'package:uni_market/pages/chat_model.dart';
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

  Future<Map<String, dynamic>?> fetchChatSessionDetails(
      String chatSessionId) async {
    return await _chatModel.getSessionDetails(chatSessionId);
  }
  
  Future<List<Map<String, dynamic>>> fetchLocationsBasedOnSession(String chatSessionId) async {
  return await _chatModel.fetchLocationsBasedOnSession(chatSessionId);
  }

  Future<void> sendLocationMessage(String chatSessionId, String locationName, String schoolName, String address) async {
  await _chatModel.sendLocationMessage(chatSessionId, locationName, schoolName, address);
}

  Future<void> sendVenmoLink(BuildContext context, String chatSessionId) async {
    await _chatModel.sendVenmoLink(context, chatSessionId);
  }


Stream<bool> getDeletedByUsersStream(String chatSessionId) {
  return _chatModel.getDeletedByUsersStream(chatSessionId);
}



  // If you need to expose _chatModel, provide a public getter
  ChatModel get chatModel => _chatModel;
}
