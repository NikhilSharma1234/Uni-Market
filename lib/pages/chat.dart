import 'package:flutter/material.dart';
import 'package:uni_market/pages/chat_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';

class ChatPage extends StatefulWidget {
  final String chatSessionId;

  const ChatPage({Key? key, required this.chatSessionId}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ChatController _chatController = ChatController();
  late Future<Map<String, dynamic>?> _sessionDetailsFuture;
  bool canCurrentUserSendMessages = true;

  @override
  void initState() {
    super.initState();
    _sessionDetailsFuture = _chatController
        .fetchChatSessionDetails(widget.chatSessionId)
        .then((sessionDetails) {
      if (sessionDetails != null &&
          (sessionDetails['deletedByUsers'] as List).isNotEmpty) {
        canCurrentUserSendMessages = false;
        _maybeShowDeletedSessionSnackbar();
      }
      return sessionDetails;
    });
  }

  bool _isWidgetActive = true;

  @override
  void dispose() {
    _isWidgetActive = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _sessionDetailsFuture,
      builder: (context, snapshot) {
        String title = "Chat";
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          final data = snapshot.data!;
          title = "${data['buyerName']} - ${data['productName']}";
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(title),
            actions: canCurrentUserSendMessages
                ? [
                    IconButton(
                      icon: const Icon(Icons.location_on),
                      onPressed: _showLocationsModal,
                    ),
                  ]
                : [],
          ),
          body: Padding(
            padding: const EdgeInsets.only(bottom: 32),
            child: Column(
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
                        padding: EdgeInsets.only(
                            bottom: canCurrentUserSendMessages ? 0 : 20),
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
                if (canCurrentUserSendMessages) _buildMessageComposer(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMessageBubble(BuildContext context,
      QueryDocumentSnapshot<Object?> message, bool isSentByMe) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    Color senderBubbleColorLight = Colors.blueGrey.shade700;
    Color receiverBubbleColorLight = Colors.blueGrey.shade700;
    Color senderBubbleColorDark = Colors.white;
    Color receiverBubbleColorDark = Colors.grey.shade200;
    Color locationBubbleColor =
        isDarkMode ? Colors.white : Colors.blueGrey.shade700;

    Color bubbleColor = isSentByMe
        ? (isDarkMode ? senderBubbleColorDark : senderBubbleColorLight)
        : (isDarkMode ? receiverBubbleColorDark : receiverBubbleColorLight);
    Color textColor = isDarkMode ? Colors.black : Colors.white;

    final messageData = message.data() as Map<String, dynamic>?;

    bool isLocationMessage = messageData?.containsKey('type') == true &&
        messageData?['type'] == 'location';

    double screenWidth = MediaQuery.of(context).size.width;
    double bubbleMaxWidth = screenWidth * 0.6;

    if (isLocationMessage) {
      return Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          margin: const EdgeInsets.symmetric(vertical: 10),
          width: bubbleMaxWidth,
          decoration: BoxDecoration(
            color: locationBubbleColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(fontSize: 16, color: textColor),
              children: [
                TextSpan(
                  text: "${message.get('content')} -- ",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: "view location",
                  style: const TextStyle(
                      decoration: TextDecoration.underline,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      _showLocationInfo(
                          message.get('schoolName'), message.get('address'));
                    },
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return Row(
        mainAxisAlignment:
            isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: bubbleMaxWidth,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: bubbleColor,
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
          ),
        ],
      );
    }
  }

  void _maybeShowDeletedSessionSnackbar() {
    if (_isWidgetActive && mounted) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Session Deleted'),
            content:
                const Text('This session has been deleted by the other user.'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
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
              maxLines: 5,
              minLines: 1,
              textInputAction: TextInputAction.send,
              onEditingComplete: () {
                _chatController.sendMessage(widget.chatSessionId);

                FocusScope.of(context).requestFocus(FocusNode());
              },
              inputFormatters: [
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
    final locations = await _chatController
        .fetchLocationsBasedOnSession(widget.chatSessionId);

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            title: const Text(
              "Recommended locations",
              textAlign: TextAlign.center,
            ),
            content: const Text(
              "Suggest a location for the trade of the item",
              textAlign: TextAlign.center,
            ),
            actions: [
              Padding(
                padding:
                    const EdgeInsets.only(top: 8, left: 8, right: 8, bottom: 4),
                child: Column(children: [
                  const Divider(),
                  for (var location in locations) ...[
                    ListTile(
                      title: Text(
                        location['locationName'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                        _chatController.sendLocationMessage(
                          widget.chatSessionId,
                          location['locationName'],
                          location['schoolName'],
                          location['address'],
                        );
                      },
                    ),
                    const Divider()
                  ],
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF041E42),
                        padding: const EdgeInsets.all(16.0),
                        textStyle: const TextStyle(fontSize: 20),
                      ),
                      child: const Text('Close'),
                    ),
                  )
                ]),
              )
            ]);
      },
    );
  }

  void _showLocationInfo(String schoolName, String address) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location Info', textAlign: TextAlign.center),
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
              child: const Text('Close'),
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
