import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_avatar/flutter_advanced_avatar.dart';
import 'package:intl/intl.dart';
import 'package:uni_market/components/ItemGeneration/item.dart';
import 'package:uni_market/pages/chat_service.dart';
import 'package:uni_market/pages/chat.dart';

SingleChildScrollView itemPageInfo(
    Item itemData, String sellerName, String sellerProfilePic, BuildContext context) {
  return SingleChildScrollView(
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(itemData.name,
                style:
                    const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            Padding(
              padding: const EdgeInsets.only(bottom: 36),
              child: Text('\$${itemData.price}',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.start),
            ),
            Text(
                'Listed ${DateFormat('yMd').format(itemData.dateListed.toDate())} at ${itemData.schoolId}',
                style: const TextStyle(fontSize: 16)),
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 4),
              child: ElevatedButton(
                onPressed: () async {
                  ChatService chatService =
                      ChatService(); // Create an instance of ChatService
                  String? sessionId =
                      await chatService.createChatSession(itemData.id);
                  if (sessionId != null) {
                    if (kDebugMode) {
                      print("Chat session ID: $sessionId");
                    }
                    // Navigate to the ChatPage with sessionId
                    // ignore: use_build_context_synchronously
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatPage(
                            chatSessionId:
                                sessionId), // Ensure this matches the ChatPage constructor parameter name
                      ),
                    );
                  } else {
                    if (kDebugMode) {
                      print("Failed to create chat session.");
                    }
                    // Optionally, show an error message to the user
                  }
                },
                style: ElevatedButton.styleFrom(
                    shape: const BeveledRectangleBorder()),
                child: const Text('Contact Seller'),
              ),
            ),
            const Divider(),
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text('About the product',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text('Product Description: ${itemData.description}'),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text('Product Tags:'),
            ),
            Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
              for (var tag in itemData.tags)
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Chip(
                    label: Text(tag),
                  ),
                )
            ]),
            const Padding(padding: EdgeInsets.only(top: 8), child: Divider()),
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text('Seller Information',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: AdvancedAvatar(
                      size: 96,
                      image: NetworkImage(sellerProfilePic),
                    ),
                  ),
                  Text('Name: $sellerName'),
                  const Text('Items Sold: 2'),
                  const Text('Items Bought: 2'),
                ],
              ),
            ),
          ]),
    ),
  );
}
