import 'package:flutter/material.dart';
import 'package:uni_market/pages/chat_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';


class ChatPage extends StatefulWidget {
  final String chatSessionId;

  const ChatPage({Key? key, required this.chatSessionId}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
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
            actions: [
              IconButton(
                icon: const Icon(Icons.location_on),
                onPressed:
                    _showLocationsModal, // Directly use the method without passing context.
              ),
            ],
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

  Widget _buildMessageBubble(BuildContext context, QueryDocumentSnapshot<Object?> message, bool isSentByMe) {
  // Determine if we are in dark mode or light mode
  bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

  // Define bubble colors for light mode and dark mode
  Color senderBubbleColorLight = Colors.blueGrey.shade700;
  Color receiverBubbleColorLight = Colors.blueGrey.shade700;
  Color senderBubbleColorDark = Colors.white;
  Color receiverBubbleColorDark = Colors.grey.shade200;

  // Set bubble color and text color based on the theme and sender
  Color bubbleColor = isSentByMe ? (isDarkMode ? senderBubbleColorDark : senderBubbleColorLight) : (isDarkMode ? receiverBubbleColorDark : receiverBubbleColorLight);
  Color textColor = isDarkMode ? Colors.black : Colors.white;

  final messageData = message.data() as Map<String, dynamic>?;

  // Use the safely casted Map to check for the 'type' key.
  bool isLocationMessage = messageData?.containsKey('type') == true && messageData?['type'] == 'location';

  if (isLocationMessage) {
    // Special styling for location messages
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        margin: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white, // Light blue color for location message
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "${message.get('content')}", // Display the formatted content
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black, // Text color for location message
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 5),
            TextButton(
              onPressed: () {
                // Implement functionality to view the location
                // For example, you might want to open the location in a map view
              },
              child: Text(
                "View Location",
                style: TextStyle(decoration: TextDecoration.underline, color: Colors.blue),
              ),
            ),
          ],
        ),
      ),
    );
  } else {
    // Regular text message layout
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate dynamic width here, e.g., a percentage of the parent's width
        double bubbleMaxWidth = constraints.maxWidth * 0.8; // Example: 80% of parent width

        return Row(
          mainAxisAlignment: isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: bubbleMaxWidth, // Use dynamic width
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                      message.get('content'),
                      style: TextStyle(color: textColor),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        message.get('timestamp').toDate().toString(),
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
                  borderRadius: BorderRadius.all(Radius.circular(20.0)),
                ),
              ),
              keyboardType: TextInputType.multiline,
              maxLines: 5, // Allows the input box to expand up to 5 lines
              minLines: 1, // Starts with a single line
              textInputAction: TextInputAction.send,
              onEditingComplete: () {
                _chatController.sendMessage(widget.chatSessionId);
                // Reset focus to the text field after sending message to allow continuous typing
                FocusScope.of(context).requestFocus(FocusNode());
              },
              inputFormatters: [
                // Prevent new line characters on web
                if (kIsWeb) FilteringTextInputFormatter.deny(RegExp('[\n]')),
              ],
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

  void _showLocationsModal() async {
  final locations = await _chatController.fetchLocationsBasedOnSession(widget.chatSessionId);

  // Check if the widget is still mounted (i.e., part of the widget tree) after the async gap.
  if (!mounted) return;

  // Since we're now inside the 'if' block, we're sure 'context' can be safely used.
  showDialog(
    context: context, // Directly using 'context' from the stateful widget.
    builder: (BuildContext context) {
      return Dialog(
        child: Container(
          height: 200.0,
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: locations.length,
            itemBuilder: (BuildContext context, int index) {
              var location = locations[index];
              return ListTile(
                title: Text(location['locationName']),
                trailing: IconButton(
                  icon: const Icon(Icons.info_outline),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                    _showLocationInfo(location['schoolName'], location['address']);
                  },
                ),
                onTap: () {
  Navigator.of(context).pop(); // Close the dialog
  _chatController.sendLocationMessage(
    widget.chatSessionId,
    location['locationName'],
    location['schoolName'],
    location['address'],
  );
},
              );
            },
          ),
        ),
      );
    },
  );
}


  void _showLocationInfo(String schoolName, String address) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location Info'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('School: $schoolName'),
                const SizedBox(height: 8.0),
                Text('Address: $address'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
