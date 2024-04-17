import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_avatar/flutter_advanced_avatar.dart';
import 'package:intl/intl.dart';
import 'package:uni_market/components/ItemGeneration/item.dart';
import 'package:uni_market/data_store.dart';
import 'package:uni_market/helpers/functions.dart';
import 'package:uni_market/pages/chat_service.dart';
import 'package:uni_market/pages/chat.dart';
import 'package:uni_market/data_store.dart' as data_store;

class ItemPageInfo extends StatefulWidget {
  final Item itemData;
  final String sellerName;
  final String sellerProfilePic;
  final int? sellerItemsBought;
  final int? sellerItemsSold;
  final bool noAction;

  const ItemPageInfo(
      {Key? key,
      required this.itemData,
      required this.sellerName,
      required this.sellerProfilePic,
      required this.sellerItemsBought,
      required this.sellerItemsSold,
      required this.noAction})
      : super(key: key);

  @override
  State<ItemPageInfo> createState() => _ItemPageInfoState();
}

class _ItemPageInfoState extends State<ItemPageInfo> {
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    Widget itemButton = ElevatedButton(
      onPressed: widget.noAction
          ? null
          : () async {
              setState(() {
                loading = true;
              });
              ChatService chatService =
                  ChatService(); // Create an instance of ChatService
              String? sessionId = await chatService.createChatSession(
                  widget.itemData.id, widget.itemData);
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
                        chatSessionId: sessionId,
                        productId: widget.itemData.id,
                        sellerId: widget.itemData
                            .sellerId), // Ensure this matches the ChatPage constructor parameter name
                  ),
                );
                setState(() {
                  loading = false;
                });
              } else {
                if (kDebugMode) {
                  print("Failed to create chat session.");
                }
                // Optionally, show an error message to the user
              }
            },
      style: ElevatedButton.styleFrom(shape: const BeveledRectangleBorder()),
      child: const Text('Contact Seller'),
    );
    if (user.email == widget.itemData.sellerId) {
      var db = FirebaseFirestore.instance;
      itemButton = ElevatedButton(
        onPressed: widget.noAction
            ? null
            : () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Delete Post'),
                        content: const Text(
                            'Are you sure you want to delete your post. This will notify chat sessions associated with this item and will delete them from your inbox as well.'),
                        actions: [
                          TextButton(
                            onPressed: () async {
                              setState(() {
                                loading = true;
                              });
                              // "delete" the post
                              await deleteChats(widget.itemData.id);
                              await db
                                  .collection('items')
                                  .doc(widget.itemData.id)
                                  .update({"deletedAt": Timestamp.now()});
                              if (context.mounted) {
                                Navigator.pop(context);
                                Navigator.pop(context);
                              }
                              setState(() {
                                loading = true;
                              });
                            },
                            child: const Text('Click here to delete your post'),
                          ),
                        ],
                      );
                    });
              },
        style: ElevatedButton.styleFrom(
          shape: const BeveledRectangleBorder(),
          backgroundColor: Colors.red,
        ),
        child: const Text('Delete Post'),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.itemData.name,
                  style: const TextStyle(
                      fontSize: 32, fontWeight: FontWeight.bold)),
              Padding(
                padding: const EdgeInsets.only(bottom: 36),
                child: Text('\$${widget.itemData.price}',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.start),
              ),
              Text(
                  'Listed ${DateFormat('yMd').format(widget.itemData.createdAt)} at ${widget.itemData.schoolId}',
                  style: const TextStyle(fontSize: 16)),
              Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 4),
                  child: loading
                      ? const CircularProgressIndicator()
                      : Row(
                          children: widget.itemData.deletedAt != null &&
                                  widget.itemData.sellerId ==
                                      data_store.user.email
                              ? [
                                  const Text(
                                    'This item was deleted.',
                                    style: TextStyle(
                                        fontSize: 24, color: Colors.red),
                                  )
                                ]
                              : [
                                  itemButton,
                                  IconButton(
                                    icon: const Icon(Icons.favorite),
                                    selectedIcon: const Icon(Icons.favorite,
                                        color: Colors.red),
                                    iconSize: 36,
                                    tooltip: 'Add to wishlist',
                                    isSelected: data_store.user.wishlist
                                        .contains(widget.itemData.id),
                                    onPressed: widget.noAction
                                        ? null
                                        : () async {
                                            setState(() {
                                              loading = true;
                                            });
                                            if (data_store.user.wishlist
                                                .contains(widget.itemData.id)) {
                                              data_store.user.wishlist
                                                  .remove(widget.itemData.id);
                                            } else {
                                              data_store.user.wishlist
                                                  .add(widget.itemData.id);
                                            }
                                            await FirebaseFirestore.instance
                                                .collection('users')
                                                .doc(data_store.user.email)
                                                .update({
                                              'wishlist':
                                                  data_store.user.wishlist
                                            });
                                            setState(() {
                                              loading = false;
                                            });
                                          },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.flag),
                                    selectedIcon: const Icon(Icons.flag,
                                        color: Colors.orange),
                                    iconSize: 36,
                                    tooltip: widget.itemData.isFlagged
                                        ? 'Item is under review'
                                        : 'Report Item',
                                    isSelected: widget.itemData.isFlagged,
                                    onPressed: widget.noAction
                                        ? null
                                        : () async {
                                            if (widget.itemData.isFlagged)
                                              return;
                                            setState(() {
                                              loading = true;
                                            });
                                            await FirebaseFirestore.instance
                                                .collection('items')
                                                .doc(widget.itemData.id)
                                                .update({'isFlagged': true});
                                            widget.itemData.isFlagged = true;
                                            setState(() {
                                              loading = false;
                                            });
                                            if (context.mounted) {
                                              Navigator.of(context).pop();
                                              showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return const AlertDialog(
                                                      title: Text(
                                                          "Item has been reported"),
                                                      content: Text(
                                                          "The team will review the item to see if it contains questionable data. Please refresh the page to see new items."),
                                                    );
                                                  });
                                            }
                                          },
                                  ),
                                ],
                        )),
              const Divider(),
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text('About the product',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child:
                    Text('Product Description: ${widget.itemData.description}'),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text('Product Tags:'),
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    for (var tag in widget.itemData.tags)
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
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: AdvancedAvatar(
                        size: 96,
                        image: NetworkImage(widget.sellerProfilePic),
                      ),
                    ),
                    Text('Name: ${widget.sellerName}'),
                    Text('Items Sold: ${widget.sellerItemsSold ?? 0}'),
                    Text('Items Bought: ${widget.sellerItemsBought ?? 0}'),
                    widget.itemData.sellerId != data_store.user.email
                        ? !loading
                            ? ElevatedButton(
                                onPressed: widget.noAction
                                    ? null
                                    : () async {
                                        setState(() {
                                          loading = true;
                                        });
                                        if (data_store.user.blockedUsers
                                            .contains(
                                                widget.itemData.sellerId)) {
                                          return;
                                        }
                                        data_store.user.blockedUsers
                                            .add(widget.itemData.sellerId);
                                        await FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(data_store.user.email)
                                            .update({
                                          'blockedUsers':
                                              data_store.user.blockedUsers
                                        });
                                        var sellerUserObject =
                                            await FirebaseFirestore.instance
                                                .collection('users')
                                                .doc(widget.itemData.sellerId)
                                                .get();
                                        if (!sellerUserObject['blockedUsers']
                                            .contains(data_store.user.email)) {
                                          var blockedBySeller =
                                              sellerUserObject['blockedUsers'];
                                          blockedBySeller
                                              .add(data_store.user.email);
                                          await FirebaseFirestore.instance
                                              .collection('users')
                                              .doc(sellerUserObject['email'])
                                              .update({
                                            'blockedUsers': blockedBySeller
                                          });
                                        }
                                        var snapshots = await FirebaseFirestore
                                            .instance
                                            .collection('chat_sessions')
                                            .where('participantIds', whereIn: [
                                          [
                                            data_store.user.email,
                                            widget.itemData.sellerId
                                          ],
                                          [
                                            widget.itemData.sellerId,
                                            data_store.user.email
                                          ],
                                        ]).get();
                                        for (var snapshot in snapshots.docs) {
                                          await FirebaseFirestore.instance
                                              .collection('chat_sessions')
                                              .doc(snapshot.id)
                                              .update({
                                            'deletedByUsers':
                                                FieldValue.arrayUnion(
                                                    [data_store.user.email])
                                          });
                                        }
                                        await loadCurrentUser(
                                            data_store.user.email);
                                        setState(() {
                                          loading = false;
                                        });
                                        if (context.mounted) {
                                          Navigator.of(context).pop();
                                          showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return const AlertDialog(
                                                  title: Text("User Blocked"),
                                                  content: Text(
                                                      "You have blocked the user. Please reload the app to no longer view this user's content."),
                                                );
                                              });
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    shape: const BeveledRectangleBorder()),
                                child: const Text('Block this user'),
                              )
                            : const CircularProgressIndicator()
                        : const SizedBox(width: 0)
                  ],
                ),
              ),
            ]),
      ),
    );
  }
}
