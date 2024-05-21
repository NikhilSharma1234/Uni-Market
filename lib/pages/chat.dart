// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:uni_market/pages/chat_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:intl/intl.dart';
import 'package:uni_market/image_data_store.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:widget_and_text_animator/widget_and_text_animator.dart';

class ChatPage extends StatefulWidget {
  final String chatSessionId;
  final String sellerId;
  final String productId;

  const ChatPage(
      {Key? key,
      required this.chatSessionId,
      required this.productId,
      required this.sellerId})
      : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ChatController _chatController = ChatController();
  late bool _seenTransactionWarning = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const InkWell(
          onTap: null,
          child: AppBarTitleWithImage(
            title: 'Chat',
            imagePath: null,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.location_on),
            onPressed: _showLocationsModal,
          ),
          const IconButton(
            icon: Icon(Icons.block),
            onPressed: null,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 32),
        child: Column(
          children: [
            Expanded(
                child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.only(bottom: 0),
              itemCount: 3,
              itemBuilder: (context, index) {
                var message = [
                  {
                    'content': 'I\'ll see you there!',
                    'timestamp': Timestamp.now(),
                    'sender': false
                  },
                  {
                    'type': 'location',
                    'content':
                        'Current user suggested -- Joe Crowley Student Union at The University of Nevada, Reno to be the trade location',
                    'timestamp': Timestamp.now(),
                    'sender': true
                  },
                  {
                    'content': 'I want to buy your item',
                    'timestamp': Timestamp.now(),
                    'sender': true
                  },
                  {
                    'content': 'Hello??',
                    'timestamp': Timestamp.now(),
                    'sender': true
                  }
                ][index];
                return _buildMessageBubble(context, message);
              },
            )),
            _buildMessageComposer(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context, var message) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    bool isSentByMe = message['sender'];

    Color senderBubbleColorLight = Colors.blueGrey.shade700;
    Color receiverBubbleColorLight = const Color.fromARGB(255, 68, 65, 65);
    Color senderBubbleColorDark = Colors.white;
    Color receiverBubbleColorDark = const Color.fromARGB(150, 198, 220, 248);
    Color locationBubbleColor = isDarkMode
        ? const Color.fromARGB(255, 203, 196, 196)
        : const Color.fromARGB(255, 43, 79, 128);

    Color bubbleColor = isSentByMe
        ? (isDarkMode ? senderBubbleColorDark : senderBubbleColorLight)
        : (isDarkMode ? receiverBubbleColorDark : receiverBubbleColorLight);
    Color textColor = isDarkMode ? Colors.black : Colors.white;
    Color transactionTextColor = isDarkMode ? Colors.black : Colors.white;

    final messageData = message as Map<String, dynamic>;

    bool isLocationMessage = messageData.containsKey('type') == true &&
        messageData['type'] == 'location';
    bool isTransactionMessage = messageData.containsKey('type') == true &&
        messageData['type'] == 'transaction';
    bool isVenmoLink = messageData.containsKey('type') == true &&
        messageData['type'] == 'venmo';

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
                  text: "${message['content']} -- ",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                    text: "view location",
                    style: const TextStyle(
                        decoration: TextDecoration.underline,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold),
                    recognizer: TapGestureRecognizer()..onTap = null),
              ],
            ),
          ),
        ),
      );
    } else if (isTransactionMessage) {
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
                  text: "${message['content']}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      );
    } else if (isVenmoLink) {
      return Center(
        child: SizedBox(
          width: screenWidth < 1500 ? 125 : bubbleMaxWidth * .15,
          child: WidgetAnimator(
            atRestEffect: WidgetRestingEffects.wave(effectStrength: 0.4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              margin: const EdgeInsets.symmetric(vertical: 10),
              width: screenWidth < 1500 ? 125 : bubbleMaxWidth * .15,
              decoration: BoxDecoration(
                color: locationBubbleColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  InkWell(
                      onTap: () async {
                        _showTransactionWarning(context, message);
                      },
                      child: Image.asset("assets/venmo_logo_title.png")),
                  Column(
                    children: [
                      Text(
                        message['content'],
                        style: TextStyle(
                          color: transactionTextColor,
                          fontSize: 9.0,
                        ),
                      )
                    ],
                  ),
                ],
              ),
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
                    message['content'],
                    style: TextStyle(color: textColor),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      DateFormat('dd/MM/yy hh:mm a')
                          .format(message['timestamp'].toDate()),
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
              onEditingComplete: null,
              inputFormatters: [
                if (kIsWeb) FilteringTextInputFormatter.deny(RegExp('[\n]')),
              ],
            ),
          ),
          const IconButton(
            icon: Icon(Icons.send),
            onPressed: null,
          ),
        ],
      ),
    );
  }

  void _showTransactionWarning(BuildContext context, var message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('WARNING!'),
          content: const Text(
              'Do not proceed with venmo transactions until you have desired items in hand'),
          actions: [
            TextButton(
              onPressed: () async {
                if (context.mounted) {
                  setState(() {
                    _seenTransactionWarning = true;
                  });
                  Navigator.of(context).pop();
                  final venmoUrl = Uri.parse(message.get('url'));
                  if (_seenTransactionWarning) {
                    if (await canLaunchUrl(venmoUrl)) {
                      await launchUrl(venmoUrl);
                    } else {
                      throw 'Could not launch $venmoUrl';
                    }
                  }
                }
              },
              child: const Text('Click to Continue'),
            ),
          ],
        );
      },
    );
  }

  void _showLocationsModal() async {
    final locations = [
      {'locationName': 'Joe Crowley Student Union'},
      {'locationName': 'Dandini Campus - TMCC'}
    ];

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
                        location['locationName']!,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                        // _chatController.sendLocationMessage(
                        //   widget.chatSessionId,
                        //   location['locationName']!,
                        //   location['schoolName']!,
                        //   location['address']!,
                        // );
                      },
                    ),
                    const Divider()
                  ],
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
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
}

class AppBarTitleWithImage extends StatelessWidget {
  final String title;
  final String? imagePath; // Make this nullable

  const AppBarTitleWithImage({
    Key? key,
    required this.title,
    this.imagePath, // Now nullable
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // If no imagePath is provided, just return the title
    if (imagePath == null) {
      return Text(title);
    }

    // Proceed with fetching the image if imagePath is provided
    return FutureBuilder<String?>(
      future: ImageDataStore().getImageUrl(imagePath!),
      builder: (context, snapshot) {
        Widget leadingWidget = const CircleAvatar(
          backgroundColor: Colors.grey,
          child: Icon(Icons.person, color: Colors.white),
        );

        if (snapshot.connectionState == ConnectionState.waiting) {
          leadingWidget = const CircleAvatar(
            backgroundColor: Colors.grey,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          );
        } else if (snapshot.hasData) {
          leadingWidget = CircleAvatar(
            backgroundImage: NetworkImage(snapshot.data!),
          );
        }

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            leadingWidget,
            const SizedBox(width: 8),
            Expanded(child: Text(title, overflow: TextOverflow.ellipsis)),
          ],
        );
      },
    );
  }
}
