import 'package:flutter/material.dart';
import 'ChatController.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatPage extends StatefulWidget {
  final String chatSessionId;

  const ChatPage({Key? key, required this.chatSessionId}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ChatController _chatController = ChatController();
  late Future<Map<String, dynamic>?> _sessionDetailsFuture;

  @override
  void initState() {
    super.initState();
    _sessionDetailsFuture =
        _chatController.fetchChatSessionDetails(widget.chatSessionId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _sessionDetailsFuture,
      builder: (context, snapshot) {
        String title = "Chat"; // Default title
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          final data = snapshot.data!;
          title = "${data['buyerName']} - ${data['productName']}";
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(title),
          ),
          body: Column(
            children: [
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream:
                      _chatController.getMessageStream(widget.chatSessionId),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    return ListView.builder(
                      reverse: true,
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        var message = snapshot.data!.docs[index];
                        bool isSentByMe = message['senderId'] ==
                            _chatController.chatModel.currentUser?.uid;
                        return _buildMessageBubble(
                            context, message, isSentByMe);
                      },
                    );
                  },
                ),
              ),
              _buildMessageComposer(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMessageBubble(
      BuildContext context, QueryDocumentSnapshot message, bool isSentByMe) {
    // Determine if we are in dark mode or light mode
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Define bubble colors for light mode
    Color senderBubbleColorLight = Colors.blueGrey.shade700;
    Color receiverBubbleColorLight = Colors.blueGrey.shade700;

    // Define bubble colors for dark mode
    Color senderBubbleColorDark = Colors.white;
    Color receiverBubbleColorDark = Colors.grey.shade200;

    // Set bubble color and text color based on the theme and sender
    Color bubbleColor;
    Color textColor;

    if (isDarkMode) {
      bubbleColor =
          isSentByMe ? senderBubbleColorDark : receiverBubbleColorDark;
      textColor = Colors.black;
    } else {
      bubbleColor =
          isSentByMe ? senderBubbleColorLight : receiverBubbleColorLight;
      textColor = Colors.white;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate dynamic width here, e.g., a percentage of the parent's width
        double bubbleMaxWidth =
            constraints.maxWidth * 0.8; // Example: 80% of parent width

        return Row(
          mainAxisAlignment:
              isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: bubbleMaxWidth, // Use dynamic width
              ),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: bubbleColor, // Use the determined bubble color
                  borderRadius: isSentByMe
                      ? const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        )
                      : const BorderRadius.only(
                          topRight: Radius.circular(20),
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message['content'],
                      style: TextStyle(color: textColor),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        message['timestamp'].toDate().toString(),
                        style: TextStyle(
                          color: textColor.withOpacity(0.7),
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        );
      },
    );
  }

  Widget _buildMessageComposer() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _chatController.messageController,
              decoration: const InputDecoration(
                labelText: "Type a message...",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0))),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () => _chatController.sendMessage(widget.chatSessionId),
          ),
        ],
      ),
    );
  }
}
