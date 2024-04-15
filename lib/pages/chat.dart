// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uni_market/helpers/functions.dart';
import 'package:uni_market/pages/chat_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:intl/intl.dart';
import 'package:uni_market/data_store.dart' as data_store;
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
  late Future<Map<String, dynamic>?> _sessionDetailsFuture;
  bool _isDialogShown = false; // Add this flag

  bool _isWidgetActive = true;

  @override
  void initState() {
    super.initState();
    _sessionDetailsFuture =
        _chatController.fetchChatSessionDetails(widget.chatSessionId);
  }

  @override
  void dispose() {
    _isWidgetActive = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: _chatController.getDeletedByUsersStream(widget.chatSessionId),
      builder: (context, canSendSnapshot) {
        if (canSendSnapshot.hasData &&
            !canSendSnapshot.data! &&
            !_isDialogShown) {
          _isDialogShown = true; // Indicate that dialog is being shown
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _maybeShowDeletedSessionSnackbar();
          });
        }
        bool canCurrentUserSendMessages = canSendSnapshot.data ?? true;

        return FutureBuilder<Map<String, dynamic>?>(
          future: _sessionDetailsFuture,
          builder: (context, sessionSnapshot) {
            String title = "Chat";
            String imagePath = "";
            if (sessionSnapshot.connectionState == ConnectionState.done &&
                sessionSnapshot.hasData) {
              final data = sessionSnapshot.data!;
              title = "${data['buyerName']} - ${data['productName']}";
              imagePath = data['productImageUrl'] ?? "";
            }

            return Scaffold(
              appBar: AppBar(
                title: AppBarTitleWithImage(
                  title: title,
                  imagePath: imagePath,
                ),
                actions: canCurrentUserSendMessages
                    ? [
                        IconButton(
                          icon: const Icon(Icons.location_on),
                          onPressed: _showLocationsModal,
                        ),
                        ...data_store.user.email == widget.sellerId
                            ? [
                                IconButton(
                                  icon: const Icon(Icons.sell),
                                  onPressed: _confirmSell,
                                )
                              ]
                            : [],
                        IconButton(
                          icon: const Icon(Icons.block),
                          onPressed: _confirmBlock,
                        ),
                        IconButton(
                            onPressed: _showVenmoLink,
                            icon: Image.asset('../assets/venmo_logo.png')),
                      ]
                    : [],
              ),
              body: Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: Column(
                  children: [
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: _chatController
                            .getMessageStream(widget.chatSessionId),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(
                                child: CircularProgressIndicator());
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
    bool isTransactionMessage = messageData?.containsKey('type') == true &&
        messageData?['type'] == 'transaction';
    bool isVenmoLink = messageData?.containsKey('type') == true &&
        messageData?['type'] == 'venmo';

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
                  text: "${message.get('content')}",
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
                        final venmoUrl = Uri.parse(message.get('url'));
                        if (!await launchUrl(venmoUrl)) {
                          throw (Exception('Could not launch $venmoUrl'));
                        }
                      },
                      child: Image.asset("../assets/venmo_logo_+_title.webp")),
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
                    message.get('content'),
                    style: TextStyle(color: textColor),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      DateFormat('dd/MM/yy hh:mm a')
                          .format(message.get('timestamp').toDate()),
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
            content: const Text('This session has been deleted.'),
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

  void _showVenmoLink() async {
    _chatController.sendVenmoLink(widget.chatSessionId);
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

  void _confirmSell() async {
    var snapshot = await FirebaseFirestore.instance
        .collection('chat_sessions')
        .doc(widget.chatSessionId)
        .get();
    List<dynamic> participants = snapshot.data()!['participantIds'];
    String buyerId =
        participants.where((email) => email != widget.sellerId).toList()[0];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            title: const Text(
              "Confirm Transaction",
              textAlign: TextAlign.center,
            ),
            content: Text(
              "Would you like to mark this item as sold to $buyerId? Other chats for this item will be notified and deleted from your feed.",
              textAlign: TextAlign.center,
            ),
            actions: [
              ElevatedButton(
                  onPressed: () async {
                    await FirebaseFirestore.instance
                        .collection('items')
                        .doc(widget.productId)
                        .update({'buyerId': data_store.user.email});
                    var snapshots = await FirebaseFirestore.instance
                        .collection('chat_sessions')
                        .where('productId', isEqualTo: widget.productId)
                        .get();
                    String messageContent = "This item has now been sold";
                    for (var snapshot in snapshots.docs) {
                      await FirebaseFirestore.instance
                          .collection('chat_sessions')
                          .doc(snapshot.id)
                          .collection('messages')
                          .add({
                        'senderId': FirebaseAuth.instance.currentUser!.uid,
                        'type': 'transaction',
                        'content': messageContent,
                        'timestamp': Timestamp.now(),
                      });
                      await FirebaseFirestore.instance
                          .collection('chat_sessions')
                          .doc(snapshot.id)
                          .update({
                        'lastMessage': messageContent,
                        'lastMessageAt': Timestamp.now(),
                        'deletedByUsers':
                            FieldValue.arrayUnion([widget.sellerId])
                      });
                    }
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Yes')),
              ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('No'))
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

  void _confirmBlock() async {
    var snapshot = await FirebaseFirestore.instance
        .collection('chat_sessions')
        .doc(widget.chatSessionId)
        .get();
    List<dynamic> participants = snapshot.data()!['participantIds'];
    String otherUser = participants
        .where((email) => email != data_store.user.email)
        .toList()[0];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            title: const Text(
              "Confirm Block",
              textAlign: TextAlign.center,
            ),
            content: const Text(
              "Would you to block this user? Any chats open with this user will be deleted. You will no longer be able to view any of their items. They will also not be able to view any of your items.",
              textAlign: TextAlign.center,
            ),
            actions: [
              ElevatedButton(
                  onPressed: () async {
                    if (data_store.user.blockedUsers.contains(otherUser)) {
                      return;
                    }
                    data_store.user.blockedUsers.add(otherUser);
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(data_store.user.email)
                        .update({'blockedUsers': data_store.user.blockedUsers});
                    var sellerUserObject = await FirebaseFirestore.instance
                        .collection('users')
                        .doc(otherUser)
                        .get();
                    if (!sellerUserObject['blockedUsers']
                        .contains(data_store.user.email)) {
                      var blockedByOtherUser = sellerUserObject['blockedUsers'];
                      blockedByOtherUser.add(data_store.user.email);
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(sellerUserObject['email'])
                          .update({'blockedUsers': blockedByOtherUser});
                    }
                    var snapshots = await FirebaseFirestore.instance
                        .collection('chat_sessions')
                        .where('participantIds', whereIn: [
                      [data_store.user.email, otherUser],
                      [otherUser, data_store.user.email],
                    ]).get();
                    for (var snapshot in snapshots.docs) {
                      await FirebaseFirestore.instance
                          .collection('chat_sessions')
                          .doc(snapshot.id)
                          .update({
                        'deletedByUsers':
                            FieldValue.arrayUnion([data_store.user.email])
                      });
                    }
                    await loadCurrentUser(data_store.user.email);

                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Yes')),
              ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('No'))
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
