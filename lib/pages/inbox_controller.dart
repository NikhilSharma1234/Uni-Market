//inbox_controller.dart

import 'package:flutter/material.dart';
import 'inbox_model.dart';
import 'chat.dart';
import 'chat_summary.dart';

export 'chat_summary.dart';

class InboxController {
  final InboxModel _model = InboxModel();

  Stream<List<ChatSessionSummary>> chatSummariesStream(String userEmail) {
    return _model.getChatSummaries(userEmail);
  }

  void onChatSelected(BuildContext context, String sessionId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(chatSessionId: sessionId),
      ),
    );
  }
}
